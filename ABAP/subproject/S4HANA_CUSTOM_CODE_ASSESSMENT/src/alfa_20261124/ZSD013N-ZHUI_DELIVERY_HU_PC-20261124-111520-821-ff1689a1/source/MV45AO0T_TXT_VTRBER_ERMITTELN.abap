*&---------------------------------------------------------------------*
*&      Module  TXT_VTRBER_ERMITTELN  OUTPUT
*&---------------------------------------------------------------------*
*       Beschreibungstext für Vertriebsbereich
*----------------------------------------------------------------------*
MODULE TXT_VTRBER_ERMITTELN OUTPUT.
* Verkaufsorganisationstext ermitteln
  PERFORM TVKOT_SELECT USING VBAK-VKORG
                             SPACE
                             SY-SUBRC.
* Vertriebsweg-Text ermitteln
  PERFORM TVTWT_SELECT USING VBAK-VTWEG
                             SPACE
                             SY-SUBRC.
* Spartentext ermitteln
  PERFORM TSPAT_SELECT USING VBAK-SPART
                             SPACE
                             SY-SUBRC.
* Texte zusammenfügen
  PERFORM TXT_VTRBER_ZUSAMMENFUEGEN.

ENDMODULE.                 " TXT_VTRBER_ERMITTELN  OUTPUT