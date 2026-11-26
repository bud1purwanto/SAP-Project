*---------------------------------------------------------------------*
*       FORM PARAMETER_BEW_SOND_SETZEN                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  MSEG                                                          *
*  -->  MSEGK                                                         *
*  -->  DM07M                                                         *
*  -->  XBBEFU                                                        *
*---------------------------------------------------------------------*
FORM PARAMETER_BEW_SOND_SETZEN    USING MSEG  STRUCTURE MSEG
                                        MSEGK STRUCTURE MSEGK
                                        DM07M STRUCTURE DM07M
                                        XBBEFU STRUCTURE BBEFU.
* OM EhP 604
  IF gv_mm_om1_sfws_sc_active = abap_true.
    IF t156-bustr EQ bustr_64A.
      CLEAR MSEG-SOBKZ.
*     MSEG-UMSOK = XBBEFU-UMSOK.
      MSEG-LIFNR = XBBEFU-EMLIF.
    ENDIF.
  ENDIF.
*/ OM EhP 604

* Begin of SIT
  IF MSEG-SOBKZ = T OR MSEG-UMSOK = T.
  ELSE.
    MSEG-SOBKZ = MSEGK-SOBKZ = XBBEFU-UMSOK.
    MSEG-UMSOK = XBBEFU-SOBKZ.
  ENDIF.
* End of SIT
  IF NOT MSEG-SOBKZ = E AND NOT MSEG-SOBKZ = Q AND NOT MSEG-SOBKZ = T.
    CLEAR: MSEG-KZBWS, MSEGK-KZBWS.
  ENDIF.

  DM07M-UMKZBWS = XBBEFU-KZBWS.
  IF MSEG-SOBKZ = E.
    MSEG-MAT_KDAUF = MSEGK-MAT_KDAUF = XBBEFU-KDAUF.
    MSEG-MAT_KDPOS = MSEGK-MAT_KDPOS = XBBEFU-KDPOS.
  ELSEIF MSEG-SOBKZ = T.
    MSEG-MAT_KDAUF = MSEGK-MAT_KDAUF.                      "SIT
    MSEG-MAT_KDPOS = MSEGK-MAT_KDPOS.                      "SIT
  ELSEIF MSEG-SOBKZ = Q.
    MSEG-MAT_PSPNR = MSEGK-MAT_PSPNR = XBBEFU-PS_PSP_PNR.
  ENDIF.
  IF MSEG-KZVBR = A.
    CLEAR DM07M-KONTO.
  ELSEIF MSEG-KZVBR = E OR MSEG-KZVBR = P.
    IF NOT MSEG-UMSOK = E AND NOT MSEG-UMSOK = Q AND
       NOT DM07M-UMKZBWS IS INITIAL.
      MSEG-KZVBR = V.
      CLEAR: MSEG-KDAUF, MSEGK-KDAUF, MSEG-KDPOS, MSEGK-KDPOS,
             MSEG-PS_PSP_PNR, MSEGK-PS_PSP_PNR, MSEG-KZBWS, MSEGK-KZBWS.
    ENDIF.
  ENDIF.
ENDFORM.