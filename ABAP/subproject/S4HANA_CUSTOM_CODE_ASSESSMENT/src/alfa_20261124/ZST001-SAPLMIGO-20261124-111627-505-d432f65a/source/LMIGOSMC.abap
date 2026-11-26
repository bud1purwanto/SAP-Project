*----------------------------------------------------------------------*
*   INCLUDE LMIGOSMC                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Modify fieldselection
************************************************************************
METHOD set.
  DATA: ls_fs     TYPE ty_s_fs,
        ls_fields TYPE migo_fieldname,
        lt_fields TYPE ty_t_fieldname.
  FIELD-SYMBOLS: <t_fieldselection> TYPE ty_s_fst,
                 <s_fs>             TYPE ty_s_fs.
* Access the fieldselection table and modify the contents
  READ TABLE t_fieldselection ASSIGNING <t_fieldselection>
       WITH TABLE KEY glc = i_global_counter.
* Create internal table with the fields to be processed
  SPLIT i_fields AT ' ' INTO TABLE lt_fields.
  DELETE lt_fields WHERE table_line IS initial.
  APPEND LINES OF it_fields TO lt_fields.
  CASE i_inversion.
    WHEN abap_false.
*     Set the status for the specified fields
      LOOP AT lt_fields INTO ls_fields.
        READ TABLE <t_fieldselection>-table ASSIGNING <s_fs>
             WITH TABLE KEY name = ls_fields.
*       Error in fieldselection list. For the template, this is
*       allowed as the list for GLC 0 has to be copied and contains
*       more entries.
        IF sy-subrc <> 0.
          IF i_global_counter <> c_item_template.
            MESSAGE e899 WITH 'FIELDSELECTION'
                              ls_fields
                              space
                              space.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
*       Modify MODE fieldselection (Only a lower status is allowed)
        CASE i_mode.
          WHEN abap_false.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-work.
            IF i_status <= <s_fs>-mode.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-work = <s_fs>-mode.
            ENDIF.
          WHEN abap_true.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-mode.
            IF i_status <= <s_fs>-sfac.
              <s_fs>-mode = i_status.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-mode = <s_fs>-sfac.
              <s_fs>-work = <s_fs>-sfac.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    WHEN abap_true.
*     Process all fields except the ones given in the list
      SORT lt_fields BY table_line.
      LOOP AT <t_fieldselection>-table ASSIGNING <s_fs>.
        READ TABLE lt_fields WITH KEY table_line = <s_fs>-name
                             TRANSPORTING NO FIELDS.
        CHECK sy-subrc <> 0.
        CASE i_mode.
          WHEN abap_false.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-work.
            IF i_status <= <s_fs>-mode.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-work = <s_fs>-mode.
            ENDIF.
          WHEN abap_true.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-mode.
            IF i_status <= <s_fs>-sfac.
              <s_fs>-mode = i_status.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-mode = <s_fs>-sfac.
              <s_fs>-work = <s_fs>-sfac.
            ENDIF.
        ENDCASE.
      ENDLOOP.
  ENDCASE.
ENDMETHOD.
************************************************************************
* Get the current status of the WORK area
************************************************************************
METHOD get.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  IF sy-subrc <> 0.
    MESSAGE e899 WITH 'FIELDSELECTION=>GET'
                      'GLOBAL_COUNTER'
                      i_global_counter
                      space.
  ENDIF.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  IF sy-subrc <> 0.
*   BAdI: No error message, if the field is not used on any screen in
*         transaction MIGO. Set r_status=8 (=not valid).
    IF i_badi = x.
      r_status = 8.
      EXIT.
    ENDIF.
    MESSAGE e899 WITH 'FIELDSELECTION=>GET FIELD'
                      i_global_counter
                      i_field
                      space.
  ENDIF.
  r_status = <ls_fs>-work.
ENDMETHOD.
************************************************************************
* Check whether a given field is required
************************************************************************
METHOD get_required.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  CHECK sy-subrc = 0.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  CHECK sy-subrc = 0.
  r_required = <ls_fs>-work_required.
ENDMETHOD.
************************************************************************
* Main fieldselection routine. Called from SCREENOBJECT in every
* screen and for each line of the TC. This method can handle
* normal fields, tabstrips, table control buttons, and local
* specialties...
************************************************************************
METHOD main.
  FIELD-SYMBOLS:
    <ls_fst>           TYPE lcl_migo_screenmodification=>ty_s_fst,
    <l_required_field> TYPE ANY.
  DATA:
    ls_column TYPE lcl_migo_screenmodification=>ty_s_column,
    ls_fs     TYPE lcl_migo_screenmodification=>ty_s_fs.
ENHANCEMENT-POINT LMIGOSMC_04 SPOTS ES_SAPLMIGO STATIC .
* Access the fieldselection data
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  CHECK sy-subrc = 0.
* Execute the screenmodification.
  LOOP AT SCREEN.
    READ TABLE <ls_fst>-table INTO ls_fs
               WITH TABLE KEY name = screen-name.
    CHECK sy-subrc = 0.
*   Columns in the table control: Special handling (as usual...).
*   - 0200 = Table Control-Screen
*   - 1000 = Split quantity popup
*   - GLC initial: If we are in the LOOP AT CONTROL, no column manip.
*   - TYPE = C: Superset for columns in TC.
ENHANCEMENT-SECTION     LMIGOSMC_02 SPOTS ES_SAPLMIGO.
    IF ls_fs-type = 'C' AND
       ( sy-dynnr = '0200' OR sy-dynnr = '1000' ).
*     Read the COLS table of the table control to check
*     whether this element is a column or not (remember: there
*     are buttons in screen 0200, too).
      CASE sy-dynnr.
        WHEN '0200'.
          READ TABLE tv_goitem-cols INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
        WHEN '1000'.
          READ TABLE tv_gosplit-cols INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
      ENDCASE.
*     GLC = 0 : Disabling columns
      IF i_global_counter IS INITIAL.
*       Check for SY-SUBRC is necessary as there are data in field-
*       selections which are possibly columns in the TC, but not
*       currently implemented (accounting fields). For these, the
*       MIGO fieldselection is used as a transporter for FS-information.
        IF sy-subrc = 0.
*        Columns disabled by administrator: INVISIBLE = X. Do not touch!
*         Columns disabled by us:            INVISIBLE = 1. Jupedidu!
          CHECK ls_column-invisible <> x.
          ls_column-invisible = c_mod_off.
          IF ls_fs-work = c_invisible.
            ls_column-invisible = c_mod_on.
          ENDIF.
          CASE sy-dynnr.
            WHEN '0200'.
              MODIFY tv_goitem-cols FROM ls_column
                                    INDEX sy-tabix
                                    TRANSPORTING invisible.
            WHEN '1000'.
              MODIFY tv_gosplit-cols FROM ls_column
                                     INDEX sy-tabix
                                     TRANSPORTING invisible.
          ENDCASE.
*         Do not execute normal screen modification!!!
          CONTINUE.
        ENDIF.
      ELSE.
*       GLC > 0: Item modification in TV. Check that column
*       is visible. Necessary to prevent the field itself to
*       be set INVISIBLE (No fields transport. Deadly!)
        CHECK ls_column-invisible = c_mod_off.
      ENDIF.
    ENDIF.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT FIELDSELECTION_01 SPOTS ES_SAPLMIGO.
*   Normal fields (no columns of the table control)
    IF ls_fs-work >= c_input.
      screen-invisible = c_mod_off.
      screen-input     = c_mod_on.
    ELSEIF ls_fs-work >= c_visible.
      screen-invisible = c_mod_off.
      screen-input     = c_mod_off.
    ELSE.
      screen-invisible = c_mod_on.
      screen-input     = c_mod_off.
    ENDIF.
*   Tabstrips must be INPUT = 1, even if invisible.
*   Consistency is a nice thing to have, but a hard thing to achieve...
    IF ls_fs-type = 'T'.
      screen-input = c_mod_on.
    ENDIF.
ENHANCEMENT-POINT LMIGOSMC_03 SPOTS ES_SAPLMIGO .
*   Mark required fields for the user. This cannot be done using
*   the REQUIRED attribute, because this would block the transaction.
*   We use INTENSIFIED instead. There is a twin of this code in
*   LMIGODA2 for the fields on the foreign accounting screen.
    IF ls_fs-work_required = abap_true.
*     Check whether the field is empty.
      ASSIGN (screen-name) TO <l_required_field>.
      IF sy-subrc = 0 AND <l_required_field> IS INITIAL.
        screen-intensified = c_mod_on.
      ENDIF.
    ENDIF.
ENHANCEMENT-POINT LMIGOSMC_01 SPOTS ES_SAPLMIGO.
    MODIFY SCREEN.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Copy the current template data to a new line in T_FIELDSELECTION
************************************************************************
METHOD template_copy.
  DATA: ls_fst TYPE ty_s_fst.
  READ TABLE t_fieldselection INTO ls_fst
       WITH TABLE KEY glc = c_item_template.
  ls_fst-glc = i_global_counter.
  INSERT ls_fst INTO TABLE t_fieldselection.
ENDMETHOD.
************************************************************************
* Delete an entry in the fieldselection table
************************************************************************
METHOD delete_item.
  DELETE t_fieldselection WHERE glc = i_global_counter.
ENDMETHOD.
************************************************************************
* Delete all items. Used in Kernel->RESET.
************************************************************************
METHOD delete_all.
  DELETE t_fieldselection WHERE NOT glc IS initial
                            AND NOT glc = c_item_template.
ENDMETHOD.
************************************************************************
* Restore the fieldselection table.
* If called with I_MODE = TRUE --> Copy SFAC into MODE and WORK.
* otherwise operate on MODE -> WORK only.
* Only one GLC at a time.
************************************************************************
METHOD restore.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
       WITH TABLE KEY glc = i_global_counter.
  LOOP AT <ls_fst>-table ASSIGNING <ls_fs>.
    IF i_mode = abap_true.
      <ls_fs>-mode          = <ls_fs>-sfac.
      <ls_fs>-mode_required = <ls_fs>-sfac_required.
    ENDIF.
    <ls_fs>-work          = <ls_fs>-mode.
    <ls_fs>-work_required = <ls_fs>-mode_required.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* For a given list of fieldnames, look through all global_counter
* lines and return the highest status the field has.
* Used for dynamic disabling of table control columns.
************************************************************************
METHOD dynamic_columns.
  DATA: ls_fs      TYPE ty_s_fs,
        ls_dynamic TYPE ty_s_dynamic.
  FIELD-SYMBOLS: <ls_fst>     TYPE ty_s_fst,
                 <ls_dynamic> TYPE ty_s_dynamic.
* Reset the result field to initial value for all incoming lines
  MODIFY ct_dynamic FROM ls_dynamic TRANSPORTING status
                    WHERE NOT name IS INITIAL.
* Check all lines in the model (GLC = 99999: template)
  LOOP AT t_fieldselection ASSIGNING <ls_fst>
                           WHERE glc <> 0.
*   Fields to be processed
    LOOP AT ct_dynamic ASSIGNING <ls_dynamic>.
*     Get the field status in this line
      READ TABLE <ls_fst>-table INTO ls_fs
           WITH TABLE KEY name = <ls_dynamic>-name.
*     Remember the maximum
      IF ls_fs-work > <ls_dynamic>-status.
        <ls_dynamic>-status = ls_fs-work.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Set the REQUIRED-attribute for a given field
* This method is not as sophisticated as SET as it is only
* used to set the attribute for movement type depending fields
************************************************************************
METHOD set_required.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  IF i_mode = abap_true.
    <ls_fs>-mode_required = abap_true.
  ENDIF.
  <ls_fs>-work_required = abap_true.
ENDMETHOD.
************************************************************************
* Locate a field on the dynpros. Return a table of dynpros
* where the specified field is ready for input.
************************************************************************
METHOD field_locate.
  DATA: ls_generated TYPE ty_s_generated,
        l_status     TYPE migo_fs_status.
* Start with a clean result table
  CLEAR et_dynnr.
* Check that the field  is ready for input for the specified GLC
  CALL METHOD get
    EXPORTING
      i_field          = i_field
      i_global_counter = i_global_counter
    RECEIVING
      r_status         = l_status.
  CHECK l_status >= c_input.
* Access the fielddata from the generated include
  READ TABLE t_generated INTO ls_generated
             WITH TABLE KEY name = i_field.
  CHECK sy-subrc = 0.
* Fill the export table from the two available dynpro data
  IF NOT ls_generated-dynnr1 IS INITIAL.
    INSERT ls_generated-dynnr1 INTO TABLE et_dynnr.
  ENDIF.
  IF NOT ls_generated-dynnr2 IS INITIAL.
    INSERT ls_generated-dynnr2 INTO TABLE et_dynnr.
  ENDIF.
ENDMETHOD.