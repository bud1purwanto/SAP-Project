*eject
*----------------------------------------------------------------------*
*       Form  EXPORT_AUSFUHR                                           *
*----------------------------------------------------------------------*
*       ==> SIMULATION : Simulationsmodus: JA - X,  NEIN - ' '         *
*----------------------------------------------------------------------*
*       Aufruf des Funktionsbausteins zur Durchführung der Export-     *
*       kontrolle:                                                     *
*       RV_EXPORT_CONTROL                                              *
*----------------------------------------------------------------------*
*       In diesem Funktionsbaustein wird jede Position auf ihre        *
*       "Ausfuhrgenehmigungsfaehigkeit" und "-pflicht" ueberprueft     *
*                                                                      *
*       Ergebnis dieser Pruefung :                                     *
*       - Setzen eines Ausfuhrsperr-CO-Status EXLS pro Position        *
*       - Fortschreibung der Tabelle                    XVBEX / YVBEX  *
*       - Fortschreibung der Werte im Genehmigungsstamm EMBK           *
*       - Protokoll-Tabelle                             EXANALY        *
*----------------------------------------------------------------------*
FORM EXPORT_AUSFUHR
     USING SIMULATION.

  DATA:  PROTOKOLL_AKTIV LIKE TVAK-EXDIA.

  IF (       CALL_FUNCTION IS INITIAL )      AND
     ( NOT ( SIMULATION    IS INITIAL ) OR
       NOT ( TVAK-EXDIA    IS INITIAL )    ) .
    PROTOKOLL_AKTIV = CHARX.
  ELSE.
    CLEAR: PROTOKOLL_AKTIV.
  ENDIF.

*-------Aufruf FB zur Ausfuhrkontrolle: Aufbau XVBEX, YVBEX
  CALL FUNCTION 'RV_EXPORT_CONTROL'
    EXPORTING
       SIMUL_FLG       = SIMULATION
       EXPORT_DATE_NEW = VBAK-VDATU
       EXPORT_DATE_OLD = YVBAK-VDATU
       ORDER_TYPE      = TVAK-VBTYP
       REDETERMINATION = AUSFUHR_NEU
       I_PROT_ACTIVE   = PROTOKOLL_AKTIV
       I_LOG_LEVEL     = TVAK-EXCLG
    TABLES
       I_XVBAP         = XVBAP         " Positionsdaten           -neu-
       I_YVBAP         = YVBAP         " Positionsdaten           -alt-
       I_XVBPA         = XVBPA         " Partner                  -neu-
       I_YVBPA         = YVBPA         " Partner                  -alt-
       I_XVBKD         = XVBKD         " Kaufmaennische Daten     -neu-
       I_YVBKD         = YVBKD         " Kaufmaennische Daten     -alt-
       I_XVBEP         = XVBEP         " Einteilungsdaten         -neu
       I_YVBEP         = YVBEP         " Einteilungsdaten         -alt-
       E_XVBEX         = XVBEX         " Ausfuhrgenehmigungsdaten -neu-
       E_YVBEX         = YVBEX         " Ausfuhrgenehmigungsdaten -alt-
       E_XEMBK         = XEMBK.        " Genehmigungsstamm-Fortschreib.

*-------Ruecksetzen des Kennzeichens: Neuablauf der Ausfuhrkontrolle
*-------Falls im Aenderungsmodus die Neuermittlung der Ausfuhrkontroll-
*-------daten angestoßen wurde, nachtraeglich aber Daten geändert
*-------wurden, laeuft die Ausfuhrkontrolle sowieso neu ab:
*-------Ruecksetzen des Kennzeichens, damit die AUsfuhrkontrolle nur
*-------hier einmal ablaeuft
  IF SIMULATION IS INITIAL.
    CLEAR: AUSFUHR_NEU.
  ENDIF.

ENDFORM.