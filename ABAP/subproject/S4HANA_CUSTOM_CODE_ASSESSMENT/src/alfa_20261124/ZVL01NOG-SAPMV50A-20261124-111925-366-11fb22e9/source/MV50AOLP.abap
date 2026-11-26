************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Kundenlieferabwicklung              *
*     Module alphabetisch geordnet; hier Tabelle LIPS.                 *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE LIPS_BEARBEITEN_VOR(bereiten)                          *
*---------------------------------------------------------------------*
*       Vorbereiten der Bearbeitung einer Lieferposition              *
*---------------------------------------------------------------------*
module lips_bearbeiten_vor output.

  perform lips_bearbeiten_vorbereiten(sapfv50p).

endmodule.                    "lips_bearbeiten_vor OUTPUT
*eject


*---------------------------------------------------------------------*
*       MODULE LIPS_DYNPRO_VOR(bereiten)                              *
*---------------------------------------------------------------------*
*       Füllen von Feldern (Texten) des Dynpros                       *
*---------------------------------------------------------------------*
module lips_dynpro_vor output.

*   Werk
  perform t001w_select using lips-werks
                             space
                             sy-subrc.
  rv50a-txwklg = space.
  if lips-werks ne space.
    rv50a-txwklg = t001w-name1.

*      Lager
    perform t001l_select using lips-werks
                               lips-lgort
                               space
                               sy-subrc.
    if lips-lgort ne space.
*         Texte dazu
      rv50a-txwklg+31 = '/'.
      rv50a-txwklg+33 = t001l-lgobe.
      condense rv50a-txwklg.
    endif.
  else.
    clear t001l.
    clear rv50a-txwklg.
  endif.

*  Lagernummer
  if lips-lgnum = space.
    clear t300t.
    clear t301t.
  else.
    perform t300t_select using lips-lgnum.
    perform t301t_select using lips-lgtyp
                               lips-lgnum.                  "hp_314544
  endif.

*   Material lesen
  if lips-matnr ne space.
*      notwendig wegen MPN-Abwicklung (GF)
*      and likp-vbtyp na vbtyp_mmli.          "nicht für Lieferavise
    perform maapv_select(sapfv50p) using lips-matnr
                                   likp-vkorg
                                   lips-vtweg
                                   sy-subrc.

*      Raumbedingung
    perform t142_select using maapv-raube
                              space
                              sy-subrc.

*      Temperaturbedingung
    perform t143_select using maapv-tempb
                              space
                              sy-subrc.

*   maapv is initialized before dynpro processing -> values to be
*   displayed must be copied to output structure RV50A
    rv50a-raube = maapv-raube.
    rv50a-tempb = maapv-tempb.

  endif.

* Item category
  perform tvlp_select using lips-pstyv                      "n_540444
                            sy-subrc.

*   Transportgruppe
  perform ttgr_select using lips-tragr
                            space
                            sy-subrc.

*   Materialfrachtgruppe
  perform tmfgt_select using lips-mfrgr
                             space
                             sy-subrc.

*   Ladegruppe
  perform tlgr_select using lips-ladgr
                            space
                            sy-subrc.

*   Fakturasperre
  perform tvfsp_select using lips-faksp
                             space
                             sy-subrc.

* Division
  perform tspa_select using lips-spart
                            space
                            sy-subrc.

* Distribution channel
  perform tvtw_select using lips-vtweg
                            space
                            sy-subrc.

* Reason for movement type
  perform t157e_select using    lips-bwart
                                lips-grund
                       changing sy-subrc.

* Staging area
  perform t30c_select using lips-lgnum
                            lips-lgbzo
                            space
                            sy-subrc.

*   Status und Texte dazu lesen
  perform xvbup_lesen(sapfv50p) using likp-vbeln
                                      lips-posnr.

  vbup = xvbup.

  call function 'RV_DOCUMENT_POS_STATUS_TEXTS'
    EXPORTING
      sprache       = sy-langu
      vbup_gelesen  = charx
      vbup_in       = vbup
      window_senden = space
      vbtyp         = likp-vbtyp
    IMPORTING
      vbstt_wa      = vbstt.

*   Text zur Absicherungsform lesen
  perform t691l_text_select using    lips-abfor
                            changing t691l-bezei.

* Text for stock type
  perform txt_insmk_select using lips-insmk
                           changing rv50a-insmk_txt.

* Text for the document type of the preceding document
  perform txt_vbtyp_select using lips-vgtyp
                           changing rv50a-vgtyp_txt.

endmodule.                    "lips_dynpro_vor OUTPUT
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS_HPOS_VOR(bereiten)                                *
*---------------------------------------------------------------------*
*       Vorbereiten der Hauptposition zum Chargensplit                *
*---------------------------------------------------------------------*
module lips_hpos_vor output.

  perform lips_hpos_vorbereiten(sapfv50p).

endmodule.                    "lips_hpos_vor OUTPUT
*eject


*---------------------------------------------------------------------*
*       MODULE XLIPS_AUFSETZEN                                        *
*---------------------------------------------------------------------*
*       Aufsetzen in Tabelle XLIPS                                    *
*---------------------------------------------------------------------*
module xlips_aufsetzen output.

  perform xlips_aufsetzen(sapfv50p).

endmodule.                    "xlips_aufsetzen OUTPUT
*eject

*---------------------------------------------------------------------*
*       MODULE XLIPS_EXIT_FROM_LOOP                                   *
*---------------------------------------------------------------------*
*       Leere Loopzeilen werden auf nicht eingabebereit gesetzt.      *
*                                                                     *
*---------------------------------------------------------------------*
module xlips_exit_from_loop output.

  perform xlips_exit_from_loop(sapfv50p).

endmodule.                    "xlips_exit_from_loop OUTPUT
*eject


*---------------------------------------------------------------------*
*       MODULE XLIPS_LESEN                                            *
*---------------------------------------------------------------------*
*       Tabelle XLIPS fuer Bildschirmanzeige lesen                    *
*---------------------------------------------------------------------*
module xlips_lesen output.

  perform xlips_lesen(sapfv50p).

endmodule.                    "xlips_lesen OUTPUT
*eject

*##mos-anf
*---------------------------------------------------------------------*
*       MODULE TC_REFRESH_271                                         *
*---------------------------------------------------------------------*
*       Table Control mit aktuellen Werten des akt. Dynpros aktualis. *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE WADAT_IST_INIT                                         *
*---------------------------------------------------------------------*
*  Init. im Zusammenhang mit WADAT_IST:                               *
*  - Im Table Control-Bild Menüpunkt Ist-WADat excl.                  *
*  - falls LIKP-WADAT_IST initial, schlage Tagesdatum vor und merken, *
*    daß es nur Vorschlagswert war                                    *
*---------------------------------------------------------------------*
module wadat_ist_init output.
  lips-posnr = 0.
endmodule.                    "wadat_ist_init OUTPUT

*---------------------------------------------------------------------*
*     MODULE  ILIPS_TABIX_AKTUELL fuer SCROLLEN SETZEN                *
*---------------------------------------------------------------------*
module ilips_tabix_zeile_1 output.
  if ilips_tabix_zeile_1_set is initial.
* Kontrolle durch Table Control
    ilips_tabix_zeile_1 = <tc>-top_line.
  else.
* Kontrolle durch Programm
    <tc>-top_line = ilips_tabix_zeile_1 .
  endif.
  clear ilips_tabix_zeile_1_set.
endmodule.                    "ilips_tabix_zeile_1 OUTPUT
*---------------------------------------------------------------------*
*      Module  Seitenzaehlerzuweisung im TC
*---------------------------------------------------------------------*
module tc_assign output.

  case sy-dynnr.
    when scr_all.
      assign tc_lips_all to <tc>.
    when scr_gew.
      assign tc_lips_gew to <tc>.
    when scr_kom.
      assign tc_lips_kom to <tc>.
*     Set correct description for LIPSD-PIKMG
      if likp-vbtyp ca vbtyp_mmli.
        gf_pikmg_txt = 'Einlagermenge'(028).
      else.
        gf_pikmg_txt = 'Pickmenge'(029).
      endif.
    when scr_lgr.
      assign tc_lips_lgr to <tc>.
    when scr_cha.
      assign tc_lips_cha to <tc>.
    when scr_avi.
      assign tc_lips_avi to <tc>.
    when scr_gwe.
      assign tc_lips_gwe to <tc>.
    when scr_over.                                          "46A BEY
      assign tc_lips_over to <tc>.
    when scr_pick.
      assign tc_lips_pick to <tc>.
    when scr_pod.
      assign tc_lips_pod to <tc>.
    when scr_pod_quan.
      assign tc_lips_pod_quan to <tc>.
    when scr_load.
      assign tc_lips_load to <tc>.
    when scr_tran.
      assign tc_lips_tran to <tc>.
    when scr_chnd or scr_chnd_empty.
      assign tc_lips_chnd to <tc>.
    when scr_over_inb.                                      "46A GGS
      assign tc_lips_over_inb to <tc>.
    when scr_pick_inb.
      assign tc_lips_pick_inb to <tc>.
    when scr_load_inb.
      assign tc_lips_load_inb to <tc>.
    when scr_tran_inb.
      assign tc_lips_tran_inb to <tc>.
    when scr_wada.
      assign tc_lips_wada to <tc>.
    when scr_ret_crm.                  "SPE returns
      assign tc_ret_data to <tc>.
    when scr_ret_sto.                  "SPE returns
      assign tc_ret_sto to <tc>.
    when others.                                            "IS2ERP
ENHANCEMENT-POINT MV50AOLP_01 SPOTS ES_SAPMV50A.

      "$$
  endcase.

endmodule.                    "tc_assign OUTPUT
*---------------------------------------------------------------------*
*    Module um Zeilen fuer VL02 zu initialisieren                     *
*---------------------------------------------------------------------*
module ilips_lines output.
  describe table ilips lines lin.
  if sy-loopc ne 0.
    lin = ( ( lin div sy-loopc ) + 1 ) * sy-loopc.
    <tc>-lines = lin.
  endif.
endmodule.                    "ilips_lines OUTPUT
*---------------------------------------------------------------------*
*       MODULE XLIPS_LESEN_MIT_REF                                    *
*---------------------------------------------------------------------*
*       Tabelle XLIPS fuer Bildschirmanzeige lesen                    *
*       und Referenzangaben aus Aufträgen besorgen                    *
*---------------------------------------------------------------------*
module xlips_lesen_mit_ref output.
  perform xlips_lesen(sapfv50p).

  if t180-trtyp ne charh and
     lips-vgbel ne space and
     xlips-ofmng eq 0.
     *lips = lips.
    perform lips_referenz_lesen(sapfv50p).
    modify xlips index ilips-tabix.
  endif.

endmodule.                    "xlips_lesen_mit_ref OUTPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  LIPS_IN_EA  OUTPUT
*&---------------------------------------------------------------------*
*       Transport von Feldern aus LIPS in EA-Felder von Grob-WE wegen  *
*       abweichender Doku; Bestücken Aktionskennung, AUfteiler, etc.  *
*----------------------------------------------------------------------*
module lips_in_ea output.

  if likp-vbtyp ca vbtyp_grwe.
    rv50a-menge_gw = lips-lfimg.       "#&rm
    rv50a-meins_gw = lips-vrkme.
    rv50a-idnlf = lips-kdmat.
    if lips-aktnr ne space.
      rv50a-kz_aktion = 'X'.
    endif.
    if lips-abeln ne space.
      rv50a-kz_auft = 'X'.
    endif.
  endif.
* the following can be deleted                                "n_907659
* Ermitteln, ob es einen Text für die Position gibt
* clear rv50a-kz_text.
* if not xlips-posnr is initial.
*   clear xthead. refresh xthead.
*   perform tvlp_select(sapmv50a) using xlips-pstyv sy-subrc.
*   perform xthead_uebersicht_p_ansteuern(sapfv45t)
*                   using tvlp-txtgr
*                         charl
*                         likp-vbeln
*                         xlips-posnr.
*   loop at xthead where tdobject = 'VBBP'.
*     if not xthead-tdrefobj is initial and
*        not xthead-tdrefname is initial and
*        not xthead-tdrefid is initial and
*            xthead-tdname+0(10) = xlips-vbeln and
*            xthead-tdname+10 = xlips-posnr.
*       rv50a-kz_text = 'X'.
*       exit.
*     endif.
*   endloop.
* endif.

endmodule.                             " LIPS_IN_EA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIKP_IN_EA  OUTPUT
*&---------------------------------------------------------------------*
*       Transport von Feldern aus LIKP in EA-Felder                    *
*----------------------------------------------------------------------*
module likp_in_ea output.

  perform tvst_select using likp-vstel space sy-subrc.
  perform t30bt_select using likp-lgnum likp-lgtor.
  perform t300t_select using likp-lgnum.

endmodule.                             " LIPS_IN_EA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  LIPS_PODPOS_VOR  OUTPUT
*&---------------------------------------------------------------------*
*       POD Position vorbereiten
*----------------------------------------------------------------------*
module lips_podpos_vor output.

*  IF NOT GF_ERROR_POD IS INITIAL.
*    SUPPRESS DIALOG.
*  ENDIF.

  if not lips-posnr is initial.
    perform lips_podpos_vorbereit(sapfv50p).
  endif.


endmodule.                             " LIPS_PODPOS_VOR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  POD_DATEN_ZUFUEGEN  OUTPUT
*&---------------------------------------------------------------------*
*       POD Daten zur LIPS-Position anreichern
*----------------------------------------------------------------------*
module pod_daten_zufuegen output.

* Update and add POD data
  perform pod_daten_zufuegen(sapfv50p) using tvpodvb
                                             tvpod-podmg
                                             tvpodgt-gtext.
* In case of cancelling the POD confirmation header status update
* has to be made
  if fcode eq gc_fcode_podstor and
     not lips-posnr is initial and
     gf_error_pod is initial.
    perform xvbuk_pflegen(sapfv50k).
    vbuk = xvbuk.
    read table xvbup with key vbeln = lips-vbeln
                              posnr = lips-posnr.
  endif.

endmodule.                             " POD_DATEN_ZUFUEGEN  OUTPUT

* BORGR_WBSTK_FROM_EKES removed with n_1072933