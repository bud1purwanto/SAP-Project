*----------------------------------------------------------------------*
*                        INCLUDE LMIGOKGE
*
* additional methods for tied empties handling when preparing
* goods movement
*----------------------------------------------------------------------*

************************************************************************
*                               <LG>
* the actual goitem-line is a full product with an empties bom
* following; memorize the component factors of its bom
*
* input:
*     is_goitem_full_product : actual full product
*
* changing:
*     ct_slcomp : collective table of empties boms; every full product
*                 writes its bom into this table so that we need to read
*                 every bom just once from the database during
*                 goods_movement_fill;
************************************************************************
METHOD goods_movement_memorize_fp.

  DATA: ls_slcomp TYPE ty_s_slcomp,
        lt_slcomp TYPE ty_t_slcomp.

* get empties bom to actual full product
  CALL METHOD bom_empties_read
    EXPORTING is_goitem_full_product = is_goitem_full_product
    IMPORTING et_slcomp              = lt_slcomp
    EXCEPTIONS not_found = 01.
* if bom could be found -> append to collective bom table
  IF sy-subrc = 0.
    INSERT LINES OF lt_slcomp INTO TABLE ct_slcomp.
  ENDIF.

ENDMETHOD.

************************************************************************
*                               <LG>
* before posting a tied empty the changes done with the full product
* must be done with the empty accordingly (e.g. erfmg, lgort ...)
*
* import:
*     it_imseg : imseg-table; this is needed to get line index of
*                full product in goods_mvt_full_data_mix_in
*
* export:
*     es_goitem_full : corresponding full product to the actual tied
*                      empty; this is needed just in case of an error
*                      message via goods_movement_error_empties
*
* changing:
*     ct_slcomp :  collective empties bom; this table should contain the
*                  bom factor of the actual tied empty
*     cs_goitem_empty : actual tied empty which has to be adjusted
*     i_refix : (reference) index of the full product in imseg-table
************************************************************************
METHOD goods_movement_adjust_tied_ety.

  DATA: ls_goitem_full       TYPE ty_s_goitem,
        ls_slcomp            TYPE ty_s_slcomp.

* get the corresponding full product
  READ TABLE pt_goitem INTO ls_goitem_full
             WITH TABLE KEY global_counter = cs_goitem_empty-parent.
  IF sy-subrc <> 0.
* full product couldn't be found -> stop processing empty
    RAISE fp_not_found.
  ENDIF.
  MOVE ls_goitem_full TO es_goitem_full.
* get bom factor for actual empty
  CALL METHOD goods_mvmt_empty_factor_read
    EXPORTING is_goitem_empty   = cs_goitem_empty
              is_goitem_full    = ls_goitem_full
    IMPORTING es_slcomp         = ls_slcomp
    CHANGING  ct_slcomp         = ct_slcomp
    EXCEPTIONS not_found = 01.
*
  IF sy-subrc <> 0.
* bom entry for actual empty cannot be found -> stop processing empty
    RAISE bom_not_found.
  ENDIF.
* mix in 'master data' from full product
  CALL METHOD goods_mvmt_full_data_mix_in
    EXPORTING  is_goitem_full  = ls_goitem_full
               is_slcomp       = ls_slcomp
               it_imseg        = it_imseg
    CHANGING   cs_goitem_empty = cs_goitem_empty
               i_refix         = i_refix.

ENDMETHOD.

************************************************************************
*                               <LG>
* get bom entry for the actual empty from collective bom table; if
* not found try to get it via full product and mgw0_..
*
* input:
*     is_goitem_empty : actual tied empty
*     is_goitem_full : corresponding full product to the actual tied
*                      empty
*
* exporting:
*     es_slcomp : the line of empties bom which contains the bom factor
*                 of the actual tied empty
*
* changing:
*     ct_slcomp : collective empties bom table; every full product
*                 writes its bom into this table so that we need to read
*                 every bom just once from the database;
*                 if the full product's bom has not been appended yet
*                 -> do it here
************************************************************************
METHOD goods_mvmt_empty_factor_read.

  CLEAR es_slcomp.
* try to get bom factor for the empty from collective bom table
  READ TABLE ct_slcomp INTO es_slcomp
       WITH TABLE KEY global_counter = is_goitem_empty-parent
                      idnrk          = is_goitem_empty-matnr.
  IF sy-subrc <> 0.
* empties bom of full product is not in collective bom table yet ->
* try to get it in
    CALL METHOD goods_movement_memorize_fp
      EXPORTING is_goitem_full_product = is_goitem_full
      CHANGING  ct_slcomp              = ct_slcomp.
* try again to get bom factor
    READ TABLE ct_slcomp INTO es_slcomp
         WITH TABLE KEY global_counter = is_goitem_empty-parent
                        idnrk          = is_goitem_empty-matnr.
    IF sy-subrc <> 0.
* attempt to get empties bom of full product was not successful
      RAISE not_found.
    ENDIF.
  ENDIF.

ENDMETHOD.

************************************************************************
*                               <LG>
* take over specific data of full product into data of tied empty;
* get sure that no individual data of the tied empty gets lost by that
*
* input:
*     is_goitem_full : corresponding full product to the actual tied
*                      empty
*     is_slcomp      : the line of empties bom which contains the bom
*                      factor for the actual tied empty
*     it_imseg       : imseg-table; this is needed to get the index of
*                      the corresponding full product entry
*
* changing:
*     cs_goitem_empty : actual tied empty which has to be adjusted
*     i_refix : (reference) index of the full product in imseg-table
************************************************************************
METHOD goods_mvmt_full_data_mix_in.

  DATA: ls_imseg             TYPE ty_s_imseg.
* copy certain data from full product to tied empty
  CALL METHOD full_product_data_copy
    EXPORTING is_goitem_full   = is_goitem_full
    CHANGING  cs_goitem_empty  = cs_goitem_empty.
* calculate quantities
  CLEAR cs_goitem_empty-menge.
  cs_goitem_empty-erfmg = is_goitem_full-erfmg * is_slcomp-menge.
  cs_goitem_empty-lsmng = is_goitem_full-lsmng * is_slcomp-menge.
  CALL METHOD unit_conversion CHANGING cs_goitem = cs_goitem_empty.
* get index of full product and assign it to refix of tied empty
  READ TABLE it_imseg INTO ls_imseg
      WITH KEY global_counter = cs_goitem_empty-parent.
  IF sy-subrc IS INITIAL.
    i_refix = sy-tabix.
  ENDIF.

ENDMETHOD.

************************************************************************
*                               <LG>
* process error output into log
*
* input:
*     i_subrc : return value of method goods_movement_adjust_tied_ety
*     is_goitem_empty : tied empty which has actually been tried to
*                       process and failed
*     is_goitem_full_head : corresponding full product to the actual
*                           tied empty
************************************************************************
METHOD goods_movement_error_empties.

  IF i_subrc = 01.
* full product not found
    CALL METHOD oref_log->message_add
       EXPORTING
            i_msgty = e
            i_msgid = 'MIGO'
            i_msgno = '005'
            i_msgv1 = is_goitem_empty-matnr
            i_msgv2 = is_goitem_empty-parent.
  ELSEIF i_subrc = 02.
* empties bom not found
    CALL METHOD oref_log->message_add
       EXPORTING
            i_msgty = e
            i_msgid = 'MIGO'
            i_msgno = '006'
            i_msgv1 = is_goitem_empty-matnr
            i_msgv2 = is_goitem_full_head-matnr
            i_msgv3 = is_goitem_full_head-erfme.
  ENDIF.

ENDMETHOD.

************************************************************************
*                               <LG>
* we are about to post the goods movement; if there are still some full
* products with empties bom missing -> explode the empties bom here
* because mb_create_goods_movement cannot explode it itself
************************************************************************
METHOD goods_mvmt_empties_boms_check.

  DATA: l_tabix  TYPE sytabix.
  FIELD-SYMBOLS <goitem_full> TYPE goitem.

* select all full products
  LOOP AT pt_goitem ASSIGNING <goitem_full> WHERE xvgtype = p.
* look for a child
    l_tabix = sy-tabix.
    READ TABLE pt_goitem WITH KEY parent = <goitem_full>-global_counter
      TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
* no empties bom -> explode it
      CALL METHOD line_expand_full_product
        EXPORTING i_tabix     = l_tabix
                  i_invisible = x.
    ELSE.
* full product has an empties bom -> set hpos_wws (or upvor respectively
      <goitem_full>-hpos_wws = c_upvor_vg.
    ENDIF.
  ENDLOOP.

ENDMETHOD.

************************************************************************
*                               <LG>
* Empties are expanded and parent item is changed => modify empties
************************************************************************
METHOD vg_line_modify.
  DATA: ls_change_children TYPE ty_s_change_children,
        ls_goitem_comp     TYPE goitem,
        ls_goitem_top      TYPE goitem,
        lt_slcomp       TYPE ty_t_slcomp,            "table of empty bom
        ls_slcomp       TYPE ty_s_slcomp.
.
  CHECK cs_goitem <> is_old_goitem.
  CASE cs_goitem-xvgtype.
    WHEN p.
      LOOP AT pt_goitem INTO ls_goitem_comp
         WHERE parent  = cs_goitem-global_counter
         AND   xvgtype = c.
        READ TABLE pt_change_children
           WITH KEY glc = cs_goitem-global_counter
           TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          ls_change_children-glc       = ls_goitem_comp-global_counter.
          ls_change_children-fieldname = lcl_migo_cursor=>field.
          CHECK NOT ls_change_children-fieldname IS INITIAL.
          APPEND ls_change_children TO pt_change_children.
        ENDIF.
      ENDLOOP.
    WHEN c.
      READ TABLE pt_goitem INTO ls_goitem_top
        WITH KEY global_counter = cs_goitem-parent.
      CALL METHOD bom_empties_read
        EXPORTING
          is_goitem_full_product = ls_goitem_top
        IMPORTING
          et_slcomp              = lt_slcomp
        EXCEPTIONS
          not_found              = 01.
      CHECK sy-subrc = 0.
* process each empty
      LOOP AT lt_slcomp INTO ls_slcomp.
        READ TABLE pt_goitem INTO ls_goitem_comp
          WITH KEY parent         = ls_slcomp-global_counter
                   matnr          = ls_slcomp-idnrk
                   global_counter = cs_goitem-global_counter.
        CHECK sy-subrc = 0.
* copy certain data from full product to tied empty
        CALL METHOD full_product_data_copy
          EXPORTING
            is_goitem_full  = ls_goitem_top
          CHANGING
            cs_goitem_empty = ls_goitem_comp.
* Line is child of full product
        CLEAR: ls_goitem_comp-umrez,
               ls_goitem_comp-umren.
        ls_goitem_comp-matnr = ls_slcomp-idnrk.
        ls_goitem_comp-erfmg = ls_goitem_top-erfmg * ls_slcomp-menge .
        ls_goitem_comp-erfme = ls_slcomp-meins.
        CALL METHOD unit_conversion CHANGING cs_goitem = ls_goitem_comp.
        cs_goitem = ls_goitem_comp.
      ENDLOOP.
  ENDCASE.
ENDMETHOD.

************************************************************* "n1397313
*                               <LG>                          "n1397313
* get global table pt_goitems with items of the MM document   "n1397313
* for further checks                                          "n1397313
*                                                             "n1397313
* exporting:                                                  "n1397313
*     e_gt_goitem  :  items/positions of material document    "n1397313
************************************************************* "n1397313
METHOD get_pt_goitem.                                         "n1397313
       e_pt_goitem[] = pt_goitem[].                           "n1397313
ENDMETHOD.                                                    "n1397313