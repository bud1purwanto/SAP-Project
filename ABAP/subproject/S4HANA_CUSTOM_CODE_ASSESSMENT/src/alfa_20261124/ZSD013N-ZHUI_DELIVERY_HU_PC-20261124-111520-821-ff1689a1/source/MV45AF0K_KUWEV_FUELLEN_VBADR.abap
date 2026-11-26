*---------------------------------------------------------------------*
*       FORM KUWEV_FUELLEN_VBADR                                      *
*---------------------------------------------------------------------*
*       Warenempfänger mit Werten aus Adresse überlagern              *
*---------------------------------------------------------------------*
FORM kuwev_fuellen_vbadr.

  DATA: da_cityc LIKE kuwev-cityc,
        da_counc LIKE kuwev-counc.
* City- und County Code merken
  da_cityc = kuwev-cityc.
  da_counc = kuwev-counc.
  kuwev-lzone = xvbpa-lzone.
  IF NOT xvbpa-adrnr IS INITIAL AND
     xvbpa-adrnr = xvbadr-adrnr.
    MOVE-CORRESPONDING xvbadr TO kuwev.
  ENDIF.
* City- und County Code wieder aufnehmen
  kuwev-cityc = da_cityc.
  kuwev-counc = da_counc.
  kuwev-ablad = xvbpa-ablad.
  kuwev-knref = xvbpa-knref.
  IF NOT xvbpa-xcpdk IS INITIAL.       "eu-tax
    kuwev-stceg = xvbpa-stceg.
  ENDIF.
  PERFORM kuwev-txtpa_ermitteln.

ENDFORM.