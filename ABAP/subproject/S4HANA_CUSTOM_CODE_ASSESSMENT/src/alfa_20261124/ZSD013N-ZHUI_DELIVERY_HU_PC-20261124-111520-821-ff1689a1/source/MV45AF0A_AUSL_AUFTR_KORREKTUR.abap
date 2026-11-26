*----------------------------------------------------------------------*
*   INCLUDE MV45AF0A_AUSL_AUFTR_KORREKTUR                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  AUSLIEFERUNGSAUFTRAG_KORREKTUR
*&---------------------------------------------------------------------*
*       SUBRC 91 setzen für Vorplanungszuordnung bei
*       Auslieferungsauftrags-Korrektur
*----------------------------------------------------------------------*
FORM AUSLIEFERUNGSAUFTRAG_KORREKTUR CHANGING US_SUBRC_LF.

  CHECK VBAK-VBKLT EQ VBKLT_AUSL_AUFT_KORR.

  US_SUBRC_LF = 91.

ENDFORM.                               " AUSLIEFERUNGSAUFTRAG_KORREKTUR