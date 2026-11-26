*eject
*---------------------------------------------------------------------*
*       FORM BELEG_ERGAENZEN_INIT                                     *
*---------------------------------------------------------------------*
*       Beim Stornieren bzw. Kopieren eines Materialbeleges werden    *
*       nicht zu übernehmende Felder initialisiert.                   *
*---------------------------------------------------------------------*
FORM BELEG_ERGAENZEN_INIT.

  CLEAR: MSEG-GJAHR,
         MSEG-BUKRS,
         MSEG-XRUEM,
         MSEG-XRUEJ,
         MSEG-LGNUM,
         MSEG-BESTQ,
         MSEG-BWLVS,
         MSEG-TBNUM,
         MSEG-TBPOS,
         MSEG-XBLVS,
         MSEG-VSCHN,
         MSEG-NSCHN,
         MSEG-DYPLA,
         MSEG-UBNUM,
         MSEG-TBPRI,
         MSEG-TANUM,
         MSEG-SMBLN,
         MSEG-SJAHR,
         MSEG-SMBLP.

ENDFORM.