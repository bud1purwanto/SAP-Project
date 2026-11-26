*---------------------------------------------------------------------*
*       FORM DATUM_PRUEFEN_GUELTIGKEIT.                               *
*---------------------------------------------------------------------*
*       Prüfen, ob ein Datum im Gültigkeitszeitraum liegt             *
*---------------------------------------------------------------------*

FORM DATUM_PRUEFEN_GUELTIGKEIT USING DP_DATUM
                                     DP_ANGDT
                                     DP_GUEBG
                                     DP_GUEEN.

  DATA: DP_DATUMC(10).

  CHECK DP_DATUM > 0.

  IF DP_DATUM < DP_ANGDT.
    WRITE DP_ANGDT TO DP_DATUMC DD/MM/YYYY.
    IF VBAK-VBTYP CA VBTYP_ANGE.
      MESSAGE W446 WITH DP_DATUMC.
    ELSE.
      MESSAGE W447 WITH DP_DATUMC.
    ENDIF.
    message_collect_lord.
  ENDIF.

  IF VBAK-ABDIS NE SPACE AND
     SY-BINPT   EQ CHARX.
    DATA: DA_BDCRUN LIKE BDCRUN.

    CALL FUNCTION 'BDC_RUNNING'
         IMPORTING
              BI_INFO         = DA_BDCRUN
         EXCEPTIONS
              BI_INVALID_DATA = 1
              BI_NOTAKTIV     = 2
              OTHERS          = 3.

    IF SY-SUBRC <> 0.
      CLEAR DA_BDCRUN.
    ENDIF.
  ENDIF.

  IF DP_DATUM < DP_GUEBG.
    WRITE DP_GUEBG TO DP_DATUMC DD/MM/YYYY.
    IF VBAK-ABDIS       NE SPACE AND
       DA_BDCRUN-CTU_AMODUS EQ 'N'.
*     Dunkles Einspielen eines Zuliefererlieferplans erzeugt einen
*     Error, damit keine ungültigen Einteilungen ohne Kenntnis
*     des Benutzers eingespielt werden können
      MESSAGE E447 WITH DP_DATUMC.
    ELSE.
      MESSAGE W447 WITH DP_DATUMC.
      message_collect_lord.
    ENDIF.
  ENDIF.

ENHANCEMENT-SECTION     MV45_DATUM_PRU_GUE SPOTS ES_SAPMV45A.
  IF DP_DATUM > DP_GUEEN AND
     DP_GUEEN > 0.
    WRITE DP_GUEEN TO DP_DATUMC DD/MM/YYYY.
    IF VBAK-ABDIS    NE SPACE AND
       DA_BDCRUN-CTU_AMODUS EQ 'N'.
*     Dunkles Einspielen eines Zuliefererlieferplans erzeugt einen
*     Error, damit keine ungültigen Einteilungen ohne Kenntnis
*     des Benutzers eingespielt werden können
      MESSAGE E448 WITH DP_DATUMC.
    ELSE.
      MESSAGE W448 WITH DP_DATUMC.
      message_collect_lord.
    ENDIF.
  ENDIF.
END-ENHANCEMENT-SECTION.

ENDFORM.