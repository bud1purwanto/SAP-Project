*----------------------------------------------------------------------*
*   INCLUDE MV50ADIA                                                   *
*----------------------------------------------------------------------*

*-----------------------------------------------------------------------
*        Fields for controlling the delivery dialog
*-----------------------------------------------------------------------
* Correct name of the picking/putaway quantity (inbound/outbound)
* Output length 17 equals the defined lenght of LIPSD-PIKMG
data: gf_pikmg_txt(17) type c.

* Global flags that control the processing of the item or of the header
* respectively (FORM LIPS_BEARBEITEN or LIKP_BEARBEITEN). It is
* refreshed during dynpro initialization in PBO and can be set in the
* modules of the processed subscreens
data: gf_item_work_flag type c,
      gf_header_work_flag type c.

* Global return code (to be used on module level)
data: gf_subrc like sy-subrc.

* Variable for the dynpro number of the subscreen containing the data
* of the preceding document.
data: gf_dyn_precede like sy-dynnr.

* Variables for the dynpro program and number of the deadline subscreen
data: gf_deadline_program like sy-repid,
      gf_deadline_screen  like sy-dynnr.

* Variables for the dynpro program and number of the text subscreen
data: gf_text_program like sy-repid,                        "HP_380503
      gf_text_screen  like sy-dynnr.

data: gf_returns_subscreen type sydynnr.                    "SPE returns

* Title line of the table control
data: gf_tc_title(80) type c.

* Variable text for posting goods movements
data: gf_wabu_ftext(25) type c.                             "n_1309475

* Variable for saving FCODE
data: gf_save_fcode type fcode.

* Variable for transaction variant if active
data: gf_tcvariant like shdtvciu-tcvariant.                 "HP_211201
data: gf_param_tcode like shdtv-tcode.                      "n_532957

* Flag indicating errors during reading the document
data: gf_error_on_document_read type c value space,
      gf_save_vstel like likp-vstel,                        "v_n_585842
      gf_save_lfart like likp-lfart,
      gf_save_datbi like lv50c-datbi,
      gf_save_abpos like lv50c-abpos,
      gf_save_bipos like lv50c-bipos,                       "^_n_585842
      gf_save_vbeln like likp-vbeln.

data: gf_vbeln_inb  like likp-vbeln,
      gf_vbeln_outb like likp-vbeln.

* Country and transportation zone of ship-to party before last change
data: gf_we_land1 like vbpa-land1,                          "HP_377160
      gf_we_lzone like vbpa-lzone.

* Flag indicates that the FCODE_PROCESSING is active
data: gf_fcode_processing_active type c.                    "n_608056

* Flag indicating the current process view on the delivery data
data: gf_process_view type c.
constants: gc_view_general        type c value 'G',
           gc_view_picking        type c value 'P',
           gc_view_loading        type c value 'L',
           gc_view_transportation type c value 'T',
           gc_view_text           type c value 'X',
           gc_view_foreign_trade  type c value 'F',
           gc_view_financials     type c value 'M',
           gc_view_administration type c value 'A',
           gc_view_customer       type c value 'K',           "SPE
           gc_view_returns        type c value 'R',           "SPE
           gc_view_conditions     type c value 'C',
           gc_view_catchweight    type c value 'W'.

* Administration of customer and IBS tab pages
data: gs_cust_tab type shp_cust_tab_page,
      begin of gt_taxi_admin occurs 0,
        fcode_new  like t185-fcode,
        fcode_old  like t185-fcode,
        fcode_real like t185-fcode,
        caption   like taxi_tabstrip_captions-tab01,
      end of gt_taxi_admin.

* Icons
data: gf_icon_batch_plus     like rv50a-chmult,
      gf_icon_batch_minus    like rv50a-chmult,
      gf_icon_pod_one_line   like rv50a-podmul,
      gf_icon_pod_mul_line   like rv50a-podmul,
      gf_icon_quantity_plus  like rv50a-podmul,
      gf_icon_quantity_minus like rv50a-podmul.

*-----------------------------------------------------------------------
*        Table of inactive FCODEs
*-----------------------------------------------------------------------
data: cua_exclude      type shp_cua_exclude_t,
      save_cua_exclude type shp_cua_exclude_t.

*-----------------------------------------------------------------------
*  Old dialog
*-----------------------------------------------------------------------
* Not active in creation mode
data: begin of cua_exclu_anlegen,
        f01 type fcode value 'LOES',
        f02 type fcode value 'IFLU',
        f03 type fcode value 'LT41',
        f04 type fcode value 'VL01',
        f05 type fcode value 'DRCK',
        f06 type fcode value 'LIST',
        f07 type fcode value 'VL31',
        f08 type fcode value 'VL41',
        f09 type fcode value 'LOKN',
        f10 type fcode value 'LOKW',
        f11 type fcode value 'TILN',
        f12 type fcode value 'TILW',
        f13 type fcode value 'IAEN',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_anlegen.

* Not active in change mode
data: begin of cua_exclu_aendern,
        f01 type fcode value 'VL02',
        f02 type fcode value 'XXXX',
        f03 type fcode value 'VL32',
        f04 type fcode value 'VL42',
        f05 type fcode value 'BESE',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_aendern.

* Not active in display mode
data: begin of cua_exclu_anzeige,
        f01 type fcode value 'FEAZ',
        f02 type fcode value 'KOMU',
        f03 type fcode value 'LOES',
        f04 type fcode value 'POLE',
        f05 type fcode value 'POLO',
        f06 type fcode value 'PRIN',
        f07 type fcode value 'RAUF',
        f08 type fcode value 'SICH',
        f09 type fcode value 'TEAN',
        f10 type fcode value 'TELO',
        f11 type fcode value 'WABU',
        f12 type fcode value 'VL03',
        f13 type fcode value 'VL70',
        f14 type fcode value 'VL71',
        f15 type fcode value 'FT41',
        f16 type fcode value 'VF01',
        f17 type fcode value 'TEEN',
        f18 type fcode value 'VL33',
        f19 type fcode value 'VL43',
        f20 type fcode value 'POAN',
        f21 type fcode value 'QUIT',
        f22 type fcode value 'QUIM',
        f23 type fcode value 'CHFD',
        f24 type fcode value 'CHKO',
        f25 type fcode value 'CHSL',
        f26 type fcode value 'WABI',
        f27 type fcode value 'VG01',
        f28 type fcode value 'KGGP',
        f29 type fcode value 'IFDC',
        f30 type fcode value 'IFDM',
        f31 type fcode value 'BESE',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_anzeige.

* Not active on batch split screen
data: begin of cua_exclu_chsp,
        f01 type fcode value 'UER1',
        f02 type fcode value 'UER2',
        f03 type fcode value 'UEKO',
        f04 type fcode value 'UELG',
        f05 type fcode value 'FEAZ',
        f06 type fcode value 'VERP',
        f07 type fcode value 'KOMU',
        f08 type fcode value 'WABU',
        f09 type fcode value 'KOMU',
        f10 type fcode value 'KALL',
        f11 type fcode value 'KVER',
        f12 type fcode value 'KPAR',
        f13 type fcode value 'KTEX',
        f14 type fcode value 'KDOK',
        f15 type fcode value 'KEXP',
        f16 type fcode value 'KTEX',
        f17 type fcode value 'IFLU',
        f18 type fcode value 'VL06',
        f19 type fcode value 'IWEM',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_chsp.

* Not acive depending on the shipment status
data: begin of cua_exclu_transport,
        f01 type fcode value 'LOES',
        f02 type fcode value 'POAN',
        f03 type fcode value 'POLO',
        f04 type fcode value 'POLE',                        "HP_336841
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_transport.

*-----------------------------------------------------------------------
*  New dialog
*-----------------------------------------------------------------------
* Not active in creation mode
data: begin of cua_exclu_anlegen_nd,
        f01 type fcode value 'LOES_T',
        f02 type fcode value 'IFLU_T',
        f03 type fcode value 'IAEN_T',
        f04 type fcode value 'ANZA_T',
        f05 type fcode value 'LOKN_T',
        f06 type fcode value 'LOKW_T',
        f07 type fcode value 'TILN_T',
        f08 type fcode value 'TILW_T',
        f09 type fcode value 'VL31_T',
        f10 type fcode value 'CHCR_T',
        f11 type fcode value 'AROD_T',
        f12 type fcode value 'ARID_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_anlegen_nd.

* Not active in change mode
data: begin of cua_exclu_aendern_nd,
        f01 type fcode value 'BESE_T',
        f02 type fcode value 'VL02_T',
        f03 type fcode value 'VL32_T',
        f04 type fcode value 'AROD_T',
        f05 type fcode value 'ARID_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_aendern_nd.

* Not active in display mode
data: begin of cua_exclu_anzeige_nd,
        f01 type fcode value 'FEAZ_T',
        f02 type fcode value 'KOMU_T',
        f03 type fcode value 'LOES_T',
        f04 type fcode value 'POLE_T',
        f05 type fcode value 'POLO_T',
        f06 type fcode value 'RAUF_T',
        f07 type fcode value 'SICH_T',
        f08 type fcode value 'WABU_T',
        f09 type fcode value 'POAN_T',
        f10 type fcode value 'QUIT_T',
        f11 type fcode value 'QUIM_T',
        f12 type fcode value 'CHFD_T',
        f13 type fcode value 'CHKO_T',
        f14 type fcode value 'CHSL_T',
        f15 type fcode value 'KGGP_T',
        f16 type fcode value 'IFDC_T',
        f17 type fcode value 'BESE_T',
        f18 type fcode value 'IFDH_T',
        f19 type fcode value 'IFDV_T',
        f20 type fcode value 'VL03_T',
        f21 type fcode value 'VL33_T',
        f22 type fcode value 'TSEG_INSR',
        f23 type fcode value 'TSEG_DELE',
        f24 type fcode value 'NEUT_T',
        f25 type fcode value 'CHCR_T',
        f26 type fcode value 'PAMU_T',
        f27 type fcode value 'SIMU_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_anzeige_nd.

data: begin of cua_exclu_anzeige_arch_nd,
        f01 type fcode value 'FEAZ_T',
        f02 type fcode value 'KOMU_T',
        f03 type fcode value 'LOES_T',
        f04 type fcode value 'POLE_T',
        f05 type fcode value 'POLO_T',
        f06 type fcode value 'RAUF_T',
        f07 type fcode value 'SICH_T',
        f08 type fcode value 'WABU_T',
        f09 type fcode value 'POAN_T',
        f10 type fcode value 'QUIT_T',
        f11 type fcode value 'QUIM_T',
        f12 type fcode value 'CHFD_T',
        f13 type fcode value 'CHKO_T',
        f14 type fcode value 'CHSL_T',
        f15 type fcode value 'KGGP_T',
        f16 type fcode value 'IFDC_T',
        f17 type fcode value 'BESE_T',
        f18 type fcode value 'IFDH_T',
        f19 type fcode value 'IFDV_T',
        f20 type fcode value 'AROD_T',
        f21 type fcode value 'ARID_T',
        f22 type fcode value 'TSEG_INSR',
        f23 type fcode value 'TSEG_DELE',
        f24 type fcode value 'NEUT_T',
        f25 type fcode value 'CHCR_T',
        f26 type fcode value 'PAMU_T',
        f27 type fcode value 'SIMU_T',
        f28 type fcode value 'ANZA_T',
        f29 type fcode value 'NEWD_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_anzeige_arch_nd.


* Not active in POD mode (change)
data: begin of cua_exclu_vlpodc_nd,
        f01 type fcode value 'FEAZ_T',
        f02 type fcode value 'KOMU_T',
        f03 type fcode value 'LOES_T',
        f04 type fcode value 'POLE_T',
        f05 type fcode value 'POLO_T',
        f06 type fcode value 'RAUF_T',
        f07 type fcode value 'WABU_T',
        f08 type fcode value 'POAN_T',
        f09 type fcode value 'QUIT_T',
        f10 type fcode value 'QUIM_T',
        f11 type fcode value 'CHFD_T',
        f12 type fcode value 'CHKO_T',
        f13 type fcode value 'CHSL_T',
        f14 type fcode value 'KGGP_T',
        f15 type fcode value 'IFDC_T',
        f16 type fcode value 'BESE_T',
        f17 type fcode value 'IFDH_T',
        f18 type fcode value 'IFDV_T',
        f19 type fcode value 'TSEG_INSR',
        f20 type fcode value 'TSEG_DELE',
        f21 type fcode value 'CRMA_T',
        f22 type fcode value 'CROA_T',
        f23 type fcode value 'VL02_T',
        f24 type fcode value 'VL03_T',
        f27 type fcode value 'SIMU_T',
        f28 type fcode value 'AROD_T',
        f29 type fcode value 'ARID_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_vlpodc_nd.

* Not active in POD mode (display)
data: begin of cua_exclu_vlpoda_nd,
        f01 type fcode value 'FEAZ_T',
        f02 type fcode value 'KOMU_T',
        f03 type fcode value 'LOES_T',
        f04 type fcode value 'POLE_T',
        f05 type fcode value 'POLO_T',
        f06 type fcode value 'RAUF_T',
        f07 type fcode value 'WABU_T',
        f08 type fcode value 'POAN_T',
        f09 type fcode value 'QUIT_T',
        f10 type fcode value 'QUIM_T',
        f11 type fcode value 'CHFD_T',
        f12 type fcode value 'CHKO_T',
        f13 type fcode value 'CHSL_T',
        f14 type fcode value 'KGGP_T',
        f15 type fcode value 'IFDC_T',
        f16 type fcode value 'BESE_T',
        f17 type fcode value 'IFDH_T',
        f18 type fcode value 'IFDV_T',
        f19 type fcode value 'SICH_T',
        f20 type fcode value 'TSEG_INSR',
        f21 type fcode value 'TSEG_DELE',
        f22 type fcode value 'NEUT_T',
        f23 type fcode value 'CRMA_T',
        f24 type fcode value 'CROA_T',
        f25 type fcode value 'VL02_T',
        f26 type fcode value 'VL03_T',
        f27 type fcode value 'SIMU_T',
        f28 type fcode value 'AROD_T',
        f29 type fcode value 'ARID_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_vlpoda_nd.

* Not acive depending on the shipment status
data: begin of cua_exclu_transport_nd,
        f01 type fcode value 'LOES_T',
        f02 type fcode value 'POAN_T',
        f03 type fcode value 'POLO_T',
        f99 type fcode value '9999',   "Loop end sign
      end of cua_exclu_transport_nd.

tables: /spe/ret_dia.                  "SPE returns