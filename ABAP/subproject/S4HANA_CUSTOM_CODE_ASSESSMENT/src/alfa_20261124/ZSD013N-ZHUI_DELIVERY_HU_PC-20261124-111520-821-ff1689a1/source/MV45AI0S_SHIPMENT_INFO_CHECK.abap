*----------------------------------------------------------------------*
*   INCLUDE MV45AI0S_SHIPMENT_INFO_CHECK                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  SHIPMENT_INFO_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHIPMENT_INFO_CHECK INPUT.

  CALL FUNCTION 'SD_SHIPMENT_MOT_TYPE_CHECK'
       EXPORTING
            I_TRMTYP                  = VBKD-TRMTYP
       CHANGING
            C_TRATY                   = VBKD-TRATY
       EXCEPTIONS
            MOT_TYPE_INCONSISTENT
            TRANSP_TYPE_NOT_MAINTAINED.

  CASE SY-SUBRC.
    WHEN 1.
       MESSAGE ID 'VW' TYPE 'E' NUMBER '812' WITH VBKD-TRMTYP.
    WHEN 2.
       IF VBKD-TRMTYP IS INITIAL.
         MESSAGE ID 'VW' TYPE 'E' NUMBER '813' WITH VBKD-TRATY.
       ELSE.
         MESSAGE ID 'VW' TYPE 'E' NUMBER '814'
           WITH VBKD-TRATY VBKD-TRMTYP.
       ENDIF.
  ENDCASE.

ENDMODULE.                             " SHIPMENT_INFO_CHECK  INPUT



















