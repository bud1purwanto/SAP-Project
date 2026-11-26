*&---------------------------------------------------------------------*
*&  Include           LMIGOKST
*&  Process structured articles
*&---------------------------------------------------------------------*

METHOD line_expand_structured_article.

  DATA:
        ls_gohead       TYPE gohead,
        ls_goitem_top   TYPE goitem,
        lv_tabix        TYPE sytabix.

* Read the line to be expanded
  CALL METHOD line_get(
    EXPORTING
      i_tabix   = i_tabix
    IMPORTING
      es_goitem = ls_goitem_top ).

* no explosion if stock type is <> unrestricted use
  if ls_goitem_top-migo_insmk <> abap_false.
    message s023(migo).
  endif.
*s_action-migo_mode = 'GT' Umlagerung.

* Read the header data
  CALL METHOD header_get(
    IMPORTING
      e_gohead = ls_gohead ).

  CALL METHOD st_explode_bom(
    EXPORTING
      is_goitem_st = ls_goitem_top
      i_date       = ls_gohead-budat
      i_tabix      = i_tabix
      i_transfer   = abap_false
    IMPORTING
      e_tabix      = lv_tabix ).

*structured articles will only be displayed in MIGO (except cancellation
*- but in this
*case the handling will be different) therfore it is not necessary to
*create the
*automatic lines for the transfer if display automatic lines has not
*been set
  IF NOT s_defaults-xauto_lines IS INITIAL.
    IF s_action-migo_mode = 'GT'.
      CALL METHOD st_explode_bom(
        EXPORTING
          is_goitem_st = ls_goitem_top
          i_date       = ls_gohead-budat
          i_tabix      = lv_tabix
          i_transfer   = abap_true
        IMPORTING
          e_tabix      = lv_tabix ).
    ENDIF.
  ENDIF.
  CALL METHOD status_derive( ).

ENDMETHOD.                    "line_expand_structured_article

*----------------------------------------------------------------------*
*     Adjust the quantity for the childrens of a structured article.
METHOD st_line_modify.
*i_adjust could get three values i(nvisible) v(isible) space.
  DATA:
    ls_change_children TYPE ty_s_change_children,
    ls_goitem_comp     TYPE goitem.

  IF (
      is_old_goitem-erfmg <> is_new_goitem-erfmg OR
      is_old_goitem-erfme <> is_new_goitem-erfme OR
      is_old_goitem-werks <> is_new_goitem-werks OR
      is_old_goitem-lgort <> is_new_goitem-lgort OR
      is_old_goitem-bwtar <> is_new_goitem-bwtar
      )                                          AND
      is_old_goitem-matnr = is_new_goitem-matnr.

*  CHECK is_new_goitem <> is_old_goitem.
    READ TABLE pt_goitem INTO ls_goitem_comp
         WITH KEY parent  = is_new_goitem-global_counter
                  xsttype = c.
    IF sy-subrc = 0.
      READ TABLE pt_change_children
           WITH KEY glc = is_new_goitem-global_counter
           TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        ls_change_children-glc       = ls_goitem_comp-global_counter.
        ls_change_children-fieldname = 'GOITEM-PARENT'.
        APPEND ls_change_children TO pt_change_children.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMETHOD.                    "st_line_modify


*----------------------------------------------------------------------*
METHOD st_explode_bom.

  DATA: lt_prefetch02   TYPE ty_t_prefetch02,
        ls_prefetch02   TYPE ty_s_prefetch02,
        lt_prefetch03   TYPE ty_t_prefetch03,
        ls_prefetch03   TYPE ty_s_prefetch03,
        ls_gohead       TYPE gohead,
        ls_goitem_top   TYPE goitem,
        ls_goitem_comp  TYPE goitem,
        ls_gobom        TYPE gobom,
        ls_mtcom        TYPE mtcom,
        ls_mtcor        TYPE mtcor,
        ls_mbefu        TYPE mbefu,
        l_kzbsf         TYPE kzbsf,
        l_current_tabix TYPE sytabix,
        lv_tabix        TYPE sytabix,
        lt_xstru        TYPE TABLE OF wsos_stuli,
        ls_xstru        TYPE wsos_stuli,
        lv_subrc        TYPE sysubrc,
        lv_fcode        TYPE fcode,
        lv_shkzg_item   TYPE goitem-shkzg,
        lv_shkzg_head   TYPE goitem-shkzg,
        lv_comp_bwart   TYPE goitem-bwart,
        lv_matnr        TYPE goitem-matnr,
        lv_werks        TYPE goitem-werks,
        lv_shkzg        TYPE goitem-shkzg,
        lv_lgort        TYPE goitem-lgort,
        lv_umlgo        TYPE goitem-umlgo,
        lv_lgobe        TYPE goitem-lgobe,
        lv_umlgobe      TYPE goitem-umlgobe,
        lv_umwrk        TYPE goitem-umwrk,
        lv_umname1      TYPE goitem-umname1,
        lv_bwtar        TYPE goitem-bwtar,
        ls_t156         TYPE got156,
        lr_retail_badi  TYPE REF TO if_ex_mb_me_csgmt_badi_sap.

  IF i_transfer = abap_true.
    lv_matnr = is_goitem_st-ummat.
    lv_werks = is_goitem_st-umwrk.
    lv_umwrk = is_goitem_st-werks.
    lv_lgort = is_goitem_st-umlgo.
    lv_lgobe = is_goitem_st-umlgobe.
    lv_umlgo = is_goitem_st-lgort.
    lv_bwtar = is_goitem_st-umbar.
    lv_umlgobe = is_goitem_st-lgobe.
    IF is_goitem_st-shkzg = s.
      lv_shkzg = h.
    ELSEIF is_goitem_st-shkzg = h.
      lv_shkzg = s.
    ENDIF.
  ELSE.
    lv_matnr = is_goitem_st-matnr.
    lv_werks = is_goitem_st-werks.
    lv_lgort = is_goitem_st-lgort.
    lv_umlgo = is_goitem_st-umlgo.
    lv_lgobe = is_goitem_st-lgobe.
    lv_bwtar = is_goitem_st-bwtar.
    lv_umlgobe = is_goitem_st-umlgobe.
    lv_umwrk   = is_goitem_st-umwrk.
    lv_umname1 = is_goitem_st-umname1.
    lv_shkzg   = is_goitem_st-shkzg.
  ENDIF.

  CALL FUNCTION 'MB_SHOW_MATERIAL_STRUCTURE'
    EXPORTING
      matbf   = lv_matnr
      werks   = lv_werks
      f_attyp = is_goitem_st-xsttype
      datab   = i_date
      datbi   = i_date
      f_menge = is_goitem_st-menge
      meins   = is_goitem_st-meins
      f_kzbwa = is_goitem_st-kzbwa
      f_bflme = space
    IMPORTING
      subrc   = lv_subrc
    TABLES
      xstru   = lt_xstru.

  IF lt_xstru IS INITIAL.
*   change the error message
    MESSAGE s023(migo).
    EXIT.
  ENDIF.

* prefetch material
  LOOP AT lt_xstru INTO ls_xstru.
    ls_prefetch02-matnr = ls_xstru-matnr.
    ls_prefetch02-werks = lv_werks.
    ls_prefetch02-lgort = lv_lgort.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    ls_prefetch03-matnr = ls_xstru-matnr.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
  ENDLOOP.
  CALL METHOD material_prefetch_read(
    EXPORTING
      it_prefetch02 = lt_prefetch02
      it_prefetch03 = lt_prefetch03 ).

  CALL METHOD lcl_migo_buffer=>move_type_get(
    EXPORTING
      i_move   = is_goitem_st-bwart
    IMPORTING
      e_got156 = ls_t156
    EXCEPTIONS
      OTHERS   = 1 ).

* components get same shkzg as the original parent
* lv_shkzg_item = exploded componets
* lv_shkzg_head = neg of parent
  IF ls_t156-kzbwa = 'SZ'.
    IF lv_shkzg = s.
      lv_shkzg_item = h.
    ELSE.
      lv_shkzg_item = s.
    ENDIF.
    lv_shkzg_head = lv_shkzg.
  ELSE.
    IF lv_shkzg = s.
      lv_shkzg_head = h.
    ELSE.
      lv_shkzg_head = s.
    ENDIF.
    lv_shkzg_item = lv_shkzg.
  ENDIF.

* determine the movement type for the components
  IF lv_shkzg_head = h.
    IF ls_t156-xstbw IS INITIAL.
      lv_fcode = 'MSTH'.
    ELSE.
      lv_fcode = 'MSSS'.
    ENDIF.
  ELSE.
    IF ls_t156-xstbw IS INITIAL.
      lv_fcode = 'MSTS'.
    ELSE.
      lv_fcode = 'MSSH'.
    ENDIF.
  ENDIF.
  CALL METHOD lcl_migo_buffer=>move_type_next_get(
    EXPORTING
      i_move      = space
      i_fcode     = lv_fcode
    RECEIVING
      e_move_next = lv_comp_bwart ).

*if retail consignment handling is active and sobkz = k replace the
*movement types
  IF lcl_migo_globals=>retail_consignment_active = abap_true.
    IF NOT lcl_migo_globals=>if_badi_retail_mb_me_csgmt IS INITIAL.
      lr_retail_badi = lcl_migo_globals=>if_badi_retail_mb_me_csgmt.

      CALL METHOD lr_retail_badi->wrf_get_csgmt_mvt_struct_art(
        EXPORTING
          i_sobkz       = is_goitem_st-sobkz
          i_xstbw       = ls_t156-xstbw
          i_shkzg       = lv_shkzg_head
        CHANGING
          x_bwart_t156n = lv_comp_bwart ).
    ENDIF.
  ENDIF.

* the 1st component is not derived from the structure - it is the parent
* material with opposite d/c indicator

* copy parent line to component
  CALL METHOD st_line_copy(
    EXPORTING
      is_goitem_head = is_goitem_st
      i_copydata     = p
    CHANGING
      cs_goitem_comp = ls_goitem_comp ).

  ls_goitem_comp-matnr   = lv_matnr.
  ls_goitem_comp-werks   = lv_werks.
  ls_goitem_comp-lgort   = lv_lgort.
  ls_goitem_comp-umlgo   = lv_umlgo.
  ls_goitem_comp-lgobe   = lv_lgobe.
  ls_goitem_comp-umlgobe = lv_umlgobe.
  ls_goitem_comp-umwrk   = lv_umwrk.
  ls_goitem_comp-umname1 = lv_umname1.
  ls_goitem_comp-shkzg   = lv_shkzg_head.
  ls_goitem_comp-bwart   = lv_comp_bwart.

  l_current_tabix = i_tabix.
  l_current_tabix = l_current_tabix + 1.

  CALL METHOD line_modify(
    EXPORTING
      i_tabix          = l_current_tabix
      i_insert         = abap_true
      i_status_delayed = abap_true
    CHANGING
      cs_goitem        = ls_goitem_comp ).

  LOOP AT lt_xstru INTO ls_xstru.

    CALL METHOD st_line_copy(
      EXPORTING
        is_goitem_head = is_goitem_st
        i_copydata     = c
      CHANGING
        cs_goitem_comp = ls_goitem_comp ).

    ls_goitem_comp-werks   = lv_werks.
    ls_goitem_comp-lgort   = lv_lgort.
    ls_goitem_comp-umlgo   = lv_umlgo.
    ls_goitem_comp-lgobe   = lv_lgobe.
    ls_goitem_comp-umlgobe = lv_umlgobe.
    ls_goitem_comp-umwrk   = lv_umwrk.
    ls_goitem_comp-umname1 = lv_umname1.
    ls_goitem_comp-shkzg   = lv_shkzg_item.
    ls_goitem_comp-bwart   = lv_comp_bwart.
    MOVE-CORRESPONDING ls_xstru TO ls_goitem_comp.
    l_current_tabix = l_current_tabix + 1.

    CALL METHOD line_modify(
      EXPORTING
        i_tabix          = l_current_tabix
        i_insert         = abap_true
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = ls_goitem_comp ).
  ENDLOOP.
  e_tabix = l_current_tabix.

ENDMETHOD.                    "st_explode_bom

*----------------------------------------------------------------------*
METHOD st_line_copy.
* exp is_goitem_head
* chg cs_goitem_comp
  CLEAR cs_goitem_comp.
  CASE i_copydata.
* copy the header to the corresponding
    WHEN p.
      cs_goitem_comp-charg = is_goitem_head-charg.
      cs_goitem_comp-lifnr = is_goitem_head-lifnr.
      cs_goitem_comp-erfme = is_goitem_head-erfme.
      cs_goitem_comp-erfmg = is_goitem_head-erfmg.
      cs_goitem_comp-bwtar = is_goitem_head-bwtar.
      cs_goitem_comp-take_it = is_goitem_head-take_it.
      cs_goitem_comp-xauto = 'S'.
*   Organizational data
      cs_goitem_comp-xsttype = c.      "Line is child of structured article

    WHEN c.
      cs_goitem_comp-take_it = is_goitem_head-take_it.
      cs_goitem_comp-xsttype = c.
      cs_goitem_comp-xauto = s.

  ENDCASE.

* this is needed in case retail-consigment is active
  IF lcl_migo_globals=>retail_consignment_active = abap_true.
    cs_goitem_comp-sobkz = is_goitem_head-sobkz.
    cs_goitem_comp-lifnr = is_goitem_head-lifnr.
    cs_goitem_comp-vendorname = is_goitem_head-vendorname.
  ENDIF.

*   Organizational data
  cs_goitem_comp-zeile  = is_goitem_head-zeile.
  cs_goitem_comp-parent = is_goitem_head-global_counter.
  cs_goitem_comp-depth  = is_goitem_head-depth + 1.

ENDMETHOD.                    "st_line_copy