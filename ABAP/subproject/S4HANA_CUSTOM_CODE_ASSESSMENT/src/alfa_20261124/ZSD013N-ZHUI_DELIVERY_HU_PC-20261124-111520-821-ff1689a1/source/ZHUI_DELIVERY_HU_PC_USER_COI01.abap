*----------------------------------------------------------------------*
***INCLUDE ZHUI_DELIVERY_HU_PC_USER_COI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.
  CASE SY-UCOMM.
    WHEN '&ONT'.
    CLEAR : V_VBELN.
      SELECT SINGLE VEKP~VPOBJKEY
        INTO V_VBELN
        FROM VEKP
        WHERE VEKP~EXIDV = ITAB-ZEXIDV.

      SELECT SINGLE LIKP~VBELN
        INTO V_VBELN
        FROM LIKP
        WHERE LIKP~VBELN = V_VBELN
          AND LIKP~LFART IN ('ZDLF', 'ZELF' ).

      IF SY-SUBRC = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT         = V_VBELN
         IMPORTING
           OUTPUT         = V_VBELN.

        CONCATENATE 'HU has been created in ODO :' V_VBELN INTO V_TEXT SEPARATED BY SPACE.
        MESSAGE V_TEXT TYPE 'E'.
        EXIT.
      ENDIF.

      CLEAR : V_ROUTE.
      IF LIKP-ROUTE NE '' AND ZCUST_ROUTE-ROUTE NE ''.
        MESSAGE 'Fill only one route' TYPE 'E'.
      ENDIF.

      IF LIKP-ROUTE NE ''.
        V_ROUTE = LIKP-ROUTE.
        CLEAR : WA_ROUTE.
        WA_ROUTE-ROUTE = LIKP-ROUTE.
        WA_ROUTE-KUNNR = V_KUNNR.
        INSERT ZCUST_ROUTE FROM WA_ROUTE.
      ELSE.
        V_ROUTE = ZCUST_ROUTE-ROUTE.
      ENDIF.
      PERFORM CREATE_DELIVERY.
    WHEN '&AC1'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT

*&---------------------------------------------------------------------*
*&      Module  HELP_ROUTE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_ROUTE INPUT.
    "-GET DATA ROUTE
    SELECT
      ZCUST_ROUTE~ROUTE
      TVROT~BEZEI
      KNA1~KUNNR
      KNA1~NAME1
      INTO CORRESPONDING FIELDS OF TABLE IT_ROUTE
      FROM ZCUST_ROUTE
      INNER JOIN TVROT ON ZCUST_ROUTE~ROUTE = TVROT~ROUTE
      INNER JOIN KNA1 ON ZCUST_ROUTE~KUNNR = KNA1~KUNNR
      WHERE ZCUST_ROUTE~KUNNR = V_KUNNR.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD    = 'ROUTE'
        DYNPPROG    = SY-CPROG
        DYNPNR      = SY-DYNNR
        DYNPROFIELD = 'P_ROUTE2'
        VALUE_ORG   = 'S'
      TABLES
        VALUE_TAB   = IT_ROUTE.

    IF SY-SUBRC <> 0.
*           Implement suitable error handling here
    ENDIF.

ENDMODULE.                 " HELP_ROUTE  INPUT


*&---------------------------------------------------------------------*
*&      Module  ASSIGN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ASSIGN INPUT.


ENDMODULE.                 " ASSIGN  INPUT