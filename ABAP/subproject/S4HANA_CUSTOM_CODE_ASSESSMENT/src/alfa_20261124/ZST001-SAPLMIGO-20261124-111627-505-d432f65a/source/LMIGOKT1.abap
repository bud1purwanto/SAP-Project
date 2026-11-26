*----------------------------------------------------------------------*
*   INCLUDE LMIGOKT1                                                   *
*----------------------------------------------------------------------*
************************************************************************
* Calls all the necessary methods for table-handling
************************************************************************
************************************************************************
* search in table for a character-string
************************************************************************
METHOD table_sort.
* send message to viewer, so that they save their current-line
  def_sms 'MODEL_CHANGE_BEGIN' space space.

* in order to avoid a short dump
  IF i_column_name <> 'OK_DETERMINE' AND
     i_column_name <> 'OK_DOC_BATCH_DETAIL'.
    IF i_sort_up = abap_false.
      SORT pt_goitem DESCENDING BY (i_column_name) zeile.        "753550
    ELSE.
      SORT pt_goitem ASCENDING  BY (i_column_name) zeile.        "753550
    ENDIF.
  ENDIF.

* If sorting by ZEILE, bring subitems back into original order
  IF i_column_name = 'ZEILE'.
    IF i_sort_up = abap_false.
      SORT pt_goitem BY zeile DESCENDING depth global_counter.
    ELSE.
      SORT pt_goitem BY zeile ASCENDING  depth global_counter.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT LMIGOKT1_01 SPOTS ES_SAPLMIGO.

* send message to viewer, so that they get back their current-line
  CALL METHOD status_derive.
  def_sms 'MODEL_CHANGE_COMPLETE' space space.
ENDMETHOD.                    "table_sort

************************************************************************
* Delete lines in the table control.
* Exceptions:
* - Children of subcontracting positions not deleted even if unflagged.
*   Reason: Unmarking means: Post this component with quantity 0.
*   Removing the entire line would destroy that information.
* - Parents of BOM-resolution are unflagged as they are only for
*   display reasons. However, they cannot be deleted as they
*   are parents for their children.
************************************************************************
METHOD table_delete_not_ok.
  DATA: lt_todelete TYPE STANDARD TABLE OF migo_global_counter,
        l_glc TYPE migo_global_counter,
        ls_goitem   TYPE goitem.

* Tip
  def_sms 'MIGO_TIP_REQUEST' 'HELP_MIGO_DELETE_LINE' space.

* send message to viewer, so that they save their current-line
  def_sms 'MODEL_CHANGE_BEGIN' space space.

* Get the global counters of all affected lines before changing model
  LOOP AT pt_goitem INTO ls_goitem
                    WHERE     take_it IS initial
                      AND NOT global_counter IS initial
                      AND     invisible IS initial.
    IF ( ls_goitem-xlbtype  = 'C' ) OR
       ( ls_goitem-xbomtype = 'P' ).
      CONTINUE.
    ENDIF.
    APPEND ls_goitem-global_counter TO lt_todelete.
    IF ls_goitem-xgatype = 'C'.
      READ TABLE pt_goitem
        WITH KEY global_counter = ls_goitem-parent
                 xgatype        = p
                 TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE pt_goitem WITH KEY parent  = ls_goitem-parent
                                      take_it = abap_true
                                      xgatype = c
                                      TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          READ TABLE pt_goitem INTO ls_goitem
            WITH KEY global_counter = ls_goitem-parent
                     xgatype        = p.
          CHECK: sy-subrc = 0, sy-tabix > 0.
          IF ls_goitem-xpoitem = abap_true.
* In case of GR for PO delete generic article too, if there are no
* variants there anymore
            APPEND ls_goitem-global_counter TO lt_todelete.
          ELSE.
            ls_goitem-expand = c_icon_expand.
            MODIFY pt_goitem FROM ls_goitem INDEX sy-tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Delete the lines.
  LOOP AT lt_todelete INTO l_glc.
    READ TABLE pt_goitem WITH KEY global_counter = l_glc
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
*     Caution: Using SY-TABIX directly is only permitted because
*     I_TABIX is used "BY VALUE" (note 381320).
      CALL METHOD line_delete
        EXPORTING
          i_tabix       = sy-tabix
          i_no_messages = abap_true.
    ENDIF.
  ENDLOOP.

* send message to viewer, so that they get back their current-line
  def_sms 'MODEL_CHANGE_COMPLETE' space space.

ENDMETHOD.                    "table_delete_not_ok