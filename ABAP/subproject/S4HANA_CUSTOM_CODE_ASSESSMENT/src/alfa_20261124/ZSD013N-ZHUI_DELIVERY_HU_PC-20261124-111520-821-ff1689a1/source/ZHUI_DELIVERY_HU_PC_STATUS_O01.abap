*----------------------------------------------------------------------*
***INCLUDE ZHUI_DELIVERY_HU_PC_STATUS_O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE STATUS_2000 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  CLEAR : LIKP-WADAT, LIKP-ROUTE, ZCUST_ROUTE-ROUTE.
      LIKP-WADAT = ZEDATU.
      SELECT SINGLE VBAP~ROUTE
        INTO ZCUST_ROUTE-ROUTE
        FROM VBAP
        WHERE VBAP~VBELN = V_VBELN
          AND VBAP~POSNR = V_POSNR.

      IF ZCUST_ROUTE-ROUTE EQ ''.
        SELECT SINGLE ZCUST_ROUTE~ROUTE
          INTO ZCUST_ROUTE-ROUTE
          FROM ZCUST_ROUTE
          WHERE ZCUST_ROUTE~KUNNR = V_KUNNR
            AND ZCUST_ROUTE~PRIORITY = 1.
      ENDIF.

ENDMODULE.                 " STATUS_2000  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_2100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_2100 OUTPUT.
    SELECTION-SCREEN BEGIN OF SCREEN 2100 AS SUBSCREEN.
**      SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-004.
**      PARAMETERS: P_ROUTE  LIKE LIKP-ROUTE,
**                  P_ROUTE2 LIKE LIKP-ROUTE,
**                  P_EDATU  LIKE SY-DATUM.
**      SELECTION-SCREEN END OF BLOCK BLOCK3.
    SELECTION-SCREEN END OF SCREEN 2100 .

ENDMODULE.                 " SEL_SCR_2100  OUTPUT