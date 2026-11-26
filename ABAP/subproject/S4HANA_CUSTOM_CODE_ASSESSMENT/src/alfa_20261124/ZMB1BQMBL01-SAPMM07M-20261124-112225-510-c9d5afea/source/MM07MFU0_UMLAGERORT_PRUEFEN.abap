*eject
*---------------------------------------------------------------------*
*       FORM UMLAGERORT_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Der Umlagerlagerort wird gelesen.                             *
*---------------------------------------------------------------------*
FORM umlagerort_pruefen USING ut001l LIKE t001l
                              u-bwart LIKE mseg-bwart.

  xumla = x.
  CLEAR xt001l.
  xt001l-werks = ut001l-werks.
  xt001l-lgort = ut001l-lgort.
  xt001l-xlong = ut001l-xlong.
  PERFORM lagerort_pruefen(sapfm07m) USING xt001l
                                           u-bwart.
  ut001l = xt001l.
  CLEAR xumla.

ENDFORM.