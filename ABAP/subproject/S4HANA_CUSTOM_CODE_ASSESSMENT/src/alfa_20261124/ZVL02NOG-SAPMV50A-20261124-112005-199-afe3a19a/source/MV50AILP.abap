************************************************************************
*                                                                      *
* PAI Module Lieferababwicklung                                        *
*     Module alphabetisch geordnet; hier Datei LIPS LIPS               *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE LIPS_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten der Lieferungsposition                             *
*---------------------------------------------------------------------*
module lips_bearbeiten.

ENHANCEMENT-POINT LIPS_BEARBEITEN_MOD_01 SPOTS ES_SAPMV50A.
  perform ilips_aendern(sapfv50p).

* zur Zeit scheint es auch ohne den check keinen Bedarfsfehler
* zu geben, aber wegen Sicherheit:
  check lips ne *lips or lipsd ne *lipsd.

* Store TABIX of item that was changed by user interaction  "v_n_633732
* on item overview screen
  if taxi_screen_group(1) eq 'W' and
     slips-tabix ne 0.
    gf_cursor_tabix = slips-tabix.
  endif.                                                    "^_n_633732

* Liefermenge als aktuelle Menge setzen, wenn sie geändert wurde
  perform lips_lfimg_setzen_dialog(sapfv50p).                 "n_858997

  perform lips_bearbeiten(sapfv50p).


endmodule.
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS_BEARBEITEN_ND                                     *
*---------------------------------------------------------------------*
*       Process the delivery item if global work flag has been set    *
*---------------------------------------------------------------------*
module lips_bearbeiten_nd.

  check gf_item_work_flag ne space.
  clear gf_item_work_flag.

ENHANCEMENT-POINT EHP6_LIPS_BEARBEITEN_ND_01 SPOTS ES_SAPMV50A .

* Do not clear selection mark of current item in new dialog
* PERFORM ILIPS_AENDERN(SAPFV50P).

* zur Zeit scheint es auch ohne den check keinen Bedarfsfehler
* zu geben, aber wegen Sicherheit:
  check lips ne *lips or lipsd ne *lipsd.

* Liefermenge als aktuelle Menge setzen, wenn sie geändert wurde
  perform lips_lfimg_setzen_dialog(sapfv50p).                "n_858997

  perform lips_bearbeiten(sapfv50p).


endmodule.
*eject
*---------------------------------------------------------------------*
*       MODULE LIPS_CHARGEN_SPLIT                                     *
*---------------------------------------------------------------------*
*       Bearbeiten der Chargensplitposition                           *
*---------------------------------------------------------------------*
module lips_chargen_split.

  perform ilips_aendern(sapfv50p).
ENHANCEMENT-SECTION     LIPS_CHARGEN_SPLIT_01 SPOTS ES_SAPMV50A.
  check
   lips-lgort ne  *lips-lgort or
   lips-charg ne  *lips-charg or
   lips-bwtar ne  *lips-bwtar or
   lips-lichn ne  *lips-lichn or
   lips-lfimg ne  *lips-lfimg or       "#&rm
*  lips-vrkme ne  *lips-vrkme.                            begin_n_437185
   lips-vrkme ne  *lips-vrkme or
   sy-ucomm = 'CHCR_T'.                                    "end_n_437185
END-ENHANCEMENT-SECTION.
* Hier noch keine Übernahme der Mengen. Umvkz/n fehlt noch !       "#&rm
* Muß im generiert_aendern.../...hinzufuegen nachgeholt werden     "#&rm
* IF lips-lfimg <> *lips-lfimg.                                    "#&rm
*   IF lips-vrkme = *lips-vrkme AND                                "#&rm
*      lips-charg = *lips-charg.                                   "#&rm
*         PERFORM lips_quan_set(sapfv50p)          USING 'A' space."#&rm
*   ELSE. PERFORM lips_quan_set_with_uom(sapfv50p) USING 'A' space."#&rm
*   ENDIF.
* ENDIF.
  perform lips_chargen_split_bearbeiten(sapfv50p)
                                          using space.      "SP_375923

endmodule.
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS_FUELLEN                                           *
*---------------------------------------------------------------------*
*       LIPS mit Vorschlagswerten aus den Stammdaten beim             *
*       Anlegen füllen                                                *
*---------------------------------------------------------------------*
module lips_fuellen.

  perform lips_fuellen_or(sapfv50p) changing gf_subrc.

endmodule.
*eject
*---------------------------------------------------------------------*
*       MODULE LIPS_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       Vorschlagswerte den Eingabedaten unterlegen                   *
*---------------------------------------------------------------------*
module lips_unterlegen.
  perform lips_unterlegen(sapfv50p).

endmodule.
*---------------------------------------------------------------------*
*       MODULE LIPS_UNTERLEGEN_CHSP                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module lips_unterlegen_chsp output.
  perform lips_unterlegen_chsp(sapfv50p).

endmodule.
*---------------------------------------------------------------------*
*       MODULE LIPS_UNTERLEGEN_CHSP                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module lips_unterlegen_chsp.
  perform lips_unterlegen_chsp(sapfv50p).

endmodule.
*eject

*---------------------------------------------------------------------*
*       MODULE XLIPS_BLAETTERN                                        *
*---------------------------------------------------------------------*
*       Blättern in der Tabelle ILIPS                                 *
*---------------------------------------------------------------------*
module xlips_blaettern.

  perform xlips_blaettern(sapfv50p).

endmodule.
*eject


*---------------------------------------------------------------------*
*       MODULE XLIPS_ERGAENZEN_REF                                    *
*---------------------------------------------------------------------*
*       Tabelle XLIPS mit den Angaben aus dem Referenzbeleg           *
*       ergänzen                                                      *
*---------------------------------------------------------------------*
module xlips_ergaenzen_ref.

  if t180-trtyp ne charh and
     lips-vgbel ne space and
     xlips-ofmng eq 0.
    perform lips_referenz_lesen(sapfv50p).
  endif.

endmodule.
*eject


*---------------------------------------------------------------------*
*       MODULE XLIPS_LOESCHEN_LOOP                                    *
*---------------------------------------------------------------------*
*       Löschen der markierten Einträge in der Tabelle XLIPS          *
*       aus dem STEP-LOOP.                                            *
*---------------------------------------------------------------------*
module xlips_loeschen_loop.

  check t180-bldgr(1) ne 'E' or                             "n_521409
        v50agl-new_del_mode eq space.

  perform xlips_loeschen_loop(sapfv50p).

endmodule.
*eject
*---------------------------------------------------------------------*
*       MODULE XLIPS_LOESCHEN_REST                                    *
*---------------------------------------------------------------------*
*       Delete of items which do not appear on the actual screen.     *
*---------------------------------------------------------------------*
module xlips_loeschen_rest.

  if t180-bldgr(1) eq 'E' and                               "v_n_521409
     v50agl-new_del_mode ne space.
    perform delete_delivery_items_dialog.
    exit.
  endif.                                                    "^_n_521409

  perform xlips_loeschen_rest(sapfv50p).

endmodule.
*eject


*---------------------------------------------------------------------*
*       MODULE XLIPS_POSITIONIEREN                                    *
*---------------------------------------------------------------------*
*       Blättern in der Tabelle ILIPS durch Eingabe der Position      *
*---------------------------------------------------------------------*
module xlips_positionieren.

  perform xlips_positionieren(sapfv50p).

endmodule.
*eject
*&---------------------------------------------------------------------*
*&      Module  ILIPS_AENDERN  INPUT
*&---------------------------------------------------------------------*
*       Transfer selection sign to internal table ILIPS
*----------------------------------------------------------------------*
module ilips_aendern input.            "46A BEY

  perform ilips_aendern(sapfv50p).

endmodule.                             " ILIPS_AENDERN  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SPLIT_ITEMS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_split_items input.
  if lips-kzfme is initial.
    perform lips_lfimg_setzen(sapfv50p).
  else.
    perform lips_quan_set(sapfv50p) using chara space.
  endif.
* Prüfung, falls neue Lieferistmenge < Pickmenge ist
  if lips-uecha is initial or
     lips-komkz ca 'BCD12'.
    perform lips-lfimg_pruefen_pikmg(sapfv50p)
                                   using lips-lfimg lips-lfimg_flo
                                         lips-lgmng lips-lgmng_flo
                                   changing xlips_loeschen_menge_0.
  endif.

* Ändern Liefermenge unter die verpackte Menge nicht erlaubt
  if tvlp-chhpv eq space.                                   "n_558252
    perform lips-lfimg_pruefen_pack(sapfv50p)
                                   using lips-lfimg lips-lfimg_flo
                                         lips-lgmng lips-lgmng_flo
                                   changing xlips_loeschen_menge_0.
  endif.                                                    "n_558252


* Ändern Liefermenge unter die Menge der Serialnummern nicht erlaubt
  perform lips-lfimg_pruefen_serial(sapfv50p)
                                 using lips-lfimg lips-lfimg_flo
                                       lips-lgmng lips-lgmng_flo
                                 changing xlips_loeschen_menge_0.


endmodule.                             " CHECK_SPLIT_ITEMS  INPUT

*v_n_638127
*&---------------------------------------------------------------------*
*&      Module  lips_protect_results  INPUT
*&---------------------------------------------------------------------*
*  Protect calculated lips fields from being overwritten in step loop
*----------------------------------------------------------------------*
MODULE lips_protect_results INPUT.

* correlation results
  read table gt_correlated transporting no fields
   with key table_line = slips-tabix.
  if sy-subrc eq 0.
    delete gt_correlated index sy-tabix.
* reverse field transports for calculated fields
    lips-brgew = xlips-brgew.
    lips-volum = xlips-volum.
  endif.

ENDMODULE.                 " lips_protect_results  INPUT

*&---------------------------------------------------------------------*
*&      Module  xlips_unprotect_results  INPUT
*&---------------------------------------------------------------------*
*  Release protections from recently calculated fields
*----------------------------------------------------------------------*
MODULE xlips_unprotect_results INPUT.
  refresh: gt_correlated.
ENDMODULE.                 " xlips_unprotect_results  INPUT
*^_n_638127
*v_n_1293737
*&---------------------------------------------------------------------*
*&      Module  SELKZ_UPDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELKZ_UPDATE INPUT.
  RV50A-LIPS_SELKZ = TVPODVB-SELKZ.
ENDMODULE.                 " SELKZ_UPDATE  INPUT
*^_n_1293737