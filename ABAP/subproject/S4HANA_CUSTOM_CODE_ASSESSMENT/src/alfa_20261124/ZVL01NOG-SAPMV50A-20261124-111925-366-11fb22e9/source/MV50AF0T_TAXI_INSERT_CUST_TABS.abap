*&---------------------------------------------------------------------*
*&  Include           MV50AF0T_TAXI_INSERT_CUST_TABS                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  taxi_insert_cust_tabs
*&---------------------------------------------------------------------*
*       Rebuild caption structure taxi_tabstrip_captions and complete it
*       with the additional tab pages. Build administration table
*       GT_TAXI_ADMIN for the translation between the fcodes stored in
*       table TAXITABS and the actual fcodes belonging to the modified
*       tab sequence
*----------------------------------------------------------------------*
form taxi_insert_cust_tabs.

  data: begin of lt_tab_insert occurs 0,
          position like shp_cust_tab_page-head_position,
        end of lt_tab_insert,
        lf_caption          like taxi_tabstrip_captions-tab01,
        lf_counter          like sy-index,
        lf_position_counter like sy-index,
        lf_tabix            like sy-tabix,
        lf_position         like shp_cust_tab_page-head_position,
        ls_taxi_admin_cust  like line of gt_taxi_admin,
        ls_taxi_admin_orig  like line of gt_taxi_admin,
        lf_index_numc(2)    type n,
        lf_varname          type fieldname.

  field-symbols: <lf_caption>      like gs_cust_tab-head_caption,
                 <lf_customer_tab> like gs_cust_tab-tab_w,
                 <lf_taxi_caption> like taxi_tabstrip_captions-tab01.

* 1.) Fill administration table with the original sequence of
* captions ( = tab pages) (only necessary one time for each screen
* group)
  refresh gt_taxi_admin.
  do 32 times varying lf_caption
              from taxi_tabstrip_captions-tab01
              next taxi_tabstrip_captions-tab02.

    if lf_caption eq space.
      exit.
    endif.

    lf_index_numc = sy-index.
    concatenate c_prefix_captions_field lf_index_numc
                into gt_taxi_admin-fcode_old.

    gt_taxi_admin-fcode_new = gt_taxi_admin-fcode_old.

*   The "real" function code is also needed here in order to
*   suppress tabs for which the function code is deactivated by the
*   application
    call function 'TAXI_CONVERT_FCODE'
      exporting
        fcode_in        = gt_taxi_admin-fcode_new
      importing
        fcode_out       = gt_taxi_admin-fcode_real
      exceptions
        fcode_not_found = 1
        others          = 2.

    gt_taxi_admin-caption   = lf_caption.
    append gt_taxi_admin.

  enddo.

* 2.) The tabs that are deactivated because the assigned function code
* is not active must be handled here (they can not be suppressed by
* function module TAXI_CREATE_CAPTIONS as in former releases)
  loop at taxi_inactive_fcodes.
    delete gt_taxi_admin
           where fcode_real eq taxi_inactive_fcodes-fcode.
  endloop.

* 3.) Determine number of possible additional tab pages
  case taxi_screen_group(1).
    when 'W'. "item overview
      lf_counter = 1.
    when 'H'. "head detail
      lf_counter = 4.
    when 'I'. "item detail
      lf_counter = 2.
    when 'C'. "batch split item
      lf_counter = 2.
  endcase.

* 4.) Calculate positions for insertions. Note that the administrative
* table LT_TAB_INSERT must be filled in the same sequence as the
* additional tabs are inserted
  case taxi_screen_group(1).
    when 'W'.
      lt_tab_insert-position = gs_cust_tab-over_position.
      append lt_tab_insert.
    when 'H'.
      lt_tab_insert-position = gs_cust_tab-head_position.
      append lt_tab_insert.
      lt_tab_insert-position = gs_cust_tab-scem_position.
      append lt_tab_insert.
      lt_tab_insert-position = gs_cust_tab-gltr_position.
      append lt_tab_insert.
      lt_tab_insert-position = gs_cust_tab-auid_position.
      append lt_tab_insert.
    when 'I'.
      lt_tab_insert-position = gs_cust_tab-item_position.
      append lt_tab_insert.
      lt_tab_insert-position = gs_cust_tab-glti_position.
      append lt_tab_insert.
    when 'C'.
      lt_tab_insert-position = gs_cust_tab-item_position.
      append lt_tab_insert.
      lt_tab_insert-position = gs_cust_tab-glti_position.
      append lt_tab_insert.
  endcase.

* If a tab with a greater position number is inserted before a tab with
* a smaller position number this has to be taken into account here
* Example: 3 tabs should be inserted subsequently at positions 5, 2 and
* 6. Then the first tab must be inserted at position 4 because it is
* shifted by one position by the subsequent insertion of the second tab
* at position 2. The third tab position must not be changed because it
* can be inserted at the intended position
  do lf_counter times.
    read table lt_tab_insert index sy-index.
    if lt_tab_insert-position ne 0.
      lf_tabix = sy-tabix + 1.
      lf_position_counter = 0.
*     Search for subsequent tabs with a smaller position number. The
*     current position number has to be reduced by as many units as such
*     tabs were found
      loop at lt_tab_insert transporting no fields
                            from lf_tabix
                            where position lt lt_tab_insert-position
                              and position gt 0.
        add 1 to lf_position_counter.
      endloop.
      if lf_position_counter ne 0.
        subtract lf_position_counter from lt_tab_insert-position.
        modify lt_tab_insert index sy-index.
      endif.
    endif.
  enddo.

* Loop over all additional tabs
  do lf_counter times.

*   5.) Assign caption and desired position of customer tab according to
*   screen group. The field tab_x contains the technical name of the
*   customer tab (T\nn)
    case taxi_screen_group(1).
      when 'W'.
        assign gs_cust_tab-over_caption  to <lf_caption>.
        assign gs_cust_tab-tab_w         to <lf_customer_tab>.
      when 'H'.
        case sy-index.
          when 1.  "customer tab
            assign gs_cust_tab-head_caption  to <lf_caption>.
            assign gs_cust_tab-tab_h         to <lf_customer_tab>.
          when 2.  "SCEM tab
            assign gs_cust_tab-scem_caption  to <lf_caption>.
            assign gs_cust_tab-tab_s         to <lf_customer_tab>.
          when 3.  "Global Trade tab
            assign gs_cust_tab-gltr_caption  to <lf_caption>.
            assign gs_cust_tab-tab_g         to <lf_customer_tab>.
          when 4. "Auto-ID tab
            assign gs_cust_tab-auid_caption  to <lf_caption>.
            assign gs_cust_tab-tab_a         to <lf_customer_tab>.
        endcase.
      when 'I'.
        case sy-index.
          when 1.  "customer tab
            assign gs_cust_tab-item_caption  to <lf_caption>.
            assign gs_cust_tab-tab_i         to <lf_customer_tab>.
          when 2.  "Global Trade tab
            assign gs_cust_tab-glti_caption  to <lf_caption>.
            assign gs_cust_tab-tab_t         to <lf_customer_tab>.
        endcase.
      when 'C'.
        case sy-index.
          when 1.  "customer tab
            assign gs_cust_tab-item_caption  to <lf_caption>.
            assign gs_cust_tab-tab_c         to <lf_customer_tab>.
          when 2.  "Global Trade tab
            assign gs_cust_tab-glti_caption  to <lf_caption>.
            assign gs_cust_tab-tab_r         to <lf_customer_tab>.
        endcase.
    endcase.

*   Get recalculated position of the additional tab (from step 4.)
    read table lt_tab_insert index sy-index.
    lf_position = lt_tab_insert-position.

*   6.) Replace the caption of the additional tab currently processed
*   by 'C'
    loop at gt_taxi_admin where fcode_old eq <lf_customer_tab>.
      gt_taxi_admin-caption = 'C'.
      modify gt_taxi_admin from gt_taxi_admin transporting caption.
      exit.
    endloop.

*   7.) Insert customer tab page at the desired position if caption is
*   provided by BAdI method ACTIVATE_TAB_PAGE
    if <lf_caption> eq space.
*     No caption provided by BAdI? Suppress customer tab
      delete gt_taxi_admin where caption eq 'C'.
    else.
*     If desired position is greater than number of table rows: tab
*     is placed at the right corner
      describe table gt_taxi_admin lines sy-tfill.
      if lf_position gt sy-tfill.
        lf_position = sy-tfill.
      endif.
      if lf_position le 0.
        lf_position = 1.
      endif.
      read table gt_taxi_admin into ls_taxi_admin_orig
                               index lf_position.
      read table gt_taxi_admin into ls_taxi_admin_cust
                               with key caption = 'C'.
      if sy-subrc eq 0.
        ls_taxi_admin_orig-caption    = <lf_caption>.
        ls_taxi_admin_orig-fcode_old  = ls_taxi_admin_cust-fcode_old.
        ls_taxi_admin_orig-fcode_real = ls_taxi_admin_cust-fcode_real.
        insert ls_taxi_admin_orig into gt_taxi_admin index lf_position.
      endif.
*     Delete original entry
      delete gt_taxi_admin where caption eq 'C'.
    endif.

  enddo.  "End of loop over all additional tab pages


* 8.) The administration table GT_TAXI_ADMIN now contains the tab pages
* in the desired sequence and with the desired captions. The table has
* to be completed with the current fcodes to allow a translation
* between the actual tab structure visible on the screen and
* the tab structure inside function group TAXI (reflecting the state
* from table TAXITABS). Structure TAXI_TABSTRIP_CAPTIONS has to be
* provided with the current captions
  clear taxi_tabstrip_captions.
  loop at gt_taxi_admin.

    lf_index_numc = sy-tabix.
    concatenate c_prefix_captions_field lf_index_numc
                into gt_taxi_admin-fcode_new.
    modify gt_taxi_admin transporting fcode_new.

    concatenate 'taxi_tabstrip_captions-tab' lf_index_numc
                into lf_varname.
    assign (lf_varname) to <lf_taxi_caption>.
    <lf_taxi_caption> = gt_taxi_admin-caption.

  endloop.

endform.                    " taxi_insert_cust_tabs