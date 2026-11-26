*eject
*---------------------------------------------------------------------*
*       FORM CHARGENBESTIMMUNG_WM_PP
*---------------------------------------------------------------------*
*       Die Chargenfindung für WM_PP                                  *
*---------------------------------------------------------------------*
FORM CHARGENBESTIMMUNG_WM_PP.

  CLEAR YLGORT.
  REFRESH YLGORT.
  REFRESH E_BDBATCH.
  CALL FUNCTION 'L_IM_BATCH_DETERMINATION_INT'
       EXPORTING
            I_DM07M   = DM07M
            I_MSEG    = MSEG
            I_RM07M   = RM07M
            I_ST156S  = S156S
            I_VM07M   = VM07M
            I_XMBWL   = XMBWL
            I_MKPF    = MKPF
       TABLES
            T_BDBATCH = E_BDBATCH
       EXCEPTIONS
            OTHERS    = 1.
  IF SY-SUBRC IS INITIAL.
    IF DM07M-KZUML IS INITIAL.
      YLGORT-SOBKZ = MSEG-SOBKZ.
    ELSE.
      YLGORT-SOBKZ = MSEG-UMSOK.
    ENDIF.
    LOOP AT E_BDBATCH.
      YLGORT-KZECH = PLUS.
      YLGORT-XSELP = X.
      YLGORT-ZEILE = MSEG-ZEILE.
      YLGORT-UMSOK = MSEG-UMSOK.                                 "401462
      YLGORT-MATNR = E_BDBATCH-MATNR.
      YLGORT-WERKS = E_BDBATCH-WERKS.
      YLGORT-LGORT = E_BDBATCH-LGORT.
      YLGORT-CHARG = E_BDBATCH-CHARG.
      YLGORT-MENGE = E_BDBATCH-MENGE.
      YLGORT-MEINS = E_BDBATCH-MEINS.
      YLGORT-ERFMG = E_BDBATCH-ERFMG.
      YLGORT-ERFME = E_BDBATCH-ERFME.
      APPEND YLGORT.
    ENDLOOP.
  ENDIF.

ENDFORM.