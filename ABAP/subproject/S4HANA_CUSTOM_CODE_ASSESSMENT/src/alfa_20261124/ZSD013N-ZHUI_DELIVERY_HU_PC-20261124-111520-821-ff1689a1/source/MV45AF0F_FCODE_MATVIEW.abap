*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_MATVIEW
*&---------------------------------------------------------------------*

FORM fcode_matview.

  DATA: l_lines_vbap             TYPE sy-tabix,
         ls_vbap                  TYPE vbap,
         ls_komv                  TYPE komv,
       lt_komv                  TYPE va_komv_t,
       lt_materials             TYPE wsd_mv_materials_tty,
       ls_materials             TYPE wsd_mv_materials_sty,
       ls_mv_cfg                TYPE wsdt_mv_cfg.
  DATA: l_price_date             TYPE date,
        l_last_order_date_from_d TYPE sydatum,
        l_last_order_date_from   TYPE date,
        l_last_order_date_to     TYPE date,
        l_open_qty_date_d        TYPE sydatum,
        l_open_qty_date          TYPE date,
        l_inverse_selection      TYPE charx.
  DATA: lr_mat_view_badi TYPE REF TO badi_wsd_material_view_display.
  data: ls_WSD_COND_TYPE_MARGIN_ABS type WSD_COND_TYPE_MARGIN_ABS,
      ls_WSD_COND_TYPE_MARGIN_per type WSD_COND_TYPE_MARGIN_per.
  data: L_current_line type SYSTEPL.

  FIELD-SYMBOLS: <ls_ivbap>   LIKE ivbap,
                 <ls_svbep>  LIKE svbep,
                 <ls_xvbep>  LIKE xvbep.

  l_current_line = tc_selline.
  ls_mv_cfg = cl_wsd_config=>read_mat_view_config( cl_wsd_constants=>co_appl_sales_order ).

  read table ivbap with key selkz = 'X'
       transporting NO FIELDS.
  if sy-subrc <> 0.
    READ TABLE ivbap  ASSIGNING <ls_ivbap> INDEX l_current_line.
    if sy-subrc = 0.
      if <ls_ivbap>-selkz is initial.
        PERFORM XVBAP_MARKIEREN in PROGRAM SAPFV45P.
        READ TABLE ivbap  ASSIGNING <ls_ivbap> INDEX l_current_line.
        if  <ls_ivbap>-selkz is not initial.
          <ls_ivbap>-selkz = 'X'.
          l_inverse_selection = 'X'.
        endif.
      endif.
    endif.
  endif.

* check number of lines.
  DESCRIBE TABLE ivbap LINES l_lines_vbap.
  IF l_lines_vbap = 0.
    RETURN.
  ELSEIF l_lines_vbap = 1.

    READ TABLE ivbap  ASSIGNING <ls_ivbap> INDEX 1.
    IF  <ls_ivbap>-selkz IS INITIAL.
      <ls_ivbap>-selkz = 'X'.
      l_inverse_selection = 'X'.
    ENDIF.
  ENDIF.

  read table ivbap with key selkz = 'X'
       transporting NO FIELDS.
  if sy-subrc <> 0.
    message s323.
    return.
  endif.

* read first selected line
  LOOP AT ivbap ASSIGNING <ls_ivbap>
       WHERE selkz = 'X'.

    READ TABLE xvbap INTO ls_vbap INDEX <ls_ivbap>-tabix.

* General processing
    refresh lt_komv.
    vbap = ls_vbap.    perform KOEIN_ERMITTELN_N46(SAPFV45P).
    loop at xkomv into ls_komv where kposn = ls_vbap-posnr.
      append ls_komv to lt_komv.
    endloop.

    ls_materials-matnr = ls_vbap-matnr.
    ls_materials-plant = ls_vbap-werks.
    ls_materials-quantity             = ls_vbap-kwmeng.
    ls_materials-unit                 = ls_vbap-vrkme.

* get the net price
   data: lr_price_handler type ref to cl_wsd_price_handler.
   lr_price_handler = cl_wsd_price_handler=>get_instance( ).
   try.
       call method lr_price_handler->GET_PRICE_ELEMENT_VALUE
         exporting
             I_KALSM             = vbak-kalsm
             I_KVEWE             = cl_wsd_constants=>co_kvewe_a
             I_KAPPL             = cl_wsd_constants=>co_kappl_v
             I_PRICING_ELEMENT   = cl_wsd_constants=>CO_PE_NET_PRICE
             IT_KOMV             = lt_komv
             IS_KOMP             = tkomp
         importing
             e_value             = ls_materials-cust_price-price
             e_value_kpein       = ls_materials-cust_price-qty
             e_value_kmein       = ls_materials-cust_price-unit
             e_value_waers       = ls_materials-cust_price-currency.
      catch CX_WSD_NO_DATA_FOUND.
        clear:
          ls_materials-cust_price-qty,
          ls_materials-cust_price-unit,
          ls_materials-cust_price-currency.
    endtry.
"    ls_materials-cust_price-price     = ls_vbap-netpr.
    if ls_materials-cust_price-currency is initial.
      ls_materials-cust_price-currency  = ls_vbap-waerk.
    endif.
    if ls_materials-cust_price-qty is initial.
      ls_materials-cust_price-qty       = ls_vbap-kpein.
    endif.
    if ls_materials-cust_price-unit is initial.
      ls_materials-cust_price-unit      = ls_vbap-kmein.
    endif.

* get the list price
    data: l_kschl_listprice type kschl.
    TRY.
      CALL METHOD cl_wsd_price_handler=>get_list_price_condition_type
        EXPORTING
          i_order_type = vbak-auart
          i_vkorg      = vbak-vkorg
          i_vtweg      = vbak-vtweg
          i_spart      = vbak-spart
          i_kunnr      = vbak-kunnr
        IMPORTING
           e_kschl      =  l_kschl_listprice.
        CATCH cx_wsd_no_data_found .
        CATCH cx_wsd_exception .

    ENDTRY.

    READ TABLE xkomv INTO ls_komv
         WITH KEY kposn = ls_vbap-posnr
                  kschl = l_kschl_listprice.
    IF sy-subrc = 0.
      ls_materials-list_price-price     = ls_komv-kbetr.
      ls_materials-list_price-currency  = ls_komv-waers.
      ls_materials-list_price-qty       = ls_komv-kpein.
      ls_materials-list_price-unit      = ls_komv-kmein.
      ls_materials-pricing_date         = ls_komv-kdatu.
    ENDIF.

* begin read margin
    data: ls_order type bapiorders.
    ls_order-SD_DOC = vbak-VBELN.
    ls_order-ITM_NUMBER = ls_vbap-posnr.
    ls_order-MATERIAL = ls_vbap-matnr.
    ls_order-DOC_TYPE = vbak-auart.
    ls_order-SALES_ORG = vbak-vkorg.
    ls_order-DISTR_CHAN = vbak-vtweg.
    ls_order-division = vbak-spart.
    ls_order-PLANT =  ls_vbap-werks.

    CALL METHOD cl_wsd_price_handler=>GET_MARGIN
      EXPORTING
        IS_ORDER            = ls_order
        I_KVEWE             = cl_wsd_constants=>CO_KVEWE_A
        I_KAPPL             = cl_wsd_constants=>CO_KAPPL_V
        i_kunnr             = vbak-kunnr
        it_komv             = lt_komv
        is_komp             = tkomp
      IMPORTING
        E_MARGIN_ABSOLUTE   = ls_materials-margin_absolute
        E_MARGIN_PERCENTAGE = ls_materials-margin_percentage.
* end read margin


    READ TABLE svbep ASSIGNING <ls_svbep> INDEX <ls_ivbap>-tabix.
    IF sy-subrc = 0.
      READ TABLE xvbep ASSIGNING  <ls_xvbep> INDEX <ls_svbep>-tabix.
      IF sy-subrc = 0.
        IF ls_materials-plant IS INITIAL.
          MESSAGE s004(wsd_message) WITH <ls_ivbap>-posnr
                                         ls_vbap-matnr.
          CONTINUE.
        ENDIF.
        l_open_qty_date_d = <ls_xvbep>-edatu.
      ELSE.
        l_open_qty_date_d = sy-datum.
      ENDIF.
    ELSE.
      l_open_qty_date_d = sy-datum.
    ENDIF.

    ls_materials-open_qty_date = l_open_qty_date_d.
    APPEND ls_materials TO lt_materials.

  ENDLOOP.

  IF l_inverse_selection = 'X'.
    READ TABLE ivbap  ASSIGNING <ls_ivbap> INDEX l_current_line.
    CLEAR <ls_ivbap>-selkz.
    CLEAR l_inverse_selection.
  ENDIF.

  IF lt_materials IS INITIAL.
    RETURN.
  ENDIF.

  l_price_date           = vbkd-prsdt.
  l_last_order_date_from_d = sy-datum - ls_mv_cfg-so_offset.
  l_last_order_date_from = l_last_order_date_from_d.
  l_last_order_date_to   = sy-datum.

* If user badi exist, call it instead of our Material View
  TRY.
      GET BADI lr_mat_view_badi.
      CALL BADI lr_mat_view_badi->material_view_display
        EXPORTING
          i_app_name             = ls_mv_cfg-app_name
          i_materials            = lt_materials
          i_kunnr                = vbak-kunnr
          i_price_date           = l_price_date
          i_order_type           = vbak-auart
          i_last_order_date_from = l_last_order_date_from
          i_last_order_date_to   = l_last_order_date_to
          i_vkorg                = vbak-vkorg
          i_vtweg                = vbak-vtweg
          i_spart                = vbak-spart.

* If BAdi is not implemented, call our Material View
    CATCH cx_badi_not_implemented.
      CALL FUNCTION 'WSD_MATERIAL_VIEW_DISPLAY'
        DESTINATION 'NONE'
        EXPORTING
          i_app_name             = ls_mv_cfg-app_name
          i_materials            = lt_materials
          i_kunnr                = vbak-kunnr
          i_price_date           = l_price_date
          i_order_type           = vbak-auart
          i_last_order_date_from = l_last_order_date_from
          i_last_order_date_to   = l_last_order_date_to
          i_vkorg                = vbak-vkorg
          i_vtweg                = vbak-vtweg
          i_spart                = vbak-spart
        EXCEPTIONS
          system_failure         = 1
          communication_failure  = 2
          OTHERS                 = 3.

* We only support 1 BADI implementation, warn user.
    CATCH cx_badi_multiply_implemented.
      MESSAGE s093(wsd_message) WITH 'badi_wsd_material_view_display'.
      RETURN.

* All others errors are catched here
    CATCH cx_root.
      MESSAGE s093(wsd_message) WITH 'badi_wsd_material_view_display'.
      RETURN.
  ENDTRY.

ENDFORM.                    "fcode_matview