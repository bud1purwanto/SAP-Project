*---------------------------------------------------------------------*
*       FORM auftraggeber_anlegen                                     *
*---------------------------------------------------------------------*
form auftraggeber_anlegen.

  check fcode eq fcode_auftraggeber_anlegen.

  perform fcode_iaan.
  fcode = fcode_gleiche_seite.

endform.