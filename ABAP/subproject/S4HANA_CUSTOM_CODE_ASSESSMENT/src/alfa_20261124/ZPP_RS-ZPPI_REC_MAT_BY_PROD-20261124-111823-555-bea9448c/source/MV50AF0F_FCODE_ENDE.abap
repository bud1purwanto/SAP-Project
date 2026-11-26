***INCLUDE MV50AF0F_FCODE_ENDE .
*---------------------------------------------------------------------*
*       FORM FCODE_ENDE                                               *
*---------------------------------------------------------------------*
*       Ende der Transaktion                                          *
*---------------------------------------------------------------------*
form fcode_ende.

* leave wirkt nur innerhalb einer gecallten Transaktion
  leave.
  if not gf_param_tcode is initial.                         "v_n_532957
    leave to transaction gf_param_tcode.
  else.
    leave to transaction sy-tcode.
  endif.                                                    "^_n_532957

endform.