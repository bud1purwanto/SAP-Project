************************************************************************
*                                                                      *
* Unterroutinen fuer die Kundenauftragsabwicklung; K R E D I T         *
* Unterroutinen fuer die Kundenauftragsabwicklung; S T A T I S T I K   *
*                                                                      *
************************************************************************
form creditcheck using    c_update     " X - Status setzen
                          c_position   " X - aus Positionsverarb.
                 changing c_kvbuk.
  local: vbuk_kein_kreditcheck.        "kein Kreditrecheck
  local: vbuk_kredit_vfp.              "mit Bedarfen
  local: xvbap.
  local: svbap-tabix.

  data: da_subrc_incomplete like sy-subrc,
        da_subrc_yvbuk      like sy-subrc,
        da_subrc_old        like sy-subrc,
        da_subrc_new        like sy-subrc.
  data: da_svbap_tabix like svbap-tabix,
        da_subrc       like sy-subrc,
        da_no_dialog   type c,
        lv_activity(4).

  perform xvbuk_lesen(sapfv45k) using vbak-vbeln.
  if not xvbuk-cmgst     is initial          and
    ( ( tvak-klimp       ne chard     and
         tvak-babss      is initial )     or
       ( vbak-knkli      is initial   and
         not yvbak-knkli is initial ) ).
*   alter Stand war kreditrelevant, neuer erfordert keine Prüfung mehr
    clear c_kvbuk.
    CALL FUNCTION 'RV_XVBUK_MAINTAIN_CREDIT'
      EXPORTING
        c_vbeln = vbak-vbeln
        c_vbtyp = vbak-vbtyp
        skvbuk  = c_kvbuk
      TABLES
        fxvbuk  = xvbuk
        fyvbuk  = yvbuk.
    perform xvbuk_lesen(sapfv45k) using vbak-vbeln.
  endif.

*
  check tvak-klimp    eq chard or
    not tvak-babss    is initial.
* nicht im Freigabmodus
* CHECK VBUK_FREIGABE         NE CHARX
  check ( vbuk_freigabe       ne charx or
          not tvak-babss      is initial )
  and   vbuk_kein_kreditcheck ne charx
  and   call_activity         ne activity_invoice_receipt.
* AND   THIRD_PARTY_STATUS    NE CHARX.

* Retten Tabix auf XVBAP
  if not c_position is initial.
*   Bei Positionsverarbeitung nur eine Position
    move svbap-tabix to da_svbap_tabix.
    perform offene_werte_ermitteln tables open_values
                                   using  space da_svbap_tabix.
  endif.
*
  if svbuk_subrc ne 0 and
     t180-trtyp eq 'H'.
*   Bei Kontrakten muß für die Simulation Statistikfortschreibung die
*   VBUK interpretiert werden, um herauszufinden,
*   ob Angebot oder Auftrag.
*   Beim Hinzufügen ist diese aber noch initial.
    data:  da_change like upd_vbuk.
    CALL FUNCTION 'RV_XVBUK_MAINTAIN'
      EXPORTING
        f_vbeln       = vbak-vbeln
        f_vbtyp       = vbak-vbtyp
        f_vbak        = vbak
      IMPORTING
        e_vbuk_change = da_change
      TABLES
        fxvbup        = xvbup
        fxvbuk        = xvbuk
        fxvbuv        = xvbuv
        fyvbuk        = yvbuk.
    if not da_change is initial.
      upd_vbuk = charu.
    endif.
    perform xvbuk_lesen(sapfv45k) using vbak-vbeln.
  endif.

  if not incompletion_active is initial and
         c_position          is initial.
*   Das SY-SUBRC der Folgefunktion Bedarf/Verfügbarkeit zur letzten
*   Kreditprüfung wird gespeichert, wenn die Unvollständigkeit
*   durchlaufen wurde.
    perform xvbuk_lesen(sapfv45k) using vbak-vbeln.
    CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
      EXPORTING
        bvbak   = vbak
        bvbuk   = vbuk
        fofun   = fofun_beda_verfuegbar
      EXCEPTIONS
        error   = 01
        warning = 02.
    da_subrc_incomplete = sy-subrc.
  endif.

  if call_activity eq gc_activity_lord.
    lv_activity = gc_activity_lord.
  endif.

  CALL FUNCTION 'SD_ORDER_CREDIT_CHECK'
    EXPORTING
      trtyp        = t180-trtyp
      xvbak        = vbak
      yvbak        = yvbak
      xvbak_updkz  = xvbak_updkz
      yvbak_updkz  = yvbak_updkz
      tabtvak      = tvak
      update       = c_update
      recheck      = vbuk_recheck
      freigabe     = vbuk_freigabe
      svbap_tabix  = da_svbap_tabix
      kredit_check = vbuk_kein_kreditcheck
      position     = c_position
      activity     = lv_activity
    IMPORTING
      rvbak        = vbak         "Update Kopf
      returncode   = da_subrc
      rkvbuk       = kvbuk
    TABLES
      xkomv        = xkomv
      xvbap        = xvbap
      xvbep        = xvbep
      xvbkd        = xvbkd
      xvbpa        = xvbpa
      xvbfa        = xvbfa
      xvbuk        = xvbuk        "Update Status
      xvbup        = xvbup
      yvbap        = yvbap
      yvbep        = yvbep
      yvbkd        = yvbkd
      yvbpa        = yvbpa
      yvbfa        = yvbfa
      yvbuk        = yvbuk
      yvbup        = yvbup
      vbapf        = xvbapf
      xfpla        = xfpla
      yfpla        = yfpla
      xfplt        = xfplt
      yfplt        = yfplt
      ivbep1       = ivbep1
      i_s132       = open_values
    CHANGING
      upd_vbap     = upd_vbap
      upd_vbep     = upd_vbep
      upd_vbup     = upd_vbup
    EXCEPTIONS
      error        = 1.
  if sy-subrc = 1.
    CALL FUNCTION 'DIALOG_GET_STATUS'
      IMPORTING
        dialog_status = da_no_dialog.
    sy-subrc = 1.
    if not da_no_dialog is initial and
       call_activity ne gc_activity_lord.
      if c_update = charx.
        message id sy-msgid type 'E' number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                raising error_message.
      endif.
      exit.
    else.
      if kopieren ne charx.
        if call_activity ne gc_activity_lord or
           fcode eq fcode_sichern.
          message id sy-msgid type 'E' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        else.
          message id sy-msgid type 'W' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          message_collect_lord.
          gf_saving_abort = charx.
          exit.
        endif.
      else.
        if call_activity ne gc_activity_lord.
          message id sy-msgid type 'I' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          leave to transaction sy-tcode.
        else.
          message id sy-msgid type 'W' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          message_collect_lord.
        endif.
      endif.
    endif.
  endif.

  if r185d-dataloss ne space and
     not upd_vbap   is initial and
     not upd_vbup   is initial and
     not upd_vbep   is initial.
    r185d-dataloss = charx.
  endif.
  move kvbuk to c_kvbuk.

* Neuer Aufruf der Verfugbarkeitsprüfung mit neuer Kreditprüfung
* ==============================================================
*  Die Limitprüfung (dynamische oder statische Prüfung) könnte
*  fälschlicherweise auf OK sitzen, wenn aufgrund einer vorherigen
*  Zurücknahme der bestätigten Menge jetzt fälschlicherweise ohne
*  bestätigte Menge geprüft wurde.

* NICHT: bei Freigabe, im Recheck, im Positions-Check oder
*        in APO-Rückstandsbearbeitung
* Also skip this check when calling from purchase order
  if  vbuk_freigabe is initial and
      vbuk_recheck  is initial and
      not c_update  is initial and
      not c_update  eq charz   and
      not bop_flag  eq chary   and
      not call_activity eq activity_purchase.
* Mengen-Rücknahme für neuen Zustand --> da_subrc_new
    perform xvbuk_lesen(sapfv45k) using vbak-vbeln.
    CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
      EXPORTING
        bvbak   = vbak
        bvbuk   = vbuk
        fofun   = fofun_beda_verfuegbar
      EXCEPTIONS
        error   = 01
        warning = 02.
    da_subrc_new = sy-subrc.
* Nur wenn die Gesamtsituation OK (da_subrc_new) ist,
* oder eine der beiden Limitprüfungen OK ist.
    if ( da_subrc_new eq 0     or
         vbuk-cmpsa   eq chara or
         vbuk-cmpsb   eq chara    ).
* Mengen-Rücknahme für alten Zustand --> da_subrc_old
      vbukkey-mandt = vbuk-mandt.
      vbukkey-vbeln = vbuk-vbeln.
      sort yvbuk by mandt vbeln.
      read table yvbuk with key vbukkey binary search.
      da_subrc_yvbuk = sy-subrc.
      if da_subrc_yvbuk eq 0.
        move-corresponding yvbuk to *vbuk.
        CALL FUNCTION 'SD_ORDER_SUBSEQUENT_ALLOWED'
          EXPORTING
            bvbak   = vbak
            bvbuk   = *vbuk
            fofun   = fofun_beda_verfuegbar
          EXCEPTIONS
            error   = 01
            warning = 02.
        da_subrc_old = sy-subrc.
      endif.
* In allen Fällen, in denen im alten Zustand die bestätigte
* Menge zurückgenommen wurde und im neuen Zustand die Gesamtsituation
* OK ist oder eine Limitprüfung OK ist, muß neu geprüft werden.
* Für die Ermittlung des alten Zustandes gibt es folgende Fälle:
* (1) Alter Zustand aus YVBUK (da_subrc_old)
* (2) Alter Zustand vor Unvollständigkeits-Popup (da_subrc_incomplete)
* (3) Alter Zustand aus XVBUK, da kein YVBUK vorhanden ist,
*     da keine Änderung im Status stattfand (da_subrc_yvbuk),
*     aber wir sind im Ändern des Beleges (t180-trtyp).
*     Vorher UND Nachher: Rücknahme der bestätigten Menge, also
*     da_subrc_new = da_subrc_old!
*     Nehme da_subrc_new, da da_subrc_old nicht ermittelt werden konnte.
*     (Der Status der Limitprüfung (CMPSA oder CMPSB) könnte nicht
*     richtig sitzen.)
      if da_subrc_old        eq 1 or                        " Fall (1)
         da_subrc_incomplete eq 1 or                        " Fall (2)
         ( da_subrc_yvbuk    ne 0   and                     " Fall (3)
           t180-trtyp        ne 'H' and
           da_subrc_new      eq 1   ).
        vbuk_kein_kreditcheck = charx.
        vbuk_kredit_vfp       = charx.
*         no ATP if there is open (not delivered) confirmed quantity
        perform fcode_bvfp(sapmv45a).
        perform beschaffung_pruefen_ende(sapfv45e).
        clear incompletion_active.
* update = 'Y' anstelle von 'X' als Merker,
* daß wir das zweite Mal in den SD_ORDER_CREDIT_CHECK kommen!
* Im SD_ORDER_CREDIT_CHECK selber wird nach Auswertung sofort wieder
* auf 'X' zurückgesetzt!
        CALL FUNCTION 'SD_ORDER_CREDIT_CHECK'
          EXPORTING
            trtyp       = t180-trtyp
            xvbak       = vbak
            yvbak       = yvbak
            xvbak_updkz = xvbak_updkz
            yvbak_updkz = yvbak_updkz
            tabtvak     = tvak
            update      = chary
*           UPDATE      = c_update
            recheck     = vbuk_recheck
            svbap_tabix = da_svbap_tabix
            position    = c_position
          IMPORTING
            rvbak       = vbak "Update Kopf
            returncode  = da_subrc
            rkvbuk      = kvbuk
          TABLES
            xkomv       = xkomv
            xvbap       = xvbap
            xvbep       = xvbep
            xvbkd       = xvbkd
            xvbpa       = xvbpa
            xvbfa       = xvbfa
            xvbuk       = xvbuk"Update Status
            xvbup       = xvbup
            yvbap       = yvbap
            yvbep       = yvbep
            yvbkd       = yvbkd
            yvbpa       = yvbpa
            yvbfa       = yvbfa
            yvbuk       = yvbuk
            yvbup       = yvbup
            vbapf       = xvbapf
            xfpla       = xfpla
            yfpla       = yfpla
            xfplt       = xfplt
            yfplt       = yfplt
            ivbep1      = ivbep1
            i_s132      = open_values
          CHANGING
            upd_vbap    = upd_vbap
            upd_vbep    = upd_vbep
            upd_vbup    = upd_vbup.
        if r185d-dataloss ne space and
           not upd_vbap   is initial and
           not upd_vbup   is initial and
           not upd_vbep   is initial.
          r185d-dataloss = charx.
        endif.
        move kvbuk to c_kvbuk.
      endif.
    endif.
  endif.
endform.                    "CREDITCHECK