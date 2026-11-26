*&---------------------------------------------------------------------*
*&  Include           MV50A_BADI_DEF                                   *
*&---------------------------------------------------------------------*
*   This include should be used only for data definitions of BAdI
*   instances
*----------------------------------------------------------------------*

*data: gi_exit type ref to (name of the interface)

* EH&S (Environment, Health & Safety)
****** Definitions for dangerous goods
data: gi_badi_instance_ehs001 type ref to if_ex_ehs_dg_001.
data: gi_badi_instance_ehs002 type ref to if_ex_ehs_ps_002.

* BAdI for general delivery processing
data: gi_badi_delivery type ref to if_ex_le_shp_delivery_proc.

* BAdI customer tab pages
data: gi_cust_tab_head type ref to if_ex_le_shp_tab_cust_head,
      gi_cust_tab_item type ref to if_ex_le_shp_tab_cust_item,
      gi_cust_tab_over type ref to if_ex_le_shp_tab_cust_over.

* BAdI tab pages for add-on projects
data: gi_cust_tab_scem type ref to if_ex_le_shp_tab_scem_head,
      gi_cust_tab_gltr type ref to if_ex_le_shp_tab_gltr_head, "head
      gi_cust_tab_glti type ref to if_ex_le_shp_tab_gltr_item, "item
      gi_cust_tab_auid type ref to if_ex_le_shp_tab_auid_head. "head

* BAdi for delivery goods movements
data: gi_badi_goodsmovement type ref to if_ex_le_shp_goodsmovement.

**************Begin of retrofit SDP Bw 20050208
* BAdI for goods issue check (SAP-internal)

 data: gi_badi_dlv_gi_ibs type ref to le_shp_dlv_gi_ibs.

* data: gi_badi_dlv_gi_ibs type ref to if_ex_le_shp_dlv_gi_ibs.
* data: g_dlv_gi_active    type char1.
**************End of retrofit SDP Bw 20050208

* BAdI for delivery pricing
data: gi_badi_pricing type ref to if_ex_le_shp_pricing.
* BADi for country-specific fields in pricing:
* Migrated to New BAdI, Instance is created / buffered in form BADI_SD_COM_COUNTRY

* BAdI for delivery creation -> additional fields from KOMDLGN to LIKP and LIPS
DATA: gi_badi_gn_dlv_create TYPE REF TO IF_EX_LE_SHP_GN_DLV_CREATE.