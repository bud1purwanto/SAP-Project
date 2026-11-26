***INCLUDE MV50AF0F_FCODE_ICRE .
*---------------------------------------------------------------------*
*       FORM FCODE_ICRE                                               *
*---------------------------------------------------------------------*
*       Anzeige Warenempfänger                                        *
*---------------------------------------------------------------------*
FORM FCODE_ICRE.

  data: lf_vgbel type bstnr.
  data: ls_ekko like ekko.

  set parameter id 'LIF' field likp-lifnr.
  set parameter id 'KDY' field '/110/310'.

  check not lips-vgbel is initial.

  select single * from ekko into ls_ekko where ebeln eq lips-vgbel.
  check sy-subrc eq 0.

  set parameter id 'EKO' field ls_ekko-ekorg.

ENDFORM.