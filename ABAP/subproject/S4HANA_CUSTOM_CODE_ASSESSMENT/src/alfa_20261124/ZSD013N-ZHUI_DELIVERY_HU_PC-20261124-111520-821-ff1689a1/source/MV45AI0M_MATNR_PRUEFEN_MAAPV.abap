*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MATNR_PRUEFEN_MAAPV                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MATNR_PRUEFEN_MAAPV  INPUT
*&---------------------------------------------------------------------*
*       Prüfen der Materialnummer bzgl. MAAPV --> MAAPV_SELECT
*----------------------------------------------------------------------*
MODULE  MATNR_PRUEFEN_MAAPV.

* Nur, wenn Material tatsächlich selektiert ist
  CHECK RV45A-VBAP_SELKZ EQ SELEKTIERT.

* Selektionskennzeichen für weitere Positionen zurücksetzen
  CLEAR RV45A-VBAP_SELKZ.

* Meldungen kommen nur bei vbap-matnr <> *vbvap-matnr
  CLEAR *VBAP-MATNR.

ENHANCEMENT-POINT MATNR_PRUEFEN_MAAPV_01 SPOTS ES_SAPMV45A STATIC.


ENHANCEMENT-SECTION     MATNR_PRUEFEN_MAAPV_02 SPOTS ES_SAPMV45A.
  PERFORM MAAPV_SELECT(SAPFV45P) USING VBAP-MATNR
                                       VBAK-VKORG
                                       VBAK-VTWEG
                                       CHARX
                                       SY-SUBRC.
END-ENHANCEMENT-SECTION.

  *VBAP-MATNR = VBAP-MATNR.

ENDMODULE.