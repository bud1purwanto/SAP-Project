*eject
*---------------------------------------------------------------------*
*       FORM FUSS_ERGAENZEN                                           *
*---------------------------------------------------------------------*
*       Die interne Tabelle FUSS wird mit den Werten aus MSEG, VM07M  *
*       und DM07M ergaenzt.                                           *
*---------------------------------------------------------------------*
FORM fuss_ergaenzen.

  MOVE-CORRESPONDING mseg  TO fuss.
  MOVE-CORRESPONDING dm07m TO fuss.
  MOVE-CORRESPONDING vm07m TO fuss.
  IF fcausw-xlist IS INITIAL.
    fuss-xhell = x.
  ELSE.
    fuss-xhell = rm07m-xhell.
  ENDIF.
  fuss-xlaus = xlaus.
  fuss-xselk = x.
  fuss-xprue = x.
* In MB04 we copy the items to FUSS from LOHNBEARBEITUNG > FUSS_FUELLEN
* > FUSS_ERGAENZEN. In this initial process we set fcode = SLNV in order
* to go to screen 422 (selection screen of GI components with +/-
* quantities. We recognize this initial process with fuss-fcode initial.
* All later calls of FUSS_ERGAENZEN (e.g. after batch determination)
* should keep fcode NP as we can never get back to selection screen
* after having processed a detail screen for one item.
*
* In case of function MB_CREATE_GOODS_MOVEMENT FCODE='SLNV' is useless!
  IF t158-kzbew = o AND rm07m-kzbew IS INITIAL       "399116
                    AND fuss-fcode  IS INITIAL       "399116
                    AND xmbwl       IS INITIAL.
    fuss-fcode = fcod-slnv.
  ELSE.
    fuss-fcode = fcod-np.
  ENDIF.
  IF NOT fcausw-xaenp IS INITIAL.
    fuss-fcode = fcod-kp.
  ENDIF.

ENDFORM.