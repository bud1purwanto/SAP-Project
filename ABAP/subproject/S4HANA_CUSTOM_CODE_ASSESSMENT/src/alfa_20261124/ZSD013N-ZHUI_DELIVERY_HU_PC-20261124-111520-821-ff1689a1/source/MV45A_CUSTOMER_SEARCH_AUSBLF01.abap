*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_SEARCH_AUSBLF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CUSTOMER_SEARCH_AUSBLENDEN
*&---------------------------------------------------------------------*
*       If sold-to-party field is not ready for input or sales
*       document type is not customized for fulltext search
*       the input fields for fulltext trex search are hidden.
*----------------------------------------------------------------------*

FORM customer_search_ausblenden .

  TYPES: BEGIN OF gty_s_auart,
                fcs_active TYPE fcs_active,
         END   OF gty_s_auart.

  TYPE-POOLS: vrm.

  DATA: lv_dont_show_customer_search TYPE xfeld,
        lv_show_customer_search      TYPE xfeld,
        ls_auart                     TYPE gty_s_auart,
        lt_value                     TYPE vrm_values,
        ls_value                     LIKE LINE OF lt_value,
        lv_otr_text                  TYPE sotr_txt.


  SELECT SINGLE fcs_active FROM tvak INTO ls_auart WHERE auart = tvak-auart.
  IF ls_auart-fcs_active IS INITIAL.
* if fulltext search is not customized for this order type
* hide search field
    lv_dont_show_customer_search = abap_true.
  ENDIF.
* if fulltext search is customized for this order type
  LOOP AT SCREEN.
    IF screen-name = 'KUAGV-KUNNR' AND screen-input = '1'.
      lv_show_customer_search = abap_true.
    ENDIF.
    IF screen-name = 'TDS_KUNAG_SEARCH_TERM-TERM' OR screen-name = 'SEARCH_MODE'.
      IF lv_show_customer_search = abap_true AND lv_dont_show_customer_search IS INITIAL.
        screen-active = '1'.
        screen-invisible = '0'.
        screen-input = '1'.
      ELSE.
        screen-active = '0'.
        screen-invisible = '1'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

* fill dropdownbox for search mode selection
  CALL METHOD cl_wd_utilities=>get_otr_text_by_alias
    EXPORTING
      alias      = 'ERP_SLS_LO_OIF/EXACT'
      language   = sy-langu
    RECEIVING
      alias_text = lv_otr_text.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ls_value-text = lv_otr_text.
  ls_value-key = '1'.
  APPEND ls_value TO lt_value.

  CALL METHOD cl_wd_utilities=>get_otr_text_by_alias
    EXPORTING
      alias      = 'ERP_SLS_LO_OIF/FUZZY'
      language   = sy-langu
    RECEIVING
      alias_text = lv_otr_text.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ls_value-key = '2'.
  ls_value-text = lv_otr_text.
  APPEND ls_value TO lt_value.

  CALL METHOD cl_wd_utilities=>get_otr_text_by_alias
    EXPORTING
      alias      = 'ERP_SLS_LO_OIF/LINGUISTIC'
      language   = sy-langu
    RECEIVING
      alias_text = lv_otr_text.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ls_value-key = '3'.
  ls_value-text = lv_otr_text.
  APPEND ls_value TO lt_value.

*set values in dynpro
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'SEARCH_MODE'
      values = lt_value.

* set 'exact' as default
  IF search_mode IS INITIAL.
    search_mode = 1.
  ENDIF.

ENDFORM.                    " CUSTOMER_SEARCH_AUSBLENDEN