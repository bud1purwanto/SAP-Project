*----------------------------------------------------------------------*
***INCLUDE MV45AV_MSR .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FU_CODE_HELP
*&---------------------------------------------------------------------*
MODULE fu_code_help.
  PERFORM f4_fu_code.
ENDMODULE.                 " FU_CODE_HELP
*&---------------------------------------------------------------------*
*&      Module  INSPECTION_CODE_HELP
*&---------------------------------------------------------------------*
MODULE inspection_code_help.
  PERFORM f4_insp_code.
ENDMODULE.                 " INSPECTION_CODE_HELP

*&---------------------------------------------------------------------*
*&      Module  CUSTOMER_INSPECTION_CODE_HELP
*&---------------------------------------------------------------------*
MODULE customer_inspection_code_help.
  PERFORM f4_insp_code_cust.
ENDMODULE.                 " INSPECTION_CODE_HELP

*&---------------------------------------------------------------------*
*&      Module  FASTCHANGE_MAT_RECEIVED_HELP  INPUT
*&---------------------------------------------------------------------*
MODULE fastchange_mat_received_help INPUT.
  PERFORM f4_fastchange_mat_received.
ENDMODULE.                 " FASTCHANGE_MAT_RECEIVED_HELP  INPUT
*&---------------------------------------------------------------------*
*&      Module  FASTCHANGE_AT_CUST_SITE_HELP  INPUT
*&---------------------------------------------------------------------*
MODULE fastchange_at_cust_site_help INPUT.
  PERFORM f4_fastchange_at_cust_site.
ENDMODULE.                 " FASTCHANGE_AT_CUST_SITE_HELP  INPUT
*&---------------------------------------------------------------------*
*&      Module  NFU_CODE_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE nfu_code_help INPUT.
  PERFORM f4_nfu_code.
ENDMODULE.                 " NFU_CODE_VALUES  INPUT
*---------------------------------------------------------------------*
*       MODULE PAYING_PLANT_VALUES.                                   *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld PAYING_PLANT_VALUES                      *
*---------------------------------------------------------------------*
MODULE paying_plant_values.
  PERFORM f4_paying_plant.
ENDMODULE.                    "PAYING_PLANT_VALUES
*---------------------------------------------------------------------*
*       MODULE NEXT_PLANT_VALUES.                                   *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld NEXT_PLANT_VALUES                      *
*---------------------------------------------------------------------*
MODULE next_plant_values.
  PERFORM f4_next_plant.
ENDMODULE.                    "NEXT_PLANT_VALUES
*&---------------------------------------------------------------------*
*&      Module  REPLACE_UNIT_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE replace_unit_values INPUT.
  PERFORM f4_replace_unit.
ENDMODULE.                 " REPLACE_UNIT_VALUES  INPUT