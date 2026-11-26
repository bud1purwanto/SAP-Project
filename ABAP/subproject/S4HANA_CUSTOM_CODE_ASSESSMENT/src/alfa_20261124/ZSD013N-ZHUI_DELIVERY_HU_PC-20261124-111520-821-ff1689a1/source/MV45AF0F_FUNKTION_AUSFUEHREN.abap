*---------------------------------------------------------------------*
*       FORM FUNKTION_AUSFUEHREN                                      *
*---------------------------------------------------------------------*
*       Eine Funktion vom Typ 1 (in T185F) wird ausgeführt            *
*---------------------------------------------------------------------*
FORM FUNKTION_AUSFUEHREN.

  DATA: FLAG-LEAVE_SCREEN.
ENHANCEMENT-POINT FUNKTION_AUSFUEHREN_20 SPOTS ES_SAPMV45A.

  OLD_FCODE = FCODE.

* Set-Parameter für Matchcodesuche setzen
  IF NOT TVTA-VTWKU IS INITIAL.
    SET PARAMETER ID 'VTU' FIELD TVTA-VTWKU.
  ENDIF.

* Wenn das Flag sitzt, muß Sicherheitsabfrage durchgeführt werden
  IF SY-DATAR NE SPACE AND SY-DYNGR NE DYNGR_ANFORDERUNG.
    R185D-DATALOSS = SY-DATAR.
  ENDIF.

  IF CALL_DIALOG NE SPACE AND
     FCODE = 'BAC1'.
    FCODE = FCODE_ZURUECK.
  ENDIF.

ENHANCEMENT-POINT FUNKTION_AUSFUEHREN_02 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT FUNKTION_AUSFUEHREN_01 SPOTS ES_SAPMV45A.

* GUI 4.0:
* Die neuen Bilder sind in der Folgebildsteuerung im Programm
* SAPMV45B. Die Folgebildsteuerung verläßt sich aber auf die
* Struktur r185d, die sie jetzt in SAPMV45B sucht. Aus diesem
* Grund wird eine Dummy-Routine aufgerufen, die dafür sorgt, daß
* die Daten dort auch vorhanden sind.

  PERFORM DUMMY_SAPMV45B(SAPMV45B).

  CALL FUNCTION 'FUNCTION_EXECUTE'
       EXPORTING
            PROGRAMM        = T180-AGIDV
            KOPFGRUPPE      = TVAK-KOPGR
            POSITIONSGRUPPE = TVAP-POSGR
            FUNKTION        = FCODE
       IMPORTING
            CUA_STATUS      = T185V-STATUS
            CUA_TITEL       = T185V-CTITEL
            CUA_PARA1       = T185V-PARA1
            CUA_PARA2       = T185V-PARA2
            CUA_PARA3       = T185V-PARA3
            CUA_PARA4       = T185V-PARA4
            FOLGEFUNKTION   = FCODE
            DUNKEL          = T185-DUNKEL
            LEAVE           = FLAG-LEAVE
            LEAVE_SCREEN    = FLAG-LEAVE_SCREEN.

ENHANCEMENT-POINT FUNKTION_AUSFUEHREN_03 SPOTS ES_SAPMV45A.
  IF FLAG-LEAVE NE SPACE.
    T185F-FCODE = FCODE.
    LEAVE.
  ENDIF.
  IF FLAG-LEAVE_SCREEN NE SPACE.
    T185F-FCODE = FCODE.
ENHANCEMENT-POINT FUNKTION_AUSFUEHREN_10 SPOTS ES_SAPMV45A.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.