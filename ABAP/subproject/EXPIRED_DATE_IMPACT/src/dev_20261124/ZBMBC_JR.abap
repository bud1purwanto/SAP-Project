*&---------------------------------------------------------------------*
*& Report  ZBMBC_JR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBMBC_JR.

INCLUDE ZABAPALV.
INCLUDE ZOLAP.
INCLUDE Z_PROG_INFO.             "Program Documentation

TABLES : MCHB,MARA,MSKA,CAWN,AUFK,LIPS, VBAK.

DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
FIELD-SYMBOLS : <FS_CHAR> LIKE LINE OF IT_CHAR.
DATA : ATFLV1 TYPE P LENGTH 5 DECIMALS 1,
       ATFLV2 TYPE P LENGTH 9.

DATA: V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZBAP_STOCK_BY_CHAR'.

*DATA : BEGIN OF IT_ZBMBC OCCURS 0,
TYPES :
  BEGIN OF TYPES_ZBMBC,
   MATNR LIKE MCHB-MATNR,
   WERKS LIKE MCHB-WERKS,
   LGORT LIKE MCHB-LGORT,
   CHARG LIKE MCHB-CHARG,
   SOBKZ LIKE MSKA-SOBKZ,
   VBELN LIKE MSKA-VBELN,
   POSNR LIKE MSKA-POSNR,
   AUART LIKE VBAK-AUART,
   LGPLA LIKE LEIN-LGPLA,
   HUBOX LIKE VEKP-EXIDV,
   HUPLT LIKE VEKP-EXIDV,
   LABST TYPE P DECIMALS 3,
   LROLL TYPE I,
   INSME TYPE P  DECIMALS 3,
   IROLL TYPE I,
   SPEME TYPE P  DECIMALS 3,
   BROLL TYPE I,
   BEZEI LIKE TVAGT-BEZEI,
   NAME1 LIKE KNA1-NAME1,

**    new
     ZZTYPE(50),
     ZZTHICKNESS TYPE P LENGTH  5 DECIMALS 1,
     ZZWIDTH TYPE P LENGTH  9 DECIMALS 0,
     ZZLENGTH  TYPE P LENGTH 9 DECIMALS 0,
     ZZCORE(50),
     ZZCRITERIA(50),
     ZZPACKING(50),
     ZZNOMORROLL(50),
     ZZTREATMENT(50),
     ZZSPLICE_1 TYPE P LENGTH 9 DECIMALS 0,
     ZZSPLICE_2 TYPE P LENGTH 9 DECIMALS 0,
     ZZSPLICE_3 TYPE P LENGTH 9 DECIMALS 0,
     ZZALIAS(50),
     ZZLABEL(50),
     ZZEXLENGTH TYPE P LENGTH 9 DECIMALS 0,
     ZZEXPIREDLIVE TYPE P LENGTH 9 DECIMALS 0,
**

   DEXDT TYPE D,
   ERSDA LIKE MCH1-ERSDA,
   DIND(001),
   KALAB LIKE MSKA-KALAB,
   KAINS LIKE MSKA-KAINS,
   KAEIN LIKE MSKA-KAEIN,
   PDATE LIKE MCH1-ERSDA,  "Production data (GR date)
   TYBRL LIKE API_VALI-ATWRT,  " roll toyobo
   TYBLT LIKE API_VALI-ATWRT,  " lot toyobo
   STCH1 LIKE API_VALI-ATWRT,  "Special touch-1
END OF TYPES_ZBMBC.

TYPES :
 BEGIN OF TYPES_F4 ,
  CHARV LIKE CAWN-ATWRT,
  CHARD LIKE CAWNT-ATWTB,
END OF TYPES_F4.

TYPES :
  BEGIN OF TYPES_COLLECT ,
   MATNR LIKE MSKU-MATNR,
   WERKS LIKE MSKU-WERKS,
   CHARG LIKE MSKU-CHARG,
   SOBKZ LIKE MSKU-SOBKZ,
   LGORT LIKE MSKA-LGORT,
   VBELN LIKE MSKA-VBELN,
   POSNR LIKE MSKA-POSNR,
   LABST TYPE P DECIMALS 3,
   INSME TYPE P DECIMALS 3,
   SPEME TYPE P DECIMALS 3,
   EINME TYPE P DECIMALS 3,
 END OF TYPES_COLLECT.


DEFINE BDC_DYNPRO.
  CLEAR &1.
  &1-PROGRAM = &2.
  &1-DYNPRO = &3.
  &1-DYNBEGIN = 'X'.
  APPEND &1.
END-OF-DEFINITION.

DEFINE BDC_FIELD.
  CLEAR &1.
  &1-FNAM = &2.
  &1-FVAL = &3.
  APPEND &1.
END-OF-DEFINITION.

DATA : IT_ZBMBC TYPE STANDARD TABLE OF TYPES_ZBMBC WITH HEADER LINE,
       IT_F4 TYPE STANDARD TABLE OF TYPES_F4 WITH HEADER LINE,
       IT_COLLECT TYPE STANDARD TABLE OF TYPES_COLLECT WITH HEADER LINE,
       IT_COLLECT2 TYPE STANDARD TABLE OF TYPES_COLLECT WITH HEADER LINE,
       TMP_ZBMBC TYPE STANDARD TABLE OF TYPES_ZBMBC WITH HEADER LINE,
       TMP_COLLECT TYPE STANDARD TABLE OF TYPES_COLLECT WITH HEADER LINE,
       ZVAL TYPE STANDARD TABLE OF API_VALI WITH HEADER LINE,
       ZRETURN TYPE STANDARD TABLE OF BAPIRET2 WITH HEADER LINE,
       ZCHARACT TYPE STANDARD TABLE OF BAPICHARACTVALUESDESCR WITH HEADER LINE,
       IT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.

FIELD-SYMBOLS : <FS_ZBMBC> LIKE LINE OF IT_ZBMBC,
                <FS_F4> LIKE LINE OF IT_F4,
                <FS_COLLECT> LIKE LINE OF IT_COLLECT,
                <FS_TMP_ZBMBC> LIKE LINE OF TMP_ZBMBC,
                <FS_TMP_COLLECT> LIKE LINE OF TMP_COLLECT,
                <FS_ZVAL> LIKE LINE OF ZVAL,
                <FS_ZRETURN> LIKE LINE OF ZRETURN,
                <FS_ZCHARACT> LIKE LINE OF ZCHARACT,
                <FS_RETURN> LIKE LINE OF IT_RETURN.


FIELD-SYMBOLS : <FS_ITEM1> LIKE LINE OF IT_ZBMBC.
DATA : WA_FS_ITEM1 LIKE <FS_ITEM1>.

DATA : BDC_DATA LIKE BDCDATA OCCURS 1000 WITH HEADER LINE.
DATA : TVALUES LIKE USVALUES OCCURS 0 WITH HEADER LINE.


DATA :  JMATNR(2),
        AMATNR TYPE STRING,
        LEN TYPE I,
        R_STRING(100),
        VON TYPE XUVAL,
        DLENG TYPE MSEG-MENGE,
        P_STRING(100).

SELECTION-SCREEN BEGIN OF BLOCK MATR WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT1.
SELECT-OPTIONS: S_MATNR FOR MCHB-MATNR NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT2.
SELECT-OPTIONS : S_WERKS FOR MCHB-WERKS NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT3.
SELECT-OPTIONS : S_LGORT FOR MCHB-LGORT.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT4.
SELECT-OPTIONS : S_CHARG FOR MCHB-CHARG.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT5.
SELECT-OPTIONS : S_VBELN FOR LIPS-KDAUF.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT6.
SELECT-OPTIONS : S_POSNR FOR LIPS-KDPOS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT7.
SELECT-OPTIONS : S_AUART FOR VBAK-AUART.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK MATR.

SELECTION-SCREEN BEGIN OF BLOCK CHAR WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT8.
SELECT-OPTIONS: S_MTART FOR MARA-MTART NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT9.
SELECT-OPTIONS: S_ATWRT1 FOR CAWN-ATWRT NO INTERVALS.   "Type Film
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT10.
SELECT-OPTIONS: S_ATWRT2 FOR CAWN-ATWRT NO INTERVALS.  "Thickness
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT11.
SELECT-OPTIONS: S_ATWRT3 FOR CAWN-ATINN NO INTERVALS. "Width
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT12.
SELECT-OPTIONS: S_ATWRT4 FOR CAWN-ATINN NO INTERVALS.   "Length
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT13.
SELECT-OPTIONS: S_ATWRT5 FOR CAWN-ATINN NO INTERVALS.   "Treatment
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT14.
SELECT-OPTIONS: S_ATWRT6 FOR CAWN-ATWRT NO INTERVALS.   "Core
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK CHAR.

SELECTION-SCREEN BEGIN OF BLOCK OPTI WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT16.
SELECT-OPTIONS: S_SOBKZ FOR MSKA-SOBKZ.
SELECTION-SCREEN END OF LINE.
PARAMETERS: P_ZERO AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK OPTI.

SELECTION-SCREEN BEGIN OF BLOCK EXT WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER LRB1 RADIOBUTTON GROUP LBR.
SELECTION-SCREEN COMMENT 4(20) TXT17 FOR FIELD LRB1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER LRB2 RADIOBUTTON GROUP LBR.
SELECTION-SCREEN COMMENT 4(20) TXT18 FOR FIELD LRB2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK EXT.

SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.


START-OF-SELECTION.
  PERFORM GT_DATA.
  IF LRB1 IS INITIAL.
    PERFORM CONNECT_SQL.
    PERFORM INSERT_SQL.
  ELSEIF LRB2 IS INITIAL.
    PERFORM SET_ALV.
  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_BY_CHAR_F01                           *
*&---------------------------------------------------------------------*

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
  IF S_VBELN IS INITIAL AND S_POSNR IS INITIAL AND S_AUART IS INITIAL.
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
            WERKS IN S_WERKS AND
            LGORT IN S_LGORT AND
            CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            MTART IN S_MTART AND
         ( CLABS > 0 OR CINSM > 0 OR CEINM > 0 OR CSPEM > 0 ).

      CLEAR: TMP_ZBMBC.
      REFRESH: TMP_ZBMBC.
      SELECT DISTINCT MSKA~MATNR
                      WERKS
                      LGORT
                      CHARG
                      SOBKZ
                      MSKA~VBELN
                      MSKA~POSNR
                      AUART
                      KALAB AS LABST
                      KAINS AS INSME
                      KAEIN AS EINME
                      KASPE AS SPEME
*        INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
        APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
      FROM MSKA
        JOIN MARA ON MARA~MATNR = MSKA~MATNR
        JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
      WHERE MSKA~MATNR IN S_MATNR AND
            WERKS IN S_WERKS AND
            LGORT IN S_LGORT AND
            CHARG IN S_CHARG AND
            CHARG NE '' AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            MTART IN S_MTART AND
            ( KALAB > 0 OR KAINS > 0 OR KAEIN > 0 OR KASPE > 0 ).

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
            WERKS IN S_WERKS AND
            LGORT IN S_LGORT AND
            CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            MTART IN S_MTART.

      CLEAR: TMP_ZBMBC.
      REFRESH: TMP_ZBMBC.
      SELECT DISTINCT MSKA~MATNR
                      WERKS
                      LGORT
                      CHARG
                      SOBKZ
                      MSKA~VBELN
                      MSKA~POSNR
                      AUART
                      KALAB AS LABST
                      KAINS AS INSME
                      KAEIN AS EINME
                      KASPE AS SPEME
*        INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
        APPENDING CORRESPONDING FIELDS OF TABLE IT_ZBMBC
      FROM MSKA
        JOIN MARA ON MARA~MATNR = MSKA~MATNR
        JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
      WHERE MSKA~MATNR IN S_MATNR AND
            WERKS IN S_WERKS AND
            LGORT IN S_LGORT AND
            CHARG IN S_CHARG AND
            CHARG NE '' AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            MTART IN S_MTART.
    ENDIF.    "p_zero

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

    CLEAR: TMP_ZBMBC.
    REFRESH: TMP_ZBMBC.
    SELECT DISTINCT MSKU~MATNR
                    WERKS
                    CHARG
                    SOBKZ
                    KULAB AS LABST
                    KUINS AS INSME
                    KUEIN AS EINME
      INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
    FROM MSKU
      JOIN MARA ON MARA~MATNR = MSKU~MATNR
    WHERE SOBKZ IN S_SOBKZ AND
          MSKU~MATNR IN S_MATNR AND
          WERKS IN S_WERKS AND
          CHARG IN S_CHARG AND
*          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
          MTART IN ('ZFGS','ZSFG') AND
          MTART IN S_MTART.

    APPEND LINES OF TMP_ZBMBC TO IT_ZBMBC.

    DELETE ADJACENT DUPLICATES FROM IT_ZBMBC COMPARING ALL FIELDS.

  ELSE.

    SELECT DISTINCT MSKA~MATNR
                    WERKS
                    LGORT
                    CHARG
                    SOBKZ
                    MSKA~VBELN
                    POSNR
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
            WERKS IN S_WERKS AND
            LGORT IN S_LGORT AND
            CHARG IN S_CHARG AND
            MSKA~VBELN IN S_VBELN AND
            POSNR IN S_POSNR AND
            AUART IN S_AUART AND
            MTART IN S_MTART AND
*           MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            MTART IN ('ZFGS','ZSFG') AND
            SOBKZ IN S_SOBKZ.
  ENDIF.

*  COLLECT ALL CATEGORY####################################################
  IF LINES( IT_ZBMBC ) > 0.

  ENDIF.

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
      CALL FUNCTION 'ZCHARACTERISTICS'
        EXPORTING
          I_VAL_MATNR  = <FS_ZBMBC>-MATNR
          I_VAL_CHARGE = <FS_ZBMBC>-CHARG
        TABLES
          T_VAL_TAB    = IT_CHAR
        EXCEPTIONS
          NO_OBJECT    = 1
          NO_VALUES    = 2
          T_L_E1       = 3
          T_L_E2       = 4.
      IF SY-SUBRC EQ '0'.
        "- Tipe
        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZTYPE =  <FS_CHAR>-ATWRT.
*          TRANSLATE <FS_ZBMBC>-ZZTYPE TO UPPER CASE.
        ENDIF.

        "- Thickness
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTHICKNESS'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV1.
          MOVE  ATFLV1 TO <FS_ZBMBC>-ZZTHICKNESS .
*          TRANSLATE <FS_ZBMBC>-ZZTHICKNESS TO UPPER CASE.
        ENDIF.

        "- Width
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH'   ASSIGNING <FS_CHAR> .
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZWIDTH =  ATFLV2.
*          TRANSLATE <FS_ZBMBC>-ZZWIDTH TO UPPER CASE.
        ENDIF.

        "- Length
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZLENGTHSHT'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
        ELSE.
          READ TABLE  IT_CHAR WITH  KEY ATNAM = 'ZZLENGTH'   ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
*            TRANSLATE <FS_ZBMBC>-ZZLENGTH TO UPPER CASE.
          ENDIF.
        ENDIF.


        "- Core.
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCORE'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZCORE =  <FS_CHAR>-ATWTB.
*          TRANSLATE <FS_ZBMBC>-ZZCORE TO UPPER CASE.
        ENDIF.

        "- Criteria Grade
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCRITERIA'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZCRITERIA =  <FS_CHAR>-ATWTB.
        ENDIF.

        "- Sistem Packing
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZPACKING'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZPACKING =  <FS_CHAR>-ATWTB.
        ENDIF.

        "- Roll Number
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZNOMORROLL'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZNOMORROLL =  <FS_CHAR>-ATWRT.
        ENDIF.

        "- Treatment
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTREATMENT'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZTREATMENT =  <FS_CHAR>-ATWTB.
*          TRANSLATE <FS_ZBMBC>-ZZTREATMENT TO UPPER CASE.
        ENDIF.

        "- Splice-1
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-1'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZSPLICE_1 =  ATFLV2.
        ENDIF.

        "- Splice-2
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-2'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZSPLICE_2 =  ATFLV2.
        ENDIF.

        "- Splice-3
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-3'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZSPLICE_3 =  ATFLV2.
        ENDIF.

        "- Alias
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZALIAS'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZALIAS =  <FS_CHAR>-ATWRT.
        ENDIF.

        "- Label
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZLABEL'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
*          <FS_ZBMBC>-ZZLABEL =  <FS_CHAR>-ATWTB.
          <FS_ZBMBC>-ZZLABEL =  <FS_CHAR>-ATWRT.
        ENDIF.

        "- Extra Length
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXLENGTH'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZEXLENGTH =  ATFLV2.
        ENDIF.

        "- Expired Live
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXPIREDLIVE'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZEXPIREDLIVE =  ATFLV2.
        ENDIF.

        "- toyobo
        PERFORM GET_TOYOBO.
      ENDIF.
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

  SORT IT_ZBMBC BY MATNR WERKS LGORT CHARG.

  LOOP AT IT_ZBMBC.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = IT_ZBMBC-MATNR
        CHARG = IT_ZBMBC-CHARG
      IMPORTING
        PDATE = IT_ZBMBC-PDATE.

    MODIFY IT_ZBMBC.
  ENDLOOP.
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
      I_CALLBACK_USER_COMMAND  = '' "'F_USER_COMMAND'
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
         'SOBKZ' '' '' C_NO '' 'Special Stock' '' '' '',
         'LGPLA' '' '' C_NO '' 'Storage Bin' '' '' ''.

  PERFORM F_ALV_FIELDCATG  USING 'IT_ZBMBC' :
         'VBELN' '' '' C_NO '' 'SO No' '' '' '',
         'POSNR' '' '' C_NO '' 'SO Item' '' '' '',
         'AUART' '' '' C_NO '' 'Sales Doc Type' '' '' '',
         'HUBOX' '' '' C_NO '' 'HU Box' '' '' '',
         'HUPLT' '' '' C_NO '' 'HU Pallet' '' '' ''.

  PERFORM F_ALV_FIELDCATG_WT_ZERO USING 'IT_ZBMBC' :
         'ZZTYPE' '' '' C_NO '' 'Type' '' '' '',
         'ZZTHICKNESS' '' '' C_NO '' 'Thick' '' '' 'RIGHT',
         'ZZWIDTH' '' '' C_NO '' 'Width' '' '' 'RIGHT',
*         'ZZCLEN' '' '' C_NO '' 'Length' '' '' 'RIGHT',
         'ZZLENGTH' '' '' C_NO '' 'Length' '' '' 'RIGHT',
         'ZZCORE' '' '' C_NO '' 'Core' '' '' '',
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
         'TYBRL' '' '' C_NO '20' 'No Rol Toyobo' '' '' '',
         'TYBLT' '' '' C_NO '20' 'No Lot Toyobo' '' '' '',
         'STCH1' '' '' C_NO '40' 'Special Touch-1' '' '' ''.

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
*FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
*                          FU_SELFIELD TYPE SLIS_SELFIELD.
*  DATA: LT_HUS TYPE HUM_VENUM_T.
*
*  SY-LSIND = 0.
*  CASE FU_UCOMM.
*    WHEN '&IC1'.
*      CLEAR : BDC_DATA.
*      REFRESH : BDC_DATA.
*      READ TABLE IT_ZBMBC INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_ITEM1>.
*      CASE FU_SELFIELD-SEL_TAB_FIELD.
*        WHEN 'IT_ZBMBC-HUPLT'.
*          IF <FS_ITEM1>-HUPLT NE ' '.
*            BDC_DYNPRO  BDC_DATA 'RHU_HELP' '1000'.
*            BDC_FIELD   BDC_DATA 'BDC_OKCODE' '=ONLI'.
*            BDC_FIELD   BDC_DATA 'BDC_CURSOR' 'SELEXIDV-LOW'.
*            BDC_FIELD   BDC_DATA 'SELEXIDV-LOW' <FS_ITEM1>-HUPLT.
*            CALL TRANSACTION 'ZHUMO' USING BDC_DATA MODE 'E'.
*          ENDIF.
*      ENDCASE.
*
*  ENDCASE.
*ENDFORM.                    "F_USER_COMMAND

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
*  DATA: CUOBJ_BM LIKE MCH1-CUOBJ_BM.   "get char toyobo
*
*  SELECT SINGLE CUOBJ_BM INTO CUOBJ_BM
*  FROM MCH1
*  WHERE MCH1~MATNR  = <FS_ZBMBC>-MATNR
*  AND   MCH1~CHARG  = <FS_ZBMBC>-CHARG.

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
ENDFORM.                    "get_toyobo

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT1-LOW.
  PERFORM GT_LST_CHAR USING 'ZZCODE' CHANGING S_ATWRT1-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT5-LOW.
  PERFORM GT_LST_CHAR USING 'ZZTREATMENT' CHANGING S_ATWRT5-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT6-LOW.
  PERFORM GT_LST_CHAR USING 'ZZCORE' CHANGING S_ATWRT6-LOW.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ATWRT8.
*  PERFORM GT_LST_CHAR USING 'I/O' CHANGING S_ATWRT8.

INITIALIZATION.
  TXT1 = 'Material'.
  TXT2 = 'Plant'.
  TXT3 = 'Storage Location'.
  TXT4 = 'Batch'.
  TXT5 = 'SO Number'.
  TXT6 = 'SO Item'.
  TXT7 = 'Sales Doc Type'.

  TXT8 = 'Material Type'.
  TXT9 = 'Type Film'.
  TXT10 = 'Thickness/Tebal'.
  TXT11 = 'Width/Lebar'.
  TXT12 = 'Length/Panjang'.
  TXT13 = 'Treatment'.
  TXT14 = 'Core'.
*TXT15 = 'Inhouse/Outsource'.

  TXT16 = 'Special stock indicator'.
  TXT17 = 'Screen'.
  TXT18 = 'OLAP'.
  MOVE 'Program Information' TO INFO. "DOCUMENTATION

  "DOCUMENTATION*************************

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.
*  *************************************

  IF SY-UCOMM = 'ONLI'.
    PERFORM CHECK_WERKS .
    PERFORM CHECK_LGORT .
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'LRB2'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*--- XXXXXXX------

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