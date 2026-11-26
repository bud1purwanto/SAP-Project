*---------------------------------------------------------------------*
*       FORM XVBPA_AUFBAUEN_VBPAKOM
*---------------------------------------------------------------------*
*       Die Belegpartnertabelle wird aus Kommunikationsfeldern
*       aufgebaut
*---------------------------------------------------------------------*
FORM XVBPA_AUFBAUEN_VBPAKOM USING US_VBPAKOM STRUCTURE VBPAKOM
                                  US_VBPA3KOM STRUCTURE VBPA3KOM.

  DATA: LVF_ADDRESS_NUMBER   TYPE   AD_ADDRNUM,
        DA_SUBRC             LIKE SY-SUBRC,
        DA_TABIX             LIKE SY-TABIX,
        LVS_VBPAVB           TYPE VBPAVB.
  DATA: LVF_PARVW            TYPE PARVW_4,
        LVF_PARNR            TYPE SD_PARTNER_PARNR,
        LVS_ADDR1_DATA       TYPE ADDR1_DATA,
        LVS_SADR             TYPE SADR,
        LVS_ADDR1_VAL        TYPE ADDR1_VAL,
        lvs_addr1_comm       type addr1_comm,
        LVF_OBJECTKEY        TYPE SWO_TYPEID.

* Vorerst können Partner nicht geändert werden
  if call_bapi is initial.
    check T180-TRTYP = charh or
    ( T180-TRTYP = CHARV AND
      CALL_ACTIVITY EQ ACTIVITY_INVOICE_REQUEST AND
      VBAK-VBKLT CA 'FG').
  endif.

  CLEAR XVBPA.
  MOVE-CORRESPONDING US_VBPAKOM TO XVBPA.
  move us_vbpakom-address_origin to xvbpa-adrda.
  XVBPA-MANDT = VBAK-MANDT.
  XVBPA-VBELN = VBAK-VBELN.
  XVBPAKEY = XVBPA.
  SORT XVBPA.
  IF XVBPA-PARVW NE 'AA' AND
     XVBPA-PARVW NE 'AW'.
    READ TABLE XVBPA WITH KEY XVBPAKEY BINARY SEARCH.
  ELSE.
    READ TABLE XVBPA WITH KEY MANDT = XVBPA-MANDT
                              VBELN = XVBPA-VBELN
                              POSNR = XVBPA-POSNR
                              PARVW = XVBPA-PARVW
                              KUNNR = XVBPA-KUNNR
                              BINARY SEARCH.
  ENDIF.
  DA_SUBRC = SY-SUBRC.
  DA_TABIX = SY-TABIX.

  CALL FUNCTION 'SD_VBPA_RECORD_FILL'
       EXPORTING
            FIS_VBPAKOM               = US_VBPAKOM
            FIS_VBPA3KOM              = US_VBPA3KOM
       IMPORTING
            FES_VBPAVB                = LVS_VBPAVB
       EXCEPTIONS
            INCORRECT_INPUT_PARAMETER = 1
            OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  if lvs_vbpavb-adrda is initial.
     lvs_vbpavb-adrda = us_vbpakom-address_origin.
  endif.

  MOVE-CORRESPONDING LVS_VBPAVB TO VBPA.
  MOVE-CORRESPONDING LVS_VBPAVB TO XVBPA.

  XVBPA-MANDT = VBAK-MANDT.
  XVBPA-VBELN = VBAK-VBELN.
  XVBPA-UPDKZ = UPDKZ_NEW.
  CASE DA_SUBRC.
    WHEN 0.
      MODIFY XVBPA INDEX DA_TABIX.
    WHEN 4.
      INSERT XVBPA INDEX DA_TABIX.
    WHEN 8.
      APPEND XVBPA.
  ENDCASE.
  XVBPA_AKTIND = da_tabix.

  CLEAR XVBADR.
  MOVE-CORRESPONDING US_VBPAKOM TO XVBADR.

  if not us_vbpakom-land1 is initial and
     not us_vbpakom-regio is initial and
     not us_vbpakom-pstlz is initial.
     perform xvbpa_determine_txjcd using us_vbpakom
                                changing xvbadr-txjcd
                                         xvbadr-ort01
                                         xvbadr-ort02.
  endif.

  VBADR = XVBADR.
  CLEAR: *VBADR.
   *VBADR-LZONE = VBADR-LZONE.
   *VBADR-LAND1 = VBADR-LAND1.
   *VBADR-ADDRESS_TYPE = VBADR-ADDRESS_TYPE.
   *VBADR-ADRNP = VBADR-ADRNP.
   *VBADR-ADRNR = VBADR-ADRNR.
* Wegen Problem mit 0 und space:
  IF VBADR-HAUSN = 0.
    VBADR-HAUSN = *VBADR-HAUSN.
  ENDIF.
  IF VBADR-TELF1 CO ' 0'.
    CLEAR VBADR-TELF1.
  ENDIF.
  IF VBADR-TELF2 CO ' 0'.
    CLEAR VBADR-TELF2.
  ENDIF.
  IF VBADR-TELFX CO ' 0'.
    CLEAR VBADR-TELFX.
  ENDIF.
  IF VBADR-TELTX CO ' 0'.
    CLEAR VBADR-TELTX.
  ENDIF.
  IF VBADR-TELX1 CO ' 0'.
    CLEAR VBADR-TELX1.
  ENDIF.

  IF VBADR NE *VBADR AND
     VBADR-ADRNR IS INITIAL.
    LVF_OBJECTKEY = VBAK-VBELN.

*   init new partner object
    CALL FUNCTION 'SD_PARTNER_DATA_PUT'
         EXPORTING
              FIC_OBJECTTYPE              = BUSINESSOBJEKT
              FIC_OBJECTKEY               = LVF_OBJECTKEY
         TABLES
              FRT_XVBPA                   = XVBPA
              FRT_YVBPA                   = YVBPA
              FRT_XVBUV                   = XVBUV
              FRT_HVBUV                   = HVBUV
              FRT_XVBADR                  = XVBADR
              FRT_YVBADR                  = YVBADR
         EXCEPTIONS
              NO_OBJECT_SPECIFIED         = 1
              NO_OBJECT_CREATION_POSSIBLE = 2
              OTHERS                      = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*   conversion of VBADR structure to ADDR1_DATA (CAM) structure

*   change address of partner
    LVF_PARVW = XVBPA-PARVW.
    CASE LVS_VBPAVB-NRART.
      WHEN 'KU'.
        LVF_PARNR = LVS_VBPAVB-KUNNR.
      WHEN 'LI'.
        LVF_PARNR = LVS_VBPAVB-LIFNR.
      WHEN 'AP'.
        LVF_PARNR = LVS_VBPAVB-PARNR.
      WHEN 'PE'.
        LVF_PARNR = LVS_VBPAVB-PERNR.
      WHEN OTHERS.
        LVF_PARNR = LVS_VBPAVB-ABLAD.
    ENDCASE.

    MOVE-CORRESPONDING VBADR TO LVS_SADR.

    CALL FUNCTION 'ADDR_CONVERT_SADR_TO_ADDR1_VAL'
         EXPORTING
              SADR      = LVS_SADR
         IMPORTING
              ADDR1_VAL = LVS_ADDR1_VAL.

    MOVE-CORRESPONDING LVS_ADDR1_VAL TO LVS_ADDR1_DATA.
    MOVE VBADR-TELBX to LVS_ADDR1_DATA-EXTENSION2.
*comm data
    MOVE lvs_sadr-telf1 TO lvs_addr1_comm-tel_number.
    MOVE lvs_sadr-telfx TO lvs_addr1_comm-fax_number.

    CALL FUNCTION 'SD_PARTNER_ADDRESS_SET'
         EXPORTING
              FIC_OBJECTTYPE       = BUSINESSOBJEKT
              FIC_OBJECTKEY        = LVF_OBJECTKEY
              FIF_PARVW            = LVF_PARVW
              FIF_POSNR            = XVBPA-POSNR
              FIF_PARNR            = LVF_PARNR
              FIS_ADDRESS_COMM_OTHERS = VBADR
         CHANGING
              FIS_ADDRESS          = LVS_ADDR1_DATA
              FIS_ADDRESS_COMM     = lvs_addr1_comm
         EXCEPTIONS
              PARAMETER_INCOMPLETE = 1
              OBJECT_NOT_FOUND     = 2
              PARTNER_NOT_FOUND    = 3
              CHANGE_NOT_POSSIBLE  = 4
              ADDRESS_NOT_OK       = 5
              OTHERS               = 6.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*   get partner tables back from partner object
    CALL FUNCTION 'SD_PARTNER_DATA_GET'
         EXPORTING
              FIC_OBJECTTYPE      = BUSINESSOBJEKT
              FIC_OBJECTKEY       = LVF_OBJECTKEY
              fic_xvbuv_merged    = charx
              fic_hvbuv_merged    = charx
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
*    CALL FUNCTION 'POSTAL_CODE_CHECK'
*         EXPORTING
*              COUNTRY            = XVBADR-LAND1
*              PO_BOX             = XVBADR-PFACH
*              POSTAL_CODE        = XVBADR-PSTLZ
*              POSTAL_CODE_PO_BOX = XVBADR-PSTL2
*              REGION             = XVBADR-REGIO.

  ELSEIF XVBADR IS NOT INITIAL.
    APPEND XVBADR.
  ENDIF.

ENDFORM.