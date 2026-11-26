*---------------------------------------------------------------------*
*      FORM KANBAN_MENGE_PRÜFEN                                       *
*---------------------------------------------------------------------*
*      Mengen für Kanbanbehälter prüfen                               *
*---------------------------------------------------------------------*
FORM kanban_menge_pruefen.

  DATA: exitflag,
        mengen LIKE pkch OCCURS 0 WITH HEADER LINE.
  DATA: lv_ewm_active(1) TYPE c.

* Do not execute in simulation mode of MB_CREATE_GOODS_MOVEMENT
* as the entered data are lost and would have to be reentered during
* posting.
  " CHECK xsimu IS INITIAL.                                       "211374

  REFRESH mengen.
  CLEAR mengen.
  mengen-pkcmg = mseg-menge.
  mengen-charg = mseg-charg.
  APPEND mengen.

* don't update kanban if it is posted to the transit stock
  check mseg-bwart ne '313'.

  CALL METHOD cl_ewm_switch_check=>man_sfws_sc_ewm_man
  receiving
    rv_active = lv_ewm_active
    .
ENHANCEMENT-SECTION     sapmm07m_21 SPOTS es_sapmm07m.
* This function is called e.g. by MIGO.
* For Ext. Procurement with WM, the storage bin is returned here
* in lgpla.

  if lv_ewm_active IS INITIAL.
  CALL FUNCTION 'PK_CHECK_CONTAINER'
    EXPORTING
      aufnr          = mseg-aufnr
      rsnum          = mseg-rsnum
      ebeln          = mseg-ebeln
      ebelp          = mseg-ebelp
      xstbw          = dm07m-xstbw
      shkzg          = mseg-shkzg
      kzuml          = dm07m-kzuml
      pabnum         = vm07m-pabnum
      pabpos         = vm07m-pabpos
      pkkey          = vm07m-pkkey
      aktyp          = aktyp
      xsimu_iv       = xsimu
      mblnr          = mseg-mblnr
      lgort          = mseg-lgort
      matnr          = mseg-matnr
      kbnkz          = dm07m-kanba
      xbapi_iv       = xbapi
    IMPORTING
      kbndr          = vm07m-knbdr
      e_exit_flag    = exitflag
    TABLES
      mengen_chargen = mengen
    CHANGING
      cv_lgnum        = mseg-lgnum
      cv_lgtyp        = mseg-lgtyp
      cv_lgpla        = mseg-lgpla
      cv_umlgt        = dm07m-umlgt
      cv_umlgp        = dm07m-umlgp.
  IF NOT exitflag IS INITIAL.
    MESSAGE e188.
  ENDIF.
  else.
   CALL FUNCTION 'PK_CHECK_CONTAINER'
    EXPORTING
      aufnr          = mseg-aufnr
      rsnum          = mseg-rsnum
      ebeln          = mseg-ebeln
      ebelp          = mseg-ebelp
      xstbw          = dm07m-xstbw
      shkzg          = mseg-shkzg
      kzuml          = dm07m-kzuml
      pabnum         = vm07m-pabnum
      pabpos         = vm07m-pabpos
      pkkey          = vm07m-pkkey
      aktyp          = aktyp
      xsimu_iv       = xsimu
      mblnr          = mseg-mblnr
      vbeln_ewm      = vm07m-vbeln
      vbelp_ewm      = vm07m-vbelp
      lgort          = mseg-lgort
      matnr          = mseg-matnr
      kbnkz          = dm07m-kanba
      xbapi_iv       = xbapi
    IMPORTING
      kbndr          = vm07m-knbdr
      e_exit_flag    = exitflag
    TABLES
      mengen_chargen = mengen
    CHANGING
      cv_lgnum        = mseg-lgnum
      cv_lgtyp        = mseg-lgtyp
      cv_lgpla        = mseg-lgpla
      cv_umlgt        = dm07m-umlgt
      cv_umlgp        = dm07m-umlgp.
  IF NOT exitflag IS INITIAL.
    MESSAGE e188.
  ENDIF.
  endif.
END-ENHANCEMENT-SECTION.

ENDFORM.                    "kanban_menge_pruefen