*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_CHANGE_SUBSCREEN                             *
*----------------------------------------------------------------------*
form taxi_change_subscreen.

* If batch split is not allowed but user is navigating through the
* batch split screen a dummy dynpro without logic must be sent in order
* to keep the context for the user (and to keep all quantities correct)
  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq space.
    taxi_body_subscreen = '3120'.
  endif.

* Synchronization of table controls belonging to the same screen group
  if taxi_screen_group(1) eq 'W'        and
     taxi_panel ne *taxi_panel          and
     ilips_tabix_zeile_1_set is initial and
     <tc> is assigned.
    ilips_tabix_zeile_1_set = charx.
    ilips_tabix_zeile_1     = <tc>-top_line.
  endif.

endform.                    "TAXI_CHANGE_SUBSCREEN