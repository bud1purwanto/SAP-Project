*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAP_WAERK_SETZEN_G2                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VBAP-WAERK_SETZEN_G2  INPUT
*&---------------------------------------------------------------------*
MODULE VBAP-WAERK_SETZEN_G2 INPUT.

* Module is used for temporary adjustment of waerk
* field transport of vbap-netwr gives an error when
* vbap-waerk and vbap-netwr do not match
* vbap-waerk is cleared here to prevent error 00 011
* it is redetermined in second call of this module after
* the field transport

  data: da_save_waerk like vbap-waerk.

  if da_save_waerk is initial.
    da_save_waerk = vbap-waerk.
    IF NOT XVBAK-AGUPDA IS INITIAL OR
     ( VBAP-NETWR <> *VBAP-NETWR AND
       NOT VBAP-NETWR IS INITIAL ) OR
       VBAP-WAERK <> *VBAP-waerk.
      clear vbap-waerk.
    endif.
  else.
    if vbap-waerk is initial.
      vbap-waerk = da_save_waerk.
    endif.
    clear da_save_waerk.
  endif.

ENDMODULE.                 " VBAP-WAERK_SETZEN  INPUT