*---------------------------------------------------------------------*
*       FORM T001W_SELECT                                             *
*---------------------------------------------------------------------*
*       Werkstabelle lesen                                            *
*---------------------------------------------------------------------*
FORM T001W_SELECT USING US_WERKS
                        US_ERROR
                        CH_SUBRC.

  DATA:
    DA_OWN_LS TYPE OWN_LS.

  CH_SUBRC = 0.

  CHECK US_WERKS NE T001W-WERKS
     OR T001W-BWKEY NE T001K-BWKEY.

  IF US_WERKS = SPACE.
    CLEAR:
      T001W,
      T001K.
    EXIT.
  ENDIF.

  CALL FUNCTION 'AIP01_PLANT_DETERMINE'
       EXPORTING
            I_WERKS      = US_WERKS
       IMPORTING
            E_OWNLS      = DA_OWN_LS
            ES_T001W_EXT = T001W_EXT
       EXCEPTIONS
            OTHERS       = 1.

  IF SY-SUBRC NE 0.
    PERFORM T001W_SELECT_ERROR USING US_WERKS US_ERROR CH_SUBRC.

  ELSEIF DA_OWN_LS EQ CHARX.
    CLEAR T001W_EXT-LOGSYS.
    SELECT SINGLE * FROM T001W WHERE WERKS = US_WERKS.
    IF SY-SUBRC NE 0.
      PERFORM T001W_SELECT_ERROR USING US_WERKS US_ERROR CH_SUBRC.
    ELSEIF T001W-KUNNR EQ KUAGV-KUNNR AND NOT T001W-KUNNR IS INITIAL.
      CLEAR: US_WERKS, T001W_EXT, T001W, T001K.
      CH_SUBRC = 4.
      IF US_ERROR EQ CHARX.
        SET CURSOR FIELD 'VBAP-WERKS' LINE SY-STEPL.
        MESSAGE E755.
      ENDIF.
    ELSE.
      PERFORM T001K_SELECT USING T001W-BWKEY US_ERROR CH_SUBRC.
      IF CH_SUBRC NE 0.
        PERFORM T001W_SELECT_ERROR USING US_WERKS US_ERROR CH_SUBRC.
      ENDIF.
    ENDIF.

  ELSE.
    IF NOT VBAK-ABDIS IS INITIAL OR VBAK-VBTYP CA VBTYP_PBED.
      PERFORM T001W_SELECT_ERROR USING US_WERKS US_ERROR CH_SUBRC.

    ELSE.
*
      CLEAR T001W.
      T001W-MANDT = T001W_EXT-MANDT.
      T001W-WERKS = T001W_EXT-WERKS.
      T001W-NAME1 = T001W_EXT-NAME1.
      T001W-BWKEY = T001W_EXT-WERKS.
      T001W-LIFNR = T001W_EXT-LIFNR.
      T001W-NAME2 = T001W_EXT-NAME2.
      T001W-VKORG = T001W_EXT-VKORG.
      T001W-LAND1 = T001W_EXT-LAND1.
      T001W-VTWEG = T001W_EXT-VTWEG.
      T001W-SPART = T001W_EXT-SPART.
      T001W-ADRNR = T001W_EXT-ADRNR.
      CLEAR T001K.
      T001K-MANDT = T001W_EXT-MANDT.
      T001K-BWKEY = T001W_EXT-WERKS.
      T001K-BUKRS = T001W_EXT-BUKRS.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM T001W_SELECT_ERROR                                       *
*---------------------------------------------------------------------*
FORM T001W_SELECT_ERROR USING US_WERKS US_ERROR CH_SUBRC.

  CLEAR:
    T001W_EXT,
    T001W,
    T001K.
  CH_SUBRC = 4.

  IF US_ERROR EQ CHARX.
    SET CURSOR FIELD 'VBAP-WERKS' LINE SY-STEPL.
    MESSAGE E326 WITH US_WERKS.
  ENDIF.

ENDFORM.