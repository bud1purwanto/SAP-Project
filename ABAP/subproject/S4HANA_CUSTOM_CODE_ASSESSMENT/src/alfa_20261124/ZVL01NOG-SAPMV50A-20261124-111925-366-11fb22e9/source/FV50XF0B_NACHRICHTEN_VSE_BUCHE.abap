***INCLUDE FV50XF0B_NACHRICHTEN_VSE_BUCHE .
*---------------------------------------------------------------------*
*       FORM NACHRICHTEN_VSE_BUCHEN                                   *
*---------------------------------------------------------------------*
FORM NACHRICHTEN_VSE_BUCHEN.
  DATA: LS_OBJECT LIKE HUM_OBJECT.
* Versandelemente verbuchen
  CHECK NO_MESSAGES_UPDATE = SPACE.
  CHECK V50AGL-NO_MES_UPD_PACK = SPACE.                    "n_526239
  IF VBUK-PKSTK CA 'BC' OR PACKDATEN_VERBUCHEN = CHARX.
    IF XLIKP-VBTYP CA VBTYP_MMLI OR XLIKP-VBTYP CA VBTYP_LIRE.
      LS_OBJECT-OBJECT = '03'.
    ELSE.
      LS_OBJECT-OBJECT = '01'.
    ENDIF.
    LS_OBJECT-OBJKEY = XLIKP-VBELN.
    CALL FUNCTION 'V51P_MESSAGING_PACKING'
             EXPORTING
                  IS_OBJECT = LS_OBJECT
                  IS_VBUK   = VBUK
                  IT_VBPA   = XVBPA[]
             EXCEPTIONS
                  NO_HU_FOUND = 01
                  OTHERS      = 99.
    CHECK SY-SUBRC IS INITIAL.
  ENDIF.
ENDFORM.