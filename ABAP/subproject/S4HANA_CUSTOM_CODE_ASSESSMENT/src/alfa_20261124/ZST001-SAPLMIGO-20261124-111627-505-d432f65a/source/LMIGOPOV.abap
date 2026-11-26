*----------------------------------------------------------------------*
***INCLUDE LMIGOPOV .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  POV_FIRSTLINE_ACTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_firstline_action INPUT.
  CALL METHOD oref_firstline->pov_action.
ENDMODULE.                 " POV_FIRSTLINE_ACTION  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_FIRSTLINE_REFDOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pov_firstline_refdoc INPUT.
  CALL METHOD oref_firstline->pov_refdoc.
ENDMODULE.                 " POV_FIRSTLINE_REFDOC  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_GOSPLIT_BWTAR  INPUT
*&---------------------------------------------------------------------*
MODULE pov_gosplit_bwtar INPUT.
  CALL METHOD oref_split_quantity->pov_gosplit_bwtar.
ENDMODULE.                 " POV_GOSPLIT_BWTAR  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_HELP_TKNUM  INPUT
*&---------------------------------------------------------------------*
MODULE pov_help_tknum INPUT.
  CALL FUNCTION 'SD_F4_EXTENDED'
       EXPORTING
            mode   = 'HELP'
       EXCEPTIONS
            OTHERS = 0.
  GET PARAMETER ID 'TNR' FIELD godynpro-transport.
ENDMODULE.                 " POV_HELP_TKNUM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_HELP_DATE  INPUT
*&---------------------------------------------------------------------*
MODULE pov_help_date INPUT.
  CALL METHOD oref_header_general->pov_date.
ENDMODULE.                 " POV_HELP_DATE  INPUT
*&---------------------------------------------------------------------*
*&      Module /sappspro/pov_ebeln  INPUT
*&---------------------------------------------------------------------*
MODULE /sappspro/pov_ebeln INPUT.
ENHANCEMENT-POINT LMIGOPOV_01 SPOTS ES_SAPLMIGO.
ENDMODULE.                 "/sappspro/pov_ebeln  INPUT