***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe C:  CUA_SETZEN                                           *
*                CUA_STARTEN                                          *
*                                                                     *
***********************************************************************
include mv50af0c_call_bild_senden.
include mv50af0c_call_badi_activate_ta."b_page
include mv50af0c_call_badi_read_delive."ry
include mv50af0c_call_badi_change_fiel."d_attributes
include mv50af0c_call_badi_change_fcod."e_attributes
include mv50af0c_check_tps_change.
include mv50af0c_check_tcode_authoriza."tion
include mv50af0c_commit_in_form_commit.
include mv50af0c_confirm_central.
include mv50af0c_create_badi_instance.                      "470
include mv50af0c_cua_deactivate_pushbu."tton
include mv50af0c_cua_eliminate_pushbut."tton
include mv50af0c_cua_fcode_allow.
include mv50af0c_cua_fcode_dynamic.
include mv50af0c_cua_fcode_scrgroup.
include mv50af0c_cua_fcode_head.
include mv50af0c_cua_fcode_item.
include mv50af0c_cua_fcode_static.
include mv50af0c_cua_fcode_tcode.
include mv50af0c_cua_navigation_set.
include mv50af0c_cua_setzen.
include mv50af0c_cua_taxitab_allow.
include mv50af0c_cursor_setzen.

* Screen extensions (BAdIs)
include mv50af0c_cust_head_set_data.
include mv50af0c_cust_head_get_data.
include mv50af0c_cust_head_pass_fcode.

include mv50af0c_cust_item_set_data.
include mv50af0c_cust_item_get_data.
include mv50af0c_cust_item_pass_fcode.

include mv50af0c_cust_over_set_data.
include mv50af0c_cust_over_get_data.
include mv50af0c_cust_over_pass_fcode.

include mv50af0c_cust_scem_set_data.
include mv50af0c_cust_scem_get_data.
include mv50af0c_cust_scem_pass_fcode.

include mv50af0c_cust_gltr_set_data.
include mv50af0c_cust_gltr_get_data.
include mv50af0c_cust_gltr_pass_fcode.

include mv50af0c_cust_glti_set_data.
include mv50af0c_cust_glti_get_data.
include mv50af0c_cust_glti_pass_fcode.

include mv50af0c_cust_auid_set_data.
include mv50af0c_cust_auid_get_data.
include mv50af0c_cust_auid_pass_fcode.