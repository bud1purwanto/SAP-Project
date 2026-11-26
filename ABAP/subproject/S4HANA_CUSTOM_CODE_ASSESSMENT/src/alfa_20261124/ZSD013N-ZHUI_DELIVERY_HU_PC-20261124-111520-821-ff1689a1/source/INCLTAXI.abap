*----------------------------------------------------------------------*
*   INCLUDE INCLTAXI                                                   *
*   ****************************************************************   *
*   *   Belongs to the Tools for using tAbstrips a-X applications  *   *
*   *   NEVER CHANGE IT, PLEASE!  MAKE A COPY, IF CHANGES ARE      *   *
*   *   NECESSARY!                                                 *   *
*   ****************************************************************   *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Deklaration der Schnittstellenvariablen zwischen Auftraggeber und    *
* Detailbildbereitsteller                                              *
*----------------------------------------------------------------------*

* Eingang:
CONTROLS  TAXI_TABSTRIP TYPE TABSTRIP.                          " (1)
TABLES    TAXI_TABSTRIP_CAPTIONS.                               " (2)
DATA:     TAXI_PROGRAM           LIKE SY-REPID,                 " (3)
          TAXI_HEADER_SUBSCREEN  LIKE TAXI_PARAMS-DYNPRONR,     " (4)
          TAXI_GUI_PROGRAM       LIKE SY-REPID,                 " (5)
          TAXI_GUI_STATUS        LIKE TAXI_PARAMS-GUI_STATUS,   " (6)
          TAXI_GUI_TITLE         LIKE TAXI_PARAMS-GUI_TITLE,    " (7)
          TAXI_GUI_TITLE_PARAM   LIKE TAXI_PARAMS-TITLE_PARAM.  " (8)
* Ausgang:
DATA      TAXI_FCODE LIKE TAXI_PARAMS-FCODE.                       " (9)

* (1) Steuerstruktur des Tabstrip-Controls (enthält Funktionscode
*     des aktiven Reiters und die Scrollposition der Reiterleiste)
* (2) Feldleiste zur Aufnahme der Reiterbeschriftungen des Tabstrip-
*     Controls (Felder sind verknüpft mit Reitern des Tabstrip-Controls
*     im Trägerdynpro)
* (3) Auftraggeber-Modulpoolname
* (4) Subscreen mit fixem Kopf (zur Belegung des Subscreenbereichs
*     oberhalb des Tabstrip-controls)
* (5) Programm der Oberfläche, aus der GUI-Status und GUI-Titel stammen
* (6) ID des GUI-Status, der während der Detailbildpräsentation gesetzt
*     werden soll
* (7) ID des GUI-Titels, der während der Detailbildpräsentation gesetzt
*     werden soll
* (8) Parameter für den variablen Teil des Titles
* (9) Funktionscode, der nach Verlassen des Detailbilds an den
*     Auftraggeber zur Verarbeitung zurückgegeben wird