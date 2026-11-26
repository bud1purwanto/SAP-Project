*---------------------------------------------------------------------*
*       FORM STARTWERTE_SETZEN                                        *
*---------------------------------------------------------------------*
*       Initialisierungen Startwerte                                  *
*---------------------------------------------------------------------*
FORM STARTWERTE_SETZEN.

  VBAK-MANDT = SY-MANDT.

*-Initialisierung verschiedener Groessen -----------------------------*
  MODUL-POOL = T180-AGIDV.

  T185F-AGIDV = MODUL-POOL.
  FCODE = T185F-FCODE.
* CUA-Parameter fuer Action-Bar und Titel holen
* zusätzlich wird der Transaktionstyp übergeben --> im PAI muß nur
* noch die Routine FCODE_BERABEITEN gerufen werden (QVH 250391)
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

* Dynamisch Schlüsselwörter und Texte setzen
  PERFORM SCHLUESSELWORTE_SETZEN USING VBAK-TRVOG.

* Je nach Transaktionstyp gewisse Fcodes deaktivieren: Tabelle füllen
  IF CALL_FUNCTION = SPACE.
    PERFORM EXCLUDE_FUNCTION_TRTYP.
  ENDIF.

ENDFORM.