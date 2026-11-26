FUNCTION migo_generate_fieldselection.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------

  CLASS cl_mmim_migo_move_fields DEFINITION LOAD.

************************************************************************
* Generation of the primary fieldselection table for MIGO.
* Derived from the settings of all dynpros in SAPLMIGO
************************************************************************


  TYPES: BEGIN OF ty_s_list,
           prefix(8) TYPE c.
  INCLUDE TYPE lcl_migo_screenmodification=>ty_s_generated.
  TYPES:   postfix(2) TYPE c,
         END OF ty_s_list.


  DATA: lt_fields   TYPE STANDARD TABLE OF rpy_dyfatc,
        ls_fields   TYPE rpy_dyfatc,
        ls_list     TYPE ty_s_list,
        ls_list_old TYPE ty_s_list,
        ls_comp1    TYPE ty_s_list,
        ls_comp2    TYPE ty_s_list,
        lt_list     TYPE SORTED TABLE OF
                         ty_s_list
                         WITH UNIQUE KEY name,
        l_line(72)  TYPE c,
        l_coblname  TYPE migo_fieldname,
        lt_d020s    TYPE STANDARD TABLE OF d020s,
        ls_d020s    TYPE d020s,
        lv_sw_status TYPE sfw_switchpos.
* Get a list of all dynpros of the function group SAPLMIGO
  SELECT dnum INTO CORRESPONDING FIELDS OF TABLE lt_d020s
              FROM d020s
              WHERE prog = c_repid.

* check if long procurement number is active
  DATA cl_change TYPE REF TO /sappspro/cl_numbers.
  DATA lf_active TYPE boolean.

  CLEAR: lf_active.
  CREATE OBJECT cl_change.

  CALL METHOD cl_change->is_active
    RECEIVING
      rv_active = lf_active.

  IF lf_active = 'X'.
    DELETE lt_d020s WHERE dnum = '0320'.
  ELSE.
    DELETE lt_d020s WHERE dnum = '0400'.
  ENDIF.
  DELETE lt_d020s WHERE dnum = '0401'.                  "WP145920
  DELETE lt_d020s WHERE dnum = '0402'.                  "WP145920
  DELETE lt_d020s WHERE dnum = '2002'.                  "WP145920
  DELETE lt_d020s WHERE dnum = '2003'.                  "WP145920

ENHANCEMENT-SECTION     migo_generate_fieldselectio_03 SPOTS es_saplmigo.
  DELETE lt_d020s WHERE dnum = '8200' OR dnum = '8315' OR dnum = '8390'
    OR dnum = '8316' OR dnum = '8391'
    OR dnum = '0011'.  "Ignore screen for choosing display variant /SAPMP/
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT migo_generate_fieldselectio_01 SPOTS es_saplmigo.
  LOOP AT lt_d020s INTO ls_d020s.
*   Loop over all dynpros. Get the field data and fill them into
*   a work table.
    CALL FUNCTION 'RPY_DYNPRO_READ'
      EXPORTING
        progname             = c_repid                   "#EC DOM_EQUAL
        dynnr                = ls_d020s-dnum
      TABLES
        fields_to_containers = lt_fields.
    LOOP AT lt_fields INTO ls_fields.
      CLEAR ls_list.
*     Elimination of these elements just for hygienic reasons.
*     Could stay in the table as well. Doesn't matter.
*     LOGTEXT has to be defined as exception because it is only a
*     Textfield (corresponding pushbutton GOHEAD-LOGLEVEL)
      IF ( ls_fields-type = 'FRAME' OR ls_fields-type = 'OKCODE' OR
         ls_fields-type = 'TEXT'  OR ls_fields-name IS INITIAL ) AND
         ls_fields-name <> 'LOGTEXT'.
        CONTINUE.
      ENDIF.
ENHANCEMENT-SECTION     migo_generate_fieldselectio_05 SPOTS es_saplmigo.
* Switchable fields
      IF NOT ls_fields-sfw_switchid IS INITIAL AND      "if switch assigned
         ls_fields-sfw_showhide EQ 'D'.                 "and display switch
        CLEAR lv_sw_status.
        lv_sw_status = cl_abap_switch=>get_switch_state( ls_fields-sfw_switchid ).
        CHECK lv_sw_status EQ 'T'.                       "procede if on
      ENDIF.
END-ENHANCEMENT-SECTION.

      ls_list-name     = ls_fields-name.
      ls_list-dynnr1   = ls_d020s-dnum.
      ls_list-group1   = ls_fields-group1.
      ls_list-input    = ls_fields-input_fld.
      ls_list-required = ls_fields-requ_entry.
*     Entries coming from the screen-painter are always visible
      ls_list-visible  = 'X'.
*     Pushbuttons: Need INPUT flag although not set by SE51.
*     They can by PUSH or (!?) PUSH_TMPL.....?  HMPF!!!
      IF ls_fields-type(4) = 'PUSH'.
        ls_list-input = 'X'.
      ENDIF.
*     Set flag for item-related field: All fields within the
*     table control 0200 and all fields in dynpros 3xx without
*     300, 301, 302, 303 (transfer), 305 (transfer).
      IF ( ls_d020s-dnum = '0200' AND
           ls_fields-cont_type = 'TABLE_CTRL' ) OR
         ( ls_d020s-dnum >= '0300'
           AND ls_d020s-dnum < '0400' AND
           '0300 0301 0302 0303 0305' NS ls_d020s-dnum )  "#EC PORTABLE
           OR ls_d020s-dnum = '0500'.                     "#EC PORTABLE
        ls_list-item = 'X'.
      ENDIF.
ENHANCEMENT-POINT migo_generate_fieldselectio_02 SPOTS es_saplmigo.
*     Store type of screen element. Needed in screenmodification
*     as table control columns and tabstrip buttons need a
*     special treatment (always the same sad story...)
      CASE ls_fields-cont_type.
        WHEN 'TABLE_CTRL'. ls_list-type = 'C'.
        WHEN 'STRIP_CTRL'. ls_list-type = 'T'.
        WHEN OTHERS.       ls_list-type = space.
      ENDCASE.
*     Check for already existing entry with the same name
      READ TABLE lt_list INTO ls_list_old
                 WITH TABLE KEY name = ls_list-name.
      IF sy-subrc = 0.
*       Populate the second dynpro number into the existing line.
*       Afterwards, clear the field in LS_LIST_OLD
*       to cheat "Conflicting data".
*       We play this only once.
        IF ls_list_old-dynnr2 IS INITIAL.
          ls_list_old-dynnr2 = ls_d020s-dnum.
          MODIFY TABLE lt_list FROM ls_list_old TRANSPORTING dynnr2.
          CLEAR ls_list_old-dynnr2.
        ENDIF.
*       Ensure for GOITEM-fields that the entry with TYPE = C (column)
*       is printed out.
        IF     ls_list_old-type IS INITIAL AND
           NOT ls_list-type     IS INITIAL.
          ls_list_old-type = ls_list-type.
          MODIFY TABLE lt_list FROM ls_list_old TRANSPORTING type.
        ENDIF.
*       Ensure that GROUP1 is filled if not done yet (fields in 0200
*       have no GROUP1).
        IF ls_list_old-group1 IS INITIAL.
          ls_list_old-group1 = ls_list-group1.
          MODIFY TABLE lt_list FROM ls_list_old TRANSPORTING group1.
        ENDIF.
*       Issue message if there are differences on the dynpro-attributes
        ls_comp1 = ls_list.
        ls_comp2 = ls_list_old.
        CLEAR: ls_comp1-dynnr1, ls_comp2-dynnr1,
               ls_comp1-dynnr2, ls_comp2-dynnr2,
               ls_comp1-type,   ls_comp2-type,
               ls_comp1-group1, ls_comp2-group1.
        IF ls_comp1 <> ls_comp2.
          WRITE: / 'Conflicting data: ',                    "#EC NOTEXT
                   ls_d020s-dnum, ls_list, ls_list_old.
        ENDIF.
        CONTINUE.
      ELSE.
        INSERT ls_list INTO TABLE lt_list.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENHANCEMENT-SECTION     migo_generate_fieldselectio_06 SPOTS es_saplmigo.
* Insert fields of the accouting block into the MIGO fieldseldection.
* This makes it possible to use this method for all fields visible
* in MIGO, even if they are not on MIGO's screens. Remark: "Some"
* accouting fields are also in MIGO: in the table control. But
* only some...
* Note that fields from CI_COBL must be excluded here. Their
* data have to be appended at runtime because CI_COBL can change.
  LOOP AT cl_mmim_migo_move_fields=>t_gocobl1_no_ci
       INTO l_coblname.
    CONCATENATE 'GOITEM-' l_coblname INTO l_coblname.
    READ TABLE lt_list INTO ls_list_old
             WITH TABLE KEY name = l_coblname.
*   If not yet present in fieldselection, insert as input field.
*   Otherwise, modify the existing set and insert COBL as screen.
    IF sy-subrc <> 0.
      CLEAR ls_list.
      ls_list-name    = l_coblname.
      ls_list-dynnr1  = 'COBL'.
      ls_list-type    = 'C'.
      ls_list-item    = 'X'.
      ls_list-visible = 'X'.
      ls_list-input   = 'X'.
      INSERT ls_list INTO TABLE lt_list.
    ELSE.
      ls_list_old-dynnr2 = 'COBL'.
      MODIFY TABLE lt_list FROM ls_list_old TRANSPORTING dynnr2.
    ENDIF.
  ENDLOOP.
* Special treatment of the fields OK_GA_ADD_VARIANT and
* OK_GA_CHANGE_VARIANT: buttons are in screen 0210, but fieldseletion
* has to be done on goitem level
  READ TABLE lt_list INTO ls_list_old
           WITH TABLE KEY name = 'OK_GA_CHANGE_VARIANT'.
  IF sy-subrc = 0.
    ls_list_old-type    = 'C'.
    ls_list_old-item    = 'X'.
    MODIFY TABLE lt_list FROM ls_list_old.
  ELSE.
*   This must not be happen
    MESSAGE a899 WITH 'READ TABLE' 'lt_list'
                      'OK_GA_CHANGE_VARIANT' space.
  ENDIF.
  READ TABLE lt_list INTO ls_list_old
           WITH TABLE KEY name = 'OK_GA_ADD_VARIANT'.
  IF sy-subrc = 0.
    ls_list_old-type    = 'C'.
    ls_list_old-item    = 'X'.
    MODIFY TABLE lt_list FROM ls_list_old.
  ELSE.
*   This must not be happen
    MESSAGE a899 WITH 'READ TABLE' 'lt_list'
                      'OK_GA_ADD_VARIANT' space.
  ENDIF.
* documentary batch: partly similar to COBL - subscreen is handled by
* LO-BM and does not contain GOITEM-DOCUBATCH_CHARG; but it has to be
* handled like this field
  READ TABLE lt_list INTO ls_list_old
           WITH TABLE KEY name = 'GOITEM-DOCUBATCH_CHARG'.
  IF sy-subrc = 0.
    ls_list_old-dynnr2 = 'VBDO'.
    MODIFY TABLE lt_list FROM ls_list_old TRANSPORTING dynnr2.
  ELSE.
*   This must not happen
    MESSAGE a899 WITH 'READ TABLE' 'lt_list'
                      'GOITEM-DOCUBATCH_CHARG' space.
  ENDIF.
END-ENHANCEMENT-SECTION.
* Generate output
  WRITE: / '* Automatically generated file'.
  WRITE: / '* Generator: Function module MIGO_GENERATE_FIELDSELECTION'.
  WRITE: / '* Generated: ', sy-datum, sy-uzeit.
  WRITE: /.
  LOOP AT lt_list INTO ls_list.
    ls_list-prefix  = 'def_fs '''.
    ls_list-postfix = '''.'.
    IF ls_list-required = 'O'.
      ls_list-required = 'X'.
    ELSE.
      CLEAR ls_list-required.
    ENDIF.
    l_line = ls_list.

    WRITE: / l_line.
  ENDLOOP.
ENDFUNCTION.