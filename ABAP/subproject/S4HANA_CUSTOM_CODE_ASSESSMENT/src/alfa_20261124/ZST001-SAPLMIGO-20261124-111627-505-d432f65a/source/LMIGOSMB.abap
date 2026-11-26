*----------------------------------------------------------------------*
*   INCLUDE LMIGOSMB                                                   *
*----------------------------------------------------------------------*

* Define to read the generated coding from MIGO_GENERATE_FIELDSELECTION
DEFINE def_fs.
  ls_generated = &1.
  insert ls_generated into table t_generated.
END-OF-DEFINITION.

************************************************************************
* Generation of the internal tables for field selection.
************************************************************************
METHOD class_constructor.
  DATA: ls_generated TYPE ty_s_generated,
        ls_dfies     TYPE dfies,
        lt_dfies     TYPE STANDARD TABLE OF dfies,
        l_coblname   TYPE migo_fieldname.
* SE51 settings from MIGO_GENERATE_FIELDSELECTION
ENHANCEMENT-SECTION     LMIGOSMB_01 SPOTS ES_SAPLMIGO.
  INCLUDE lmigosmg.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT LMIGOSMB_02 SPOTS ES_SAPLMIGO.

* The fields from CI_COBL have to be appended. This has explicity
* been omitted during MIGO_GENERATE_FIELDSELECTION. The coding
* should look the same.
  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      tabname           = 'CI_COBL'
    TABLES
      dfies_tab         = lt_dfies
    EXCEPTIONS
      not_found         = 0
      OTHERS            = 0.
  LOOP AT lt_dfies INTO ls_dfies.
    CONCATENATE 'GOITEM-' ls_dfies-fieldname INTO l_coblname.
      CLEAR ls_generated.
      ls_generated-name    = l_coblname.
      ls_generated-dynnr1  = 'COBL'.
      ls_generated-type    = 'C'.
      ls_generated-item    = 'X'.
      ls_generated-visible = 'X'.
      ls_generated-input   = 'X'.
      INSERT ls_generated INTO TABLE t_generated.
  ENDLOOP.
* Settings from SFAC
  CALL METHOD fieldselection_sfac_read.
* Names of buttons used to display things.
  APPEND 'OK_LINKED_DOCUMENTS'   TO t_buttons.
  APPEND 'OK_INSPLOT'            TO t_buttons.
  APPEND 'OK_WM_SHOW'            TO t_buttons.
  APPEND 'OK_PO_HISTORY'         TO t_buttons.
  APPEND 'OK_SHIP_CONS'          TO t_buttons.
  APPEND 'OK_STOCK_OVERVIEW'     TO t_buttons.
  APPEND 'OK_STOCK_OVER_RIGHT'   TO t_buttons.
  APPEND 'OK_STOCK_OVER_LEFT'    TO t_buttons.
  APPEND 'OK_BATCH_CLASS'        TO t_buttons.
  APPEND 'OK_PURCHASEORDER'      TO t_buttons.
  APPEND 'OK_IMPORT_ITEM'        TO t_buttons.
  APPEND 'OK_NAST_SHOW'          TO t_buttons.
ENDMETHOD.
************************************************************************
* Read SFAC and modify generated-field-selection-table with the
* additional data. The data are distributed into three possible
* targets:
* a) The basic field selection list (global_counter 0), contains
*    the column selection for the table-control, too.
* b) The template for item data.
************************************************************************
METHOD fieldselection_sfac_read.
  DATA: ls_fs           TYPE ty_s_fs,
        lt_fs           TYPE ty_t_fs,
        lt_fs_template  TYPE ty_t_fs,
        ls_fst          TYPE ty_s_fst.
  FIELD-SYMBOLS: <ls_generated> TYPE ty_s_generated.

  LOOP AT t_generated ASSIGNING <ls_generated>.
*   Screen group 0001. To be applied to all fields.
*   Resulting structure is distributed into the base tables for
*   fieldselection.
*   Filling of SCREEN so that SFAC will work correctly...
    screen-name   = <ls_generated>-name.
    screen-group1 = <ls_generated>-group1.
    IF <ls_generated>-visible = x AND <ls_generated>-input = x.
      screen-active    = 1.
      screen-output    = 1.
      screen-input     = 1.
      screen-invisible = 0.
    ELSEIF <ls_generated>-visible = x AND
           <ls_generated>-input   = space.
      screen-active    = 1.
      screen-output    = 1.
      screen-invisible = 0.
      screen-input     = 0.
    ELSEIF <ls_generated>-visible = space.
      screen-active    = 0.
      screen-output    = 0.
      screen-invisible = 0.
      screen-input     = 0.
    ENDIF.
    IF <ls_generated>-required = x.
      screen-required = 1.
    ELSE.
      screen-required = 0.
    ENDIF.
    CALL FUNCTION 'FIELD_SELECTION_MODIFY_SINGLE'
         EXPORTING
              dynprogruppe = '0001'
              mode         = a
              modulpool    = c_repid.                   "#EC DOM_EQUAL
*   Now, SCREEN is filled correctly. Construct internal data.
    CLEAR ls_fs.
    ls_fs-name = screen-name.
    ls_fs-type = <ls_generated>-type.
    IF screen-invisible = 1 OR screen-active = 0.
      ls_fs-sfac = c_invisible.
    ELSEIF screen-input = 0.
      ls_fs-sfac = c_visible.
    ELSE.
      ls_fs-sfac = c_input.
    ENDIF.
*   The "required"-attribute is maintained separately
    IF screen-required = 1.
      ls_fs-sfac_required = abap_true.
    ENDIF.
*   Append to the nested table for common data or item data.
    IF <ls_generated>-item = 'X'.
      INSERT ls_fs INTO TABLE lt_fs_template.
*     GOITEM-fields are contained in SFAC 0001.
*     We insert them not only into the template, but also into
*     the GLC = 0 section. This controls the disabling of
*     table control columns.
*     Some buttons in the table-control have to be treated
*     separately as their name is different.
      IF ls_fs-name = 'GOITEM-DOCUBATCH_CHARG' OR
         ls_fs-name = 'OK_DOC_BATCH_DETAIL'.
        IF lcl_migo_globals=>doc_batch_active = abap_false.
          ls_fs-sfac = c_invisible.
          INSERT ls_fs INTO TABLE lt_fs.
        ELSE.
          ls_fs-sfac = c_visible.
          INSERT ls_fs INTO TABLE lt_fs.
        ENDIF.
      ELSEIF ls_fs-name CS 'GOITEM-'             OR
             ls_fs-name =  'OK_LINKED_DOCUMENTS' OR
             ls_fs-name =  'OK_DETERMINE'.
        ls_fs-sfac = c_visible.
        INSERT ls_fs INTO TABLE lt_fs.
      ELSEIF ls_fs-name = 'OK_GA_CHANGE_VARIANT' OR
             ls_fs-name = 'OK_GA_ADD_VARIANT'.
          INSERT ls_fs INTO TABLE lt_fs.
      ENDIF.
    ELSE.
      INSERT ls_fs INTO TABLE lt_fs.
    ENDIF.
  ENDLOOP.
* Append the main fieldselection data to the master table with
* global counter = 0, for item templates with GLC = 999999.
  ls_fst-glc   = 0.
  ls_fst-table = lt_fs.
  INSERT ls_fst INTO TABLE t_fieldselection.
  ls_fst-glc   = c_item_template.
  ls_fst-table = lt_fs_template.
  INSERT ls_fst INTO TABLE t_fieldselection.
ENDMETHOD.