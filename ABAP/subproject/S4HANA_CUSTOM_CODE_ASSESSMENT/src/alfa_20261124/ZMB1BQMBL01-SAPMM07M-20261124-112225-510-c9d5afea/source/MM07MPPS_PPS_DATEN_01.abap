*---------------------------------------------------------------------*
*       FORM PPS_DATEN_01                                             *
*---------------------------------------------------------------------*
*       Die Daten des Auftrages werden übernommen.                    *
*---------------------------------------------------------------------*
FORM pps_daten_01.

  mseg-aufps  = xfbefu-posnr.
  vm07m-bumrn = xfbefu-umren.
  vm07m-bumrz = xfbefu-umrez.
  dm07m-remng = xfbefu-armng.
  dm07m-rewrt = xfbefu-arwrt.
* Durchreichen des Kanbankennzeichens an das WM (D024693 MK)
* Wenn es einmal sitzt, soll es auch so bleiben
  IF dm07m-kanba IS INITIAL.
    dm07m-kanba = xfbefu-kbnkz.
  ENDIF.
  dm07m-parwk = xfbefu-parwk.
  dm07m-parbw = xfbefu-parbw.                               "304109
  dm07m-fchar = xfbefu-charg.
  vm07m-bwaer = xfbefu-bwaer.                               "154336
  vm07m-elikz_old = xfbefu-elikz.
  IF NOT xfbefu-kzvbr IS INITIAL.
    dm07m-knttp = xfbefu-kzvbr.
  ENDIF.
  vm07m-bdter = xfbefu-dglts.
  IF xfbefu-sobkz = e AND NOT xfbefu-kdauf IS INITIAL.
    mseg-mat_kdauf = xfbefu-kdauf.
    mseg-mat_kdpos = xfbefu-kdpos.
    CLEAR: mseg-kdauf, mseg-kdpos.
  ENDIF.
  IF xfbefu-sobkz = q AND NOT xfbefu-ps_psp_pnr IS INITIAL.
    mseg-mat_pspnr = xfbefu-ps_psp_pnr.
    CLEAR mseg-ps_psp_pnr.
  ENDIF.

ENDFORM.                    "PPS_DATEN_01