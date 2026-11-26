*eject
*&---------------------------------------------------------------------*
*&      Form  MONTAGE_INIT
*&---------------------------------------------------------------------*
*       Montage initialisieren wenn angefordert                        *
*----------------------------------------------------------------------*
FORM MONTAGE_INIT.

* Bereiche die immer initialisiert werden
* alle Statustabellen refreshen
  CALL FUNCTION 'STATUS_BUFFER_REFRESH'.

* Prüfen ob Montage im Spiel war (CO61)
  IF RV45A-MONTAGE_INIT IS INITIAL.
    CALL FUNCTION 'CO_61_CHECK_ASSEMBLY_USED'
         EXPORTING
              RESET_IMP = CHARX
         EXCEPTIONS
              NOT_USED  = 1
              OTHERS    = 2.
    IF SY-SUBRC = 0.
      RV45A-MONTAGE_INIT = CHARX.
    ENDIF.
  ENDIF.

* Bereiche die nur initialisiert werden wenn Montage aktiv war
* oder z.B. Kalkulation / Konfiguration aufgerufen wurde
  CHECK NOT RV45A-MONTAGE_INIT IS INITIAL.

* PP-Aufträge, PS-Aufträge, INST-Aufträge
  CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'.

* Projekte, Projektstrukturplan
  CALL FUNCTION 'CJWI_INIT'.

* Planaufträge
  CALL FUNCTION 'REFRESH_PLAFX_TABLES'.

* Initialisierungsflag zurücksetzen
  CLEAR RV45A-MONTAGE_INIT.

ENDFORM.