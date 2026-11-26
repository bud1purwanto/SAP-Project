*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KUWEV_SELECT_DELIVERY                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KUWEV_SELECT_DELIVERY                                     *
*---------------------------------------------------------------------*
*       Warenempfänger aus der Datenbank lesen                        *
*       bei Lieferung ohne Auftragsbezug                              *
*---------------------------------------------------------------------*
FORM kuwev_select_delivery USING ks_kunnr LIKE kuwev-kunnr
                                 ks_subrc LIKE sy-subrc.

  DATA: lf_objectkey  TYPE swo_typeid.

  FIELD-SYMBOLS: <ls_xvbpa> TYPE vbpavb.                    "HP_356921

  lf_objectkey = likp-vbeln.

  CLEAR vtcom.
  vtcom-vbeln = likp-vbeln.                                 "HP_208786
  vtcom-kunnr = ks_kunnr.
  vtcom-parvw = parvw_we.
  IF ks_kunnr CO ' 0123456789'.
    UNPACK ks_kunnr TO vtcom-kunnr.
  ENDIF.
  vtcom-aland = tvst-aland.
  vtcom-vkorg = likp-vkorg.
  vtcom-vtweg = rv50a-vtweg.
  vtcom-spart = rv50a-spart.
  vtcom-pargr = tvlk-pargr.
  vtcom-vbobj = 'L'.

* Deliveries without reference: Use new logic to copy obligatory
* partners and to fill incompleteness log
  vtcom-kzsam = space.

  CALL FUNCTION 'VIEW_KUWEV_DELIVERY'
    EXPORTING
      comwa            = vtcom
    IMPORTING
      wewa             = kuwev
    TABLES
      tknvi            = kvi
      xsadr            = xvbadr
      xvbpa            = xvbpa
    EXCEPTIONS
      no_authorization = 1
      no_address       = 2
      OTHERS           = 3.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SD_PARTNER_DATA_PUT'                  "#EC ENHOK
    EXPORTING
      fic_objecttype              = 'LIKP'
      fic_objectkey               = lf_objectkey
    TABLES
      frt_xvbpa                   = xvbpa
      frt_xvbuv                   = xvbuv
      frt_xvbadr                  = xvbadr
    EXCEPTIONS
      no_object_specified         = 1
      no_object_creation_possible = 2
      OTHERS                      = 3.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SD_PARTNER_DOC_COMPLETE_CHECK'
    EXPORTING
      fic_objecttype       = 'LIKP'
      fic_objectkey        = lf_objectkey
      fif_check_all        = 'X'
    EXCEPTIONS
      object_not_found     = 1
      parameter_incomplete = 2
      OTHERS               = 3.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SD_PARTNER_DATA_GET'
    EXPORTING
      fic_objecttype      = 'LIKP'
      fic_objectkey       = lf_objectkey
      fic_xvbuv_merged    = 'X'
    TABLES
      fet_xvbuv           = xvbuv
      fet_xvbpa           = xvbpa
    EXCEPTIONS
      no_object_specified = 1
      no_object_found     = 2
      merge_failed        = 3
      OTHERS              = 4.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'FT_SLS_PARTNER_ADDR_MEM_FILL'
    TABLES
      i_t_vbpavb_partner_new = xvbpa
      i_t_sadrvb_address_new = xvbadr.

  LOOP AT xvbpa ASSIGNING <ls_xvbpa>.                       "HP_356921
    IF <ls_xvbpa>-parvw EQ 'AG'.
      likp-kunag = <ls_xvbpa>-kunnr.
    ENDIF.
    IF <ls_xvbpa>-parvw EQ 'WE'.
      likp-kunnr = <ls_xvbpa>-kunnr.
      gf_we_land1 = <ls_xvbpa>-land1.                       "HP_377160
      gf_we_lzone = <ls_xvbpa>-lzone.
      IF <ls_xvbpa>-ablad NE space.
        likp-ablad = <ls_xvbpa>-ablad.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM invoice_calendar_determine TABLES   xvbpa         "HP_383471
                                     USING    kuwev
                                     CHANGING likp-perfk.

ENDFORM.                    "kuwev_select_delivery
*---------------------------------------------------------------------*
*       FORM KUWEV_SELECT_DELIVERY_BATCH                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  KS_KUNNR                                                      *
*  -->  KS_ADRNR                                                      *
*  -->  KS_ADRDA                                                      *
*  -->  KS_SUBRC                                                      *
*---------------------------------------------------------------------*
FORM kuwev_select_delivery_batch USING ks_kunnr LIKE kuwev-kunnr
                                       ks_adrnr LIKE vbpa-adrnr
                                       ks_adrda LIKE vbpa-adrda
                                       ks_ablad LIKE kuwev-ablad
                                       ks_subrc LIKE sy-subrc.

  DATA: ls_knva LIKE knva.                                  "HP_321629

* Füllen Kommunikationsbereich
  CLEAR vtcom.
  vtcom-kunnr = ks_kunnr.
  vtcom-parvw = parvw_we.
  vtcom-adrnr = ks_adrnr.
  vtcom-adrda = ks_adrda.
  vtcom-ablad = ks_ablad.
  vtcom-noablad = charx.  "do not ask for unloading point if not given
  vtcom-vbeln = likp-vbeln.
  vtcom-posnr = posnr_low.
  vtcom-vkorg = likp-vkorg.
  vtcom-vtweg = rv50a-vtweg.
  vtcom-spart = rv50a-spart.
  vtcom-msgkz = 'U'.
  vtcom-aland = tvst-aland.                                 "SP_312451

* Aufruf Funktionsbaustein zum Füllen XVBPA
  CALL FUNCTION 'VIEW_XVBPA_FILL'
    EXPORTING
      comwa      = vtcom
      cpd_dialog = space
    IMPORTING
      pawa       = kupav
    TABLES
      xsadr      = xvbadr
      xvbpa      = xvbpa
    EXCEPTIONS
      error_message = 99                                    "v_n_643279
      no_kna1    = 04
      no_lfa1    = 08
      no_knvk    = 08
      no_pernr   = 08.

  IF sy-subrc = 99.
    ks_subrc = sy-subrc.
    EXIT.
  ENDIF.                                                    "^_n_643279

  CALL FUNCTION 'KOPIERTE_PARTNER_PRUEFEN'
    EXPORTING
      partnergruppe             = tvlk-pargr
      position                  = posnr_low
      referenz_beleg            = likp-vbeln
      verkaufsorganisation      = likp-vkorg
      vertriebsweg              = rv50a-vtweg
      sparte                    = rv50a-spart
      knref_nachlesen           = space
      rolle_fuer_nachlesen_knvp = 'WE'
*           no_dialog                 = v50agl-sammelgang     "n_558876
            no_dialog                 = v50agl-no_partner_dialog"628005
    TABLES
      tabelle_xvbpa             = xvbpa
            vbuv_tab                  = xvbuv
       EXCEPTIONS                                           "v_n_643279
            error_message             = 99
            .
  IF sy-subrc = 99.
    ks_subrc = sy-subrc.
    EXIT.
  ENDIF.                                                    "^_n_643279

* Fill unloading point if not filled from the interface
  IF vtcom-ablad IS INITIAL.                                "HP_321629
    CALL FUNCTION 'SD_PARTNER_ABLAD_SELECTION'
      EXPORTING
        fif_kunnr          = vtcom-kunnr
        fif_no_dialog      = 'X'
      IMPORTING
        fes_knva           = ls_knva
      EXCEPTIONS
        error_message      = 99                             "v_n_643279
        no_unloading_point = 1
        no_selection_done  = 2
        OTHERS             = 3.
    IF sy-subrc EQ 0.
      vtcom-ablad = ls_knva-ablad.
    ELSEIF sy-subrc = 99.
      ks_subrc = sy-subrc.
      EXIT.                                                 "^_n_643279
    ENDIF.
  ENDIF.

* Fill work area for ship-to party (VIEW_KUWEV is used in order to fill
* parameters concerning the unloading point)
  CALL FUNCTION 'VIEW_KUWEV'
    EXPORTING
      comwa      = vtcom
      manual_address = 'X'
    IMPORTING
      wewa       = kuwev
    EXCEPTIONS
      error_message = 99                                      "n_643279
      no_kna1    = 4
      no_knva    = 8
      no_knvi    = 8
      no_knvs    = 8
      no_knvv    = 8
      no_tpakd   = 8
      no_address = 8
      OTHERS     = 8.
  ks_subrc = sy-subrc.

ENDFORM.                    "kuwev_select_delivery_batch