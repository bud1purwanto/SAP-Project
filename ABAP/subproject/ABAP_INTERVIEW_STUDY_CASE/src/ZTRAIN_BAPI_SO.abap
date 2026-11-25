REPORT ztrain_bapi_so.
* Latihan BAPI - BAPI_SALESORDER_CREATEFROMDAT2 (+ EXTENSIONIN ZDATE/ZLINE)

PARAMETERS: p_auart TYPE vbak-auart OBLIGATORY,
            p_vkorg TYPE vbak-vkorg OBLIGATORY,
            p_vtweg TYPE vbak-vtweg OBLIGATORY,
            p_spart TYPE vbak-spart OBLIGATORY,
            p_kunag TYPE kunnr      OBLIGATORY,
            p_kunwe TYPE kunnr,
            p_bstkd TYPE vbkd-bstkd,
            p_matnr TYPE matnr      OBLIGATORY,
            p_werks TYPE werks_d,
            p_menge TYPE kwmeng     OBLIGATORY,
            p_zdate TYPE vbap-zdate,
            p_zline TYPE vbap-zline,
            p_test  AS CHECKBOX DEFAULT 'X'.

DATA: gs_head   TYPE bapisdhd1,
      gs_headx  TYPE bapisdhd1x,
      gt_item   TYPE STANDARD TABLE OF bapisditm,
      gs_item   TYPE bapisditm,
      gt_itemx  TYPE STANDARD TABLE OF bapisditmx,
      gs_itemx  TYPE bapisditmx,
      gt_part   TYPE STANDARD TABLE OF bapiparnr,
      gs_part   TYPE bapiparnr,
      gt_sch    TYPE STANDARD TABLE OF bapischdl,
      gs_sch    TYPE bapischdl,
      gt_schx   TYPE STANDARD TABLE OF bapischdlx,
      gs_schx   TYPE bapischdlx,
      gt_ext    TYPE STANDARD TABLE OF bapiparex,
      gs_ext    TYPE bapiparex,
      gs_bape   TYPE bape_vbap,
      gs_bapex  TYPE bape_vbapx,
      gt_return TYPE STANDARD TABLE OF bapiret2,
      gs_return TYPE bapiret2,
      gv_vbeln  TYPE vbak-vbeln,
      gv_error  TYPE c.

START-OF-SELECTION.
* Header
  gs_head-doc_type    = p_auart.
  gs_head-sales_org   = p_vkorg.
  gs_head-distr_chan  = p_vtweg.
  gs_head-division    = p_spart.
  gs_head-purch_no_c  = p_bstkd.
  gs_headx-updateflag = 'I'.
  gs_headx-doc_type   = 'X'.
  gs_headx-sales_org  = 'X'.
  gs_headx-distr_chan = 'X'.
  gs_headx-division   = 'X'.
  gs_headx-purch_no_c = 'X'.

* Partner
  gs_part-partn_role = 'AG'.
  gs_part-partn_numb = p_kunag.
  APPEND gs_part TO gt_part.
  IF p_kunwe IS NOT INITIAL.
    gs_part-partn_role = 'WE'.
    gs_part-partn_numb = p_kunwe.
    APPEND gs_part TO gt_part.
  ENDIF.

* Item
  gs_item-itm_number  = '000010'.
  gs_item-material    = p_matnr.
  gs_item-plant       = p_werks.
  APPEND gs_item TO gt_item.
  gs_itemx-itm_number = '000010'.
  gs_itemx-updateflag = 'I'.
  gs_itemx-material   = 'X'.
  gs_itemx-plant      = 'X'.
  APPEND gs_itemx TO gt_itemx.

* Schedule line (qty)
  gs_sch-itm_number  = '000010'.
  gs_sch-sched_line  = '0001'.
  gs_sch-req_qty     = p_menge.
  APPEND gs_sch TO gt_sch.
  gs_schx-itm_number = '000010'.
  gs_schx-sched_line = '0001'.
  gs_schx-updateflag = 'I'.
  gs_schx-req_qty    = 'X'.
  APPEND gs_schx TO gt_schx.

* Field custom VBAP-ZDATE / ZLINE lewat EXTENSIONIN
  gs_bape-posnr = '000010'.
  gs_bape-zdate = p_zdate.
  gs_bape-zline = p_zline.
  gs_ext-structure  = 'BAPE_VBAP'.
  gs_ext-valuepart1 = gs_bape.
  APPEND gs_ext TO gt_ext.
  gs_bapex-posnr = '000010'.
  gs_bapex-zdate = 'X'.
  gs_bapex-zline = 'X'.
  CLEAR gs_ext.
  gs_ext-structure  = 'BAPE_VBAPX'.
  gs_ext-valuepart1 = gs_bapex.
  APPEND gs_ext TO gt_ext.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in     = gs_head
      order_header_inx    = gs_headx
      testrun             = p_test
    IMPORTING
      salesdocument       = gv_vbeln
    TABLES
      return              = gt_return
      order_items_in      = gt_item
      order_items_inx     = gt_itemx
      order_partners      = gt_part
      order_schedules_in  = gt_sch
      order_schedules_inx = gt_schx
      extensionin         = gt_ext.

  LOOP AT gt_return INTO gs_return WHERE type = 'E' OR type = 'A'.
    gv_error = 'X'.
    EXIT.
  ENDLOOP.

  IF gv_error = 'X' OR p_test = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

  LOOP AT gt_return INTO gs_return.
    WRITE: / gs_return-type, gs_return-id, gs_return-number,
             gs_return-message.
  ENDLOOP.
  IF gv_error IS INITIAL AND p_test IS INITIAL.
    WRITE: / 'Sales Order dibuat:', gv_vbeln.
  ENDIF.
