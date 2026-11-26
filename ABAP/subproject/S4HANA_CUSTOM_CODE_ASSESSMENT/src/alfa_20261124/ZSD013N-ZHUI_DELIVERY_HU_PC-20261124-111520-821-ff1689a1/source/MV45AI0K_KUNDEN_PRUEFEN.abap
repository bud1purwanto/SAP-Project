*&---------------------------------------------------------------------*
*&      Module  KUNDEN_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       Auftraggeber, Warenempfänger und Vertriebsbereich gegeneinander
*       prüfen oder fehlenden Part bestimmen
*----------------------------------------------------------------------*

MODULE kunden_pruefen INPUT.

* Check SC switch is on
  IF CL_SD_SWITCH_CHECK=>SD_SFWS_UI3_O2C( ) EQ abap_true.
* replace current customer (sold-to-party) by customer form full text search
    PERFORM cs_set_new_kuagv_kunnr.
  ENDIF.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ende_ohne_pruefung USING space
                             CHANGING leave_without_check.
  CHECK leave_without_check IS INITIAL.

  PERFORM kunden_pruefen.

ENDMODULE.                             " KUNDEN_PRUEFEN  INPUT