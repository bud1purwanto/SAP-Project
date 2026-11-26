*----------------------------------------------------------------------*
*   INCLUDE MV45AF0X_XMERKMAL_BEARBEITEN                               *
*----------------------------------------------------------------------*
FORM xmerkmal_bearbeiten.

  DATA: da_subrc,
        da_mnam LIKE rv45a-mnam01,
        da_mbez LIKE rv45a-mbez01,
        da_numc2(2) TYPE n,
        da_fieldname(50).

  FIELD-SYMBOLS: <mname>, <mbez>.

* Eintrag löschen
  IF char_va_sel-atnam is initial.
    DELETE xmerkmal where INDEX = sy-stepl.
    CLEAR da_mnam.
    CLEAR da_mbez.
  ELSE.
* prüfen ob das Merkmal geändert wurde / Eintrag neu aufbauen
    READ TABLE xmerkmal WITH KEY INDEX = sy-stepl.
    IF sy-subrc = 0 and
       xmerkmal-atnam <> char_va_sel-atnam.
      DELETE xmerkmal where INDEX = sy-stepl.
    ENDIF.
* Merkmal aus interner Tabelle lesen
    PERFORM xmerkmal_lesen           USING char_va_sel-atnam
                                           charx
                                           sy-stepl
                                           da_subrc.
    IF da_subrc is initial.
      xmerkmal-cleng = char_va_sel-cleng.
      MODIFY xmerkmal transporting cleng where INDEX = sy-stepl.
      da_mnam = char_va_sel-atnam.
      da_mbez = xmerkmal-atbez.
    ENDIF.
    CLEAR da_mbez.
  ENDIF.

* Wert in RV45A Felder übernehmen
  da_numc2 = sy-stepl.
  CLEAR: da_fieldname.
  CONCATENATE 'RV45A-MNAM' da_numc2 INTO da_fieldname.
  ASSIGN (da_fieldname) TO <mname>.
  CLEAR: da_fieldname.
  CONCATENATE 'RV45A-MBEZ' da_numc2 INTO da_fieldname.
  ASSIGN (da_fieldname) TO <mbez>.
  <mname> = da_mnam.
  <mbez>  = da_mbez.

ENDFORM.