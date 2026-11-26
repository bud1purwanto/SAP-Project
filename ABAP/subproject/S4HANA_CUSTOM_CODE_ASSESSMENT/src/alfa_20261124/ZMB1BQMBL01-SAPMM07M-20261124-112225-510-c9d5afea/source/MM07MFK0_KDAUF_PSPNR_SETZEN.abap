*---------------------------------------------------------------------*
*       FORM KDAUF_PSPNR_SETZEN                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  BUSTW                                                         *
*  -->  BUZID                                                         *
*  -->  SOBKZ                                                         *
*  -->  KDAUF                                                         *
*  -->  KDPOS                                                         *
*  -->  MAT_KDAUF                                                     *
*  -->  MAT_KDPOS                                                     *
*  -->  PSPNR                                                         *
*  -->  MAT_PSPNR                                                     *
*---------------------------------------------------------------------*
form kdauf_pspnr_setzen using bustw like xaccit-bustw
                              buzid like xaccit-buzid
                              sobkz like xaccit-sobkz
                              kdauf like xaccit-kdauf
                              kdpos like xaccit-kdpos
                              mat_kdauf like xaccit-mat_kdauf
                              mat_kdpos like xaccit-mat_kdpos
                              pspnr like xaccit-ps_psp_pnr
                              mat_pspnr like xaccit-mat_pspnr.
  if ( bustw = bustw_wa04 or bustw = bustw_wa06 ) and
     buzid ne u and buzid ne m and buzid ne p.     " Note 205959
    if sobkz = e.
      data:kdauf_save like xaccit-kdauf.
      data:kdpos_save like xaccit-kdpos.
      kdauf_save = kdauf.
      kdpos_save = kdpos.
      kdauf = mat_kdauf.
      kdpos = mat_kdpos.
      mat_kdauf = kdauf_save.
      mat_kdpos = kdpos_save.
    elseif sobkz = q.
      data:pspnr_save like xaccit-ps_psp_pnr.
      pspnr_save = pspnr.
      pspnr = mat_pspnr.
      mat_pspnr = pspnr_save.
    endif.
  endif.
* The data from the material are copied to the accounting
* fields for the accrural posting in case of valuated special stock
* if this is no transfer posting and not related to purchase
* order or production order.
  if   x156w-vorsl = vorsl_gbb and not mseg-kzbws is initial
         and dm07m-kzuml is initial and mseg-umsok is initial
         and bustw = bustw_wa01 and
         ( mseg-kzbew <> b and mseg-kzbew <> f ).
    if mseg-sobkz = e and xaccit-kdauf is initial
                             and   dm07m-fausw+12(1) ne minus.
      xaccit-kdauf = xaccit-mat_kdauf.
      xaccit-kdpos = xaccit-mat_kdpos.
    elseif mseg-sobkz = q and xaccit-ps_psp_pnr is initial
                              and dm07m-fausw+11(1) ne minus.
      xaccit-ps_psp_pnr = mat_pspnr.
    endif.
  endif.
* note 0364581
* clear on xaccit-kdauf or ps_psp_pnr is not necessary if first
* clear on xaccit-mat_kdauf and mat_pspnr
*  IF BUSTW = 'WA04' AND  X156W-VORSL = 'GBB'
*       AND  ( MSEG-SOBKZ EQ E OR MSEG-SOBKZ EQ Q )
*       AND  ( MSEG-UMSOK EQ E OR MSEG-UMSOK EQ Q )
*    AND MSEG-KZBWS IS INITIAL AND DM07M-UMKZBWS IS INITIAL.
*    IF NOT XACCIT-MAT_KDAUF IS INITIAL.
*      CLEAR: XACCIT-KDAUF, XACCIT-KDPOS.
*    ENDIF.
*    IF NOT XACCIT-MAT_PSPNR IS INITIAL.
*      CLEAR: XACCIT-PS_PSP_PNR.
*    ENDIF.
*  ENDIF.

*When entering transfer postings from Sales Order to Project or
*vice versa, both kdauf and ps_psp_pnr are filled for both GBB lines.
*Thus here clearing one of the fields is necessary.
*Otherwise, there will be double CO Objects send to AC.
  IF BUSTW = 'WA04' AND  X156W-VORSL = 'GBB'                 "HW 485589
     AND MSEG-KZBWS IS INITIAL AND DM07M-UMKZBWS IS INITIAL. "HW 485589
     IF MSEG-SOBKZ = E AND MSEG-UMSOK = Q.                   "HW 485589
       CLEAR: XACCIT-PS_PSP_PNR.                             "HW 485589
     ENDIF.                                                  "HW 485589
     IF MSEG-SOBKZ = Q AND MSEG-UMSOK = E.                   "HW 485589
       CLEAR: XACCIT-KDAUF, XACCIT-KDPOS.                    "HW 485589
     ENDIF.                                                  "HW 485589
  ENDIF.                                                     "HW 485589

  IF MSEG-KZBWS IS INITIAL AND DM07M-UMKZBWS IS INITIAL.
    CLEAR: XACCIT-MAT_KDAUF, XACCIT-MAT_KDPOS, XACCIT-MAT_PSPNR.
  ENDIF.
endform.