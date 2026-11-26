***INCLUDE MV50AF0F_FCODE_PSER .
*---------------------------------------------------------------------*
*       FORM FCODE_PSER                                               *
*---------------------------------------------------------------------*
*       Pflege der Serialnummern auf Positionsebene                   *
*---------------------------------------------------------------------*
form fcode_pser using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

ENHANCEMENT-POINT MV50AF0F_FCODE_PSER_03 SPOTS ES_SAPMV50A STATIC.

  data: xanzsn          like risa0-anzahl,
        xtrtyp          like t180-trtyp,
        xopera(04)      type c,
        lf_anzsn        like lips-anzsn,
        lf_datal        like r185d-dataloss,
        lf_vorgang like tj01-vrgng,                            "n_599939
        lf_werks        like lips-werks,
        lf_lgort        like lips-lgort,
        lf_subrc        like sy-subrc,
        ls_t377         type t377,
        ls_serno_change like shp_serno_change.

* New dialog: if serial number maintenance is called from the batch
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

* HSO 2007-10-04 Int. Msg. 171396 2007 --->
  data: ehpflag type xfeld.
  CLEAR ehpflag.

ENHANCEMENT-POINT EHP603_MV50AF0F_FCODE_PSER SPOTS ES_SAPMV50A.

  if ehpflag is INITIAL.
* <--- HSO 2007-10-04 Int. Msg. 171396 2007

  READ TABLE XVBUP WITH KEY VBELN = LIPS-VBELN               "v_n_925729
                            POSNR = LIPS-POSNR.
* Serialization is only allowed for Partial GR with full items
  IF SY-SUBRC    IS INITIAL    AND
     LIPS-HUPOS  IS INITIAL    AND
     LIKP-VBTYP  EQ VBTYP_LIAV AND
     XVBUP-WBSTA EQ CHARB.
    MESSAGE E891.
    EXIT.
  ENDIF.                                                     "^_n_925729

  endif.  " HSO 2007-10-04 Int. Msg. 171396 2007

  DO 1 TIMES. "Loop to control exit from routine


ENHANCEMENT-POINT MV50AF0F_FCODE_PSER_01 SPOTS ES_SAPMV50A.


    PERFORM SN_STATUS_OPERATION_DETERMINE(SAPFV50W)          "v_n_599939
                                  USING    LIKP-VBTYP
                                           TVLK-AUFER
                                           LIPS                "n_933408
                                           SPACE
                                  CHANGING LF_VORGANG.       "^_n_599939

* checks on serial numbers and batch materials
    perform serialnumber_checks tables xlips
                                using likp
                                      lips
                                      tvlk
                                      lf_vorgang               "n_599939
                                      t180-trtyp
                                changing
                                      xtrtyp
                                      lf_subrc.
    if lf_subrc ne 0.
      MESSAGE id sy-msgid type 'I' number sy-msgno display like 'E' with
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
ENHANCEMENT-SECTION     MV50AF0F_FCODE_PSER_02 SPOTS ES_SAPMV50A.
    perform serialnumber_profile_check using likp
                                             lips
                                             lf_vorgang        "n_599939
                                             xtrtyp
                                       changing lf_anzsn
                                                lf_datal.
END-ENHANCEMENT-SECTION.
*                                                      ^_n_598948
    if not lf_datal is initial.
      r185d-dataloss = charx.

      if not likp-vlstk is initial.                         "470
*     ... only when decentral WMS is active
*       fill admin table for serial number changes
        ls_serno_change-vbeln         = lips-vbeln.
        ls_serno_change-posnr         = lips-posnr.
        ls_serno_change-serno_changed = charx.
        append ls_serno_change to gt_serno_change.
        clear  ls_serno_change.
      endif.

    endif.
    if lf_anzsn ne lips-anzsn.
      lips-anzsn = lf_anzsn.
      perform xlips_aendern(sapfv50p).
      if t180-trtyp ne chara.
        if uc_process eq space.
          perform uc_internal_update(sapfv50u).
        else.
          perform uc_recalc(sapfv50u).
        endif.
      endif.
    endif.

    read table xlips_ser with key lips-posnr binary search.
    case sy-subrc.
      when 0.
        xlips_ser-anzsn = lips-anzsn.
        modify xlips_ser index sy-tabix.
      when 4.
        xlips_ser-posnr = lips-posnr.
        xlips_ser-uecha = lips-uecha.
        xlips_ser-anzsn = lips-anzsn.
        insert xlips_ser index sy-tabix.
      when 8.
        xlips_ser-posnr = lips-posnr.
        xlips_ser-uecha = lips-uecha.
        xlips_ser-anzsn = lips-anzsn.
        append xlips_ser.
    endcase.
  enddo.

  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform xlips_c0_to_i0_chsp(sapfv50p).
  endif.

endform.                    "fcode_pser