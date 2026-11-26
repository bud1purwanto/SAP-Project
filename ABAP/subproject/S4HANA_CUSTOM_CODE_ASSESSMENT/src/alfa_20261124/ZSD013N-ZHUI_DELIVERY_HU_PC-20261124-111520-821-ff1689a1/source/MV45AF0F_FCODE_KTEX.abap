*---------------------------------------------------------------------*
*       FORM FCODE_KTEX_SUB                                           *
*---------------------------------------------------------------------*
*       Übergang zum Kopftextbild                                     *
*       FCODE_KTEX gibt es noch wg. Abwärtskompatibilität             *
*---------------------------------------------------------------------*
form fcode_ktex_sub.

  perform vbak_fuellen_tvcom(sapfv45k).

endform.

form fcode_ktex.

  perform xthead_uebersicht_k_ansteuern(sapfv45t)
                                       using tvak-txtgr
                                             chara
                                             vbak-vbeln.

  perform vbak_fuellen_tvcom(sapfv45k).

endform.