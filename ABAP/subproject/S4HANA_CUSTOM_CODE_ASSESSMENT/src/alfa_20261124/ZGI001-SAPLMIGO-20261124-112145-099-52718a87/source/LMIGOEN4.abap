*----------------------------------------------------------------------*
*   INCLUDE LMIGOEN4                                                   *
*   Environment: Targets
*----------------------------------------------------------------------*

************************************************************************
* Call transaction with authorization check
************************************************************************
METHOD migo_call_transaction.
  DATA: l_task TYPE pexreport,
        l_max_sessions TYPE sta_cntre,
        l_act_sessions TYPE sta_cntre.
  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
       EXPORTING
            tcode  = i_tcode
       EXCEPTIONS
            ok     = 0
            not_ok = 1
            OTHERS = 2.
* Authorization error
  IF sy-subrc <> 0.
    e_not_authorized = abap_true.
    MESSAGE s172(00) WITH i_tcode.
    EXIT.
  ENDIF.
  e_not_authorized = abap_false.
* Leave if only authorization check was requested
  CHECK i_nocall = abap_false.
* Call the transaction
  CALL TRANSACTION i_tcode AND SKIP FIRST SCREEN.
ENDMETHOD.                    "migo_call_transaction

************************************************************************
* Save the value in a given list of SET/GET-Parameters
************************************************************************
METHOD setget_save.
  DATA: l_parid   TYPE memoryid,
        lt_parid  TYPE STANDARD TABLE OF memoryid,
        ls_setget TYPE ty_s_setget.
  SPLIT i_list AT ' ' INTO TABLE lt_parid.
  CLEAR pt_setget.
  LOOP AT lt_parid INTO l_parid.
    ls_setget-parid = l_parid.
    GET PARAMETER ID l_parid FIELD ls_setget-parva.
    APPEND ls_setget TO pt_setget.
  ENDLOOP.
ENDMETHOD.                    "setget_save

************************************************************************
* Restore the saved parameters
************************************************************************
METHOD setget_restore.
  DATA: ls_setget TYPE ty_s_setget.
  LOOP AT pt_setget INTO ls_setget.
    SET PARAMETER ID ls_setget-parid FIELD ls_setget-parva.
  ENDLOOP.
ENDMETHOD.                    "setget_restore

************************************************************************
* Stock overview (MMBE)
************************************************************************
METHOD stock_overview_show.
  DATA: lt_usr05 TYPE STANDARD TABLE OF usr05,
        ls_usr05 TYPE usr05.
  ls_usr05-parid = 'MAT'. ls_usr05-parva = i_matnr.
  APPEND ls_usr05 TO lt_usr05.
  ls_usr05-parid = 'WRK'. ls_usr05-parva = i_werks.
  APPEND ls_usr05 TO lt_usr05.
  ls_usr05-parid = 'LAG'. ls_usr05-parva = space.
  APPEND ls_usr05 TO lt_usr05.
  ls_usr05-parid = 'CHA'. ls_usr05-parva = space.
  APPEND ls_usr05 TO lt_usr05.
ENHANCEMENT-SECTION     LMIGOEN4_01 SPOTS ES_SAPLMIGO.
  CALL FUNCTION 'MMIM_CALL_TRANSACTION'
       EXPORTING
            i_transaction       = 'MMBE'
            i_skip_first_screen = 'X'
            i_new_mode          = 'X'
       TABLES
            it_parameters       = lt_usr05
       EXCEPTIONS
            not_authorized      = 1
            OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
END-ENHANCEMENT-SECTION.
ENDMETHOD.                    "stock_overview_show

************************************************************************
* Material (MM03)
************************************************************************
METHOD material_show.
  CALL METHOD setget_save( 'MAT WRK LAG BWT MXX' ).
  SET PARAMETER ID 'MAT' FIELD i_matnr.
  SET PARAMETER ID 'WRK' FIELD i_werks.
  SET PARAMETER ID 'LAG' FIELD i_lgort.
  SET PARAMETER ID 'BWT' FIELD i_bwtar.
  SET PARAMETER ID 'MXX' FIELD i_mxx.
  CALL METHOD migo_call_transaction( i_tcode = 'MM03' ).
  CALL METHOD setget_restore.
ENDMETHOD.                    "material_show

************************************************************************
* Address of vendor (XK03)
************************************************************************
METHOD vendor_address_show.
* Nothing to show if this is a stock transfer order
  IF i_bsakz = t.
    MESSAGE s004.
    EXIT.
  ENDIF.
  CALL METHOD setget_save( 'LIF BUK EKO' ).
  SET PARAMETER ID 'LIF' FIELD i_lifnr.
  IF i_bukrs <> space.
    SET PARAMETER ID 'BUK' FIELD i_bukrs.
  ENDIF.
  SET PARAMETER ID 'EKO' FIELD i_ekorg.
  SET PARAMETER ID 'KDY' FIELD '/110/310'.                       "676930
  CALL METHOD migo_call_transaction( i_tcode = 'XK03' ).
  CALL METHOD setget_restore.
ENDMETHOD.                    "vendor_address_show

************************************************************************
* Inforecord (ME13)
************************************************************************
METHOD inforecord_show.
  CALL METHOD setget_save( 'LIF WRK MAT EKO ESO' ).
  SET PARAMETER ID 'LIF' FIELD i_lifnr.
  SET PARAMETER ID 'WRK' FIELD i_werks.
  SET PARAMETER ID 'MAT' FIELD i_matnr.
  SET PARAMETER ID 'EKO' FIELD i_ekorg.
  SET PARAMETER ID 'ESO' FIELD i_sobkz.
  CALL METHOD migo_call_transaction( i_tcode = 'ME13' ).
  CALL METHOD setget_restore.
ENDMETHOD.                    "inforecord_show

************************************************************************
* Batch (MSC3N)
************************************************************************
METHOD batch_show.
  CALL METHOD setget_save( 'MAT WRK LAG CHA LAST_TAB_BATCH' ).
  SET PARAMETER ID 'MAT' FIELD i_matnr.
  SET PARAMETER ID 'WRK' FIELD i_werks.
  SET PARAMETER ID 'LAG' FIELD i_lgort.
  SET PARAMETER ID 'CHA' FIELD i_charg.
* Batch without LGORT in case of special stock E            "0823971
  IF goitem-sobkz IS NOT INITIAL.                           "1615290
    SET PARAMETER ID 'LAG' FIELD ''.                        "0823971
  ENDIF.                                                    "0823971
  IF i_classification = abap_true.
    SET PARAMETER ID 'LAST_TAB_BATCH' FIELD '2300'.
  ENDIF.
  CALL METHOD migo_call_transaction( i_tcode = 'MSC3N' ).
  CALL METHOD setget_restore.
ENDMETHOD.                    "batch_show

************************************************************************
* FI document
************************************************************************
METHOD fi_document_show.
  DATA: l_awref TYPE acchd-awref,
        l_aworg TYPE acchd-aworg,
        l_awtyp TYPE acchd-awtyp.
  l_awref = i_mblnr.
  l_aworg = i_mjahr.
  l_awtyp = 'MKPF'.
  CALL FUNCTION 'AC_DOCUMENT_RECORD'
       EXPORTING
            i_awtyp      = l_awtyp
            i_awref      = l_awref
            i_aworg      = l_aworg
            i_awsys      = i_awsys
       EXCEPTIONS
            no_reference = 1
            no_document  = 2
            OTHERS       = 3.
  CASE sy-subrc.
    WHEN 0.
    WHEN 1.
      MESSAGE s008(mick) WITH i_mblnr i_mjahr.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.
ENDMETHOD.                    "fi_document_show

************************************************************************
* Purchase order
************************************************************************
METHOD purchase_order_show.
  DATA: l_auth_fail TYPE abap_bool.
  CALL METHOD migo_call_transaction
    EXPORTING
      i_tcode  = 'ME23N'                    "note 357027
      i_nocall = abap_true
    IMPORTING
      e_not_authorized = l_auth_fail.
  CHECK l_auth_fail = abap_false.
    CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
         EXPORTING
              i_ebeln      = i_ebeln
              i_ebelp      = i_ebelp
              i_enjoy      = x
         EXCEPTIONS
              not_found    = 1
              no_authority = 2
              invalid_call = 3
              OTHERS       = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMETHOD.                    "purchase_order_show

************************************************************************
* Purchase order history
************************************************************************
METHOD po_history_show.
* submit report rm06ehbe will be changed by new function to display
* purchase order history with ENJOY design in PopUp by note 316149
  SUBMIT rm07migo_po_history WITH i_ebeln = i_ebeln
                             WITH i_ebelp = i_ebelp
                              AND RETURN.
ENDMETHOD.                    "po_history_show

************************************************************************
* delivery     (note 428337)
************************************************************************
METHOD delivery_show.
   DATA: ls_vbeln TYPE vbeln.             "due to type conflict in FB
   ls_vbeln = i_vbeln.
   CHECK NOT ls_vbeln IS INITIAL.
   CALL FUNCTION 'SD_SHOW_ORIGINATE_DOCUMENT'
     EXPORTING
       mblnr                   = i_mblnr
       mjahr                   = i_mjahr
       vbeln                   = ls_vbeln
     EXCEPTIONS
       OTHERS                  = 1.

   IF sy-subrc <> 0.
    MESSAGE s872(m7) WITH ls_vbeln.                     "N1083896
 endif.
  ENDMETHOD.                    "delivery_show

************************************************************************
* Warehousemanagement data
************************************************************************
METHOD wm_show.
  CALL METHOD setget_save( 'LGN TBN TBP' ).
  SET PARAMETER ID 'LGN' FIELD i_lgnum.
  SET PARAMETER ID 'TBN' FIELD i_tbnum.
  SET PARAMETER ID 'TBP' FIELD i_tbpos.
  CALL METHOD migo_call_transaction( i_tcode = 'LB03' ).
  CALL METHOD setget_restore.
  ENDMETHOD.                    "wm_show

************************************************************************
* Inspection lot (QM)
************************************************************************
METHOD inspection_lot_show.
  CALL FUNCTION 'QPL2_LOT_LIST_SHOW'
       EXPORTING
            vorgang     = i_mblnr
            vorgpos     = i_zeile
            vorgjahr    = i_mjahr
       EXCEPTIONS
            bad_options = 1
            no_entry    = 2
            OTHERS      = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ENDMETHOD.                    "inspection_lot_show

************************************************************************
* User data
************************************************************************
METHOD useraddress_show.
  DATA: l_uname    TYPE syuname,
        ls_name_in TYPE soud3.
  l_uname = i_uname.
* SAP-name not given --> locate
  IF l_uname IS INITIAL.
    CALL METHOD lcl_migo_globals=>kernel->name_search
        EXPORTING
          i_string  = i_string
        IMPORTING
          e_sapname = l_uname
        EXCEPTIONS
          OTHERS    = 1.
*   Exit if not resolvable
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.
* Use L_UNAME to show the address
  ls_name_in-sapnam = l_uname.
  CALL FUNCTION 'SO_ADDRESS_SHOW'
       EXPORTING
            user            = ls_name_in
       EXCEPTIONS
            parameter_error = 1
            user_not_exist  = 2
            x_error         = 3
            OTHERS          = 1.
  IF sy-subrc <> 0.
    MESSAGE s240(so) WITH ls_name_in.
  ENDIF.
  ENDMETHOD.                    "useraddress_show

************************************************************************
* Serialnumber
************************************************************************
METHOD serialnumber_show.
  CALL METHOD setget_save( 'MAT SER' ).
  SET PARAMETER ID 'MAT' FIELD i_matnr.
  SET PARAMETER ID 'SER' FIELD i_sernr.
  CALL METHOD migo_call_transaction( i_tcode = 'IQ03' ).
  CALL METHOD setget_restore.
  ENDMETHOD.                    "serialnumber_show


************************************************************************
* Account data
************************************************************************
METHOD account_show.
  CALL METHOD setget_save( 'SAK BUK' ).
  SET PARAMETER ID 'SAK' FIELD i_konto.
  SET PARAMETER ID 'BUK' FIELD i_bukrs.
  CALL METHOD migo_call_transaction( i_tcode = 'FSS0' ).
  CALL METHOD setget_restore.
  ENDMETHOD.                    "account_show

************************************************************************
* Linked documents to the material
************************************************************************
METHOD linked_documents_show.
  DATA: l_objky TYPE objky.
  l_objky = i_matnr.
  CALL FUNCTION 'CV141_SHOW_LINK_DOCUMENT'
       EXPORTING
            ps_drad_objky = l_objky
            ps_drad_dokob = 'MARA'.
  ENDMETHOD.                    "linked_documents_show

************************************************************************
* Handling unit
************************************************************************
METHOD handling_unit_show.
  DATA: lt_objects  TYPE hum_object_t,
        ls_objects  TYPE hum_object,
        lt_venum    TYPE hum_venum_t,
        lt_messages TYPE huitem_messages_t.

  ls_objects-objkey = i_mblnr.
  ls_objects-objkey+10(4) = i_mjahr.
  ls_objects-object = 'WE'.               "Wareneingangsbeleg
  APPEND ls_objects TO lt_objects.
  ls_objects-object = 'WA'.               "Warenausgangsbeleg
  APPEND ls_objects TO lt_objects.
  ls_objects-object = 'MM'.               "Umbuchung und/oder Umlagerung
  APPEND ls_objects TO lt_objects.
  ls_objects-object = 'MS'.               "Materialbelegsstorno
  APPEND ls_objects TO lt_objects.

* find number of handling unit
  CALL FUNCTION 'HU_PER_DOCUMENT_READ'
       EXPORTING
            it_objects  = lt_objects
       IMPORTING
            et_highest  = lt_venum
            et_messages = lt_messages
       EXCEPTIONS
            error       = 1
            OTHERS      = 0.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* display handling unit
  CALL FUNCTION 'HU_DISPLAY'
       EXPORTING
            it_venum   = lt_venum
       EXCEPTIONS
            no_hus_found = 01
            OTHERS       = 99.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ENDMETHOD.                    "handling_unit_show

************************************************************************
* Address of customer (XD03)
************************************************************************
METHOD customer_address_show.
  CALL METHOD setget_save( 'KUN BUK' ).
  SET PARAMETER ID 'KUN' FIELD i_kunnr.
  IF i_bukrs <> space.
    SET PARAMETER ID 'BUK' FIELD i_bukrs.
  ENDIF.
  CALL METHOD migo_call_transaction( i_tcode = 'XD03' ).
  CALL METHOD setget_restore.
  ENDMETHOD.                    "customer_address_show