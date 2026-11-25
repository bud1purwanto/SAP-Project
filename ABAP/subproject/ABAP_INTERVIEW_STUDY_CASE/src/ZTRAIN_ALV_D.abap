REPORT ztrain_alv_d.
* Latihan ALV D - CL_SALV_TABLE
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
       END OF ty_po.

DATA: gt_po   TYPE STANDARD TABLE OF ty_po,
      gs_po   TYPE ty_po,
      go_salv TYPE REF TO cl_salv_table,
      go_cols TYPE REF TO cl_salv_columns_table,
      go_col  TYPE REF TO cl_salv_column_table,
      go_agg  TYPE REF TO cl_salv_aggregations,
      lx_msg  TYPE REF TO cx_salv_msg,
      go_evt  TYPE REF TO cl_salv_events_table,
      lx_any  TYPE REF TO cx_root.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,
                s_bedat FOR ekko-bedat.

CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    METHODS on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_events IMPLEMENTATION.
  METHOD on_link_click.
    READ TABLE gt_po INTO gs_po INDEX row.
    IF sy-subrc = 0 AND column = 'EBELN'.
      SET PARAMETER ID 'BES' FIELD gs_po-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

DATA: go_events TYPE REF TO lcl_events.

START-OF-SELECTION.
  SELECT k~ebeln k~bedat k~lifnr p~ebelp p~matnr p~txz01
         p~menge p~meins p~netwr k~waers
    INTO CORRESPONDING FIELDS OF TABLE gt_po
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    WHERE k~ebeln IN s_ebeln
      AND k~bedat IN s_bedat
      AND k~bstyp = 'F'          "hanya PO (bukan RFQ/kontrak)
      AND p~loekz = space.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_salv
                              CHANGING  t_table      = gt_po ).
    CATCH cx_salv_msg INTO lx_msg.
      MESSAGE lx_msg TYPE 'E'.
  ENDTRY.

  go_salv->get_functions( )->set_all( abap_true ).
  go_cols = go_salv->get_columns( ).
  go_cols->set_optimize( abap_true ).
  TRY.
      go_col ?= go_cols->get_column( 'EBELN' ).
      go_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
      go_col ?= go_cols->get_column( 'NETWR' ).
      go_col->set_currency_column( 'WAERS' ).   "total per mata uang
      go_agg = go_salv->get_aggregations( ).
      go_agg->add_aggregation( columnname = 'NETWR' ).
    CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing INTO lx_any.
      MESSAGE lx_any TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

  CREATE OBJECT go_events.
  go_evt = go_salv->get_event( ).
  SET HANDLER go_events->on_link_click FOR go_evt.
  go_salv->display( ).
