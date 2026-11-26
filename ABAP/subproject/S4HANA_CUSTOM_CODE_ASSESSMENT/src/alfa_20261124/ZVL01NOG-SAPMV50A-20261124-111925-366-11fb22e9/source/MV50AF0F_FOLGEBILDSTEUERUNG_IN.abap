***INCLUDE MV50AF0F_FOLGEBILDSTEUERUNG_IN .
*---------------------------------------------------------------------*
*       FORM FOLGEBILDSTEUERUNG_INIT                                  *
*---------------------------------------------------------------------*
*   Definition von Parametern für die Bildfolgesteuerung:
*   - Verarbeitungsortes
*   - Arbeitsgebiet und Aktivitaetsklassifizierung
*   - CUA-Parameter fuer Action-Bar und Titel holen
*
*   Tabelle 180 muß gelesen sein
*   Der Aufruf dieses Teiles der Initialisierung einer Transaktion
*   ist für alle VLnn (00 <= nn <= 3 ) zwingend erforderlich
*
*---------------------------------------------------------------------*
FORM FOLGEBILDSTEUERUNG_INIT.

  T185-BLDGR      = T180-BLDGR.
  T185-PANEL      = T180-PANEL.

  T185F-AGIDV     = T180-AGIDV.
  MODUL-POOL+3(5) = T180-AGIDV.
  T185F-TRTYP     = T180-TRTYP.
  T185F-AKTYP     = T180-AKTYP.

  CALL FUNCTION 'CUA_PARAMETER_READ'
       EXPORTING
            PROGRAMM   = T185F-AGIDV
            BILDGRUPPE = T185-BLDGR
            BILD       = T185-PANEL
            TYP        = T185F-TRTYP
       IMPORTING
            CUA_STATUS = T185V-STATUS
            CUA_TITEL  = T185V-CTITEL
            CUA_PARA1  = T185V-PARA1
            CUA_PARA2  = T185V-PARA2
            CUA_PARA3  = T185V-PARA3
            CUA_PARA4  = T185V-PARA4.

ENDFORM.