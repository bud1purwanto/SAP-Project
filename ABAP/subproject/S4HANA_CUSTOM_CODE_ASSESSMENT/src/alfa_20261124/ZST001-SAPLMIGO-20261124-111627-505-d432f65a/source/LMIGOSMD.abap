*----------------------------------------------------------------------*
*   INCLUDE LMIGOSMD                                                   *
*----------------------------------------------------------------------*

************************************************************************
* check if required fields in t_fieldselection are filled with data in
* goitem and gohead.
************************************************************************
METHOD screen_modify_required.
  DATA: l_fieldname     TYPE migo_fieldname,
        l_field         TYPE dfies-lfieldname,
        l_tabname       TYPE ddobjname,
        l_message(60)   TYPE c,
        ls_dfies        TYPE dfies,
        l_glc_initial   TYPE migo_global_counter.
  FIELD-SYMBOLS: <ls_fst>  TYPE ty_s_fst,
                 <ls_fs>   TYPE ty_s_fs,
                 <content> TYPE ANY.
ENHANCEMENT-POINT LMIGOSMD_01 SPOTS ES_SAPLMIGO STATIC .

  IF is_goitem IS INITIAL.
*   Read fieldselection for gohead
    READ TABLE t_fieldselection ASSIGNING <ls_fst>
               WITH TABLE KEY glc = l_glc_initial.
    l_tabname = 'GOHEAD'.
  ELSE.
*   Read fieldselection for goitem
    READ TABLE t_fieldselection ASSIGNING <ls_fst>
               WITH TABLE KEY glc = is_goitem-global_counter.
    l_tabname = 'GOITEM'.
  ENDIF.
* Check required fields in goitem and gohead.
* A field is required if it is ready for input and has the flag.
  LOOP AT <ls_fst>-table ASSIGNING <ls_fs>
                         WHERE work_required = abap_true AND
                               work          = c_input.
*   Check only GOHEAD or GOITEM-fields. All other fields cannot
*   be set to required (e.g. BOM explosion parameters). This is
*   not error, but corresponds to design.
    CHECK <ls_fs>-name(6) = 'GOHEAD' OR
          <ls_fs>-name(6) = 'GOITEM'.
    CONCATENATE 'IS_' <ls_fs>-name INTO l_fieldname.
*   Special cases (here: header general)
    CASE g_sub_general.
*     This screen contains LFSNR, but no MTSNR. However, the value
*     to be checked is in XBLNR (goods receipt for PO).
      WHEN 110.
        CASE <ls_fs>-name.
          WHEN 'GOHEAD-LFSNR'. l_fieldname = 'IS_GOHEAD-XBLNR'.
          WHEN 'GOHEAD-MTSNR'. CONTINUE.
        ENDCASE.
*     Goods receipt for production order
      WHEN 111.
        CASE <ls_fs>-name.
          WHEN 'GOHEAD-FRBNR' OR
               'GOHEAD-MTSNR'. CONTINUE.
        ENDCASE.
*     Other goods movements
      WHEN 112.
        CASE <ls_fs>-name.
          WHEN 'GOHEAD-MTSNR'. l_fieldname = 'IS_GOHEAD-XBLNR'.
          WHEN 'GOHEAD-LFSNR' OR
               'GOHEAD-FRBNR'. CONTINUE.
        ENDCASE.
    ENDCASE.

    IF ( l_fieldname = 'IS_GOITEM-J_1BEXBASE'  "1257313
    OR l_fieldname = 'IS_GOITEM-MWSKZ' )       "1257313
    AND goitem-brazil = ' '.                   "1257313
      CONTINUE.                                "1257313
    ENDIF.                                     "1257313

ENHANCEMENT-SECTION     LMIGOSMD_02 SPOTS ES_SAPLMIGO.
    ASSIGN (l_fieldname) TO <content>.
    IF <content> IS INITIAL.
*     Get longtext for field
      l_field = <ls_fs>-name+7.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = l_tabname
          lfieldname     = l_field
          langu          = sy-langu
        IMPORTING
          dfies_wa       = ls_dfies
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        l_message = <ls_fs>-name.
      ELSEIF ls_dfies-scrtext_l IS INITIAL.
        l_message = ls_dfies-fieldtext.
      ELSE.
        l_message = ls_dfies-scrtext_l.
      ENDIF.
*     Fill application log.
      CALL METHOD oref_log->context_set
           EXPORTING i_global_counter = is_goitem-global_counter
                     i_fieldname      = <ls_fs>-name.

      CALL METHOD oref_log->message_add
        EXPORTING i_msgty = 'E'
                  i_msgid = 'M7'
                  i_msgno = '018'
                  i_msgv1 = l_message.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDLOOP.
ENDMETHOD.