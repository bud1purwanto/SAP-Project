*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_BY_CHAR_F01                           *
*&---------------------------------------------------------------------*
  DATA: V_ZZTYPE LIKE CABN-ATINN,
        V_ZZTHICKNESS LIKE CABN-ATINN,
        V_ZZWIDTH LIKE CABN-ATINN,
        V_ZZLENGTH LIKE CABN-ATINN,
        V_ZZNOMORROLL LIKE CABN-ATINN,
        V_ZZSPLICE-1 LIKE CABN-ATINN,
        V_ZZSPLICE-2 LIKE CABN-ATINN,
        V_ZZSPLICE-3 LIKE CABN-ATINN,
        V_ZZALIAS LIKE CABN-ATINN,
        V_ZZEXLENGTH LIKE CABN-ATINN,
        V_ZZEXPIREDLIVE LIKE CABN-ATINN,
        V_ZZLENGTHSHT LIKE CABN-ATINN,
        V_ZZCORE LIKE CABN-ATINN,
        V_ZZCRITERIA LIKE CABN-ATINN,
        V_ZZPACKING LIKE CABN-ATINN,
        V_ZZTREATMENT LIKE CABN-ATINN,
        V_ZZLABEL LIKE CABN-ATINN,
        V_ZZGRADE LIKE CABN-ATINN,
        V_ZZPACKCODE LIKE CABN-ATINN, "ADDED BY FATHIR ON 20.07.2020 - internal no ZZPACKINGCODE, tuning
        V_ZZCOMBNO LIKE CABN-ATINN. "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No

*&---------------------------------------------------------------------*
*&      Form  GT_LST_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZCHAR      text
*      -->ZVAL       text
*----------------------------------------------------------------------*
  FORM GT_LST_CHAR USING ZCHAR CHANGING ZVAL.
    REFRESH : ZCHARACT, IT_F4.
    IF ZCHAR = 'I/O'.
      IT_F4-CHARV = 'I'.
      IT_F4-CHARD = 'Inhouse'.
      APPEND IT_F4.
      IT_F4-CHARV = 'O'.
      IT_F4-CHARD = 'Outsource'.
      APPEND IT_F4.
    ELSE.

      CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
        EXPORTING
          CHARACTNAME        = ZCHAR
        TABLES
          CHARACTVALUESDESCR = ZCHARACT
          RETURN             = ZRETURN.

*    SORT ZCRHD BY ARBPL.
      LOOP AT ZCHARACT ASSIGNING <FS_ZCHARACT>.
        IT_F4-CHARV = <FS_ZCHARACT>-VALUE_CHAR.
        IT_F4-CHARD = <FS_ZCHARACT>-DESCRIPTION.
        APPEND IT_F4.
      ENDLOOP.
    ENDIF.

    IF ZCHAR = 'ZZTYPE'.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD     = 'CHARV'
          WINDOW_TITLE = 'Resource Help List'
          VALUE_ORG    = 'S'
        TABLES
          VALUE_TAB    = IT_F4
          RETURN_TAB   = IT_RETURN.
    ELSE.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD     = 'CHARD'
          WINDOW_TITLE = 'Resource Help List'
          VALUE_ORG    = 'S'
        TABLES
          VALUE_TAB    = IT_F4
          RETURN_TAB   = IT_RETURN.
    ENDIF.

*
    IF SY-SUBRC = 0.
      ZVAL = IT_RETURN-FIELDVAL.
    ENDIF.

  ENDFORM.                    "GT_LST_CHAR

*&---------------------------------------------------------------------*
*&      Form  GT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GT_DATA.
    DATA : DLEN TYPE I.
    DATA : NUMBER1(10),
           NUMBER2(10),
           NUM TYPE P,
           V_PERCENT TYPE P,
           LINE TYPE P,
           VTEXT TYPE STRING.

    CLEAR   : IT_ZBMBC,IT_F4,IT_COLLECT,TMP_ZBMBC,TMP_COLLECT,ZVAL,ZRETURN,ZCHARACT,IT_RETURN.
    REFRESH : IT_ZBMBC,IT_F4,IT_COLLECT,TMP_ZBMBC,TMP_COLLECT,ZVAL,ZRETURN,ZCHARACT,IT_RETURN.

    CHECK LINES( S_MATNR ) > 0.

    PERFORM SET_ATINN.  "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Set ATINN di awal proses
    IF S_VBELN IS INITIAL AND S_POSNR IS INITIAL AND S_AUART IS INITIAL.

*- add by ALF for fine tuning
      SELECT MATNR INTO TABLE TMP_ZBMBC FROM MARA
        WHERE MATNR IN S_MATNR AND MTART IN ('ZFGS','ZSFG') AND MTART IN S_MTART.
      IF SY-SUBRC = 0.
        REFRESH S_MATNR.
        S_MATNR-SIGN = 'I'.   S_MATNR-OPTION = 'EQ'.
        LOOP AT TMP_ZBMBC.
          S_MATNR-LOW = TMP_ZBMBC-MATNR.
          APPEND S_MATNR.
        ENDLOOP.
        REFRESH: TMP_ZBMBC.
      ENDIF.
*- end of add by ALF for fine tuning

      IF S_ATWRT7[] IS NOT INITIAL.  "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No

        SELECT MCH1~CHARG AS CHARG " get batch berdasarkan input 'TYB Combination No'
          FROM AUSP JOIN MCH1 ON AUSP~OBJEK  = MCH1~CUOBJ_BM
          INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
          WHERE MCH1~MATNR IN S_MATNR
            AND AUSP~ATINN = V_ZZCOMBNO
            AND AUSP~ATWRT IN S_ATWRT7
            AND AUSP~KLART = '023'.

        IF SY-SUBRC EQ 0. " copy batch yang ditemukan ke dalam range batch S_CHARG
          S_CHARG-SIGN = 'I'. S_CHARG-OPTION = 'EQ'.
          LOOP AT TMP_ZBMBC.
            S_CHARG-LOW = TMP_ZBMBC-CHARG.
            APPEND S_CHARG.
          ENDLOOP.
        ENDIF.

        REFRESH: TMP_ZBMBC.
        CLEAR: TMP_ZBMBC.
      ENDIF. "End of ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No

      IF P_ZERO IS NOT INITIAL.
        SELECT DISTINCT MCHB~MATNR AS MATNR
                        MCHB~WERKS AS WERKS
                        MCHB~LGORT AS LGORT
                        MCHB~CHARG AS CHARG
                        MCHB~CLABS AS LABST
                        MCHB~CINSM AS INSME
                        MCHB~CEINM AS EINME
                        MCHB~CSPEM AS SPEME
          INTO CORRESPONDING FIELDS OF TABLE IT_ZBMBC
        FROM MCHB
          JOIN MARA ON MARA~MATNR = MCHB~MATNR
        WHERE MCHB~MATNR IN S_MATNR AND
              MCHB~WERKS IN S_WERKS AND
              MCHB~LGORT IN S_LGORT AND
              MCHB~CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
              MTART IN ('ZFGS','ZSFG') AND
              MTART IN S_MTART AND
           ( CLABS > 0 OR CINSM > 0 OR CEINM > 0 OR CSPEM > 0 ).

        CLEAR: TMP_ZBMBC.
        REFRESH: TMP_ZBMBC.
        SELECT DISTINCT MSKA~MATNR
                        MSKA~WERKS
                        MSKA~LGORT
                        MSKA~CHARG
                        MSKA~SOBKZ
                        MSKA~VBELN
                        MSKA~POSNR
*                      AUART
                        MSKA~KALAB AS LABST
                        MSKA~KAINS AS INSME
                        MSKA~KAEIN AS EINME
                        MSKA~KASPE AS SPEME
*        INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
          APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
        FROM MSKA
          JOIN MARA ON MARA~MATNR = MSKA~MATNR
*        JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
        WHERE MSKA~MATNR IN S_MATNR AND
              MSKA~WERKS IN S_WERKS AND
              MSKA~LGORT IN S_LGORT AND
              MSKA~CHARG IN S_CHARG AND
              MSKA~CHARG NE '' AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
              MARA~MTART IN ('ZFGS','ZSFG') AND
              MARA~MTART IN S_MTART AND
              ( MSKA~KALAB > 0 OR MSKA~KAINS > 0 OR MSKA~KAEIN > 0 OR MSKA~KASPE > 0 ).

        "ADDED BY FATHIR ON 20.07.2020
        " pemindahan query get MSKU, tuning
        SELECT DISTINCT MSKU~MATNR
                        MSKU~WERKS
                        MSKU~CHARG
                        SOBKZ
                        KULAB AS LABST
                        KUINS AS INSME
                        KUEIN AS EINME
          APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
          FROM MSKU
          JOIN MARA ON MARA~MATNR = MSKU~MATNR
          WHERE SOBKZ IN S_SOBKZ
            AND MSKU~MATNR IN S_MATNR
            AND MSKU~WERKS IN S_WERKS
            AND MSKU~CHARG IN S_CHARG
            AND MTART IN ('ZFGS','ZSFG')
            AND MTART IN S_MTART
            AND ( MSKU~KULAB > 0 OR MSKU~KUINS > 0 OR MSKU~KUEIN > 0 ).

        SORT IT_ZBMBC BY VBELN.
        CLEAR TMP_COLLECT.
        LOOP AT IT_ZBMBC WHERE VBELN NE ''.
          IF TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
            CONTINUE.
          ENDIF.

          SELECT SINGLE AUART INTO IT_ZBMBC-AUART FROM VBAK WHERE VBELN = IT_ZBMBC-VBELN.
          IF SY-SUBRC = 0.
            MODIFY IT_ZBMBC TRANSPORTING AUART WHERE  VBELN = IT_ZBMBC-VBELN.
          ENDIF.
          TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
        ENDLOOP.

      ELSE.   "p_zero

        SELECT DISTINCT MCHB~MATNR AS MATNR
                        MCHB~WERKS AS WERKS
                        MCHB~LGORT AS LGORT
                        MCHB~CHARG AS CHARG
                        MCHB~CLABS AS LABST
                        MCHB~CINSM AS INSME
                        MCHB~CEINM AS EINME
                        MCHB~CSPEM AS SPEME
          INTO CORRESPONDING FIELDS OF TABLE IT_ZBMBC
        FROM MCHB
          JOIN MARA ON MARA~MATNR = MCHB~MATNR
        WHERE MCHB~MATNR IN S_MATNR AND
              MCHB~WERKS IN S_WERKS AND
              MCHB~LGORT IN S_LGORT AND
              MCHB~CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
              MTART IN ('ZFGS','ZSFG') AND
              MTART IN S_MTART.

        CLEAR: TMP_ZBMBC.
        REFRESH: TMP_ZBMBC.
        SELECT DISTINCT MSKA~MATNR
                        MSKA~WERKS
                        MSKA~LGORT
                        MSKA~CHARG
                        MSKA~SOBKZ
                        MSKA~VBELN
                        MSKA~POSNR
*                      AUART
                        MSKA~KALAB AS LABST
                        MSKA~KAINS AS INSME
                        MSKA~KAEIN AS EINME
                        MSKA~KASPE AS SPEME
*        INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
          APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
        FROM MSKA
          JOIN MARA ON MARA~MATNR = MSKA~MATNR
*        JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
        WHERE MSKA~MATNR IN S_MATNR AND
              MSKA~WERKS IN S_WERKS AND
              MSKA~LGORT IN S_LGORT AND
              MSKA~CHARG IN S_CHARG AND
              MSKA~CHARG NE '' AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
              MARA~MTART IN ('ZFGS','ZSFG') AND
              MARA~MTART IN S_MTART.

        "ADDED BY FATHIR ON 20.07.2020
        " pindah query get MSKU, tuning
        SELECT DISTINCT MSKU~MATNR
                        MSKU~WERKS
                        MSKU~CHARG
                        SOBKZ
                        KULAB AS LABST
                        KUINS AS INSME
                        KUEIN AS EINME
          APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
          FROM MSKU
          JOIN MARA ON MARA~MATNR = MSKU~MATNR
          WHERE SOBKZ IN S_SOBKZ
            AND MSKU~MATNR IN S_MATNR
            AND MSKU~WERKS IN S_WERKS
            AND MSKU~CHARG IN S_CHARG
            AND MTART IN ('ZFGS','ZSFG')
            AND MTART IN S_MTART.

        "ADDED BY FATHIR ON 20.07.2020
        " get Order Type, tuning
        SORT IT_ZBMBC BY VBELN.
        CLEAR TMP_COLLECT.
        LOOP AT IT_ZBMBC WHERE VBELN NE ''.
          IF TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
            CONTINUE.
          ENDIF.

          SELECT SINGLE AUART INTO IT_ZBMBC-AUART FROM VBAK WHERE VBELN = IT_ZBMBC-VBELN.
          IF SY-SUBRC = 0.
            MODIFY IT_ZBMBC TRANSPORTING AUART WHERE  VBELN = IT_ZBMBC-VBELN.
          ENDIF.
          TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
        ENDLOOP.


      ENDIF.    "p_zero

      "CHANGED BY FATHIR ON 10.07.2020
      " pindah blok ini di dalam "Zero Stockline", tuning
*      SORT IT_ZBMBC BY VBELN.
*      CLEAR TMP_COLLECT.
*      LOOP AT IT_ZBMBC WHERE VBELN NE ''.
*        IF TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
*          CONTINUE.
*        ENDIF.
*
*        SELECT SINGLE AUART INTO IT_ZBMBC-AUART FROM VBAK WHERE VBELN = IT_ZBMBC-VBELN.
*        IF SY-SUBRC = 0.
*          MODIFY IT_ZBMBC TRANSPORTING AUART WHERE  VBELN = IT_ZBMBC-VBELN.
*        ENDIF.
*        TMP_COLLECT-VBELN = IT_ZBMBC-VBELN.
*      ENDLOOP.

*    LOOP AT TMP_ZBMBC ASSIGNING <FS_ZBMBC> WHERE CHARG NE ' '.
*      SELECT SINGLE LGPLA INTO <FS_ZBMBC>-LGPLA
*        FROM LIPS
*      WHERE VBELN = <FS_ZBMBC>-VBELN AND
*            POSNR = <FS_ZBMBC>-POSNR.
*    ENDLOOP.

*    APPEND LINES OF TMP_ZBMBC TO IT_ZBMBC.

      REFRESH TMP_COLLECT.
      SELECT DISTINCT MSLB~MATNR WERKS CHARG SOBKZ
                      LBLAB AS LABST
                      LBINS AS INSME
                      LBEIN AS EINME
        INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
      FROM MSLB
      JOIN MARA ON MARA~MATNR = MSLB~MATNR
      WHERE SOBKZ IN S_SOBKZ AND
            MSLB~MATNR IN S_MATNR AND
            WERKS IN S_WERKS AND
            CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            MTART IN S_MTART.

      LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
        COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
      ENDLOOP.

      IF S_LGORT IS INITIAL.
        CLEAR IT_ZBMBC.
        LOOP AT IT_COLLECT ASSIGNING <FS_COLLECT>.
          IT_ZBMBC-MATNR = <FS_COLLECT>-MATNR.
          IT_ZBMBC-WERKS = <FS_COLLECT>-WERKS.
          IT_ZBMBC-CHARG = <FS_COLLECT>-CHARG.
          IT_ZBMBC-SOBKZ = <FS_COLLECT>-SOBKZ.
          IT_ZBMBC-LABST = <FS_COLLECT>-LABST.
          IT_ZBMBC-INSME = <FS_COLLECT>-INSME.
*        IT_ZBMBC-SPEME = <FS_COLLECT>-EINME.
          APPEND IT_ZBMBC.
        ENDLOOP.
      ENDIF.

      "CHANGED BY FATHIR ON 20.07.2020
      " pindah query ke blok "No Zero/Zero Stock Line", tuning
*      CLEAR: TMP_ZBMBC.
*      REFRESH: TMP_ZBMBC.
*      SELECT DISTINCT MSKU~MATNR
*                      MSKU~WERKS
*                      MSKU~CHARG
*                      SOBKZ
*                      KULAB AS LABST
*                      KUINS AS INSME
*                      KUEIN AS EINME
*        INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
*      FROM MSKU
*        JOIN MARA ON MARA~MATNR = MSKU~MATNR
*      WHERE SOBKZ IN S_SOBKZ AND
*            MSKU~MATNR IN S_MATNR AND
*            MSKU~WERKS IN S_WERKS AND
*            MSKU~CHARG IN S_CHARG AND
**          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
*            MTART IN ('ZFGS','ZSFG') AND
*            MTART IN S_MTART.
*
*      APPEND LINES OF TMP_ZBMBC TO IT_ZBMBC.

    ELSE.

      SELECT DISTINCT MSKA~MATNR
                      MSKA~WERKS
                      MSKA~LGORT
                      MSKA~CHARG
                      SOBKZ
                      MSKA~VBELN
                      MSKA~POSNR
                      VBAK~AUART
                      KALAB AS LABST
                      KAINS AS INSME
                      KAEIN AS EINME
                      KASPE AS SPEME
        INTO CORRESPONDING FIELDS OF TABLE IT_ZBMBC
      FROM MSKA
        JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
        JOIN MARA ON MARA~MATNR = MSKA~MATNR
        WHERE MSKA~MATNR IN S_MATNR AND
              MSKA~WERKS IN S_WERKS AND
              MSKA~LGORT IN S_LGORT AND
              MSKA~CHARG IN S_CHARG AND
              MSKA~VBELN IN S_VBELN AND
              MSKA~POSNR IN S_POSNR AND
              AUART IN S_AUART AND
              MTART IN S_MTART AND
*           MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
              MTART IN ('ZFGS','ZSFG') AND
              SOBKZ IN S_SOBKZ.
    ENDIF.

*  COLLECT ALL CATEGORY####################################################

    "CHANGED BY FATHIR ON 10.07.2020
    " pindah proses get CoreID, tuning
*    DATA: STATUS TYPE ZCORER-STATUS.
*    DATA: CHARG TYPE ZCORER-CHARG.
*    DATA: COREID TYPE ZCORER-COREID.
*    DATA: SEQNO TYPE ZCORER-SEQNO.
*
*    IF LINES( IT_ZBMBC ) > 0.      "Added By: J. Budi on 28.01.2019
*      LOOP AT IT_ZBMBC.
*        SELECT MAX( SEQNO ) INTO SEQNO FROM ZCORER WHERE CHARG = IT_ZBMBC-CHARG.
*        SELECT SINGLE COREID INTO COREID FROM ZCORER WHERE SEQNO = SEQNO.
*        SELECT SINGLE STATUS INTO STATUS FROM ZCORER WHERE COREID = COREID AND CHARG = 'MASTER'.
*
*        IF STATUS = 'B' OR STATUS = 'R' OR STATUS = 'C'.
*          CLEAR SEQNO.
*          SELECT MAX( SEQNO ) INTO SEQNO FROM ZCORER WHERE COREID = COREID.
*          SELECT SINGLE CHARG INTO CHARG FROM ZCORER WHERE SEQNO = SEQNO.
*          IT_ZBMBC-COREID = COREID.
*          MODIFY IT_ZBMBC TRANSPORTING COREID WHERE CHARG = CHARG.
*        ENDIF.
*
*        CLEAR STATUS.
*        CLEAR CHARG.
*        CLEAR COREID.
*        CLEAR SEQNO.
*      ENDLOOP.
*    ENDIF.

*  DELETE IT_COLLECT WHERE SOBKZ = 'K'.
*  DELETE IT_COLLECT WHERE SOBKZ = 'M'.
*  DELETE IT_COLLECT WHERE SOBKZ = 'Q'.
*######################################################################
*  DELETE BASE ON SELECTION SCREEN###############################################################
*  IT_COLLECT2[] = IT_COLLECT[].
    IF S_SOBKZ IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE SOBKZ NOT IN S_SOBKZ.
    ENDIF.

    IF P_ZERO IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE LABST = 0 AND INSME = 0 AND SPEME = 0.
    ENDIF.

    IF S_VBELN IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE VBELN NOT IN S_VBELN.
    ENDIF.
    IF S_POSNR IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE POSNR NOT IN S_POSNR.
    ENDIF.
    IF S_AUART IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE AUART NOT IN S_AUART.
    ENDIF.
*###################################################################################################
    DELETE IT_ZBMBC WHERE CHARG = ' '.
    DESCRIBE TABLE IT_ZBMBC LINES LINE.
    NUMBER2 = LINE.
    NUM = NUMBER1 = 0.

    LOOP AT IT_ZBMBC ASSIGNING <FS_ZBMBC>  .
      CLEAR : ZVAL.
      REFRESH : ZVAL.
      NUM = NUM + 1.
      IF NUM = '100'.
        NUMBER1 = NUMBER1 + NUM.
        CONCATENATE NUMBER1 'OF' NUMBER2 INTO VTEXT SEPARATED BY SPACE.
        V_PERCENT  = ( SY-TABIX / LINE ) * 100.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            PERCENTAGE = V_PERCENT
            TEXT       = VTEXT.
        NUM = 0.
      ENDIF.

      SELECT SINGLE LGPLA INTO <FS_ZBMBC>-LGPLA
          FROM LQUA
        WHERE MATNR = <FS_ZBMBC>-MATNR AND
              WERKS = <FS_ZBMBC>-WERKS AND
              CHARG = <FS_ZBMBC>-CHARG.

      PERFORM GT_HU USING 'BOX' <FS_ZBMBC>-MATNR <FS_ZBMBC>-CHARG <FS_ZBMBC>-WERKS
                                <FS_ZBMBC>-LGORT <FS_ZBMBC>-SOBKZ
                  CHANGING <FS_ZBMBC>-HUBOX.

      IF <FS_ZBMBC>-HUBOX NE ''.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <FS_ZBMBC>-HUBOX
          IMPORTING
            OUTPUT = <FS_ZBMBC>-HUBOX.
      ENDIF.

      PERFORM GT_HU USING 'PLT' <FS_ZBMBC>-MATNR <FS_ZBMBC>-CHARG <FS_ZBMBC>-WERKS
                                <FS_ZBMBC>-LGORT <FS_ZBMBC>-SOBKZ
                    CHANGING <FS_ZBMBC>-HUPLT.

      IF <FS_ZBMBC>-HUPLT NE ''.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <FS_ZBMBC>-HUPLT
          IMPORTING
            OUTPUT = <FS_ZBMBC>-HUPLT.
      ENDIF.


* function baru
      IF <FS_ZBMBC>-CHARG NE ''.
        CLEAR : IT_CHAR.
        REFRESH : IT_CHAR.
*      CALL FUNCTION 'ZCHARACTERISTICS'
*        EXPORTING
*          I_VAL_MATNR  = <FS_ZBMBC>-MATNR
*          I_VAL_CHARGE = <FS_ZBMBC>-CHARG
*        TABLES
*          T_VAL_TAB    = IT_CHAR
*        EXCEPTIONS
*          NO_OBJECT    = 1
*          NO_VALUES    = 2
*          T_L_E1       = 3
*          T_L_E2       = 4.
*
*  SELECT SINGLE CUOBJ_BM INTO CUOBJ_BM
*    FROM MCH1
*    WHERE MCH1~MATNR  = I_VAL_MATNR
*    AND   MCH1~CHARG  = I_VAL_CHARGE.

        SELECT AUSP~ATINN AS ATINN
               AUSP~ATWRT AS ATWRT
               AUSP~ATFLV AS ATFLV
          FROM AUSP JOIN MCH1 ON AUSP~OBJEK  = MCH1~CUOBJ_BM
          INTO CORRESPONDING FIELDS OF TABLE IT_CHAR
          WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR   AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG
          AND  AUSP~ATINN IN (V_ZZTYPE,V_ZZTHICKNESS, V_ZZWIDTH, V_ZZLENGTH, V_ZZNOMORROLL, V_ZZSPLICE-1, V_ZZSPLICE-2, V_ZZSPLICE-3,
               V_ZZALIAS, V_ZZEXLENGTH, V_ZZEXPIREDLIVE, V_ZZLENGTH,
               V_ZZCOMBNO)  "CHANGED FOR AGS BY FATHIR ON 31.02.2021 - Combination No
          AND AUSP~KLART = '023'.
*------
        SELECT AUSP~ATINN AS ATINN
               AUSP~ATWRT AS ATWRT
               AUSP~ATFLV AS ATFLV
               CAWNT~ATWTB AS ATWTB
          FROM MCH1
          JOIN AUSP ON AUSP~OBJEK  = MCH1~CUOBJ_BM
          JOIN CAWN ON  AUSP~ATINN = CAWN~ATINN
                    AND AUSP~ATWRT = CAWN~ATWRT
          JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN
                    AND CAWN~ATZHL = CAWNT~ATZHL
          APPENDING CORRESPONDING FIELDS OF TABLE IT_CHAR
          WHERE MCH1~MATNR = <FS_ZBMBC>-MATNR AND MCH1~CHARG = <FS_ZBMBC>-CHARG AND CAWNT~SPRAS = 'E'
            AND AUSP~ATINN IN (V_ZZCORE, V_ZZCRITERIA, V_ZZPACKING, V_ZZTREATMENT, V_ZZLABEL, V_ZZGRADE,
                               V_ZZPACKCODE)
            AND AUSP~KLART = '023'.

        LOOP AT IT_CHAR.
*  if v_atinn = v_ZZTYPE.
*    <FS_ZBMBC>-ZZTYPE =  <FS_CHAR>-ATWRT.
          IF IT_CHAR-ATINN =  V_ZZTYPE.
            <FS_ZBMBC>-ZZTYPE =  IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN =  V_ZZTHICKNESS.
            MOVE IT_CHAR-ATFLV TO ATFLV1.
            <FS_ZBMBC>-ZZTHICKNESS =  ATFLV1.
          ELSEIF IT_CHAR-ATINN =  V_ZZWIDTH.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZWIDTH =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZLENGTH.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZNOMORROLL.
            <FS_ZBMBC>-ZZNOMORROLL =  IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN =  V_ZZSPLICE-1.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZSPLICE_1 =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZSPLICE-2.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZSPLICE_2 =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZSPLICE-3.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZSPLICE_3 =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZALIAS.
            <FS_ZBMBC>-ZZALIAS =  IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN =  V_ZZEXLENGTH.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZEXLENGTH =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZLENGTHSHT.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZEXPIREDLIVE.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZEXPIREDLIVE =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZLENGTH.
            MOVE IT_CHAR-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
          ELSEIF IT_CHAR-ATINN =  V_ZZCORE.
            <FS_ZBMBC>-ZZCORE =  IT_CHAR-ATWTB.
          ELSEIF IT_CHAR-ATINN =  V_ZZCRITERIA.
            <FS_ZBMBC>-ZZCRITERIA =  IT_CHAR-ATWTB.
          ELSEIF IT_CHAR-ATINN =  V_ZZPACKING.
            <FS_ZBMBC>-ZZPACKING =  IT_CHAR-ATWTB.
          ELSEIF IT_CHAR-ATINN =  V_ZZTREATMENT.
            <FS_ZBMBC>-ZZTREATMENT =  IT_CHAR-ATWTB.
          ELSEIF IT_CHAR-ATINN =  V_ZZLABEL.
            <FS_ZBMBC>-ZZLABEL =  IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN =  V_ZZGRADE.
            <FS_ZBMBC>-ZZGRADE =  IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN = V_ZZPACKCODE.  "ADDED BY FATHIR On 20.07.2020 - copy ZZPACKINGCODE, tuning
            <FS_ZBMBC>-ZZPACKINGCODE = IT_CHAR-ATWRT.
          ELSEIF IT_CHAR-ATINN = V_ZZCOMBNO.  "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No
            <FS_ZBMBC>-TYBCOMBNO = IT_CHAR-ATWRT.
          ELSE.

          ENDIF.
        ENDLOOP.
      ENDIF.
** ----


      IF <FS_ZBMBC>-LABST NE 0.
        <FS_ZBMBC>-LROLL = 1.
      ENDIF.
*    <FS_ZBMBC>-INSME = <FS_COLLECT>-INSME.
      IF <FS_ZBMBC>-INSME NE 0.
        <FS_ZBMBC>-IROLL = 1.
      ENDIF.
*      <FS_ZBMBC>-SPEME = <FS_COLLECT>-SPEME.
      IF <FS_ZBMBC>-SPEME NE 0.
        <FS_ZBMBC>-BROLL = 1.
      ENDIF.
*    ENDIF.

      IF <FS_ZBMBC>-VBELN IS NOT INITIAL AND <FS_ZBMBC>-POSNR IS NOT INITIAL.
        SELECT SINGLE BEZEI INTO <FS_ZBMBC>-BEZEI
          FROM TVAGT
        JOIN VBAP ON VBAP~ABGRU = TVAGT~ABGRU
        WHERE SPRAS = 'E' AND
              VBELN = <FS_ZBMBC>-VBELN AND
              POSNR = <FS_ZBMBC>-POSNR.

        SELECT SINGLE B~NAME1 INTO <FS_ZBMBC>-NAME1
          FROM VBPA AS A JOIN ADRC AS B ON A~ADRNR = B~ADDRNUMBER
         WHERE A~VBELN = <FS_ZBMBC>-VBELN AND A~PARVW = 'AG'.

      ELSEIF <FS_ZBMBC>-VBELN IS INITIAL AND <FS_ZBMBC>-POSNR IS INITIAL.
        SELECT SINGLE NAME1 INTO <FS_ZBMBC>-NAME1
          FROM KNA1
        JOIN MSKU ON MSKU~KUNNR = KNA1~KUNNR
          WHERE MSKU~MATNR = <FS_ZBMBC>-MATNR AND
                MSKU~WERKS = <FS_ZBMBC>-WERKS AND
                MSKU~CHARG = <FS_ZBMBC>-CHARG.
      ENDIF.

      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = <FS_ZBMBC>-MATNR
          CHARG = <FS_ZBMBC>-CHARG
        IMPORTING
          PDATE = <FS_ZBMBC>-ERSDA.

      IF <FS_ZBMBC>-ERSDA NE '00000000'.
        <FS_ZBMBC>-DEXDT = <FS_ZBMBC>-ERSDA + <FS_ZBMBC>-ZZEXPIREDLIVE.
      ENDIF.

    ENDLOOP.

    IF S_ATWRT1 IS NOT INITIAL.
      DELETE IT_ZBMBC  WHERE ZZTYPE NOT IN S_ATWRT1 .
    ENDIF.

    IF S_ATWRT2 IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE ZZTHICKNESS NOT IN S_ATWRT2.
    ENDIF.

    IF S_ATWRT3 IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE ZZWIDTH NOT IN S_ATWRT3.
    ENDIF.

    IF S_ATWRT4 IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE ZZLENGTH NOT IN S_ATWRT4.
    ENDIF.

    IF S_ATWRT6 IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE ZZCORE NOT IN S_ATWRT6.
    ENDIF.

    IF S_ATWRT5 IS NOT INITIAL.
      DELETE IT_ZBMBC WHERE ZZTREATMENT NOT IN S_ATWRT5.
    ENDIF.

    IF S_ATWRT7 IS NOT INITIAL. "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No
      DELETE IT_ZBMBC WHERE TYBCOMBNO NOT IN S_ATWRT7.
    ENDIF.

    SORT IT_ZBMBC BY MATNR WERKS LGORT CHARG.

    LOOP AT IT_ZBMBC.
      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = IT_ZBMBC-MATNR
          CHARG = IT_ZBMBC-CHARG
        IMPORTING
          PDATE = IT_ZBMBC-PDATE.

*- get vendor batch
      SELECT SINGLE LICHA INTO IT_ZBMBC-LICHA FROM MCH1 WHERE CHARG = IT_ZBMBC-CHARG.

      MODIFY IT_ZBMBC.
    ENDLOOP.

*- toyobo
    IF P_TYB = 'X'.
      PERFORM GET_TOYOBO.
    ENDIF.

    IF P_KTNG = 'X'.
      PERFORM GET_KTNG.
    ENDIF.

    "ADDED BY FATHIR ON 20.07.2020
*- get COREID
    PERFORM F_GETCOREID.
  ENDFORM.                    "GT_DATA

*&---------------------------------------------------------------------*
*&      Form  GT_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZMAGRV     text
*      -->ZMATNR     text
*      -->ZCHARG     text
*      -->ZWERKS     text
*      -->ZLGORT     text
*      -->ZSOBKZ     text
*      -->ZEXIDV     text
*----------------------------------------------------------------------*
  FORM GT_HU USING ZMAGRV ZMATNR ZCHARG ZWERKS ZLGORT ZSOBKZ CHANGING ZEXIDV.
    DATA : DVENUM LIKE VEPO-VENUM.

    SELECT SINGLE EXIDV INTO ZEXIDV
      FROM VEPO
    JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
      WHERE MATNR = ZMATNR AND
            VEPO~CHARG = ZCHARG AND
            VEPO~WERKS = ZWERKS AND
            VEPO~LGORT = ZLGORT AND
            SOBKZ = ZSOBKZ AND
            MAGRV = ZMAGRV.

    IF ZMAGRV = 'PLT' AND ZEXIDV IS INITIAL.
      SELECT SINGLE VENUM INTO DVENUM
        FROM VEPO
      WHERE MATNR = ZMATNR AND
            CHARG = ZCHARG AND
            WERKS = ZWERKS AND
            LGORT = ZLGORT.

      CHECK DVENUM IS NOT INITIAL.
      SELECT SINGLE EXIDV INTO ZEXIDV
        FROM VEKP
      JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
        WHERE UNVEL = DVENUM AND
              MAGRV = ZMAGRV.
    ENDIF.
  ENDFORM.                    "GT_HU

*&---------------------------------------------------------------------*
*&      Form  RD_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZCHAR      text
*      -->ZATWTB     text
*----------------------------------------------------------------------*
  FORM RD_CHAR USING ZCHAR CHANGING ZATWTB.
    READ TABLE ZVAL WITH KEY ATNAM = ZCHAR ASSIGNING <FS_ZVAL>.
    IF SY-SUBRC = 0.
      ZATWTB = <FS_ZVAL>-ATWTB.
    ENDIF.
  ENDFORM.                    "RD_CHAR

*&---------------------------------------------------------------------*
*&      Form  RD_CHAR2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZCHAR      text
*      -->ZATWTB     text
*      -->ZATWRT     text
*----------------------------------------------------------------------*
  FORM RD_CHAR2 USING ZCHAR CHANGING ZATWTB ZATWRT.
    READ TABLE ZVAL WITH KEY ATNAM = ZCHAR ASSIGNING <FS_ZVAL>.
    IF SY-SUBRC = 0.
      ZATWTB = <FS_ZVAL>-ATWTB.
      ZATWRT = <FS_ZVAL>-ATWRT.
    ENDIF.
  ENDFORM.                    "RD_CHAR2

*&---------------------------------------------------------------------*
*&      Form  SET_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM SET_ALV.
    CLEAR : WA_LAYOUT.
    DATA : G_SAVE VALUE 'A'.
    D_REPID = SY-REPID.
    T_PRINT-NO_PRINT_SELINFOS = 'X'.
    T_PRINT-NO_PRINT_LISTINFOS = 'X'.
    PERFORM LAYOUT_INIT_BOX USING WA_LAYOUT.
    PERFORM EVENTTAB_BUILD USING T_EVENTS[].
    WA_VARIANTE-REPORT = D_REPID.
    PERFORM BUILD_FIELDCAT.
    PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].
*  PERFORM BUILD_SORTCAT.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        I_CALLBACK_PROGRAM       = D_REPID
        I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
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
        T_OUTTAB                 = IT_ZBMBC.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    REFRESH IT_ZBMBC.
  ENDFORM.                    "SET_ALV

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
  FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
    REFRESH FT_EXTAB.
    CLEAR FT_EXTAB.
*  APPEND 'DETAIL' TO FT_EXTAB.

    SET PF-STATUS 'STANDARD' EXCLUDING FT_EXTAB.
  ENDFORM.                    " F_ALV_STATUS


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM BUILD_FIELDCAT.
    REFRESH T_FIELDCAT.
    PERFORM F_ALV_FIELDCATG  USING 'IT_ZBMBC' :
           'MATNR' '' '' C_NO 18 'Material No' '' '' '',
           'WERKS' '' '' C_NO '' 'Plant' '' '' '',
           'LGORT' '' '' C_NO '' 'Sloc' '' '' ''.

    PERFORM F_ALV_FIELDCATG_WT_ZERO USING 'IT_ZBMBC' :
           'CHARG' '' '' C_NO '' 'Batch' '' '' '',
           'COREID' '' '' C_NO '' 'Core ID' '' '' '',
           'SOBKZ' '' '' C_NO '' 'Special Stock' '' '' '',
           'LGPLA' '' '' C_NO '' 'Storage Bin' '' '' ''.

    PERFORM F_ALV_FIELDCATG  USING 'IT_ZBMBC' :
           'VBELN' '' '' C_NO '' 'SO No' '' '' '',
           'POSNR' '' '' C_NO '' 'SO Item' '' '' '',
           'AUART' '' '' C_NO '' 'Sales Doc Type' '' '' '',
           'HUBOX' '' '' C_NO '' 'HU Box' '' '' '',
           'HUPLT' '' '' C_NO '' 'HU Pallet' '' 'X' ''.

    PERFORM F_ALV_FIELDCATG_WT_ZERO USING 'IT_ZBMBC' :
           'ZZTYPE' '' '' C_NO '' 'Type' '' '' '',
           'ZZTHICKNESS' '' '' C_NO '' 'Thick' '' '' 'RIGHT',
           'ZZWIDTH' '' '' C_NO '' 'Width' '' '' 'RIGHT',
*         'ZZCLEN' '' '' C_NO '' 'Length' '' '' 'RIGHT',
           'ZZLENGTH' '' '' C_NO '' 'Length' '' '' 'RIGHT',
           'ZZCORE' '' '' C_NO '' 'Core' '' '' '',
           'ZZGRADE' '' '' C_NO '' 'Grade' '' '' '',
           'ZZCRITERIA' '' '' C_NO '' 'Criteria' '' '' '',
           'ZZPACKING' '' '' C_NO '' 'Packing' '' '' '',
           'ZZNOMORROLL' '' '' C_NO '' 'No Roll' '' '' '',
           'ZZTREATMENT' '' '' C_NO '' 'Treatment' '' '' '',
           'LABST' '' '' C_NO '' 'Unrest(Kg)' '' '' '',
           'LROLL' '' '' C_NO '' 'Unrest(Roll)' '' '' '',
           'INSME' '' '' C_NO '' 'Quality Inspection(Kg)' '' '' '',
           'IROLL' '' '' C_NO '' 'Quality Inspection(Roll)' '' '' '',
           'SPEME' '' '' C_NO '' 'Blocked Stock(Kg)' '' '' '',
           'BROLL' '' '' C_NO '' 'Blocked Stock(Roll)' '' '' '',
           'BEZEI' '' '' C_NO '' 'SO Rejection' '' '' '',
           'NAME1' '' '' C_NO '' 'Customer Name' '' '' '',
           'ZZSPLICE_1' '' '' C_NO '' 'Splice-1' '' '' '',
           'ZZSPLICE_2' '' '' C_NO '' 'Splice-2' '' '' '',
           'ZZSPLICE_3' '' '' C_NO '' 'Splice-3' '' '' '',
           'ZZEXLENGTH' '' '' C_NO '' 'Extra Length' '' '' '',
           'ZZALIAS' '' '' C_NO '' 'Tipe Alias' '' '' '',
           'ZZLABEL' '' '' C_NO '' 'Tipe Label' '' '' '',
           'DEXDT' '' '' C_NO '' 'Expired Date' '' '' '',
           'ERSDA' '' '' C_NO '' 'Production Date' '' '' '',
           'PDATE' '' '' C_NO '' 'GR Date' '' '' '',
           'STCH1' '' '' C_NO '40' 'Special Touch-1' '' '' '',
           'LICHA' '' '' C_NO '12' 'Vendor Batch' '' '' ''.

    IF P_TYB = 'X'.
      PERFORM F_ALV_FIELDCATG_WT_ZERO USING 'IT_ZBMBC' :
         'TYBRL' '' '' C_NO '20' 'No Rol Toyobo' '' '' '',
         'TYBLT' '' '' C_NO '20' 'No Lot Toyobo' '' '' '',
         'TYBPS' '' '' C_NO '5' 'Posisi' '' '' '',
         'TYBCT' '' '' C_NO '5' 'Kategori' '' '' '',
         'TYBCOMBNO' '' '' C_NO '25' 'Comb. No.' '' '' ''.
    ENDIF.

    IF P_KTNG = 'X'.
      PERFORM F_ALV_FIELDCATG  USING 'IT_ZBMBC' :
             'VKTNG' '' '' C_NO '25' 'No KTNG' '' '' ''.
    ENDIF.

    IF P_ACTWGT = 'X'.
      PERFORM F_ALV_FIELDCATG  USING 'IT_ZBMBC' :
             'AWEIGHT' '' '' C_NO '15' 'Actual Weight' '' '' '',
             'ALENGTH' '' '' C_NO '15' 'Actual Length' '' '' '',
             'ACORE' '' '' C_NO '15' 'Act core weight' '' '' ''.
    ENDIF.

    T_SORT-FIELDNAME = 'MATNR'.
    APPEND T_SORT.
  ENDFORM.                    " BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
  FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
    DATA: LS_LINE TYPE SLIS_LISTHEADER.

    CLEAR LS_LINE.
    REFRESH LT_TOP_OF_PAGE.
    LS_LINE-TYP  = 'H'.
    LS_LINE-INFO = 'Report Stock Overview with Characteristic'.
    APPEND LS_LINE TO LT_TOP_OF_PAGE.
  ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT_BOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
  FORM LAYOUT_INIT_BOX USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
    RS_LAYOUT-DETAIL_POPUP      = 'X'.
    RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
    RS_LAYOUT-ZEBRA             = 'X'.
    RS_LAYOUT-INFO_FIELDNAME     = 'BOX'.
*rs_layout-no_totalline      = 'X'.
  ENDFORM.                    "LAYOUT_INIT_BOX

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
  FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
    DATA : LS_EVENT TYPE SLIS_ALV_EVENT.
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
      EXPORTING
        I_LIST_TYPE = 0
      IMPORTING
        ET_EVENTS   = RT_EVENTS.

    READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                              INTO LS_EVENT.

    IF SY-SUBRC = 0.
      MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
      APPEND LS_EVENT TO RT_EVENTS.
    ENDIF.
  ENDFORM.                    "EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM TOP_OF_PAGE.
    CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
      EXPORTING
        I_LOGO             = ' '
        IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
  ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  GT_CUR_LEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZMATNR     text
*      -->ZCHARG     text
*      -->ZCURLEN    text
*----------------------------------------------------------------------*
  FORM GT_CUR_LEN USING ZMATNR ZCHARG CHANGING ZCURLEN.
    DATA : DOBJECTID TYPE CDHDR-OBJECTID,
           DTABKEY TYPE CDPOS-TABKEY,
           DCURLEN TYPE CDPOS-VALUE_NEW,
           OCURLEN TYPE CDPOS-VALUE_NEW,
           NCURLEN TYPE F,
           PCURLEN TYPE P,
           DCHAR TYPE STRING,
           DINITIAL TYPE BOOLEAN.

    TYPES :
     BEGIN OF TYPES_ZMCH1,
      MATNR LIKE MCH1-MATNR,
      CHARG LIKE MCH1-CHARG,
      OBJBM LIKE MCH1-CUOBJ_BM,
      OBJID LIKE CDHDR-OBJECTID,
      CHANGENR LIKE CDHDR-CHANGENR,
      UDATE TYPE CDHDR-UDATE,
      UTIME TYPE CDHDR-UTIME,
    END OF TYPES_ZMCH1.

    DATA : ZMCH1 TYPE STANDARD TABLE OF TYPES_ZMCH1 WITH HEADER LINE.

    FIELD-SYMBOLS : <FS_ZMCH1> LIKE LINE OF ZMCH1.

    SELECT MATNR CHARG CUOBJ_BM AS OBJBM
      INTO CORRESPONDING FIELDS OF TABLE ZMCH1
    FROM MCH1
      WHERE MATNR = ZMATNR AND
            CHARG = ZCHARG.

    LOOP AT ZMCH1 ASSIGNING <FS_ZMCH1>.
      CONCATENATE <FS_ZMCH1>-OBJBM 'O' INTO <FS_ZMCH1>-OBJID.
      SELECT SINGLE CHANGENR UDATE UTIME OBJECTID
        INTO (<FS_ZMCH1>-CHANGENR, <FS_ZMCH1>-UDATE, <FS_ZMCH1>-UTIME,<FS_ZMCH1>-OBJID)
      FROM CDHDR
        WHERE OBJECTCLAS = 'CLASSIFY' AND
              OBJECTID = ZMCH1-OBJID.
    ENDLOOP.

    SORT ZMCH1 DESCENDING BY UDATE UTIME.

    READ TABLE ZMCH1 INDEX 1 ASSIGNING <FS_ZMCH1>.
    IF SY-SUBRC = 0.
      CLEAR DTABKEY.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          INPUT  = 'ZZLENGTH'
        IMPORTING
          OUTPUT = DCHAR.

      CONCATENATE <FS_ZMCH1>-OBJBM DCHAR '001O' INTO DTABKEY.
      SELECT SINGLE VALUE_NEW VALUE_OLD
        INTO (DCURLEN,OCURLEN)
      FROM CDPOS
        WHERE OBJECTCLAS = 'CLASSIFY' AND
              CHANGENR = <FS_ZMCH1>-CHANGENR AND
              OBJECTID = <FS_ZMCH1>-OBJID AND
              TABNAME = 'ABAUSP' AND
              TABKEY = DTABKEY AND
              FNAME = 'ATFLV'.

      IF DCURLEN IS INITIAL.
        DINITIAL = 'X'.
      ENDIF.
      MOVE DCURLEN TO NCURLEN.
    ENDIF.
    PCURLEN = NCURLEN.
    IF PCURLEN = 0.
      MOVE OCURLEN TO NCURLEN.
      PCURLEN = NCURLEN.
    ENDIF.

    IF DINITIAL = 'X'.
      CLEAR ZCURLEN.
    ELSE.
      ZCURLEN = PCURLEN.
    ENDIF.

  ENDFORM.                    "GT_CUR_LEN

*&---------------------------------------------------------------------*
*&      Form  GT_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZMATNR     text
*      -->ZCHARG     text
*      -->ZCHAR      text
*      -->ZVALUE     text
*----------------------------------------------------------------------*
  FORM GT_CHAR USING ZMATNR ZCHARG ZCHAR CHANGING ZVALUE.
    DATA : DOBJ LIKE MCH1-CUOBJ_BM,
           DATINN LIKE AUSP-ATINN.

    SELECT SINGLE CUOBJ_BM INTO DOBJ
      FROM MCH1
    WHERE MATNR = ZMATNR AND
          CHARG = ZCHARG.

    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = ZCHAR
      IMPORTING
        OUTPUT = DATINN.
  ENDFORM.                    "GT_CHAR


*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&
*&---------------------------------------------------------------------*
  FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                            FU_SELFIELD TYPE SLIS_SELFIELD.
    DATA: LT_HUS TYPE HUM_VENUM_T.

    SY-LSIND = 0.
    CASE FU_UCOMM.
      WHEN '&IC1'.
        CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
          EXPORTING
            TCODE  = 'ZHUMO'
          EXCEPTIONS
            OK     = 1
            NOT_OK = 2
            OTHERS = 3.
        IF SY-SUBRC > 1.
          MESSAGE I063(VO) WITH 'ZHUMO'.
        ELSE.

          CLEAR : BDC_DATA.
          REFRESH : BDC_DATA.
          READ TABLE IT_ZBMBC INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_ITEM1>.
          CASE FU_SELFIELD-SEL_TAB_FIELD.
            WHEN 'IT_ZBMBC-HUPLT'.
              IF <FS_ITEM1>-HUPLT NE ' '.
                BDC_DYNPRO  BDC_DATA 'RHU_HELP' '1000'.
                BDC_FIELD   BDC_DATA 'BDC_OKCODE' '=ONLI'.
                BDC_FIELD   BDC_DATA 'BDC_CURSOR' 'SELEXIDV-LOW'.
                BDC_FIELD   BDC_DATA 'SELEXIDV-LOW' <FS_ITEM1>-HUPLT.
                CALL TRANSACTION 'ZHUMO' USING BDC_DATA MODE 'E'.
              ENDIF.
          ENDCASE.
        ENDIF.
    ENDCASE.
  ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM INSERT_SQL.
** -- bagus yang ubah 3-1-12
    TRY.
        EXEC SQL.
          DELETE FROM XZBMBC
        ENDEXEC.

        EXEC SQL.
          COMMIT WORK
        ENDEXEC.

      CATCH CX_SY_NATIVE_SQL_ERROR.
        MESSAGE 'Error in procedure delete' TYPE 'I'.
    ENDTRY.

    TRY .
        LOOP AT IT_ZBMBC. "ASSIGNING <FS_ZBMBC>.
          EXEC SQL.
            INSERT INTO XZBMBC(COL001,COL002,COL003,COL004,COL005,COL006,COL007,COL008,COL009,COL010,COL011,COL012,COL013,
              COL014,COL015,COL016,COL017, COL018,COL019,COL020,COL021,COL022,COL023,COL024,COL025,COL026,COL027,COL028,
              COL029,COL030,COL031,COL032,COL033,COL034,COL035,COL036,COL037)
            VALUES (:IT_ZBMBC-MATNR, :IT_ZBMBC-WERKS, :IT_ZBMBC-LGORT, :IT_ZBMBC-CHARG, :IT_ZBMBC-SOBKZ,
              :IT_ZBMBC-LGPLA, :IT_ZBMBC-VBELN, :IT_ZBMBC-POSNR, :IT_ZBMBC-AUART, :IT_ZBMBC-HUBOX, :IT_ZBMBC-HUPLT,
              :IT_ZBMBC-ZZTYPE, :IT_ZBMBC-ZZTHICKNESS, :IT_ZBMBC-ZZWIDTH,
              :IT_ZBMBC-ZZLENGTH , :IT_ZBMBC-ZZCORE, :IT_ZBMBC-ZZCRITERIA , :IT_ZBMBC-ZZPACKING , :IT_ZBMBC-ZZNOMORROLL, :IT_ZBMBC-ZZTREATMENT,
              :IT_ZBMBC-LABST, :IT_ZBMBC-LROLL, :IT_ZBMBC-INSME, :IT_ZBMBC-IROLL, :IT_ZBMBC-SPEME, :IT_ZBMBC-BROLL,
              :IT_ZBMBC-BEZEI, :IT_ZBMBC-NAME1, :IT_ZBMBC-ZZSPLICE_1 , :IT_ZBMBC-ZZSPLICE_2 , :IT_ZBMBC-ZZSPLICE_3 , :IT_ZBMBC-ZZEXLENGTH ,
              :IT_ZBMBC-ZZALIAS, :IT_ZBMBC-ZZLABEL, :IT_ZBMBC-DEXDT, :IT_ZBMBC-ERSDA, :IT_ZBMBC-PDATE)
          ENDEXEC.
        ENDLOOP.

        EXEC SQL.
          COMMIT WORK
        ENDEXEC.

      CATCH CX_SY_NATIVE_SQL_ERROR.
        MESSAGE `Error in procedure insert` TYPE 'I'.
    ENDTRY.

    EXEC SQL.
      DISCONNECT :SAP_CON
    ENDEXEC.

    REFRESH IT_ZBMBC.

  ENDFORM.                    "INSERT_SQL
*&---------------------------------------------------------------------*
*&      Form  CHECK_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM CHECK_WERKS .
    CLEAR : VON, TVALUES. REFRESH  : TVALUES.
    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        USER_NAME           = SY-UNAME
        SEL_OBJECT          = 'Z_WERKS'
      TABLES
        VALUES              = TVALUES
      EXCEPTIONS
        USER_NAME_NOT_EXIST = 1
        NOT_AUTHORIZED      = 2
        INTERNAL_ERROR      = 3.

    READ TABLE TVALUES INDEX 1.
    VON = TVALUES-VON.

    CHECK VON NE '*'.


    READ TABLE S_WERKS WITH KEY LOW = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_WERKS. REFRESH : S_WERKS.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      S_WERKS-SIGN   = 'I'.
      S_WERKS-OPTION = 'EQ'.
      S_WERKS-LOW    = VON.
      APPEND S_WERKS.
      RETURN.
    ELSE.

      READ TABLE S_WERKS WITH KEY HIGH = '*'.
      IF SY-SUBRC = 0.
        CLEAR : S_WERKS. REFRESH : S_WERKS.
        MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
        S_WERKS-SIGN   = 'I'.
        S_WERKS-OPTION = 'EQ'.
        S_WERKS-LOW    = VON.
        APPEND S_WERKS.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT S_WERKS.
      IF S_WERKS-LOW NE ''.
        AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-LOW.
        IF SY-SUBRC NE 0.
          MESSAGE 'No Authorization to process data' TYPE 'E'.
          CLEAR : S_WERKS. REFRESH : S_WERKS.
          RETURN.
        ENDIF.
      ENDIF.
      IF S_WERKS-HIGH NE ''.
        AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-HIGH.
        IF SY-SUBRC NE 0.
          MESSAGE 'No Authorization to process data' TYPE 'E'.
          CLEAR : S_WERKS. REFRESH : S_WERKS.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDFORM.                    " CHECK_WERKS
*&---------------------------------------------------------------------*
*&      Form  CHECK_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM CHECK_LGORT .
    CLEAR : VON, TVALUES. REFRESH  : TVALUES.
    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        USER_NAME           = SY-UNAME
        SEL_OBJECT          = 'Z_LGORT'
      TABLES
        VALUES              = TVALUES
      EXCEPTIONS
        USER_NAME_NOT_EXIST = 1
        NOT_AUTHORIZED      = 2
        INTERNAL_ERROR      = 3.

    READ TABLE TVALUES WITH KEY VON = '*'.
    IF SY-SUBRC = 0.
      RETURN.
    ENDIF.


    READ TABLE S_LGORT WITH KEY LOW = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_LGORT. REFRESH : S_LGORT.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      LOOP AT TVALUES.
        S_LGORT-SIGN   = 'I'.
        S_LGORT-OPTION = 'EQ'.
        S_LGORT-LOW    = TVALUES-VON.
        APPEND S_LGORT.
      ENDLOOP.
      RETURN.
    ELSE.

      READ TABLE S_LGORT WITH KEY HIGH = '*'.
      IF SY-SUBRC = 0.
        CLEAR : S_LGORT. REFRESH : S_LGORT.
        MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
        LOOP AT TVALUES.
          S_LGORT-SIGN   = 'I'.
          S_LGORT-OPTION = 'EQ'.
          S_LGORT-LOW    = TVALUES-VON.
          APPEND S_LGORT.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT S_LGORT.
      IF S_LGORT-LOW NE ''.
        AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-LOW.
        IF SY-SUBRC NE 0.
          MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
          CLEAR : S_LGORT-LOW.
          MODIFY S_LGORT.
        ENDIF.
      ENDIF.
      IF S_LGORT-HIGH NE ''.
        AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-HIGH.
        IF SY-SUBRC NE 0.
          MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
          CLEAR : S_LGORT-HIGH.
          MODIFY S_LGORT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDFORM.                    " CHECK_LGORT


*&---------------------------------------------------------------------*
*&      Form  get_toyobo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_TOYOBO.
    DATA: VX_ATNROL LIKE CABN-ATINN,
        VX_ATNUOM LIKE CABN-ATINN,
        VX_ROLNO LIKE AUSP-ATWRT,
        VX_UOM LIKE AUSP-ATWRT,
        VX_MATNR_JR LIKE MCH1-MATNR,
        VX_CHARG_JR LIKE MCH1-CHARG.

    SELECT SINGLE ATINN INTO VX_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
    SELECT SINGLE ATINN INTO VX_ATNUOM FROM CABN WHERE ATNAM = 'ZZUNITOFMEASURE'.

    LOOP AT IT_ZBMBC ASSIGNING <FS_ZBMBC>.
      CLEAR: VX_ROLNO,VX_MATNR_JR,VX_CHARG_JR,VX_UOM.

      SELECT SINGLE  AUSP~ATWRT AS ATWRT
        FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
        JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
        INTO <FS_ZBMBC>-TYBLT
      WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR
      AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG
        AND   CABN~ATNAM = 'ZZNOLOTTOYOBO'.

      SELECT SINGLE  AUSP~ATWRT AS ATWRT
        FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
        JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
        INTO <FS_ZBMBC>-TYBRL
      WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR
      AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG
        AND   CABN~ATNAM = 'ZZNOROLLTOYOBO'.

      SELECT SINGLE  AUSP~ATWRT AS ATWRT
        FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
        JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
        INTO <FS_ZBMBC>-STCH1
      WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR
      AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG
        AND   CABN~ATNAM = 'ZZSPECIALTOUCH-1'.

      SELECT SINGLE  AUSP~ATWRT AS ATWRT
        FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
        JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
        INTO <FS_ZBMBC>-TYBCT
      WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR
      AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG
        AND   CABN~ATNAM = 'ZZTAILORED'.

*- position L/C/R
      SELECT SINGLE  AUSP~ATWRT INTO VX_ROLNO
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE MCH1~MATNR = <FS_ZBMBC>-MATNR AND MCH1~CHARG = <FS_ZBMBC>-CHARG AND AUSP~ATINN = VX_ATNROL.

      VX_ROLNO = VX_ROLNO+0(13).

      SELECT SINGLE MCH1~MATNR MCH1~CHARG INTO (VX_MATNR_JR, VX_CHARG_JR)
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE AUSP~ATINN = VX_ATNROL AND AUSP~KLART = '023' AND AUSP~ATWRT = VX_ROLNO.

      IF SY-SUBRC = 0.
        SELECT SINGLE  AUSP~ATWRT INTO <FS_ZBMBC>-TYBPS   "VX_UOM
          FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
          WHERE MCH1~MATNR = VX_MATNR_JR AND MCH1~CHARG = VX_CHARG_JR AND AUSP~ATINN = VX_ATNUOM.
      ENDIF.
    ENDLOOP.

  ENDFORM.                    "get_toyobo

*&---------------------------------------------------------------------*
*&      Form  set_atinn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM SET_ATINN.
    SELECT SINGLE ATINN INTO V_ZZTYPE FROM CABN WHERE ATNAM = 'ZZTYPE'.
    SELECT SINGLE ATINN INTO V_ZZTHICKNESS FROM CABN WHERE ATNAM = 'ZZTHICKNESS'.
    SELECT SINGLE ATINN INTO V_ZZWIDTH FROM CABN WHERE ATNAM = 'ZZWIDTH'.
    SELECT SINGLE ATINN INTO V_ZZLENGTH FROM CABN WHERE ATNAM = 'ZZLENGTH'.
    SELECT SINGLE ATINN INTO V_ZZNOMORROLL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
    SELECT SINGLE ATINN INTO V_ZZSPLICE-1 FROM CABN WHERE ATNAM = 'ZZSPLICE-1'.
    SELECT SINGLE ATINN INTO V_ZZSPLICE-2 FROM CABN WHERE ATNAM = 'ZZSPLICE-2'.
    SELECT SINGLE ATINN INTO V_ZZSPLICE-3 FROM CABN WHERE ATNAM = 'ZZSPLICE-3'.
    SELECT SINGLE ATINN INTO V_ZZALIAS FROM CABN WHERE ATNAM = 'ZZALIAS'.
    SELECT SINGLE ATINN INTO V_ZZEXLENGTH FROM CABN WHERE ATNAM = 'ZZEXLENGTH'.
    SELECT SINGLE ATINN INTO V_ZZEXPIREDLIVE FROM CABN WHERE ATNAM = 'ZZEXPIREDLIVE'.
    SELECT SINGLE ATINN INTO V_ZZLENGTH FROM CABN WHERE ATNAM = 'ZZLENGTH'.
    SELECT SINGLE ATINN INTO V_ZZCORE FROM CABN WHERE ATNAM = 'ZZCORE'.
    SELECT SINGLE ATINN INTO V_ZZCRITERIA FROM CABN WHERE ATNAM = 'ZZCRITERIA'.
    SELECT SINGLE ATINN INTO V_ZZPACKING FROM CABN WHERE ATNAM = 'ZZPACKING'.
    SELECT SINGLE ATINN INTO V_ZZTREATMENT FROM CABN WHERE ATNAM = 'ZZTREATMENT'.
    SELECT SINGLE ATINN INTO V_ZZLABEL FROM CABN WHERE ATNAM = 'ZZLABEL'.
    SELECT SINGLE ATINN INTO V_ZZGRADE FROM CABN WHERE ATNAM = 'ZZGRADE'.
    SELECT SINGLE ATINN INTO V_ZZPACKCODE FROM CABN WHERE ATNAM = 'ZZPACKINGCODE'.  "ADDED BY FATHIR ON 20.07.2020 - get Internal No ZZPACKINGCODE, tuning
    SELECT SINGLE ATINN INTO V_ZZCOMBNO FROM CABN WHERE ATNAM = 'ZZTYBCOMBINATIONNO'. "ADDED FOR AGS BY FATHIR ON 31.02.2021 - Combination No
  ENDFORM.                    "set_atinn

*&---------------------------------------------------------------------*
*&      Form  GET_KTNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_KTNG.
    DATA: IT_KTNG LIKE ZDETAIL_KTNG.

    LOOP AT IT_ZBMBC ASSIGNING <FS_ZBMBC>.
      CLEAR IT_KTNG.
      SELECT SINGLE * INTO IT_KTNG FROM ZDETAIL_KTNG WHERE BATCH EQ <FS_ZBMBC>-CHARG
             AND SONUM EQ <FS_ZBMBC>-VBELN AND SOITEM EQ <FS_ZBMBC>-POSNR AND DELETION EQ ''. "Added by AKBAR 18.12.2019 (KT&G case SO to SO)
      CONCATENATE IT_KTNG-KTNGCODE '-' IT_KTNG-COMPANY '-' IT_KTNG-JRDATE '-' IT_KTNG-JRNUMB '-'
                  IT_KTNG-MIDROLL '-' IT_KTNG-SLITT_MCHN '-' IT_KTNG-TS '-' IT_KTNG-PS INTO <FS_ZBMBC>-VKTNG.
    ENDLOOP.
  ENDFORM.                    "GET_KTNG


*&---------------------------------------------------------------------*
*&      Form  GET_ACTUAL_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_ACTUAL_WEIGHT.
    DATA: V_ATINN LIKE CABN-ATINN,
          STOUCH3 LIKE AUSP-ATWRT,
          V_CHAR1(20), V_CHAR2(20), V_CHAR3(20), V_NUM1 TYPE P.

    SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZSPECIALTOUCH-3'.
    LOOP AT IT_ZBMBC.
      SELECT SINGLE A~ATWRT INTO STOUCH3
        FROM AUSP AS A JOIN MCH1 AS B ON A~OBJEK = B~CUOBJ_BM
         WHERE B~CHARG = IT_ZBMBC-CHARG AND A~ATINN = '0000000850'.
      IF SY-SUBRC = 0.
        SPLIT STOUCH3 AT '-' INTO V_CHAR1 V_CHAR2 V_CHAR3.
        IF V_CHAR1 CO '0123456789. '.
          IT_ZBMBC-ALENGTH = V_CHAR1.
        ELSE.
          IT_ZBMBC-ALENGTH = 0.
        ENDIF.

        IF V_CHAR2 CO '0123456789. '.
          IT_ZBMBC-AWEIGHT = V_CHAR2.
        ELSE.
          IT_ZBMBC-AWEIGHT = 0.
        ENDIF.

        IF V_CHAR3 CO '0123456789. '.
          IT_ZBMBC-ACORE = V_CHAR3.
        ELSE.
          IT_ZBMBC-ACORE = 0.
        ENDIF.

        MODIFY IT_ZBMBC.
      ENDIF.
    ENDLOOP.
  ENDFORM.                    "get_actual_weight

*&---------------------------------------------------------------------*
*&      Form  F_GETCOREID
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR ON 20.07.2020
*       Get Core ID untuk batch yang ditemukan (RTP Core)
*----------------------------------------------------------------------*
  FORM F_GETCOREID.

    RANGES: R_COREVAL FOR ZMAPP_RTP-CHAR_VALUE.
    DATA: IT_CORE LIKE TABLE OF ZMAPP_RTP WITH HEADER LINE.
    DATA: IT_COREMD LIKE TABLE OF ZCORER WITH HEADER LINE.

    DATA: V_STATUS TYPE ZCORER-STATUS,
          V_CHARG TYPE ZCORER-CHARG,
          V_COREID TYPE ZCORER-COREID,
          V_SEQNO TYPE ZCORER-SEQNO,
          V_TEMPCHARG TYPE MCH1-CHARG.

    IF LINES( IT_ZBMBC ) > 0.      "Added By: J. Budi on 28.01.2019

      " isi ranges CHAR VALUE yang berisi 'C' (Core)
      " untuk parameter query
      R_COREVAL-SIGN = 'I'.
      R_COREVAL-OPTION = 'CP'.
      R_COREVAL-LOW = '*C*'.
      APPEND R_COREVAL.

      " get Char Value CORE
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_CORE
        FROM ZMAPP_RTP
        WHERE CATEGORY = 'ZZPACKINGCODE'
          AND CHAR_VALUE IN R_COREVAL.

      IF SY-SUBRC <> 0.
        EXIT.
      ENDIF.

      " get Master Data COREID
      SELECT COREID
             STATUS
        INTO CORRESPONDING FIELDS OF TABLE IT_COREMD
        FROM ZCORER
        WHERE CHARG = 'MASTER'.

      IF SY-SUBRC <> 0.
        EXIT.
      ENDIF.

      " get Core ID hanya jika ZZPACKINGCODE terisi
      SORT IT_ZBMBC BY CHARG ASCENDING ZZPACKINGCODE DESCENDING.
      LOOP AT IT_ZBMBC WHERE ZZPACKINGCODE NE ''.

        CLEAR: V_STATUS, V_CHARG, V_COREID, V_SEQNO.

        " jika batch yang sama sudah diproses, maka CONTINUE
        IF IT_ZBMBC-CHARG = V_TEMPCHARG.
          CONTINUE.
        ENDIF.
        V_TEMPCHARG = IT_ZBMBC-CHARG.

        " cek penggunaan RTP Core
        " jika ZZPACKINGCODE tidak menggunakan RTP Core, maka CONTINUE
        READ TABLE IT_CORE WITH KEY INT_CHAR = IT_ZBMBC-ZZPACKINGCODE.
        IF SY-SUBRC <> 0.
          CONTINUE.
        ENDIF.

        " get Sequence RTP Core
        SELECT MAX( SEQNO ) INTO V_SEQNO FROM ZCORER WHERE CHARG = IT_ZBMBC-CHARG.
        IF SY-SUBRC <> 0.
          CONTINUE.
        ENDIF.

        " get Core ID
        SELECT SINGLE COREID INTO V_COREID FROM ZCORER WHERE SEQNO = V_SEQNO.
        IF SY-SUBRC <> 0.
          CONTINUE.
        ENDIF.

        " get status RTP Core
        READ TABLE IT_COREMD WITH KEY COREID = V_COREID.
        IF SY-SUBRC <> 0.
          CONTINUE.
        ENDIF.

        IF IT_COREMD-STATUS = 'B' OR IT_COREMD-STATUS = 'R' OR IT_COREMD-STATUS = 'C'.
          CLEAR V_SEQNO.

          " get Sequence RTP Core
          SELECT MAX( SEQNO ) INTO V_SEQNO FROM ZCORER WHERE COREID = V_COREID.
          IF SY-SUBRC <> 0.
            CONTINUE.
          ENDIF.

          " get Batch
          SELECT SINGLE CHARG INTO V_CHARG FROM ZCORER WHERE SEQNO = V_SEQNO.
          IF SY-SUBRC <> 0.
            CONTINUE.
          ENDIF.

          IT_ZBMBC-COREID = V_COREID.
          MODIFY IT_ZBMBC TRANSPORTING COREID WHERE CHARG = V_CHARG.
        ENDIF.

        CLEAR V_STATUS.
        CLEAR V_CHARG.
        CLEAR V_COREID.
        CLEAR V_SEQNO.
      ENDLOOP.

    ENDIF.

  ENDFORM.                    "F_GETCOREID