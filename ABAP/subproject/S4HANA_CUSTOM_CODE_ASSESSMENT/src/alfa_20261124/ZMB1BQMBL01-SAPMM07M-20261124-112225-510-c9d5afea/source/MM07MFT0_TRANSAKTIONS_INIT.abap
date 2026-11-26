*eject
*---------------------------------------------------------------------*
*       FORM TRANSAKTIONS_INIT                                        *
*---------------------------------------------------------------------*
*       Die Transaktion wird initialisiert.                           *
*---------------------------------------------------------------------*
FORM transaktions_init.

  SELECT SINGLE * FROM t000 WHERE mandt = sy-mandt.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'T000' sy-mandt.
  ENDIF.
  SELECT SINGLE * FROM tcurm.
* falls die Trennung der Wertbildung in einem künftigen Release
* verwendet werden sollte, dieses CLEAR wieder ausbauen
  CLEAR tcurm-mbval.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'CURM' sy-mandt.
  ENDIF.
ENHANCEMENT-SECTION     mm07mft0_transaktions_init_02 SPOTS es_sapmm07m.
  CLEAR: mbval, xwert.
* Trennung der Wertbildung wird deaktiviert ausgeliefert
* und kann nur in Absprache mit SAP aktiviert werden.
  PERFORM mwoff_steuerflags
          USING tcurm CHANGING xwert mbval.
END-ENHANCEMENT-SECTION.
  CALL FUNCTION 'JV_ACTIVE'
    IMPORTING
      active        = joint_venture
    EXCEPTIONS
      error_message = 4.
  IF NOT sy-subrc IS INITIAL.
    CLEAR joint_venture.
  ENDIF.
* Die Definition der Chargenebene und Zustandsverwaltung wird bestimmt
  PERFORM charge_init.
  IF tcode IS INITIAL.
    tcode = sy-tcode.
  ENDIF.
  SELECT SINGLE * FROM t158 WHERE tcode = tcode.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '158' tcode.
  ENDIF.
ENHANCEMENT-POINT mm07mft0_transaktions_init_03 SPOTS es_sapmm07m.
  IF xcanc = x AND xmbwl = x AND im_process = l.
    t158-vgart = gs_mkpf_keep-vgart.
  ENDIF.
  xsele_ombi = t158-xsele.
  IF t158-trtyp = h AND NOT t158-vgart IS INITIAL.
    SELECT SINGLE * FROM t003m WHERE vgart = t158-vgart.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '003M' t158-vgart.
    ENDIF.
  ENDIF.
  IF t158-kzbew = o.
    SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbmb
                               AND   bwart = space.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'T156N' fcod-lbmb.
    ENDIF.
    rm07m-bwartwe = t156n-bwart_next.
  ENDIF.
  anf_bild = x.
  MOVE-CORRESPONDING t158 TO new_pfsta.
  MOVE-CORRESPONDING t158 TO new_tit.
  rm07m-kzbew = t158-kzbew.
* Trennung der Wertbildung
  PERFORM check_movement             USING xwert mbval
                                           rm07m-kzbew
                                           t158-vgart
                                           brazil
                                           inventur.
  CASE t158-trtyp.
    WHEN h.
      aktyp = h.
      actvt = actvt01.
    WHEN v.
      aktyp = a.
      actvt = actvt02.
    WHEN OTHERS.
      aktyp = a.
      actvt = actvt03.
  ENDCASE.
  vgart = t158-vgart.

* Text zur Vorgangsart lesen
  SELECT SINGLE * FROM t158w WHERE spras = sy-langu
                             AND   vgart = t158-vgart.
  IF NOT sy-subrc IS INITIAL.
    CLEAR t158w-ltext.
  ENDIF.
* use movement same document types as in original document in case of
* cancellation
  IF xcanc = x AND xmbwl = x AND im_process = l.
    mkpf-blart = gs_mkpf_keep-blart.
    mkpf-blaum = gs_mkpf_keep-blaum.
    mkpf-bla2d = gs_mkpf_keep-bla2d.
  ELSE.
    mkpf-blart = t158-blart.
    mkpf-blaum = t158-blaum.
    mkpf-bla2d = t158-bla2d.
  ENDIF.
  mkpf-awsys = awsys = t000-logsys.
  vgart_old  = t158-vgart.
  ecode = fcode = fcode_next = t158-fcode.
  PERFORM rw_vorgang_setzen USING t158-vgart.
  CLEAR: xconfirm,
         rm07m-wvers1, rm07m-wvers2, rm07m-wvers3, rm07m-xnapr.
  CASE t158-wever.
    WHEN 1.
      rm07m-wvers1 = x.
    WHEN 2.
      rm07m-wvers2 = x.
    WHEN 3.
      rm07m-wvers3 = x.
  ENDCASE.
  IF t158-kzbew = b.
    GET PARAMETER ID 'SIC' FIELD sicht.
  ENDIF.
  GET PARAMETER ID 'NDR' FIELD rm07m-xnapr.
  PERFORM fcode_lesen USING fcode.
*- Steuerung Meldungen------------------------------------------------*
  GET PARAMETER ID 'MSV' FIELD msgvs.
  IF msgvs EQ space.
    msgvs = '00'.
  ENDIF.
* Steuerung bei CATT
  IMPORT cattaktiv FROM MEMORY ID 'CATT'.

*- Steuerung Kontierungsblock bei Batch-Input und CATT ---------------*
  IF NOT sy-binpt IS INITIAL AND cattaktiv IS INITIAL.
    xfull = x.
  ENDIF.
*- Aufruf Folgefunktion aus Bestellung anzeigen ----------------------*
  IF sy-calld = x.
    IMPORT rm07m-ebeln rm07m-ebelp FROM MEMORY ID 'FOLGEWE'.
    FREE MEMORY ID 'FOLGEWE'.
  ENDIF.
*- ATP-Server initialisieren                     ---------------------*
  e_atpdi-atptr = 'MB'.
  CALL FUNCTION 'DELTA_INITIALIZE'
    EXPORTING
      p_atpdi = e_atpdi
    EXCEPTIONS
      OTHERS  = 0.
*- BAdI: Get instance (BAdI MB_QUAN_CHECK_BADI interface)
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_QUAN_CHECK_BADI'
      null_instance_accepted = x
    CHANGING
      instance               = if_badi_quan_check.
*- BAdI: Get instance (BAdI MB_CHECK_LINE_BADI interface)
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_CHECK_LINE_BADI'
      null_instance_accepted = x
    CHANGING
      instance               = if_mb_check_line_badi.
*- BADI: Get instance (BAdI MB_STOR_LOC_BADI_GTS interface)  "ERP 2005
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_STOR_LOC_BADI_GTS'
      null_instance_accepted = x
    CHANGING
      instance               = if_mb_stor_loc_badi_gts.

* Check if OM switch is active - EhP 604
  IF cl_ops_switch_check=>mm_om1_sfws_sc( ) = cl_ops_switch_check=>switch_active_true.
    gv_mm_om1_sfws_sc_active = abap_true.
  ENDIF.

*------- initialisieren retail-spezifischer Daten
  PERFORM transaktions_init_retail.

ENHANCEMENT-POINT transaktions_init_01 SPOTS es_sapmm07m.
* set debug flag for assertions
  CREATE OBJECT g_assert.

*------- KAYAK Add-On active?
  PERFORM check_kyk_active(sapfskykdyapi) IF FOUND
    CHANGING gv_flag_kayak_active.

* MAA2 Begin
* if business function multi account assignment is active
  IF cl_ops_switch_check=>mm_sfws_maa( ) IS NOT INITIAL AND
     NOT go_mmim_maa_2 IS BOUND.
* get instance of class CL_MMIM_MAA_2
    go_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( ).
  ENDIF.
* MAA2 End

ENDFORM.                    "transaktions_init
ENHANCEMENT-POINT MM07MFT0_TRANSAKTIONS_INIT_04 SPOTS ES_SAPMM07M STATIC .