*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TAXI_READ_LOCATION                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TAXI_READ_LOCATION
*&---------------------------------------------------------------------*
*       Determine current screen group and panel
*&---------------------------------------------------------------------*
form taxi_read_location.

   *taxi_screen_group = taxi_screen_group.
   *taxi_panel        = taxi_panel.

  call function 'LOCATION_EXTRACT'
    importing
      bild       = t185v-panel
      bildgruppe = t185v-bldgr
      funktion   = taxi_fcode
      programm   = t185v-agidv.

  taxi_screen_group = t185v-bldgr.
  taxi_panel        = t185v-panel.

* On the item detail screen for the batch split item the FCODE CDET_T
* must be transformed to IABW_T in order to address the first tabstrip
* (so status I0 can be used for both screen groups I= and C0)
  if taxi_screen_group(1) eq c_taxi_scrgrp_batch(1) and
     taxi_fcode           eq 'CDET_T'.
    taxi_fcode = 'IABW_T'.
  endif.

* Ensure that the right tab is activated on return from the batch-split
* item detail screen
  if *taxi_screen_group(1) eq c_taxi_scrgrp_batch(1) and    "v_n_529958
     taxi_fcode            eq 'BACK_T'.
    taxi_fcode = 'CHSP_T'.
  endif.                                                    "^_n_529958

endform.                               " TAXI_READ_LOCATION