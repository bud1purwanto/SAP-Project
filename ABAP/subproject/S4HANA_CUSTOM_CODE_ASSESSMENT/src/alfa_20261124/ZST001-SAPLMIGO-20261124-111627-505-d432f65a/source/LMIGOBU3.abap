*----------------------------------------------------------------------*
* INCLUDE LMIGOBU3                                                     *
*----------------------------------------------------------------------*

************************************************************************
* Vendor master data: we only read table LFA1. No need for LFM1 (EKORG)
************************************************************************
METHOD vendor_master_get.
  DATA: ls_buffer TYPE pty_s_vendor_buffer.
  DATA: s_addr1_val type addr1_val,                  "IAV
        l_iav(1).                                    "IAV
  IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'.   "IAV
    l_iav = 'X'.                                     "IAV
  ENDIF.                                             "IAV
  IF NOT i_lifnr IS INITIAL.                                     "556316
* Buffer
    READ TABLE pt_vendor_buffer INTO ls_buffer
               WITH TABLE KEY lifnr = i_lifnr.
    IF sy-subrc = 0.
      es_vendordata_a = ls_buffer-lfa1.
      EXIT.
    ENDIF.
* Database: only LFA1
    CLEAR es_vendordata_a.
    ls_buffer-lifnr = i_lifnr.
    CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
      EXPORTING
        i_lfa1_lifnr     = i_lifnr
        i_lfm1_ekorg     = space
        i_read_cam       = l_iav                     "IAV
      IMPORTING
        a_lfa1           = ls_buffer-lfa1
        a_address_value  = s_addr1_val               "IAV
      EXCEPTIONS
        vendor_not_found = 1
        OTHERS           = 2 .
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
  IF l_iav EQ 'X'.
    cl_iav_mapping_util=>copy_address_to_lfa1(
         EXPORTING is_address_value = s_addr1_val
         CHANGING cs_lfa1 = ls_buffer-lfa1 ).
  ENDIF.

* Insert set, return result
   INSERT ls_buffer INTO TABLE pt_vendor_buffer.

    es_vendordata_a = ls_buffer-lfa1.
  ELSE.                                                          "556316
    CLEAR es_vendordata_a.                                       "556316
  ENDIF.                                                         "556316
ENDMETHOD.                             "VENDOR_MASTER_GET

************************************************************************
* Reads T418 data from buffer or from data base and updates buffer
************************************************************************
METHOD item_cat_get.
  DATA: ls_t418 TYPE t418.
* look for item categorie data in the buffer table
  READ TABLE pt_418_buffer INTO ls_t418
       WITH TABLE KEY postp = i_postp.
  IF sy-subrc = 0.
    e_kzbsf = ls_t418-kzbsf.
    EXIT.
  ENDIF.
* read movement type data from data base
  CLEAR ls_t418.
  SELECT SINGLE * FROM t418 INTO ls_t418 WHERE postp = i_postp.
  IF sy-subrc = 0.
    e_kzbsf = ls_t418-kzbsf.
    INSERT ls_t418 INTO TABLE pt_418_buffer.
  ELSE.
*   No insert into the buffer
    MESSAGE e001(mick) WITH i_postp
            RAISING not_found.
  ENDIF.
ENDMETHOD.                             "ITEM_CAT_GET
************************************************************************
* Reads customer master from buffer or from data base and updates buffer
************************************************************************
METHOD customer_name_get.
  DATA: ls_buffer TYPE kna1.
  CHECK NOT i_kunnr IS INITIAL.
* Buffer
  READ TABLE pt_customer_buffer INTO ls_buffer
             WITH TABLE KEY kunnr = i_kunnr.
  IF sy-subrc = 0.
    e_customer_name = ls_buffer-name1.
    EXIT.
  ENDIF.
* Database
  CLEAR ls_buffer.
  CALL FUNCTION 'KNA1_READ_SINGLE'
    EXPORTING
      id_kunnr                  = i_kunnr
    IMPORTING
      es_kna1                   = ls_buffer
    EXCEPTIONS
*     NOT_FOUND                 = 1
*     INPUT_NOT_SPECIFIED       = 2
      OTHERS                    = 1
            .
  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.
* Insert set, return result
  INSERT ls_buffer INTO TABLE pt_customer_buffer.
  e_customer_name = ls_buffer-name1.

ENDMETHOD.                             "CUSTOMER_NAME_GET

************************************************************************
* Method    archive_cust_get
************************************************************************
* reads t158 with transaction corresponding to te current
* s_action-migo_mode:
************************************************************************
METHOD archive_cust_get.
  DATA: ls_archive_buffer TYPE pty_archive_buffer,
        l_tcode TYPE tcode.

  CLEAR: e_xarch.

* Customizing for archiving operates on the internal code
* describing the mode. It accesses T158 which only should countain
* entries MIGO_GR, MIGO_GI, MIGO_GO, MIGO_GS and MIGO_TR.
* Other entries in this table are irrelevant!
  CASE lcl_migo_globals=>kernel->s_action-migo_mode.
    WHEN 'GI'.
      l_tcode = 'MIGO_GI'.
    WHEN 'GO'.
      l_tcode = 'MIGO_GO'.
    WHEN 'GR'.
      l_tcode = 'MIGO_GR'.
    WHEN 'GS'.
      l_tcode = 'MIGO_GS'.
    WHEN 'GT'.
      l_tcode = 'MIGO_TR'.
    WHEN OTHERS.
      CLEAR l_tcode.
      EXIT.
  ENDCASE.
* check if opt. archiving is activ for current transaction
* look in buffer
  READ TABLE pt_archive_buffer INTO ls_archive_buffer
                             WITH KEY tcode = l_tcode.
  IF sy-subrc = 0.
    e_xarch = ls_archive_buffer-xarch.
  ELSE.
*   look in database
    CLEAR ls_archive_buffer.
    SELECT SINGLE tcode xarch FROM  t158
                              INTO  ls_archive_buffer
                              WHERE tcode = l_tcode.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
*   insert in buffer
    INSERT ls_archive_buffer INTO TABLE pt_archive_buffer.
    e_xarch = ls_archive_buffer-xarch.
  ENDIF.

ENDMETHOD.

* 719669_v
***********************************************************************
* Method  order_type_get
***********************************************************************
* reads aufk for a given order and stores the order type (autyp)
* The roder type is needed for the ATP call (ATPCSX-delkzord)
***********************************************************************
METHOD order_type_get.
  data: l_autyp type AUFTYP,
        ls_buffer type pty_order_type_buffer.
  clear e_delkzord.

  read table pt_order_type_buffer into ls_buffer
                                  with key aufnr = i_aufnr.

  if sy-subrc is initial.
    l_autyp = ls_buffer-autyp.
  else.
    select single aufnr autyp
                  from AUFK
                  into corresponding fields of ls_buffer
                  where aufnr = i_aufnr.
    if sy-subrc is initial.
      append ls_buffer to pt_order_type_buffer.
      l_autyp = ls_buffer-autyp.
    else.
      clear l_autyp.
    endif.
  endif.

  IF l_autyp = '30'.             "Maintenance orders
    e_delkzord = 'IH'.
  ELSEIF l_autyp = '20'.         "Network orders
    e_delkzord = 'NE'.
  ELSE.
    e_delkzord = 'FE'.           "process/production orders and default
  ENDIF.
ENDMETHOD.
* 719669_^