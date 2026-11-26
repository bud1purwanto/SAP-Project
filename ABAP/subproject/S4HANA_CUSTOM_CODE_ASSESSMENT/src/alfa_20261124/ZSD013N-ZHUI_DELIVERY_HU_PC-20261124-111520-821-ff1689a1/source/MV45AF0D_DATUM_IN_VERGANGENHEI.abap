*---------------------------------------------------------------------*
*       FORM DATUM_IN_VERGANGENHEIT_PRUEFEN                           *
*---------------------------------------------------------------------*
*       Prüfen, ob ein Datum in der Vergangenheit liegt.              *
*---------------------------------------------------------------------*

FORM DATUM_IN_VERGANGENHEIT_PRUEFEN USING DP_DATUM.

  DATA: DP_DATUMC(10).

  CHECK DP_DATUM > 0.

  IF DP_DATUM < SY-DATLO.
    WRITE DP_DATUM TO DP_DATUMC DD/MM/YYYY.
    MESSAGE W437 WITH DP_DATUMC.
    message_collect_lord.
  ENDIF.

ENDFORM.