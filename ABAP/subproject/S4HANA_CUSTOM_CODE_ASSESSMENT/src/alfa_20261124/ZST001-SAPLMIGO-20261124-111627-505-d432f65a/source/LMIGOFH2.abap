*&---------------------------------------------------------------------*
*&  Include           LMIGOFH2                                         *
*   F4 helps implementation                                            *
*&---------------------------------------------------------------------*

CLASS lcl_migo_field_help IMPLEMENTATION.

  METHOD f4_help_field.
    DATA: lv_field(20) TYPE c,
          lv_line      TYPE i.

    GET CURSOR FIELD lv_field LINE lv_line.

    CASE lv_field.
* batch
      WHEN 'GOITEM-CHARG'.
        oref_field_help->f4_help_charg( lv_line ).
* vendor batch
      WHEN 'GOITEM-LICHA'.
        oref_field_help->f4_help_licha( lv_line ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.

  ENDMETHOD.                    "f4_help_field


  METHOD f4_help_charg.

    TYPES:
      BEGIN OF lty_component,
        ebeln           TYPE bstnr,
        ebelp           TYPE ebelp,
        matnr           TYPE matnr,
        werks           TYPE werks_d,
        charg           TYPE charg_d,
      END OF lty_component,

      BEGIN OF lty_header_charg,
        matnr           TYPE matnr,
        charg           TYPE charg_d,
      END OF lty_header_charg,

      BEGIN OF lty_subsequent,
        ebeln             TYPE bstnr,
        ebelp             TYPE ebelp,
        matnr             TYPE matnr,
        charg             TYPE charg_d,
        mblnr             TYPE mblnr,
        mjahr             TYPE mjahr,
        menge             TYPE menge_d,
        meins             TYPE meins,
    END OF lty_subsequent.

    DATA:
      ls_goitem         TYPE goitem,
      ls_goitem_parent  TYPE goitem,

      lt_component      TYPE STANDARD TABLE OF lty_component,
      lt_subsequent     TYPE STANDARD TABLE OF lty_subsequent,
      lt_dseltab        TYPE STANDARD TABLE OF dselc,
      ls_dseltab        TYPE dselc.

* BEGIN of block: classification search help
    ls_dseltab-fldname = 'MATNR'.
    ls_dseltab-fldinh  = ls_goitem-matnr.
    APPEND ls_dseltab TO lt_dseltab.
    ls_dseltab-fldname = 'WERKS'.
    ls_dseltab-fldinh  = ls_goitem-werks.
    APPEND ls_dseltab TO lt_dseltab.
    EXPORT dseltab FROM lt_dseltab TO MEMORY ID 'DSELTAB'.
* END of block: classification search help

    IF cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) IS NOT INITIAL.
*detail tab
      IF iv_line IS INITIAL.
        ls_goitem = goitem.
* table control
      ELSE.
        lcl_migo_globals=>kernel->line_get(
          EXPORTING
            i_line = iv_line
          IMPORTING
            es_goitem = ls_goitem ).
      ENDIF.

      CASE lcl_migo_globals=>kernel->s_action-migo_mode.
        WHEN 'GR'.
* component material for subcontracting PO
          IF ls_goitem-xlbtype EQ 'C'.
            lcl_migo_globals=>kernel->get_parent_item(
                 EXPORTING
                  i_global_counter = ls_goitem-parent
                 IMPORTING
                    e_goitem = ls_goitem_parent ).
            IF ls_goitem_parent-ebeln IS NOT INITIAL AND
               ls_goitem_parent-ebelp IS NOT INITIAL.
              SELECT ebeln ebelp kmatnr kwerks kcharg
                FROM chvw_inc_pur
                INTO TABLE lt_component
                WHERE ebeln  EQ ls_goitem_parent-ebeln
                  AND ebelp  EQ ls_goitem_parent-ebelp
                  AND kmatnr EQ ls_goitem-matnr.
            ENDIF.
          ENDIF.

        WHEN 'GS'.
* header material
          IF ls_goitem-xlbtype EQ 'P'.
            IF goitem-parent IS NOT INITIAL.
              lcl_migo_globals=>kernel->get_parent_item(
                EXPORTING
                  i_global_counter = goitem-parent
                IMPORTING
                  e_goitem = ls_goitem ).
            ENDIF.
            IF ls_goitem-ebeln IS NOT INITIAL AND
               ls_goitem-ebelp IS NOT INITIAL.
              SELECT *
                FROM chvw
                INTO CORRESPONDING FIELDS OF TABLE lt_subsequent
                WHERE ebeln EQ ls_goitem-ebeln
                  AND ebelp EQ ls_goitem-ebelp
                  AND matnr EQ ls_goitem-matnr.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.

    IF lt_subsequent IS NOT INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = 'CHARG'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'GOITEM-CHARG'
          value_org   = 'S'
          stepl       = iv_line
        TABLES
          value_tab   = lt_subsequent
        EXCEPTIONS
          OTHERS      = 0.
    ELSEIF lt_component IS NOT INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = 'CHARG'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'GOITEM-CHARG'
          value_org   = 'S'
          stepl       = iv_line
        TABLES
          value_tab   = lt_component
        EXCEPTIONS
          OTHERS      = 0.
    ELSE.
      CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
        EXPORTING
          tabname     = 'GOITEM'
          fieldname   = 'CHARG'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'MCH1-CHARG'
        EXCEPTIONS
          OTHERS      = 0.
    ENDIF.

  ENDMETHOD.                    "f4_help_charg

********************************************************************************************
*Search-Help for the field Vendor Batch                                                    *
********************************************************************************************
  METHOD f4_help_licha.
    TYPES:
     BEGIN OF lty_licha,
       licha             TYPE lichn,
       ebeln             TYPE bstnr,
       ebelp             TYPE ebelp,
     END OF lty_licha.

    DATA:
      lt_licha         TYPE STANDARD TABLE OF lty_licha,
      ls_goitem         TYPE goitem.
    IF cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) IS NOT INITIAL.
* detail tab
      IF iv_line IS INITIAL.
        ls_goitem = goitem.
* table control
      ELSE.
        lcl_migo_globals=>kernel->line_get(
          EXPORTING
            i_line = iv_line
          IMPORTING
            es_goitem = ls_goitem ).
      ENDIF.
      SELECT licha ebeln ebelp
        FROM mch_pur_temp
        INTO CORRESPONDING FIELDS OF TABLE lt_licha
        WHERE ebeln EQ ls_goitem-ebeln
          AND ebelp EQ ls_goitem-ebelp.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'LICHA'
          dynpprog        = sy-repid
          dynpnr          = sy-dynnr
          dynprofield     = 'GOITEM-LICHA'
          value_org       = 'S'
        TABLES
          value_tab       = lt_licha
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ELSE.                                                     "n1611424
*     If the BF is inactive, user should at least get an info "n1611424
*     MSG DH801: No values found                              "n1611424
      MESSAGE s801(dh).                                       "n1611424
    ENDIF.
  ENDMETHOD.                    "F4_HELP_LICHA
ENDCLASS.                    "lcl_migo_field_help IMPLEMENTATION