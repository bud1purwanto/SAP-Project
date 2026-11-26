*eject
*---------------------------------------------------------------------*
*       FORM UMLAGERWERK_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Das Umlagerwerk wird gelesen.                                 *
*---------------------------------------------------------------------*
FORM umlagerwerk_pruefen USING u-werks LIKE mseg-werks
                                 xauth TYPE c.
  PERFORM werk_pruefen(sapfm07m) USING    xauth
                                          u-werks
                                      dm07m-umbwk
                                      dm07m-umbwm
                                      dm07m-umxei
                                      dm07m-umxbn
                                      dm07m-umxvk
                                      dm07m-umbuk
                                      dm07m-umkpl
                                      dm07m-umper
                                      dm07m-umwae
                                       mkpf-budat
                                      dm07m-umgja
                                      dm07m-ummon
                                      dm07m-umxrm
                                      dm07m-umxrj
                                      dm07m-umlfg
                                      dm07m-umlfm
                                      dm07m-umfab
                                      dm07m-umkzxab.
  mseg-parbu    = dm07m-umbuk.
* Field which are needed in UMLAGERMAT_PRUEFEN for the check on
* negative stocks if the segment does not exist. These data
* are filled again in SEGMENTDATEN_MAT_UMLAGERUNG,
* but this is too late.
  dm07m-umxlaut = t159l-xlaut.
  dm07m-umxsm   = t159l-xsmng.                                   "382382
  dm07m-umxsv   = t159l-xsvng.                                   "382382
  dm07m-umxsk   = t159l-xskng.                                   "382382
  dm07m-umxso   = t159l-xsong.                                   "382382
  dm07m-umxsw   = t159l-xswng.                                   "382382
  dm07m-umxse   = t159l-xseng.                                   "382382
  dm07m-umxsq   = t159l-xsqng.                                   "382382
ENDFORM.