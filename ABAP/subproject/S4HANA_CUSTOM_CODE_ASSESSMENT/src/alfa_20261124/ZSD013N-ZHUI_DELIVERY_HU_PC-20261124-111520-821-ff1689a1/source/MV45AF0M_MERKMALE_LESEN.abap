*----------------------------------------------------------------------*
*   INCLUDE MV45AF0M_MERKMALE_LESEN                                    *
*----------------------------------------------------------------------*
FORM merkmale_lesen.

  DATA: da_zaehler(2) TYPE n,
        da_tabix like sy-tabix,
        da_numc2(2) TYPE n,
        da_fieldname(50).

  FIELD-SYMBOLS: <mname>, <mbez>.

* SPA/GPA Parameter VAM holen
  PERFORM parameter_vam_holen.

* Merkmalstexte holen
  DO ueco_col_count TIMES.
    da_numc2 = sy-index.
    CLEAR: da_fieldname.
    CONCATENATE 'RV45A-MNAM' da_numc2 INTO da_fieldname.
    ASSIGN (da_fieldname) TO <mname>.
    CLEAR: da_fieldname.
    CONCATENATE 'RV45A-MBEZ' da_numc2 INTO da_fieldname.
    ASSIGN (da_fieldname) TO <mbez>.

    IF not <mname> is initial.
      da_tabix = da_numc2.
      PERFORM xmerkmal_lesen           USING <mname>
                                             charx
                                             da_tabix
                                    CHANGING sy-subrc.
      IF sy-subrc is initial.
        <mbez> = xmerkmal-atbez.
      ENDIF.
    ELSE.
      CLEAR <mbez>.
    ENDIF.
  ENDDO.

ENDFORM.