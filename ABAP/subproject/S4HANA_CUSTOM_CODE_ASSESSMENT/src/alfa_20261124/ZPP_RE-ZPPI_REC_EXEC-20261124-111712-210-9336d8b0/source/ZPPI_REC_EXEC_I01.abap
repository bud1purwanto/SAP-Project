*&---------------------------------------------------------------------*
*&  Include           ZPPI_REC_EXEC_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7000 INPUT.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'REPORTL'.           "Report Table Log ZERROR_LOG
      SUBMIT ZPPR_REC_EXEC_REPORT
        VIA SELECTION-SCREEN
        AND RETURN.
*      MESSAGE 'Report Table Log' TYPE 'I'.
    WHEN 'BTNGO'.
      IF RB_CRTD = 'X'. " Create Order & Execution
*        DELETE FROM ZERROR_LOG.
*        d_pilih = 1.
        clear: zplant, zresource, zmatnr, zqty, zoperator.
        call screen 7100.
        MESSAGE 'Create Order & Execution' TYPE 'I'.
      ELSEIF RB_CNCL = 'X'. " Cancel Order
*        d_pilih = 2.
*        call screen 2000.
        clear: so_plant, so_matnr, so_aufnr, so_res, so_posdt.
        call screen 7200.
        MESSAGE 'Cancel Order' TYPE 'I'.
      ELSEIF RB_ERROR = 'X'. " Create Order & Execution
*        d_pilih = 1.
        clear: so_plnt2, znik, so_res2, so_psdt2,  so_mtnr2, so_lgort.
*        call screen 2000.
        call screen 7300.
        MESSAGE 'Error Handling' TYPE 'I'.
      ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_RECYCLE01'. DO NOT CHANGE THIS LINE
*&SPWIZARD: MODIFY TABLE
MODULE ZTC_RECYCLE01_MODIFY INPUT.
CLEAR: VLGORT, VLGORT2, MSG_ERROR, IT_VALUE, IT_VALUE2, VGRUND.
REFRESH: IT_VALUE, IT_VALUE2.

     MODIFY IT_RECYCLE01
       FROM WA_RECYCLE01
       INDEX ZTC_RECYCLE01-CURRENT_LINE.

CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      charactname             = 'ZZCODE'
    TABLES
      charactvaluesdescr        = it_value
      return                    = d_retvalue.

CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      charactname             = 'ZZPRODLINE'
    TABLES
      charactvaluesdescr        = it_value2
      return                    = d_retvalue2.

  IF IT_RECYCLE01[] IS NOT INITIAL.

  LOOP AT IT_RECYCLE01 WHERE NOMOR = ZTC_RECYCLE01-CURRENT_LINE.
*     SELECT SINGLE ZTMAP_SLOCREC~ZRRLGORT INTO (VLGORT)
*      FROM  ZTMAP_SLOCREC
*      WHERE ZTMAP_SLOCREC~ZRRLGORT = IT_RECYCLE01-LGORT
*      AND   ZTMAP_SLOCREC~WERKS    = IT_RECYCLE01-WERKS.
*
*      SELECT SINGLE ZTMAP_SLOCREC~LGORT_RCYL INTO (VLGORT2)
*      FROM  ZTMAP_SLOCREC
*      WHERE ZTMAP_SLOCREC~LGORT_RCYL = IT_RECYCLE01-LGORT2
*      AND   ZTMAP_SLOCREC~WERKS    = IT_RECYCLE01-WERKS.

*    IF VLGORT IS INITIAL. "Validasi SLoc GI
*      CONCATENATE 'SLoc GI' IT_RECYCLE01-LGORT 'does not exists' into MSG_ERROR SEPARATED BY SPACE.
*      MESSAGE MSG_ERROR TYPE 'E'.
*      EXIT.
*    ENDIF.
*
*    IF VLGORT2 IS INITIAL. "Validasi SLoc GR
*      CONCATENATE 'SLoc GR' IT_RECYCLE01-LGORT2 'does not exists' into MSG_ERROR SEPARATED BY SPACE.
*      MESSAGE MSG_ERROR TYPE 'E'.
*      EXIT.
*    ENDIF.

    IF IT_RECYCLE01-GRUND IS NOT INITIAL.
        SELECT SINGLE T157D~GRUND INTO (VGRUND)
          FROM T157D
          WHERE T157D~BWART = '101'
          AND   T157D~GRUND = IT_RECYCLE01-GRUND.

        IF VGRUND IS INITIAL. "Validasi Asal
          MESSAGE 'Asal does not exists' TYPE 'E'.
        ENDIF.
    ENDIF.

    IF IT_RECYCLE01-FILM IS NOT INITIAL.
        LOOP AT IT_VALUE WHERE VALUE_CHAR EQ IT_RECYCLE01-FILM.
          MSG_ERROR = 'X'.
        ENDLOOP.

        IF MSG_ERROR IS INITIAL. "Validasi Film
          MESSAGE 'Film does not exists' TYPE 'E'.
        ENDIF.
    ENDIF.

    IF IT_RECYCLE01-LINE IS NOT INITIAL.
        clear msg_error.
        LOOP AT IT_VALUE2 WHERE VALUE_CHAR EQ IT_RECYCLE01-LINE.
          MSG_ERROR = 'X'.
        ENDLOOP.

        IF MSG_ERROR IS INITIAL. "Validasi Line
          MESSAGE 'Line does not exists' TYPE 'E'.
        ENDIF.
     ENDIF.

  ENDLOOP.

  ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_RECYCLE01'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ZTC_RECYCLE01_MARK INPUT.
  DATA: g_ZTC_RECYCLE01_wa2 like line of IT_RECYCLE01.
    if ZTC_RECYCLE01-line_sel_mode = 1
    and WA_RECYCLE01-FLAGS = 'X'.
     loop at IT_RECYCLE01 into g_ZTC_RECYCLE01_wa2
       where FLAGS = 'X'.
       g_ZTC_RECYCLE01_wa2-FLAGS = ''.
       modify IT_RECYCLE01
         from g_ZTC_RECYCLE01_wa2
         transporting FLAGS.
     endloop.
  endif.
  MODIFY IT_RECYCLE01
    FROM WA_RECYCLE01
    INDEX ZTC_RECYCLE01-CURRENT_LINE
    TRANSPORTING FLAGS.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_RECYCLE01'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
MODULE ZTC_RECYCLE01_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'ZTC_RECYCLE01'
                              'IT_RECYCLE01'
                              'FLAGS'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7100 INPUT.

  CASE SY-UCOMM.
    WHEN 'BTNGORD'.
*      DELETE FROM zerror_log.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD ZPLANT. "add New Company
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        RETURN.
      ENDIF.

      IF ZOPERATOR = ' '.
        MESSAGE 'Please Input NIK!!' TYPE 'S'.
      ELSEIF ZOPERATOR <> ' '.
        PERFORM PREPARATION.
      ENDIF.
    WHEN 'EXECUTION'.
      PERFORM EXECUTION.
*      PERFORM DISPLAY.
*      CALL FUNCTION 'DEQUEUE_ALL'.
    WHEN 'REFRESH'.
      CLEAR SY-UCOMM.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD ZPLANT. "add New Company
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        RETURN.
      ENDIF.
      PERFORM PREPARATION.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7100  INPUT

*&---------------------------------------------------------------------*
*&      Module  U_CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_7100 INPUT.
  CASE SY-UCOMM.
  WHEN 'EXIT'.
      LEAVE PROGRAM.
  WHEN 'BACK'.
      CLEAR: it_recycle01, wa_recycle01, zplant, zresource, zmatnr, zqty, zoperator.
      REFRESH: it_recycle01.
      LEAVE TO SCREEN 7000.
  ENDCASE.
ENDMODULE.                 " U_CANCEL  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_CANCEL01'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ZTC_CANCEL01_MARK INPUT.
  DATA: g_ZTC_CANCEL01_wa2 like line of IT_CANCEL01.
    if ZTC_CANCEL01-line_sel_mode = 1
    and WA_CANCEL01-FLAGS = 'X'.
     loop at IT_CANCEL01 into g_ZTC_CANCEL01_wa2
       where FLAGS = 'X'.
       g_ZTC_CANCEL01_wa2-FLAGS = ''.
       modify IT_CANCEL01
         from g_ZTC_CANCEL01_wa2
         transporting FLAGS.
     endloop.
  endif.
  MODIFY IT_CANCEL01
    FROM WA_CANCEL01
    INDEX ZTC_CANCEL01-CURRENT_LINE
    TRANSPORTING FLAGS.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_CANCEL01'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ZTC_CANCEL01_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'ZTC_CANCEL01'
                              'IT_CANCEL01'
                              'FLAGS'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7200 INPUT.


  CASE SY-UCOMM.
    WHEN 'BTN_CGO'.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD SO_PLANT-LOW. "add New Company
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        RETURN.
      ENDIF.
      PERFORM LOAD_CANCEL.
    WHEN 'RTECO'.
      PERFORM REVOKE_TECO.
      CALL FUNCTION 'DEQUEUE_ALL'.
    WHEN 'CPOST'.
      PERFORM author.
      IF SY-SUBRC EQ 0.
        PERFORM CANCEL_POSTING.
      ELSE.
        MESSAGE 'No authorization' TYPE 'E'.
      ENDIF.
    WHEN 'REFRESH'.
      CLEAR SY-UCOMM.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD SO_PLANT-LOW. "add New Company
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        RETURN.
      ENDIF.
      PERFORM LOAD_CANCEL.
*    WHEN 'EXIT'.
*      LEAVE PROGRAM.
*    WHEN 'BACK'.
*      CLEAR: SY-UCOMM, WA_CANCEL01.
*      REFRESH: IT_CANCEL01.
*      LEAVE TO SCREEN 7000.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7200  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_7200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_7200 INPUT.
  CASE SY-UCOMM.
  WHEN 'EXIT'.
      LEAVE PROGRAM.
  WHEN 'BACK'.
      CLEAR: it_cancel01, wa_cancel01, so_plant, so_matnr, so_aufnr, so_res, so_posdt.
      REFRESH: it_cancel01.
      LEAVE TO SCREEN 7000.
  ENDCASE.
ENDMODULE.                 " EXIT_7200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7300 INPUT.

  CASE SY-UCOMM.
    WHEN 'BTNEXEC'.
         AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD SO_PLNT2-LOW. "add New Company
         IF SY-SUBRC NE 0.
           MESSAGE 'No Authorization to process data' TYPE 'E'.
           RETURN.
         ENDIF.
         PERFORM LOAD_ERROR.
    WHEN 'EXECUTION'.
         PERFORM EXECUTION_ERROR.
    WHEN 'TESTRUN'.
         PERFORM TESTRUN_ERROR.
*    WHEN 'TECO'.
*      PERFORM TECO.
*      PERFORM DISPLAY.
      CALL FUNCTION 'DEQUEUE_ALL'.
    WHEN 'REFRESH'.
         CLEAR SY-UCOMM.
         AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD SO_PLNT2-LOW. "add New Company
         IF SY-SUBRC NE 0.
           MESSAGE 'No Authorization to process data' TYPE 'E'.
           RETURN.
         ENDIF.
         PERFORM LOAD_ERROR.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7300  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_7300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_7300 INPUT.
   CASE SY-UCOMM.
  WHEN 'EXIT3'.
      LEAVE PROGRAM.
  WHEN 'BACK3'.
      CLEAR: it_error01, wa_error01, so_plnt2, znik, so_res2, so_psdt2,  so_mtnr2, so_lgort.
      REFRESH: it_error01.
      LEAVE TO SCREEN 7000.
  ENDCASE.
ENDMODULE.                 " EXIT_7300  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_ERRHAND'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ZTC_ERRHAND_MARK INPUT.
  DATA: g_ZTC_ERRHAND_wa2 like line of IT_ERROR01.
    if ZTC_ERRHAND-line_sel_mode = 1
    and WA_ERROR01-FLAGS = 'X'.
     loop at IT_ERROR01 into g_ZTC_ERRHAND_wa2
       where FLAGS = 'X'.
       g_ZTC_ERRHAND_wa2-FLAGS = ''.
       modify IT_ERROR01
         from g_ZTC_ERRHAND_wa2
         transporting FLAGS.
     endloop.
  endif.
  MODIFY IT_ERROR01
    FROM WA_ERROR01
    INDEX ZTC_ERRHAND-CURRENT_LINE
    TRANSPORTING FLAGS.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_ERRHAND'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ZTC_ERRHAND_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'ZTC_ERRHAND'
                              'IT_ERROR01'
                              'FLAGS'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SEARCH_FILM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_FILM INPUT.
  CLEAR d_charval.
  PERFORM f_get_values_request USING 'ZZCODE' CHANGING d_charval.

  IF d_charval IS NOT INITIAL.
    PERFORM f_update_ztc USING 'WA_RECYCLE01-FILM' d_charval.
  ENDIF.
ENDMODULE.                 " SEARCH_FILM  INPUT



*&---------------------------------------------------------------------*
*&      Module  SEARCH_LINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_LINE INPUT.
  CLEAR d_charval.
  PERFORM f_get_values_request USING 'ZZPRODLINE' CHANGING d_charval.

  IF d_charval IS NOT INITIAL.
    PERFORM f_update_ztc USING 'WA_RECYCLE01-LINE' d_charval.
  ENDIF.
ENDMODULE.                 " SEARCH_LINE  INPUT

*&---------------------------------------------------------------------*
*&      Module  SEARCH_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_LGORT INPUT.

PERFORM f_get_lgort CHANGING d_charval.
PERFORM f_update_ztc USING 'WA_RECYCLE01-LGORT2' d_charval.

ENDMODULE.                 " SEARCH_LGORT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ZTC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0524   text
*      -->P_D_CHARVAL  text
*----------------------------------------------------------------------*
FORM F_UPDATE_ZTC  USING    VALUE(P_0524)
                            P_D_CHARVAL.

DATA ld_row LIKE sy-stepl.
  DATA ld_field(20).

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = ld_row
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.

  DATA: BEGIN OF dynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END OF dynpfields.

  CLEAR dynpfields.
  MOVE P_0524 TO dynpfields-fieldname.
  MOVE P_D_CHARVAL TO dynpfields-fieldvalue.
  MOVE ld_row TO dynpfields-stepl.
  APPEND dynpfields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid  "'ZMFIADHFPP'
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 01
      invalid_dynprofield  = 02
      invalid_dynproname   = 03
      invalid_dynpronummer = 04
      invalid_request      = 05
      no_fielddescription  = 06
      undefind_error       = 07.


ENDFORM.                    " F_UPDATE_ZTC

*&---------------------------------------------------------------------*
*&      Module  SEARCH_RESOURCE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_RESOURCE INPUT.

DATA: BEGIN OF IT_DETAIL OCCURS 0,
          WERKS TYPE CRHD-WERKS,
          ARBPL TYPE CRHD-ARBPL,
          KTEXT TYPE CRTX-KTEXT,
        END OF IT_DETAIL.

DATA: dynfields type table of dynpread with header line.

  dynfields-fieldname = 'ZPLANT'.
  append dynfields.

  call function 'DYNP_VALUES_READ'
       exporting
            dyname               = sy-cprog
            dynumb               = sy-dynnr
            translate_to_upper   = 'X'
       tables
            dynpfields           = dynfields
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            stepl_not_found      = 10
            others               = 11.


  read table dynfields with key fieldname = 'ZPLANT'.
  ZPLANT = dynfields-fieldvalue.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL
    FROM ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = ZPLANT.

LOOP AT IT_DETAIL.
  SELECT SINGLE CRTX~KTEXT INTO (IT_DETAIL-KTEXT)
    FROM CRTX
    JOIN CRHD ON CRHD~OBJID = CRTX~OBJID
    WHERE CRTX~OBJTY = 'A'
    AND   CRHD~ARBPL = IT_DETAIL-ARBPL.
    MODIFY IT_DETAIL.
ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM IT_DETAIL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ARBPL'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = sy-repid
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ARBPL'
    TABLES
      VALUE_TAB    = IT_DETAIL.


ENDMODULE.                 " SEARCH_RESOURCE  INPUT

MODULE SEARCH_LGORT_GR INPUT.

DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
          WERKS TYPE CRHD-WERKS,
          ARBPL TYPE CRHD-ARBPL,
          LGORT_RCYL TYPE LGORT_D,
        END OF IT_DETAIL2.


  dynfields-fieldname = 'ZPLANT'.
  append dynfields.

  dynfields-fieldname = 'ZRESOURCE'.
  append dynfields.

  call function 'DYNP_VALUES_READ'
       exporting
            dyname               = sy-cprog
            dynumb               = sy-dynnr
            translate_to_upper   = 'X'
       tables
            dynpfields           = dynfields
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            stepl_not_found      = 10
            others               = 11.


  read table dynfields with key fieldname = 'ZPLANT'.
  ZPLANT = dynfields-fieldvalue.

  read table dynfields with key fieldname = 'ZRESOURCE'.
  ZRESOURCE = dynfields-fieldvalue.

   SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~LGORT_RCYL
          INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
          FROM  ZTMAP_SLOCREC
          WHERE ZTMAP_SLOCREC~WERKS = ZPLANT
          AND   ZTMAP_SLOCREC~ARBPL = ZRESOURCE.

  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'LGORT'
      WINDOW_TITLE = 'Sloc Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = sy-repid
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'LGORT'
    TABLES
      VALUE_TAB    = IT_DETAIL2.


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SEARCH_LGORT_GI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_LGORT_GI INPUT.

PERFORM f_get_lgort_gi CHANGING d_charval.
PERFORM f_update_ztc USING 'WA_RECYCLE01-LGORT' d_charval.

ENDMODULE.                 " SEARCH_LGORT_GI  INPUT

FORM author.

  AUTHORITY-CHECK OBJECT 'ZTRN_CODE'
    ID 'ACTVT' FIELD '85'.

ENDFORM.