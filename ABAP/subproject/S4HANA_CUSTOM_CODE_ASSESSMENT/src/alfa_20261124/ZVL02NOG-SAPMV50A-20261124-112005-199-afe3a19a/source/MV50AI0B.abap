************************************************************************
*                                                                      *
* PAI Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "B" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE BELEG_BEST_ERGAENZEN                                   *
*---------------------------------------------------------------------*
*       Die Lieferung wird zum Zweck des Wareneingangs um Daten       *
*       aus der zugrundeliegenden Betsellung ergänzt                  *
*---------------------------------------------------------------------*
module beleg_best_ergaenzen.

  perform beleg_bestellung_ergaenzen.

endmodule.                    "beleg_best_ergaenzen

*---------------------------------------------------------------------*
*       MODULE BELEG_LESEN                                            *
*---------------------------------------------------------------------*
*       Der Beleg wird gelesen                                        *
*---------------------------------------------------------------------*
module beleg_lesen.

  check fcode ne 'ANZA_T'.

* In case of errors during reading the document the internal tables have
* to be reset again
  if gf_error_on_document_read eq charx.
    gf_save_vbeln = likp-vbeln.
    perform beleg_daten_init.
    likp-vbeln = gf_save_vbeln.
  else.
    gf_error_on_document_read = charx.
  endif.

if tcode <> 'VLIDAR' and tcode <> 'VLODAR'.
  perform beleg_lesen_simple using likp-vbeln.                "n_527241
else.
  perform beleg_lesen_archiv using likp-vbeln
                                   likp-erdat.
endif.
* CLEAR gf_error_on_document_read.

endmodule.                    "beleg_lesen
*eject


*---------------------------------------------------------------------*
*       MODULE BERECHTIGUNG_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       Prüfen der user-Berechtigungen                                *
*---------------------------------------------------------------------*
module berechtigung_pruefen.

ENHANCEMENT-SECTION     MOD_BERECHTIGUNG_PRUEFEN_01 SPOTS ES_SAPMV50A.
  data: da_actvt like tact-actvt,
        da_subrc like sy-subrc.

  if fcode(4) = 'DRCK'.                                     "46A BEY
    da_actvt = '04'.
  else.
    da_actvt = '  '.
  endif.
  perform berechtigung_pruefen using da_actvt da_subrc.
  if da_subrc ne 0  and da_actvt = actvt_04.
    message e087 with likp-vstel.
  endif.
END-ENHANCEMENT-SECTION.

endmodule.                    "berechtigung_pruefen
*eject

ENHANCEMENT-POINT MV50AI0B_01 SPOTS ES_SAPMV50A STATIC .
*&---------------------------------------------------------------------*
*&      Module  batch_text_restore  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module batch_text_restore input.                            "hp_204766

  check not lips-uecha is initial and
        not lips-charg is initial and
        not lips-arktx is initial.

  read table xlips index slips-tabix.
  if lips-arktx eq xlips-charg.
    lips-arktx = xlips-arktx.
  endif.

endmodule.                 " batch_text_restore  INPUT