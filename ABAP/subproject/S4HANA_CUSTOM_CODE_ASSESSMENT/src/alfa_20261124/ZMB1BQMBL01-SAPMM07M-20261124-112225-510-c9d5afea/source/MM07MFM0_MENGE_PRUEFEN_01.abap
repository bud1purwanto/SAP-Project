*---------------------------------------------------------------------*
*       FORM MENGE_PRUEFEN_01                                         *
*---------------------------------------------------------------------*
*       Routine aufgenommen, da aus Module MENGE_PRUEFEN              *
*       mehrere FORM-Routinen aufgerufen werden, die dann im          *
*       LMBWLU04 z. T. gefehlt haben. Bitte FORM-Aufrufe hier ein-    *
*       tragen und nicht unter MODULE. Nur so ist gewährleistet, daß  *
*       diese auch ohne Änderung im MB_CREATE_GOODS_MOVEMENT          *
*       prozessiert werden.                                           *
*---------------------------------------------------------------------*
FORM menge_pruefen_01
                 USING IS_ENHANCEMENT TYPE ISU_MENGE_PRUEFEN_01."IS2ERP

  DATA: LS_ISU_MENGE_PRUEFEN TYPE ISU_MENGE_PRUEFEN.        "IS2ERP

ENHANCEMENT-POINT MENGE_PRUEFEN_01_01 SPOTS ES_SAPMM07M.

* Umbewertung Charge: keine Verfügbarkeitsprüfung erforderlich
  CHECK t156-kzbwa NE kzbwa-07.

* fill quantites for MAA items on PO item level               "MAA2
  DATA: dm07m_kont TYPE DM07M,                                "MAA2
        dm07m_changed  TYPE c.                                "MAA2
  FIELD-SYMBOLS: <xebefu>     TYPE ebefu,                     "MAA2
                 <ls_po_data> TYPE cl_mmim_maa_2=>ts_po_data. "MAA2
  IF NOT dm07m-xhistma IS INITIAL AND NOT xmbwl IS INITIAL AND"MAA2
     NOT mseg-maa_urzei IS INITIAL.                           "MAA2
    READ TABLE XEBEFU WITH KEY ebeln = mseg-ebeln             "MAA2
                               ebelp = mseg-ebelp             "MAA2
                               lfbja = mseg-lfbja             "MAA2
                               lfbnr = mseg-lfbnr             "MAA2
                               lfpos = mseg-lfpos             "MAA2
                               ASSIGNING <xebefu>.            "MAA2
    IF sy-subrc IS INITIAL.                                   "MAA2
      dm07m_kont = dm07m.                                     "MAA2
      MOVE-CORRESPONDING <xebefu> TO dm07m.                   "MAA2
      LOOP AT go_mmim_maa_2->gt_po_data ASSIGNING <ls_po_data>"MAA2
        WHERE key-ebeln = mseg-ebeln                          "MAA2
          AND key-ebelp = mseg-ebelp.                         "MAA2
        MOVE  <ls_po_data>-item_bpbmg  to dm07m-bpbmg.        "MAA2
        EXIT.                                                 "MAA2
      ENDLOOP.                                                "MAA2
      dm07m_changed = 'X'.                                    "MAA2
    ENDIF.                                                    "MAA2
  ENDIF.                                                      "MAA2

  PERFORM menge_pruefen(sapfm07m)
                                  USING ls_isu_menge_pruefen. "IS2ERP

  IF dm07m_changed = 'X'.                                     "MAA2
    dm07m = dm07m_kont.                                       "MAA2
    clear dm07m_changed.                                      "MAA2
  ENDIF.                                                      "MAA2

  PERFORM mengen_korrelation.
*  PERFORM mindesthaltbarkeit_pruefen.       "DEL SW ALRK043086
  IF NOT dm07m-kanba IS INITIAL.
    PERFORM kanban_menge_pruefen.
  ENDIF.
  PERFORM qss_pruefen.
ENHANCEMENT-POINT MENGE_PRUEFEN_01_02 SPOTS ES_SAPMM07M.
* Call BAdI: MB_QUAN_CHECK_BADI
  IF NOT if_badi_quan_check IS INITIAL.                          "538117
    CALL METHOD if_badi_quan_check->check_item_data
      EXPORTING
        is_mkpf    =  mkpf
        is_mseg    =  mseg
        is_dm07m   =  dm07m
        is_vm07m   =  vm07m
        i_trtyp    =  t063-trtyp.
  ENDIF.                                                         "538117
  PERFORM zero_quantity_elikz_check.                        "note 494142
ENHANCEMENT-POINT MENGE_PRUEFEN_01_03 SPOTS ES_SAPMM07M.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZERO_QUANTITY_ELIKZ_CHECK                          "494142
*&---------------------------------------------------------------------*
* Check if only ELIKZ will be set while quantity equals zero
* and batch will be created during that posting. And material
* ledger is active.
*----------------------------------------------------------------------*
FORM zero_quantity_elikz_check.
  if not mseg-charg is initial.
    IF ( ( mseg-mengu IS INITIAL AND NOT mseg-wertu IS INITIAL
        AND mseg-vkwrt = 0 ) OR
        ( mseg-erfmg = 0 AND mseg-menge = 0 AND NOT
        ( mseg-mengu IS INITIAL AND NOT mseg-wertu IS INITIAL ) ) ).
        IF ( mseg-kzear <> vm07m-kzear_old ) or
           ( mseg-elikz <> vm07m-elikz_old ).
          if not vm07m-mlmaa is initial.
            read table xmcha with key matnr = mseg-matnr
                                      werks = mseg-werks
                                      charg = mseg-charg.
            if sy-subrc is initial.
              if not xmcha-rmcha is initial.
                message e425 with mseg-matnr mseg-charg mseg-werks.
              endif.
            endif.
          endif.
        endif.
      endif.
    endif.
ENDFORM.