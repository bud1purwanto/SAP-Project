*---------------------------------------------------------------------*
*       FORM ZAHLUNGSKARTEN_BEARBEITEN                                *
*---------------------------------------------------------------------*
FORM ZAHLUNGSKARTEN_BEARBEITEN.
  CHECK NOT TVAK-RPART IS INITIAL.
  IF CCDATA NE *CCDATA OR
      ( CCARD_CVV-CVVAL NE XFPLT-CVVAL AND call_bapi is initial ).

  TABLES: FPLTVB.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA FPLA_TMP LIKE FPLA.
  DATA: DA_FPLTR_DELETE LIKE FPLT-FPLTR.

  CLEAR FPLAA.
  MOVE-CORRESPONDING VBAK TO FPLAA.
  IF VBAK-RPLNR IS INITIAL.
    CALL FUNCTION 'BILLING_SCHEDULE_GENERATE'
         EXPORTING
              I_FPLNR     = VBAK-RPLNR
              I_WAERS     = VBAK-WAERK
              I_FPART     = TVAK-RPART
              I_UPD_FPLA  = UPD_FPLA
              I_UPD_FPLT  = UPD_FPLT
              I_FPLA_ONLY = CHARX
         IMPORTING
              E_FPLNR     = VBAK-RPLNR
              E_DATALOSS  = DA_DATALOSS
              E_UPD_FPLA  = UPD_FPLA
              E_UPD_FPLT  = UPD_FPLT
         TABLES
              FPLA_NEW    = XFPLA
              FPLA_OLD    = YFPLA
              FPLT_NEW    = XFPLT
              FPLT_OLD    = XFPLT.
  ENDIF.

  MOVE VBAK-MANDT  TO FPLTVB-MANDT.
  MOVE VBAK-RPLNR  TO FPLTVB-FPLNR.
  READ TABLE XFPLT WITH KEY FPLNR = VBAK-RPLNR BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    MOVE XFPLT TO FPLTVB.
*   die erste merken, wenn mehr als eine
    ADD 1 TO SY-TABIX.
    READ TABLE XFPLT INDEX SY-TABIX.
    IF SY-SUBRC EQ 0 AND XFPLT-FPLNR EQ VBAK-RPLNR.
      DA_FPLTR_DELETE = FPLTVB-FPLTR.
    ENDIF.
  ELSE.
    FPLTVB-TYPZM = '0'.
  ENDIF.

  IF     CCDATA-CCINS IS INITIAL AND
         CCDATA-CCNUM IS INITIAL AND
         CCDATA-DATBI IS INITIAL AND
     NOT FPLTVB-FPLTR IS INITIAL.
*   Löschen gesamten Ratenplan oder Zeile, wenn mehr als eine Karte
    CALL FUNCTION 'BILLING_SCHEDULE_DELETE'
         EXPORTING
              I_FPLNR             = VBAK-RPLNR
              I_FPLTR             = DA_FPLTR_DELETE
              I_UPD_FPLA          = UPD_FPLA
              I_UPD_FPLT          = UPD_FPLT
         IMPORTING
              E_UPD_FPLA          = UPD_FPLA
              E_UPD_FPLT          = UPD_FPLT
              E_FPLNR             = VBAK-RPLNR
         TABLES
              FPLA_NEW            = XFPLA
              FPLA_OLD            = YFPLA
              FPLT_NEW            = XFPLT
              FPLT_OLD            = YFPLT
         EXCEPTIONS
              DELETE_NOT_POSSIBLE = 1
              OTHERS              = 2.
  ELSE.
    IF CCDATA-CCNUM NE FPLTVB-CCNUM AND
       NOT FPLTVB-CCARD_GUID IS INITIAL.
       CLEAR FPLTVB-CCARD_GUID.
    ENDIF.
    MOVE CCDATA-CCINS  TO FPLTVB-CCINS.
    MOVE CCDATA-CCNUM  TO FPLTVB-CCNUM.
    MOVE CCDATA-DATBI  TO FPLTVB-DATBI.
    MOVE CCDATA-CCNAME TO FPLTVB-CCNAME.
    MOVE CCARD_CVV-CVVAL TO FPLTVB-CVVAL.
    MOVE CCARD_CVV-CVVST TO FPLTVB-CVVST.
*   set currency
    MOVE VBAK-WAERK    TO FPLTVB-WAERS.
    CLEAR FPLTVB-CCTYP.                "Typ neu berechnen

    CALL FUNCTION 'BILLING_SCHEDULE_MAINTAIN'
         EXPORTING
              I_FPLT     = FPLTVB
              I_UPD_FPLT = UPD_FPLT
              I_FPLNR    = VBAK-RPLNR
         IMPORTING
              E_DATALOSS = DA_DATALOSS
              E_UPD_FPLA = UPD_FPLA
              E_UPD_FPLT = UPD_FPLT
         TABLES
              FPLA_OLD   = YFPLA
              FPLA_NEW   = XFPLA
              FPLT_OLD   = YFPLT
              FPLT_NEW   = XFPLT.

  ENDIF.
 ENDIF.
ENDFORM.                   " ZAHLUNGSKARTEN_BEARBEITEN  INPUT