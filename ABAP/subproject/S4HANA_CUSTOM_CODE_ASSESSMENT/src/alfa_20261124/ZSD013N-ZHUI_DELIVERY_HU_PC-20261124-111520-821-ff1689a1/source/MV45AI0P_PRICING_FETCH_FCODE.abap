*----------------------------------------------------------------------*
***INCLUDE MV45AI0P_PRICING_FETCH_FCODE .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PRICING_FETCH_FCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module pricing_fetch_fcode input.

  call function 'PRICING_FETCH_FCODE'
       importing
            okcode = fcode.

  if fcode is initial.
    fcode = 'ENT1'.
  endif.

endmodule.                             " PRICING_FETCH_FCODE  INPUT