*&---------------------------------------------------------------------*
*&      Form  TCTRL_U_ERF_KONFIG_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Erfassungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM tctrl_u_erf_konfig_init.

  DATA: da_tfill LIKE sy-tabix,
        da_vislength LIKE screen-length,
        da_name LIKE screen-name,
        da_invisible,
        da_zaehler(2) TYPE n,
        da_numc2(2) TYPE n,
        da_tabix LIKE sy-tabix,
        da_fieldname(50),
        ds_column TYPE scxtab_column.
  FIELD-SYMBOLS: <mname>, <mwert>.

  DESCRIBE TABLE ivbap LINES da_tfill.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF t185f-trtyp NE 'A'.
    da_tfill = da_tfill + 1.
  ENDIF.
  tctrl_u_erf_konfig-lines    = da_tfill.
  tctrl_u_erf_konfig-top_line = ivbap_tabix_zeile_1.
  tctrl_name = 'TCTRL_U_ERF_KONFIG'.

* Prüfen welche Spalten ausgeblendet werden müssen und evtl. visuelle
* Spaltenbreite setzen

  LOOP AT SCREEN.
    da_name = screen-name.
    IF da_name(1) = '*'.
      SHIFT da_name LEFT.
    ENDIF.
* Länge aus XMERKMAL lesen
    IF da_name(11) = 'RV45A-MWERT'.
      da_numc2 = da_name+11(2).
      CLEAR: da_fieldname.
      CONCATENATE 'RV45A-MNAM' da_numc2 INTO da_fieldname.
      ASSIGN (da_fieldname) TO <mname>.
      CLEAR: da_fieldname.
      CONCATENATE 'RV45A-MWERT' da_numc2 INTO da_fieldname.
      ASSIGN (da_fieldname) TO <mwert>.

      CLEAR: da_vislength.
      IF NOT <mname> IS INITIAL.
        da_tabix = da_numc2.
        PERFORM xmerkmal_lesen           USING <mname>
                                               charx
                                               da_tabix
                                      CHANGING sy-subrc.
        IF sy-subrc IS INITIAL.
          da_vislength = xmerkmal-cleng.
        ENDIF.

* Spalten ausblenden
      ELSE.
        da_invisible = charx.
      ENDIF.
      PERFORM tctrl_spalten_konfig TABLES tctrl_u_erf_konfig-cols
                            USING  da_name
                                   da_invisible
                                   da_vislength.
    ENDIF.
* Zielmengen-Felder einblenden/ausblenden
    IF da_name = 'VBAP-ZMENG'
      OR da_name = 'VBAP-ZIEME'.
      IF vbak-vbtyp CA vbtyp_ohne_einteilung.
        CLEAR da_invisible.
        CLEAR da_vislength.
      ELSE.
        da_invisible = charx.
        CLEAR da_vislength.
      ENDIF.
      PERFORM tctrl_spalten_konfig TABLES tctrl_u_erf_konfig-cols
                            USING  da_name
                                   da_invisible
                                   da_vislength.
    ENDIF.
* Auftragsmengen-Felder einblenden/ausblenden
    IF da_name = 'RV45A-KWMENG'
      OR da_name = 'VBAP-VRKME'.
      IF vbak-vbtyp CA vbtyp_ohne_einteilung.
        da_invisible = charx.
        CLEAR da_vislength.
      ELSE.
        CLEAR da_invisible.
        CLEAR da_vislength.
      ENDIF.
      PERFORM tctrl_spalten_konfig TABLES tctrl_u_erf_konfig-cols
                            USING  da_name
                                   da_invisible
                                   da_vislength.
    ENDIF.

    CLEAR: da_invisible, da_vislength.

* da zu 4.6A die VBAP-MATNR im TC nach hinten gerutscht ist, muß sie
* - außer für Batch-Input - ausgeblendet werden (nur Spaltenüberschrift
* ausblenden genügt nicht)
    IF screen-group3 =  '059' AND screen-name = '*VBAP-MATNR'.
      IF tvak-ermat NE chara AND sy-binpt EQ space.
*       es wird ohne Materialbestellnummer gearbeitet
        LOOP AT tctrl_u_erf_konfig-cols INTO ds_column.
          IF ds_column-screen-name = 'VBAP-MATNR'.
            ds_column-invisible = 1.
            MODIFY tctrl_u_erf_konfig-cols FROM ds_column.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Merkmalstabelle Übersichtsbild initialisieren
  REFRESH xmwert.

ENDFORM.                    "tctrl_u_erf_konfig_init