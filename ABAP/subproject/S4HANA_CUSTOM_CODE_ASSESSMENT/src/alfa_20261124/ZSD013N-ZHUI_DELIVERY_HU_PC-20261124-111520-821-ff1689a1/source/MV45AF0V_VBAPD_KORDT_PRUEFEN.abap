*&---------------------------------------------------------------------*
*&  Include           MV45AF0V_VBAPD_KORDT_PRUEFEN                     *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  VBAPD-KORDT_PRUEFEN
*&---------------------------------------------------------------------*
*       Prüfen, ob das Lieferdatum für eine Korrekturlieferung
*       gefüllt ist: Das Lieferdatum muß gefüllt sein, wenn eine
*       Korrekturmenge eingegeben wurde.
*----------------------------------------------------------------------*
FORM VBAPD-KORDT_PRUEFEN.

* Wenn Korrekturmenge gefüllt, muß auch -datum gefüllt sein.

  CHECK     VBAPD-KORDT  IS INITIAL AND
        NOT VBAPD-KORMNG IS INITIAL.

  MESSAGE E325(V4).

ENDFORM.                    " VBAPD-KORDT_PRUEFEN