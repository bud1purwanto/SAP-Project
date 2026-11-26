
*----------------------------------------------------------------------*
* INCLUDE IUID_MIGO.
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Module INIT_UII_FIELDS OUTPUT
*&---------------------------------------------------------------------*

MODULE init_uii_fields OUTPUT.

* display of column uii depending on iuid relevance
  PERFORM init_uii_fields.

ENDMODULE.                 " UII_HIDE_FIELDS  OUTPUT


*&---------------------------------------------------------------------*
*& Form INIT_UII_FIELDS
*&---------------------------------------------------------------------*
*  display iuid fields depending on customizing settings
*----------------------------------------------------------------------*

FORM init_uii_fields.

* local types
  TYPES:
    lty_cxtab_column TYPE TABLE OF cxtab_column.

* local variables
  DATA:
    lv_len           TYPE i,
    ls_t377p         TYPE t377p,
    lv_iuid_relevant TYPE t377p,
    ls_marc          TYPE marc.

* local pointers
  FIELD-SYMBOLS:
    <ls_col>     TYPE cxtab_column,
    <fs_tc_cols> TYPE lty_cxtab_column.

* check for enabled iuid maintainance by customizing
* besides iuid relavance
  CALL FUNCTION 'MARC_SINGLE_READ'
    EXPORTING
      matnr             = goitem-matnr
      werks             = goitem-werks
    IMPORTING
      wmarc             = ls_marc
    EXCEPTIONS
      lock_on_marc      = 1
      lock_system_error = 2
      wrong_call        = 3
      not_found         = 4
      OTHERS            = 5.
  IF sy-subrc = 0 AND ls_marc-sernp IS NOT INITIAL.
    SELECT SINGLE * FROM t377p INTO ls_t377p
           WHERE serail = ls_marc-sernp.
  ENDIF.

* check for iuid relevance
  lv_iuid_relevant = cl_uid_iuid=>is_material_iuid_relevant(
                                  iv_matnr     = goitem-matnr
                                  iv_uii_plant = goitem-werks ).

* display column uii if iuid maintainance is enabled
* column width is given by customizing
  IF NOT ls_t377p-uid_used IS INITIAL.
    lv_len = cl_uid_cust=>get_uid_max_length( cl_uid_cust=>gc_iuid ).

* hide column if material is really NOT iuid relevant
* by setting column witdh equal to zero
  ELSEIF lv_iuid_relevant IS INITIAL.
    lv_len = 0.

* all other cases:
* set column width to maximum length given by customizing
  ELSE.
    lv_len = cl_uid_cust=>get_uid_max_length( cl_uid_cust=>gc_iuid ).
  ENDIF.

* display column uii with regard to derived column width
  ASSIGN tv_goserial-cols TO <fs_tc_cols>.
  LOOP AT <fs_tc_cols> ASSIGNING <ls_col>
      WHERE screen-group1 = cl_uid_iuid=>gc_uii.
    IF lv_len IS INITIAL.
      <ls_col>-invisible     = 1.
    ELSE.
      <ls_col>-invisible     = 0.
      <ls_col>-screen-length = lv_len.   "DEC->HEX
      <ls_col>-vislength     = lv_len.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " INIT_UII_FIELDS


*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_UII_LOOP  INPUT
*&---------------------------------------------------------------------*

MODULE pai_detail_uii_loop INPUT.

  PERFORM check_uii_field USING goitem-matnr goitem-werks
                       CHANGING goserial-uii goserial-serialno.

ENDMODULE.                 " PAI_DETAIL_UII_LOOP  INPUT


*&---------------------------------------------------------------------*
*& Form CHECK_UII_FIELD
*&---------------------------------------------------------------------*
*  consistencs checks for UII
*----------------------------------------------------------------------*

FORM check_uii_field USING iv_matnr TYPE matnr
                           iv_plant TYPE equi-uii_plant
                  CHANGING cv_uii   TYPE uii_char72
                           cv_sernr TYPE gernr.

* local data
  DATA:
    lv_matnr         TYPE matnr,
    lv_sernr         TYPE gernr,
    lv_equnr         TYPE equnr,
    lv_iuid_relevant TYPE xfeld.

* check for entered uniqui item identifier
  IF cv_uii IS INITIAL.
    "try to get UII
    IF cv_sernr IS NOT INITIAL.
      CALL METHOD cl_uid_iuid=>get_uii_of_matnr_sernr
        EXPORTING
          ip_matnr = iv_matnr
          ip_sernr = cv_sernr
        IMPORTING
          ep_uii   = cv_uii.
    ENDIF.
  ELSE.
* get equipment, material and serial number according to given uii
    CALL METHOD cl_uid_iuid=>get_matnr_sernr_of_uii
      EXPORTING
        ip_uii   = cv_uii
      IMPORTING
        ep_matnr = lv_matnr
        ep_sernr = lv_sernr
        ep_equnr = lv_equnr.

* check that entered uii belongs to given material
    IF iv_matnr NE lv_matnr    AND
       NOT iv_matnr IS INITIAL AND
       NOT lv_matnr IS INITIAL.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = 'E'
          i_msgid = 'IUID'
          i_msgno = '039'.
*        MESSAGE e039(iuid) WITH cv_uii lv_matnr.
    ENDIF.

* no serial number entered
    IF cv_sernr IS INITIAL.

*   use serial number of selected equipment master data
      IF NOT lv_sernr IS INITIAL.
        cv_sernr = lv_sernr.

*   otherwise generate valid serial number for entered uii
*   if material is iuid relevant
      ELSE.
        CALL METHOD cl_uid_iuid=>is_material_iuid_relevant
          EXPORTING
            iv_matnr         = iv_matnr
            iv_uii_plant     = iv_plant
          RECEIVING
            rv_iuid_relevant = lv_iuid_relevant.
        IF NOT lv_iuid_relevant IS INITIAL.
          PERFORM sernr_to_uii_gen CHANGING cv_uii cv_sernr.
        ENDIF.
      ENDIF.

* serial number is entered
    ELSE.

*   check if entered serial number equals serial number of equi master
      IF NOT lv_sernr IS INITIAL.
        IF lv_sernr NE cv_sernr.
          CALL METHOD oref_log->message_add
            EXPORTING
              i_msgty = 'E'
              i_msgid = 'IUID'
              i_msgno = '040'.
*        MESSAGE e040(iuid) WITH cv_sernr lv_sernr cv_uii.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_UII_FIELD


*&---------------------------------------------------------------------*
*& Form SERNR_TO_UII_GEN
*&---------------------------------------------------------------------*
*  add/create serial to given uii
*----------------------------------------------------------------------*

FORM sernr_to_uii_gen CHANGING cv_uii   TYPE uii_char72
                               cv_sernr TYPE gernr.

ENDFORM.                    " SERNR_TO_UII_GEN