*&---------------------------------------------------------------------*
*&      Form  RV45A-MUEBS_LESEN                                        *
*&---------------------------------------------------------------------*
*       Die Merkmale werden aus der Merkmalsübersicht gelesen          *
*----------------------------------------------------------------------*
FORM rv45a-muebs_lesen USING    us_error
                       CHANGING ch_subrc.

  DATA: da_zaehler(2) TYPE n,
        da_subrc LIKE sy-subrc,
        da_numc2(2) TYPE n,
        da_fieldname(50).

ENHANCEMENT-POINT RV45A-MUEBS_LESEN_05 SPOTS ES_SAPMV45A STATIC.
  FIELD-SYMBOLS: <mname>, <mbez>.

ENHANCEMENT-POINT RV45A-MUEBS_LESEN_01 SPOTS ES_SAPMV45A.
  REFRESH xmerkmal.

* RV45A-MNAMnn löschen
  DO ueco_col_count TIMES.
    da_numc2 = sy-index.
    CLEAR: da_fieldname.
    CONCATENATE 'RV45A-MNAM' da_numc2 INTO da_fieldname.
    ASSIGN (da_fieldname) TO <mname>.
    CLEAR: da_fieldname.
    CONCATENATE 'RV45A-MBEZ' da_numc2 INTO da_fieldname.
    ASSIGN (da_fieldname) TO <mbez>.
    CLEAR <mname>.
    CLEAR <mbez>.
  ENDDO.

  CLEAR vbmuet-bezei.

  CHECK NOT rv45a-muebs IS INITIAL AND
        NOT rv45a-muebs = '**********'.

* Prüfen ob Merkmalsanzeige existiert
  SELECT SINGLE * FROM vbmuet WHERE muebs = rv45a-muebs.
  IF NOT sy-subrc IS INITIAL.
    IF us_error = charx.
      MESSAGE e214(v2) WITH rv45a-muebs.
    ELSE.
      MESSAGE i214(v2) WITH rv45a-muebs.
      ch_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT RV45A-MUEBS_LESEN_02 SPOTS ES_SAPMV45A.
* Text zur Merkmalsübersicht holen
  CLEAR vbmuet.
  SELECT SINGLE * FROM vbmuet WHERE muebs = rv45a-muebs AND
                                    spras = sy-langu.
* VBMUEZ lesen und RV45A-MNAMnn füllen
  CLEAR da_zaehler.
  SELECT * FROM vbmuez WHERE muebs = rv45a-muebs.
    da_zaehler = da_zaehler + 1.
ENHANCEMENT-SECTION     RV45A-MUEBS_LESEN_03 SPOTS ES_SAPMV45A.
    PERFORM xmerkmal_lesen           USING vbmuez-atnam
                                           charx
                                           da_zaehler
                                           da_subrc.
    IF da_subrc <> 0.
      da_zaehler = da_zaehler - 1.
    ELSE.
      xmerkmal-cleng = vbmuez-cleng.
      MODIFY xmerkmal INDEX da_zaehler.
      CLEAR: da_fieldname.
      CONCATENATE 'RV45A-MNAM' da_zaehler INTO da_fieldname.
      ASSIGN (da_fieldname) TO <mname>.
      <mname> = vbmuez-atnam.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDSELECT.

ENHANCEMENT-POINT RV45A-MUEBS_LESEN_04 SPOTS ES_SAPMV45A.
ENDFORM.