*&---------------------------------------------------------------------*
*&  Include LMIGOKP5  Purchase order                                   *
*&---------------------------------------------------------------------*

************************************************************************
* Read the data from a purchase order into the tables T_POITEM,
* S_POHEAD
************************************************************************
METHOD purchase_order_st_fill_data.
  DATA: l_move_next     TYPE bwart,
        ls_st_poitem    TYPE bbefu,
        ls_goitem       TYPE goitem,
        ls_got156       TYPE got156,
        ls_migo_t156    TYPE migo_t156,
        lt_prefetch02 TYPE ty_t_prefetch02,
        lt_prefetch03 TYPE ty_t_prefetch03,
        ls_prefetch02 TYPE ty_s_prefetch02,
        ls_prefetch03 TYPE ty_s_prefetch03,
        l_no_take_over TYPE sysubrc.                          "<LG>

  LOOP AT it_st_poitem INTO ls_st_poitem
       WHERE NOT matnr IS INITIAL.
    MOVE-CORRESPONDING ls_st_poitem TO ls_prefetch02.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    MOVE-CORRESPONDING ls_st_poitem TO ls_prefetch03.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
  ENDLOOP.
  CALL METHOD material_prefetch_read
       EXPORTING it_prefetch02 = lt_prefetch02
                 it_prefetch03 = lt_prefetch03.
* Send the data from LT_ST_POITEM to ls_goitem
  LOOP AT it_st_poitem INTO ls_st_poitem.
    CHECK ls_st_poitem-loekz IS INITIAL.
*   Read movement type data
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING  i_move       = s_defaults-bwart
      IMPORTING  e_got156     = ls_got156
                 es_migo_t156 = ls_migo_t156
      EXCEPTIONS OTHERS       = 1.
    CLEAR ls_goitem.
    CLEAR l_no_take_over.                                    "<LG>
    MOVE-CORRESPONDING ls_got156 TO ls_goitem.
    MOVE-CORRESPONDING ls_migo_t156 TO ls_goitem.
    CALL METHOD purchase_order_fill_goitem
         EXPORTING i_transfer      = abap_true
                   is_st_poitem    = ls_st_poitem
                   is_goitem       = ls_goitem
                   it_pofreight    = it_pofreight
         IMPORTING es_goitem       = ls_goitem
         EXCEPTIONS no_take_over   = 1.
*   if trouble with actual po item (e.g. tied empty) -> skip it; <LG>
    l_no_take_over = sy-subrc.
*   Default values
    CALL METHOD defaults_merge CHANGING cs_goitem = ls_goitem.
    ls_goitem-matnr = ls_st_poitem-ummat.
    ls_goitem-bumrz = ls_st_poitem-umrez.
    ls_goitem-bumrn = ls_st_poitem-umren.
*   Propose quantity for 351 (shkzg = h)
    IF ls_goitem-shkzg = h.
*     ls_goitem-erfmg is set from fill_goitem (bbefu-erfmg) and
*     is the ordered quantity
      ls_goitem-erfmg = ls_goitem-erfmg - ls_st_poitem-wamng.
    ELSE.
      ls_goitem-erfmg = ls_st_poitem-wamng - ls_st_poitem-wemng.
    ENDIF.
    IF ls_goitem-erfmg < 0.
      CLEAR ls_goitem-erfmg.
    ENDIF.
ENHANCEMENT-POINT LMIGOKP5_01 SPOTS ES_SAPLMIGO.
*   Take the item, if the quantity is set or also items with
*   no quantity are to be proposed.
ENHANCEMENT-SECTION     LMIGOKP5_02 SPOTS ES_SAPLMIGO.
    CHECK ls_goitem-erfmg <> 0 OR
          s_defaults-propose_all_items = abap_true.
END-ENHANCEMENT-SECTION.
*   posting a tied empty without full product doesn't make sense; <LG>
    IF NOT l_no_take_over IS INITIAL.
      def_msg_add oref_doc_log e 'M7' '350'
                          ls_st_poitem-ebeln
                          ls_st_poitem-ebelp
                          space space.
      CONTINUE.
    ENDIF.
    CALL METHOD line_modify
         EXPORTING i_line            = 0
                   i_authority_check = abap_true
                   i_status_delayed  = abap_true
         CHANGING cs_goitem          = ls_goitem.
ENHANCEMENT-POINT LMIGOKP5_03 SPOTS ES_SAPLMIGO.
  ENDLOOP.
  CALL METHOD status_derive.
ENDMETHOD.