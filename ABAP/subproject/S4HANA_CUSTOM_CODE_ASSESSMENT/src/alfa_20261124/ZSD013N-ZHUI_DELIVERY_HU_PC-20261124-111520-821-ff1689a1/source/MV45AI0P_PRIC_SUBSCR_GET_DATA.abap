*----------------------------------------------------------------------*
***INCLUDE MV45AI0P_PRIC_SUBSCR_GET_DATA .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PRICING_SUBSCREEN_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRICING_SUBSCREEN_GET_DATA INPUT.


  IF PRICING_HEADER IS INITIAL.
    CHECK VBAP-POSAR NE CHARB.
  ENDIF.

ENHANCEMENT-SECTION     PRICING_SUBSCREEN_GET_DATA_10 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'PRICING_SUBSCREEN_GET_DATA'
       IMPORTING
            COMM_HEAD_E      = TKOMK
            COMM_ITEM_E      = TKOMP
            CALCULATION_TYPE = GLOBAL_PRICING_TYPE
       TABLES
            TKOMV            = XKOMV
            TKOMP            = TKOMP
       EXCEPTIONS
            ERROR            = 1
            OTHERS           = 2.
END-ENHANCEMENT-SECTION.


  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " PRICING_SUBSCREEN_GET_DATA  INPUT