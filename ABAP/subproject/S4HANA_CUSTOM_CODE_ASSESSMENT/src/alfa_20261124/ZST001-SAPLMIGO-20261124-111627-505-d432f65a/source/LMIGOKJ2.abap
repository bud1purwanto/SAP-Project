*----------------------------------------------------------------------*
*   INCLUDE LMIGOKJ2                                                   *
*----------------------------------------------------------------------*
* Official number South America
*----------------------------------------------------------------------*
METHOD off_number_default.
  CHECK lcl_migo_globals=>kernel->s_action-create = abap_true.

  CALL FUNCTION 'OFF_NUMBER_MIGO_DEFAULTS'
       EXPORTING
            i_bukrs       = is_goitem-bukrs_for_stock
            i_bwart       = is_goitem-bwart
            i_werks       = is_goitem-werks
            i_lgort       = is_goitem-lgort
            i_return_flag = lcl_migo_globals=>kernel->s_action-return
       CHANGING
            c_xblnr       = r_xblnr.
ENDMETHOD.