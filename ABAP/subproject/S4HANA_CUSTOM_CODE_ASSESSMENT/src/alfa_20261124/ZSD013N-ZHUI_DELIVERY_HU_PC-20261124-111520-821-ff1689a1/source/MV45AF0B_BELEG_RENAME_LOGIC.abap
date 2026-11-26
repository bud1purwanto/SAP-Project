*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_BELEG_RENAME_LOGIC
*&---------------------------------------------------------------------*

form beleg_rename_logic.

  data: ls_vbeln type tds_vbeln.
  data: ls_filter type tds_field_value,
        lt_filter type tdt_field_value.


* LOGIC: rename parent key (vbeln)
  if t180-trtyp eq charh.
    if not gr_logic_vbak is initial or
       not gr_logic_vbap is initial.
      clear ls_filter.
      ls_filter-field = 'VBELN'.
*     ls_filter-value = space.
      append ls_filter to lt_filter.
      ls_vbeln-vbeln = vbak-vbeln.
      cl_logic_access=>rename_pkey_all( exporting is_pkey_new = ls_vbeln
                                                  it_pkey_filter = lt_filter ).
      if not gr_logic_vbak is initial.
        gr_logic_vbak->switch_guid( ).
      endif.
      if not gr_logic_vbap is initial.
        gr_logic_vbap->switch_guid( ).
      endif.
    endif.
  endif.

endform.