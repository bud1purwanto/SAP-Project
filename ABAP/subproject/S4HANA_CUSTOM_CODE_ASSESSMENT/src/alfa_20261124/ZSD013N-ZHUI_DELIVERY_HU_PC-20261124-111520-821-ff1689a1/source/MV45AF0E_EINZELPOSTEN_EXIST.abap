*----------------------------------------------------------------------*
*   INCLUDE MV45AF0E_EINZELPOSTEN_EXIST                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  EINZELPOSTEN_EXIST
*&---------------------------------------------------------------------*
*       Prüfung, ob es aufwandsbezogene Faktura oder Angebotserstellung
*       ist
*----------------------------------------------------------------------*
*      <-- I_VBKLT     Vertriebsbelegkennzeichnung
*      <-- I_VKGRU     Klassifizierung von Positionen
*      --> CH_AUFWAND  'X' bei aufwandsbezogenem Vorgang
*----------------------------------------------------------------------*
FORM EINZELPOSTEN_EXIST USING    I_VBKLT LIKE VBAK-VBKLT
                                 I_VKGRU LIKE VBAP-VKGRU
                        CHANGING CH_AUFWAND.

  CLEAR CH_AUFWAND.

  IF I_VBKLT CA  VBKLT_FAKT_ANF OR
     I_VKGRU EQ VKGRU_DYN_POSTEN OR
     I_VKGRU EQ VKGRU_DYN_POSTEN_AG.
    CH_AUFWAND = CHARX.
  ENDIF.

ENDFORM.                               " EINZELPOSTEN_EXIST