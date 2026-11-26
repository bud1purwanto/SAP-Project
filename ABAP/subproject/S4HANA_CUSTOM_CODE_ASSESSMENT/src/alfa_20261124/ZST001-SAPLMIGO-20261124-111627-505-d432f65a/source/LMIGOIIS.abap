*&---------------------------------------------------------------------*
*&  Include           LMIGOIIS
*&---------------------------------------------------------------------*
* IS2ERP: Include contains modules that are needed for these cases:
* { Insert FIELD corefield MODULE ismodule }
*&---------------------------------------------------------------------*
*&      Module  is_enhancement_01  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE is_enhancement_01 INPUT.
ENHANCEMENT-POINT IS_ENHANCEMENT_01_01 SPOTS ES_SAPLMIGO.


ENDMODULE.                 " is_enhancement_01  INPUT

MODULE is_enhancement_02 INPUT.
* SAPLMIGO  0200
* /sapmp/batch_check

ENHANCEMENT-POINT LMIGOIIS SPOTS ES_SAPLMIGO.

ENDMODULE.                " is_enhancement_02  INPUT

*&---------------------------------------------------------------------*
*&      Module  variable_paramters_1  OUTPUT
*&---------------------------------------------------------------------*
* IS2ERP Modul CWM
* fill param. for subscreen sub_ts_goitem_quantities (core/industry)
*----------------------------------------------------------------------*
MODULE variable_paramters_1 OUTPUT.
  CLEAR: L_INCL_DYNP.
  L_INCL_DYNP = '0315'.
ENHANCEMENT-POINT LMIGOIIS_02 SPOTS ES_SAPLMIGO.

ENDMODULE.                 " variable_paramters_1 OUTPUT

*&---------------------------------------------------------------------*
*&      Module  variable_paramters_1  OUTPUT
*&---------------------------------------------------------------------*
* IS2ERP Modul CWM
* fill parameter for called subscr. sub_ts_goitem_trans (core/industry)
*----------------------------------------------------------------------*
MODULE variable_paramters_2 OUTPUT.
  CLEAR: L_INCL_DYNP.
  L_INCL_DYNP = '0390'.
ENHANCEMENT-POINT LMIGOIIS_03 SPOTS ES_SAPLMIGO.

ENDMODULE.                 " variable_paramters_2 OUTPUT