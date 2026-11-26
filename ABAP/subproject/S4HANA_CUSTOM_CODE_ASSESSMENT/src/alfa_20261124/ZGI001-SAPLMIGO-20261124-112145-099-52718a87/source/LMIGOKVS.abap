*&---------------------------------------------------------------------*
*&  Include           LMIGOKVS
*&  Process value added services
*&---------------------------------------------------------------------*
METHOD purchase_order_fill_vas.
* Read value added services from PO to modify goitem
  FIELD-SYMBOLS: <ls_goitem_top>   TYPE goitem.
  DATA: lt_wtadab    TYPE STANDARD TABLE OF frm_wtadab_extended_t
                     WITH DEFAULT KEY,
        ls_wtadab    TYPE frm_wtadab_extended_t,
        lt_goitem    TYPE TABLE OF goitem,
        l_posnr      TYPE posnr.

* IF upvor cannot be derived exactly in the PO => upvor = x,
* check if upvor could be '9' according to sub-item's uptyp
  IF is_poitem-upvor = x.
    READ TABLE  it_poitem WITH KEY uptyp = '9'
                                   ebeln = is_poitem-ebeln
                                   uebpo = is_poitem-ebelp
                                   lfbnr = cs_goitem-lfbnr
                                   TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      cs_goitem-xvastype = 'P'.
    ENDIF.
  ENDIF.
  IF is_poitem-upvor = '9'.
    cs_goitem-xvastype = 'P'.
  ELSEIF is_poitem-uptyp = '9'.
*   This has to be done because the same PO can be applied many times
    lt_goitem[] = pt_goitem[].
    SORT lt_goitem BY global_counter DESCENDING.
    READ TABLE lt_goitem ASSIGNING <ls_goitem_top>
       WITH KEY xvastype = p
                 ebeln   = cs_goitem-ebeln
                 ebelp   = is_poitem-uebpo
                 lfbnr   = cs_goitem-lfbnr.
    IF sy-subrc <> 0.
*     We do not need the SLS sub-item if no header could be derived
      CLEAR: cs_goitem.
      EXIT.
    ENDIF.
*   Derive service data of the sub-item
    MOVE cs_goitem-ebelp TO l_posnr.
    CALL FUNCTION 'W_VAS_SERVICES_GET_SINGLE_DOC'
      EXPORTING
          i_doc_nbr         = cs_goitem-ebeln           "#EC DOM_EQUAL
          i_doc_item        = l_posnr                   "#EC DOM_EQUAL
          i_application     = '02'
          i_sirel           = abap_true
      TABLES
          et_wtadab         = lt_wtadab
      EXCEPTIONS
          no_services_found = 1
          others            = 2.
    IF sy-subrc = 0.
      LOOP AT lt_wtadab INTO ls_wtadab.
        cs_goitem-frm_service_data = ls_wtadab-addifrmcust.
        EXIT.
      ENDLOOP.
    ENDIF.
*   organizational data for sub-item
    cs_goitem-parent     = <ls_goitem_top>-global_counter.
    cs_goitem-xvastype   = 'C'.
    cs_goitem-invisible  = abap_true.
    cs_goitem-depth      = <ls_goitem_top>-depth + 1.
    cs_goitem-zeile      = <ls_goitem_top>-zeile.
    CLEAR: cs_goitem-global_counter.
  ENDIF.
ENDMETHOD.                    "purchase_order_fill_vas


METHOD vas_relevance_check.
* The function 'W_VAS_GR_CHECK' is called to get data about
* vas-relevance
  DATA: lt_message_tab TYPE frm_message_tab_t,
        ls_message     TYPE LINE OF frm_message_tab_t,
        ls_mseg        TYPE mseg,
        ls_mkpf        TYPE mkpf.

  MOVE-CORRESPONDING cs_goitem TO ls_mseg.
  MOVE-CORRESPONDING ps_gohead TO ls_mkpf.
  CALL FUNCTION 'W_VAS_GR_CHECK'
       EXPORTING
            i_mkpf                = ls_mkpf
            i_mseg                = ls_mseg
       TABLES
            et_messagelog         = lt_message_tab
       EXCEPTIONS
            do_not_accept_gr_item = 1
            interface_error       = 2
            MESSAGE_OUTPUT        = 3
            OTHERS                = 4.
  IF sy-subrc <> 0.
* Add messages to log
    CALL METHOD oref_log->context_set
      EXPORTING
        i_global_counter = cs_goitem-global_counter.
    LOOP AT lt_message_tab INTO ls_message.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = w
          i_msgid = ls_message-msgid
          i_msgno = ls_message-msgno
          i_msgv1 = ls_message-msgv1
          i_msgv2 = ls_message-msgv2
          i_msgv3 = ls_message-msgv3
          i_msgv4 = ls_message-msgv4.
    ENDLOOP.
    CALL METHOD oref_log->message_exist_single
      EXPORTING
        i_global_counter = cs_goitem-global_counter
      IMPORTING
        e_loglevel       = cs_goitem-loglevel.
  ENDIF.
ENDMETHOD.                    "vas_relevance_check


METHOD vas_line_modify.
* The unit of measure of the components has to be equal to the unit of
* measure of the parent item
  DATA: ls_goitem_top    TYPE goitem,
        ls_goitem_comp   TYPE goitem,
        l_tabix          TYPE sytabix.

  CHECK is_new_goitem-xvastype = p.
  IF is_new_goitem-erfme <> is_old_goitem-erfme.
    LOOP AT pt_goitem INTO ls_goitem_comp
      WHERE parent   = is_new_goitem-global_counter
      AND   xvastype = c.
      ls_goitem_comp-erfme = is_new_goitem-erfme.
      CLEAR ls_goitem_comp-erfmg.
      CALL FUNCTION 'MB_UNIT_CONVERSION'
        EXPORTING
          matnr                = ls_goitem_comp-matnr
          meins                = ls_goitem_comp-meins
          erfme                = ls_goitem_comp-erfme
          menge                = ls_goitem_comp-menge
          erfmg                = ls_goitem_comp-erfmg
        IMPORTING
          o_menge              = ls_goitem_comp-menge
          o_erfmg              = ls_goitem_comp-erfmg
        EXCEPTIONS
          conversion_not_found = 4.
      CHECK sy-subrc IS INITIAL.
      MODIFY TABLE pt_goitem FROM ls_goitem_comp
        TRANSPORTING erfmg erfme menge meins.
    ENDLOOP.
  ENDIF.
* Quantity of the parent item has to be equal to the total quantity of
* the sub-items
  CLEAR: ls_goitem_comp, ls_goitem_top.
  LOOP AT pt_goitem INTO ls_goitem_comp
    WHERE parent = is_new_goitem-global_counter
    AND xvastype = c.
    ls_goitem_top-erfmg = ls_goitem_top-erfmg
                          + ls_goitem_comp-erfmg.
  ENDLOOP.
  IF is_new_goitem-erfme = is_old_goitem-erfme AND
     ls_goitem_top-erfmg <> is_new_goitem-erfmg.
* Message M7 338 "Quantities of the sub-items are different from qty of
* the main item"
    MESSAGE i338(M7).
    l_tabix = is_new_goitem-global_counter.
    CALL METHOD line_expand( l_tabix ).
  ENDIF.
ENDMETHOD.                         " vas_line_modify