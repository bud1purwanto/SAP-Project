*-----------------------------------------------------------------------
*        Allgemeine Felder im Versand
*-----------------------------------------------------------------------

TABLES:  rv50a, *rv50a,
         r185d, v50agl, finchdel, *finchdel,
         bdcrun, v50agl_cust.
DATA:    BEGIN OF COMMON PART mv50acom.
DATA: no_requirements.
DATA: no_dequeue(1) TYPE c.

DATA: auto_chargenfindung(1) TYPE c.
DATA  ilips_tabix_aktuell_calldynpro LIKE ilips_tabix_aktuell.
DATA  ilips_tabix_zeile_1_calldynpro LIKE ilips_tabix_zeile_1.
DATA: positionsgenerieren(1) TYPE c,
      productselection(1) TYPE c.
DATA: save_kcmeng     LIKE lips-kcmeng,
      save_kcmeng_flo LIKE lips-kcmeng_flo,
      save_kcmengvme  LIKE lips-kcmengvme,
      save_kcmengvmef LIKE lips-kcmengvmef.

DATA: kz_chsp_posdetailbild(1) TYPE c.
*>>>> BEGIN OF INSRTION note 129899
DATA: save_287_menge LIKE lips-lfimg.
DATA: save_287_menge_flo LIKE lips-lfimg_flo.
*>>>> END OF INSERTION note 129899

DATA: gf_arktx_old LIKE lips-arktx,                          "v_n_774742
      gf_arktx_new LIKE lips-arktx,
      gf_matnr_old LIKE lips-matnr,
      gf_matnr_new LIKE lips-matnr.                          "^_n_774742
DATA: xlips_chsp_rueckmeldung  TYPE c.
*data: kommirueckmeldung(1) type c. "replaced by v50agl flag
DATA: no_messages_update TYPE c.
DATA: no_imseg_refresh(1) TYPE c.
DATA: nicht_sperren(1) TYPE c.         "Lieferung nicht sperren
DATA: aufrufer.                        "T Transport
DATA: status_buffer_init VALUE 'X'.
DATA: call_activity(4) TYPE c.
DATA: status_transport LIKE sy-subrc.
DATA: uc_process.                "step indicator uncompleteness prot.

DATA: posnr_last LIKE lips-posnr.

DATA: BEGIN OF gt_batch_item_num OCCURS 0,
        vbeln LIKE likp-vbeln,
        posnr_last LIKE lips-posnr,
      END OF gt_batch_item_num.

DATA: lo_menge_old_lme LIKE lips-lfimg.
DATA: lo_menge_new_lme LIKE lips-lfimg.
DATA: lo_menge_old_vme LIKE lips-lfimg.
DATA: lo_menge_new_vme LIKE lips-lfimg.
DATA: lo_menge_old_lme_flo LIKE lips-lfimg_flo.
DATA: lo_menge_new_lme_flo LIKE lips-lfimg_flo.
DATA: lo_menge_old_vme_flo LIKE lips-lfimg_flo.
DATA: lo_menge_new_vme_flo LIKE lips-lfimg_flo.
DATA: lo_menge LIKE lips-lfimg.
DATA: BEGIN OF lo_lips.
        INCLUDE STRUCTURE lipsvb.
DATA: END OF lo_lips.
DATA: BEGIN OF lo_lips_old.
        INCLUDE STRUCTURE lipsvb.
DATA: END OF lo_lips_old.
DATA: meng15_high LIKE vepvg-brgew VALUE 999999999999.
DATA: meng15_hilf LIKE vepvg-brgew.
DATA: wa_zaehl    LIKE sy-subrc.       "WA Zaehler

DATA: flag_vfp_packen. "Es konnten nicht alle Verpackungspositionen
                                       "generiert werden

DATA: gf_batch_level LIKE tcuch-kzdch.                        "n_722389

DATA: BEGIN OF kclips OCCURS 10,
        posnr   LIKE lips-posnr,
        uecha   LIKE lips-uecha,
        brgew LIKE lips-brgew,
        ntgew LIKE lips-ntgew,
        volum LIKE lips-volum,
        gewei   LIKE lips-gewei,
        voleh   LIKE lips-voleh,
        lgmng   LIKE lips-lgmng,
        lfimg   LIKE lips-lfimg,
        lgmng_flo LIKE lips-lgmng_flo,
        lfimg_flo LIKE lips-lfimg_flo,
        vrkme   LIKE lips-vrkme,
        umvkz   LIKE lips-umvkz,
        umvkn   LIKE lips-umvkn,
        brgew_old LIKE lips-brgew,
        ntgew_old LIKE lips-ntgew,
        volum_old LIKE lips-volum,
        gewei_old LIKE lips-gewei,
        voleh_old LIKE lips-voleh,
        lgmng_old LIKE lips-lgmng,
        lfimg_old LIKE lips-lfimg,
        lgmng_flo_old LIKE lips-lgmng_flo,
        lfimg_flo_old LIKE lips-lfimg_flo,
        vrkme_old LIKE lips-vrkme,
        umvkz_old LIKE lips-umvkz,
        umvkn_old LIKE lips-umvkn,
        komkz     LIKE lips-komkz,
      END OF kclips.
DATA: BEGIN OF kcpick OCCURS 0,
        posnr LIKE lips-posnr,
        rfmng LIKE vbfa-rfmng,
      END OF kcpick.

TYPES: BEGIN OF lips_batch,                                  "v_n_708022
         called_by  TYPE lips-sobkz,                           "n_711627
         vbeln      TYPE lips-vbeln,
         posnr      TYPE lips-posnr,
         lgmng      TYPE lips-lgmng,
         lgmng_flo  TYPE lips-lgmng_flo,
         meins      TYPE lips-meins,
         akmng      TYPE lips-akmng,
         lfimg      TYPE lips-lfimg,                         "v_n_711627
         lfimg_flo  TYPE lips-lfimg_flo,
         vrkme      TYPE lips-vrkme,                         "^_n_711627
      END OF lips_batch.

DATA: gs_lips_batch TYPE lips_batch.                         "^_n_708022

* Subscreen used in several dynpros.
DATA: bottom_subscreen LIKE sy-dynnr VALUE '611',  "empty
      bottom_subscreen_text(100) TYPE c,
      gf_icon_incompleteness(4) TYPE c,
      bottom_subscreen_posnr LIKE lips-posnr.


* Serialnummern und Chargen
DATA: BEGIN OF xlips_ser OCCURS 0,
        posnr  LIKE lips-posnr,
        uecha  LIKE lips-uecha,
        anzsn  LIKE lips-anzsn,
      END OF xlips_ser.

* POD Data:
DATA: BEGIN OF gt_tvpod OCCURS 100.
        INCLUDE STRUCTURE tvpodvb.
DATA: END OF gt_tvpod.
DATA: BEGIN OF gt_ytvpod OCCURS 100.
        INCLUDE STRUCTURE tvpodvb.
DATA: END OF gt_ytvpod.
DATA: BEGIN OF gt_check_pod OCCURS 100,
        grund LIKE tvpodvb-grund,
        posnr LIKE tvpodvb-posnr,
      END OF gt_check_pod.
DATA: gf_anz_pod LIKE sy-tabix.
DATA: gf_lines_pod TYPE c VALUE space.
DATA: gf_error_pod LIKE sy-subrc.
DATA: BEGIN OF gs_error_pod,
        msgno LIKE sy-msgno,
        msgty LIKE sy-msgty,
        msgid LIKE sy-msgid,
        msgv1 LIKE sy-msgv1,
        msgv2 LIKE sy-msgv2,
        msgv3 LIKE sy-msgv3,
        msgv4 LIKE sy-msgv4,
      END OF gs_error_pod.
* SIT: POD item for inbound delivery update
DATA: BEGIN OF gt_tvpod_sit OCCURS 100.
        INCLUDE STRUCTURE tvpodvb.
DATA: END OF gt_tvpod_sit.

* Versandtermine
DATA: BEGIN OF idltab OCCURS 10.
        INCLUDE STRUCTURE dltab.
DATA: END OF idltab.

DATA:    tcode      LIKE sy-tcode,     "Transactionscode
         fcode      LIKE t185-fcode,
         old_fcode  LIKE t185-fcode,
         time1 TYPE p,                 " Run-Time Test
         time2 TYPE p,                 " Run-Time Test
         time3 TYPE p.                 " Run-Time Test

DATA:    lieferung_or(1).              "Kennzeichen ob Lieferschein
                                       "ohne Auftragsreferenz vorliegt
DATA:   vpobj LIKE vekp-vpobj.         "Verpackungsobjekt

*  Supplier Consignation Data
DATA:   BEGIN OF vbsupcon_tab OCCURS 0.
        INCLUDE STRUCTURE vbsupcon.
DATA:   END OF vbsupcon_tab.

*-document number of referred rush order
DATA: gv_vbeln_sof LIKE vbak-vbeln.
*#mos-begin
DATA: gv_event_pov.
*#mos-end
* structure to store the controlflags for the SD-monitor
DATA: BEGIN OF xsdctrlflag.
        INCLUDE STRUCTURE sdctrlflag.
DATA: END   OF xsdctrlflag.

*-----variabel messages
DATA:
                 "message handling parameter, upwards compatibility
      BEGIN OF gs_mhpar.
        INCLUDE STRUCTURE t160mvl_msgvs.
DATA:
END OF gs_mhpar.


CONSTANTS: yes VALUE 'X',
            no VALUE ' ',
           BEGIN OF aktyp,
              create(1)  VALUE 'H',
              change(1)  VALUE 'V',
              display(1) VALUE 'A',
           END OF aktyp.

DATA: gt_finchdel TYPE vlikp_t_finchdel.

RANGES: gt_r_autlf_del FOR vbak-vbeln.
DATA: BEGIN OF gt_pricing_type_save OCCURS 0,              "470
        vbeln        TYPE likp-vbeln,
        pricing_type TYPE t683-knprs_v,
      END OF gt_pricing_type_save.

*   Table for doc./items which should be deleted in incomplet. routine
DATA: BEGIN OF gt_mark_for_del OCCURS 0,
        vbeln     TYPE lips-vbeln,
        posnr     TYPE lips-posnr,
        spe_struc TYPE /spe/struc,
      END OF gt_mark_for_del.

*-- Findungsprotokoll-steuerung
DATA: BEGIN OF lepad_pakti.
        INCLUDE STRUCTURE lepad_par.
DATA: END OF lepad_pakti.
*--

* Global structures for dialog processing "46A BEY
DATA: gs_set_cursor TYPE shp_cursor,
      gs_get_cursor TYPE shp_cursor,
      gf_pushbutton_line TYPE shp_cursor-line,
      gf_cursor_tabix LIKE sy-tabix,                        "n_583914
      gf_cursor_fieldname TYPE shp_cursor-fieldname,
      gf_title_posnr(6) TYPE c.

* Variable to store last value of weight unit
DATA: gf_save_gewei TYPE gewei.

* Tables for the storing of the items already displayed
DATA: gt_wlips_main TYPE shp_wlips OCCURS 0,
      gt_wlips_chsp TYPE shp_wlips OCCURS 0.

* Data for storing data relevant for dialog processing
DATA: gt_ilips_main TYPE shp_ilips OCCURS 0,
      gt_ilips_chsp TYPE shp_ilips OCCURS 0,
      gs_ilips_main TYPE shp_ilips,
      gs_ilips_chsp TYPE shp_ilips,
      gs_xlips_main TYPE lipsvb,
      gs_xlips_chsp TYPE lipsvb,
      gs_lips_main TYPE lips,
      gs_lips_chsp TYPE lips,
      gf_loopc_main TYPE syloopc,
      gf_loopc_chsp TYPE syloopc,
      gf_umfang_main TYPE c,
      gs_vbup_uecha TYPE vbup,                              "50A
      gf_tabix_zeile_1_main TYPE sytabix,
      gf_force_cursor_line_1 TYPE c,
      gf_tabix_zeile_1_chsp TYPE sytabix.

DATA: kunnr_old LIKE kuwev-kunnr.      "Ship-to party AIP


* For customer-specific copy-routines (VOFM) acces to vorgabe_daten
DATA: gs_vorgabe_daten TYPE shp_vorgabe_daten.

* Globally known definitions for BAdI instances
INCLUDE mv50a_badi_def.                                     "470

* Tabelle der Nachricht für die Kommiliste                "v_n_614627
DATA: BEGIN OF nat OCCURS 10.
        INCLUDE STRUCTURE nast.
DATA: END OF nat.                                         "^_n_614627

* documentary batch
DATA:
  gf_docubatch_active TYPE xfeld.

DATA:   END OF COMMON PART.
*eject
TABLES: tvshp.                         "Zentrale Steuerung


DATA  global_pricing_type LIKE t683-knprs_v.

*---global used constants
INCLUDE shpconst.

*-- Findungsprotokoll-steuerung
TABLES: tvpad.


* administration table for serial numbers changes on delivery item level
DATA: gt_serno_change TYPE TABLE OF shp_serno_change.       "470

* Difference of the sum of the weight and volumn of the HU before and
* after changes. (X/Y-difference).
DATA: gf_hu_weight_diff,
      gf_hu_volumn_diff.

*SPE INB ST
DATA: BEGIN OF spe_control,
        database_update TYPE xfeld,
      END OF spe_control.