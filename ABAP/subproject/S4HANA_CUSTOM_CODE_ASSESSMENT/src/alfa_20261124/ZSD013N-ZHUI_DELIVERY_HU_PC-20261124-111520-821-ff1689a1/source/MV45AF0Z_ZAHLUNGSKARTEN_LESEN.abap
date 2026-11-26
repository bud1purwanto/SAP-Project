*---------------------------------------------------------------------*
*       FORM ZAHLUNGSKARTEN_LESEN                                *
*---------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_LESEN
  TABLES   CH_FPLT   STRUCTURE FPLTVB
  USING    US_VBELN LIKE VBAK-VBELN
  CHANGING CH_FPLA  LIKE FPLA
           CH_RC    LIKE SY-SUBRC.
  CH_RC = 4.
  CLEAR CH_FPLA.
  CLEAR CH_FPLT. REFRESH CH_FPLT.

  CHECK NOT VBAK-RPLNR IS INITIAL.

  CALL FUNCTION 'BILLING_SCHEDULE_READ'
       EXPORTING
            FPLNR    = VBAK-RPLNR
*           I_VFKDAT =
*           I_BFKDAT =
       TABLES
            ZFPLA    = XFPLA
            ZFPLT    = XFPLT.
*
  LOOP AT XFPLT WHERE FPLNR EQ VBAK-RPLNR.
    MOVE XFPLT TO CH_FPLT. APPEND CH_FPLT.
  ENDLOOP.
  READ TABLE XFPLA WITH KEY FPLNR = VBAK-RPLNR BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    MOVE XFPLA TO CH_FPLA.
    CLEAR CH_RC.
  ENDIF.
ENDFORM.                   " ZAHLUNGSKARTEN_LESEN  INPUT