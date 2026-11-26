*&---------------------------------------------------------------------*
*&  Include LMIGOKP7  Purchase order                                   *
*&---------------------------------------------------------------------*

************************************************************************
*                            <LG>
* Fill special data for full product (LSMEH) and/or tied empties (link
* to full product)
*
* input:
*     is_poitem   : actual tied empty line of the po
*     is_st_poitem: actual tied empty line of the stock transfer po
*     i_transfer  : flag which says whether stock transfer or normal po
* changing:
*     cs_goitem : actual full product or tied empty line in goitem
*                 scheme
************************************************************************
METHOD purchase_order_full_empty.

  DATA: ls_empties_poitem TYPE ty_s_empties_poitem.
* move po info into general structure
  IF i_transfer IS INITIAL.
    MOVE-CORRESPONDING is_poitem TO ls_empties_poitem.
  ELSE.
    MOVE-CORRESPONDING is_st_poitem TO ls_empties_poitem.
    MOVE is_st_poitem-erfme TO ls_empties_poitem-bstme.
  ENDIF.
* if po item is a full product -> uom of delivery note quantity must
* be equal to unit of entry;
* both fields 'lsmeh' and 'erfme' are no longer input but just
* display -> important for a stable empties bom
  IF ls_empties_poitem-upvor = c_upvor_vg.
      cs_goitem-xvgtype = p.
      cs_goitem-lsmeh = cs_goitem-erfme = ls_empties_poitem-bstme.
  ENDIF.
* if po item is a tied empty -> build up link to full product
  IF ls_empties_poitem-uptyp = c_uptyp_lg.
    CALL METHOD purchase_order_fill_tied_empty
         EXPORTING is_empties_poitem   = ls_empties_poitem
         CHANGING  cs_goitem   = cs_goitem
         EXCEPTIONS not_found = 1.
    IF sy-subrc <> 0.
*     posting a tied empty without full product doesn't make sense
      RAISE full_not_found.
    ENDIF.
  ENDIF.
ENDMETHOD.

************************************************************************
*                            <LG>
* Fill special data for tied empties (link to full product);
*
* attention: the same full product can appear several times in
*            pt_goitem (e.g. take over po several times and change
*            qty); find the right full product
*
* input:
*     is_empties_poitem : infos about the actual tied empty line of the
*                         po (ebeln, uebpo..)
*
* changing:
*     cs_goitem : actual tied empty line in goitem scheme
************************************************************************
METHOD purchase_order_fill_tied_empty.

  FIELD-SYMBOLS <goitem_full> TYPE goitem.

  CLEAR cs_goitem-parent.
* look for the full product
  LOOP AT pt_goitem ASSIGNING <goitem_full>
     WHERE ebeln = is_empties_poitem-ebeln  AND
           ebelp = is_empties_poitem-uebpo  AND
           lfbnr = is_empties_poitem-lfbnr.
* check full product: does already exist an empty linked to it?
    IF <goitem_full>-expand = c_icon_expand.
* full product has not been expanded on screen -> candidate
      READ TABLE pt_goitem TRANSPORTING NO FIELDS
         WITH KEY ebeln = is_empties_poitem-ebeln
                  ebelp = is_empties_poitem-ebelp
                  parent = <goitem_full>-global_counter.
      IF NOT sy-subrc IS INITIAL.
* full product is a hit -> build up link from empty to full product
        cs_goitem-xvgtype   = c.
        cs_goitem-parent    = <goitem_full>-global_counter.
        cs_goitem-zeile     = <goitem_full>-zeile.
        cs_goitem-invisible = x.
        cs_goitem-depth     = <goitem_full>-depth + 1.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  IF cs_goitem-parent IS INITIAL.
* corresponding full product to actual empty could not be found
    RAISE not_found.
  ENDIF.

ENDMETHOD.