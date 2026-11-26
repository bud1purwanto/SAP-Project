*&---------------------------------------------------------------------*
*&      Module  TXT_VTRBER_ERMITTELN_VBAP  OUTPUT
*&---------------------------------------------------------------------*
*       Beschreibungstext für Vertriebsbereich (Positionsebene)
*----------------------------------------------------------------------*
MODULE TXT_VTRBER_ERMITTELN_VBAP OUTPUT.
* Verkaufsorganisationstext ermitteln
  PERFORM TVKOT_SELECT USING VBAK-VKORG
                             SPACE
                             SY-SUBRC.
* Vertriebsweg-Text ermitteln
  PERFORM TVTWT_SELECT USING VBAK-VTWEG
                             SPACE
                             SY-SUBRC.
* Spartentext ermitteln
  PERFORM TSPAT_SELECT USING VBAP-SPART
                             SPACE
                             SY-SUBRC.
* Texte zusammenfügen
  PERFORM TXT_VTRBER_ZUSAMMENFUEGEN.

ENDMODULE.                 " TXT_VTRBER_ERMITTELNVBAP  OUTPUT