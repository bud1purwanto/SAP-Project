*----------------------------------------------------------------------*
***INCLUDE ZPPI_REC_MAT_BY_PROD_O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.
  SET PF-STATUS 'PROD_STAT1000'.
  SET TITLEBAR  'PROD_TITLE1000'.

ENDMODULE.                 " STATUS_1000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

  DATA IT_EXCLUDE TYPE TABLE OF SY-UCOMM.

  REFRESH IT_EXCLUDE.
  IF IT_TIMBANG[] IS INITIAL.
    APPEND 'TESTRUN' TO IT_EXCLUDE.
    APPEND 'EXECUTE' TO IT_EXCLUDE.
  ENDIF.

  SET PF-STATUS 'PROD_STAT1100' EXCLUDING IT_EXCLUDE.
  SET TITLEBAR  'PROD_TITLE1100'.

  PERFORM INITIAL_LGORT.


ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1120 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1120  AS SUBSCREEN.
  PARAMETERS :   S_PDATE TYPE SY-DATUM DEFAULT SY-DATUM.
  SELECTION-SCREEN END OF SCREEN 1120 .
ENDMODULE.                 " SEL_SCR_1120  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1110 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1110 AS SUBSCREEN.
  PARAMETERS    :   S_SDATE TYPE SY-DATUM DEFAULT SY-DATUM OBLIGATORY.
  PARAMETERS    :   S_EDATE TYPE SY-DATUM DEFAULT SY-DATUM OBLIGATORY.
  SELECT-OPTIONS:   S_PLINE  FOR  CAWN-ATWRT NO INTERVALS OBLIGATORY.
  SELECTION-SCREEN END OF SCREEN 1110 .
ENDMODULE.                 " SEL_SCR_1110  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
  SET PF-STATUS 'PROD_STAT1200'.
  SET TITLEBAR  'PROD_TITLE1200'.
ENDMODULE.                 " STATUS_9000  OUTPUT

*----------------------------------------------------------------------*
*  MODULE M_CLEAR_DISPLAY OUTPUT
*----------------------------------------------------------------------*
*       ADDED BY FATHIR ON 12.11.2020
*       ubah nilai qty untuk kebutuhan display setelah dari tabel display - TRDK917760
*----------------------------------------------------------------------*
MODULE M_CLEAR_DISPLAY OUTPUT.
  IF SY-UCOMM = 'YES'.
    PERFORM F_SET_QTY_DISPLAY USING 'X'.
  ENDIF.
ENDMODULE.                    "M_CLEAR_DISPLAY OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_TIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_TIMBANG_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_TIMBANG LINES TC_TIMBANG-LINES.
ENDMODULE.                    "TC_TIMBANG_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LTIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_LTIMBANG_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITLOGTIMBANG LINES TC_LTIMBANG-LINES.
ENDMODULE.                    "TC_LTIMBANG_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_TIPE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_TIPE_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_TIPE LINES TC_TIPE-LINES.
ENDMODULE.                    "TC_TIPE_CHANGE_TC_ATTR OUTPUT



*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_DIST'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_DIST_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_DIST LINES TC_DIST-LINES.
ENDMODULE.                    "TC_DIST_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_DIST'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_DIST_MODIFY INPUT.
  MODIFY ITAB_DIST
    FROM WA_DIST
    INDEX TC_DIST-CURRENT_LINE.

  DATA : COUNTER TYPE I,
         ZTOTALRR TYPE MSEG-MENGE,
         FLAGQTY TYPE I.

  COUNTER = 1.

  PRSNORDTOTAL = 0.

  CLEAR : OK_CODE.

  LOOP AT ITAB_DIST ASSIGNING <FS_DIST>.

    " validasi qty pembebanan terlalu besar
    IF <FS_DIST>-MENGA > WA_TIMBANG-MENGE.
     MESSAGE 'Quantity Pembebanan Tidak Sama dengan Quantity Timbang. Silahkan Periksa Inputan Anda' TYPE 'I'.
     EXIT.
    ENDIF.

    <FS_DIST>-PRSN = ( <FS_DIST>-MENGA / WA_TIMBANG-MENGE ) * 100.

    PRSNORDTOTAL = PRSNORDTOTAL + <FS_DIST>-PRSN.

  ENDLOOP.

ENDMODULE.                    "TC_DIST_MODIFY INPUT

******************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PLINE-LOW.
******************************************************
  PERFORM F_GET_VALUES_REQUEST CHANGING S_PLINE-LOW.

*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUES_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FC_ATWRT   text
*----------------------------------------------------------------------*
FORM F_GET_VALUES_REQUEST CHANGING FC_ATWRT.

  SELECT CAWN~ATWRT CAWNT~ATWTB
      INTO TABLE V_LINE
      FROM CAWN
        INNER JOIN CABN ON CABN~ATINN = CAWN~ATINN
        INNER JOIN CAWNT ON CAWNT~ATINN = CAWN~ATINN AND CAWNT~ATZHL = CAWN~ATZHL
     WHERE CABN~ATNAM = 'ZZPRODLINE'.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ATWRT'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ATWRT'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = V_LINE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "f_get_values_request


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_2000 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 2010  AS SUBSCREEN.
  SELECT-OPTIONS : L_BUDAT  FOR MKPF-BUDAT NO-EXTENSION DEFAULT SY-DATUM,
                   L_MBLNR  FOR MKPF-MBLNR NO-EXTENSION,
                   L_WERKS  FOR MSEG-WERKS NO INTERVALS NO-EXTENSION OBLIGATORY,
                   L_LINE   FOR CAWN-ATWRT NO INTERVALS,
                   L_NIK    FOR MKPF-USNAM NO INTERVALS NO-EXTENSION.
  SELECTION-SCREEN END OF SCREEN 2010 .

ENDMODULE.                 " SEL_SCR_1210  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.
  CLEAR : S_CONN.
  S_CONN = 'TRIASDB05'.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'R_OLAP'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SET PF-STATUS 'PROD_STAT2000'.
  SET TITLEBAR 'PROD_TITLE2000'.

ENDMODULE.                 " STATUS_2000  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_3000 OUTPUT.
  SET PF-STATUS 'PROD_STAT3000'.
  SET TITLEBAR 'PROD_TITLE3000'.
ENDMODULE.                 " STATUS_3000  OUTPUT