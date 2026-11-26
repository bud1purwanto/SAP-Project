***INCLUDE MV50ATST .
CONSTANTS: C_AGIDC_GUI40          LIKE TAXI_PROGRAM   VALUE 'SAPMV50A'.

* FCode leading to the default header screen
CONSTANTS: C_TAXI_DEFAULT_HEAD_FCODE
                                  LIKE TAXI_PARAMS-FCODE VALUE 'HABW_T'.
* Fcode leading to the default item screen
* TAXI_GOTO_ITEM
CONSTANTS: C_TAXI_DEFAULT_ITEM_FCODE
                                  LIKE TAXI_PARAMS-FCODE VALUE 'IABW_T'.

* Tabstrip-Controls
CONTROLS: TAXI_TABSTRIP_OVERVIEW  TYPE TABSTRIP,   "Overview screens
          TAXI_TABSTRIP_HEAD      TYPE TABSTRIP,   "Header screens
          TAXI_TABSTRIP_ITEM      TYPE TABSTRIP.   "Item screens

*-----------------------------------------------------------------------
* Screen groups
*-----------------------------------------------------------------------
DATA: TAXI_SCREEN_GROUP LIKE TAXI_PARAMS-SCREEN_GROUP,     " (1)
      *TAXI_SCREEN_GROUP LIKE TAXI_PARAMS-SCREEN_GROUP.    " (2)
*     (1) current screen group (filled in CUA_setzen),
*     (2) screen group before last screen change

* Constants for screen groups
CONSTANTS:   C_TAXI_SCRGRP_INITIAL           "Initial screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'E0',
             C_TAXI_SCRGRP_OVERVIEW          "Overview screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'W0',
             C_TAXI_SCRGRP_HEAD              "Header screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'H0',
             C_TAXI_SCRGRP_ITEM              "Item screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'I0',
             C_TAXI_SCRGRP_BATCH             "Item screens batch detail
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'C0',
             C_TAXI_SCRGRP_INITIAL_INB       "Initial screens inbound
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'E1',
             C_TAXI_SCRGRP_OVERVIEW_INB      "Overview screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'WI',
             C_TAXI_SCRGRP_HEAD_INB          "Header screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'HI',
             C_TAXI_SCRGRP_ITEM_INB          "Item screens
                  LIKE TAXI_PARAMS-SCREEN_GROUP VALUE 'II'.

* Internal table with screen group attributes
DATA: BEGIN OF TAXI_SCREEN_GROUPS OCCURS 0,
          SCREEN_GROUP   LIKE  TAXI_PARAMS-SCREEN_GROUP,   " (1)
          TABSTRIP_NAME  LIKE  TAXI_PARAMS-TABSTRIP_NAME,  " (2)
          TAB_FCODE      LIKE  TAXI_PARAMS-FCODE.          " (3)
DATA: END OF TAXI_SCREEN_GROUPS.
*     (1) screen group (Key)
*     (2) name of the tabstrip control belongig to the screen group
*     (3) true function code of the index-tab currently active
* Table is filled by 'taxi_screen_groups_init' in module
* 'transaktion_init.
*------------------------------------------ End of screen groups -------

* Panel
DATA: TAXI_PANEL LIKE TAXI_PARAMS-PANEL,     " (1)
      *TAXI_PANEL LIKE TAXI_PARAMS-PANEL.    " (2)
*     (1) current panel (filled in CUA_SETZEN)
*     (2) panel before last dialog step

* Number of the subscreen in the tabstrip control
DATA: TAXI_BODY_SUBSCREEN LIKE TAXI_PARAMS-DYNPRONR.

* Internal table with index-tab fcode to be deactivated
DATA: BEGIN OF TAXI_INACTIVE_FCODES OCCURS 0.
         INCLUDE STRUCTURE TAXI_INACTIVE_FCODES.
DATA: END OF TAXI_INACTIVE_FCODES.

* Maybe not used (who knows...):

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