*---------------------------------------------------------------------*
*       MODULE     FCODE_BEARBEITEN INPUT                             *
*---------------------------------------------------------------------*
*       Bearbeitung des gesetzten oder übergebenen FCODEs             *
*       Die Übergabe/das Setzen erfolgt im MODUL FOLGEWERTE_SETZEN    *
*       direkt zu Beginn der PAI-Bearbeitung.                         *
*---------------------------------------------------------------------*
module fcode_bearbeiten input.

ENHANCEMENT-SECTION     FCODE_BEARBEITEN_03 SPOTS ES_SAPMV50A.
* Clear global flags used for item processing
  clear: xlips_loeschen, rv50a-lips_selkz.                  "46A/45B
  clear: v50agl-warenausgang.                                 "n_690050

  save_ilips_tabix = ilips-tabix.
  perform position_gewichtsupdate_chsp(sapfv50p) using chard.
  if save_ilips_tabix ne 0.
    read table xlips index save_ilips_tabix.
    read table ilips with key xlips-posnr binary search.
  endif.

  if v50agl-chargensplitbild = 'X'                          "v_n_558685
    and clips-uepos is initial
    and not clips-grkor is initial.
    perform XLIPS_I0_CHSP_KORR_MENGEN(SAPFV50P).
  endif.                                                    "^_n_558685

* Update packing control in case of batch splits and HU management
  perform hu_batchsplit_chhpv_update(sapfv50p) using    likp-vbeln
                                                        ilips-tabix
                                                        space
                                               changing gf_subrc.
  if gf_subrc ne 0.
    message id sy-msgid type 'I' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Update incompleteness status of the delivery before next process step
  if t180-trtyp ne chara  and
     uc_process eq space  and
     fcode(4)   ne 'SICH' and                               "n_531900
     fcode(4)   ne 'WABU'.
    perform uc_internal_update(sapfv50u).
  endif.

* In case of errors during processing the screen sequence   "v_n_608056
* control only ENT1 is allowed as subsequent function code
  if gf_fcode_processing_active ne space.
    fcode = fcode_gleiche_seite.
  endif.
  gf_fcode_processing_active = charx.                       "^_n_608056
  perform fcode_bearbeiten.
  clear gf_fcode_processing_active.                         "n_608056
END-ENHANCEMENT-SECTION.

endmodule.                    "fcode_bearbeiten INPUT
*eject

ENHANCEMENT-POINT FCODE_BEARBEITEN_MOD_02 SPOTS ES_SAPMV50A STATIC.
*---------------------------------------------------------------------*
*       MODULE     FCODE_INIT INPUT                                   *
*---------------------------------------------------------------------*
*       Bearbeitung des gesetzten oder übergebenen FCODEs beim ersten *
*       Aufruf der Folgebildsteuerung auf dem ersten Bild             *
*       einer Transaktion                                             *
*---------------------------------------------------------------------*
module fcode_anforderung input.

  perform fcode_anforderung.
  clear gf_error_on_document_read.

endmodule.                    "fcode_anforderung INPUT
*eject

*---------------------------------------------------------------------*
*       MODULE     FUNKTION_AUSFUEHREN                                *
*---------------------------------------------------------------------*
*       Bearbeitung eines FCODES, der kein Folgebild ansteuert oder   *
*       eines FCODES, der eine laufende Verarbeitung beendet.         *
*---------------------------------------------------------------------*
module funktion_ausfuehren input.

  perform funktion_ausfuehren.

endmodule.                    "funktion_ausfuehren INPUT

*&---------------------------------------------------------------------*
*&      Module  FUNKTION_UMFANG_AENDERN  INPUT
*&---------------------------------------------------------------------*
*       Falls beim Anklicken der Position das Feld CHMULT getroffen    *
*       wurde, wird der Umfang geändert                                *
*----------------------------------------------------------------------*
module fcode_umfang_aendern input.

  data: fua_cursor(20) type c,
        fua_selline(2) type p.

  get cursor field fua_cursor line fua_selline.

* keine LOOP-Zeile oder nicht das richtige Feld ?
  if sy-subrc <> 0 or
     fua_selline = space or
     fua_cursor <> 'LIPSD-CHMULT'.
    sy-subrc = 4.
    exit.
  endif.

* Umfang entgegengesetzt verändern
  case xlips_umfang.
    when xlips_umfang_uall.
      fcode = 'UCHA'.
    when xlips_umfang_ucha.
      fcode = 'UALL'.
  endcase.

endmodule.                             " FUNKTION_UMFANG_AENDERN  INPUT

*##mos-anf
*&---------------------------------------------------------------------*
*&      Module  KOMPLETT_MARKIERUNGEN  INPUT
*&---------------------------------------------------------------------*
*       Bearbeitung der Funktionscodes MKAL/MKLO zum Markieren/Entmark.
*       aller Positionen
*----------------------------------------------------------------------*
module komplett_markierungen input.

  if fcode(4) = 'MKAL'.                " Set marks    "46A BEY
    ilips-selkz = charx.
  elseif fcode(4) = 'MKLO'.            " Clear marks
    ilips-selkz = space.
  else.                                " Exit on other FCODES
    exit.
  endif.
  modify ilips transporting selkz
               where selkz <> ilips-selkz.

endmodule.                             " KOMPLETT_MARKIERUNGEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  FOREIGN_TRADE_HEAD_PROCESS  INPUT
*&---------------------------------------------------------------------*
module foreign_trade_head_process input.

  perform foreign_trade_head_process changing fcode
                                              likp-expkz
                                              likp-exnum
                                              r185d-dataloss.

endmodule.                 " FOREIGN_TRADE_HEAD_PROCESS  INPUT

*&---------------------------------------------------------------------*
*&      Module  FOREIGN_TRADE_ITEM_PROCESS  INPUT
*&---------------------------------------------------------------------*
module foreign_trade_item_process input.

  perform foreign_trade_item_process using    lips-posnr
                                     changing fcode
                                              likp-expkz
                                              likp-exnum
                                              r185d-dataloss.

endmodule.                 " FOREIGN_TRADE_ITEM_PROCESS  INPUT