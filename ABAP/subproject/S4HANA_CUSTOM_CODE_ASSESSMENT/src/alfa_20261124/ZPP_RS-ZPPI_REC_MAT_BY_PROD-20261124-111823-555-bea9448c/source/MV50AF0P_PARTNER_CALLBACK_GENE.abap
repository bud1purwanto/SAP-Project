*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_CALLBACK_GENE                             *
*----------------------------------------------------------------------*
* This callback routine is processed whenever partner data are changed
* via function group V09A/B/C

FORM PARTNER_CALLBACK_GENERAL
                   TABLES IT_CHANGES  TYPE LV09A_CHANGED_VALUES
                    USING IF_EVENT    TYPE SD_PARTNER_CALL_BACK_EVENT
                          IF_ROLETYPE TYPE SD_PARTNER_ROLETYPE
                          IF_POSNR    TYPE POSNR.

  DATA: LF_SAVE_ROUTE LIKE LIKP-ROUTE,
        LS_VBPA_WE LIKE VBPAVB,
        LS_SADR LIKE SADRVB,
        LS_VBPA_LF LIKE VBPAVB,
        ls_changes like line of it_changes,                   "n_1685675
        LF_OBJECTKEY TYPE SWO_TYPEID.

  PERFORM LIKP_BEARBEITEN_VORBEREITEN(SAPFV50K).
  LF_OBJECTKEY = LIKP-VBELN.

  CALL FUNCTION 'SD_PARTNER_DOC_COMPLETE_CHECK'
       EXPORTING
            FIC_OBJECTTYPE       = 'LIKP'
            FIC_OBJECTKEY        = LF_OBJECTKEY
            FIF_CHECK_ALL        = 'X'
       EXCEPTIONS
            OBJECT_NOT_FOUND     = 1
            PARAMETER_INCOMPLETE = 2
            OTHERS               = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CALL FUNCTION 'SD_PARTNER_DATA_GET'
    EXPORTING
      FIC_OBJECTTYPE      = 'LIKP'
      FIC_OBJECTKEY       = LF_OBJECTKEY
      FIC_XVBUV_MERGED    = 'X'
      FIC_HVBUV_MERGED    = 'X'
    TABLES
      FET_XVBPA           = XVBPA
      FET_YVBPA           = YVBPA
      FET_XVBUV           = XVBUV
      FET_HVBUV           = HVBUV
      FET_XVBADR          = XVBADR
      FET_YVBADR          = YVBADR
    EXCEPTIONS
      NO_OBJECT_SPECIFIED = 1
      NO_OBJECT_FOUND     = 2
      MERGE_FAILED        = 3
      OTHERS              = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Update vendor information for inbound deliveries
  IF LIKP-VBTYP CA VBTYP_MMLI.
    READ TABLE XVBPA INTO LS_VBPA_LF
                     WITH KEY VBELN = LIKP-VBELN
                              POSNR = POSNR_LOW
                              PARVW = PARVW_LF.
    IF SY-SUBRC EQ 0.
      LIKP-LIFNR  = LS_VBPA_LF-LIFNR.                          "n_674761
      KUWEV-NAME1 = LS_VBPA_LF-NAME1.
      KUWEV-LAND1 = LS_VBPA_LF-LAND1.
    ENDIF.
  ELSE.
*   Fill communication structure for ship-to party
    PERFORM WARENEMPFAENGER_BEREITSTELLEN.
  ENDIF.

  READ TABLE XVBPA INTO LS_VBPA_WE
                   WITH KEY VBELN = LIKP-VBELN
                            POSNR = POSNR_LOW
                            PARVW = PARVW_WE.
  IF SY-SUBRC EQ 0.

    LIKP-ABLAD = LS_VBPA_WE-ABLAD.

*   Check whether ship-to party has been changed
    IF LIKP-KUNNR NE LS_VBPA_WE-KUNNR.
      LIKP-KUNNR = LS_VBPA_WE-KUNNR.
    ENDIF.

*   Perform new route determination since parts of the ship-to address
*   may have been changed
    IF TVLK-ROUTF NE SPACE AND
       ( GF_WE_LAND1 NE LS_VBPA_WE-LAND1 OR
         GF_WE_LZONE NE LS_VBPA_WE-LZONE ).                 "HP_377160
      LF_SAVE_ROUTE = LIKP-ROUTE.
      PERFORM ROUTE_ERMITTELN(SAPFV50K) USING LIKP-ROUTE
                                        SPACE
                                        SY-SUBRC.
      IF SY-SUBRC EQ 0.
        IF LF_SAVE_ROUTE NE LIKP-ROUTE.
*         In case of a new route the route schedule may be
*         inconsistent to this route. It is therefore deleted.
          CLEAR LIKP-AULWE.
          MESSAGE I466 WITH LIKP-ROUTE.
          PERFORM RESCHEDULE_EXECUTE.
        ENDIF.
      ELSE.
        LIKP-ROUTE = LF_SAVE_ROUTE.
      ENDIF.
    ENDIF.

*   Update items if Address entered in document manually was changed
*   (Address fields have to be transferred to APO via field catalog)
    IF LS_VBPA_WE-ADRDA CA 'BCEF'.
      READ TABLE XVBADR INTO LS_SADR WITH KEY ADRNR = LS_VBPA_WE-ADRNR.
      IF SY-SUBRC EQ 0 AND LS_SADR-UPDKZ EQ UPDKZ_UPDATE.
        PERFORM MARK_ITEMS_FOR_UPDATE_EXTENDED.
      ENDIF.
    ENDIF.

  ENDIF.

* Redetermination of export data
  IF GF_WE_LAND1 NE LS_VBPA_WE-LAND1.                       "HP_377160
    PERFORM EXPORT_DATA_REDETERMINE.                        "HP_320996
  ENDIF.

* Save current ship-to parameters for detecting changes
  GF_WE_LAND1 = LS_VBPA_WE-LAND1.                           "HP_377160
  GF_WE_LZONE = LS_VBPA_WE-LZONE.

* Check whether sales-to party has been changed
  READ TABLE XVBPA WITH KEY VBELN = LIKP-VBELN
                            POSNR = POSNR_LOW
                            PARVW = PARVW_AG.
  IF SY-SUBRC EQ 0.
    LIKP-KUNAG = XVBPA-KUNNR.
  ELSE.                                                      "n_715021
    CLEAR LIKP-KUNAG.                                        "n_715021
  ENDIF.

* Lines deleted n_531900

* In case of a delivery w/o reference: Determine invoice calendar
* only for outbound deliveries -> note 1227877
  IF LIEFERUNG_OR EQ CHARX AND                              "HP_383471
     LIKP-VBTYP NA VBTYP_MMLI.                              "n_1227877
    PERFORM INVOICE_CALENDAR_DETERMINE TABLES   XVBPA
                                       USING    KUWEV
                                       CHANGING LIKP-PERFK.
  ENDIF.

  CALL FUNCTION 'FT_SLS_PARTNER_ADDR_MEM_FILL'
    TABLES
      I_T_VBPAVB_PARTNER_NEW = XVBPA
      I_T_VBPAVB_PARTNER_OLD = YVBPA
      I_T_SADRVB_ADDRESS_NEW = XVBADR
      I_T_SADRVB_ADDRESS_OLD = YVBADR.

* update time zone from address data                      "v_n_1685675
  if lieferung_or eq charx or
     likp-vbtyp   na vbtyp_mmli and
     if_roletype  eq '0002'.   "ship-to

    read table it_changes into ls_changes
                          with key fieldname = 'TIME_ZONE'.
    if sy-subrc eq 0.
      likp-tzonrc = ls_changes-new_value(6).
    endif.
   endif.                                                  "^_n_1685675

  IF R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = CHARX.
  ENDIF.

  PERFORM LIKP_BEARBEITEN(SAPFV50K).

  PERFORM UC_UPD_REQUEST(SAPFV50U) USING CHARX POSNR_LOW    "n_531900
                                         POSNR_LOW POSNR_LOW.

  PERFORM BUILD_ADDRESS_DIALOG.                             "n_532800

ENDFORM.                    "partner_callback_general