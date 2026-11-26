*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_FCODE_SCRGROUP                                *
*----------------------------------------------------------------------*
* This routine activates or deactivates FCODES dependend on the current
* screen group. Consequently, only one CUA-status is active through
* the whole delivery processing

form cua_fcode_scrgroup.

  case taxi_screen_group(1).
*$*$--------------------------------------------------------------------
    when c_taxi_scrgrp_initial(1) or space.
      if t180-trtyp eq charh.
        case t180-tcode.
          when 'VL01N'.
            perform cua_fcode_allow using 'CROA_T' yes.
            perform cua_fcode_allow using 'CRMA_T' no.
          when 'VL01NO'.
            perform cua_fcode_allow using 'CROA_T' no.
            perform cua_fcode_allow using 'CRMA_T' yes.
        endcase.
        perform cua_fcode_allow using 'PRNT_T' no.
      else.
        perform cua_fcode_allow using 'PRNT_T' yes.
      endif.
ENHANCEMENT-POINT CUA_FCODE_SCRGROUP_01 SPOTS ES_SAPMV50A.
*$*$--------------------------------------------------------------------
    when c_taxi_scrgrp_overview(1).
*     Delete functions
      if t180-trtyp ne chara.
        perform cua_fcode_allow using 'POLO_T' yes.
*       Deliver order
        perform cua_fcode_allow using 'RAUF_T' yes.         "470
      endif.
*     Printing not allowed
      perform cua_fcode_allow using 'PRNT_T' no.
      if t180-trtyp ne chara.
*     Confirmation of marked items
        perform cua_fcode_allow using 'QUIM_T' yes.
      endif.
*     Double click
      perform cua_fcode_allow using 'IDET_T' yes.
*     Header detail
      perform cua_fcode_head.
*     Item overview
      perform cua_fcode_allow using 'OVER_T' no.
*     Mark/demark all
      perform cua_fcode_allow using 'MKAL_T' yes.
      perform cua_fcode_allow using 'MKLO_T' yes.
      perform cua_fcode_allow using 'POPO_T' yes.           "n_572602
*     Item related functions (serial numbers, configuration, dangerous
*     goods profile, credit assurance, output)
      perform cua_fcode_allow using 'PSER_T' yes.
      perform cua_fcode_allow using 'POKO_T' yes.
      perform cua_fcode_allow using 'PGGP_T' yes.
      perform cua_fcode_allow using 'ZUKI_T' yes.
      perform cua_fcode_allow using 'PPRT_T' yes.
      perform cua_fcode_allow using 'IBST_T' yes.
      perform cua_fcode_allow using 'IMST_T' yes.
      perform cua_fcode_allow using 'IVFP_T' yes.
      perform cua_fcode_allow using 'IEHS_T' yes.
*     Scrolling functions
      perform cua_fcode_allow using 'FPAG_T' yes.
      perform cua_fcode_allow using 'PPAG_T' yes.
      perform cua_fcode_allow using 'NPAG_T' yes.
      perform cua_fcode_allow using 'LPAG_T' yes.
*     Item detail
      perform cua_fcode_item.
*     Item navigation
      perform cua_fcode_allow using 'FITE_T' no. "first item
      perform cua_fcode_allow using 'PITE_T' no. "previous item
      perform cua_fcode_allow using 'NITE_T' no. "next item
      perform cua_fcode_allow using 'LITE_T' no. "last item
*     Status overview
      case taxi_panel.
        when 'STAT'.
          perform cua_fcode_allow using 'POLO_T' no.
          perform cua_fcode_allow using 'POAN_T' no.
          perform cua_fcode_allow using 'POPO_T' no.
          perform cua_fcode_allow using 'CHSP_T' no.
        when others.
          if t180-trtyp ne chara.
            perform cua_fcode_allow using 'POLO_T' yes.
            perform cua_fcode_allow using 'POAN_T' yes.
          endif.
          perform cua_fcode_allow using 'POPO_T' yes.
          perform cua_fcode_allow using 'CHSP_T' yes.
      endcase.
ENHANCEMENT-POINT CUA_FCODE_SCRGROUP_02 SPOTS ES_SAPMV50A.
*$*$--------------------------------------------------------------------
    when c_taxi_scrgrp_head(1).
*     Header detail
      perform cua_fcode_head.
*     Item overview
      perform cua_fcode_allow using 'OVER_T' yes.
*     Printing not allowed
      perform cua_fcode_allow using 'PRNT_T' no.
*     Mark/demark all
      perform cua_fcode_allow using 'MKAL_T' no.
      perform cua_fcode_allow using 'MKLO_T' no.
      perform cua_fcode_allow using 'POPO_T' no.            "n_572602
*     Delete functions
      perform cua_fcode_allow using 'POLO_T' no.
*     Confirmation of marked items
      perform cua_fcode_allow using 'QUIM_T' no.
*     Double click
      if taxi_panel eq 'HPAR' or
         taxi_panel eq 'HKON'.
        perform cua_fcode_allow using 'IDET_T' yes.
      else.
        perform cua_fcode_allow using 'IDET_T' no.
      endif.
*     Item related functions (serial numbers, configuration, dangerous
*     goods profile, credit assurance, output)
      perform cua_fcode_allow using 'PSER_T' no.
      perform cua_fcode_allow using 'POKO_T' no.
      perform cua_fcode_allow using 'PGGP_T' no.
      perform cua_fcode_allow using 'ZUKI_T' no.
      perform cua_fcode_allow using 'PPRT_T' no.
      perform cua_fcode_allow using 'IBST_T' no.
      perform cua_fcode_allow using 'IMST_T' no.
      perform cua_fcode_allow using 'IVFP_T' no.
      perform cua_fcode_allow using 'IEHS_T' no.
*     Deliver order
      perform cua_fcode_allow using 'RAUF_T' no.
*     Scrolling functions
      case taxi_panel.
        when 'HTER'.
          perform cua_fcode_allow using 'FPAG_T' yes.
          perform cua_fcode_allow using 'PPAG_T' yes.
          perform cua_fcode_allow using 'NPAG_T' yes.
          perform cua_fcode_allow using 'LPAG_T' yes.
        when others.
          perform cua_fcode_allow using 'FPAG_T' no.
          perform cua_fcode_allow using 'PPAG_T' no.
          perform cua_fcode_allow using 'NPAG_T' no.
          perform cua_fcode_allow using 'LPAG_T' no.
      endcase.
*     Item detail
      perform cua_fcode_item.
*     Item navigation
      perform cua_fcode_allow using 'FITE_T' no. "first item
      perform cua_fcode_allow using 'PITE_T' no. "previous item
      perform cua_fcode_allow using 'NITE_T' no. "next item
      perform cua_fcode_allow using 'LITE_T' no. "last item
ENHANCEMENT-POINT CUA_FCODE_SCRGROUP_03 SPOTS ES_SAPMV50A.
*$*$--------------------------------------------------------------------
    when c_taxi_scrgrp_item(1).
      perform cua_fcode_head.
      perform cua_fcode_item.
      perform cua_fcode_allow using 'IMST_T' yes.
*     Confirmation of marked items
      perform cua_fcode_allow using 'QUIM_T' no.
*     Printing not allowed
      perform cua_fcode_allow using 'PRNT_T' no.
*     Item related functions (serial numbers, configuration, dangerous
*     goods profile, credit assurance, output)
      perform cua_fcode_allow using 'PSER_T' yes.
      perform cua_fcode_allow using 'POKO_T' yes.
      perform cua_fcode_allow using 'PGGP_T' yes.
      perform cua_fcode_allow using 'ZUKI_T' yes.
      perform cua_fcode_allow using 'PPRT_T' yes.
      perform cua_fcode_allow using 'IBST_T' yes.
      perform cua_fcode_allow using 'IMST_T' yes.
      perform cua_fcode_allow using 'IVFP_T' yes.
      perform cua_fcode_allow using 'IEHS_T' yes.
*     Deliver order
      perform cua_fcode_allow using 'RAUF_T' no.
      if taxi_panel eq gc_panel_chsp and
         t180-trtyp ne chara.                                 "n_646493
        perform cua_fcode_allow using 'POLO_T' yes.
      else.
        perform cua_fcode_allow using 'POLO_T' no.
      endif.
      case taxi_panel.
        when gc_panel_chsp.
*         Scrolling functions
          perform cua_fcode_allow using 'FPAG_T' yes.
          perform cua_fcode_allow using 'PPAG_T' yes.
          perform cua_fcode_allow using 'NPAG_T' yes.
          perform cua_fcode_allow using 'LPAG_T' yes.
*         Double click
          perform cua_fcode_allow using 'IDET_T' yes.
*         Mark/demark all
          perform cua_fcode_allow using 'MKAL_T' yes.
          perform cua_fcode_allow using 'MKLO_T' yes.
          if v50agl-chargensplitbild ne space.              "v_n_572602
            perform cua_fcode_allow using 'POPO_T' yes.
          else.
            perform cua_fcode_allow using 'POPO_T' no.
          endif.                                            "^_n_572602
        when 'IKON'.
*         Double click
          perform cua_fcode_allow using 'IDET_T' yes.
        when others.
          perform cua_fcode_allow using 'FPAG_T' no.
          perform cua_fcode_allow using 'PPAG_T' no.
          perform cua_fcode_allow using 'NPAG_T' no.
          perform cua_fcode_allow using 'LPAG_T' no.
          perform cua_fcode_allow using 'IDET_T' no.
          perform cua_fcode_allow using 'MKAL_T' yes.       "n_554233
          perform cua_fcode_allow using 'MKLO_T' no.
          perform cua_fcode_allow using 'POPO_T' no.        "n_572602
      endcase.
      perform cua_fcode_allow using 'OVER_T' yes.
      perform cua_navigation_set tables gt_ilips_main
                                 using  gs_ilips_main-posnr.
ENHANCEMENT-POINT CUA_FCODE_SCRGROUP_04 SPOTS ES_SAPMV50A.
*$*$--------------------------------------------------------------------
    when c_taxi_scrgrp_batch(1).
*     Delete functions
      perform cua_fcode_allow using 'POLO_T' no.
*     Header detail
      perform cua_fcode_head.
*     Item overview
      perform cua_fcode_allow using 'OVER_T' yes.
*     Printing not allowed
      perform cua_fcode_allow using 'PRNT_T' no.
*     Mark/demark all
      perform cua_fcode_allow using 'MKAL_T' yes.           "n_554233
      perform cua_fcode_allow using 'MKLO_T' no.
      perform cua_fcode_allow using 'POPO_T' no.            "n_572602
*     Confirmation of marked items
      perform cua_fcode_allow using 'QUIM_T' no.
*     Double click
      if taxi_panel eq 'IKON'.
        perform cua_fcode_allow using 'IDET_T' yes.
      else.
        perform cua_fcode_allow using 'IDET_T' no.
      endif.
*     Item related functions (serial numbers, configuration, dangerous
*     goods profile, credit assurance, output)
      perform cua_fcode_allow using 'PSER_T' yes.
      perform cua_fcode_allow using 'POKO_T' yes.
      perform cua_fcode_allow using 'PGGP_T' yes.
      perform cua_fcode_allow using 'ZUKI_T' yes.
      perform cua_fcode_allow using 'PPRT_T' yes.
      perform cua_fcode_allow using 'IBST_T' yes.
      perform cua_fcode_allow using 'IMST_T' yes.
      perform cua_fcode_allow using 'IVFP_T' yes.
      perform cua_fcode_allow using 'IEHS_T' yes.
*     Deliver order
      perform cua_fcode_allow using 'RAUF_T' no.
*     Scrolling functions
      perform cua_fcode_allow using 'FPAG_T' no.
      perform cua_fcode_allow using 'PPAG_T' no.
      perform cua_fcode_allow using 'NPAG_T' no.
      perform cua_fcode_allow using 'LPAG_T' no.
*     Item detail
      perform cua_fcode_item.
      perform cua_navigation_set tables gt_ilips_chsp
                                 using  gs_ilips_chsp-posnr.
ENHANCEMENT-POINT CUA_FCODE_SCRGROUP_05 SPOTS ES_SAPMV50A.
  endcase.

endform.