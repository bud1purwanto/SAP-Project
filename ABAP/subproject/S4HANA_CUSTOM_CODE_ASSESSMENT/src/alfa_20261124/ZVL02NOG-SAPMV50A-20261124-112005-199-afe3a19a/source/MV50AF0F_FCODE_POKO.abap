***INCLUDE MV50AF0F_FCODE_POKO .
*---------------------------------------------------------------------*
*       FORM FCODE_POKO                                               *
*---------------------------------------------------------------------*
*       Anzeigen Konfiguration (=Merkmalsbewertung) der               *
*       zugrundeliegenden Auftragsposition                            *
*---------------------------------------------------------------------*

form fcode_poko using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

  data: cfcode like sy-ucomm,
        cincl like incl_bild,
        lf_subrc like sy-subrc.

* New dialog: if configuration data display is called from the batch
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

*... konfigurierte Position
  if not lips-cuobj is initial.

    cincl = space.
    call function 'VC_I_DISPLAY_CONFIGURATION'
         exporting
              instance           = lips-cuobj
              include_screen     = cincl
         exceptions
              instance_not_found = 1
              internal_error     = 2
              others             = 3.

    if sy-subrc <> 0.
    endif.

  else.
*... nicht konfigurierte Position
    message id 'V1' type 'I' number 469 with lips-posnr.
  endif.

  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform xlips_c0_to_i0_chsp(sapfv50p).
  endif.

endform.