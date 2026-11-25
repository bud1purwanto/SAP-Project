* Latihan OData (S/4 ADB) - method yang di-redefine di ZCL_ZTRN_PO_DPC_EXT
* Project SEGW ZTRN_PO: entity PurchaseOrder (set PurchaseOrderSet) dan
* POItem (set POItemSet), association PurchaseOrder 1:n POItem,
* navigation property ToItems. Tipe ZCL_ZTRN_PO_MPC=>TS_*/TT_* dibuat SEGW.
* Gaya sintaks klasik (tetap jalan di 7.54) supaya sama dengan modul ECC.

METHOD purchaseorderset_get_entityset.
* GET .../PurchaseOrderSet?$filter=Lifnr eq '0000100000'&$top=5
  DATA: lo_filter TYPE REF TO /iwbep/if_mgw_req_filter,
        lt_so     TYPE /iwbep/t_mgw_select_option,
        ls_so     TYPE /iwbep/s_mgw_select_option,
        lr_ebeln  TYPE RANGE OF ebeln,
        lr_lifnr  TYPE RANGE OF lifnr.

  lo_filter = io_tech_request_context->get_filter( ).
  lt_so = lo_filter->get_filter_select_options( ).
  LOOP AT lt_so INTO ls_so.
    CASE ls_so-property.
      WHEN 'EBELN'.
        lo_filter->convert_select_option(
          EXPORTING is_select_option = ls_so
          IMPORTING et_select_option = lr_ebeln ).
      WHEN 'LIFNR'.
        lo_filter->convert_select_option(
          EXPORTING is_select_option = ls_so
          IMPORTING et_select_option = lr_lifnr ).
    ENDCASE.
  ENDLOOP.

  SELECT ebeln bsart lifnr bedat waers
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE et_entityset
    WHERE ebeln IN lr_ebeln
      AND lifnr IN lr_lifnr
      AND bstyp = 'F'
    ORDER BY ebeln.

* $top / $skip
  /iwbep/cl_mgw_data_util=>paging(
    EXPORTING is_paging = is_paging
    CHANGING  ct_data   = et_entityset ).
ENDMETHOD.


METHOD purchaseorderset_get_entity.
* GET .../PurchaseOrderSet('4500000001')
  DATA: lt_keys  TYPE /iwbep/t_mgw_tech_pairs,
        ls_key   TYPE /iwbep/s_mgw_tech_pair,
        lv_ebeln TYPE ebeln.

  lt_keys = io_tech_request_context->get_keys( ).
  READ TABLE lt_keys INTO ls_key WITH KEY name = 'EBELN'.
  lv_ebeln = ls_key-value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING input  = lv_ebeln
    IMPORTING output = lv_ebeln.

  SELECT SINGLE ebeln bsart lifnr bedat waers
    FROM ekko
    INTO CORRESPONDING FIELDS OF er_entity
    WHERE ebeln = lv_ebeln
      AND bstyp = 'F'.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid  = /iwbep/cx_mgw_busi_exception=>business_error
        message = 'PO tidak ditemukan'.
  ENDIF.
ENDMETHOD.


METHOD poitemset_get_entityset.
* GET .../PurchaseOrderSet('4500000001')/ToItems   (navigasi)
* GET .../PurchaseOrderSet?$expand=ToItems         (framework memanggil ini)
* GET .../POItemSet?$filter=Ebeln eq '4500000001'
  DATA: lt_keys  TYPE /iwbep/t_mgw_tech_pairs,
        ls_key   TYPE /iwbep/s_mgw_tech_pair,
        lo_filter TYPE REF TO /iwbep/if_mgw_req_filter,
        lt_so    TYPE /iwbep/t_mgw_select_option,
        ls_so    TYPE /iwbep/s_mgw_select_option,
        lr_ebeln TYPE RANGE OF ebeln,
        ls_ebeln LIKE LINE OF lr_ebeln.

* 1) dipanggil lewat navigasi: kunci PO datang dari entity sumber
  lt_keys = io_tech_request_context->get_source_keys( ).
  READ TABLE lt_keys INTO ls_key WITH KEY name = 'EBELN'.
  IF sy-subrc = 0.
    ls_ebeln-sign   = 'I'.
    ls_ebeln-option = 'EQ'.
    ls_ebeln-low    = ls_key-value.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = ls_ebeln-low
      IMPORTING output = ls_ebeln-low.
    APPEND ls_ebeln TO lr_ebeln.
  ELSE.
* 2) dipanggil langsung dengan $filter
    lo_filter = io_tech_request_context->get_filter( ).
    lt_so = lo_filter->get_filter_select_options( ).
    READ TABLE lt_so INTO ls_so WITH KEY property = 'EBELN'.
    IF sy-subrc = 0.
      lo_filter->convert_select_option(
        EXPORTING is_select_option = ls_so
        IMPORTING et_select_option = lr_ebeln ).
    ENDIF.
  ENDIF.

  IF lr_ebeln IS INITIAL.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid  = /iwbep/cx_mgw_busi_exception=>business_error
        message = 'Isi filter Ebeln atau akses lewat PurchaseOrderSet'.
  ENDIF.

  SELECT ebeln ebelp matnr txz01 menge meins netwr
    FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE et_entityset
    WHERE ebeln IN lr_ebeln
      AND loekz = space
    ORDER BY ebeln ebelp.
ENDMETHOD.
