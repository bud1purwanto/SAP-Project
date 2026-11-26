FUNCTION-POOL migo MESSAGE-ID migo.

************************************************************************
* GLobal data for field transport
************************************************************************
TABLES:
  godynpro,                            "Screen fields
  gohead,                              "Header data
  goitem,                              "Item data
  gosearch_po,                         "PopUp Search Purchase Orders
  gosearch_ord,                        "PopUp Search Orders
  gosearch_res,                        "PopUp Search Orders
  godefault,                           "PopUp Default Values
  godefault_tv,                        "Table view for defaults
  GODEFAULT_TRA_TV,                    "Table view for transfer defaults
  gosplit,                             "Split Item
  goserial,                            "Serialnumbers
  gofreight,                           "Freight supplier
  gobom,                               "Parameter for BOM explosion
  goitem_tv,                           "tableview-fields
  gocomp_tv,                           "Component consumption tableview
  rl50e.                               "Workarea
ENHANCEMENT-POINT LMIGOTOP_06 SPOTS ES_SAPLMIGO STATIC.

DATA:
  okcode TYPE syucomm,                 "OK-code
  ok_check TYPE flag.                  "Simulation mode         "1102164
************************************************************************
* ABAP Controls
************************************************************************
CONTROLS:
  tv_goitem    TYPE TABLEVIEW USING SCREEN '0200',
  tv_gocomp    TYPE TABLEVIEW USING SCREEN '0323',      "BT
  tv_gofreight TYPE TABLEVIEW USING SCREEN '0330',
  tv_goserial  TYPE TABLEVIEW USING SCREEN '0360',
  tv_gosplit   TYPE TABLEVIEW USING SCREEN '1000',
  tv_godefault TYPE TABLEVIEW USING SCREEN '1100',
  tv_godefault_transfer TYPE TABLEVIEW USING SCREEN '1110',
  ts_gohead    TYPE TABSTRIP,
  ts_goitem    TYPE TABSTRIP.
ENHANCEMENT-POINT LMIGOTOP_07 SPOTS ES_SAPLMIGO STATIC.
* IS2ERP IS-CWM CWEK001982 begin
* retrofit for dynpro 8200 in SAPLMIGO
CONTROLS:
  tv_goitem_8200    TYPE TABLEVIEW USING SCREEN '8200'.
*IS2ERP IS-CWM CWEK001982 end

************************************************************************
* Type pools
************************************************************************
TYPE-POOLS:
  abap,
  slis.

************************************************************************
* Commonly usable defines (no defines used in a single class only!)
************************************************************************
DEFINE def_boolean_toggle.
  if &1 = abap_false.
    &1 = abap_true.
  else.
    &1 = abap_false.
  endif.
END-OF-DEFINITION.

************************************************************************
* Constants           (begin with c_ except alphabet)
************************************************************************
INCLUDE:
  <icon>.
CONSTANTS:
* for screen modification
  c_mod_on              TYPE c             VALUE '1',
  c_mod_off             TYPE c             VALUE '0',
  c_mod_off_blank       TYPE c             VALUE ' ',
  c_repid               TYPE sy-repid      VALUE 'SAPLMIGO',
* output determination
  c_nast_appl           TYPE sna_kappl     VALUE 'ME',
* empties processing
  c_uptyp_lg            TYPE c             VALUE '3',
  c_upvor_vg            TYPE c             VALUE '3',
* Discount in kind: inclusive / exclusive bonus qty
  c_uptyp_nre           TYPE c             VALUE '2',  "1099242
  c_uptyp_nra           TYPE c             VALUE '4',  "1099242
* Literals
  a TYPE c VALUE 'A',
  b TYPE c VALUE 'B',
  c TYPE c VALUE 'C',
  d TYPE c VALUE 'D',
  e TYPE c VALUE 'E',
  f TYPE c VALUE 'F',
  h TYPE c VALUE 'H',
  i TYPE c VALUE 'I',
  j TYPE c VALUE 'J',
  k TYPE c VALUE 'K',
  l TYPE c VALUE 'L',
  m TYPE c VALUE 'M',
  n TYPE c VALUE 'N',
  o TYPE c VALUE 'O',
  p TYPE c VALUE 'P',
  q TYPE c VALUE 'Q',
  r TYPE c VALUE 'R',
  s TYPE c VALUE 'S',
  t TYPE c VALUE 'T',
  u TYPE c VALUE 'U',
  v TYPE c VALUE 'V',
  w TYPE c VALUE 'W',
  x TYPE c VALUE 'X',
* Icons for line expansion
  c_icon_expand   TYPE char4 VALUE '@3S@',
  c_icon_collapse TYPE char4 VALUE '@3T@'.


************************************************************************
* INCLUDES: please do not sort alphabetically!!!
* problems with the sequence of data definition
************************************************************************

* Deferred definitions to avoid interlocking
CLASS lcl_migo_defaults       DEFINITION DEFERRED.
CLASS lcl_migo_screenobject   DEFINITION DEFERRED.
CLASS lcl_migo_kernel         DEFINITION DEFERRED.
CLASS lcl_migo_cursor         DEFINITION DEFERRED.
CLASS lcl_migo_griddisplay    DEFINITION DEFERRED.
* Definition loads for have access on some class components
CLASS cl_mmim_auth            DEFINITION LOAD.
CLASS cl_mmim_line_id_manager DEFINITION LOAD.
CLASS cl_mmim_cross_system    DEFINITION LOAD.                   "sdp462
ENHANCEMENT-POINT LMIGOTOP_01 SPOTS ES_SAPLMIGO STATIC.

INCLUDE lmigoif1. " Interface
INCLUDE lmigobu1. " Buffer
INCLUDE lmigogl1. " Globals
INCLUDE lmigolo1. " Application log
INCLUDE lmigoso1. " Screenobject (abstract)
INCLUDE lmigobo1. " BOM parameters
INCLUDE lmigoke1. " Kernel
INCLUDE lmigode1. " Default values kernel section
INCLUDE lmigoeq1. " Enqueue management
INCLUDE lmigofr1. " Framework
INCLUDE lmigocu1. " Cursor
INCLUDE lmigotp1. " Tips
INCLUDE lmigosr1. " Search functions
INCLUDE lmigoca1. " Control area
INCLUDE lmigogd1. " Grid display
INCLUDE lmigoen1. " Environment functions
INCLUDE lmigodo1. " Detailobject (abstract)
INCLUDE lmigodc1. " Detail carrier
INCLUDE lmigoda1. " Detail tabstrip account
INCLUDE lmigoda3. " Detail tabstrip MAA   - MAA-DEV
INCLUDE lmigodb1. " Detail tabstrip batch
INCLUDE lmigodb3. " Detail tabstrip documentary batch
INCLUDE lmigodd1. " Detail tabstrip destination
INCLUDE lmigodf1. " Detail tabstrip freight
INCLUDE lmigodi1. " Detail tabstrip import
INCLUDE lmigodl1. " Dynpro locator
INCLUDE lmigodm1. " Detail tabstrip material
INCLUDE lmigodn1. " Detail tabstrip output determination (NAST)
INCLUDE lmigodp1. " Detail tabstrip purchase order
INCLUDE lmigodp3. " Detail tabstrip partners
INCLUDE lmigodp5. " Detail tabstrip po sc components              "Outsourced Manufacturing EhP 4
INCLUDE lmigodr3. " Detail tabstrip Retail generic articles
INCLUDE lmigodo3. " Detail tabstrip order
INCLUDE lmigodt3. " Detail tabstrip transfer po
INCLUDE lmigodt5. " Detail TAKE_IT
INCLUDE lmigodt7. " Detail tabstrip transfer
INCLUDE lmigods1. " Detail tabstrip serial numbers
INCLUDE lmigodq1. " Detail tabstrip quantity
INCLUDE lmigodt1. " Detail tabstrip taxes
INCLUDE lmigodw1. " Detail tabstrip wm  " EhP 603
INCLUDE lmigodx1. " Detail tabstrip ewm
INCLUDE lmigody1. " Detail tabstrip external subs for internal "EHP606 CFB
INCLUDE lmigofh1. " Field help
INCLUDE lmigoho1. " Headerobject (abstract)
INCLUDE lmigohc1. " Header carrier
INCLUDE lmigohg1. " Header tabstrip general
INCLUDE lmigohv1. " Header tabstrip vendor
INCLUDE lmigohp1. " Header tabstrip people
INCLUDE lmigohd1. " Header tabstrip document info
INCLUDE lmigohi1. " Header tabstrip import
INCLUDE lmigojb1. " Status nota fiscal
INCLUDE lmigopr1. " Predocuments
INCLUDE lmigost1. " GUI status
INCLUDE lmigosm3. " Screenmodification
INCLUDE lmigosm1. " Screenmanager
INCLUDE lmigoto1. " Toggler
INCLUDE lmigofl1. " First line
INCLUDE lmigotr1. " Trace
INCLUDE lmigoti1. " Titlebar
INCLUDE lmigosp1. " Split quantity
INCLUDE lmigods5. " Determine stock
INCLUDE lmigotv1. " Tableview
INCLUDE lmigoht1. " HTML-Help
INCLUDE lmigotr3. " Tree
INCLUDE lmigotra. " New tree
INCLUDE lmigodr1. " Detail tabstrip reservation
INCLUDE lmigoar1. " optical archiving

ENHANCEMENT-POINT LMIGOTOP_02 SPOTS ES_SAPLMIGO STATIC.
************************************************************************
* Classes
************************************************************************
DATA:
  oref_defaults          TYPE REF TO lcl_migo_defaults,
  oref_bom               TYPE REF TO lcl_migo_bom,
  oref_environment       TYPE REF TO lcl_migo_environment,
  oref_firstline         TYPE REF TO lcl_migo_firstline,
  oref_log               TYPE REF TO lcl_migo_log,
  oref_doc_log           TYPE REF TO lcl_migo_log,
  oref_atp_log           TYPE REF TO lcl_migo_log,              "703419
  oref_badi_log          TYPE REF TO lcl_migo_log,              "ERP2005
  oref_status            TYPE REF TO lcl_migo_status,
  oref_nota_fiscal       TYPE REF TO lcl_migo_nota_fiscal,
  oref_screenmanager     TYPE REF TO lcl_migo_screenmanager,
  oref_tip               TYPE REF TO lcl_migo_tip,
  oref_titlebar          TYPE REF TO lcl_migo_titlebar,
  oref_predocument       TYPE REF TO lcl_migo_predocument,
  oref_arch              TYPE REF TO lcl_migo_arch,
  oref_dynprolocator     TYPE REF TO lcl_migo_dynprolocator,

* Header
  oref_header            TYPE REF TO lcl_migo_header,
  oref_header_general    TYPE REF TO lcl_migo_header_general,
  oref_header_vendor     TYPE REF TO lcl_migo_header_vendor,
  oref_header_people     TYPE REF TO lcl_migo_header_people,
  oref_header_docinfo    TYPE REF TO lcl_migo_header_docinfo,
  oref_header_import     TYPE REF TO lcl_migo_header_import,
* Detail
  oref_detail            TYPE REF TO lcl_migo_detail,
  oref_detail_material   TYPE REF TO lcl_migo_detail_material,
  oref_detail_quantity   TYPE REF TO lcl_migo_detail_quantity,
  oref_detail_po         TYPE REF TO lcl_migo_detail_po,

  oref_detail_po_sc      TYPE REF TO lcl_migo_detail_po_sc,         "Outsourced Manufacturing EhP 4

  oref_detail_order      TYPE REF TO lcl_migo_detail_order,
  oref_detail_partners   TYPE REF TO lcl_migo_detail_partners,
  oref_detail_transfer   TYPE REF TO lcl_migo_detail_transfer,  "for po
  oref_detail_trans      TYPE REF TO lcl_migo_detail_trans,
  oref_detail_takeit     TYPE REF TO lcl_migo_detail_takeit,
  oref_detail_dest       TYPE REF TO lcl_migo_detail_dest,
  oref_detail_batch      TYPE REF TO lcl_migo_detail_batch,
  oref_detail_doc_batch  TYPE REF TO lcl_migo_detail_doc_batch,
  oref_detail_output     TYPE REF TO lcl_migo_detail_output,
  oref_detail_account    TYPE REF TO lcl_migo_detail_account,
  oref_detail_maa        TYPE REF TO lcl_migo_detail_maa,             "MAA-DEV
  oref_detail_freight    TYPE REF TO lcl_migo_detail_freight,
  oref_detail_import     TYPE REF TO lcl_migo_detail_import,
  oref_detail_taxes      TYPE REF TO lcl_migo_detail_taxes,
  oref_detail_serial_numbers
                         TYPE REF TO lcl_migo_detail_serial_numbers,
  oref_serial_container  TYPE REF TO cl_gui_custom_container,    "637093
  oref_detail_ga         TYPE REF TO lcl_migo_detail_ga,
  oref_detail_wm         TYPE REF TO lcl_migo_detail_wm,
  oref_detail_ewm        TYPE REF TO lcl_migo_detail_ewm,
  oref_detail_ext_int    TYPE REF TO lcl_migo_detail_ext_int,  "EHP606 CFB
  oref_header_toggler    TYPE REF TO lcl_migo_toggler,
  oref_tv_toggler        TYPE REF TO lcl_migo_toggler,
  oref_detail_toggler    TYPE REF TO lcl_migo_toggler,
  oref_trace             TYPE REF TO lcl_migo_trace,
  oref_split_quantity    TYPE REF TO lcl_migo_split_quantity,
  oref_determine_stock   TYPE REF TO lcl_migo_determine_stock,
  oref_tableview         TYPE REF TO lcl_migo_tableview,
  oref_tableview_buttons TYPE REF TO lcl_migo_tableview_buttons,
  oref_search            TYPE REF TO lcl_migo_search,
  oref_field_help        TYPE REF TO lcl_migo_field_help,
  oref_tree              TYPE REF TO lcl_migo_tree,
  oref_html_help         TYPE REF TO lcl_migo_html_help,
  oref_controlarea       TYPE REF TO lcl_migo_controlarea,
  oref_detail_reservation
                         TYPE REF TO lcl_migo_detail_reservation.

data : go_mmim_maa_2 type ref to cl_mmim_maa_2.            "MAA2
ENHANCEMENT-POINT LMIGOTOP_03 SPOTS ES_SAPLMIGO STATIC.

************************************************************************
* Global data. Necessary only for dynpro communications.
* Dynamic button-texts have to be global, and subscreen numbers
* as public components in classes will work but raise errors in SLIN.
************************************************************************
DATA:
* Dynamic texts for the GUI status have to be global
  g_tree_button_text    TYPE char40,                         "#EC NEEDED
* Dummy field in dynpro 0001
  g_dummy_field         TYPE char4,                          "#EC NEEDED
* Dummy field for dynpros "Frieght" and "Serial numbers".
* If not present,
* the frontend will not place the cursor into this subscreen
* when selecting it as active tab --> tab will change upon
* OK-code.
  g_dummy_serial        TYPE char1,                          "#EC NEEDED
  g_dummy_freight       TYPE char1,                          "#EC NEEDED
* Subscreen numbers
  g_screenmanager_dynnr TYPE sydynnr,                        "#EC NEEDED
  g_firstline_screen    TYPE sydynnr VALUE '0010',           "#EC NEEDED
  g_firstline_subscreen TYPE sydynnr,                        "#EC NEEDED
  g_header_current_dyn  TYPE sydynnr,                        "#EC NEEDED
  g_header_subscreen    TYPE sydynnr,                        "#EC NEEDED
  g_detail_current_dyn  TYPE sydynnr,                        "#EC NEEDED
  g_detail_subscreen    TYPE sydynnr,                        "#EC NEEDED
  g_tablev_current_dyn  TYPE sydynnr,                        "#EC NEEDED
  g_tablev_subscreen    TYPE sydynnr,                        "#EC NEEDED
  g_sub_account         TYPE sydynnr,                        "#EC NEEDED
  g_sub_batch           TYPE sydynnr,                        "#EC NEEDED
  g_sub_freight         TYPE sydynnr,                        "#EC NEEDED
  g_sub_import          TYPE sydynnr,                        "#EC NEEDED
  g_sub_nast            TYPE sydynnr,                        "#EC NEEDED
  g_sub_order           TYPE sydynnr,                        "#EC NEEDED
  g_sub_po              TYPE sydynnr,                        "#EC NEEDED
  g_sub_serial          TYPE sydynnr,                        "#EC NEEDED
  g_sub_transfer        TYPE sydynnr,                        "#EC NEEDED
  g_sub_ga              TYPE sydynnr VALUE '4000',           "#EC NEEDED
  g_sub_wm              TYPE sydynnr,                        "#EC NEEDED
  g_sub_ewm             TYPE sydynnr,                        "#EC NEEDED
  g_sub_sc              TYPE sydynnr,                        "#EC NEEDED Outsourced Manufacturing EhP 4
  g_sub_taxes           TYPE sydynnr,                        "Note 316975
  g_cobl_subscreen      TYPE tcobl-dynnr,                    "#EC NEEDED
  g_cobl_progn          TYPE sycprog,                        "#EC NEEDED
  g_maa_subscreen       TYPE sydynnr,                        " MAA-DEV
  g_maa_progn           TYPE sycprog,                        " MAA-DEV
  g_sub_res             TYPE sydynnr,                        "#EC NEEDED
  g_sub_stock_identifier TYPE sydynnr,                       "#EC NEEDED
  g_qm_prog             TYPE sycprog,                        "#EC NEEDED
  g_sub_qm_cert         TYPE sydynnr,                        "#EC NEEDED
  g_sub_partners        TYPE sydynnr,                            "381347
  g_sub_transfer_left   TYPE sydynnr,                        "#EC NEEDED
  g_sub_transfer_right  TYPE sydynnr,                        "#EC NEEDED
  g_sub_date_batch      TYPE sydynnr,                        "#EC NEEDED
  g_sub_ext_int         TYPE sydynnr,                        "#EC NEEDED  "EHP606 CFB

* BAdI: External Screens (default to empty MIGO screen [2099] if unused)
* External screen 1 (detail):
  g_ext1_cprog          TYPE sycprog VALUE sy-repid,
  g_ext1_dynnr          TYPE sydynnr VALUE '2099',
  ts_goitem_ext_1       TYPE migo_badi_heading,
* External screen 1 (header):
  g_ext1_head_dynnr     TYPE sydynnr VALUE '2099',
  ts_gohead_ext_1       TYPE migo_badi_heading,
* External screen 2 (detail):
  g_ext2_cprog          TYPE sycprog VALUE sy-repid,
  g_ext2_dynnr          TYPE sydynnr VALUE '2099',
  ts_goitem_ext_2       TYPE migo_badi_heading,
* External screen 2 (header):
  g_ext2_head_dynnr     TYPE sydynnr VALUE '2099',
  ts_gohead_ext_2       TYPE migo_badi_heading,
* External screen 3 (detail):
  g_ext3_cprog          TYPE sycprog VALUE sy-repid,
  g_ext3_dynnr          TYPE sydynnr VALUE '2099',
  ts_goitem_ext_3       TYPE migo_badi_heading,
* External screen 3 (header):
  g_ext3_head_dynnr     TYPE sydynnr VALUE '2099',
  ts_gohead_ext_3       TYPE migo_badi_heading,
* External screen 4 (detail):
  g_ext4_cprog          TYPE sycprog VALUE sy-repid,
  g_ext4_dynnr          TYPE sydynnr VALUE '2099',
  ts_goitem_ext_4       TYPE migo_badi_heading,
* External screen 4 (header):
  g_ext4_head_dynnr     TYPE sydynnr VALUE '2099',
  ts_gohead_ext_4       TYPE migo_badi_heading,
* External screen 5 (detail):
  g_ext5_cprog          TYPE sycprog VALUE sy-repid,
  g_ext5_dynnr          TYPE sydynnr VALUE '2099',
  ts_goitem_ext_5       TYPE migo_badi_heading,
* External screen 5 (header):
  g_ext5_head_dynnr     TYPE sydynnr VALUE '2099',
  ts_gohead_ext_5       TYPE migo_badi_heading,

* subscreen numbers for header
  g_sub_general         TYPE sydynnr,                        "#EC NEEDED
  g_sub_vendor          TYPE sydynnr,                        "#EC NEEDED

* Popup: Split quantity
  g_split_maktx         TYPE goitem-maktx,
  g_split_name1         TYPE goitem-name1,
  g_split_matnr         TYPE goitem-matnr,
  g_split_werks         TYPE goitem-werks,
  g_split_erfme         TYPE goitem-erfme,
  g_sum_quantity        TYPE goitem-erfmg,

* Popup: Tip
  g_tip_dont_show_again TYPE migo_tip_dont_show.

*IS2ERP CWM
DATA: L_INCL_DYNP type SYDYNNR.

* EHP 606 CFB
DATA: if_badi_ext_int      TYPE REF TO mb_migo_badi_ext_int. "screen BAdi
DATA: ts_goitem_ext_int    TYPE scrfstxg.
DATA: gv_scrn_badi_no_tab  TYPE text100.
DATA: gv_scrn_badi_dynpro  TYPE scradnum,
      gv_scrn_badi_program TYPE program.


ENHANCEMENT-POINT LMIGOTOP_04 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-POINT LMIGOTOP_05 SPOTS ES_SAPLMIGO STATIC.