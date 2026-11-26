*----------------------------------------------------------------------*
*   INCLUDE TABCDAT1
*   Definition table control                                           *
*----------------------------------------------------------------------*
constants: scr_all       like sy-dynnr value '0200'.
constants: scr_gew       like sy-dynnr value '0201'.
constants: scr_kom       like sy-dynnr value '0220'.
constants: scr_lgr       like sy-dynnr value '0210'.
constants: scr_cha       like sy-dynnr value '0250'.
constants: scr_pod_quan  like sy-dynnr value '0260'.     "POD quantities
constants: scr_avi       like sy-dynnr value '0270'.
constants: scr_gwe       like sy-dynnr value '0280'.
constants: scr_over      like sy-dynnr value '1102'.        "46A BEY
constants: scr_pick      like sy-dynnr value '1104'.
constants: scr_load      like sy-dynnr value '1106'.
constants: scr_tran      like sy-dynnr value '1108'.
constants: scr_pod       like sy-dynnr value '1110'. "POD screen
constants: scr_wada      like sy-dynnr value '1112'. "GM Data screen
constants: scr_ret_crm   like sy-dynnr value '1120'. "SPE returns
constants: scr_ret_sto   like sy-dynnr value '1124'. "SPE returns
constants: scr_chnd      like sy-dynnr value '3112'. "batch split screen
constants: scr_chnd_empty like sy-dynnr value '3120'."empty screen
constants: scr_over_inb  like sy-dynnr value '1202'.
constants: scr_pick_inb  like sy-dynnr value '1204'.
constants: scr_load_inb  like sy-dynnr value '1206'.
constants: scr_tran_inb  like sy-dynnr value '1208'.
constants: scr_chnd_inb  like sy-dynnr value '3212'. "batch split screen

type-pools: cxtab.

controls: tc_lips_all  type tableview using screen scr_all.
controls: tc_lips_gew  type tableview using screen scr_gew.
controls: tc_lips_lgr  type tableview using screen scr_lgr.
controls: tc_lips_kom  type tableview using screen scr_kom.
controls: tc_lips_cha  type tableview using screen scr_cha.
controls: tc_lips_avi  type tableview using screen scr_avi.
controls: tc_lips_gwe  type tableview using screen scr_gwe.
controls: tc_lips_over type tableview using screen scr_over."46A BEY
ENHANCEMENT-POINT TABCDAT1_01 SPOTS ES_SAPMV50A STATIC .
* IS2ERP IS-CWM CWEK004650/CWEK005159 begin
* retrofit for dynpros in SAPMV50A
CONTROLS: TC_LIPS_OVER_CW     TYPE TABLEVIEW USING SCREEN '8102'.
*POD screen
CONTROLS: TC_LIPS_POD_CW      TYPE TABLEVIEW USING SCREEN '8110'.
CONTROLS: TC_LIPS_POD_QUAN_CW TYPE TABLEVIEW USING SCREEN '8260'.
*IS2ERP IS-CWMCWEK004650/CWEK005159 end
controls: tc_lips_pick type tableview using screen scr_pick.
controls: tc_lips_pod  type tableview using screen scr_pod. "POD screen
controls: tc_lips_wada type tableview using screen scr_wada. "MOV Screen
controls: tc_ret_data  type tableview using screen scr_ret_crm. "SPE returns
controls: tc_ret_sto   type tableview using screen scr_ret_sto. "SPE returns
controls: tc_lips_pod_quan type tableview using screen scr_pod_quan.
controls: tc_lips_load type tableview using screen scr_load.
controls: tc_lips_tran type tableview using screen scr_tran.
controls: tc_lips_chnd type tableview using screen scr_chnd.
controls: tc_lips_over_inb type tableview using screen scr_over_inb.
controls: tc_lips_pick_inb type tableview using screen scr_pick_inb.
controls: tc_lips_load_inb type tableview using screen scr_load_inb.
controls: tc_lips_tran_inb type tableview using screen scr_tran_inb.
controls: tc_lips_chnd_inb type tableview using screen scr_chnd_inb.

field-symbols: <tc> type cxtab_control.