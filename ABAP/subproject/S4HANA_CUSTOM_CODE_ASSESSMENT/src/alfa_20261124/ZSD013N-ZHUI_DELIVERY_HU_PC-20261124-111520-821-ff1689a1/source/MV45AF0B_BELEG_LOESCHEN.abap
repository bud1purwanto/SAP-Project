*---------------------------------------------------------------------*
*       FORM BELEG_LOESCHEN                                           *
*---------------------------------------------------------------------*
*       Der Beleg wird gelöscht.                                      *
*---------------------------------------------------------------------*
FORM beleg_loeschen.

  DATA: da_tfill LIKE sy-tfill,
        da_answer, da_answer_jfmip,
        updkz_jfmip LIKE vbapd-updkz VALUE 'D'.
  DATA: l_sd_sales_exit   TYPE REF TO if_ex_badi_sd_sales,
          active TYPE xfeld.
  data: lv_nodel type char1.


  IF t180-trtyp = charh.
    MESSAGE s007.
    message_collect_lord.
    EXIT.
  ENDIF.

* Löschberechtigung prüfen
  PERFORM berechtigung_pruefen USING    actvt_06
                                        vbak-auart
                                        space
                               CHANGING sy-subrc.
  IF sy-subrc = 0.
    PERFORM xvbap_loeschen_pruefen_alle(sapfv45p) USING sy-subrc.
enhancement-point beleg_loeschen_10 spots es_sapmv45a.
    CASE sy-subrc.
      WHEN 0.
        da_answer = charj.
      WHEN 4.
        IF call_activity EQ gc_activity_lord.
          da_answer = charn.
          MESSAGE s006.
          message_collect_lord.
        ELSE.
          CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
            EXPORTING
              titel         = text-100
              diagnosetext1 = text-101
              diagnosetext2 = text-102
              textline1     = text-103
              textline2     = text-104
            IMPORTING
              answer        = da_answer.
          IF da_answer NE charj.
            EXIT.
          ELSE.
          ENDIF.
        ENDIF.
      WHEN 8.
        da_answer = charn.
        MESSAGE s006.
        message_collect_lord.
    ENDCASE.

* BADI_SD_TO_FM
    IF da_answer EQ charj.
      CALL FUNCTION 'GET_HANDLE_SD_TO_FM'
        IMPORTING
          handle = inst_badi_sd_to_fm
          active = active_badi_sd_to_fm.
      IF active_badi_sd_to_fm EQ charx.
        DATA: xvbap_jfmip TYPE va_vbapvb_t,
              yvbap_jfmip TYPE va_vbapvb_t,
              wa_vbap     TYPE vbapvb.
        LOOP AT xvbap INTO wa_vbap.
          wa_vbap-updkz = 'D'.
          APPEND wa_vbap TO yvbap_jfmip.
          APPEND wa_vbap TO xvbap_jfmip.
        ENDLOOP.
        CALL METHOD inst_badi_sd_to_fm->mv45af0b_call_s008
          EXPORTING
            call_function = call_function
          CHANGING
            xvbak         = vbak
            yvbak         = yvbak
            xkomv         = xkomv[]
            xvbap         = xvbap_jfmip[]
            xvbep         = xvbep[]
            xvbkd         = xvbkd[]
            xvbpa         = xvbpa[]
            xvbfa         = xvbfa[]
            xvbuk         = xvbuk[]
            xvbup         = xvbup[]
            yvbap         = yvbap_jfmip[]
            yvbep         = yvbep[]
            yvbkd         = yvbkd[]
            yvbpa         = yvbpa[]
            yvbfa         = yvbfa[]
            yvbuk         = yvbuk[]
            yvbup         = yvbup[]
            vbapf         = xvbapf[]
            xfpla         = xfpla[]
            yfpla         = yfpla[]
            xfplt         = xfplt[]
            yfplt         = yfplt[]
            xvbak_updkz   = updkz_jfmip
            yvbak_updkz   = updkz_jfmip
            trtyp         = t180-trtyp
            da_answer     = da_answer_jfmip.
        IF da_answer_jfmip EQ '2'.
          da_answer = charn.
          MESSAGE s899 WITH 'Document cannot be deleted, '
                            'because of error in Funds-Management, '
                            'see log.'.
        ENDIF.
      ENDIF.
    ENDIF.

*   Bei zugeordneter Servicemeldung muß Kundenauftragsnummer dort
*   entfernt werden
*   !! Darf erst aufgerufen werden, wenn klar ist, daß gelöscht wird !!
    IF NOT vbak-qmnum IS INITIAL AND
       da_answer = charj.
      CALL FUNCTION 'IQS0_REFRESH_SD_ORDER_LINK_DB'
        EXPORTING
          i_qmnum             = vbak-qmnum
          i_vbeln             = vbak-vbeln
        EXCEPTIONS
          invalid_entry       = 1
          foreign_lock        = 2
          status_not_possible = 3
          update_not_possible = 4.

*     Gegebenenfalls den Kundenauftrag nicht löschen
      CASE sy-subrc.
        WHEN 2.
          da_answer = charn.
          MESSAGE s758 WITH vbak-qmnum.
        WHEN 3.
          da_answer = charn.
          MESSAGE s759 WITH vbak-qmnum.
        WHEN 4.
          da_answer = charn.
          MESSAGE s759 WITH vbak-qmnum.
      ENDCASE.

    ENDIF.

*   Bei Gruppenkontrakten zuerst alle Unterkontrakte löschen
    IF vbak-vbtyp EQ vbtyp_gruko.
      DESCRIBE TABLE gruko LINES sy-tfill.
      IF sy-tfill > 0.
        da_answer = charn.
        MESSAGE s006.
        message_collect_lord.
      ENDIF.
    ENDIF.

*   LOGIC
    clear lv_nodel.
    perform beleg_loeschen_pruefen_logic changing lv_nodel.
    if not lv_nodel is initial.
      da_answer = charn.
    endif.

    IF da_answer = charj.
      PERFORM xvbap_markieren_alle(sapfv45p).
      LOOP AT xvbap WHERE updkz NE updkz_delete
                      AND uepos IS INITIAL.
        svbap-tabix = sy-tabix.
        PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
        PERFORM xvbap_loeschen_gruppe_pruefen(sapfv45p)
                                              USING vbap-posnr
                                              CHANGING sy-subrc.
        IF sy-subrc = 0.
          PERFORM xvbap_loeschen_gruppe(sapfv45p) USING vbap-posnr.
        ENDIF.
      ENDLOOP.
      DESCRIBE TABLE ivbap LINES da_tfill.
      IF da_tfill = 0.
        PERFORM vbak_loeschen(sapfv45k).
      ELSE.
        PERFORM ivbap-selkz_init_alle(sapfv45p).
      ENDIF.
    ENDIF.
  ENDIF.
  IF xvbak_updkz NE updkz_delete.
    IF call_activity EQ gc_activity_lord.
      EXIT.
    ENDIF.
    IF call_function IS INITIAL.
      fcode = fcode_default_uebersicht_1.
      PERFORM funktion_ausfuehren.
    ELSE.
      sy-subrc = 1.
      EXIT.
    ENDIF.
  ELSE.
    IF call_bapi_simulation_mode IS INITIAL.
      CALL FUNCTION 'RV_MESSAGES_DELETE'
        EXPORTING
          msg_objky         = xobjky
          delete_all_status = charx.

*   Delete CPE Formula Documents
      CALL FUNCTION 'CPE_ERP_FORMULA_DELETE'
        EXPORTING
          iv_knumv          = vbak-knumv
        EXCEPTIONS
          cpe_not_active    = 0
          formula_not_found = 0.

enhancement-point beleg_loeschen_01 spots es_sapmv45a.

enhancement-point beleg_loeschen_11 spots es_sapmv45a.

*     LOGIC
      perform beleg_loeschen_logic.

*   Call SD Sales BAdI
      CALL FUNCTION 'GET_HANDLE_SD_SALES'
        IMPORTING
          handle = l_sd_sales_exit
          active = active.
      IF active = charx.
        CALL METHOD l_sd_sales_exit->delete_document
          EXPORTING
            ft180  = t180
          CHANGING
            fvbak  = vbak
            fxvbap = xvbap[]
            fxvbkd = xvbkd[]
            fxvbpa = xvbpa[]
            fxvbep = xvbep[]
            fxvbuk = xvbuk[].
      ENDIF.

enhancement-point beleg_loeschen_20 spots es_sapmv45a.
*   Userexit
      PERFORM userexit_delete_document.
      INCLUDE MV45AF0B_INTTAB_ANALYZE_1.

      IF call_activity EQ gc_activity_lord.
        IF gf_synchron IS INITIAL.
          PERFORM beleg_sichern USING space
                                      sy-subrc.
        ELSE.
          PERFORM beleg_sichern USING charx
                                      sy-subrc.
        ENDIF.
      ELSE.
        PERFORM beleg_sichern USING space
                                    sy-subrc.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "BELEG_LOESCHEN



*&---------------------------------------------------------------------*
*&      Form  beleg_loeschen_lord
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UF_SYNCHRON   text
*      -->UF_DELETED    text
*----------------------------------------------------------------------*
FORM beleg_loeschen_lord USING uf_synchron
                               uf_no_commit
                               uf_deleted.

  DATA: da_vbeln_save TYPE vbeln_va.

  CLEAR da_vbeln_save.
  EXPORT da_vbeln_save TO MEMORY ID container_sales_doc.

  CLEAR uf_deleted.

  gf_synchron = uf_synchron.
  gf_no_commit = uf_no_commit.

  PERFORM beleg_loeschen.

  CLEAR gf_no_commit.
  CLEAR gf_synchron.

  IMPORT da_vbeln_save TO da_vbeln_save
         FROM MEMORY ID container_sales_doc.

  IF NOT da_vbeln_save IS INITIAL.
    uf_deleted = charx.
  ENDIF.

ENDFORM.                    "beleg_loeschen_lord