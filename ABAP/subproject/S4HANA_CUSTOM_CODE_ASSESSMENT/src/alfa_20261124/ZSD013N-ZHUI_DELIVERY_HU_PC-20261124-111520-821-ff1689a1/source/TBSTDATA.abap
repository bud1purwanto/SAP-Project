*----------------------------------------------------------------------*
*   INCLUDE TBSTDATA                                                   *
*----------------------------------------------------------------------*
* === TAXI-Einführung ==================================================

* Arbeitsgebiet, für die neuen Bilder im Verkauf.
CONSTANTS: C_AGIDC_GUI40          LIKE TAXI_PROGRAM   VALUE 'SAPMV45B'.

* FCode, der zum Default-Kopfbild führt
CONSTANTS: C_TAXI_DEFAULT_HEAD_FCODE
                                  LIKE TAXI_PARAMS-FCODE VALUE 'KKAU'.
* FCode, der zum Default-Positionsbild führt (benutzt in der Form
* TAXI_GOTO_ITEM)
CONSTANTS: C_TAXI_DEFAULT_ITEM_FCODE
                                  LIKE TAXI_PARAMS-FCODE VALUE 'PKAU'.

* Tabstrip-Controls
CONTROLS: TAXI_TABSTRIP_OVERVIEW  TYPE TABSTRIP,   "Übersichten
          TAXI_TABSTRIP_HEAD      TYPE TABSTRIP,   "Kopfbilder
          TAXI_TABSTRIP_ITEM      TYPE TABSTRIP,   "Positionsbilder
          TAXI_TABSTRIP_SHEDLINE  TYPE TABSTRIP,   "Einteilungsbilder
          TAXI_TABSTRIP_FC_DSH    TYPE TABSTRIP,   "Lieferabrufkopf
          TAXI_TABSTRIP_JIT_DSH   TYPE TABSTRIP,   "Feinabrufkopf
          TAXI_TABSTRIP_AG_UV     TYPE TABSTRIP.   "Auftraggeber

*-----------------------------------------------------------------------
* Bildgruppe
*-----------------------------------------------------------------------
DATA: TAXI_SCREEN_GROUP LIKE TAXI_PARAMS-SCREEN_GROUP,     " (1)
      *TAXI_SCREEN_GROUP LIKE TAXI_PARAMS-SCREEN_GROUP.    " (2)
*     (1) aktuelle Bildgruppe (wird in CUA_setzen versorgt),
*     (2) Bildgruppe vor dem letzten Bildwechsel

* vorhandene Bildgruppen als symbolische Konstanten
CONSTANTS:   C_TAXI_SCRGRP_INITIAL           "Einstiegsbilder
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'A0',
             C_TAXI_SCRGRP_OVERVIEW          "Übersichtsbilder
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'U0',
             C_TAXI_SCRGRP_HEAD              "Bilder zum Belegkopf
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'K0',
             C_TAXI_SCRGRP_ITEM              "Bilder zu einer Position
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'P0',
             C_TAXI_SCRGRP_SCHEDLINE         "Bilder zu einer Einteilung
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'P1',
             C_TAXI_SCRGRP_FC_DSH            "Bilder zum Lieferabrufkopf
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'PL',
             C_TAXI_SCRGRP_JIT_DSH           "Bilder zum Feinabrufkopf
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'PF'.

* interne Tabelle der Bildgruppenattribute
DATA: BEGIN OF TAXI_SCREEN_GROUPS OCCURS 0,
          SCREEN_GROUP   LIKE  TAXI_PARAMS-SCREEN_GROUP,   " (1)
          TABSTRIP_NAME  LIKE  TAXI_PARAMS-TABSTRIP_NAME,  " (2)
          TAB_FCODE      LIKE  TAXI_PARAMS-FCODE.          " (3)
DATA: END OF TAXI_SCREEN_GROUPS.
*     (1) Bildgruppe (Key)
*     (2) Name des zur Bildgruppe gehörenden Tabstrip-Controls
*     (3) 'echter' Funktionscode des aktuell aktiven Reiters
* Diese Tabelle wird mittels der Form 'taxi_screen_groups_init' im
* Modul 'transaktion_init' vorbelegt!
*----------------------------------------------- Ende Bildgruppe -------

* Panel
DATA: TAXI_PANEL LIKE TAXI_PARAMS-PANEL,     " (1)
      *TAXI_PANEL LIKE TAXI_PARAMS-PANEL.    " (2)
*     (1) aktuelles Panel (wird in CUA_setzen versorgt),
*     (2) Panel vor dem letzten Dialogschritt

* Dynpronummer des Subscreens innerhalb des Tabstrip-Controls.
DATA: TAXI_BODY_SUBSCREEN LIKE TAXI_PARAMS-DYNPRONR.

* Interne Tabelle zur Aufnahme inaktiv zu schaltender Reiterfkt.codes
DATA: BEGIN OF TAXI_INACTIVE_FCODES OCCURS 0.
         INCLUDE STRUCTURE TAXI_INACTIVE_FCODES.
DATA: END OF TAXI_INACTIVE_FCODES.

* Flag, das beim Aufruf eines Headersubscreens gesetzt ist, wenn dessen
* Felder eine gültige Belegung aufweisen.
DATA: TAXI_HEADER_INITIALIZED LIKE TAXI_PARAMS-FLAG.

* Identifier zum Zugriff auf die im ABAP-MEMORY abgelegten Inhalte der
* Headersubscreenfelder.
CONSTANTS:   C_TAXI_ITEM_HEADER_ID(30)
                  TYPE C    VALUE 'TAXI_ITEM_HEADER',
             C_TAXI_DOCUMENT_HEADER_ID(30)
                  TYPE C    VALUE 'TAXI_DOCUMENT_HEADER',
             C_TAXI_OVERVIEW_HEADER_ID(30)
                  TYPE C    VALUE 'TAXI_OVERVIEW_HEADER'.

* Konstanter Funktionscode-Präfix
CONSTANTS:   C_PREFIX_CAPTIONS_FIELD(2)  TYPE C  VALUE 'T\'.