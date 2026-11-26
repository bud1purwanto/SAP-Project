*----------------------------------------------------------------------*
*   INCLUDE LMIGOBU1
*----------------------------------------------------------------------*
* Read methods with buffer tables
*----------------------------------------------------------------------*
CLASS lcl_migo_buffer DEFINITION.
*----------------------------------------------------------------------*
* PUBLIC SECTION                                                       *
*----------------------------------------------------------------------*
  PUBLIC SECTION.
*----------------------------------------------------------------------*
    TYPES: ty_t_mvt TYPE TABLE OF bwart.

*----------------------------------------------------------------------*
* Public CLASS-METHODS                                                 *
*----------------------------------------------------------------------*
    CLASS-METHODS:
*----------------------------------------------------------------------*
*     Allowed movement types get
      allowed_mvt_get
         IMPORTING  i_migo_mode   TYPE char10
                    i_migo_action TYPE goaction
         EXPORTING  et_mvt        TYPE ty_t_mvt,
*----------------------------------------------------------------------*
*     Checks if a movement type is allowed for the current process
      allowed_mvt_check
         IMPORTING  i_bwart TYPE bwart
         exceptions not_allowed,
*----------------------------------------------------------------------*
*     Fills got156 from buffer or t156
      move_type_get
         IMPORTING   i_move       TYPE bwart
         EXPORTING   e_got156     TYPE got156
                     es_migo_t156 TYPE migo_t156
         EXCEPTIONS  not_found,
*----------------------------------------------------------------------*
*     Fills 156N from buffer or from t156n
      move_type_next_get
         IMPORTING   i_move             TYPE bwart
                     i_fcode            TYPE t156n-fcode
         RETURNING   value(e_move_next) TYPE bwart
         EXCEPTIONS  not_found,
*----------------------------------------------------------------------*
*     Fills 156T from buffer or from t156t
      move_type_text_get               "exact match required
        IMPORTING  i_move              TYPE bwart
                   i_spec_stock        TYPE sobkz     OPTIONAL
                   i_mov_ind           TYPE kzbew     OPTIONAL
                   i_rec_ind           TYPE kzzug     OPTIONAL
                   i_consumpt          TYPE kzvbr     OPTIONAL
                   i_langu             TYPE spras     DEFAULT sy-langu
                   i_match             TYPE abap_bool DEFAULT abap_false
        RETURNING  value(e_move_text)  TYPE bwtxt
        EXCEPTIONS not_found,
*----------------------------------------------------------------------*
*     Reads complete name and telephone for a SAP user
    name_and_phone_get
       IMPORTING i_usnam   TYPE usnam  "SAP name (12)
       EXPORTING e_exnam   TYPE migo_username   "complete name (35)
                 e_telnr   TYPE sp_telno,                        "448648
*----------------------------------------------------------------------*
*     Reads complete name and telephone for buyer (T024)
    name_and_phone_buyer_get
       IMPORTING i_ekgrp   TYPE ekgrp
       EXPORTING e_eknam   TYPE eknam
                 e_ektel   TYPE ektel,
*----------------------------------------------------------------------*
*     Reads item categorie for BOM (T418)
    item_cat_get
       IMPORTING i_postp   TYPE postp
       EXPORTING e_kzbsf   TYPE kzbsf
       EXCEPTIONS not_found,
*----------------------------------------------------------------------*
*     Fills goplant from buffer or from db ( -> plant_get_from_db)
    plant_get
       IMPORTING   i_plant          TYPE werks_d
       RETURNING   value(e_goplant) TYPE goplant
       EXCEPTIONS  not_found
                   val_area_not_found,
*     Name only
    plant_name_get
       IMPORTING i_werks        TYPE werks_d
       RETURNING value(r_name1) TYPE name1,
*----------------------------------------------------------------------*
*     Fills goplant from buffer or from t001l
    storage_loc_get
       IMPORTING   i_plant              TYPE werks_d
                   i_storage_loc        TYPE lgort_d
       RETURNING   value(e_storage_loc) TYPE got001l
       EXCEPTIONS  not_found,
    sloc_name_get
       IMPORTING i_werks        TYPE werks_d
                 i_lgort        TYPE lgort_d
       RETURNING value(r_lgobe) TYPE lgobe,
*----------------------------------------------------------------------*
*    Fills WEVER from buffer or from T158 - note 315434
    trx_control_get                         "315434
       IMPORTING  i_tcode       TYPE tcode
       EXPORTING  e_wever       TYPE wever
       EXCEPTIONS not_found,
*----------------------------------------------------------------------*
    vendor_master_get
      IMPORTING
        i_lifnr         TYPE elifn
      EXPORTING
        es_vendordata_a TYPE lfa1
      EXCEPTIONS
        not_found,
*----------------------------------------------------------------------*
    customer_name_get
      IMPORTING
        i_kunnr TYPE ekunn
      EXPORTING
        e_customer_name TYPE name1_gp
      EXCEPTIONS
        not_found,
*----------------------------------------------------------------------*
*   looks if opt. archiving is active (t158 is read with transaction   *
*   corresponding to the current s_action-migo_mode)                   *
    archive_cust_get
      EXPORTING e_xarch TYPE xoarc,
*----------------------------------------------------------------------*
*   Get info if automatic creation of purchase order is allowed from
*   T158B
*   Note 556499
    auto_po_get
      IMPORTING
        i_tcode   TYPE tcode
        i_bwart   TYPE bwart
      EXPORTING
        e_xautopo TYPE mb_xfeld
      EXCEPTIONS
        not_found,
*----------------------------------------------------------------------*
* note 752637 start
* checks if goods movements are relevant for the given serial profile
    serial_relevance_check
      IMPORTING
        i_sernp TYPE serail
        i_bwart TYPE bwart
        i_SOBKZ TYPE sobkz
        i_KZBEW TYPE kzbew
        i_KZZUG TYPE kzzug
        i_kzvbr TYPE kzvbr
      EXPORTING
        e_serialize TYPE abap_bool,
* note 752637 end
* 719669_v
    order_type_get
      IMPORTING i_aufnr type aufnr
      RETURNING value(e_delkzord) TYPE delkz.
* 719669_^
*------------------------------------------------end of public section-*
* PRIVATE SECTION                                                      *
*----------------------------------------------------------------------*
  PRIVATE SECTION.
*----------------------------------------------------------------------*
* Private types                                                        *
*----------------------------------------------------------------------*
    TYPES:
      BEGIN OF pty_move_next_buffer,
        fcode      TYPE t156n-fcode,
        bwart      TYPE bwart,
        bwart_next TYPE bwart,
      END OF pty_move_next_buffer,
* type of buffer table for goplant
      BEGIN OF pty_plant_buffer,
        werks      TYPE werks_d,
        plant_data TYPE goplant,
      END OF pty_plant_buffer,
* type of buffer table for got001l
      BEGIN OF pty_storage_loc_buffer,
        plant            TYPE werks_d,
        st_loc           TYPE lgort_d,
        storage_loc_data TYPE got001l,
      END OF pty_storage_loc_buffer,
* Buffer table for user names and telephone
      BEGIN OF ty_s_name_buffer,
        usnam   TYPE usnam,            "SAP name (12)
        exnam   TYPE migo_username,    "complete name (35)
        telnr   TYPE sp_telno,                                   "448648
      END   OF ty_s_name_buffer,
* Vendor master
      BEGIN OF pty_s_vendor_buffer,
        lifnr TYPE elifn,
        lfa1  TYPE lfa1,
      END OF pty_s_vendor_buffer,
* Move type text buffer
      BEGIN OF pty_s_move_text_buffer,
        match TYPE abap_bool,
        spras TYPE spras,
        bwart TYPE bwart,
        sobkz TYPE sobkz,
        kzbew TYPE kzbew,
        kzzug TYPE kzzug,
        kzvbr TYPE kzvbr,
        btext TYPE bwtxt,
      END OF pty_s_move_text_buffer,
* buffer for customizing info of opt. archiving
      BEGIN OF pty_archive_buffer,
         tcode TYPE tcode,
         xarch TYPE xoarc,
      END OF pty_archive_buffer,
* buffer for order types added by note 719669
      BEGIN OF pty_order_type_buffer,
        aufnr TYPE aufnr,
        autyp TYPE auftyp,
      END OF pty_order_type_buffer.

*--------------------------------------------end of private types------*
* Private CLASS-DATA                                                   *
*----------------------------------------------------------------------*
    CLASS-DATA:
* Buffer table for goplant
     pt_plant_buffer       TYPE HASHED TABLE OF pty_plant_buffer
                                WITH UNIQUE KEY werks,
* Buffer table for got156
     pt_move_buffer        TYPE HASHED TABLE OF got156
                                WITH UNIQUE KEY bwart,
     pt_move_next_buffer   TYPE HASHED TABLE OF pty_move_next_buffer
                                WITH UNIQUE KEY fcode bwart,
* Buffer table for T156T-BTEXT
     pt_move_text_buffer TYPE HASHED TABLE OF pty_s_move_text_buffer
                                WITH UNIQUE KEY match
                                                spras
                                                bwart
                                                sobkz
                                                kzbew
                                                kzzug
                                                kzvbr,

* Buffer table for got001l
     pt_storage_loc_buffer TYPE HASHED TABLE OF pty_storage_loc_buffer
                                WITH UNIQUE KEY plant st_loc,
* Buffer table for user names and telephone
     pt_name_buffer TYPE HASHED TABLE OF ty_s_name_buffer
                         WITH UNIQUE KEY usnam,
     pt_024_buffer  TYPE HASHED TABLE OF t024
                         WITH UNIQUE KEY ekgrp,
* Buffer table for transaction control (T158)
     pt_158_buffer  TYPE HASHED TABLE OF t158      "315434
                         WITH UNIQUE KEY tcode,    "315434
* Buffer table of item categories for BOM
     pt_418_buffer  TYPE HASHED TABLE OF t418
                         WITH UNIQUE KEY postp,
* Vendor master
     pt_vendor_buffer TYPE HASHED TABLE OF pty_s_vendor_buffer
                         WITH UNIQUE KEY lifnr,
* Customer master
     pt_customer_buffer TYPE HASHED TABLE OF kna1
                         WITH UNIQUE KEY kunnr,
* buffer for customizing info of opt. archiving
     pt_archive_buffer  TYPE STANDARD TABLE OF pty_archive_buffer,
* buffer for Automatic creation of a purchase order / returns order
     pt_158b_buffer TYPE HASHED TABLE OF t158b                   "556499
                         WITH UNIQUE KEY tcode                   "556499
                                         bwart,                  "556499
* buffer for allowed movement types
     pt_mvt TYPE TABLE OF bwart,
* Private attributes to save last action/mode which are used to
* determine allowed movement types
     p_migo_action      TYPE goaction,
     p_migo_mode        TYPE char10,

* buffer for serial number customizing added by note 752637
     pt_156q_buffer TYPE HASHED TABLE OF t156q
                         WITH UNIQUE KEY bwart
                                         sobkz
                                         kzbew
                                         kzzug
                                         kzvbr,
* buffer for order types -> needed for ATP - added by note 719669
     pt_order_type_buffer type standard table of pty_order_type_buffer.

*--------------------------------------------end of private class-data-*
* Private CLASS-METHODS                                                *
*----------------------------------------------------------------------*
    CLASS-METHODS:
* used by method move_type_get to gather data for pt_plant_buffer from
* data base. Reads tables: t001w, t159l, tqss1, t001k, t001
      plant_get_from_db
         IMPORTING   i_plant TYPE werks_d
         EXPORTING   value(e_goplant) TYPE goplant
         EXCEPTIONS  not_found
                     val_area_not_found.
ENDCLASS.