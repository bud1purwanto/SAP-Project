***INCLUDE MV50AF0F_FCODE_PGGP .
*---------------------------------------------------------------------*
*       FORM FCODE_PGGP                                               *
*---------------------------------------------------------------------*
*       Maintaining dangerous goods data on item level                *
*---------------------------------------------------------------------*
form fcode_pggp using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

  data: lf_subrc like sy-subrc.

* New dialog: if serial dg maintenance is called from the batch
* split screen the marked item has to be moved to the workarea:
  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform read_first_marked_item(sapfv50p) tables gt_wlips_chsp
                                             using  space
                                             changing lf_subrc.
    check lf_subrc eq 0.               "Exit if no item marked

*   Fill tables and workareas with well-defined values
    gt_ilips_chsp[] = ilips[].
    gs_ilips_chsp = ilips.
    gs_xlips_chsp = xlips.
    gs_lips_chsp  = lips.
    gf_loopc_chsp = ilips_loopc.
    gf_tabix_zeile_1_chsp = ilips_tabix_zeile_1.
  endif.

  perform gg_lipsdg_maintain using likp lips.

  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform xlips_c0_to_i0_chsp(sapfv50p).
  endif.

endform.