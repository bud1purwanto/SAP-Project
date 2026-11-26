*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSFORM_VIEW_FCODE                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_VIEW_FCODE
*&---------------------------------------------------------------------*
*       Determine next screen depending on the current processing
*       view
*       If a process relevant detail screen is called the current
*       process view is changed
*----------------------------------------------------------------------*
form transform_view_fcode changing cf_fcode type fcode.

  local: taxi_screen_group, taxi_tabstrip_captions.         "v_n_529538

  data: lf_dynpro           like shdsvci-dynpro,
        lf_program          like shdsvci-progname value 'SAPMV50A',
        lf_index(2)         type n,
        lf_fieldname        like shdsvfvci-fieldname,
        lf_scvariant        like shdsvci-scvariant,
        lt_values_scvariant like shdsvfvci occurs 0 with header line,
        lt_guixt_scripts    like shdguixt occurs 0.         "^_n_529538

  check t180-bldgr eq gc_new_dialog_outb or
        t180-bldgr eq gc_new_dialog_inb.
  check cf_fcode cs '_T'.

* If the batch structure is shown on the overview screen, the green
* arrow causes the return to the all-item overview screen instead
* of leaving the dialog completely.
  if taxi_screen_group(1) eq c_taxi_scrgrp_overview(1) and
     cf_fcode             eq 'BACK_T'                  and
     xlips_umfang         eq xlips_umfang_ucha.
    cf_fcode = 'CHPL_T01'.
    exit.
  endif.

* Set default view on the delivery data. Note: Deliveries without
* reference must always start with the general view since an obligatory
* field is on the tab strip 'Item overview'!
  if gf_process_view is initial.
    if lieferung_or eq charx and t180-trtyp eq charh.
      gf_process_view = gc_view_general.
    else.
      get parameter id 'SHP_PROCESS_VIEW' field gf_process_view.
      if gf_process_view is initial.
        gf_process_view = gc_view_general.
      endif.
    endif.
  endif.

* Returns overview active but no returns document in process?
* Switch back to normal view
  if gf_process_view eq gc_view_returns and
     likp-spe_le_scenario eq space.
    gf_process_view = gc_view_general.
  endif.

* If the delivery is not relevant for import/export processing the
* automatic navigation should not switch to the foreign trade tab
  if likp-expkz      eq space                 and           "HP_322186
     gf_process_view eq gc_view_foreign_trade and
     ( fcode eq 'HDET_T' or fcode eq 'IDET_T' ).
    gf_process_view = gc_view_general.
  endif.

* Inbound delivery dialog does not have any dynpros for conditions,
* therefore don't use tab coming from user parameter
  if likp-vbtyp ca vbtyp_mmli and                          "v_n_1020153
     gf_process_view eq gc_view_conditions.
    gf_process_view = gc_view_general.
  endif.                                                   "^_n_1020153

* SPE returns: If cursor was placed on field for original delivery
* call detail view of this delivery
  if likp-spe_le_scenario eq charr OR likp-spe_le_scenario eq chart.
    if fcode eq 'IDET_T' and
       ( gs_get_cursor-fieldname eq '/SPE/RET_DIA-ORIG_VBELN' or
         gs_get_cursor-fieldname eq '/SPE/RET_DIA-ORIG_POSNR' ).
      cf_fcode = 'DORI_T'.
      return.
    endif.
  endif.

  if fcode eq 'OVER_T' or              "item overview
     fcode eq 'IDET_T' or              "item detail
     fcode eq 'HDET_T'.                "header detail

*   Special processing in case of transaction variants: Avoid jumping on
*   suppressed tabs
    if not gf_tcvariant is initial.                         "v_n_529538
*     Determine next screen group
      case cf_fcode.
        when 'OVER_T'.
          lf_dynpro = '1000'.
          taxi_screen_group = 'W'.
        when 'IDET_T'.
          lf_dynpro = '3000'.
          taxi_screen_group = 'I'.
        when 'HDET_T'.
          lf_dynpro = '2000'.
          taxi_screen_group = 'H'.
      endcase.
      if likp-vbtyp ca vbtyp_mmli.
        concatenate taxi_screen_group 'I' into taxi_screen_group.
      else.
        concatenate taxi_screen_group '0' into taxi_screen_group.
      endif.
*     Get screen variant for next screen if existent
      call function 'RS_HDSYS_GET_SC_VARIANT'
        exporting
          progname         = lf_program
          dynpro           = lf_dynpro
        importing
          scvariant        = lf_scvariant
        tables
          values_scvariant = lt_values_scvariant
          guixt_scripts    = lt_guixt_scripts.
      if not lf_scvariant is initial.
*       Check for inactive tab strips
        loop at lt_values_scvariant
             transporting no fields
             where fieldname cs 'TAXI_TABSTRIP_CAPTIONS'
               and active eq space.
          exit.
        endloop.
        if sy-subrc eq 0.
*         At least one tab is suppressed: Display the first active tab
          do 32 times.
            lf_fieldname =  'TAXI_TABSTRIP_CAPTIONS-TAB'.
            lf_index = sy-index.
            concatenate lf_fieldname lf_index into lf_fieldname.
            read table lt_values_scvariant
                       with key fieldname = lf_fieldname
                       transporting no fields.
            if sy-subrc ne 0.
              exit.
            endif.
          enddo.
          call function 'TAXI_CREATE_CAPTIONS'
            exporting
              program                 = 'SAPMV50A'
              screen_group            = taxi_screen_group
            importing
              tabstrip_captions       = taxi_tabstrip_captions
            exceptions
              no_tabs_for_screengroup = 0
              no_caption_for_fcode    = 0
              others                  = 0.

*         Create translation table for the tab titles (The current
*         status of table GT_TAXI_ADMIN is not needed any more since the
*         screen group will be changed anyway)
          perform taxi_insert_cust_tabs.

          clear cf_fcode.
          concatenate 'T\' lf_index into cf_fcode.

*         The sequence of tabs may be changed by BAdIs: Translation
*         between the visible tab structure and the tab structure inside
*         function group TAXI is necessary
          read table gt_taxi_admin with key fcode_new = cf_fcode
                                   binary search.
          if sy-subrc eq 0.
            cf_fcode = gt_taxi_admin-fcode_old.
          endif.

          call function 'TAXI_CONVERT_FCODE'
            exporting
              fcode_in        = cf_fcode
            importing
              fcode_out       = cf_fcode
            exceptions
              fcode_not_found = 1
              others          = 2.
          exit.
        endif.
      endif.
    endif.                                                  "^_n_529538

    case gf_process_view.
      when gc_view_general.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IABW_T'.
          when 'HDET_T'.
            cf_fcode = 'HABW_T'.
        endcase.
      when gc_view_picking.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'PIOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IPIC_T'.
          when 'HDET_T'.
            cf_fcode = 'HPIC_T'.
        endcase.
      when gc_view_loading.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'LDOV_T'.
          when 'IDET_T'.
            cf_fcode = 'ILOA_T'.
          when 'HDET_T'.
            cf_fcode = 'HLOA_T'.
        endcase.
      when gc_view_transportation.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'TROV_T'.
          when 'IDET_T'.
            cf_fcode = 'ILOA_T'.
          when 'HDET_T'.
            cf_fcode = 'HTRA_T'.
        endcase.
      when gc_view_text.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'ITEX_T'.
          when 'HDET_T'.
            cf_fcode = 'HTEX_T'.
        endcase.
      when gc_view_foreign_trade.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IFOR_T'.
          when 'HDET_T'.
            cf_fcode = 'HFOR_T'.
        endcase.
      when gc_view_financials.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IFIN_T'.
          when 'HDET_T'.
            cf_fcode = 'HFIN_T'.
        endcase.
      when gc_view_conditions.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IKON_T'.
          when 'HDET_T'.
            cf_fcode = 'HKON_T'.
        endcase.
      when gc_view_administration.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'ITEC_T'.
          when 'HDET_T'.
            cf_fcode = 'HADM_T'.
        endcase.
      when gc_view_customer.                                    "v_SPE
        case cf_fcode.
          when 'OVER_T'.
            if not gs_cust_tab-over_caption is initial.
              cf_fcode = 'WCUS_T'.
            else.
              cf_fcode = 'ITOV_T'.
            endif.
          when 'IDET_T'.
            if not gs_cust_tab-item_caption is initial.
              cf_fcode = 'ICUS_T'.
            else.
              cf_fcode = 'IABW_T'.
            endif.
          when 'HDET_T'.
            if not gs_cust_tab-head_caption is initial.
              cf_fcode = 'HCUS_T'.
            else.
              cf_fcode = 'HABW_T'.
            endif.
        endcase.
      when gc_view_returns.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'SRMA_T'.
          when 'IDET_T'.
            cf_fcode = 'IABW_T'.
          when 'HDET_T'.
            cf_fcode = 'HABW_T'.
        endcase.                                                "^_SPE
      when others.
ENHANCEMENT-SECTION     TRANSFORM_VIEW_FCODE_01 SPOTS ES_SAPMV50A.
        case cf_fcode.
          when 'OVER_T'.
            cf_fcode = 'ITOV_T'.
          when 'IDET_T'.
            cf_fcode = 'IABW_T'.
          when 'HDET_T'.
            cf_fcode = 'HABW_T'.
        endcase.

END-ENHANCEMENT-SECTION.
    endcase.

  else.
* Change process view depending on the next screen to process (except
* batch detail)
    if taxi_screen_group(1) ne c_taxi_scrgrp_batch(1) and   "HP_211201
       gf_tcvariant is initial.
      case cf_fcode.
        when 'HPIC_T' or               "header picking
             'IPIC_T' or               "item picking
             'PIOV_T'.                 "item overview
          gf_process_view = gc_view_picking.
        when 'HLOA_T' or               "header loading
             'LDOV_T'.                 "overview loading
          gf_process_view = gc_view_loading.
        when 'HTRA_T' or               "header transportation
             'ILOA_T' or               "item loading and transportation
             'TROV_T'.                 "transportation overview
          gf_process_view = gc_view_transportation.
        when 'HTEX_T' or               "header text
             'ITEX_T'.                 "item text
          gf_process_view = gc_view_text.
        when 'HFOR_T' or               "header foreign trade
             'IFOR_T'.                 "item foreign trade
          gf_process_view = gc_view_foreign_trade.
        when 'HFIN_T' or               "header financial processing
             'IFIN_T'.                 "item financial processing
          gf_process_view = gc_view_financials.
        when 'HKON_T' or               "header conditions
             'IKON_T'.                 "item conditions
          gf_process_view = gc_view_conditions.
        when 'HADM_T' or               "header adminstration
             'ITEC_T'.                 "item administration/techn. data
          if t180-bldgr eq gc_new_dialog_outb.
            gf_process_view = gc_view_administration.
          endif.
        when 'HABW_T' or               "header processing
             'IABW_T' or               "item processing
             'ITOV_T'.                 "general item overview
          gf_process_view = gc_view_general.
        when 'HCUS_T' or                                                  "v_SPE
             'ICUS_T' or
             'WCUS_T'.
          gf_process_view = gc_view_customer.
        when 'SRMA_T'.
          gf_process_view = gc_view_returns.                              "^_SPE
        when others.
ENHANCEMENT-POINT TRANSFORM_VIEW_FCODE_02 SPOTS ES_SAPMV50A.
      endcase.
    endif.
  endif.

  set parameter id 'SHP_PROCESS_VIEW' field gf_process_view.

endform.                               " TRANSFORM_VIEW_FCODE