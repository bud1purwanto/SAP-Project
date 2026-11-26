*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_SCREENGROUPS_INI                             *
*----------------------------------------------------------------------*
FORM TAXI_SCREEN_GROUPS_INIT.

* Table TAXI_SCREEN_GROUPS is filled with default data
* - Screen group 'W0' (item Overview)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_OVERVIEW.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_overview'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'OVER_T'.
  APPEND TAXI_SCREEN_GROUPS.
* - Screen group 'H0' (Header screens)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_HEAD.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_head'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'HDET_T'.
  APPEND TAXI_SCREEN_GROUPS.
* - Screen group 'I0' (Item screens)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_ITEM.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_item'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'IDET_T'.
  APPEND TAXI_SCREEN_GROUPS.

* - Screen group 'WI' (item Overview inbound delivery)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_OVERVIEW_INB.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_overview'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'OVER_T'.
  APPEND TAXI_SCREEN_GROUPS.
* - Screen group 'HI' (Header screens inbound delivery)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_HEAD_INB.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_head'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'HDET_T'.
  APPEND TAXI_SCREEN_GROUPS.
* - Screen group 'II' (Item screens inbound delivery)
  TAXI_SCREEN_GROUPS-SCREEN_GROUP  = C_TAXI_SCRGRP_ITEM_INB.
  TAXI_SCREEN_GROUPS-TABSTRIP_NAME = 'taxi_tabstrip_item'.
  TAXI_SCREEN_GROUPS-TAB_FCODE     = 'IDET_T'.
  APPEND TAXI_SCREEN_GROUPS.


ENDFORM.