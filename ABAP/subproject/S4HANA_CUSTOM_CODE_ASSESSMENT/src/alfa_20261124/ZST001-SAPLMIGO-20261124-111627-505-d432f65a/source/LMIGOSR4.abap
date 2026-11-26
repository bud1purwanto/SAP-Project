*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR4                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Send the popup to enter search criteria for purchase orders
************************************************************************
METHOD purchase_order_search_popup.
  gosearch_po-werks =                                            "411519
    lcl_migo_globals=>kernel->s_defaults-werks.                  "411519
  gosearch_po-werksname =                                        "411519
    lcl_migo_buffer=>plant_name_get( gosearch_po-werks ).        "411519
  CALL SCREEN 3000 STARTING AT 5 1.
  IF sy-ucomm = 'OK_START'.
    CALL METHOD purchase_order_search.
  ENDIF.
ENDMETHOD.

************************************************************************
* Search for purchase orders.
* Uses a function module from MM-PUR.
* This method has been completely renewed with note 411519.
************************************************************************
METHOD purchase_order_search.
  TYPE-POOLS:
    rsds,
    rsfs.
  DATA:
*   Creation of the select-options
    ls_dynsel        TYPE rsds_type,
    ls_range         TYPE rsds_range,
    ls_frange        TYPE rsds_frange,
    ls_selopt        TYPE rsdsselopt,
    l_selpa          TYPE selpa,
    ls_ekko          TYPE ekko,
    ls_ekpo          TYPE ekpo,
    ls_eket          TYPE eket,
*   Interface to MM-PUR function module
    lt_ekko          LIKE STANDARD TABLE OF ls_ekko,
    lt_ekpo          LIKE STANDARD TABLE OF ls_ekpo,
    lt_eket          LIKE STANDARD TABLE OF ls_eket,
*   Sorted tables for non-cubic access time in nested loop
    lt_ekko_sort     LIKE SORTED TABLE OF ls_ekko
                          WITH UNIQUE KEY ebeln,
    lt_ekpo_sort     LIKE SORTED TABLE OF ls_ekpo
                          WITH UNIQUE KEY ebeln ebelp,
    lt_eket_sort     LIKE SORTED TABLE OF ls_eket
                          WITH UNIQUE KEY ebeln ebelp etenr,
    ls_list          TYPE ty_s_purchase_order,
    ls_lfa1          TYPE lfa1,
    lt_list          TYPE ty_t_purchase_order,
    lt_list_send     TYPE ty_t_purchase_order,
    ls_message       TYPE lif_migo_frame=>ty_s_message.
  FIELD-SYMBOLS:
    <ls_list>        TYPE ty_s_purchase_order.

* Macro to fill a single value into a line of FRANGE
  DEFINE def_add_field.
    if not &1 is initial.
      clear ls_frange.
      ls_frange-fieldname = &2.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      ls_selopt-low    = &1.
      append ls_selopt to ls_frange-selopt_t.
      append ls_frange to ls_range-frange_t.
    endif.
  END-OF-DEFINITION.
* Macro to add the data collected so far to a table section
  DEFINE def_add_table.
    if not ls_range-frange_t is initial.
      ls_range-tablename = &1.
      append ls_range to ls_dynsel-trange.
    endif.
    clear ls_range.
  END-OF-DEFINITION.

* Selection parameter according to movement type
  SELECT SINGLE selpa INTO (l_selpa) FROM t156
         WHERE bwart = lcl_migo_globals=>kernel->s_defaults-bwart.
  def_add_field l_selpa 'SELPA'.
  def_add_table 'T160T'.
* Fields from EKKO
  def_add_field gosearch_po-lifnr 'LIFNR'.
  def_add_field gosearch_po-reswk 'RESWK'.
* BSTYP must be filled manually because it needs two values
  CLEAR ls_frange.
  ls_frange-fieldname = 'BSTYP'.
  ls_selopt-sign   = 'I'.
  ls_selopt-option = 'EQ'.
  ls_selopt-low    = 'F'.
  APPEND ls_selopt TO ls_frange-selopt_t.
  ls_selopt-low    = 'L'.
  APPEND ls_selopt TO ls_frange-selopt_t.
  APPEND ls_frange TO ls_range-frange_t.
  def_add_table 'EKKO'.
* Fields from EKPO
  def_add_field gosearch_po-matnr 'MATNR'.
  def_add_field gosearch_po-werks 'WERKS'.
  def_add_field gosearch_po-ean11 'EAN11'.
  def_add_field gosearch_po-idnlf 'IDNLF'.
  def_add_table 'EKPO'.
* Value for EKET-EINDT depending on what is filled
* (simulation of SELECT-OPTIONS).
  IF NOT gosearch_po-eindt_from IS INITIAL OR
     NOT gosearch_po-eindt_to   IS INITIAL.
    CLEAR ls_frange.
    ls_frange-fieldname = 'EINDT'.
    ls_selopt-sign = 'I'.
    ls_selopt-low  = gosearch_po-eindt_from.
    IF gosearch_po-eindt_to IS INITIAL.
      ls_selopt-option = 'EQ'.
    ELSE.
      ls_selopt-option = 'BT'.
      ls_selopt-high   = gosearch_po-eindt_to.
    ENDIF.
    APPEND ls_selopt TO ls_frange-selopt_t.
    APPEND ls_frange TO ls_range-frange_t.
  ENDIF.
  def_add_table 'EKET'.

* Execution of search. This function module is the back-office
* of logical database MEPOLDB and is released to be used
* directly in MIGO. See internal memo in note 411519.
  CLEAR sy-msgty.
  CALL FUNCTION 'ME_READ_EKKO_MULTIPLE'
    EXPORTING
      i_dynsel                  = ls_dynsel
*     I_DYNFIE...is not used because the database select in the function
*     does not use it anyway and filling it is cumbersome.
      i_selection_limit         = gosearch_po-qcount
    TABLES
      te_ekko                   = lt_ekko
      te_ekpo                   = lt_ekpo
      te_eket                   = lt_eket
    EXCEPTIONS
      wrong_vornr_nplnr         = 1
      wrong_selpa               = 2
      limit_ds                  = 3
      no_trange                 = 4
      nothing_selected          = 5
      uncomplete_selected       = 6
      OTHERS                    = 7.
* Let's hope that MM-PUR sends a message for each eception.
* The check for SY-MSGTY at least prevents short-dumps.
  IF sy-subrc <> 0 AND NOT sy-msgty IS INITIAL.
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Copy data to sorted tables for the nested loop
  lt_ekko_sort = lt_ekko.
  lt_ekpo_sort = lt_ekpo.
  lt_eket_sort = lt_eket.

* Extract relevant data for MIGO. Performance ensured by SORTED tables
  LOOP AT lt_ekko_sort INTO ls_ekko.
    ls_list-ebeln = ls_ekko-ebeln.
    ls_list-lifnr = ls_ekko-lifnr.
    IF ls_lfa1-lifnr <> ls_list-lifnr.
      CLEAR ls_lfa1.
      ls_lfa1-lifnr = ls_list-lifnr.
      SELECT SINGLE name1 INTO (ls_lfa1-name1) FROM lfa1
                    WHERE lifnr = ls_list-lifnr.
    ENDIF.
    ls_list-name1 = ls_lfa1-name1.
    ls_list-reswk = ls_ekko-reswk.
    CLEAR ls_list-namew.
    SELECT SINGLE name1 INTO (ls_list-namew) FROM t001w
                  WHERE werks = ls_list-reswk.
    ls_list-ernam = ls_ekko-ernam.
    LOOP AT lt_ekpo_sort INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
      ls_list-ebelp = ls_ekpo-ebelp.
      ls_list-matnr = ls_ekpo-matnr.
      ls_list-maktx = ls_ekpo-txz01.           "No MOVE-CORRESPONDING
      ls_list-meins = ls_ekpo-meins.
      ls_list-idnlf = ls_ekpo-idnlf.
      ls_list-ean11 = ls_ekpo-ean11.
      ls_list-werks = ls_ekpo-werks.
      CLEAR ls_list-werks_name.
      SELECT SINGLE name1 INTO (ls_list-werks_name) FROM t001w
                    WHERE werks = ls_list-werks.
      ls_list-lgort = ls_ekpo-lgort.
      CLEAR ls_list-lgobe.
      SELECT SINGLE lgobe INTO (ls_list-lgobe) FROM t001l
                    WHERE werks = ls_list-werks
                      AND lgort = ls_list-lgort.
      ls_list-matkl = ls_ekpo-matkl.
      CLEAR ls_list-wgbez.
      SELECT SINGLE wgbez INTO (ls_list-wgbez) FROM t023t
                    WHERE matkl = ls_list-matkl
                      AND spras = sy-langu.
      ls_list-knttp = ls_ekpo-knttp.
      CLEAR ls_list-knttx.
      SELECT SINGLE knttx INTO (ls_list-knttx) FROM t163i
                    WHERE knttp = ls_list-knttp
                      AND spras = sy-langu.
      LOOP AT lt_eket_sort INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                          AND ebelp = ls_ekpo-ebelp.
        ls_list-eindt = ls_eket-eindt.
        ls_list-menge = ls_eket-menge.       "Not EKPO-MENGE!!!
        ls_list-wemng = ls_eket-wemng.
        APPEND ls_list TO lt_list.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

* MM-IM should not show multiple lines per PO. Therefore, in case
* of scheduling agreement (with additional key ETENR) the data
* returned need to be collected.
* Strategy: Sum up quantities and choose the EINDT of the earliest
* open item.
  SORT lt_list BY ebeln ebelp eindt.
  LOOP AT lt_list INTO ls_list.
    READ TABLE lt_list_send ASSIGNING <ls_list>
               WITH TABLE KEY ebeln = ls_list-ebeln
                              ebelp = ls_list-ebelp.
    IF sy-subrc <> 0.
      IF ls_list-wemng >= ls_list-menge.
        CLEAR ls_list-eindt.
      ENDIF.
      INSERT ls_list INTO TABLE lt_list_send.
    ELSE.
      ADD ls_list-wemng TO <ls_list>-wemng.
      ADD ls_list-menge TO <ls_list>-menge.
      IF <ls_list>-eindt IS INITIAL AND
         ls_list-wemng < ls_list-menge.
        <ls_list>-eindt = ls_list-eindt.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Send the searchresult (may be empty)
  ls_message-data1 = 'R01'.
  GET REFERENCE OF lt_list_send INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'NEW_SEARCHRESULT'
      is_message    = ls_message.

ENDMETHOD.