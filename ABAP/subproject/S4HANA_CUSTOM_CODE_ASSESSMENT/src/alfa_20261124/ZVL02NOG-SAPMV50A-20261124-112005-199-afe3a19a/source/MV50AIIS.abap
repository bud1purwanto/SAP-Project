*&---------------------------------------------------------------------*
*&  Include           MV50AIIS
*&---------------------------------------------------------------------*

* The multiple used include MV50AIIS was created by the IS2ERP project
* -> migration of industry solutions into the ERP 2005.

* Why?
* IS2ERP migration is supported by the Switch Framework (SFW) tools of
* NetWeaver 2005.
* SFW does not support the migration of the following IS Dynpro
* screen logic (example):

* FIELD EKPO-WEBRE MODULE CHECK_OIA_SPLTIV.

* FIELD EKPO-WEBRE is a CORE field and cannot be switched by SFW.
* MODULE CHECK_OIA_SPLTIV is an IS module and needs to be switched, but
* the syntax check does not allow the introduction of an SFW switch.

* For migration purposes the IS module needs to be replaced by a CORE
* module. Therefore this multiple used include was created to collect
* such by IS2ERP created CORE modules (IS_ENHANCEMENT_xx). Within
* this module SFW can be used again to switch the implementation of the
* former IS Module.

MODULE IS_ENHANCEMENT_01 INPUT.
* Dynproname und - nummer: SAPMV50A 0108
* ursprünglicher Modulname: MODULE EKES_LESEN

ENHANCEMENT-POINT MV50AIIS_01 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_01

MODULE IS_ENHANCEMENT_02 INPUT.
* Dynproname und - nummer: SAPMV50A 0370
* ursprünglicher Modulname: module trx_flg_route_setzen

ENHANCEMENT-POINT MV50AIIS_02 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_02

MODULE IS_ENHANCEMENT_03 INPUT.
* Dynproname und - nummer: SAPMV50A 0370
* ursprünglicher Modulname: module trx_read_route_data

ENHANCEMENT-POINT MV50AIIS_03 SPOTS ES_SAPMV50A STATIC.

ENHANCEMENT-POINT MV50AIIS_04 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_03

MODULE IS_ENHANCEMENT_04 INPUT.
* Dynproname und - nummer: SAPMV50A 1208 and 2208
* ursprünglicher Modulname: MODULE TRX_f4_AULWE

ENHANCEMENT-POINT MV50AIIS_05 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_04


MODULE IS_ENHANCEMENT_05 INPUT.
* Dynproname und - nummer: SAPMV50A 2210
* ursprünglicher Modulname: MODULE borgr_check_shpm_append

ENHANCEMENT-POINT MV50AIIS_06 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_05

MODULE IS_ENHANCEMENT_06 INPUT.
* Dynproname und - nummer: SAPMV50A 108
* ursprünglicher Modulname: MODULE GET_PAB_DATA

ENHANCEMENT-POINT MV50AIIS_07 SPOTS ES_SAPMV50A.

ENDMODULE.  "IS_ENHANCEMENT_06