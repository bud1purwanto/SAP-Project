REPORT ztrain_alv_b.
* Latihan ALV B - REUSE_ALV_HIERSEQ_LIST_DISPLAY (header PO - item)
TYPE-POOLS: slis.
TABLES: ekko.

TYPES: BEGIN OF ty_head,
         ebeln TYPE ekko-ebeln,
         bedat TYPE ekko-bedat,
         lifnr TYPE ekko-lifnr,
         waers TYPE ekko-waers,
         expand TYPE c,
       END OF ty_head,
       BEGIN OF ty_item,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netwr TYPE ekpo-netwr,
       END OF ty_item.

DATA: gt_head TYPE STANDARD TABLE OF ty_head,
      gt_item TYPE STANDARD TABLE OF ty_item,
      gt_fcat TYPE slis_t_fieldcat_alv,
      gs_fcat TYPE slis_fieldcat_alv,
      gs_key  TYPE slis_keyinfo_alv,
      gs_lay  TYPE slis_layout_alv.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,
                s_bedat FOR ekko-bedat.

START-OF-SELECTION.
  SELECT ebeln bedat lifnr waers FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE gt_head
    WHERE ebeln IN s_ebeln AND bedat IN s_bedat
      AND bstyp = 'F'.            "hanya PO (bukan RFQ/kontrak)
  IF gt_head IS INITIAL.
    MESSAGE 'Data PO tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SELECT ebeln ebelp matnr txz01 menge meins netwr FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE gt_item
    FOR ALL ENTRIES IN gt_head
    WHERE ebeln = gt_head-ebeln AND loekz = space.
  SORT gt_item BY ebeln ebelp.

  PERFORM add USING 'GT_HEAD' 'EBELN' 'PO Number'.
  PERFORM add USING 'GT_HEAD' 'BEDAT' 'PO Date'.
  PERFORM add USING 'GT_HEAD' 'LIFNR' 'Vendor'.
  PERFORM add USING 'GT_HEAD' 'WAERS' 'Curr'.
  PERFORM add USING 'GT_ITEM' 'EBELP' 'Item'.
  PERFORM add USING 'GT_ITEM' 'MATNR' 'Material'.
  PERFORM add USING 'GT_ITEM' 'TXZ01' 'Description'.
  PERFORM add USING 'GT_ITEM' 'MENGE' 'Qty'.
  PERFORM add USING 'GT_ITEM' 'MEINS' 'UoM'.
  PERFORM add USING 'GT_ITEM' 'NETWR' 'Net Value'.

  gs_key-header01 = 'EBELN'.
  gs_key-item01   = 'EBELN'.
  gs_lay-expand_fieldname  = 'EXPAND'.
  gs_lay-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_lay
      it_fieldcat        = gt_fcat
      i_tabname_header   = 'GT_HEAD'
      i_tabname_item     = 'GT_ITEM'
      is_keyinfo         = gs_key
    TABLES
      t_outtab_header    = gt_head
      t_outtab_item      = gt_item
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE 'ALV error' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

FORM add USING p_tab p_field p_text.
  CLEAR gs_fcat.
  gs_fcat-tabname   = p_tab.
  gs_fcat-fieldname = p_field.
  gs_fcat-seltext_l = p_text.
  IF p_field = 'EBELN' OR p_field = 'EBELP'.
    gs_fcat-key = 'X'.
  ENDIF.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.
