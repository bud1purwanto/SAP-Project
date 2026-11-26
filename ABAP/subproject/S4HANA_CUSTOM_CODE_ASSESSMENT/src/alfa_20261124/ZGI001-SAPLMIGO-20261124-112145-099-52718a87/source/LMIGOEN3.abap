*----------------------------------------------------------------------*
*   INCLUDE LMIGOEN3                                                   *
*   Environment
*----------------------------------------------------------------------*

************************************************************************
* Register for the OK-codes of the buttons to start trips and
* register for OK_PICK to enable double clicking.
************************************************************************
METHOD constructor.
  DATA: lt_okcodes   TYPE lif_migo_frame=>ty_t_okcodes,
        lt_receiving TYPE lif_migo_frame=>ty_t_message_ids.
  lif_migo_frame~class_id = 'MIGO_ENVIRONMENT'.
  APPEND 'OK_PICK'              TO lt_okcodes.
  APPEND 'MIGO_OK_INSPLOT'      TO lt_okcodes.
  APPEND 'MIGO_OK_WM_SHOW'      TO lt_okcodes.
  APPEND 'MIGO_OK_PO_HISTORY'   TO lt_okcodes.
  APPEND 'MIGO_OK_PO_DOC'       TO lt_okcodes.
  APPEND 'MIGO_OK_STOCK_OVERV'  TO lt_okcodes.
  APPEND 'MIGO_OK_FI_DOC'       TO lt_okcodes.
  APPEND 'MIGO_OK_SPLIT_ST_OVR' TO lt_okcodes.
  APPEND 'MIGO_OK_STOCK_OVR_R'  TO lt_okcodes.
  APPEND 'MIGO_OK_STOCK_OVR_L'  TO lt_okcodes.
  APPEND 'MIGO_OK_LINKED_DOC'   TO lt_okcodes.
  APPEND 'MIGO_OK_LINKS'        TO lt_okcodes.
  APPEND 'MIGO_OK_HUM'          TO lt_okcodes.

  APPEND 'ITEMDETAIL_CURRENTLINE' TO lt_receiving.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes
      it_receiving  = lt_receiving.
ENDMETHOD.

************************************************************************
* Reaction for OK-codes.
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  DATA: l_name            TYPE lcl_migo_screenobject=>ty_name,
        l_tabix           TYPE sytabix,
        l_secondary_tabix TYPE sytabix,
        ls_gohead         TYPE gohead,
        ls_goitem         TYPE goitem,
        ls_goserial       TYPE lcl_migo_kernel=>ty_s_goserial,
        lt_goserial       TYPE lcl_migo_kernel=>ty_t_goserial,
        lt_gofreight      TYPE lcl_migo_kernel=>ty_t_gofreight,
        ls_gofreight      TYPE lcl_migo_kernel=>ty_s_gofreight,
        l_string          TYPE so_adrnam.

* Find out where the cursor is (section, fieldname, line, ...)
  IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
    CALL METHOD
      lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
        IMPORTING
          e_name            = l_name
          e_tabix           = l_tabix
          e_secondary_tabix = l_secondary_tabix.
  ENDIF.
* On the other hand: If a button has been pressed we always
* use the line where the itemdetail is (may change when buttons are
* in the tableview). Button in Split Quantity special handling.
  IF i_okcode(7) = 'MIGO_OK' AND i_okcode <> 'MIGO_OK_SPLIT_ST_OVR'
                             AND i_okcode <> 'MIGO_OK_LINKS'.    "527816
    l_tabix = p_itemdetail_line.
  ENDIF.
* Read the correct data from header, item, eventually dependent tables
  CALL METHOD lcl_migo_globals=>kernel->header_get
    IMPORTING e_gohead = ls_gohead.
  CALL METHOD lcl_migo_globals=>kernel->line_get
    EXPORTING i_line              = l_tabix
              i_dependent_tables  = abap_true
    IMPORTING es_goitem           = ls_goitem
              et_gofreight        = lt_gofreight
              et_goserial         = lt_goserial.
* In case of serial numbers, read the correct line of the
* dependent table.
  IF l_name = 'SERIALNUMBERS'.
    READ TABLE lt_goserial INTO ls_goserial INDEX l_secondary_tabix.
  ENDIF.
* In case of freight vendors, reas the correct line of the
* dependent table.
  IF l_name = 'FREIGHT'.
    READ TABLE lt_gofreight INTO ls_gofreight INDEX l_secondary_tabix.
  ENDIF.
* According to the fieldname or OK-code, fill the appropriate data
* into GOTRIP and call the method which calls the other applications.
  CASE i_okcode.
* Buttons ==============================================================
*   Stock overview
    WHEN 'MIGO_OK_STOCK_OVERV' OR 'MIGO_OK_SPLIT_ST_OVR'
                               OR 'MIGO_OK_STOCK_OVR_L'.
      IF NOT ls_goitem-matnr IS INITIAL.
        CALL METHOD stock_overview_show
          EXPORTING
            i_matnr = ls_goitem-matnr
            i_werks = ls_goitem-werks.
      ENDIF.
    WHEN 'MIGO_OK_STOCK_OVR_R'.
      IF NOT ls_goitem-ummat IS INITIAL.
        CALL METHOD stock_overview_show
          EXPORTING
            i_matnr = ls_goitem-ummat
            i_werks = ls_goitem-umwrk.
      ENDIF.
*   FI documents
    WHEN 'MIGO_OK_FI_DOC'.

      CALL METHOD fi_document_show
        EXPORTING
          i_mblnr = ls_gohead-mblnr
          i_mjahr = ls_gohead-mjahr
          i_awsys = ls_gohead-awsys.
*   Purchase order
    WHEN 'MIGO_OK_PO_DOC'.
      CALL METHOD purchase_order_show
        EXPORTING
          i_ebeln = ls_goitem-ebeln
          i_ebelp = ls_goitem-ebelp.
*   Purchase order history
    WHEN 'MIGO_OK_PO_HISTORY'.
      CALL METHOD po_history_show
        EXPORTING
          i_ebeln = ls_goitem-ebeln
          i_ebelp = ls_goitem-ebelp.
*         i_webre = ls_goitem-webre             "316149
*         i_bstyp = ls_goitem-bstyp             "316149
*         i_pstyp = ls_goitem-pstyp             "316149
*         i_retpo = ls_goitem-retpo.            "316149
*   Inspection lot
    WHEN 'MIGO_OK_INSPLOT'.
      CALL METHOD inspection_lot_show
        EXPORTING
          i_mblnr = ls_goitem-mblnr
          i_mjahr = ls_goitem-mjahr
          i_zeile = ls_goitem-zeile.
*   Warehousemanagement
    WHEN 'MIGO_OK_WM_SHOW'.
      CALL METHOD wm_show
        EXPORTING
          i_lgnum = ls_goitem-lgnum
          i_tbnum = ls_goitem-tbnum
          i_tbpos = ls_goitem-tbpos.
*   Handling Unit
    WHEN 'MIGO_OK_HUM'.
       CALL METHOD handling_unit_show
         EXPORTING
           i_mblnr = ls_goitem-mblnr
           i_mjahr = ls_goitem-mjahr.
*   Purchase order
    WHEN 'GOITEM-EBELP'.
      CALL METHOD purchase_order_show
        EXPORTING
          i_ebeln = ls_goitem-ebeln
          i_ebelp = ls_goitem-ebelp.
*   Documents linked to the material
    WHEN 'MIGO_OK_LINKED_DOC' OR 'MIGO_OK_LINKS'.
      CALL METHOD linked_documents_show
        EXPORTING
          i_matnr = ls_goitem-matnr.
* Double click =========================================================
    WHEN 'OK_PICK'.
*     Leave if there is no entry in the selected field
*     Exception [:-)] Double click on an empty serial number field
*     should call the complete list come up.
      CHECK NOT lcl_migo_cursor=>value IS INITIAL OR
            l_name = 'SERIALNUMBERS'.
      CASE lcl_migo_cursor=>field.
*       Material all views
        WHEN 'GOITEM-MAKTX' OR 'GOITEM-MATNR' OR 'GOITEM-EAN11_BME' OR
             'GOITEM-EAN11_KON' OR 'GOITEM-EANME' OR 'G_SPLIT_MAKTX' OR
             'G_SPLIT_MATNR' OR 'GODYNPRO-MATNR' OR 'GODYNPRO-MAKTX'.
          CALL METHOD material_show
            EXPORTING
              i_matnr = ls_goitem-matnr
              i_werks = ls_goitem-werks                         "1008210
              i_lgort = ls_goitem-lgort                         "1008210
              i_bwtar = ls_goitem-bwtar                         "1008210
              i_mxx   = 'BDEKLXZ'.
*       Plant (material view)
        WHEN 'GOITEM-WERKS' OR 'GOITEM-NAME1' OR 'G_SPLIT_NAME1' OR
             'G_SPLIT_WERKS' OR 'GODYNPRO-WERKS' OR 'GODYNPRO-NAME1'.
          IF NOT ls_goitem-matnr IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-matnr
                i_werks = ls_goitem-werks
                i_mxx   = 'X'.
          ENDIF.
*       Storage location (material view)
        WHEN 'GOITEM-LGORT' OR 'GOITEM-LGOBE' OR
             'GODYNPRO-LGORT' OR 'GODYNPRO-LGOBE'.
          IF NOT ls_goitem-matnr IS INITIAL
             AND NOT ls_goitem-werks IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-matnr
                i_werks = ls_goitem-werks
                i_lgort = ls_goitem-lgort
                i_mxx   = 'Z'.
          ENDIF.
*       Valuation type (material view)
        WHEN 'GOITEM-BWTAR' OR 'GODYNPRO-BWTAR'.
          IF NOT ls_goitem-matnr IS INITIAL
             AND NOT ls_goitem-werks IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-matnr
                i_werks = ls_goitem-werks
                i_bwtar = ls_goitem-bwtar
                i_mxx   = 'B'.
          ENDIF.
*       Stockholding material
        WHEN 'GOITEM-MATBF'.
          CALL METHOD material_show
            EXPORTING
              i_matnr = ls_goitem-matbf
              i_werks = ls_goitem-werks
              i_mxx   = 'BDEKLXZ'.
*       Inforecord
        WHEN 'GOITEM-IDNLF'.
          CALL METHOD inforecord_show
            EXPORTING
              i_matnr = ls_goitem-matnr
              i_werks = ls_goitem-werks
              i_ekorg = ls_goitem-ekorg
              i_lifnr = ls_goitem-lifnr
              i_sobkz = ls_goitem-sobkz.
*       Batch
        WHEN 'GOITEM-CHARG' OR 'GODYNPRO-CHARG'.
          IF NOT ls_goitem-matnr IS INITIAL
             AND NOT ls_goitem-werks IS INITIAL.
            CALL METHOD batch_show
              EXPORTING
                i_matnr = ls_goitem-matnr
                i_werks = ls_goitem-werks
                i_lgort = ls_goitem-lgort
                i_charg = ls_goitem-charg.
          ENDIF.
*       Purchase order
        WHEN 'GOITEM-EBELN'.
          CALL METHOD purchase_order_show
            EXPORTING
              i_ebeln = ls_goitem-ebeln.
*       Purchase order position
        WHEN 'GOITEM-EBELP'.
          CALL METHOD purchase_order_show
            EXPORTING
              i_ebeln = ls_goitem-ebeln
              i_ebelp = ls_goitem-ebelp.
*       Delivery if possible                                  "428337
        WHEN 'GOHEAD-LFSNR' OR 'GOHEAD-MTSNR'.
          CALL METHOD delivery_show
            EXPORTING
              i_mblnr = ls_gohead-mblnr
              i_mjahr = ls_gohead-mjahr
              i_vbeln = ls_gohead-xblnr.
*       Vendors in the header
        WHEN 'GOHEAD-LIFNR' OR 'GOHEAD-VENDORNAME' OR
             'GOHEAD-VENDORZIP' OR 'GOHEAD-VENDORADD'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_gohead-lifnr
              i_ekorg = ls_gohead-ekorg
              i_bsakz = ls_gohead-bsakz.
        WHEN 'GOHEAD-RECVENDNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_gohead-emlif
              i_ekorg = ls_gohead-ekorg
              i_bsakz = ls_gohead-bsakz.
        WHEN 'GOHEAD-SUPVENDNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_gohead-llief
              i_ekorg = ls_gohead-ekorg
              i_bsakz = ls_gohead-bsakz.
*       Vendors in the positions
        WHEN 'GOITEM-LIFNR' OR 'GOITEM-VENDORNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_goitem-lifnr
              i_bukrs = ls_goitem-bukrs
              i_ekorg = ls_goitem-ekorg
              i_bsakz = ls_goitem-bsakz.
        WHEN 'GOITEM-MAT_LIFNR' OR 'GOITEM-MAT_VENDORNAME' OR
             'GODYNPRO-MAT_LIFNR' OR 'GODYNPRO-MAT_VENDORNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_goitem-mat_lifnr
              i_bukrs = ls_goitem-bukrs.
        WHEN 'GOITEM-UMMAT_LIFNR' OR 'GOITEM-UMMAT_VENDORNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_goitem-ummat_lifnr.
        WHEN 'GOITEM-RECVENDNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_goitem-emlif
              i_bukrs = ls_goitem-bukrs_for_stock
              i_ekorg = ls_goitem-ekorg
              i_bsakz = ls_goitem-bsakz.
        WHEN 'GOITEM-RSNUM'.
          CALL METHOD reservation_show
            EXPORTING
              i_rsnum = ls_goitem-rsnum.
        WHEN 'GOITEM-PPS_AUFNR'.
          CALL METHOD order_show
            EXPORTING i_aufnr = ls_goitem-pps_aufnr.
        WHEN 'GOITEM-AUFNR'.
          CALL METHOD order_show
            EXPORTING i_aufnr = ls_goitem-aufnr.
        WHEN 'GOITEM-SUPVENDNAME'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_goitem-llief
              i_bukrs = ls_goitem-bukrs_for_stock
              i_ekorg = ls_goitem-ekorg
              i_bsakz = ls_goitem-bsakz.
*       Customer
        WHEN 'GOITEM-KUNNR' OR 'GOITEM-CUSTNAME'.
          CALL METHOD customer_address_show
            EXPORTING
              i_kunnr = ls_goitem-kunnr
              i_bukrs = ls_goitem-bukrs.
        WHEN 'GOITEM-MAT_KUNNR' OR 'GOITEM-MAT_CUSTNAME' OR
             'GODYNPRO-MAT_KUNNR' OR 'GODYNPRO-MAT_CUSTNAME'.
          CALL METHOD customer_address_show
            EXPORTING
              i_kunnr = ls_goitem-mat_kunnr
              i_bukrs = ls_goitem-bukrs.
        WHEN 'GOITEM-UMMAT_KUNNR' OR 'GOITEM-UMMAT_CUSTNAME'.
          CALL METHOD customer_address_show
            EXPORTING
              i_kunnr = ls_goitem-ummat_kunnr.
*       Usernames
        WHEN 'GOHEAD-CREATEDBY'.
          CALL METHOD useraddress_show
            EXPORTING i_uname = ls_gohead-usnam.
        WHEN 'GOHEAD-POUSERNAME'.
          CALL METHOD useraddress_show
            EXPORTING i_uname = ls_gohead-pouser.
        WHEN 'GODYNPRO-USERNAME'.
          CALL METHOD useraddress_show
            EXPORTING i_string = godynpro-username.
        WHEN 'GOITEM-WEMPF'.
*         Why is casting like this still necessary? When does
*         ABAP learn the implicit cast?
          l_string = ls_goitem-wempf.
          CALL METHOD useraddress_show
            EXPORTING i_string = l_string.
        WHEN 'GOITEM-AFNAM'.
          l_string = ls_goitem-afnam.
          CALL METHOD useraddress_show
            EXPORTING i_string = l_string.
*       Serial numbers
        WHEN 'GOSERIAL-SERIALNO'.
          CALL METHOD serialnumber_show
            EXPORTING
              i_matnr = ls_goitem-matnr
              i_sernr = ls_goserial-serialno.
*       Freight vendor
        WHEN 'GOFREIGHT-VENDORNAME' OR 'GOFREIGHT-LIFNR'.
          CALL METHOD vendor_address_show
            EXPORTING
              i_lifnr = ls_gofreight-lifnr
              i_ekorg = ls_goitem-ekorg
              i_bsakz = ls_goitem-bsakz.
*       Account
        WHEN 'GOITEM-KONTO'.
          CALL METHOD account_show
            EXPORTING
              i_konto = ls_goitem-konto
              i_bukrs = ls_goitem-bukrs.

*       Transferfields Environment --------------------------
*       Transfer: Material
        WHEN 'GOITEM-UMMAT' OR 'GOITEM-UMMAKTX'.
          CALL METHOD material_show
            EXPORTING
              i_matnr = ls_goitem-ummat
              i_mxx   = 'BDEKLXZ'.
*       Transfer: Valuation type
        WHEN 'GOITEM-UMBAR' OR 'GODYNPRO-UMBAR'.
          IF NOT ls_goitem-ummat IS INITIAL
             AND NOT ls_goitem-umwrk IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-ummat
                i_werks = ls_goitem-umwrk
                i_bwtar = ls_goitem-umbar
                i_mxx   = 'B'.
          ENDIF.
*       Transfer: Plant
        WHEN 'GOITEM-UMWRK' OR 'GOITEM-UMNAME1'.
          IF NOT ls_goitem-ummat IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-ummat
                i_werks = ls_goitem-umwrk
                i_mxx   = 'X'.
          ENDIF.
*       Transfer: Storage location
        WHEN 'GOITEM-UMLGO' OR 'GOITEM-UMLGOBE'.
          IF NOT ls_goitem-ummat IS INITIAL
             AND NOT ls_goitem-umwrk IS INITIAL.
            CALL METHOD material_show
              EXPORTING
                i_matnr = ls_goitem-ummat
                i_werks = ls_goitem-umwrk
                i_lgort = ls_goitem-umlgo
                i_mxx   = 'Z'.
          ENDIF.
*       Transfer: Batch
        WHEN 'GOITEM-UMCHA' OR 'GODYNPRO-UMCHA'.
          IF NOT ls_goitem-ummat IS INITIAL
             AND NOT ls_goitem-umwrk IS INITIAL.
            CALL METHOD batch_show
              EXPORTING
                i_matnr = ls_goitem-ummat
                i_werks = ls_goitem-umwrk
                i_lgort = ls_goitem-umlgo
                i_charg = ls_goitem-umcha.
          ENDIF.
*       End Transferfields Environment --------------------------
      ENDCASE.
  ENDCASE.
ENDMETHOD.

************************************************************************
* Reaction for messages
************************************************************************
METHOD lif_migo_frame~message_handler.
  CASE i_message_id.
    WHEN 'ITEMDETAIL_CURRENTLINE'.
      p_itemdetail_line = is_message-data1.
  ENDCASE.
ENDMETHOD.