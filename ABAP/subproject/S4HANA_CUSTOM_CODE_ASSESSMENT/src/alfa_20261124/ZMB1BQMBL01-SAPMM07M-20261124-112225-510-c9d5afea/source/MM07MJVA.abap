*---------------------------------------------------------------------*
*       FORM jv_crp_cal_on_off                                        *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
FORM JV_CRP_CAL_ON_OFF.

  CHECK NOT JOInT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  if if_exit_jv_crp is initial.
    CALL METHOD cl_le_badi_manager=>get_instance
      EXPORTING
          im_exit_name = 'BADI_JVA_MM07M'
      CHANGING
          ch_if_ex_le_badi = if_exit_jv_crp.
  endif.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_cal_on_off
       changing  c_dm07m       = dm07m.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM JV_price_dialog_crp                                      *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
FORM JV_PRICE_DIALOG_CRP.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_pricing_dialog
       exporting i_trtyp        = t158-trtyp
                 i_aktyp        = aktyp
                 i_fcode        = fcode
                 i_mkpf         = mkpf
                 i_mseg         = mseg
       changing  c_dm07m        = dm07m.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM JV_PRICING_CRP                                           *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
FORM JV_PRICING_CRP.

  data: ld_caltyp type c.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.


  LOOP AT YMSEG WHERE ZEILE = MSEG-ZEILE.
    IF MSEG-ERFMG = YMSEG-ERFMG.
      ld_CALTYP = A.
    ELSE.
      ld_CALTYP = B.
    ENDIF.
  ENDLOOP.

  check mseg-bustw = 'WA01' or   "goods issue             "note 635387
        mseg-bustw = 'WA04' or   "goods transfer          "note 635387
        mseg-bustw = 'WA15'.     "fixed asset             "note 635387

  if if_exit_jv_crp is initial.                           "note 635387
    CALL METHOD cl_le_badi_manager=>get_instance          "note 635387
      EXPORTING                                           "note 635387
          im_exit_name = 'BADI_JVA_MM07M'                 "note 635387
      CHANGING                                            "note 635387
          ch_if_ex_le_badi = if_exit_jv_crp.              "note 635387
                                                          "note 635387
    check not if_exit_jv_crp is initial.                  "note 635387
                                                          "note 635387
    call method if_exit_jv_crp->jv_crp_cal_on_off         "note 635387
       changing  c_dm07m       = dm07m.                   "note 635387
  endif.                                                  "note 635387

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_pricing
       exporting i_trtyp        = t158-trtyp
                 i_s156s        = s156s
                 i_t001         = t001
                 i_aktyp        = aktyp
                 i_mkpf         = mkpf
                 i_caltyp       = ld_caltyp
       changing  c_mseg         = mseg
                 c_dm07m        = dm07m
                 c_cobl         = cobl
                 c_fcode        = fcode.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM JV_read_crp_data                                         *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
FORM JV_READ_CRP_DATA.

  CHECK NOT JOINT_VENTURE IS INITIAL.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM JV_save_crpcal                                           *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
FORM JV_SAVE_CRPCAL.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_save
       exporting i_dm07m        = dm07m.

ENDFORM.
*                                                                     *
*       FORM JV_CRP_POST.                                             *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_CRP_POST.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_post.

ENDFORM.
*eject
*                                                                     *
*       FORM JV_KNUMV_GET_NEXT.                                       *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_KNUMV_GET_NEXT.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->jv_crp_knumv_get
       changing  c_mkpf       = xmkpf.


ENDFORM.
*                                                                     *
*       FORM JV_F_SEG_ERSTELLEN_1                                     *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_F_SEG_ERSTELLEN_1.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  CALL METHOD cl_le_badi_manager=>get_instance
    EXPORTING
        im_exit_name = 'BADI_JVA_MM07M'
    CHANGING
        ch_if_ex_le_badi = if_exit_jv_ers.

  check not if_exit_jv_ers is initial.

  call method if_exit_jv_ers->jva_fseg_erst_1
       exporting i_accit       = xaccit.


ENDFORM.
*                                                                     *
*       FORM JV_F_SEG_ERSTELLEN_2                                     *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_F_SEG_ERSTELLEN_2.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  check not if_exit_jv_ers is initial.

  call method if_exit_jv_ers->jva_fseg_erst_2
       exporting i_t156x       = t156x
                 i_mseg        = zmseg
                 i_t156w       = x156w
       changing  c_accit       = xaccit.

ENDFORM.
*                                                                     *
*       FORM JV_F_SEG_ERZEUGEN_1
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_F_SEG_ERZEUGEN_1.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  CALL METHOD cl_le_badi_manager=>get_instance
    EXPORTING
        im_exit_name = 'BADI_JVA_MM07M'
    CHANGING
        ch_if_ex_le_badi = if_exit_jv_erz.

  check not if_exit_jv_erz is initial.

  call method if_exit_jv_erz->jva_fseg_erz_1
       exporting i_hkont        = xaccit-hkont.


ENDFORM.
*                                                                     *
*       FORM JV_F_SEG_ERZEUGEN_2
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_F_SEG_ERZEUGEN_2.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  check not if_exit_jv_erz is initial.

  call method if_exit_jv_erz->jva_fseg_erz_2
       exporting i_t156x        = t156x
                 i_mseg         = zmseg
                 i_t156w        = x156w
       changing  c_hkont        = xaccit-hkont.

ENDFORM.
*eject
*                                                                     *
*       FORM JV_DETERMINE_RECID                                       *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_DETERMINE_RECID.

  data: gd_exit_jv_rec type ref to if_ex_BADI_JVA_Mm07m.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  CALL METHOD cl_le_badi_manager=>get_instance
    EXPORTING
        im_exit_name = 'BADI_JVA_MM07M'
    CHANGING
        ch_if_ex_le_badi = gd_exit_jv_rec.

  check not gd_exit_jv_rec is initial.

  call method gd_exit_jv_rec->jva_determine_recid
       exporting i_dm07m        = dm07m
                 i_mseg         = zmseg
                 i_t156w        = x156w
                 i_mkpf         = mkpf
       changing  c_accit        = xaccit.


ENDFORM.
*                                                                     *
*       FORM JV_KOMV_CLEAR                                            *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_KOMV_CLEAR.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  check not if_exit_jv_crp is initial.

  call method if_exit_jv_crp->JV_CRP_KOMV_CLEAR.

ENDFORM.
*                                                                     *
*       FORM JV_UMLAGER_KONDITIONEN_A                                 *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_UMLAGER_KONDITIONEN_A.

  data: gd_exit_jv_uma type ref to if_ex_BADI_JVA_Mm07m.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  if sy-tcode(4) = 'MIGO'.                                    "<<MIGO
    read table ymseg into mseg with key zeile = zdm07m-zeild. "<<MIGO
    dm07m = zdm07m.                                           "<<MIGO
    perform jv_pricing_crp.                                   "<<MIGO
    loop at zdm07m where zeild = dm07m-zeild.                 "<<MIGO
      zdm07m = dm07m.                                         "<<MIGO
      modify zdm07m.                                          "<<MIGO
    endloop.                                                  "<<MIGO
  endif.                                                      "<<MIGO

  class cl_le_badi_manager definition load.

  CALL METHOD cl_le_badi_manager=>get_instance
    EXPORTING
        im_exit_name = 'BADI_JVA_MM07M'
    CHANGING
        ch_if_ex_le_badi = gd_exit_jv_uma.

  check not gd_exit_jv_uma is initial.

  call method gd_exit_jv_uma->JVA_UML_CONDA
    exporting
      I_aktyp     = aktyp
      i_kzuml     = zdm07m-kzuml
      i_zeile_1   = zmseg-zeile
      i_zeile_2   = xmseg-zeile .



ENDFORM.
*                                                                     *
*       FORM JV_UMLAGER_KONDITIONEN_B                                 *
*                                                                     *
*       Joint Venture Accounting                                      *
*                                                                     *
FORM JV_UMLAGER_KONDITIONEN_B.

  data: gd_exit_jv_umb type ref to if_ex_BADI_JVA_Mm07m.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  CALL METHOD cl_le_badi_manager=>get_instance
    EXPORTING
        im_exit_name = 'BADI_JVA_MM07M'
    CHANGING
        ch_if_ex_le_badi = gd_exit_jv_umb.

  check not gd_exit_jv_umb is initial.

  call method gd_exit_jv_umb->JVA_UML_CONDb
    exporting
      i_aktyp      = aktyp.


ENDFORM.
*eject
*&---------------------------------------------------------------------*
*&      Form  JV_COBL_SCREEN
*&---------------------------------------------------------------------*
*       Add JV-specific COBL-fields.
*----------------------------------------------------------------------*
FORM JV_COBL_SCREEN.

  CHECK NOT JOINT_VENTURE IS INITIAL.

  int_coblf-required    = '0'.
  int_coblf-input       = '1'.
  int_coblf-output      = '1'.
  int_coblf-intens      = '0'.
  int_coblf-active      = '1'.
  int_coblf-invisible   = '0'.

  int_coblf-fdnam       = 'CONDI' .
  append int_coblf.
  int_coblf-fdnam       = 'CRPCAL'.
  append int_coblf.

ENDFORM.                    " JV_COBL_SCREEN
*&---------------------------------------------------------------------*
*&      Form  jv_m_seg_zuordnen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_M_XUMBW  text
*----------------------------------------------------------------------*
FORM jv_m_seg_zuordnen  USING    P_M_XUMBW type c.      "525347

  data yfbuz_dmbtr type bseg-dmbtr.                     "525347

  CHECK NOT JOINT_VENTURE IS INITIAL.                   "525347
ENHANCEMENT-POINT OIH_MM07MJVA_01 SPOTS ES_MM07MJVA.

* First: add up values                                  "525347
  clear yfbuz_dmbtr.                                    "525347
  LOOP AT yfbuz WHERE zeile = ymbuz-zeile               "525347
                AND   xumbw = P_M_XUMBW.                "525347
ENHANCEMENT-POINT OIH_MM07MJVA_02 SPOTS ES_MM07MJVA.

    IF yfbuz-buzid = m AND NOT xmseg-xauto = x.         "525347
      if yfbuz-shkzg = 'S'.                             "525347
        subtract yfbuz-dmbtr from yfbuz_dmbtr.          "640430
      else.                                             "525347
        add yfbuz-dmbtr to yfbuz_dmbtr.                 "640430
      endif.                                            "525347
    ENDIF.                                              "525347
    IF yfbuz-buzid = u AND xmseg-xauto = x.             "525347
      if yfbuz-shkzg = 'S'.                             "525347
        subtract yfbuz-dmbtr from yfbuz_dmbtr.          "640430
      else.                                             "525347
        add yfbuz-dmbtr to yfbuz_dmbtr.                 "640430
      endif.                                            "525347
    ENDIF.                                              "525347
  ENDLOOP.                                              "525347

* second: reposition to first entry and replace value   "525347
* no returncode-handling necessary!                     "525347
  LOOP AT yfbuz WHERE zeile = ymbuz-zeile               "525347
                AND   xumbw = P_M_XUMBW.                "525347
ENHANCEMENT-POINT OIH_MM07MJVA_03 SPOTS ES_MM07MJVA.

    IF yfbuz-buzid = m AND NOT xmseg-xauto = x.         "525347
      EXIT.                                             "525347
    ENDIF.                                              "525347
    IF yfbuz-buzid = u AND xmseg-xauto = x.             "525347
      EXIT.                                             "525347
    ENDIF.                                              "525347
  ENDLOOP.                                              "525347
  if yfbuz_dmbtr < 0.                                   "525347
     yfbuz-dmbtr = - yfbuz_dmbtr.                       "525347
  else.                                                 "525347
     yfbuz-dmbtr =   yfbuz_dmbtr.                       "525347
  endif.                                                "525347
ENDFORM.                    " jv_m_seg_zuordnen         "525347


*---------------------------------------------------------------------*
*       FORM jv_maintain_account                                      *
*---------------------------------------------------------------------*
*       Joint Venture Accounting   Note 1472370                       *
*---------------------------------------------------------------------*
FORM JV_MAINTAIN_ACCOUNT.

  data: l_tabix like sy-tabix.
        l_tabix = sy-tabix.

  CHECK NOT JOInT_VENTURE IS INITIAL.

  class cl_le_badi_manager definition load.

  if if_exit_jv_crp is initial.
    CALL METHOD cl_le_badi_manager=>get_instance
      EXPORTING
          im_exit_name = 'BADI_JVA_MM07M'
      CHANGING
          ch_if_ex_le_badi = if_exit_jv_crp.
  endif.

  check not if_exit_jv_crp is initial.

CALL METHOD if_exit_jv_crp->jv_maintain_account
  EXPORTING
    c_dm07m = dm07m
  CHANGING
    ymbuz   = ymbuz.
* retrieve the old value of sy-tabix

    if l_tabix <> sy-tabix.
        sy-tabix = l_tabix.
    endif.

  ENDFORM.