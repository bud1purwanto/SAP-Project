*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_NITE                                        *
*----------------------------------------------------------------------*
* Switch to the next item on the detail screen
* The work areas XLIPS, LIPS, *LIPS, ILIPS and SLIPS are filled with
* the new values. The new workarea ILIPS is saved in GS_ILIPS_MAIN or
* GS_ILIPS_CHSP because this workarea is used for leafing through the
* items

form fcode_nite.

* Use suitable ILIPS depending on the current screen group
  case taxi_screen_group(1).
    when c_taxi_scrgrp_item(1).
*     If current screen is the batch split screen then the batch
*     split has to be terminated regularly first
      if t185v-panel eq gc_panel_chsp.
        perform xlips_i0_to_i0_chsp(sapfv50p).
      endif.
      perform wlips_next_item(sapfv50p) tables gt_ilips_main
                                               gt_wlips_main
                                        using  gs_ilips_main-posnr.
      gs_ilips_main = ilips.
      gs_xlips_main = xlips.
      gs_lips_main  = lips.
*     If requested item is a batch split item the status line of the
*     main item must be filled for a correct field control
      if not gs_xlips_main-uecha is initial.                "HP_310651
        read table xvbup into gs_vbup_uecha
                         with key vbeln = gs_xlips_main-vbeln
                                  posnr = gs_xlips_main-uecha.
      else.
        clear gs_vbup_uecha.
      endif.
*     If batch split screen is active prepare batch split for the new
*     main item
      if taxi_panel eq gc_panel_chsp.
        perform xlips_chsp_nd(sapfv50p).
      endif.
    when c_taxi_scrgrp_batch(1).
      perform wlips_next_item(sapfv50p) tables gt_ilips_chsp
                                               gt_wlips_chsp
                                        using  gs_ilips_chsp-posnr.
      gs_ilips_chsp = ilips.
      gs_xlips_chsp = xlips.
      gs_lips_chsp  = lips.
  endcase.

endform.