*----------------------------------------------------------------------*
*   INCLUDE LMIGOKE1                                                   *
*----------------------------------------------------------------------*

* Feb 2009 MM                                               "n1306620
* enable MIGO to display MM docs from the AIS archive, too  "n1306620

CLASS lcl_migo_kernel DEFINITION.
************************************************************************
* Careful: Only define a method as public if needed outside the kernel
* Most kernel methods should be PRIVATE!!
************************************************************************
*----------------------------------------------------------------------*
* PUBLIC SECTION
*----------------------------------------------------------------------*
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
*----------------------------------------------------------------------*
* Public types
*----------------------------------------------------------------------*
    TYPES:
*     Type of reference document, derived from ACTION and REFDOC
      ty_refdoctype(3) TYPE c,
*     Migo-mode.
*     Used to steer the selcetion of the table control variant
*     and authorization checks. Derived from ACTION/REFDOC/VGART
      ty_migo_mode TYPE char10,
*     Current ACTION data, derived from S_CONTROL-ACTION
      BEGIN OF ty_s_action,
        cancel     TYPE abap_bool,     "Cancel material document
        create     TYPE abap_bool,     "Create material document
        copy       TYPE abap_bool,     "Copy   material document  ERP 10
                                       "( take it as a template )
        display    TYPE abap_bool,     "Display material document
        receipt    TYPE abap_bool,     "Normal goods receipt
        release    TYPE abap_bool,     "Release blocked stock
        return     TYPE abap_bool,     "Return to material document
        subsequent TYPE abap_bool,     "Subsequent delivery (WE**3)
        sc_comp    TYPE abap_bool,     "Outsourced Manufacturing EhP 4 /in-time consumption component
        place      TYPE abap_bool,     "Place in storage
        issue      TYPE abap_bool,
        migo_mode  TYPE ty_migo_mode,
        refdoctype TYPE ty_refdoctype,
      END OF ty_s_action,
*     Current kernel status. Derived from contents of T_GOITEM
*     Determines which detail tabstrips should be visible
      BEGIN OF ty_s_status,
        xtaxes    TYPE abap_bool,
        xbatch    TYPE abap_bool,
        xaccount  TYPE abap_bool,
        xserial   TYPE abap_bool,
        xlinks    TYPE abap_bool,
        xfreight  TYPE abap_bool,
        xnast     TYPE abap_bool,
        xpartners TYPE abap_bool,
        ximport   TYPE abap_bool,
        xloglight TYPE abap_bool,
        xpoitem   TYPE abap_bool,
        xstpoitem TYPE abap_bool,
        xorditem  TYPE abap_bool,
        xresitem  TYPE abap_bool,
        xwm       TYPE abap_bool,
        ewm       type abap_bool,
        xpo_sc    type abap_bool,      "Outsourced Manufacturing EhP 4
        xhum      TYPE abap_bool,
        xext_int  TYPE abap_bool,      "EHP 606 CFB
        no_predoc TYPE abap_bool,      "If 'X', predoc save disabled
        max_zeile TYPE mblpo,          "Maximum number in the button
        max_tabix TYPE sytabix,        "Number of lines in model
        lines     TYPE sytabix,        "Number of lines on screen
        allowed_refdoc TYPE refdoc,    "Currently allowed refdoc
        allowed_predoc TYPE abap_bool,
      END OF ty_s_status,
*     Current set of control data of the kernel.
      BEGIN OF ty_s_control,
        action            TYPE goaction,
        refdoc            TYPE refdoc,
        vgart             TYPE vgart,
        rw_vorgn          TYPE glvor,      "431091: for COBL
        new_line_mode     TYPE char1,  "P = Positions, C = Container
        cancel_mode       TYPE abap_bool,  "future development
        return_mode       TYPE abap_bool,  "future development
      END OF ty_s_control,
*     Current default values for unfilled data
      BEGIN OF ty_s_defaults,
        werks             TYPE goitem-werks,
        lgort             TYPE goitem-lgort,
        bwart             TYPE goitem-bwart,
        bwartx            TYPE abap_bool,
        sobkz             TYPE goitem-sobkz,
        insmk             TYPE goitem-insmk,
        take_it_all       TYPE abap_bool,
        propose_all_items TYPE abap_bool,
        xsaut             TYPE abap_bool,
        xauto_lines       TYPE abap_bool,
        xbom              TYPE abap_bool,
        tbfkz             TYPE lvs_tbfkz,
        bsskz             TYPE lvs_bsskz,
        wever             TYPE wever,
        xkto              TYPE abap_bool,
      END OF ty_s_defaults,
*     Data structure to exchange data about reference documents
      BEGIN OF ty_s_refdockey,
        po_number          TYPE ebeln,
        po_item            TYPE ebelp,
        po_werks           TYPE werks_d,
        mat_doc            TYPE mblnr,
        doc_year           TYPE mjahr,
        delivery_note      TYPE lfsnr1,
        inbound_delivery   TYPE vbeln_vl,
        outbound_delivery  TYPE vbeln_vl,
        shipping_unit      TYPE xvsel,
        transport          TYPE tknum,
        transportident     TYPE traid,
        transport_means    TYPE traty,
        guid               TYPE guid_22,
        refid              TYPE refid_d,
        order_number       TYPE aufnr,
        order_item         TYPE co_posnr,
        order_operation    TYPE vornr,
        reservation_number TYPE rsnum,
        reservation_item   TYPE rspos,
        reservation_type   TYPE rsart,
      END OF ty_s_refdockey,
*     Filled by reading reservations
      ty_s_resheader  TYPE rkpf,
      ty_t_resheader  TYPE STANDARD TABLE OF ty_s_resheader,
      ty_s_resitem    TYPE resb,
      ty_t_resitem    TYPE STANDARD TABLE OF ty_s_resitem,
      ty_t_goitem     TYPE STANDARD TABLE OF goitem,
      ty_s_gofreight  TYPE gofreight,
      ty_t_gofreight  TYPE STANDARD TABLE OF gofreight.
ENHANCEMENT-POINT lcl_migo_kernel_01 SPOTS es_saplmigo STATIC.
    "$$
    "$$
    "$$
*     Product quantities: Save fields before unit conversion
    TYPES:
     BEGIN OF ty_s_unit_conversion,
       menge TYPE menge_d,
       umren TYPE umren,
       umrez TYPE umrez,
     END   OF ty_s_unit_conversion,
*     Serial number with SELECTED-flag
     BEGIN OF ty_s_goserial,
       selected TYPE xfeld,
       serialno TYPE gernr,
       uii      TYPE uii_char72,              "EHP603 IUID
       subrk    TYPE xfeld,                   "EHP604 TT 2007.12.21
     END OF ty_s_goserial,
     ty_t_goserial  TYPE STANDARD TABLE OF ty_s_goserial WITH
                                              NON-UNIQUE DEFAULT KEY,
*     Brazil: export XMSEG after simulate -> Values needed
     ty_t_xmseg      TYPE STANDARD TABLE OF mseg,
*     Output determination
     BEGIN OF ty_s_nastkey,
            mblnr TYPE mblnr,
            mjahr TYPE mjahr,
            zeile TYPE mblpo,
     END OF ty_s_nastkey,
     ty_t_nastkey TYPE HASHED TABLE OF ty_s_nastkey
                  WITH UNIQUE KEY mblnr mjahr zeile,
*     Transfer of EMSEG from kernel to archiving
     ty_s_emseg      TYPE emseg,
     ty_t_emseg      TYPE STANDARD TABLE OF ty_s_emseg,
*     Generic article
     ty_t_var_goitem TYPE STANDARD TABLE OF var_goitem,
     ty_s_var_goitem TYPE var_goitem,
     ty_t_mtrx_vart  TYPE TABLE OF mtrx_vart,
     ty_t_mtrx_werte TYPE TABLE OF mtrx_werte,
     ty_t_mtrx_msel  TYPE TABLE OF mtrx_msel,
     ty_t_mtrx_char  TYPE TABLE OF mtrx_char,
     ty_t_mtrx_vali  TYPE TABLE OF mtrx_vali,
*     Generic article and webre
     BEGIN OF ty_s_sawe,
            ebeln TYPE ebeln,
            uebpo TYPE uebpo,
            lfbnr TYPE lfbnr,
            wesbs TYPE wesbs,
            bpwes TYPE bpwes,
            wemng TYPE wemng,
            bpwem TYPE bpwem,
            wewrt TYPE wewrt,
            wewwr TYPE wewwr,
            remng TYPE remng,
            bprem TYPE bprem,
            rewrt TYPE rewrt,
            rewwr TYPE rewwr,
            arewr TYPE arewr,
            areww TYPE areww,
     END OF ty_s_sawe,
     ty_t_sawe TYPE STANDARD TABLE OF ty_s_sawe
                     WITH DEFAULT KEY.
*---------------------------------------------end of public types------*
* Public data
*----------------------------------------------------------------------*
    DATA:
      s_action          TYPE ty_s_action              READ-ONLY,
      s_status          TYPE ty_s_status              READ-ONLY,
      s_control         TYPE ty_s_control             READ-ONLY,
      s_defaults        TYPE ty_s_defaults            READ-ONLY.

    CONSTANTS:
*    Fixed values for the field S_ACTION-REFDOCTYPE
     c_refdoctype_po          TYPE ty_refdoctype VALUE 'PO ',
     c_refdoctype_matdoc      TYPE ty_refdoctype VALUE 'MAT',
     c_refdoctype_order       TYPE ty_refdoctype VALUE 'ORD',
     c_refdoctype_reservation TYPE ty_refdoctype VALUE 'RES',
     c_refdoctype_none        TYPE ty_refdoctype VALUE '   '.

*---------------------------------------------end of public data ------*
* Public methods
*----------------------------------------------------------------------*

ENHANCEMENT-POINT lmigoke1_03 SPOTS es_saplmigo STATIC.
    METHODS:

*----------------------------------------------------------------------

*     ATP Check during batch split
         availability_check
           IMPORTING ls_goitem          TYPE goitem
                     l_transdet         TYPE c
           EXPORTING lt_availability    TYPE tbl_atpcs      "703419
                     e_shortage_plant   TYPE c              "703419
           CHANGING  ls_cdcom           TYPE cdcom,
*----------------------------------------------------------------------*

* note 703419 start
* ATP Check at batch/stock determination
         availability_struc_fill
           IMPORTING is_goitem           TYPE goitem
                     is_resitem          TYPE resb
                     i_transdet          TYPE c
                     i_batch_det         TYPE c
                     i_item              TYPE migo_global_counter
                     i_matnr             TYPE goitem-matnr
                     i_werks             TYPE goitem-werks
                     i_lgort             TYPE goitem-lgort
                     i_charg             TYPE goitem-charg
                     i_sobkz             TYPE goitem-sobkz
                     i_lief              TYPE goitem-emlif
                     i_prreg             TYPE cdcom-prreg
           EXPORTING es_avail_curr_line  TYPE atpcs
                     es_avail_plant      TYPE atpcs
           CHANGING  ct_avail_prev_lines TYPE tbl_atpcs,

         availability_plant_check
           IMPORTING is_goitem           TYPE goitem
                     is_avail_curr_line  TYPE atpcs
                     is_avail_plant      TYPE atpcs
                     it_avail_prev_lines TYPE tbl_atpcs
                     i_kzvbp             TYPE kzvbp
           EXPORTING e_shortage_plant    TYPE c,

* note 703419 end
* note 810352 start
      availability_gi_po
              IMPORTING i_po_numb TYPE ebeln
                        i_po_item TYPE ebelp
              EXPORTING e_bdter   TYPE bdter
              CHANGING  c_vmeng TYPE bestmng,
* note 810352 end
*----------------------------------------------------------------------*
*     Maintain batch data
         batch_maintain
           IMPORTING i_line TYPE sytabix,
*----------------------------------------------------------------------*
*     Break point for the tracer (do not remove)
         break_point,
*----------------------------------------------------------------------*
*     Change all items in PT_GOITEM after all line_modify calls
         change_all_items,
*----------------------------------------------------------------------*
*     Cross Docking
         cd_lgort_distribution_check,
*----------------------------------------------------------------------*
*     Cross Docking
         cd_lgort_distribution_get
           CHANGING cs_goitem TYPE goitem,
*----------------------------------------------------------------------*
*     Constructor
         constructor,
*----------------------------------------------------------------------*
*     Defaults: Set the current default values in S_DEFAULTS
         defaults_set
           IMPORTING
             is_defaults        TYPE ty_s_defaults,
*----------------------------------------------------------------------*
*     Defaults operation
         defaults_merge
           CHANGING cs_goitem TYPE goitem,
*----------------------------------------------------------------------*
*     Document operations
         document_post
           EXPORTING
             e_ok TYPE abap_bool,
*----------------------------------------------------------------------*
         document_check
           IMPORTING
             i_enqueue     TYPE abap_bool OPTIONAL
             i_sim_values  TYPE abap_bool OPTIONAL
             i_error_only  TYPE abap_bool OPTIONAL
           EXPORTING
             e_ok     TYPE abap_bool
             et_xmseg TYPE ty_t_xmseg,
*----------------------------------------------------------------------*
* edit variants of generic article
         ga_variants_edit
           IMPORTING i_line          TYPE sytabix
                     is_goitem       TYPE goitem OPTIONAL
                     i_new_variant   TYPE c OPTIONAL,
*----------------------------------------------------------------------*
* add new variants to an generic article
         ga_variants_create
           IMPORTING is_goitem_top TYPE goitem
                     it_var_msel   TYPE ty_t_mtrx_msel
                     it_var_char   TYPE ty_t_mtrx_char
                     it_var_vali   TYPE ty_t_mtrx_vali
           CHANGING  ct_var_values TYPE ty_t_mtrx_werte
                     ct_var_vart   TYPE ty_t_mtrx_vart,
*----------------------------------------------------------------------*
*     Change fields like take_it and quantity of a generic article.
         ga_line_modify
           IMPORTING is_old_goitem TYPE goitem OPTIONAL
                     is_new_goitem TYPE goitem,
*----------------------------------------------------------------------*
*     copy data from screen Variants into pt_goitem
         ga_variants_pai
           IMPORTING i_line  TYPE sytabix,
*----------------------------------------------------------------------*
* Buttons 'OK_GA_CHANGE_VARIANT' and 'OK_GA_ADD_VARIANT'
         ga_buttons_fieldselection
           IMPORTING i_line  TYPE sytabix,
*----------------------------------------------------------------------*
*     get parent item for component item (subcontracting)
         get_parent_item
           IMPORTING
             i_global_counter  TYPE migo_global_counter
           EXPORTING
             e_goitem          TYPE goitem,
*----------------------------------------------------------------------*
*     Centralized document loader
         ref_document_read
           IMPORTING
             i_refdoc TYPE refdoc
             is_key   TYPE ty_s_refdockey
           EXPORTING
             e_nothing_found TYPE abap_bool,
*----------------------------------------------------------------------*
*     Header operations
         header_get
           EXPORTING e_gohead TYPE gohead,
*----------------------------------------------------------------------*
         header_modify
           IMPORTING i_gohead TYPE gohead,
*----------------------------------------------------------------------*
*     Line operations
*       For the meaning of the parameters please see the implementation
         line_get
           IMPORTING i_line              TYPE sytabix OPTIONAL
                     value(i_tabix)      TYPE sytabix OPTIONAL
                     i_dependent_tables  TYPE abap_bool DEFAULT abap_false
           EXPORTING et_goserial         TYPE ty_t_goserial
                     et_gofreight        TYPE ty_t_gofreight
                     es_goitem           TYPE goitem,
*----------------------------------------------------------------------*
         line_modify
           IMPORTING i_line             TYPE sytabix OPTIONAL
                     value(i_tabix)     TYPE sytabix OPTIONAL
                     i_insert           TYPE abap_bool DEFAULT abap_false
                     i_force_change     TYPE abap_bool DEFAULT abap_false
                     i_authority_check  TYPE abap_bool DEFAULT abap_true
                     i_status_delayed   TYPE abap_bool DEFAULT abap_false
                     i_dependent_tables TYPE abap_bool DEFAULT abap_false
                     it_goserial        TYPE ty_t_goserial  OPTIONAL
                     it_gofreight       TYPE ty_t_gofreight OPTIONAL
           CHANGING  cs_goitem          TYPE goitem,
*----------------------------------------------------------------------*
         line_modify_badi
            CHANGING  cs_goitem         TYPE goitem,
*----------------------------------------------------------------------*
         line_modify_badi2
            CHANGING cs_goitem          TYPE goitem,
*----------------------------------------------------------------------*
         line_badi_special_fields
           IMPORTING is_goitem_badi     TYPE goitem
           CHANGING  c_change           TYPE abap_bool
                     cs_goitem          TYPE goitem,
*----------------------------------------------------------------------*
         line_check
           IMPORTING is_old_goitem    TYPE goitem
           CHANGING  cs_goitem        TYPE goitem,
*----------------------------------------------------------------------*
         line_check_transfer
           IMPORTING is_old_goitem      TYPE goitem
                     is_unit_conversion TYPE ty_s_unit_conversion
           CHANGING  cs_goitem          TYPE goitem,
*----------------------------------------------------------------------*
         line_check_with_global_counter
           IMPORTING is_old_goitem    TYPE goitem
           CHANGING  cs_goitem        TYPE goitem,
*----------------------------------------------------------------------*
         line_expand_collapse
           IMPORTING i_line           TYPE sytabix
                     i_okcode         TYPE syucomm OPTIONAL,
*----------------------------------------------------------------------*
         line_delete
           IMPORTING i_line         TYPE sytabix OPTIONAL
                     value(i_tabix) TYPE sytabix OPTIONAL
                     i_nestlevel    TYPE sytabix OPTIONAL
                     i_no_messages  TYPE abap_bool DEFAULT abap_false,
*----------------------------------------------------------------------*
         line_mapping
           IMPORTING i_line           TYPE sytabix             OPTIONAL
                     value(i_tabix)   TYPE sytabix             OPTIONAL
                     i_global_counter TYPE migo_global_counter OPTIONAL
                     i_zeile          TYPE mblpo               OPTIONAL
           EXPORTING e_line           TYPE sytabix
                     e_tabix          TYPE sytabix
                     e_global_counter TYPE migo_global_counter
                     e_zeile          TYPE mblpo
           EXCEPTIONS not_found.
ENHANCEMENT-POINT lmigoke1_04 SPOTS es_saplmigo STATIC.
*----------------------------------------------------------------------*
    METHODS:
*     Mode settings
          mode_get RETURNING value(rs_control) TYPE ty_s_control,
          mode_set IMPORTING is_control        TYPE ty_s_control
                             i_keep_vgart      TYPE    abap_bool
                                               DEFAULT abap_false
                             i_unconditional   TYPE    abap_bool
                                               DEFAULT abap_false
                             i_transfer        TYPE    abap_bool
                                               DEFAULT abap_false,
*----------------------------------------------------------------------*
*     Search SAP name and complete name from a string
          name_search
            IMPORTING i_string  TYPE so_adrnam
            EXPORTING e_sapname TYPE usnam
                      e_adrname TYPE so_adrnam
            EXCEPTIONS not_found,
*----------------------------------------------------------------------*
*     Propose number of GR slips
          number_slips_propose
            IMPORTING i_erfmg TYPE mb_erfmg
                      i_wesch TYPE wesch
            EXPORTING e_weanz TYPE weanz,
*----------------------------------------------------------------------*
*     Output determination
          output_determination,
          output_show
             IMPORTING i_mblnr    TYPE mblnr
                       i_mjahr    TYPE mjahr
                       i_zeile    TYPE mblpo,
*----------------------------------------------------------------------*
*     Predocument handling
          predocument_save
            IMPORTING i_guid  TYPE guid_22,
          predocument_load
            IMPORTING i_guid TYPE guid_22,
*----------------------------------------------------------------------*
*     Reservations
          reservation_header_receive
            IMPORTING is_resheader   TYPE ty_s_resheader,
*----------------------------------------------------------------------*
*     Reservations
          reservation_items_receive
            IMPORTING is_resitem     TYPE ty_s_resitem,
*----------------------------------------------------------------------*
*     Reset the kernel
          reset,
*----------------------------------------------------------------------*
*     serialnumbers
          serialnumbers_select_all
             IMPORTING i_line TYPE sytabix,
          serialnumbers_deselect_all
             IMPORTING i_line TYPE sytabix,
          serialnumbers_delete_sel
             IMPORTING i_line TYPE sytabix,
*----------------------------------------------------------------------*
*     Shipping_construction_maintain
          shipping_construction_maintain
            IMPORTING i_line TYPE sytabix,
**----------------------------------------------------------------------*
*     Final settings: PT_GOITEM --> S_STATUS.
          status_derive,
*----------------------------------------------------------------------*
*     Table operations
          table_sort
            IMPORTING i_column_name TYPE c
                      i_sort_up     TYPE abap_bool,
*----------------------------------------------------------------------*
          table_delete_not_ok,
*----------------------------------------------------------------------*
          umsok_get
            IMPORTING i_error_type TYPE c DEFAULT ' '
            CHANGING  c_sobkz      TYPE sobkz
                      cs_goitem    TYPE goitem,
*----------------------------------------------------------------------*
*     Value Added Services
          vas_line_modify
            IMPORTING is_old_goitem TYPE goitem
                      is_new_goitem TYPE goitem,
*----------------------------------------------------------------------*
*     Value Added Services
          vas_relevance_check
            CHANGING  cs_goitem    TYPE goitem,
*----------------------------------------------------------------------*
*     Tied empties
         vg_line_modify
           IMPORTING is_old_goitem TYPE goitem OPTIONAL
           CHANGING  cs_goitem     TYPE goitem,
*----------------------------------------------------------------------*
*     get items entered in MM document                 "n1397313
         get_pt_goitem                                 "n1397313
           EXPORTING e_pt_goitem TYPE ty_t_goitem.     "n1397313
*---------------------------------------------end of public methods----*
* PRIVATE SECTION
*----------------------------------------------------------------------*
  PRIVATE SECTION.
*----------------------------------------------------------------------*
* Private types
*----------------------------------------------------------------------*
    TYPES:
*     General
      ty_s_goitem     TYPE goitem,
*     Interface to MB_CREATE_GOODS_MOVEMENT, MB_CANCEL_GOODS_MOVEMENT
      ty_cancel       TYPE mblpo,
      ty_t_cancel     TYPE STANDARD TABLE OF ty_cancel,
      ty_s_imseg      TYPE imseg,
      ty_t_imseg      TYPE STANDARD TABLE OF ty_s_imseg,
      ty_s_imkpf      TYPE imkpf,
      ty_s_emkpf      TYPE emkpf,
* Preparation for postings with serialnumbers
*      ty_s_goserial_post TYPE bapi2017_gm_serialnumber,   "EHP603 IUID
      BEGIN OF ty_s_goserial_post.                         "EHP603 IUID
        INCLUDE TYPE bapi2017_gm_serialnumber.
TYPES:  subrk   TYPE xfeld,                                "EhP604 A&D
      END OF ty_s_goserial_post,

      ty_t_goserial_post TYPE STANDARD TABLE OF ty_s_goserial_post,
* types to handle serial number process
      BEGIN OF ty_s_goserial_kernel,
          global_counter TYPE migo_global_counter,
          t_goserial TYPE ty_t_goserial,
      END OF ty_s_goserial_kernel,
* Filled by reading material document
      ty_s_mseg       TYPE mseg,
* Filled by reading purchase orders
      ty_s_poitem     TYPE ebefu,
      ty_s_po_acc     TYPE accounting,                        "MAA-DEV
      ty_s_st_poitem  TYPE bbefu,
      ty_s_mdgi       TYPE mdgi,                              "Outsourced Manufacturing EhP 4
      ty_t_poitem     TYPE STANDARD TABLE OF ty_s_poitem,
      ty_t_po_acc     TYPE STANDARD TABLE OF ty_s_po_acc,     "MAA-DEV
      ty_t_st_poitem  TYPE STANDARD TABLE OF ty_s_st_poitem,
      ty_t_mdgi       TYPE STANDARD TABLE OF ty_s_mdgi,       "Outsourced Manufacturing EhP 4
      ty_s_pofreight  TYPE ekbnk,
      ty_t_pofreight  TYPE STANDARD TABLE OF ty_s_pofreight,
* Result of searching purchase orders
      ty_s_wueb       TYPE wueb,
      ty_t_wueb       TYPE STANDARD TABLE OF ty_s_wueb,
      ty_s_vepwe      TYPE vepwe,
      ty_t_vepwe      TYPE STANDARD TABLE OF ty_s_vepwe,
* Filled by reading orders
      ty_s_orditem    TYPE fbefu,
      ty_t_orditem    TYPE STANDARD TABLE OF ty_s_orditem,
* Prefetch material master
      ty_s_prefetch02 TYPE pre02,
      ty_t_prefetch02 TYPE STANDARD TABLE OF ty_s_prefetch02,
      ty_s_prefetch03 TYPE pre03,
      ty_t_prefetch03 TYPE STANDARD TABLE OF ty_s_prefetch03,
* Mapping table from internal line numbers to external line numbers
      BEGIN OF ty_s_line_mapping,
        line  TYPE sytabix,
        tabix TYPE sytabix,
      END OF ty_s_line_mapping,
* empties bom; <LG>
      BEGIN OF ty_s_slcomp,
          global_counter TYPE migo_global_counter,
          idnrk          TYPE idnrk,
          menge          TYPE kmpmg,
          meins          TYPE kmpme,
      END OF ty_s_slcomp,
      ty_t_slcomp      TYPE STANDARD TABLE OF ty_s_slcomp,
      ty_t_slcomp_hash TYPE HASHED   TABLE OF ty_s_slcomp
        WITH UNIQUE KEY global_counter idnrk,
* relevant fields of ebefu/bbefu for tied empties
      BEGIN OF ty_s_empties_poitem,
          ebeln TYPE ebefu-ebeln,
          ebelp TYPE ebefu-ebelp,
          lfbnr TYPE ebefu-lfbnr,
          uebpo TYPE ebefu-uebpo,
          bstme TYPE ebefu-bstme,
          upvor TYPE ebefu-upvor,
          uptyp TYPE ebefu-uptyp,
          elikz TYPE ebefu-elikz,
      END OF ty_s_empties_poitem,
* for changing elikz in all corresponding items
      BEGIN OF ty_s_change_po_elikz,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        migo_elikz TYPE migo_elikz,
      END OF ty_s_change_po_elikz,
      BEGIN OF ty_s_change_ord_elikz,
        pps_aufnr TYPE aufnr,
        pps_posnr TYPE co_posnr,
        migo_elikz TYPE migo_elikz,
      END OF ty_s_change_ord_elikz,
      BEGIN OF ty_s_change_res_kzear,
        rsnum TYPE rsnum,
        rspos TYPE rspos,
        rsart TYPE rsart,
        kzear TYPE kzear,
      END OF ty_s_change_res_kzear,
* batch data that can be changed(!) by IM
      BEGIN OF ty_s_batch_relevant_data,
        licha    TYPE lichn,
        hsdat    TYPE hsdat,
        vfdat    TYPE vfdat,
* fields LIFNR, ZUSTD and BWTAR intentionally NOT included!
      END OF ty_s_batch_relevant_data,
* similar structure for transfer postings
* keep identical to ty_s_batch_relevant_data!
      BEGIN OF ty_s_batch_relevant_trans_data,
        vendorbatch_from_refdoc    TYPE lichn,
        umhsdat  TYPE hsdat,
        umvfdat  TYPE vfdat,
      END OF ty_s_batch_relevant_trans_data,
* change structure for product quantity unit
      BEGIN OF ty_s_change_batch,
        charg TYPE charg_d,
        matnr TYPE matnr,
        werks TYPE werks_d,
      END   OF ty_s_change_batch,
* Classification structure
      BEGIN OF ty_s_classification,
         charg   TYPE charg_d,
         bwtar   TYPE bwtar_d,
         hsdat   TYPE hsdat,
         vfdat   TYPE vfdat,
         prfrq   TYPE prfrq,
         xkcfc   TYPE xkcfc,
         xpoitem TYPE migo_poitem,
         vendorbatch_from_refdoc TYPE lichn.
    INCLUDE TYPE bncom.
    TYPES: END OF ty_s_classification,
* Classification structure (reference fields)
    BEGIN OF ty_s_ref_batch,
      ref_matnr TYPE matnr,
      ref_charg TYPE charg_d,
      ref_werks TYPE werks_d,
    END OF ty_s_ref_batch,
* Export structure for batch_maintain_dark
     BEGIN OF ty_s_batch_dark,
       charg   TYPE charg_d,
       licha   TYPE lichn,
       bwtar   TYPE bwtar_d,
       hsdat   TYPE hsdat,
       vfdat   TYPE vfdat,
       zustd   TYPE dzustd,
*      lifnr   TYPE lifnr,                                   "748683
       umcha   TYPE umcha,
       umbar   TYPE umbar,
       umhsdat TYPE umhsdat,
       umvfdat TYPE umvfdat,
       umzst   TYPE umzst,
     END   OF ty_s_batch_dark,
* Change structure for TAKE_IT indicator to ensure that
* changes are cascaded to all dependent lines (modulo exceptions
* for subcontracting)
      BEGIN OF ty_s_change_takeit,
        glc    TYPE migo_global_counter,
        takeit TYPE abap_bool,
      END OF ty_s_change_takeit,
* Change structure for fields of children according to the vaiue of the
* parent item, e.g. LGORT of a generic article and its variants
      BEGIN OF ty_s_change_children,
        glc       TYPE migo_global_counter,
        fieldname TYPE migo_fieldname,
      END OF ty_s_change_children,
* Conversion of storage location (buffer)
* Internal buffer for plant/text relation
      BEGIN OF ty_s_t001w,
        werks TYPE werks_d,
        name1 TYPE name1,
        nameg TYPE name1,
      END OF ty_s_t001w,
* Buffer for storage location conversion
      BEGIN OF ty_s_t001l,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        lgobe TYPE lgobe,
        lgobg TYPE lgobe,
      END OF ty_s_t001l,
* Buffer for plant/storage location changes
      BEGIN OF ty_s_pslbuffer,
        umwrk   TYPE umwrk,
        umname1 TYPE umname1,
        umlgo   TYPE umlgo,
        umlgobe TYPE umlgobe,
      END OF ty_s_pslbuffer.

*
* <LG>: copying data from full product to tied empty: defining 2 types:
* individual and optional structure
    INCLUDE lmigokee.
*----------------------------------------------------------------------*
* Private data
*----------------------------------------------------------------------*
    DATA:
* Items in process
      pt_goitem           TYPE STANDARD TABLE OF goitem
                               WITH KEY global_counter,
* Subcontracting
      pt_ekbe_sc          TYPE STANDARD TABLE OF ekbe_sc,       "Outsourced Manufacturing EhP 4
* Items of cross docking before changing by user
      pt_cd_mseg          TYPE STANDARD TABLE OF mseg,
* Freight suppliers
      pt_gofreight_kernel TYPE STANDARD TABLE OF gofreight,
* Serial numbers
      pt_goserial_kernel  TYPE HASHED   TABLE OF ty_s_goserial_kernel
                               WITH UNIQUE KEY global_counter,
* Serial numbers for post
      pt_goserial_post    TYPE ty_t_goserial_post,
* Header data for goods move.
      ps_gohead           TYPE gohead,
* Header data for output
      ps_mkpf_nast        TYPE mkpf,
* Item data
      pt_mseg_nast        TYPE HASHED TABLE OF mseg
                               WITH UNIQUE KEY mblnr mjahr zeile,
* Header data from PO
      ps_pohead           TYPE kbefu,
* General data
      ps_vendordata_a     TYPE lfa1,
* Reservation header received from ldb MMIMMKKPFRESB
      pt_reservation_header TYPE ty_t_resheader,
* Reservation items received from ldb MMIMMKKPFRESB
      pt_reservation_item TYPE ty_t_resitem,
* Currently assigned glob.cnt
      p_line_id           TYPE migo_global_counter,
* Father/Child
      pt_line_mapping     TYPE HASHED TABLE OF ty_s_line_mapping
                          WITH UNIQUE KEY line.

ENHANCEMENT-POINT lmigoke1_05 SPOTS es_saplmigo STATIC.
    DATA :
* Change tables for all items (in change_all)
          pt_change_po_elikz TYPE HASHED TABLE OF ty_s_change_po_elikz
                WITH UNIQUE KEY ebeln ebelp,
          pt_change_ord_elikz TYPE HASHED TABLE OF ty_s_change_ord_elikz
                WITH UNIQUE KEY pps_aufnr pps_posnr,
          pt_change_res_kzear TYPE HASHED TABLE OF ty_s_change_res_kzear
                WITH UNIQUE KEY rsnum rspos,
          pt_change_batch     TYPE HASHED TABLE OF ty_s_change_batch
                WITH UNIQUE KEY charg matnr werks,
          pt_change_batch_uom TYPE HASHED TABLE OF ty_s_change_batch
                WITH UNIQUE KEY charg matnr werks,
*     This table is NOT HASHED as it has another handling type
          pt_change_takeit TYPE SORTED TABLE OF ty_s_change_takeit
                WITH UNIQUE KEY glc,
          pt_change_children TYPE TABLE OF ty_s_change_children
                WITH NON-UNIQUE KEY glc,
* Conversion of storage location (buffer): note 608593
          pt_t001w TYPE TABLE OF ty_s_t001w,
          pt_t001l TYPE TABLE OF ty_s_t001l,
          p_t001w_initialized VALUE space,
          p_t001l_initialized VALUE space,
          ps_pslbuffer TYPE ty_s_pslbuffer.
ENHANCEMENT-POINT LMIGOKE1_06 SPOTS ES_SAPLMIGO STATIC.
    "$$

*------------------------------------------end of private data --------*
* Private methods
*----------------------------------------------------------------------*
    METHODS:
*----------------------------------------------------------------------*
*     Fill data for batch classification
      batch_class_structure_fill
        IMPORTING is_goitem          TYPE goitem
        EXPORTING es_classification  TYPE ty_s_classification
                  es_ref_batch       TYPE ty_s_ref_batch,
*----------------------------------------------------------------------*
*     Create batch (Call function module VB_CREATE_BATCH)
      batch_create
        IMPORTING is_mcha            type mcha
                  i_new_lgort        type lgort_d
                  is_bncom           type bncom
                  is_ref_batch       type ty_s_ref_batch
                  i_kzcla            type kzcla
                  i_xkcfc            type xkcfc
        EXPORTING es_mcha            type mcha,
*----------------------------------------------------------------------*
*     Get batch data from buffer
      batch_data_get
        IMPORTING is_mcha_buffer TYPE mcha
        CHANGING  cs_goitem      TYPE goitem,
*----------------------------------------------------------------------*
*     Get transfer batch data from buffer (-> UMCHA)
      batch_data_transfer_get
        IMPORTING is_mcha_buffer TYPE mcha
        CHANGING  cs_goitem      TYPE goitem,
*----------------------------------------------------------------------*
*     Create a batch without dialog for product uoms
      batch_maintain_dark
        IMPORTING  is_goitem     TYPE goitem
        EXPORTING  es_batch_dark TYPE ty_s_batch_dark,
*----------------------------------------------------------------------*
*     Update batch buffer, fill screen fields with batch data
      batch_data_update
        IMPORTING
          is_old_goitem TYPE goitem
        CHANGING
          cs_goitem     TYPE goitem,
*----------------------------------------------------------------------*
      batch_data_transfer_update
        IMPORTING
          is_old_goitem TYPE goitem
        CHANGING
          cs_goitem     TYPE goitem,
*----------------------------------------------------------------------*
*     empties processing: get bom; <LG>
      bom_empties_read
        IMPORTING is_goitem_full_product  TYPE goitem
        EXPORTING et_slcomp               TYPE ty_t_slcomp
        EXCEPTIONS not_found,
*----------------------------------------------------------------------*
*     changes lgort for all variants with same storage location
      change_children,
*----------------------------------------------------------------------*
*     changes lgort for all variants with same storage location
      change_children_process
        IMPORTING
          i_glc       TYPE migo_global_counter
          i_fieldname TYPE migo_fieldname,
*----------------------------------------------------------------------*
*     change_quantity_all_items for product units
      change_quantity_all_items,
*----------------------------------------------------------------------*
*     change_quantity_later for product units
      change_quantity_later
         IMPORTING
            is_change_batch TYPE ty_s_change_batch,
*----------------------------------------------------------------------*
*     changes batch data for all items with same batch
      change_batch_all_items,
*----------------------------------------------------------------------*
*     changes batch data for all items with same batch
      change_batch_later
        IMPORTING
          is_batch_key         TYPE ty_s_change_batch,
*----------------------------------------------------------------------*
*     changes elikz for all items with the same keys.
      change_elikz_all_items,
*----------------------------------------------------------------------*
*     changes elikz for all items with the same keys.
      change_elikz_later
        IMPORTING
           is_change_po_elikz  TYPE ty_s_change_po_elikz OPTIONAL
           is_change_ord_elikz TYPE ty_s_change_ord_elikz OPTIONAL
           is_change_res_kzear TYPE ty_s_change_res_kzear OPTIONAL,
*----------------------------------------------------------------------*
*     Changes for the TAKEIT-indicator
      change_takeit_later
        IMPORTING
          i_glc    TYPE migo_global_counter
          i_takeit TYPE abap_bool,
*----------------------------------------------------------------------*
      change_takeit_all_items,
*----------------------------------------------------------------------*
      change_takeit_process
        IMPORTING
          i_glc    TYPE migo_global_counter
          i_takeit TYPE abap_bool,
*----------------------------------------------------------------------*
*     determines whether the classification of the batch can be modified
      check_batch_posted
        IMPORTING
           i_matnr             TYPE goitem-matnr
           i_werks             TYPE goitem-werks
           i_charg             TYPE goitem-charg
        EXPORTING
           e_date_last_gr      TYPE mcha-lwedt,
*----------------------------------------------------------------------*
*     Read a confirmation via ME_CONFIRMATION_SEARCH_GR
      confirmation_get
        IMPORTING i_vbeln  TYPE vbeln_vl
                  i_vbelp  TYPE posnr_vl OPTIONAL
                  is_vepwe TYPE vepwe OPTIONAL,
*----------------------------------------------------------------------*
*     Returns a complete line enriched with the current defaults
      default_line_get
        RETURNING value(rs_goitem) TYPE goitem,
*----------------------------------------------------------------------*
*     Delivery note (R03)
      delivery_note_read
        IMPORTING i_delivery_note TYPE lfsnr1,
*----------------------------------------------------------------------*
*     Determine whether documentary batch is used for this
*     material/ plant/ process
      doc_batch_get_control_for_item
        IMPORTING
          i_goitem            TYPE goitem
        EXPORTING
          e_docubatch_control TYPE goitem-docubatch_control,
*     read documentary batches for display material document
      doc_batch_get_data_for_matdoc
        IMPORTING
          i_goitem            TYPE goitem
        EXPORTING
          e_docubatch_control TYPE goitem-docubatch_control   "1302682
          e_docubatch_charg   TYPE goitem-docubatch_charg     "1302682
          e_mult_entries TYPE goitem-docubatch_mult_entries,  "1302682
*     call function modules from VBDOCUBATCH_DM to post doc. batch
      doc_batch_post,
*     check for hidden components with documentary batches active
      doc_batch_check_components
        IMPORTING
          is_goitem           TYPE goitem,
*----------------------------------------------------------------------*
*     Document post / check
      document_operation
        IMPORTING
          i_simulate   TYPE abap_bool
          i_sim_values TYPE abap_bool OPTIONAL
          i_error_only TYPE abap_bool OPTIONAL
        EXPORTING
          e_ok         TYPE abap_bool
          et_xmseg     TYPE ty_t_xmseg,
*----------------------------------------------------------------------*
*     Foreign trade
      ftrade_determine_item
        IMPORTING
          is_goitem       TYPE goitem
        EXPORTING
          e_process       TYPE abap_bool,
*----------------------------------------------------------------------*
      ftrade_refresh_all
        IMPORTING
          i_exnum          TYPE gohead-exnum
          i_home_country   TYPE gohead-land1,
*----------------------------------------------------------------------*
      ftrade_item_refresh
        IMPORTING
          i_exnum          TYPE gohead-exnum
          i_global_counter TYPE migo_global_counter
          i_home_country   TYPE goitem-land1,
*----------------------------------------------------------------------*
      ftrade_copy_from_po
        IMPORTING
          is_goitem       TYPE goitem,
*----------------------------------------------------------------------*
* <lg> : copy certain data from full product to tied empty
      full_product_data_copy
        IMPORTING is_goitem_full  TYPE goitem
        CHANGING  cs_goitem_empty TYPE goitem,
*----------------------------------------------------------------------*
*     Determine whether qties entry in base and product UOM is allowed
      get_xparallel
        IMPORTING
          i_matnr         TYPE goitem-matnr
          i_werks         TYPE goitem-werks
          i_charg         TYPE goitem-charg
          i_kzcla         TYPE goitem-kzcla
        EXPORTING
          e_xparallel     TYPE goitem-xparallel.
*----------------------------------------------------------------------*
ENHANCEMENT-POINT lmigoke1_01 SPOTS es_saplmigo STATIC.
    METHODS:

*     Goods movement calls
          goods_cancel_fill
            EXPORTING
              et_cancel TYPE ty_t_cancel,
*----------------------------------------------------------------------*
          goods_movement_error_handling
            IMPORTING
              is_emkpf   TYPE ty_s_emkpf
              it_emseg   TYPE ty_t_emseg,
*----------------------------------------------------------------------*
          goods_movement_fill
            EXPORTING
              et_imseg   TYPE ty_t_imseg
              es_imkpf   TYPE ty_s_imkpf,
*----------------------------------------------------------------------*
          goods_movement_post
            EXPORTING
              es_emkpf_old TYPE ty_s_emkpf,"_old => EMKP from MB_CREATE
*----------------------------------------------------------------------*
*     modify parent_id and line_depth for BOM-positions
          goods_movement_bom_handling
              CHANGING ct_imseg TYPE ty_t_imseg,
*----------------------------------------------------------------------*
*     memorize empties bom of a full product; <LG>
          goods_movement_memorize_fp
              IMPORTING is_goitem_full_product  TYPE ty_s_goitem
              CHANGING  ct_slcomp               TYPE ty_t_slcomp_hash,
*----------------------------------------------------------------------*
*     adjust empty according to the corresponding full product
          goods_movement_adjust_tied_ety
              IMPORTING  it_imseg                TYPE ty_t_imseg
              EXPORTING  es_goitem_full          TYPE ty_s_goitem
              CHANGING   ct_slcomp               TYPE ty_t_slcomp_hash
                         cs_goitem_empty         TYPE ty_s_goitem
                         i_refix                 TYPE sytabix
              EXCEPTIONS fp_not_found
                         bom_not_found,
*----------------------------------------------------------------------*
*     get bom factor of empties material
          goods_mvmt_empty_factor_read
              IMPORTING  is_goitem_empty        TYPE goitem
                         is_goitem_full         TYPE goitem
              EXPORTING  es_slcomp              TYPE ty_s_slcomp
              CHANGING   ct_slcomp              TYPE ty_t_slcomp_hash
              EXCEPTIONS not_found,
*----------------------------------------------------------------------*
*     mix in data of full product into empty material
          goods_mvmt_full_data_mix_in
              IMPORTING  is_goitem_full         TYPE goitem
                         is_slcomp              TYPE ty_s_slcomp
                         it_imseg               TYPE ty_t_imseg
              CHANGING   cs_goitem_empty        TYPE goitem
                         i_refix                TYPE sytabix,
*----------------------------------------------------------------------*
*     process error output into log and skip all the empties bom
          goods_movement_error_empties
              IMPORTING  i_subrc                TYPE sysubrc
                         is_goitem_empty        TYPE ty_s_goitem
                         is_goitem_full_head    TYPE ty_s_goitem,
*----------------------------------------------------------------------*
*     checks whether there is an empties bom for every full product
          goods_mvmt_empties_boms_check,
*----------------------------------------------------------------------*
*     Header operations
          header_defaults_set,
*     Inbound delivery (R04)
          inbound_delivery_read
              IMPORTING  i_inbound_delivery TYPE vbeln_vl
                         i_shipping_unit    TYPE xvsel OPTIONAL,
*----------------------------------------------------------------------*
*     Authority checks
          line_add_authority_check
              IMPORTING
                is_goitem   TYPE goitem
              RETURNING
                value(r_ok) TYPE abap_bool,
*----------------------------------------------------------------------*
*     Collapse a line including all subitems recursively
          line_collapse
              IMPORTING value(i_tabix) TYPE sytabix,
*     Expand a line including all subitems recursively
          line_expand
              IMPORTING value(i_tabix) TYPE sytabix
                       i_okcode        TYPE syucomm     OPTIONAL,
*----------------------------------------------------------------------*
          line_check_automatic_lines
              IMPORTING
                is_old_goitem TYPE goitem
              CHANGING
                cs_goitem     TYPE goitem,
*----------------------------------------------------------------------*
          line_expand_subcontracting
              IMPORTING value(i_tabix) TYPE sytabix,
*----------------------------------------------------------------------*
*     explode empties bom; <LG>
          line_expand_full_product
              IMPORTING value(i_tabix) TYPE sytabix
                        i_invisible    TYPE migo_line_invisible,
*----------------------------------------------------------------------*
*     Expand lines of a bill of material
          line_expand_bom
              IMPORTING value(i_tabix) TYPE sytabix,
*----------------------------------------------------------------------*
*     Expand lines of a structured article
          line_expand_structured_article
              IMPORTING value(i_tabix) TYPE sytabix,
*----------------------------------------------------------------------*
*     Material document from AIS archive (internal)         "n1306620
          material_doc_from_archive                         "n1306620
              IMPORTING i_mat_doc         TYPE  mblnr       "n1306620
                        i_doc_year        TYPE  mjahr       "n1306620
              CHANGING  cs_mkpf           TYPE  mkpf        "n1306620
                        ct_mseg           TYPE  ty_t_mseg   "n1306620
                        cv_flag_archive   TYPE  abap_bool,  "n1306620
*----------------------------------------------------------------------*
*     Material document (internal)
          materialdocument_get
              IMPORTING i_mat_doc         TYPE mblnr
              CHANGING  c_doc_year        TYPE mjahr,
*----------------------------------------------------------------------*
*     Material document (R02)
          materialdocument_read
              IMPORTING i_mat_doc         TYPE mblnr
              CHANGING  c_doc_year        TYPE mjahr,
*----------------------------------------------------------------------*
*     Material master
          material_prefetch_read
              IMPORTING
                it_prefetch02 TYPE ty_t_prefetch02     OPTIONAL
                it_prefetch03 TYPE ty_t_prefetch03     OPTIONAL,
*----------------------------------------------------------------------*
          material_read
              IMPORTING i_transfer TYPE abap_bool OPTIONAL
              CHANGING  cs_goitem  TYPE goitem,
*----------------------------------------------------------------------*
*     help method to fill UM-Fields (UMMAT/UMWRK/WMLGO/UMCHA/UMBAR)
          mm_sloc_convert
              CHANGING c_plant     TYPE umwrk
                       c_planttext TYPE umname1
                       c_sloc      TYPE umlgo
                       c_sloctext  TYPE umlgobe,
*----------------------------------------------------------------------*
*     subsequent adjustment
          mvt_move_component_get
              IMPORTING i_sc_adjust TYPE migo_sc_adjust
                        i_shkzg     TYPE shkzg
              CHANGING  c_move      TYPE bwart,
          mvt_sc_adjust_component_get
              IMPORTING i_move      TYPE bwart
              CHANGING  c_sc_adjust TYPE migo_sc_adjust,
*----------------------------------------------------------------------*
*     Send message with new document
          new_document
              IMPORTING
                i_refdoc         TYPE refdoc
                is_key           TYPE ty_s_refdockey
                i_from_posting   TYPE abap_bool DEFAULT abap_false,
*----------------------------------------------------------------------*
*     Insert a new position for WUEB entries without PO
          new_position_from_wueb
              IMPORTING
                is_wueb    TYPE wueb
                is_vepwe   TYPE vepwe         OPTIONAL
                i_delivery TYPE abap_bool     OPTIONAL,
*----------------------------------------------------------------------*
*     Official number South America
          off_number_default
              IMPORTING is_goitem TYPE goitem
              RETURNING value(r_xblnr) TYPE gohead-xblnr,
*----------------------------------------------------------------------*
*     Methods regarding orders
          order_fill_data
              IMPORTING it_orditem   TYPE ty_t_orditem,
*----------------------------------------------------------------------*
          order_fill_goitem
              IMPORTING
                is_orditem   TYPE fbefu
                is_goitem    TYPE goitem
              EXPORTING
                es_goitem    TYPE goitem,
*----------------------------------------------------------------------*
          order_fill_matdoc
              IMPORTING  is_mseg      TYPE ty_s_mseg
                         is_goitem    TYPE ty_s_goitem
              EXPORTING  es_goitem    TYPE ty_s_goitem
              EXCEPTIONS no_take_over,
*----------------------------------------------------------------------*
*     Order (internally used)
          order_get
              IMPORTING i_order_number   TYPE aufnr
                        i_order_item     TYPE co_posnr   OPTIONAL,
*----------------------------------------------------------------------*
          order_read
              IMPORTING i_order_number  TYPE aufnr
                        i_order_item    TYPE co_posnr    OPTIONAL,
*----------------------------------------------------------------------*
          order_read_data
              IMPORTING i_order_number   TYPE aufnr
                        i_order_item     TYPE co_posnr   OPTIONAL
                        is_mseg          TYPE ty_s_mseg  OPTIONAL
              EXPORTING et_orditem       TYPE ty_t_orditem,
*----------------------------------------------------------------------*
          order_reservation_read
              IMPORTING i_order_number    TYPE aufnr
                        i_order_operation TYPE vornr,
*----------------------------------------------------------------------*
*     Outbound delivery (R05)
          outbound_delivery_read
              IMPORTING i_outbound_delivery TYPE vbeln_vl
                        i_shipping_unit     TYPE xvsel  OPTIONAL,
*----------------------------------------------------------------------*
*     Output determination
          output_exist
              IMPORTING i_mblnr    TYPE mblnr
                        i_mjahr    TYPE mjahr
              EXPORTING i_exist    TYPE abap_bool
                        it_nastkey TYPE ty_t_nastkey,
*----------------------------------------------------------------------*
*     Pipeline supplier read.
          pipe_supplier_get
              IMPORTING
                is_gohead   TYPE gohead
              CHANGING
                cs_goitem   TYPE ty_s_goitem,
*----------------------------------------------------------------------*
*     Purchase order (internally used)
          purchase_order_get
              IMPORTING
                i_po_number TYPE ebeln
                i_po_item   TYPE ebelp     OPTIONAL
                i_po_werks  TYPE werks_d   OPTIONAL
                i_ib_number TYPE vbeln_vl  OPTIONAL
                i_ib_item   TYPE posnr_vl  OPTIONAL
                is_wueb     TYPE wueb      OPTIONAL
                is_vepwe    TYPE vepwe     OPTIONAL
                i_delivery  TYPE abap_bool OPTIONAL,
*----------------------------------------------------------------------*
          purchase_order_fill_cd
              IMPORTING
                is_poitem   TYPE ty_s_poitem
              CHANGING
                cs_goitem   TYPE goitem,
*----------------------------------------------------------------------*
          purchase_order_fill_data
              IMPORTING
                it_poitem    TYPE ty_t_poitem
                it_pofreight TYPE ty_t_pofreight OPTIONAL
                i_ib_number  TYPE vbeln_vl       OPTIONAL
                is_wueb      TYPE wueb           OPTIONAL
                is_vepwe     TYPE vepwe          OPTIONAL
                i_delivery   TYPE abap_bool      OPTIONAL,
*----------------------------------------------------------------------*
          purchase_order_st_fill_data
              IMPORTING
                it_st_poitem TYPE ty_t_st_poitem
                it_pofreight TYPE ty_t_pofreight OPTIONAL,
*----------------------------------------------------------------------*
          purchase_order_fill_goitem
              IMPORTING
                i_transfer   TYPE abap_bool
                is_poitem    TYPE ebefu          OPTIONAL
                is_st_poitem TYPE bbefu          OPTIONAL
                is_goitem    TYPE goitem
                it_pofreight TYPE ty_t_pofreight OPTIONAL
              EXPORTING
                es_goitem    TYPE goitem
              EXCEPTIONS
                no_take_over,
*----------------------------------------------------------------------*
          purchase_order_fill_matdoc
              IMPORTING
                is_mseg   TYPE ty_s_mseg
                is_goitem TYPE ty_s_goitem
              EXPORTING
                es_goitem TYPE goitem
              EXCEPTIONS
                no_take_over,
*----------------------------------------------------------------------*
          purchase_order_fill_gofreight
              IMPORTING
                it_pofreight TYPE ty_t_pofreight OPTIONAL
                i_po_number  TYPE ebeln
                i_po_item    TYPE ebelp
              EXPORTING
                e_freight    TYPE abap_bool,
*----------------------------------------------------------------------*
*     specific po data for full product and/or tied empty; <LG>
          purchase_order_full_empty
              IMPORTING  is_poitem    TYPE ebefu
                         is_st_poitem TYPE bbefu
                         i_transfer   TYPE abap_bool
              CHANGING   cs_goitem    TYPE goitem
              EXCEPTIONS full_not_found,
*----------------------------------------------------------------------*
*     specific data of an ordered tied empty; <LG>
          purchase_order_fill_tied_empty
              IMPORTING
                is_empties_poitem    TYPE ty_s_empties_poitem
              CHANGING
                cs_goitem    TYPE goitem
              EXCEPTIONS   not_found,
*----------------------------------------------------------------------*
* read generic article from PO
          purchase_order_fill_ga
              IMPORTING is_poitem       TYPE ty_s_poitem
                        it_poitem       TYPE ty_t_poitem
                        it_goitem       TYPE ty_t_goitem
              CHANGING  cs_goitem       TYPE ty_s_goitem,
*----------------------------------------------------------------------*
* read article with SLS from PO
          purchase_order_fill_vas
              IMPORTING is_poitem       TYPE ty_s_poitem
                        it_poitem       TYPE ty_t_poitem
              CHANGING  cs_goitem       TYPE ty_s_goitem,
*----------------------------------------------------------------------*
* add headers of generic article
          purchase_order_ga_header_add
              CHANGING  ct_poitem       TYPE ty_t_poitem,
*----------------------------------------------------------------------*
*     Purchase order (R01)
          purchase_order_read
              IMPORTING
                i_po_number TYPE ebeln
                i_po_item   TYPE ebelp   OPTIONAL
                i_po_werks  TYPE werks_d OPTIONAL,
*----------------------------------------------------------------------*
          purchase_order_read_header
              IMPORTING
                i_po_number TYPE ebeln,
*----------------------------------------------------------------------*
        purchase_order_read_data
            IMPORTING
              i_po_number  TYPE ebeln
              i_po_item    TYPE ebelp    OPTIONAL
              i_po_werks   TYPE werks_d  OPTIONAL
              i_ib_number  TYPE vbeln_vl OPTIONAL
              i_ib_item    TYPE posnr_vl OPTIONAL
              i_md_number  TYPE mblnr    OPTIONAL
              i_md_item    TYPE mblpo    OPTIONAL
              i_md_year    TYPE mjahr    OPTIONAL
              i_lfbnr      TYPE lfbnr    OPTIONAL
              i_lfpos      TYPE lfpos    OPTIONAL
              i_lfbja      TYPE lfbja    OPTIONAL
              i_sc_comp    TYPE i        OPTIONAL
            EXPORTING
              et_poitem    TYPE ty_t_poitem
              et_pofreight TYPE ty_t_pofreight,
*----------------------------------------------------------------------*
*   Components of subcontraction-purchase orders
        purchase_order_sc_data_fill                  "Outsourced Manufacturing EhP 4
            IMPORTING
              i_po_number  TYPE ebeln
              i_po_item    TYPE ebelp
              i_po_werks   TYPE werks_d  OPTIONAL
              i_ib_number  TYPE vbeln_vl OPTIONAL
              i_ib_item    TYPE posnr_vl OPTIONAL
            EXPORTING
              et_poitem    TYPE ty_t_poitem,
*----------------------------------------------------------------------*
*   Stock Transfer Purchase order - Goods Issue
        purchase_order_st_read_data
            IMPORTING
              i_po_number  TYPE ebeln
              i_po_item    TYPE ebelp    OPTIONAL
              i_po_werks   TYPE werks_d  OPTIONAL
              i_md_number  TYPE mblnr    OPTIONAL
              i_md_item    TYPE mblpo    OPTIONAL
              i_md_year    TYPE mjahr    OPTIONAL
            EXPORTING
              et_st_poitem TYPE ty_t_st_poitem
              et_pofreight TYPE ty_t_pofreight,
*----------------------------------------------------------------------*
*   Reservations
        reservation_data_get
            IMPORTING i_res_number   TYPE rsnum
              i_res_item     TYPE rspos OPTIONAL
              i_res_type     TYPE rsart OPTIONAL
              i_all          TYPE abap_bool DEFAULT abap_false,
*----------------------------------------------------------------------*
*   Reservations
        reservation_data_fill
            IMPORTING it_resheader   TYPE ty_t_resheader
                      it_resitem     TYPE ty_t_resitem,
*----------------------------------------------------------------------*
        reservation_fill_matdoc
          IMPORTING is_mseg      TYPE ty_s_mseg
                    is_goitem    TYPE ty_s_goitem
          EXPORTING es_goitem    TYPE ty_s_goitem,
*----------------------------------------------------------------------*
*   Reservations
        reservation_goitem_fill
            IMPORTING is_resheader   TYPE ty_s_resheader
                      is_resitem     TYPE ty_s_resitem,
*----------------------------------------------------------------------*
*   Reservations
        reservation_read
            IMPORTING i_res_number   TYPE rsnum
                      i_res_item     TYPE rspos OPTIONAL
                      i_res_type     TYPE rsart OPTIONAL,
*----------------------------------------------------------------------*
*   Reservations
        reservation_transfer
            IMPORTING is_resitem TYPE ty_s_resitem
            EXPORTING e_rc       TYPE abap_bool
            CHANGING  cs_goitem  TYPE ty_s_goitem,
*----------------------------------------------------------------------*
*   Subcontracting: Consumption of SC components before GR
          sc_line_modify
            IMPORTING is_new_goitem  TYPE goitem
                      is_old_goitem  TYPE goitem,
*----------------------------------------------------------------------*
*   Screenmodification triggered by the kernel
        screen_modify_mode,
        screen_modify_line
            IMPORTING is_goitem TYPE goitem,
        screen_modify_transfer_fields
            IMPORTING is_goitem TYPE goitem,
        screen_modify_status,
        screen_modify_general_rules
            IMPORTING is_goitem TYPE goitem OPTIONAL,
        screen_modify_automatic_lines
            IMPORTING is_goitem TYPE goitem,
        screen_modify_field_relevant
            IMPORTING i_fieldname       TYPE migo_fieldname
                      is_goitem         TYPE goitem
            RETURNING value(r_relevant) TYPE abap_bool,
*----------------------------------------------------------------------*
*   Send quantity to class: For product quantity units
        send_quantity_to_class
            IMPORTING
              is_goitem        TYPE goitem
            EXPORTING
              es_batch_dark    TYPE ty_s_batch_dark,
*----------------------------------------------------------------------*
*   Serialnumbers
        serialnumbers_fill
            IMPORTING i_counter        TYPE sy-tabix
                      i_global_counter TYPE goitem-global_counter,
*----------------------------------------------------------------------*
        serialnumbers_read
            IMPORTING is_goitem TYPE goitem
                      is_vepwe  TYPE vepwe                  "731711
            EXPORTING et_goserial TYPE ty_t_goserial,
*----------------------------------------------------------------------*
        serialnumbers_post,
*----------------------------------------------------------------------*
*   Select shipping elements
        shippingelement_select
            IMPORTING i_vbeln  TYPE vbeln_vl
            EXPORTING et_vepwe TYPE ty_t_vepwe,
*----------------------------------------------------------------------*
*   Transfer postings: Set special stock identifier in GOITEM
        special_stock_identifier_set
            CHANGING  cs_goitem TYPE goitem,
*----------------------------------------------------------------------*
*   Transfer postings: Set special stock identifier in IMSEG
        special_stock_imseg_set
            IMPORTING is_goitem TYPE goitem
            CHANGING  cs_imseg  TYPE imseg,
*----------------------------------------------------------------------*
*     Adjust the quantity for the childrens of a structured article.
          st_line_modify
            IMPORTING is_new_goitem  TYPE goitem
                      is_old_goitem  TYPE goitem,
*     Copy certain data of the header item to the children
          st_line_copy
            IMPORTING is_goitem_head TYPE goitem
                      i_copydata     TYPE c
            changing  cs_goitem_comp TYPE goitem,

*     explode the structured article and enrich goitem with the components
          st_explode_bom
            importing is_goitem_st   TYPE goitem
                      i_date         TYPE gohead-budat
                      i_tabix        TYPE sytabix
                      i_transfer     TYPE abap_bool
            exporting e_tabix        type sytabix,
*----------------------------------------------------------------------*
*   Transfer data
        transfer_read
            CHANGING  cs_goitem  TYPE goitem,
*----------------------------------------------------------------------*
*   Transport (R06)
        transport_read
            IMPORTING i_transport TYPE tknum,
*----------------------------------------------------------------------*
*   Transportidentification (R07)
        transportident_read
            IMPORTING i_transportident  TYPE traid
                      i_transport_means TYPE traty,
*----------------------------------------------------------------------*
*   Fill the UM-Fields (UMMAT/UMWRK/WMLGO/UMCHA/UMBAR)
        um_fields_fill
            CHANGING  cs_goitem        TYPE goitem,
*----------------------------------------------------------------------*
*   Fill the UM-Fields before post/check goods movement
        um_fields_fill_for_posting,
*----------------------------------------------------------------------*
*   Unit conversion
        unit_conversion
            IMPORTING i_called_by_reservation TYPE abap_bool OPTIONAL
                      i_transfer              TYPE abap_bool OPTIONAL
            CHANGING cs_goitem TYPE goitem,
*----------------------------------------------------------------------*
*   Valuation type
        valuation_type_set
            IMPORTING i_matnr     TYPE matnr
                      i_werks     TYPE werks_d
                      i_lgort     TYPE lgort_d
                      i_charg     TYPE charg_d
                      i_sobkz     TYPE sobkz
                      i_mat_kdauf TYPE mat_kdauf
                      i_mat_kdpos TYPE mat_kdpos
                      i_mat_pspnr TYPE mat_pspnr
                      i_kzbaa     TYPE kzbaa
            EXPORTING e_bwtar     TYPE bwtar_d,
*----------------------------------------------------------------------*
*   WM - Warehouse management
        wm_active_check
            IMPORTING i_werks  TYPE goitem-werks
                      i_lgort  TYPE goitem-lgort
            EXPORTING e_lgnum  TYPE lgnum,
*----------------------------------------------------------------------*
*   WM - Warehouse management data prepare
        wm_data_prepare
            CHANGING  cs_goitem TYPE goitem.

ENDCLASS.                    "lcl_migo_kernel DEFINITION