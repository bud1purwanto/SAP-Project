*&---------------------------------------------------------------------*
*&      Module  is_enhancement_04 former MCOE_WERKS_CHECK1
*&---------------------------------------------------------------------*
* Enhancement Point needed - create in ANI 005
* Dynpro SAPMV45A 823
*----------------------------------------------------------------------*
MODULE is_enhancement_04 input.

ENHANCEMENT-POINT IS_ENHANCEMENT_04_01 SPOTS ES_SAPMV45A.

ENDMODULE.                     " is_enhancement_04

*&---------------------------------------------------------------------*
*&      Module  is_enhancement_08 former OIU_GUEEN_PRUEFEN
*&---------------------------------------------------------------------*
* Enhancement Point needed - create in ANI 005
* Dynpro SAPMV45A 8030
*----------------------------------------------------------------------*
MODULE is_enhancement_08 input.

ENHANCEMENT-POINT IS_ENHANCEMENT_08_01 SPOTS ES_SAPMV45A.

ENDMODULE.                     " is_enhancement_08

*&---------------------------------------------------------------------*
*&      Module  is_enhancement_09 former RESET_KUAGV
*&---------------------------------------------------------------------*
* Enhancement Point needed - create in ANI 005
* Dynpro SAPMV45A 8499
*----------------------------------------------------------------------*
MODULE is_enhancement_09 input.

ENHANCEMENT-POINT IS_ENHANCEMENT_09_01 SPOTS ES_SAPMV45A.

ENDMODULE.                     " is_enhancement_09

*&---------------------------------------------------------------------*
*&      Module  is_enhancement_10 former RESET_KUWEV
*&---------------------------------------------------------------------*
* Enhancement Point needed - create in ANI 005
* Dynpro SAPMV45A 8499
*----------------------------------------------------------------------*
MODULE is_enhancement_10 input.

ENHANCEMENT-POINT IS_ENHANCEMENT_10_01 SPOTS ES_SAPMV45A.

ENDMODULE.                     " is_enhancement_10
*&---------------------------------------------------------------------*
*&  Include           MV45AIIS
*&---------------------------------------------------------------------*

* Multiple used include IS_ENHANCEMENT was created by the IS2ERP project
* -> migration of industry solutions into the ERP 2005.

* Why?
* IS2ERP migration is supported by the Switch Framework (SFW) tools of
* NetWeaver 2005.
* SFW does not support the migration of the following IS Dynpro
* screen logic (example):

* FIELD <core-field> MODULE <is-module>.

* For migration purposes the IS module needs to be replaced by a CORE
* module. Therefore this multiple used include was created to collect
* such by IS2ERP created CORE modules (IS_ENHANCEMENT_xx). Within
* this module SFW can be used again to switch the implementation of the
* former IS Module.


*&---------------------------------------------------------------------*
*&      Module  is_enhancement_03 former VBAP-BWTAR_VAL_823
*&---------------------------------------------------------------------*
* Enhancement Point needed - create in ANI 005
* Dynpro SAPMV45A 823
*----------------------------------------------------------------------*
MODULE is_enhancement_03.

ENHANCEMENT-POINT IS_ENHANCEMENT_03_01 SPOTS ES_SAPMV45A.

ENDMODULE.                     " is_enhancement_03
