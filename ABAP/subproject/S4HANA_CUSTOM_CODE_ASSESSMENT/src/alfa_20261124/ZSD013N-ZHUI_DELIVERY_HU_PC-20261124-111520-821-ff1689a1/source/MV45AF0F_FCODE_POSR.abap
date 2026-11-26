*---------------------------------------------------------------------*
*       FORM FCODE_POSR                                               *
*---------------------------------------------------------------------*
*       Sales Order Status Report per FCODE                           *
*                                                                     *
*---------------------------------------------------------------------*
FORM FCODE_POSR USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  DATA: DA_BELNR LIKE MDPS-DEL12,
        DA_POSNR LIKE MDPS-DELPS,
        DA_AVAIL_CHECK LIKE RM61M-DSELK,
        DA_SAVETY_STOCK LIKE RM61O-SSTNO.
  DATA: DA_PROFID LIKE TCOAF-PROFID,
        BLANK VALUE ''.

  DA_BELNR = VBAP-VBELN.
  DA_POSNR = VBAP-POSNR.

* Falls kundenspezifische Belegung der Parameter availability_check und
* no_savety_stock gewünscht werden sollte, kann hier der User Exit
* eingebaut werden:
  DA_AVAIL_CHECK  = ' '.
  DA_SAVETY_STOCK = ' '.

* Auftragsfortschrittsbericht aufrufen
  SET PARAMETER ID 'WRK' FIELD VBAP-WERKS.
  SET PARAMETER ID 'AUN' FIELD VBAP-VBELN.
  SET PARAMETER ID 'KPO' FIELD VBAP-POSNR.
  SET PARAMETER ID 'MAT' FIELD VBAP-MATNR.
  SET PARAMETER ID 'PRO' FIELD BLANK.
  SET PARAMETER ID 'PSP' FIELD BLANK.
  SET PARAMETER ID 'ANR' FIELD BLANK.
  SET PARAMETER ID 'PAF' FIELD BLANK.
  GET PARAMETER ID 'PIL' FIELD DA_PROFID.

  IF DA_PROFID IS INITIAL.
    SELECT SINGLE PROFID FROM TCOAF INTO DA_PROFID.
    IF SY-SUBRC IS INITIAL.
      SET PARAMETER ID 'PIL' FIELD DA_PROFID.
    ELSE.
      MESSAGE I858.
      T185F-FCODE = FCODE_ZURUECK.
      H185  = T185.
      H185F = T185F.
      H185V = T185V.
      EXIT.
    ENDIF.
  ENDIF.

  CALL TRANSACTION 'CO46' AND SKIP FIRST SCREEN.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  T185F-FCODE = FCODE_ZURUECK.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.