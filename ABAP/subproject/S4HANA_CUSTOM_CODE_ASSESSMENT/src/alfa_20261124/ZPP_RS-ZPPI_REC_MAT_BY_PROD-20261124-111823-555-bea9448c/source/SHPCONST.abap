***INCLUDE SHPCONST .
include v70t_text_constants.

constants: gc_true(01)  type c          value 'X',
           gc_false(01) type c          value ' '.
* BAPI Methods
constants: begin of gc_method,
             savereplica like bdi_bapi-method value 'SAVEREPLICA',
             confirm_dec like bdi_bapi-method value 'CONFIRMDECENTRAL',
             split_dec   like bdi_bapi-method value 'SPLITDECENTRAL',
             change      like bdi_bapi-method value 'DELIVERYCHANGE',
           end of gc_method.
* Update Flag
constants: begin of gc_updfl,
             datbas(01) type c          value ' ',
             insert(01) type c          value 'I',
             update(01) type c          value 'U',
             delete(01) type c          value 'D',
           end of gc_updfl.
* Transaction type
constants: begin of gc_trtyp,
             create     like t180-trtyp value 'H',
             change     like t180-trtyp value 'V',
             display    like t180-trtyp value 'A',
           end of gc_trtyp.
* Message type
constants: begin of gc_msgty,
             error      like syst-msgty value 'E',
             abend      like syst-msgty value 'A',
             warning    like syst-msgty value 'W',
             info       like syst-msgty value 'I',
             success    like syst-msgty value 'S',
           end of gc_msgty.
* Use of hierarchy item
constants: begin of gc_hievw,
             mainitem       type bapiobdlvitem-usehieritm value ' ',
             btchsubitm     type bapiobdlvitem-usehieritm value '1',
             bomsubitem     type bapiobdlvitem-usehieritm value '2',
             prodselitm     type bapiobdlvitem-usehieritm value '3',
             kitcompitm     type bapiobdlvitem-usehieritm value '7',
             replkitcompitm type bapiobdlvitem-usehieritm value '8',
           end of gc_hievw.
* Indicator for batches / evaluation types
constants: begin of gc_xchbw,
             nobtcheva  like bapiobdlvitem-btchevaltyp value ' ',
             batch      like bapiobdlvitem-btchevaltyp value '1',
             evatype    like bapiobdlvitem-btchevaltyp value '2',
           end of gc_xchbw.
* Type of partner number
constants: begin of gc_nrart,
             partner    like tvpa-nrart value 'AP',
             customer   like tvpa-nrart value 'KU',
             supplier   like tvpa-nrart value 'LI',
             personno   like tvpa-nrart value 'PE',
           end of gc_nrart.
* Partner roles
constants: begin of gc_parvw,
             soldto     like vbpa-parvw value 'AG',
             shipto     like vbpa-parvw value 'WE',
             forwag     like vbpa-parvw value 'SP',
             supplr     like vbpa-parvw value 'LF',
             crssdockto like vbpa-parvw value 'EC',
             crssdockfr like vbpa-parvw value 'SC',
           end of gc_parvw.
* Packing objects
constants: begin of gc_pacobj,
             obdlvry    like vekp-vpobj value '01',
             salsdoc    like vekp-vpobj value '02',
             ibdlvry    like vekp-vpobj value '03',
             shipmnt    like vekp-vpobj value '04',
             free_hu    like vekp-vpobj value '12',           "n_1298072
             x_obdlvry  like vekp-vpobj value '21',
             x_ibdlvry  like vekp-vpobj value '23',
           end of gc_pacobj.
* Deadline types
constants: begin of gc_timtp,
             dlvdt      like bapidlvdeadln-timetype value 'WSHDRLFDAT',
             gisdt      like bapidlvdeadln-timetype value 'WSHDRWADAT',
             gidti      like bapidlvdeadln-timetype value 'WSHDRWADTI',
             loddt      like bapidlvdeadln-timetype value 'WSHDRLDDAT',
             trddt      like bapidlvdeadln-timetype value 'WSHDRTDDAT',
             picdt      like bapidlvdeadln-timetype value 'WSHDRKODAT',
             mavdt      like bapidlvdeadln-timetype value 'WSHDRMBDAT',
             idver      like bapidlvdeadln-timetype value 'IDVERSION', "v_n_1251438
             idtra      like bapidlvdeadln-timetype value 'IDINTRANS',
             iddoc      like bapidlvdeadln-timetype value 'IDDOCUMENT',
             shipm      like bapidlvdeadln-timetype value 'IDSHIPMENT', "^_n_1251438
           end of gc_timtp.
* Special stock
constants: begin of gc_sobkz,
             convend    like lips-sobkz             value 'K',
             direct(2)                              value 'EQ',
             order      TYPE lips-sobkz             VALUE 'E',"n_1026464
             project    TYPE lips-sobkz             VALUE 'Q',"n_1026464
           end of gc_sobkz.

* Reference types, described by tvlk-aufer
constants: begin of gc_aufer,
             lohnbei(1)                              value 'L',
             reservation(2)                          value 'PL',
             project(1)                              value 'P',
             with_vrsli(4)                           value 'LWOH',
             internal_delivery(3)                    value 'OHW',
             sales_order(1)                          value 'X',
*            impacts: for internal deliveries MVKE will not be read
             umbuchung(1)                            value 'H',
           end   of gc_aufer.

constants: begin of gc_sertab,
             delvry       like rserob-taser          value 'SER01',
             hdunit       like rserob-taser          value 'SER06',
           end of gc_sertab.

* Modifying of item category determination ( T184l )
constants: begin of gc_vwpos,
*---delivery with reference to reservation in wage provision process
             wage_pro_res like t184l-vwpos            value 'LRES',
           end   of gc_vwpos.

* product selection

constants: begin of gc_prosa,
* Contains cumulated quantities which do not result from batch split
              kcmeng_wo_batch(2)                     value 'AC',
* Flags used, when TVSU-SUERG is set to 'A'
              outcome_a(2)                           value 'AB',
* Main items which can only be deleted together with sub items
              main(2)                                value 'AC',
* Items carrying the requirements for sub items - no batch
              req_sum(1)                             value 'A',
* Items which share others in the group, refering an order.
              shared_reference(1)                    value 'B',
* Sourcing Main Item - main and sub item relevant for delivery
              srcng_main_all_deli_rel(1)             value 'C',
           end   of gc_prosa.

constants: begin of gc_uepvw,
* Lower Items not checked against number of delivery items (antlf)
              antlf_no_check                        value 'A',
* check against delivery status of mainitem before deliver subitem
              check_lstanr(3)        value 'BCF',
* determine weight/volume independent from tvap-gwrel
              rel_weight_vol         value 'A',
           end   of gc_uepvw.

* SPE: Constant for new values of UEPVW for kit structure
constants: begin of gc_kit_uepvw,
             kit_comp      type lips-uepvw value 'K',
             repl_kit_comp type lips-uepvw value 'R',
             all(2)        type c          value 'KR',
           end of gc_kit_uepvw.

*--message handling
constants:
      begin of gc_refmd,
            reference            value 'A',
            change_create_delete value 'B',
            pick_confirm         value 'C',
      end of gc_refmd,
      begin of gc_glomd,
            dialog                value 'A',
            background            value 'B',
            create_decentral      value 'C',
            confirm_decentral     value 'D',
            backgr_all(3)         value 'BCD',
      end of gc_glomd.

* Special characters for blocking empty fields              "50A
constants: gc_field_block(2) type c value '$%'.

* field-values of TVLK-NEUTE for date-independent re_scheduling
constants: gc_auto_rescheduling(2)         value 'YA'
         .
* Dynpro numbers  46A BEY
constants: gc_dyn_batchsplit         like sy-dynnr value '0250',
           gc_dyn_head_outb_gen_data like sy-dynnr value '0300',
           gc_dyn_head_inb_gen_data  like sy-dynnr value '0370',
           gc_dyn_head_grwe_gen_data like sy-dynnr value '0380',
           gc_dyn_head_outb_transp   like sy-dynnr value '0302',
           gc_dyn_head_outb_text     like sy-dynnr value '0330',
           gc_dyn_item_outb_text     like sy-dynnr value '0530',
           gc_dyn_outb_entry_screen  like sy-dynnr value '0101'.

* Screen group for new dialog (T180-BLDGR is used to distinguish old and
* new dialog)
constants: gc_new_dialog_outb type t180-bldgr value 'E0'.
constants: gc_new_dialog_inb  type t180-bldgr value 'E1'.

* Default icons for symbolizing batch split structure
constants: gc_batch_plus(4) type c value '@3S@',  "ICON_EXPAND
           gc_batch_minus(4) type c value '@3T@'. "ICON_COLLAPSE

* Batch split screen (T185V-PANEL)
constants: gc_panel_chsp type t185v-panel value 'CHSP'.

* Default icons for POD dialog and POD split
constants: gc_pod_display_more(4)   type c value '@1E@',
           gc_pod_enter_more(4)     type c value '@1F@',
           gc_pod_quantity_plus(4)  type c value '@04@',
           gc_pod_quantity_minus(4) type c value '@05@'.

* Default fcodes for POD dialog and POD split
constants: gc_fcode_podoview like sy-ucomm value 'UPOD_T',
           gc_fcode_podsplit like sy-ucomm value 'PPOD_T',
           gc_fcode_podpploe like sy-ucomm value 'PLOE',
           gc_fcode_podenter like sy-ucomm value 'ENT1',
           gc_fcode_podppal  like sy-ucomm value 'PPAL',
           gc_fcode_podpplo  like sy-ucomm value 'PPLO',
           gc_fcode_podcanc  like sy-ucomm value 'ABBR',
           gc_fcode_podtake  like sy-ucomm value 'TAKE',
           gc_fcode_podquit  like sy-ucomm value 'PODQ',
           gc_fcode_podstor  like sy-ucomm value 'PODS'.


*
* Switch off ATP/Requirements for document/process
*
* Lips-noatp: switch of for the documents whole lifetime
constants: gc_atp_do_quan_do_req           value space
         , gc_atp_no_quan_no_req           value 'X'
         , gc_atp_no_quan_do_req           value '1'
         , gc_atp_do_quan_no_req           value '2'
         , gc_atp_no_quan(2)               value 'X1'
         , gc_atp_no_req(2)                value 'X2'
         , gc_atp_no_any(3)                value 'X12'
         , gc_atp_do_quan(2)               value ' 2'
         , gc_atp_do_req(2)                value ' 1'
         , gc_atp_do_any(3)                value ' 12'
         .
* v50agl-quan_no_check: switch off for this process step
constants: gc_chk_do_quan_do_req           value space
         , gc_chk_no_quan_no_req           value 'W'
         , gc_chk_no_quan_do_req           value 'X'
         , gc_chk_do_quan_no_req           value '2'
         , gc_chk_no_quan(2)               value 'WX'
         , gc_chk_no_req(2)                value 'W2'
         , gc_chk_no_any(3)                value 'WX2'
         , gc_chk_do_quan(2)               value ' 2'
         , gc_chk_do_req(2)                value ' X'
         , gc_chk_do_any(3)                value ' X2'
         .

* tvlk-numkirule: finding number intervals for new deliveries created
* by split in LE component   (ULa, 4.6c)
constants: begin of gc_tvlk_numkirule
          ,  none    type leshp_numki_rule value space
          ,  tvlkn   type leshp_numki_rule value 'A'
          ,end   of gc_tvlk_numkirule

* delivery split in LE component  (ULa, 4.6c)
* items in LIKP.SplitDecentral belong to existing (old) delivery or
* created by split (new)
          ,begin of gc_belongs_to
          ,  old     type ledspd_items_belong_to value 'O'
          ,  new     type ledspd_items_belong_to value 'N'
          ,end   of gc_belongs_to
          .

* impossibe field content
constants: gc_impossible like likp-zukrl value '"!___$%&/(&%$(/'.



* Values of the domain posar
constants:  begin of gc_posar
           ,  normal                              value space
           ,  value                               value 'A'
           ,  text                                value 'B'
           ,  packing                             value 'C'
           ,  man_pack                            value 'E'
           ,  relevant_for_vtweg(2)               value ' C'
           ,end  of gc_posar.


* documents within in one type share:
* - database tables
* - enqueue-functions
* - predecessor call-backs
* -...
* used for domains: LESHP_DOCUMENT_TYPE (BAPI, VBUK-VBOBJ for delivery)
constants:  begin of gc_vbobj                     "analog to vbuk-vbobj
           ,  delivery               value 'L'    "Versand
           ,  sales                  value 'A'    "Auftrag
           ,  purchase               value 'B'    "Bestellung
           ,  so_other_system        value '1'    "sales order     "AIP
           ,  po_other_system        value '2'    "purchase order  "AIP

           ,  pr_other_system(2)     value '12'   "other system    "AIP
           ,  purchase_any(2)        value 'B2'   "Bestellung      "AIP
           ,  sales_any(2)           value 'A1'   "Auftrag         "AIP

           ,end of gc_vbobj.



* Flag to trigger activities during beleg_sichern
* see values for DDIC-Domaine leshp_database_update
constants:  begin of gc_database_update

           ,  check_and_save      value '1'  "Default as before
           ,  check_only          value '2'  "1. Step of saving
           ,  check_any(2)        value '12'

           ,  save_only           value '3'  "2. Step of saving
           ,  save_any(2)         value '13'

           ,end of gc_database_update.


* Constant to determine inbound or outbound delivery
constants:  begin of gc_delivery_type

           ,  inbound             value '1'
           ,  outbound            value '2'

           ,end of gc_delivery_type.

* split: materials for stock provided to vendor (LB-Lief)    v_n_597352
constants: gc_crit_mmli_bestell       like likpd-comb_crit value '100000',  "EHP 4
           gc_crit_mmli_bestell_lblkz like likpd-comb_crit value '200000'.
*                                                            ^_n_597352

*  Enable serial number maintenance via WS_DELIVERY_UPDATE
*  This special serial number triggers deletion of serial number list
data: gc_deleting_sernr type gernr value '%$%$%$%$%$%$%$%$%$'.


* Constants for BAPI_DELIVERYPROCESSING_EXEC

* processing mode - like domain shp_bapi_deliproc_proc_mode
constants:  begin of gc_bapi_proc_mode,
              aip value 'A',  "create uncheck delivery for AIP scenario
              46c value 'B',  "old (46c) bapi scenario - create delivery
                              "in one system or change packing item
            end   of gc_bapi_proc_mode.

* error tolerance - like domain LESHP_ERROR_TOLERANCE
constants:  begin of gc_bapi_e_tol,
              ex_at_1st_error value 'X',
              only_abort_mess value 'A',
            end   of gc_bapi_e_tol.

* SPE:Constant for CRM Billing
constants: gc_fkrel_crm_billing(5) value 'QRTUV'.
constants: gc_fkrel_erp_billing(5) value 'ADHJK'.            "n_1121976

* SPE: Constants for change management of decentralized warehouse
constants: begin of gc_cmact,
             no_cm type t340d_cmact value space,
             sync  type t340d_cmact value 'X',
             async type t340d_cmact value 'Q',
             soa_async type t340d_cmact value 'S',      "n_1316048
           end of gc_cmact.

* Constants for processing inbound deliveries on hold
constants: begin of gc_process_hold,
             non_hold     type c value space,"non hold
             insert       type c value 'I', "insert hold
             update       type c value 'U', "replace real with real n_905485
             replace_hold type c value 'H', "replace hold with hold
             replace_real type c value 'R', "replace hold with real
             delete       type c value 'D', "delete hold
             real_real    type c value 'E', "replace real with real n_1162952
*            combinations
             replace(3)   type c value 'RHE',
             repl_upd(4)  type c value 'RHUE',              "n_905485/n_1162952
             create(2)    type c value 'HI',
             existing(4)  type c value 'RHDE',              "n_1162952
             real         type c value space,
           end   of gc_process_hold.

* Constants for SPE Returns
constants: begin of gc_spe_ret,
             acc_app_expected type likp-spe_acc_app_sts value 'A',
             acc_app_ich_err_expected type likp-spe_acc_app_sts value 'D', "enhanced for error dispatching to ICH system
             acc_app_expected_edi type likp-spe_acc_app_sts value 'B',  "enhanced value of domain for likp-spe_acc_app_sts
             acc_app_edi_err_expected type likp-spe_acc_app_sts value 'E', "enhanced for error dispatching to EDI system
             acc_app_expected_ich_inf type likp-spe_acc_app_sts value 'X', "mapping value of ICH in komdlgn interface for value X from BAPIDELICIOUSREQUEST
             acc_app_received type likp-spe_acc_app_sts value 'C',
             shp_inf_expected type likp-spe_shp_inf_sts value 'A',
             shp_inf_received type likp-spe_shp_inf_sts value 'C',
           end of gc_spe_ret.

* Constants for SPE scenarios
constants: begin of gc_le_scenario,
             sto    type likp-spe_le_scenario value 'S',
             crm    type likp-spe_le_scenario value 'C',
             tpop   type likp-spe_le_scenario value 'T',
             return type likp-spe_le_scenario value 'R',
             crossd type likp-spe_le_scenario value 'A',
             kts    type likp-spe_le_scenario value 'K',  "v_EhP 3
             dirpla type likp-spe_le_scenario value 'V', "direct delivery to another plant
             dircus type likp-spe_le_scenario value 'W', "direct delivery to customer
             stopac type likp-spe_le_scenario value 'U', "STO del. w/ pack. items "^_EhP 3
             prdsup type likp-spe_le_scenario value 'B', "production supply from EWM "v_EHP4
             consum type likp-spe_le_scenario value 'F', "PP consumption for EWM
             rem    type likp-spe_le_scenario value 'G', "Repetitive Manuf.
             kanban type likp-spe_le_scenario value 'H', "Kanban supply "^_EHP4
             additm type likp-spe_le_scenario value 'I', "Additional Item Discrepancy EHP5
             advret type likp-spe_le_scenario value 'L', "Advanced Returns Delivery EhP6
             pcreq  type likp-spe_le_scenario value 'M', "Posting Change Request EhP6
             follup TYPE likp-spe_le_scenario VALUE 'N', "Follow-Up Delivery (e.g. Scrapping or Putaway)
             cntret TYPE likp-spe_le_scenario VALUE 'O', "Counter Returns Delivery
             repair TYPE likp-spe_le_scenario VALUE 'P', "Posting Change for Repair Order
             sndbck TYPE likp-spe_le_scenario VALUE 'Q', "Sendback to Customer
           end of gc_le_scenario.

* Constants for SPE initiator processes
constants: begin of gc_initiator_process,
             tcrossdock type /spe/de_initiator_process value 'TCD',
             pickdenial type /spe/de_initiator_process value 'PD',
             pushdeploy type /spe/de_initiator_process value 'PDY',
             pickfrecpt type /spe/de_initiator_process value 'PFR',
             qtyreductn type /spe/de_initiator_process value 'CRM',
             kittostock type /spe/de_initiator_process value 'KTS',  "v_EhP 3
             reversekit type /spe/de_initiator_process value 'KTR',
             gr_product type /spe/de_initiator_process value 'GRP',  "v_EhP 3
*            ext. WM IF / start
             wmdgeneral type /spe/de_initiator_process value 'WMD',
             wmdputaway type /spe/de_initiator_process value 'WPA',
             wmdcrodock type /spe/de_initiator_process value 'WCD',
             wmdcdputaw type /spe/de_initiator_process value 'WCP',
             wmdcdprepa type /spe/de_initiator_process value 'WCV',
             wmdcdftrec type /spe/de_initiator_process value 'WCR',
             wmdcdftmer type /spe/de_initiator_process value 'WCM',
             wmdftrecip type /spe/de_initiator_process value 'WFR',
             wmdftmerch type /spe/de_initiator_process value 'WFM',
*            ext. WM IF / end
             dirdlvscrp type /spe/de_initiator_process value 'SCR',
             dirdlvpick type /spe/de_initiator_process value 'PIG',
             dirdlvdsh  type /spe/de_initiator_process value 'DSH',  "^_EhP 3
             crosscomp  TYPE /spe/de_initiator_process VALUE 'CLR',
             intracomp  TYPE /spe/de_initiator_process VALUE 'ILR',
             advreturn  TYPE /spe/de_initiator_process VALUE 'ARD',
             pstchgreq  TYPE /spe/de_initiator_process VALUE 'PCR',
             advretsto  TYPE /spe/de_initiator_process VALUE 'ARS',
             advretcre  TYPE /spe/de_initiator_process VALUE 'ACR',
             advretfup  TYPE /spe/de_initiator_process VALUE 'AFU',
             advrtrepl  TYPE /spe/de_initiator_process VALUE 'ARR',
             advrtrepa  TYPE /spe/de_initiator_process VALUE 'ARE',
           end   of gc_initiator_process.


* Constants for type of external identification
constants: begin of gc_lifex_type,
             kit_to_stock  type /spe/de_lifex_type value 'K',  "EhP 3
             returns       type /spe/de_lifex_type value 'R',
             stocktransfer type /spe/de_lifex_type value 'S',
             vendor_asn    type /spe/de_lifex_type value 'V',
             NOSTOTRANSFER TYPE /SPE/DE_LIFEX_TYPE VALUE 'N', "n_1364822
             FREE_USAGE    TYPE /SPE/DE_LIFEX_TYPE VALUE SPACE,
           end   of gc_lifex_type.

* Constants for the debit/credit indicator
constants: begin of gc_shkzg,
             debit  type shkzg value 'S',
             credit type shkzg value 'H',
           end of  gc_shkzg.

* Constants for delivery category                          "v_n_1462820
CONSTANTS: BEGIN OF gc_dlvtp,
             obdlv    TYPE dlvtp VALUE 'OD',
             ibdlv    TYPE dlvtp VALUE 'ID',
             transfer TYPE dlvtp VALUE 'TP',
             ret_vend TYPE dlvtp VALUE 'RL',
             subcon   TYPE dlvtp VALUE 'LB',
             ret_cust TYPE dlvtp VALUE 'RK',
           END OF gc_dlvtp.                                "^_n_1462820

CONSTANTS: BEGIN OF GC_STGE_LOC_CHANGE,                     "v_n_1302686
             requested type shp_stge_loc_change value 'A',
             withdrawn type shp_stge_loc_change value 'B',
             original  type shp_stge_loc_change value space,
           end of gc_stge_loc_change.                       "^_n_1302686