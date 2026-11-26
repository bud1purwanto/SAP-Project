*----------------------------------------------------------------------*
*   INCLUDE LMIGOEN1                                                   *
*   Environment functions
*----------------------------------------------------------------------*

CLASS lcl_migo_environment DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
*   This one is externally visible because it can be called from
*   the "batch classification"-button in display and cancel mode.
*   Otherwise, this buttons does completely different things...
    batch_show
      IMPORTING i_matnr TYPE matnr
                i_werks TYPE werks_d
                i_lgort TYPE lgort_d
                i_charg TYPE charg_d
                i_classification TYPE abap_bool DEFAULT abap_false.

PRIVATE SECTION.
  TYPES:
    BEGIN OF ty_s_setget,
      parid TYPE memoryid,
      parva TYPE xuvalue,
    END OF ty_s_setget.
  DATA:
    p_itemdetail_line TYPE sytabix,
    pt_setget         TYPE STANDARD TABLE OF ty_s_setget.
  METHODS:
    setget_save
      IMPORTING i_list TYPE string,
    setget_restore,
    migo_call_transaction
      IMPORTING i_tcode          TYPE sytcode
                i_nocall         TYPE abap_bool DEFAULT abap_false
      EXPORTING e_not_authorized TYPE abap_bool,
    stock_overview_show
      IMPORTING i_matnr TYPE matnr
                i_werks TYPE werks_d OPTIONAL,
    material_show
      IMPORTING i_matnr TYPE matnr
                i_werks TYPE werks_d OPTIONAL
                i_lgort TYPE lgort_d OPTIONAL
                i_bwtar TYPE bwtar_d OPTIONAL
                i_mxx   TYPE char10,
    vendor_address_show
      IMPORTING i_lifnr TYPE elifn
                i_bukrs TYPE bukrs OPTIONAL
                i_ekorg TYPE ekorg OPTIONAL
                i_bsakz TYPE bsakz OPTIONAL,
    inforecord_show
      IMPORTING i_lifnr TYPE elifn
                i_werks TYPE werks_d
                i_matnr TYPE matnr
                i_ekorg TYPE ekorg
                i_sobkz TYPE sobkz,
    fi_document_show
      IMPORTING i_mblnr TYPE mblnr
"               i_zeile type mblpo : not relevant in PA0 an PA9

                i_mjahr TYPE mjahr
                i_awsys TYPE logsystem OPTIONAL,
    purchase_order_show
      IMPORTING i_ebeln TYPE ebeln
                i_ebelp TYPE ebelp OPTIONAL,
    po_history_show
      IMPORTING i_ebeln TYPE ebeln
                i_ebelp TYPE ebelp,
*               i_bstyp TYPE bstyp OPTIONAL            "316149
*               i_pstyp TYPE pstyp OPTIONAL            "316149
*               i_retpo TYPE retpo OPTIONAL            "316149
*               i_webre TYPE webre OPTIONAL,           "316149
    delivery_show                                      "428337
      IMPORTING i_mblnr TYPE mblnr
                i_mjahr TYPE mjahr
                i_vbeln TYPE xblnr1,
    wm_show
      IMPORTING i_lgnum TYPE lgnum
                i_tbnum TYPE tbnum
                i_tbpos TYPE tbpos,
    handling_unit_show
      IMPORTING i_mblnr TYPE mblnr
                i_mjahr TYPE mjahr,
    inspection_lot_show
      IMPORTING i_mblnr TYPE mblnr
                i_mjahr TYPE mjahr
                i_zeile TYPE mblpo,
    useraddress_show
      IMPORTING i_uname  TYPE syuname   OPTIONAL
                i_string TYPE so_adrnam OPTIONAL,
    serialnumber_show
      IMPORTING i_matnr TYPE matnr
                i_sernr TYPE gernr,
    account_show
      IMPORTING i_konto TYPE hkont
                i_bukrs TYPE bukrs,
    linked_documents_show
      IMPORTING i_matnr TYPE matnr,
    reservation_show
      IMPORTING i_rsnum TYPE rsnum,
    order_show
      IMPORTING i_aufnr TYPE aufnr,
    customer_address_show
      IMPORTING i_kunnr TYPE kunnr
                i_bukrs TYPE bukrs OPTIONAL.

ENDCLASS.