*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_BEW_PRUEFEN                                   *
*---------------------------------------------------------------------*
*        Die Bewegungsart, der Sonderbestand und die Bildauswahl      *
*        werden geprüft.                                              *
*---------------------------------------------------------------------*
FORM fusszeile_bew_pruefen.

  PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                               mseg-xauto.
  PERFORM sonderbestkz_pruefen(sapfm07m) USING mseg-sobkz
                                              vm07m-sobfi
                                              vm07m-soblo
                                              vm07m-sobvo.
  PERFORM bildauswahl_pruefen(sapfm07m) USING mseg-bwart
                                              mseg-sobkz.
  PERFORM bewegungstext_lesen(sapfm07m) USING mseg-bwart
                                              mseg-sobkz
                                              mseg-kzbew
                                              mseg-kzzug
                                              mseg-kzvbr
                                             dm07m-btext.
ENDFORM.