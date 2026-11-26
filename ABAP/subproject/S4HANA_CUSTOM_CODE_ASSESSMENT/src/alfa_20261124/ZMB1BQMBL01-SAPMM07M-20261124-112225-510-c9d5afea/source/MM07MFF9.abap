  INCLUDE mm07mff9_f_beleg_ergaenzen .      " F-BELEG_ERGAENZEN
  INCLUDE mm07mff9_f_segmente_bewerten .    " F-SEGMENTE_BEWERTEN
  INCLUDE mm07mff9_f_segmente_erstellen .   " F-SEGMENTE_ERSTELLEN
  INCLUDE mm07mff9_f_segmente_erzeugen .    " F-SEGMENTE_ERZEUGEN
  INCLUDE mm07mff9_f_segmente_generieren .  " F-SEGMENTE_GENERIEREN

* replaced by class CL_MMIM_MAA
*  INCLUDE MM07MFF9_F_SEGMENTE_MAA.          " F-SEGMENTE_MAA
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAB.         " F-SEGMENTE_MAA FORM-Routines "MAA EhP4
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAD.         " F-SEGMENTE_MAA DISTRIBUTE
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAL.         " F-SEGMENTE_MAA DIST LINE
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAO.         " F-SEGMENTE_MAA DIST OPERATION
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAP.         " F-SEGMENTE_MAA DIST PROCESS Z
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAQ.         " F-SEGMENTE_MAA DIST PROCESS A
*  INCLUDE MM07MFF9_F_SEGMENTE_MAAR.         " F-SEGMENTE_MAA DIST ROUND

*&---------------------------------------------------------------------*
*&      Form mb_maa_srv_complete
*&---------------------------------------------------------------------*
  FORM mb_maa_srv_complete
                        USING    us_ebeln      TYPE mseg-ebeln
                                 us_ebelp      TYPE mseg-ebelp
                                 us_lfbja      TYPE mseg-lfbja
                                 us_lfbnr      TYPE mseg-lfbnr
                                 us_lfpos      TYPE mseg-lfpos
                                 ut_acc_srv    TYPE accounting_t
                                 ut_acc_srv_cr TYPE accounting_cr_t
                        CHANGING ct_acc        TYPE accounting_t
                                 ct_acc_cr     TYPE accounting_cr_t.


    DATA: ls_acc_srv    TYPE accounting,
          ls_acc_srv_cr TYPE accounting_cr,
          ls_acc        TYPE accounting,                    "MAA2
          ls_acc_cr     TYPE accounting_cr.                 "MAA2

**-- MMSRV in case of limits accounting data is processed in first call
*if us_lfpos = '0000'.
*  if ct_acc is not INITIAL.
*    RETURN.
*  endif.
*endif.

    LOOP AT ut_acc_srv INTO ls_acc_srv
                       WHERE ebeln = us_ebeln
                         AND ebelp = us_ebelp
                         AND lfbja = us_lfbja
                         AND lfbnr = us_lfbnr
                         AND lfpos = us_lfpos.
* MAA2 Begin EN
      READ TABLE ct_acc INTO ls_acc
              WITH KEY ebeln = ls_acc_srv-ebeln
                       ebelp = ls_acc_srv-ebelp
                       lfbja = ls_acc_srv-lfbja
                       lfbnr = ls_acc_srv-lfbnr
                       lfpos = ls_acc_srv-lfpos
                       zekkn = ls_acc_srv-zekkn.
      IF sy-subrc NE 0.
        APPEND ls_acc_srv TO ct_acc.
      ENDIF.
* MAA2 End
    ENDLOOP.

    LOOP AT ut_acc_srv_cr INTO ls_acc_srv_cr
                       WHERE ebeln = us_ebeln
                         AND ebelp = us_ebelp
                         AND lfbja = us_lfbja
                         AND lfbnr = us_lfbnr
                         AND lfpos = us_lfpos.
* MAA2 Begin EN
      READ TABLE ct_acc_cr INTO ls_acc_cr
              WITH KEY ebeln = ls_acc_srv_cr-ebeln
                       ebelp = ls_acc_srv_cr-ebelp
                       lfbja = ls_acc_srv_cr-lfbja
                       lfbnr = ls_acc_srv_cr-lfbnr
                       lfpos = ls_acc_srv_cr-lfpos
                       zekkn = ls_acc_srv_cr-zekkn
                       curtp = ls_acc_srv_cr-curtp.
      IF sy-subrc NE 0.
        APPEND ls_acc_srv_cr TO ct_acc_cr.
      ENDIF.
* MAA2 End
    ENDLOOP.
** MMSRV bug

*----
  ENDFORM.    " mb_maa_srv_complete

*eject