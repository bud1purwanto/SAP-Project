************************************************************************
*                                                                      *
* Unterroutinen fuer die Kundenauftragsabwicklung                      *
*     Routinen für die Fehlerprotokolltabelle.                         *
*                                                                      *
*    --> Feldauswahl                                                   *
*                                                                      *
************************************************************************
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_LEERE_ZEILEN                                 *
*---------------------------------------------------------------------*
*       Feldauswahl für leere Loop-Zeilen                             *
*       Screen-group3 ungleich space                                  *
*---------------------------------------------------------------------*
form feldauswahl_leere_zeilen.

  field-symbols: <feld>.

*-Bei leeren Zeilen wird nur das Selektionskennzeichen modifiziert ---*
ENHANCEMENT-SECTION     FELDAUSWAHL_LEERE_ZEILEN_10 SPOTS ES_SAPMV45A.
  case screen-group3.
    when 'SEL'.
      screen-input = 0.
      modify screen.
* Bei VA01 nicht eingabebereit, hat modif3 = 001, früher Positionsnummer
    when '001'.
      if t180-trtyp = charh.
        screen-active = 0.
        modify screen.
      endif.
* Feld ausblenden, wenn initial (Nullenunterdrückung)
    when '007'.
      assign (screen-name) to <feld>.
      if <feld> is initial.
        screen-active = 0.
        modify screen.
      endif.
* Feld ausblenden, wenn initial (Nullenunterdrückung) Preisfindung
    when '014'.
      if screen-input = 0.
        assign (screen-name) to <feld>.
        if <feld> is initial.
          screen-active = 0.
          modify screen.
        endif.
      endif.

* Feld in leeren Zeilen stets ausblenden
    when 'ALZ'.
      screen-active = 0.
      modify screen.

*   Aktionsnummern bei nicht-Vertriebsschienen ausblenden
    when '030'.
      if not tvta-afind = charx.
        screen-active = 0.
        modify screen.
      endif.

* Rundungsmenge nicht anzeigen bei Auslieferungslieferplan
    when '032'.
      if tvak-vbklt eq vbklt_lp_ausl_auft.
        screen-active = 0.
        modify screen.
      endif.

* Wenn es keine Rechnungskorrektur ist, dann VGBEL und VGPOS ausblenden
    when '033'.
      if tvak-vbklt ne vbklt_rech_korr.
        screen-active = 0.
      else.
* Nur Ausgabe, wenn es sich um eine Rechnungskorrektur handelt
        screen-input  = 0.
      endif.
      modify screen.

* Bei leeren Zeilen Sortimentsbaustein und Produkthierarchie ausblenden
* Bei leeren Zeilen Kennzeichen, daß Pos. erweitert wurde, ausblenden
    when '035'.
      screen-active = 0.
      modify screen.

* Zusagemengen
    when '040'.
      screen-active = 0.
      modify screen.

* Felder ausblenden, wenn keine Wertkontraktpositionen vorliegen
    when '046'.
      loop at xvbap where erlre eq con_erlre_wertkontrakt and
                          updkz ne updkz_delete.
        exit.
      endloop.
      if sy-subrc <> 0.
        screen-active = 0.
        modify screen.
      endif.

  endcase.
END-ENHANCEMENT-SECTION.

endform.                    "FELDAUSWAHL_LEERE_ZEILEN


*&---------------------------------------------------------------------*
*&      Form  field_ctrl_empty_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form field_control_empty_line.

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.

    if tctrl_name eq 'TCTRL_U_ERF_AUFTRAG'.

      if screen-name eq 'RV45A-KWMENG' or
         screen-name eq 'VBAP-KWMENG' or
         screen-name eq 'VBAP-VRKME'.
        if tvak-kopgr eq 'GA'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        else.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        endif.
        if t180-trtyp eq chara.
          screen-input = 0.
        endif.
        modify screen.
        gs_screen = screen.
      endif.

      if screen-name eq 'VBAP-ZMENG' or
         screen-name eq 'VBAP-ZIEME'.
        if tvak-kopgr ne 'GA'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        else.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        endif.
        if t180-trtyp eq chara.
          screen-input = 0.
        endif.
        modify screen.
        gs_screen = screen.
      endif.

    endif.

    if screen-group4 eq 'MSR'.
      perform feldauswahl_msr changing screen.
      modify screen.
      gs_screen = screen.
    endif.

  endif.

endform.                    "field_ctrl_empty_line