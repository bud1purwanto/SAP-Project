REPORT ztrain_alv_a.
* Latihan ALV A - REUSE_ALV_GRID_DISPLAY (meniru pola ZMM052)
TYPE-POOLS: slis.
TABLES: ekko.

TYPES: BEGIN OF ty_po,
         ebeln TYPE ekko-ebeln,
         bedat TYPE ekko-bedat,
         lifnr TYPE ekko-lifnr,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netwr TYPE ekpo-netwr,
         waers TYPE ekko-waers,
         line_color(4) TYPE c,
       END OF ty_po.

DATA: gt_po     TYPE STANDARD TABLE OF ty_po,
      gs_po     TYPE ty_po,
      gt_fcat   TYPE slis_t_fieldcat_alv,
      gs_fcat   TYPE slis_fieldcat_alv,
      gs_layout TYPE slis_layout_alv.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,
                s_bedat FOR ekko-bedat,
                s_lifnr FOR ekko-lifnr.

START-OF-SELECTION.
  PERFORM get_data.
  IF gt_po IS INITIAL.
    MESSAGE 'Data PO tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  PERFORM set_color.
  PERFORM build_fcat.
  PERFORM display.

FORM get_data.
  SELECT k~ebeln k~bedat k~lifnr p~ebelp p~matnr p~txz01
         p~menge p~meins p~netwr k~waers
    INTO CORRESPONDING FIELDS OF TABLE gt_po
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    WHERE k~ebeln IN s_ebeln
      AND k~bedat IN s_bedat
      AND k~lifnr IN s_lifnr
      AND k~bstyp = 'F'          "hanya PO (bukan RFQ/kontrak)
      AND p~loekz = space.
ENDFORM.

FORM build_fcat.
  PERFORM add_fcat USING 'EBELN' 'PO Number'   'X' ' '.
  PERFORM add_fcat USING 'EBELP' 'Item'        ' ' ' '.
  PERFORM add_fcat USING 'BEDAT' 'PO Date'     ' ' ' '.
  PERFORM add_fcat USING 'LIFNR' 'Vendor'      ' ' ' '.
  PERFORM add_fcat USING 'MATNR' 'Material'    ' ' ' '.
  PERFORM add_fcat USING 'TXZ01' 'Description' ' ' ' '.
  PERFORM add_fcat USING 'MENGE' 'Qty'         ' ' ' '.
  PERFORM add_fcat USING 'MEINS' 'UoM'         ' ' ' '.
  PERFORM add_fcat USING 'NETWR' 'Net Value'   ' ' 'X'.
  PERFORM add_fcat USING 'WAERS' 'Curr'        ' ' ' '.
ENDFORM.

FORM add_fcat USING p_field p_text p_hotspot p_sum.
  CLEAR gs_fcat.
  gs_fcat-fieldname = p_field.
  gs_fcat-tabname   = 'GT_PO'.
  gs_fcat-seltext_l = p_text.
  gs_fcat-hotspot   = p_hotspot.
  gs_fcat-do_sum    = p_sum.
  IF p_field = 'NETWR'.
    gs_fcat-cfieldname = 'WAERS'.
  ENDIF.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.

FORM set_color.
  LOOP AT gt_po INTO gs_po.
    IF gs_po-netwr > 100000000.
      gs_po-line_color = 'C610'.
      MODIFY gt_po FROM gs_po.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM display.
  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname    = 'LINE_COLOR'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = gs_layout
      it_fieldcat             = gt_fcat
      i_save                  = 'A'
    TABLES
      t_outtab                = gt_po
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE 'ALV error' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  IF r_ucomm = '&IC1' AND rs_selfield-fieldname = 'EBELN'.
    READ TABLE gt_po INTO gs_po INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      SET PARAMETER ID 'BES' FIELD gs_po-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.

FORM top_of_page.
  DATA: lt_head TYPE slis_t_listheader,
        ls_head TYPE slis_listheader.
  ls_head-typ  = 'H'.
  ls_head-info = 'Daftar PO - Latihan ALV A'.
  APPEND ls_head TO lt_head.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM.
