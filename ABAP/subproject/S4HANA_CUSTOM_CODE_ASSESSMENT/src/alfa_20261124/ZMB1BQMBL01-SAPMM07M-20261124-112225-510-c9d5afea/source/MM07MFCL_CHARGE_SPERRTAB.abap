*eject
*---------------------------------------------------------------------*
*       FORM   CHARGE_SPERRTAB                                        *
*---------------------------------------------------------------------*
FORM CHARGE_SPERRTAB USING I_LIFCH LIKE VM07M-LIFCH
                           I_LICHA LIKE VM07M-LICHA
                           I_LWEDT LIKE VM07M-LWEDT
                           I_VFDAT LIKE MSEG-VFDAT
                           I_HSDAT LIKE MSEG-HSDAT
                           I_QNDAT LIKE VM07M-QNDAT
                  CHANGING E_LIFCH LIKE VM07M-LIFCH
                           E_LICHA LIKE VM07M-LICHA
                           E_LWEDT LIKE VM07M-LWEDT
                           E_VFDAT LIKE MSEG-VFDAT
                           E_HSDAT LIKE MSEG-HSDAT
                           E_QNDAT LIKE VM07M-QNDAT.
  IF E_LIFCH IS INITIAL AND NOT I_LIFCH IS INITIAL.
    E_LIFCH = I_LIFCH.
  ENDIF.
  IF E_LICHA IS INITIAL AND NOT I_LICHA IS INITIAL.
    E_LICHA = I_LICHA.
  ENDIF.
  IF E_LWEDT IS INITIAL AND NOT I_LWEDT IS INITIAL.
    E_LWEDT = I_LWEDT.
  ENDIF.
  IF E_VFDAT IS INITIAL AND NOT I_VFDAT IS INITIAL.
    E_VFDAT = I_VFDAT.
  ENDIF.
  IF E_HSDAT IS INITIAL AND NOT I_HSDAT IS INITIAL.
    E_HSDAT = I_HSDAT.
  ENDIF.
  IF E_QNDAT IS INITIAL AND NOT I_QNDAT IS INITIAL.
    E_QNDAT = I_QNDAT.
  ENDIF.
ENDFORM.