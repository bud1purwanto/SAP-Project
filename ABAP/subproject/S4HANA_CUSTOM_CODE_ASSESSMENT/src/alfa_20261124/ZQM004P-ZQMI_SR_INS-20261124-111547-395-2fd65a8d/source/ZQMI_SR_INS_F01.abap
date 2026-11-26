*&---------------------------------------------------------------------*
*&  Include           ZQMI_SR_INS_F01
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN.
INITIALIZATION.
  MOVE 'Program Information' TO INFO.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

START-OF-SELECTION.
  IF P_STAT1 IS NOT INITIAL.
    IF P_NIK-LOW IS NOT INITIAL.
      PERFORM GETDATA.
      CALL SCREEN 9100.
    ELSE.
      MESSAGE 'NIK harus diisi!' TYPE 'I'.
    ENDIF.
  ELSEIF P_STAT2 IS NOT INITIAL.
    PERFORM GETLOG.
    PERFORM FIELD_CATALOG.
    PERFORM LAYOUT.
    PERFORM LIST_DETAIL.
  ENDIF.

AT USER-COMMAND.
  CASE SY-UCOMM.
    WHEN 'QUIT'.
*      LEAVE TO TRANSACTION 'ZQM004P'.
      LEAVE TO SCREEN 0.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9100 OUTPUT.
  DATA: LT_FCODE TYPE TABLE OF SY-UCOMM.
  APPEND '%PC' TO LT_FCODE.
  SET PF-STATUS 'PFSTAT'EXCLUDING LT_FCODE.
  SET TITLEBAR '9100'.
  DESCRIBE TABLE T_ORDER LINES V_TOT_REC.


ENDMODULE.                 " STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ZORDER_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ZORDER_USER_COMMAND INPUT.
  IF NOT BATCH IS INITIAL OR SY-UCOMM = 'BACK' OR SY-UCOMM = 'CANC'
                            OR SY-UCOMM = 'LIST' OR SY-UCOMM = 'P+'
                            OR SY-UCOMM = 'P++'  OR SY-UCOMM = 'P-'
                            OR SY-UCOMM = 'P--'  OR SY-UCOMM = 'LIST'
                            OR SY-UCOMM = 'SRCH' OR SY-UCOMM = 'DETL'
                            OR SY-UCOMM = 'QUIT' OR SY-UCOMM = 'PRNT'.

    CASE SY-UCOMM.
      WHEN ' '.
        PERFORM F_OKCODE9100.
      WHEN 'LIST'.
        PSTAT = 'D'.
        PERFORM F_LIST_DISPLAY.
      WHEN 'SRCH'.
        PERFORM F_SEARCH.
      WHEN 'PRNT'.
        PSTAT = 'L'.
        PERFORM F_PRINT.
      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'P+'.
        ADD V_TAB_SIZE TO TCSLIT-TOP_LINE.
        IF TCSLIT-TOP_LINE > V_TOT_REC.
          TCSLIT-TOP_LINE = V_TOT_REC.
        ENDIF.
      WHEN 'P++'.
        TCSLIT-TOP_LINE = V_TOT_REC.
      WHEN 'P-'.
        SUBTRACT V_TAB_SIZE FROM TCSLIT-TOP_LINE.
        IF TCSLIT-TOP_LINE < 1.
          TCSLIT-TOP_LINE = 1.
        ENDIF.
      WHEN 'P--'.
        TCSLIT-TOP_LINE = 1.
      WHEN 'QUIT'.
        LEAVE TO TRANSACTION 'ZQM004P'.
    ENDCASE.
  ENDIF.
  CLEAR SY-UCOMM.
  BATCH = SPACE.


ENDMODULE.                 " ZORDER_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  QUIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE QUIT INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " QUIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_OKCODE9100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_OKCODE9100 .
  DATA : T_CHARG TYPE I,
         JR LIKE MARA-MTART,
         MGSTAT(1),
         EXT(1),
         CTR TYPE I,
         B_LENGHT TYPE I,
         ECHARG LIKE QALS-CHARG,
         TEMP LIKE QALS-CHARG.
  CLEAR: T_ORDER,T_ORDER1,T_BDC,PRUEFLOS, TBATCH,JR,TEMP,B_LENGHT,MGSTAT.
  REFRESH: T_ORDER,T_ORDER1,T_BDC,TBATCH.
*  BREAK-POINT.
  B_LENGHT = STRLEN( BATCH ).
  IF  B_LENGHT GT 10.
    CALL FUNCTION 'CONVERSION_EXIT_BAS36_INPUT'
      EXPORTING
        INPUT          = BATCH
      IMPORTING
        OUTPUT         = BATCH10
      EXCEPTIONS
        INVALID_FORMAT = 1
        OTHERS         = 2.
    IF SY-SUBRC <> 0.
*     Implement suitable error handling here
    ENDIF.
    BATCH = BATCH10+0(10).
  ENDIF.

  SELECT SINGLE PRUEFLOS INTO PRUEFLOS
    FROM QALS
    WHERE QALS~ART = 'Z04'
    AND QALS~CHARG = BATCH.

  IF PRUEFLOS IS INITIAL.
    SELECT MBLNR SMBLN MATNR CHARG WERKS MENGE AUFNR ZEILE SMBLP INTO CORRESPONDING FIELDS OF TABLE T_BDC
      FROM MSEG
      WHERE MSEG~CHARG = BATCH
      AND BWART IN ('101','102').

    IF SY-SUBRC NE 0.
      SELECT MSEG~MBLNR MSEG~SMBLN MSEG~MATNR MSEG~CHARG MSEG~WERKS MSEG~MENGE MSEG~AUFNR MSEG~ZEILE MSEG~SMBLP APPENDING CORRESPONDING FIELDS OF TABLE T_BDC
      FROM MSEG
        JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
      WHERE MSEG~CHARG = BATCH
      AND BWART IN ('531','532')
      AND AUFK~AUART = 'ZMM1'.
    ENDIF.

    IF SY-SUBRC NE 0.
      MESSAGE W000(0K) WITH 'Batch Tidak Tersedia'.
    ELSE.
      LOOP AT T_BDC WHERE SMBLN IS NOT INITIAL.
        DELETE T_BDC WHERE MBLNR EQ T_BDC-SMBLN AND ZEILE EQ T_BDC-SMBLP.
        DELETE T_BDC WHERE MBLNR EQ T_BDC-MBLNR AND ZEILE EQ T_BDC-ZEILE.
      ENDLOOP.

      PERFORM UPLOAD.
      IF SBDC EQ 'E'.
        MESSAGE E016(PN) WITH 'Create Inspection Lot failed'.
      ELSE.
        LOOP AT T_BDC.
          CLEAR : MGSTAT,TEMP,EXT,CTR, JR.
          TEMP = T_BDC-CHARG.         "HISAR
*          WHILE JR NE 'X' ."AND MGSTAT NE 'X'  AND CTR NE 5.
*            CTR = CTR + 1.
          REFRESH T_VALID.
          SELECT MBLNR SMBLN AUFNR ZEILE SMBLP MATNR CHARG WERKS INTO CORRESPONDING FIELDS OF TABLE T_VALID
            FROM MSEG
            WHERE MSEG~CHARG = TEMP
            AND BWART IN ('101','102').

          IF SY-SUBRC NE 0.
            SELECT MSEG~MBLNR MSEG~SMBLN MSEG~AUFNR MSEG~ZEILE MSEG~SMBLP MSEG~MATNR MSEG~CHARG MSEG~WERKS INTO CORRESPONDING FIELDS OF TABLE T_VALID
             FROM MSEG
              JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
             WHERE MSEG~CHARG = TEMP
             AND BWART IN ('531','532')
             AND AUFK~AUART = 'ZMM1'.
          ENDIF.

          LOOP AT T_VALID WHERE SMBLN IS NOT INITIAL.
            DELETE T_VALID WHERE MBLNR EQ T_VALID-SMBLN AND ZEILE EQ T_VALID-SMBLP.
            DELETE T_VALID WHERE MBLNR EQ T_VALID-MBLNR AND ZEILE EQ T_VALID-ZEILE.
          ENDLOOP.
          READ TABLE T_VALID INDEX 1.
          T_ORDER1-MATNR = T_VALID-MATNR.
          T_ORDER1-CHARGA = T_VALID-CHARG.
          T_ORDER1-WERKS = T_VALID-WERKS.
          IF T_VALID-AUFNR IS INITIAL.
            JR = 'X'.
            EXIT.
          ENDIF.
          SELECT SINGLE AUFNR INTO T_BDC-AUFNR2
            FROM AFPO
            WHERE AFPO~MILL_OC_AUFNR_U = T_VALID-AUFNR.
*          SELECT SINGLE MATNR CHARG WERKS INTO (T_ORDER1-MATNR,T_ORDER1-CHARGA,T_ORDER1-WERKS)
*            FROM MSEG
*          WHERE MSEG~CHARG = T_BDC-CHARG.
          SELECT SINGLE PRUEFLOS INTO T_ORDER1-PLOS2
            FROM QALS
            WHERE QALS~CHARG = T_BDC-CHARG
            AND QALS~ART = 'Z04'.
          PERFORM INPUT USING T_BDC-AUFNR T_BDC-AUFNR2
             CHANGING T_ORDER1-INPUT1 T_ORDER1-INPUT2 T_ORDER1-INPUT3 T_ORDER1-INPUT4
               T_ORDER1-AUFNR T_ORDER1-MATNRJR JR MGSTAT EXT.
          T_ORDER1-MATNRIN = T_ORDER1-MATNRJR.
          CLEAR: ECHARG.
          T_ORDER1-CHARG = T_ORDER1-INPUT1.
          WHILE EXT NE 'X'.
            PERFORM GETBATCHJR USING T_ORDER1-CHARG CHANGING T_ORDER1-CHARG T_ORDER1-MATNRJR EXT.
            ECHARG = T_ORDER1-CHARG.
          ENDWHILE.
*            T_ORDER1-CHARG = T_ORDER1-INPUT1.
*            TEMP = T_ORDER1-CHARG.
*            IF CTR EQ 5.
*              JR = 'X'.
*            ENDIF.
*          ENDWHILE.
          APPEND T_ORDER1.
          MODIFY T_BDC.
        ENDLOOP.
        PERFORM F_PRINT1.
      ENDIF.
    ENDIF.
    PERFORM GETDATA.
  ELSE.
    PERFORM GETDATA.
    MESSAGE W000(0K) WITH 'Batch sudah di scan, inspection lot sudah ada'.
  ENDIF.
ENDFORM.                    " F_OKCODE9100
*&---------------------------------------------------------------------*
*&      Form  F_LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DISPLAY .
  DATA: LT_FCODE TYPE TABLE OF SY-UCOMM.

  APPEND 'LIST' TO LT_FCODE.
  APPEND 'DETL' TO LT_FCODE.
  APPEND 'SRCH' TO LT_FCODE.
  APPEND 'PRNT' TO LT_FCODE.
  IF PSTAT EQ 'A'.
    APPEND 'QUIT' TO LT_FCODE.
  ENDIF.
  SET PF-STATUS 'PFSTAT' EXCLUDING LT_FCODE.
  LEAVE TO LIST-PROCESSING.

  IF PSTAT EQ 'D'.
    LOOP AT T_ORDER ."WHERE char2 NE space."flag EQ 'X'." phynr NE space.
      PERFORM SET_COLOR.
      WRITE: /01 SY-VLINE,
                (18) T_ORDER-MATNR NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER-CHARG NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER-PLOS2 NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER-CHARGA NO-GAP, '  ',SY-VLINE.

      WRITE: /01(84) SY-ULINE.
    ENDLOOP.
  ENDIF.
  IF PSTAT EQ 'L'.
    LOOP AT T_ORDER2 .
      PERFORM SET_COLOR.
      WRITE: /01 SY-VLINE,
                (18) T_ORDER2-MATNR NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-PRUEFLOS NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-CHARGAS NO-GAP, '  ',SY-VLINE,
                (30) T_ORDER2-ROLLSR NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-ERDAT NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-ERZET NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-USNAM NO-GAP, '  ',SY-VLINE,
                (15) T_ORDER2-NONIK NO-GAP, '  ',SY-VLINE.
      WRITE: /01(179) SY-ULINE.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  SET_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_COLOR .
  IF C IS INITIAL.
    FORMAT COLOR COL_NORMAL INTENSIFIED.
    C = 'x'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    CLEAR C.
  ENDIF.
ENDFORM.                    " SET_COLOR

TOP-OF-PAGE.

*  WRITE: /01 'Slit Roll Inspection'.
  IF PSTAT EQ 'D'.
    WRITE: /01(84) SY-ULINE.
    WRITE: /01 SY-VLINE,
              (18) 'Material' COLOR COL_HEADING NO-GAP, '  ',
               SY-VLINE,
              (15) 'JR Batch' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'Inspection Lot ' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) ' Batch  ' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE.
    WRITE: /01(84) SY-ULINE.
  ENDIF.
  IF PSTAT EQ 'L'.
    WRITE: /01(179) SY-ULINE.
    WRITE: /01 SY-VLINE,
              (18) 'Material' COLOR COL_HEADING NO-GAP, '  ',
               SY-VLINE,
              (15) 'Inspection Lot' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'Asigned Batch ' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (30) ' Slit Roll Number  ' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'Date Print' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'Time Print' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'User Print' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE,
              (15) 'NIK' COLOR COL_HEADING NO-GAP, '  ',
              SY-VLINE.
    WRITE: /01(179) SY-ULINE.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD .
  DATA : IT_QALS LIKE QALS,
         L_RMQED LIKE RMQED,
         E_KZSKIPLOT LIKE QALS-INSMK,
         E_PRUEFLOS LIKE QALS-PRUEFLOS,
         E_QALS LIKE QALS,
         SUBRC LIKE SY-SUBRC.

  LOOP AT T_BDC.
    CLEAR :  IT_BDCDATA[], IT_BDCMSGCOLL[], T_BDC-TMENGE.
    REFRESH : IT_BDCMSGCOLL[], IT_BDCDATA[].
    T_BDC-TMENGE = T_BDC-MENGE.
    CONDENSE T_BDC-TMENGE.
    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'QALS-HERKUNFT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'QALS-MATNR'
                                  T_BDC-MATNR.
    PERFORM BDC_FIELD       USING 'QALS-WERK'
                                  T_BDC-WERKS.
    PERFORM BDC_FIELD       USING 'QALS-HERKUNFT'
                                  '05'.

    PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  '04/03'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=NSEL'.

    PERFORM BDC_DYNPRO      USING 'SAPLSDH4' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=GOON'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'G_SELFLD_TAB-LOW(01)'.
    PERFORM BDC_FIELD       USING 'DDSHF4CTRL-MAXRECORDS'
                                  ' 500'.
    PERFORM BDC_FIELD       USING 'G_SELFLD_TAB-LOW(01)'
                                  'z04'.

    PERFORM BDC_DYNPRO      USING 'SAPMSSY0' '0120'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  '04/07'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.

    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=VORG'.
    PERFORM BDC_FIELD       USING 'QALS-CHARG'
                                  T_BDC-CHARG."'0000000842'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'QALS-LOSMENGE'.
    IF T_BDC-TMENGE LE 10.
      PERFORM BDC_FIELD       USING 'QALS-LOSMENGE'
                                    '10'.
    ELSE.
      PERFORM BDC_FIELD       USING 'QALS-LOSMENGE'
                                    T_BDC-TMENGE."'10'.
    ENDIF.
    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PS'.

    PERFORM BDC_DYNPRO      USING 'SAPLCPSE' '2110'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLKO-PLNAL(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=MARK'.

    PERFORM BDC_DYNPRO      USING 'SAPLCPSE' '2110'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RC27M-MATNR'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PICK'.

    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=STIP'.
    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=DYNA'.
    PERFORM BDC_DYNPRO      USING 'SAPLQPL1' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.
    CALL TRANSACTION 'QA01' USING IT_BDCDATA
                               MODE 'E'
                               UPDATE 'S'
                               MESSAGES INTO IT_BDCMSGCOLL.

    LOOP AT IT_BDCMSGCOLL.
      IF IT_BDCMSGCOLL-MSGTYP EQ 'E'.
        SBDC = 'E'.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " UPLOAD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0294   text
*      -->P_0295   text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0299   text
*      -->P_0300   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SEARCH .
  DATA: L_ANSWER, L_VALUE1 LIKE SPOP-VARVALUE1, L_INDEX LIKE SY-TABIX,
          L_CHAR1(10).

  CALL FUNCTION 'POPUP_TO_GET_ONE_VALUE'
    EXPORTING
      TEXTLINE1   = 'Enter Batch no:'
      TITEL       = 'Seacrh'
      VALUELENGTH = 10
    IMPORTING
      ANSWER      = L_ANSWER
      VALUE1      = L_VALUE1.
  CHECK L_ANSWER = 'J'.
  L_CHAR1 = L_VALUE1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = L_CHAR1
    IMPORTING
      OUTPUT = L_CHAR1.

  LOOP AT T_ORDER.
    IF T_ORDER-CHARGA = L_CHAR1.
      L_INDEX = SY-TABIX.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF NOT L_INDEX IS INITIAL.
    TCSLIT-TOP_LINE = L_INDEX.
  ENDIF.

ENDFORM.                    " F_SEARCH



*&SPWIZARD: OUTPUT MODULE FOR TC 'TCSLIT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TCSLIT_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE T_ORDER LINES TCSLIT-LINES.
ENDMODULE.                    "TCSLIT_CHANGE_TC_ATTR OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ZORDER_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ZORDER_GET_LINES OUTPUT.
  G_ZORDER_LINES = SY-LOOPC.
  V_TAB_SIZE     = SY-LOOPC.
ENDMODULE.                 " ZORDER_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PRINT .
  CLEAR: T_ORDER2.
  REFRESH: T_ORDER2.

  LOOP AT T_ORDER.
*    TRY.
    UPDATE ZQM_LOG_GS SET ZQM_LOG_GS~ERDAT = SY-DATUM ZQM_LOG_GS~ERZET = SY-UZEIT ZQM_LOG_GS~USNAM = SY-UNAME
    WHERE
     ZQM_LOG_GS~PRUEFLOS = T_ORDER-PLOS2.
    IF SY-SUBRC EQ 0.
      SELECT * INTO CORRESPONDING FIELDS OF WA
       FROM ZQM_LOG_GS
       WHERE ZQM_LOG_GS~PRUEFLOS = T_ORDER-PLOS2.
        APPEND WA TO T_ORDER2 .
      ENDSELECT.
    ENDIF.
  ENDLOOP.

  CLEAR T_ORDER.
  REFRESH T_ORDER.
*  PERFORM F_LIST_DISPLAY.
  PERFORM F_LIST_PRINT.
ENDFORM.                    " F_PRINT


*&---------------------------------------------------------------------*
*&      Form  F_PRINT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PRINT1.
  DATA : CT TYPE C LENGTH 10.
  DATA : BATCH LIKE ZQM_LOG_GS-CHARGAS,
         MATNR LIKE ZQM_LOG_GS-MATNR.
  CLEAR: TBATCH, T_LOG,BATCH,MATNR.
  REFRESH: TBATCH, T_LOG.

  LOOP AT T_ORDER1.
    CLEAR T_LOG.
    CALL FUNCTION 'VB_INIT'
      EXPORTING
        INIT_RESET = 'X'.
    CALL FUNCTION 'VB_BATCH_GET_DETAIL' "
            EXPORTING
              MATNR = T_ORDER1-MATNR                   " mara-matnr
              CHARG = T_ORDER1-CHARGA                     " mch1-charg
             WERKS = T_ORDER1-WERKS                    " t001w-werks
             GET_CLASSIFICATION = 'X'       " am07m-xselk
           TABLES
             CHAR_OF_BATCH = TBATCH
             EXCEPTIONS
              NO_MATERIAL              = 1
              NO_BATCH                 = 2
              NO_PLANT                 = 3
              MATERIAL_NOT_FOUND       = 4
              PLANT_NOT_FOUND          = 5
              NO_AUTHORITY             = 6
              BATCH_NOT_EXIST          = 7
              LOCK_ON_BATCH            = 8
              OTHERS                   = 9.
    LOOP AT TBATCH WHERE ATNAM ='ZZNOMORROLL'.
      T_LOG-ROLLSR = TBATCH-ATWTB.
    ENDLOOP.
    LOOP AT TBATCH WHERE ATNAM ='ZZCODE'.
      T_LOG-ZZTYPE = TBATCH-ATWTB.
    ENDLOOP.
    LOOP AT TBATCH WHERE ATNAM ='ZZTREATMENT'.
      T_LOG-TREATMENT = TBATCH-ATWTB.
    ENDLOOP.
    CLEAR TBATCH. REFRESH TBATCH.
    CALL FUNCTION 'VB_INIT'
      EXPORTING
        INIT_RESET = 'X'.
    CALL FUNCTION 'VB_BATCH_GET_DETAIL' "
            EXPORTING
              MATNR = T_ORDER1-MATNRJR                   " mara-matnr
              CHARG = T_ORDER1-CHARG                     " mch1-charg
             WERKS = T_ORDER1-WERKS                    " t001w-werks
             GET_CLASSIFICATION = 'X'       " am07m-xselk
           TABLES
             CHAR_OF_BATCH = TBATCH
             EXCEPTIONS
              NO_MATERIAL              = 1
              NO_BATCH                 = 2
              NO_PLANT                 = 3
              MATERIAL_NOT_FOUND       = 4
              PLANT_NOT_FOUND          = 5
              NO_AUTHORITY             = 6
              BATCH_NOT_EXIST          = 7
              LOCK_ON_BATCH            = 8
              OTHERS                   = 9.
    LOOP AT TBATCH WHERE ATNAM ='ZZNOMORROLL'.
      T_LOG-ROLLJR = TBATCH-ATWTB.
      CONDENSE TBATCH-ATWTB.
      SPLIT TBATCH-ATWTB AT SPACE INTO : CT T_LOG-JRCODE T_LOG-JRMOY T_LOG-JRSEQ CT.
    ENDLOOP.
    LOOP AT TBATCH WHERE ATNAM ='ZZPRODLINE'.
      SELECT SINGLE CAWN~ATWRT INTO T_LOG-PLINE
        FROM CAWN
        JOIN CAWNT ON  CAWNT~ATINN = CAWN~ATINN
        AND CAWNT~ATZHL = CAWN~ATZHL
        WHERE CAWNT~ATWTB = TBATCH-ATWTB.
    ENDLOOP.
    PERFORM GETREFNO CHANGING T_LOG-PRUEFLOSREF T_LOG-NOSEQ T_LOG-NOREF T_LOG-PREF.
    T_LOG-MATNR = T_ORDER1-MATNR.
    T_LOG-MATNRJR = T_ORDER1-MATNRJR.
    T_LOG-MATNRIN = T_ORDER1-MATNRIN.
    T_LOG-PRUEFLOS = T_ORDER1-PLOS2.
    T_LOG-CHARGJR = T_ORDER1-CHARG.
    T_LOG-CHARGAS = T_ORDER1-CHARGA.
    T_LOG-INPUT1 = T_ORDER1-INPUT1.
    T_LOG-INPUT2 = T_ORDER1-INPUT2.
    T_LOG-INPUT3 = T_ORDER1-INPUT3.
    T_LOG-INPUT4 = T_ORDER1-INPUT4.
    T_LOG-WERKS = T_ORDER1-WERKS.
    T_LOG-NONIK = P_NIK-LOW.
    DELETE FROM ZQM_LOG_GS WHERE MATNR EQ T_LOG-MATNR AND CHARGAS EQ T_LOG-CHARGAS.
    APPEND T_LOG.
  ENDLOOP.
  INSERT INTO ZQM_LOG_GS VALUES T_LOG.

ENDFORM.                    "F_PRINT1

*&---------------------------------------------------------------------*
*&      Form  GETLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETLOG .
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE T_QMLOG FROM ZQM_LOG_GS
  WHERE
  ERDAT IN P_ERDAT AND
  WERKS IN S_WERK1 AND
  NONIK IN P_NIK AND
  CHARGAS IN S_CHAR1 AND
  PLINE IN S_PLINE AND
  JRCODE IN S_CODE AND
  JRMOY IN S_MONYE AND
  JRSEQ IN S_SEQUE AND
  NOSEQ NE '' AND
  NOREF NE '' AND
  PREF NE ''.

*--- get rolno
  DATA: BEGIN OF IT_BATCH OCCURS 0,
        CHARG LIKE MCH1-CHARG,
        END OF IT_BATCH.

  DATA: BEGIN OF IT_ROLNO OCCURS 0,
        CHARG LIKE MCH1-CHARG,
        ROLNO TYPE C LENGTH 30,
    END OF IT_ROLNO.

  DATA: V_ATINN LIKE AUSP-ATINN.
  DATA: V_ZSPLICE1 LIKE AUSP-ATINN,
        V_ZSPLICE2 LIKE AUSP-ATINN,
        V_ZSPLICE3 LIKE AUSP-ATINN,
        V_NSPLICE TYPE P.  "LIKE AUSP-ATFLV.

  LOOP AT T_QMLOG WHERE INPUT1 NE ''.
    IT_BATCH-CHARG = T_QMLOG-INPUT1.
    APPEND IT_BATCH.
  ENDLOOP.

  LOOP AT T_QMLOG WHERE INPUT2 NE ''.
    IT_BATCH-CHARG = T_QMLOG-INPUT2.
    APPEND IT_BATCH.
  ENDLOOP.

  LOOP AT T_QMLOG WHERE INPUT3 NE ''.
    IT_BATCH-CHARG = T_QMLOG-INPUT3.
    APPEND IT_BATCH.
  ENDLOOP.

*  LOOP AT T_QMLOG WHERE INPUT4 NE ''.
*    IT_BATCH-CHARG = T_QMLOG-INPUT4.
*    APPEND IT_BATCH.
*  ENDLOOP.

  SORT IT_BATCH BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_BATCH COMPARING CHARG.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.

  SELECT MCH1~CHARG AUSP~ATWRT INTO TABLE IT_ROLNO
    FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
    FOR ALL ENTRIES IN IT_BATCH
    WHERE MCH1~CHARG = IT_BATCH-CHARG AND AUSP~ATINN = V_ATINN.

*  LOOP AT IT_ROLNO.
  LOOP AT IT_ROLNO.
    LOOP AT T_QMLOG WHERE INPUT1 EQ IT_ROLNO-CHARG AND MATNRIN NE ''.
      T_QMLOG-ROLLN1 = IT_ROLNO-ROLNO.
      MODIFY T_QMLOG TRANSPORTING ROLLN1 WHERE INPUT1 = IT_ROLNO-CHARG.
    ENDLOOP.

    LOOP AT T_QMLOG WHERE INPUT2 EQ IT_ROLNO-CHARG AND MATNRIN NE ''.
      T_QMLOG-ROLLN2 = IT_ROLNO-ROLNO.
      MODIFY T_QMLOG TRANSPORTING ROLLN2 WHERE INPUT2 = IT_ROLNO-CHARG.
    ENDLOOP.

    LOOP AT T_QMLOG WHERE INPUT3 EQ IT_ROLNO-CHARG AND MATNRIN NE ''.
      T_QMLOG-ROLLN3 = IT_ROLNO-ROLNO.
      MODIFY T_QMLOG TRANSPORTING ROLLN3 WHERE INPUT3 = IT_ROLNO-CHARG.
    ENDLOOP.
  ENDLOOP.

*--- get splice

  SELECT SINGLE ATINN INTO V_ZSPLICE1 FROM CABN WHERE ATNAM = 'ZZSPLICE-1'.
  SELECT SINGLE ATINN INTO V_ZSPLICE2 FROM CABN WHERE ATNAM = 'ZZSPLICE-2'.
  SELECT SINGLE ATINN INTO V_ZSPLICE3 FROM CABN WHERE ATNAM = 'ZZSPLICE-3'.


  LOOP AT T_QMLOG.
    CLEAR: T_QMLOG-SLICE1, T_QMLOG-SLICE2, T_QMLOG-SLICE3, V_NSPLICE.

    SELECT SINGLE AUSP~ATFLV INTO V_NSPLICE
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = T_QMLOG-CHARGAS AND AUSP~ATINN = V_ZSPLICE1.

    IF V_NSPLICE > 0 AND T_QMLOG-MATNR NE ''.
      WRITE V_NSPLICE TO T_QMLOG-SLICE1 DECIMALS 0.
      CONDENSE T_QMLOG-SLICE1.
    ENDIF.

    CLEAR V_NSPLICE.
    SELECT SINGLE AUSP~ATFLV INTO V_NSPLICE
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = T_QMLOG-CHARGAS AND AUSP~ATINN = V_ZSPLICE2.

    IF V_NSPLICE > 0 AND T_QMLOG-MATNR NE ''.
      WRITE V_NSPLICE TO T_QMLOG-SLICE2 DECIMALS 0.
      CONDENSE T_QMLOG-SLICE2.
    ENDIF.

    CLEAR V_NSPLICE.
    SELECT SINGLE AUSP~ATFLV INTO V_NSPLICE
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = T_QMLOG-CHARGAS AND AUSP~ATINN = V_ZSPLICE3.

    IF V_NSPLICE > 0 AND T_QMLOG-MATNR NE ''.
      WRITE V_NSPLICE TO T_QMLOG-SLICE3 DECIMALS 0.
      CONDENSE T_QMLOG-SLICE3.
    ENDIF.

    MODIFY T_QMLOG.
  ENDLOOP.

  SORT T_QMLOG BY ERDAT ERZET DESCENDING.
ENDFORM.                    " GETLOG
*&---------------------------------------------------------------------*
*&      Form  GETDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETDATA .
  SELECT MATNR PRUEFLOS CHARGJR CHARGAS ROLLJR INPUT1 INPUT2 INPUT3 INPUT4 ERDAT ERZET USNAM NONIK
    INTO (T_ORDER-MATNR,T_ORDER-PLOS2,T_ORDER-CHARG,T_ORDER-CHARGA, T_ORDER-ROLLJR,
    T_ORDER-INPUT1,T_ORDER-INPUT2,T_ORDER-INPUT3,T_ORDER-INPUT4,T_ORDER-ERDAT,T_ORDER-ERZET,T_ORDER-USNAM,T_ORDER-NONIK)
    FROM ZQM_LOG_GS
    WHERE ZQM_LOG_GS~ERDAT EQ 0
    AND ZQM_LOG_GS~NONIK = P_NIK-LOW.
    APPEND T_ORDER.
  ENDSELECT.
ENDFORM.                    " GETDATA
*&---------------------------------------------------------------------*
*&      Form  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BDC_AUFNR  text
*      <--P_T_ORDER_INPUT1  text
*      <--P_T_ORDER_INPUT2  text
*      <--P_T_ORDER_INPUT3  text
*      <--P_T_ORDER_INPUT4  text
*----------------------------------------------------------------------*
FORM INPUT  USING    P_AUFNR P_AUFNR2
            CHANGING P_INPUT1
                     P_INPUT2
                     P_INPUT3
                     P_INPUT4
                     C_AUFNR
                     MATNR
                     P_JR
                     P_MGS
                     T_EXT.
  DATA : COUNTER TYPE I,
         MATKL LIKE MARA-MATKL,
         TMTART LIKE MARA-MTART,
         T_MGS(1),
        ALL_BATCH TYPE C LENGTH 100.
  DATA : IT_MSEG LIKE STANDARD TABLE OF MSEG WITH HEADER LINE.
  CLEAR : IT_MSEG,ALL_BATCH,MATKL,TMTART,T_MGS, COUNTER,T_EXT.
  REFRESH: IT_MSEG.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
          FROM MSEG
          WHERE MSEG~AUFNR = T_BDC-AUFNR
          AND MSEG~BWART IN ('261','262','901','902','903','904').
  IF SY-SUBRC NE 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
          FROM MSEG
          WHERE MSEG~AUFNR = T_BDC-AUFNR2
          AND MSEG~BWART IN ('261','262','901','902','903','904').
  ENDIF.
  LOOP AT IT_MSEG.
    IF IT_MSEG-SMBLN IS NOT INITIAL.
      DELETE IT_MSEG WHERE MBLNR EQ IT_MSEG-SMBLN.
      DELETE IT_MSEG WHERE SMBLN EQ IT_MSEG-SMBLN.
    ENDIF.
  ENDLOOP.
  COUNTER = LINES( IT_MSEG ).
  IF COUNTER IS INITIAL.
    P_JR = 'X'.
  ENDIF.
  COUNTER = 0.
  LOOP AT IT_MSEG.
    CLEAR: TMTART,T_MGS.
    COUNTER = COUNTER + 1.
    SELECT SINGLE MTART MATKL INTO (TMTART, MATKL)
        FROM MARA
        WHERE MARA~MATNR = IT_MSEG-MATNR.
    IF MATKL GE 400001 AND MATKL LE 400100.
      T_MGS = 'X'.
    ENDIF.
    IF TMTART EQ 'ZSFG' AND T_MGS EQ 'X'.
      T_EXT = 'X'.
    ENDIF.
    IF COUNTER EQ 1.
      C_AUFNR = IT_MSEG-AUFNR.
      MATNR = IT_MSEG-MATNR.
    ENDIF.
    CONCATENATE ALL_BATCH IT_MSEG-CHARG INTO ALL_BATCH SEPARATED BY SPACE.
    IF COUNTER EQ 4.
      EXIT.
    ENDIF.
  ENDLOOP.
  CONDENSE ALL_BATCH.
  SPLIT ALL_BATCH AT SPACE INTO : P_INPUT1 P_INPUT2 P_INPUT3 P_INPUT4.
ENDFORM.                    " INPUT
*&---------------------------------------------------------------------*
*&      Form  GETREFNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_LOG_PRUEFLOSREF  text
*      <--P_T_LOG_NOSEQ  text
*      <--P_T_LOG_NOREF  text
*----------------------------------------------------------------------*
FORM GETREFNO  CHANGING P_PRUEFLOSREF
                        P_NOSEQ
                        P_NOREF
                        P_PREF.
  DATA : IDMAX TYPE C LENGTH 12,
         REF1 TYPE C VALUE 'I',
         REF2 TYPE C,
         REF4 TYPE C LENGTH 9,
         NOREF TYPE C LENGTH 2.
  DATA : IT_NOREF LIKE STANDARD TABLE OF ZQM_LOG_GS WITH HEADER LINE.
  CLEAR : REF2,REF4,IT_NOREF,NOREF,IDMAX.
  REFRESH: IT_NOREF.
  SELECT MAX( NOSEQ ) INTO IDMAX
    FROM ZQM_LOG_GS.
  SELECT SINGLE * INTO IT_NOREF
    FROM ZQM_LOG_GS
    WHERE ZQM_LOG_GS~NOSEQ = IDMAX.
  IF SY-SUBRC NE 0.
    REF2 = 'A'.
    REF4 = '000000001'.
    CONCATENATE REF1 REF2 REF4 INTO P_PRUEFLOSREF.
    P_NOREF = 1.
    P_NOSEQ = 1.
    P_PREF = REF4.
  ELSE.
    REF4 = IT_NOREF-PREF.
    P_NOREF = IT_NOREF-NOREF.
    IF REF4 = 999999999.
      P_NOREF = IT_NOREF-NOREF + 1.
      REF4 = 000000000.
    ENDIF.
    CASE P_NOREF.
      WHEN '01'.
        REF2 = 'A'.
      WHEN '02'.
        REF2 = 'B'.
      WHEN '03'.
        REF2 = 'C'.
      WHEN '04'.
        REF2 = 'D'.
      WHEN '05'.
        REF2 = 'E'.
      WHEN '06'.
        REF2 = 'F'.
      WHEN '07'.
        REF2 = 'G'.
      WHEN '08'.
        REF2 = 'H'.
      WHEN '09'.
        REF2 = 'I'.
      WHEN '10'.
        REF2 = 'J'.
      WHEN '11'.
        REF2 = 'K'.
      WHEN '12'.
        REF2 = 'L'.
      WHEN '13'.
        REF2 = 'M'.
      WHEN '14'.
        REF2 = 'N'.
      WHEN '15'.
        REF2 = 'O'.
      WHEN '16'.
        REF2 = 'P'.
      WHEN '17'.
        REF2 = 'Q'.
      WHEN '18'.
        REF2 = 'R'.
      WHEN '19'.
        REF2 = 'S'.
      WHEN '20'.
        REF2 = 'T'.
      WHEN '21'.
        REF2 = 'U'.
      WHEN '22'.
        REF2 = 'V'.
      WHEN '23'.
        REF2 = 'W'.
      WHEN '24'.
        REF2 = 'X'.
      WHEN '25'.
        REF2 = 'Y'.
      WHEN '26'.
        REF2 = 'Z'.
    ENDCASE.
    P_PREF = REF4 + 1.
    P_NOSEQ = IDMAX + 1.
    CONCATENATE REF1 REF2 P_PREF INTO P_PRUEFLOSREF.
  ENDIF.
ENDFORM.                    " GETREFNO
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'T_QMLOG' :
   'MATNR'  '' ''  '' '' 'Material'      '' '' '' '',
   'ZZTYPE' '' ''  '' ''  'Type/Thickness' '' '' '' '',
   'TREATMENT' '' ''  '' ''  'Treatment' ''  '' '' '' ,
    'PRUEFLOS' '' ''  '' ''  'Inspection Lot' ''  '' '' ' ' ,
    'CHARGAS'  '' ''  '' ''  'Asigned Batch ' ''  '' '' ' ' ,
    'ROLLSR'  '' ''  '' ''  'Slit Roll Number' ''  ' ' '' ' ' ,
    'INPUT1' '' ''  '' ''  'Input-1' ''  ' ' '' ' ' ,
    'INPUT2' '' ''  '' ''  'Input-2' ''  ' ' '' ' ' ,
    'INPUT3' '' ''  '' ''  'Input-3' ''  ' ' '' ' ' ,
    'ROLLN1' '' ''  '' ''  'No.Roll Input 1' ''  ' ' '' ' ' ,
    'ROLLN2' '' ''  '' ''  'No.Roll Input 2' ''  ' ' '' ' ' ,
    'ROLLN3' '' ''  '' ''  'No.Roll Input 3' ''  ' ' '' ' ' ,
    'SLICE1' '' ''  '' ''  'Splice-1' ''  ' ' '' ' ' ,
    'SLICE2' '' ''  '' ''  'Splice-2' ''  ' ' '' ' ' ,
    'SLICE3' '' ''  '' ''  'Splice-3' ''  ' ' '' ' ' ,
    'ERDAT'  '' ''  '' ''  'Date Print' ''  ' ' '' ' ' ,
    'ERZET'  '' ''  '' ''  'Time Print' ''  ' ' '' ' ' ,
    'NONIK'  '' ''  '' ''  'User Print' ''  ' ' '' ' ' .

ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DETAIL .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = T_FIELDCAT[]
      IT_EVENTS               = T_EVENTS[]
      IT_EVENT_EXIT           = T_EVENT_EXIT[]
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IS_VARIANT              = WA_VARIANTE
      IS_PRINT                = T_PRINT
      IT_SORT                 = T_SORT[]
      IT_EXCLUDING            = T_EXCLUDING[]
      I_BYPASSING_BUFFER      = 'X'
    TABLES
      T_OUTTAB                = T_QMLOG
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " LIST_DETAIL
*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*      -->FU_ICON    text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON2 USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    "F_ALV_FIELDCATG_ICON2
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA : WA_LOG LIKE T_QMLOG.
  CASE R_UCOMM.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN '&IC1'.
      IF RS_SELFIELD-FIELDNAME = 'PRUEFLOS'.
        READ TABLE T_QMLOG INTO WA_LOG INDEX RS_SELFIELD-TABINDEX.
        IF SY-SUBRC EQ 0.
          SET PARAMETER ID 'QLS' FIELD WA_LOG-PRUEFLOS.
          CALL TRANSACTION 'QE03' AND SKIP FIRST SCREEN.

        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_COMMIT .
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.                    " BAPI_COMMIT
*&---------------------------------------------------------------------*
*&      Form  F_LIST_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_PRINT .
  IF T_ORDER2[] IS INITIAL.
    MESSAGE 'Tidak ada Data!' TYPE 'I'.
  ELSE.
    PERFORM FIELD_CATALOG_PRINT.
    PERFORM LAYOUT.
    PERFORM LIST_DETAIL_PRINT.
  ENDIF.
ENDFORM.                    " F_LIST_PRINT
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_PRINT .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'T_ORDER2' :
    'MATNR'  '' ''  '' '' 'Material'      '' '' '' '',
    'PRUEFLOS' '' ''  '' ''  'Inspection Lot' ''  '' '' ' ' ,
    'CHARGAS'  '' ''  '' ''  'Asigned Batch ' ''  '' '' ' ' ,
    'ROLLSR'  '' ''  '' ''  'Slit Roll Number' ''  ' ' '' ' ' ,
    'ERDAT'  '' ''  '' ''  'Date Print' ''  ' ' '' ' ' ,
    'ERZET'  '' ''  '' ''  'Time Print' ''  ' ' '' ' ' ,
    'USNAM'  '' ''  '' ''  'User Print' ''  ' ' '' ' ' ,
    'NONIK'  '' ''  '' ''  'NIK' ''  ' ' '' ' ' .
ENDFORM.                    " FIELD_CATALOG_PRINT

*&---------------------------------------------------------------------*
*&      Form  LIST_DETAIL_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DETAIL_PRINT .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'TUSER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = T_ORDER2
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " LIST_DETAIL_PRINT
*&---------------------------------------------------------------------*
*&      Form  TUSER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM TUSER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'QUIT'.
      LEAVE TO TRANSACTION 'ZQM004P'.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA: LF_FCODE TYPE TABLE OF SY-UCOMM.

  APPEND 'LIST' TO LF_FCODE.
  APPEND 'DETL' TO LF_FCODE.
  APPEND 'SRCH' TO LF_FCODE.
  APPEND 'PRNT' TO LF_FCODE.
  APPEND 'QUIT' TO LT_FCODE.
  SET PF-STATUS 'PFSTAT' EXCLUDING LF_FCODE.
ENDFORM.                    "F_GUI_STATUS
*&---------------------------------------------------------------------*
*&      Form  GETBATCHJR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ECHARG  text
*      <--P_T_ORDER1_CHARG  text
*      <--P_EXT  text
*----------------------------------------------------------------------*
FORM GETBATCHJR  USING    P_ECHARG
                 CHANGING P_T_ORDER1_CHARG
                          P_T_ORDER1_MATNR
                          P_EXT.
  DATA : AUFNR LIKE AFPO-AUFNR,
         EMATKL LIKE MARA-MATKL,
         EMTART LIKE MARA-MTART,
         T_MGS(1).

  REFRESH T_VALID.
  SELECT MBLNR SMBLN AUFNR ZEILE SMBLP INTO CORRESPONDING FIELDS OF TABLE T_VALID
    FROM MSEG
    WHERE MSEG~CHARG = P_ECHARG
    AND BWART IN ('101','102').

  IF SY-SUBRC NE 0.
    SELECT MSEG~MBLNR MSEG~SMBLN MSEG~AUFNR MSEG~ZEILE MSEG~SMBLP INTO CORRESPONDING FIELDS OF TABLE T_VALID
    FROM MSEG
      JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
    WHERE MSEG~CHARG = P_ECHARG
    AND BWART IN ('531','532') AND AUFK~AUART = 'ZMM1'.
  ENDIF.

  LOOP AT T_VALID WHERE SMBLN IS NOT INITIAL.
    DELETE T_VALID WHERE MBLNR EQ T_VALID-SMBLN AND ZEILE EQ T_VALID-SMBLP.
    DELETE T_VALID WHERE MBLNR EQ T_VALID-MBLNR AND ZEILE EQ T_VALID-ZEILE.
  ENDLOOP.
  READ TABLE T_VALID INDEX 1.
  IF T_VALID-AUFNR IS INITIAL.
    P_EXT = 'X'.
    EXIT.
  ENDIF.

  CLEAR: AUFNR.
  SELECT SINGLE AUFNR INTO AUFNR
    FROM AFPO
    WHERE AFPO~MILL_OC_AUFNR_U = T_VALID-AUFNR.
  IF AUFNR = '' OR AUFNR IS INITIAL.
    P_EXT = 'X'.
    EXIT.
  ENDIF.

  REFRESH T_VALID.
  SELECT MBLNR SMBLN AUFNR ZEILE SMBLP MATNR CHARG INTO CORRESPONDING FIELDS OF TABLE T_VALID
          FROM MSEG
          WHERE MSEG~AUFNR = AUFNR
          AND MSEG~BWART IN ('261','262','901','902').
  LOOP AT T_VALID.
    IF T_VALID-SMBLN IS NOT INITIAL.
      DELETE T_VALID WHERE MBLNR EQ T_VALID-SMBLN.
      DELETE T_VALID WHERE SMBLN EQ T_VALID-SMBLN.
    ENDIF.
  ENDLOOP.
  IF T_VALID[] IS INITIAL.
    P_EXT = 'X'.
  ENDIF.
  LOOP AT T_VALID.
    CLEAR: EMTART,T_MGS,EMATKL,P_T_ORDER1_CHARG.
    SELECT SINGLE MTART MATKL INTO (EMTART, EMATKL)
        FROM MARA
        WHERE MARA~MATNR = T_VALID-MATNR.
    IF EMATKL GE 400001 AND EMATKL LE 400100.
      T_MGS = 'X'.
    ENDIF.
    IF EMTART EQ 'ZSFG' AND T_MGS EQ 'X'.
      P_EXT = 'X'.
    ENDIF.
    P_T_ORDER1_CHARG = T_VALID-CHARG.
    P_T_ORDER1_MATNR = T_VALID-MATNR.
  ENDLOOP.
ENDFORM.                    " GETBATCHJR