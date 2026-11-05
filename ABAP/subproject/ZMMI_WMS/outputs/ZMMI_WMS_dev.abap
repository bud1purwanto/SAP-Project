*&---------------------------------------------------------------------*
*& Report  ZMMI_WMS
*&---------------------------------------------------------------------*
* Description      : HU Stock with Characteristic for WMS
*                    Flow : HU (VEKP Created On + Matl Grp Pckmat)
*                           -> HU Box / HU Pallet -> Batch
*                           -> Stock (MCHB / MSKA) -> Characteristic
*                    Output : ALV / WMS (MSSQL staging Y_ZBMBCSR + SP)
*                    Reference flow : ZBMBC (ZBAP_STOCK_BY_CHAR)
*
* Application Area - MM
* ABAPer           - Budi (generate by AI)
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date       | abaper | Description                             *
* 001 | 30.10.2026 | Budi   | Initial version (generate by AI)        *
*----------------------------------------------------------------------*
REPORT ZMMI_WMS.

TABLES : VEKP.

TYPES : BEGIN OF TY_HU,
          VENUM  TYPE VEKP-VENUM,
          EXIDV  TYPE VEKP-EXIDV,
          MAGRV  TYPE VEKP-MAGRV,
          UEVEL  TYPE VEKP-UEVEL,
          STATUS TYPE VEKP-STATUS,
        END OF TY_HU,
        BEGIN OF TY_VENUM,
          VENUM TYPE VEKP-VENUM,
        END OF TY_VENUM,
        TY_T_VENUM TYPE STANDARD TABLE OF TY_VENUM WITH DEFAULT KEY,
        BEGIN OF TY_VEPO,
          VENUM TYPE VEPO-VENUM,
          VEPOS TYPE VEPO-VEPOS,
          VELIN TYPE VEPO-VELIN,
          UNVEL TYPE VEPO-UNVEL,
          MATNR TYPE VEPO-MATNR,
          CHARG TYPE VEPO-CHARG,
          WERKS TYPE VEPO-WERKS,
        END OF TY_VEPO,
        BEGIN OF TY_CONT,
          MATNR TYPE MCHB-MATNR,
          WERKS TYPE MCHB-WERKS,
          CHARG TYPE MCHB-CHARG,
          HUBOX TYPE VEKP-EXIDV,
          HUPLT TYPE VEKP-EXIDV,
        END OF TY_CONT,
        BEGIN OF TY_KEY,
          MATNR TYPE MCHB-MATNR,
          WERKS TYPE MCHB-WERKS,
          CHARG TYPE MCHB-CHARG,
        END OF TY_KEY,
        BEGIN OF TY_MATNR,
          MATNR TYPE MARA-MATNR,
        END OF TY_MATNR,
        BEGIN OF TY_MCHB,
          MATNR TYPE MCHB-MATNR,
          WERKS TYPE MCHB-WERKS,
          LGORT TYPE MCHB-LGORT,
          CHARG TYPE MCHB-CHARG,
          CLABS TYPE MCHB-CLABS,
          CINSM TYPE MCHB-CINSM,
          CEINM TYPE MCHB-CEINM,
          CSPEM TYPE MCHB-CSPEM,
        END OF TY_MCHB,
        BEGIN OF TY_MSKA,
          MATNR TYPE MSKA-MATNR,
          WERKS TYPE MSKA-WERKS,
          LGORT TYPE MSKA-LGORT,
          CHARG TYPE MSKA-CHARG,
          SOBKZ TYPE MSKA-SOBKZ,
          VBELN TYPE MSKA-VBELN,
          POSNR TYPE MSKA-POSNR,
          KALAB TYPE MSKA-KALAB,
          KAINS TYPE MSKA-KAINS,
          KAEIN TYPE MSKA-KAEIN,
          KASPE TYPE MSKA-KASPE,
        END OF TY_MSKA,
        BEGIN OF TY_VBELN,
          VBELN TYPE VBAK-VBELN,
        END OF TY_VBELN,
        BEGIN OF TY_VBAK,
          VBELN TYPE VBAK-VBELN,
          AUART TYPE VBAK-AUART,
        END OF TY_VBAK,
        BEGIN OF TY_VBPA,
          VBELN TYPE VBPA-VBELN,
          POSNR TYPE VBPA-POSNR,
          ADRNR TYPE VBPA-ADRNR,
        END OF TY_VBPA,
        BEGIN OF TY_ADRNR,
          ADDRNUMBER TYPE ADRC-ADDRNUMBER,
        END OF TY_ADRNR,
        BEGIN OF TY_ADRC,
          ADDRNUMBER TYPE ADRC-ADDRNUMBER,
          NATION     TYPE ADRC-NATION,
          NAME1      TYPE ADRC-NAME1,
        END OF TY_ADRC,
        BEGIN OF TY_MSKU,
          MATNR TYPE MSKU-MATNR,
          WERKS TYPE MSKU-WERKS,
          CHARG TYPE MSKU-CHARG,
          SOBKZ TYPE MSKU-SOBKZ,
          KUNNR TYPE MSKU-KUNNR,
        END OF TY_MSKU,
        BEGIN OF TY_KUNNR,
          KUNNR TYPE KNA1-KUNNR,
        END OF TY_KUNNR,
        BEGIN OF TY_KNA1,
          KUNNR TYPE KNA1-KUNNR,
          NAME1 TYPE KNA1-NAME1,
        END OF TY_KNA1,
        BEGIN OF TY_LQUA,
          MATNR TYPE LQUA-MATNR,
          WERKS TYPE LQUA-WERKS,
          CHARG TYPE LQUA-CHARG,
          LGPLA TYPE LQUA-LGPLA,
        END OF TY_LQUA,
        BEGIN OF TY_MCH1,
          MATNR    TYPE MCH1-MATNR,
          CHARG    TYPE MCH1-CHARG,
          CUOBJ_BM TYPE MCH1-CUOBJ_BM,
        END OF TY_MCH1,
        BEGIN OF TY_OBJ,
          MATNR TYPE MCH1-MATNR,
          CHARG TYPE MCH1-CHARG,
          OBJEK TYPE AUSP-OBJEK,
        END OF TY_OBJ,
        BEGIN OF TY_OBJEK,
          OBJEK TYPE AUSP-OBJEK,
        END OF TY_OBJEK,
        BEGIN OF TY_AUSP,
          OBJEK TYPE AUSP-OBJEK,
          ATINN TYPE AUSP-ATINN,
          ATWRT TYPE AUSP-ATWRT,
          ATFLV TYPE AUSP-ATFLV,
        END OF TY_AUSP,
        BEGIN OF TY_DESC,
          ATINN TYPE CAWN-ATINN,
          ATWRT TYPE CAWN-ATWRT,
          ATWTB TYPE CAWNT-ATWTB,
        END OF TY_DESC,
        BEGIN OF TY_CABN,
          ATINN TYPE CABN-ATINN,
          ATNAM TYPE CABN-ATNAM,
        END OF TY_CABN,
        BEGIN OF TY_OUT,
          WERKS       TYPE MCHB-WERKS,
          MATNR       TYPE MCHB-MATNR,
          ZZTYPE(50)  TYPE C,
          ZZTHICKNESS TYPE P LENGTH 5 DECIMALS 1,
          CHARG       TYPE MCHB-CHARG,
          ZZWIDTH     TYPE P LENGTH 9 DECIMALS 0,
          ZZLENGTH    TYPE P LENGTH 9 DECIMALS 0,
          ZZALIAS(50) TYPE C,
          ZZCRITERIA(50) TYPE C,
          LGORT       TYPE MCHB-LGORT,
          LGPLA       TYPE LQUA-LGPLA,
          VBELN       TYPE MSKA-VBELN,
          POSNR       TYPE MSKA-POSNR,
          AUART       TYPE VBAK-AUART,
          HUBOX       TYPE VEKP-EXIDV,
          HUPLT       TYPE VEKP-EXIDV,
          NAME1       TYPE KNA1-NAME1,
          SOBKZ       TYPE MSKA-SOBKZ,
          LABST       TYPE MCHB-CLABS,
          INSME       TYPE MCHB-CINSM,
          EINME       TYPE MCHB-CEINM,
          SPEME       TYPE MCHB-CSPEM,
        END OF TY_OUT.

CONSTANTS : GC_BOX     TYPE VEKP-MAGRV  VALUE 'BOX',
            GC_PLT     TYPE VEKP-MAGRV  VALUE 'PLT',
            GC_DELETED TYPE VEKP-STATUS VALUE '0060',
            GC_VELIN_M TYPE VEPO-VELIN  VALUE '1',   " material item
            GC_VELIN_H TYPE VEPO-VELIN  VALUE '3'.   " lower level HU

DATA : GT_HU    TYPE STANDARD TABLE OF TY_HU,
       GT_VEPO  TYPE STANDARD TABLE OF TY_VEPO,
       GT_CONT  TYPE STANDARD TABLE OF TY_CONT,
       GT_MCHB  TYPE STANDARD TABLE OF TY_MCHB,
       GT_MSKA  TYPE STANDARD TABLE OF TY_MSKA,
       GT_VBAK  TYPE STANDARD TABLE OF TY_VBAK,
       GT_VBPA  TYPE STANDARD TABLE OF TY_VBPA,
       GT_ADRC  TYPE STANDARD TABLE OF TY_ADRC,
       GT_MSKU  TYPE STANDARD TABLE OF TY_MSKU,
       GT_KNA1  TYPE STANDARD TABLE OF TY_KNA1,
       GT_LQUA  TYPE STANDARD TABLE OF TY_LQUA,
       GT_OBJ   TYPE STANDARD TABLE OF TY_OBJ,
       GT_AUSP  TYPE STANDARD TABLE OF TY_AUSP,
       GT_DESC  TYPE STANDARD TABLE OF TY_DESC,
       GT_OUT   TYPE STANDARD TABLE OF TY_OUT,
       GS_OUT   TYPE TY_OUT.

DATA : V_ZZTYPE      TYPE CABN-ATINN,
       V_ZZTHICKNESS TYPE CABN-ATINN,
       V_ZZWIDTH     TYPE CABN-ATINN,
       V_ZZLENGTH    TYPE CABN-ATINN,
       V_ZZALIAS     TYPE CABN-ATINN,
       V_ZZCRITERIA  TYPE CABN-ATINN.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK HU WITH FRAME TITLE TXT_B1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT1 FOR FIELD S_ERDAT.
SELECT-OPTIONS: S_ERDAT FOR VEKP-ERDAT DEFAULT SY-DATUM.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT7 FOR FIELD S_EXIDV.
SELECT-OPTIONS: S_EXIDV FOR VEKP-EXIDV.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT2 FOR FIELD S_MAGRV.
SELECT-OPTIONS: S_MAGRV FOR VEKP-MAGRV OBLIGATORY NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT3 FOR FIELD S_WERKS.
SELECT-OPTIONS: S_WERKS FOR VEKP-WERKS NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK HU.

SELECTION-SCREEN BEGIN OF BLOCK EXT WITH FRAME TITLE TXT_B2.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER P_ALV RADIOBUTTON GROUP LBR USER-COMMAND AC DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(20) TXT4 FOR FIELD P_ALV.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER P_WMS RADIOBUTTON GROUP LBR.
SELECTION-SCREEN COMMENT 4(20) TXT5 FOR FIELD P_WMS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (23) TXT6 FOR FIELD P_CONN MODIF ID CON.
PARAMETERS: P_CONN LIKE DBCON-CON_NAME MODIF ID CON.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK EXT.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  TXT_B1 = 'Handling Unit'.
  TXT_B2 = 'Execution Type'.
  TXT1   = 'Created On'.
  TXT2   = 'Matl Grp Pckmat'.
  TXT3   = 'Plant'.
  TXT4   = 'ALV'.
  TXT5   = 'WMS'.
  TXT6   = 'DBCO Name'.
  TXT7   = 'HU Number'.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P_WMS'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'CON'.
      IF P_WMS = 'X'.
        SCREEN-INPUT  = 1.
        SCREEN-ACTIVE = 1.
      ELSE.
        SCREEN-INPUT  = 0.
        SCREEN-ACTIVE = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  LOOP AT S_WERKS.
    AUTHORITY-CHECK OBJECT 'Z_WERKS'
    ID 'ZWERKS' FIELD S_WERKS-LOW.
    IF SY-SUBRC NE 0.
      MESSAGE 'No Authorization' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  " Created On / HU Number: minimal 1 terisi (hindari full scan VEKP)
  IF S_ERDAT[] IS INITIAL AND S_EXIDV[] IS INITIAL.
    MESSAGE 'Isi Created On atau HU Number...!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF P_WMS = 'X' AND P_CONN IS INITIAL.
    MESSAGE 'Masukan DBCO Connection name...!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM GT_HU.
  PERFORM GT_STOCK.
  PERFORM GT_OUTPUT.

  IF GT_OUT[] IS INITIAL.
    MESSAGE 'No data found' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM GT_PRELOAD.
  PERFORM GT_FILL.
  PERFORM GT_FREE.

  IF P_WMS = 'X'.
    PERFORM INSERT_SQL_WMS.
  ELSE.
    PERFORM SET_ALV.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  GT_HU
*&---------------------------------------------------------------------*
*       HU by Created On -> lower level (HU Box) & higher level (Pallet)
*----------------------------------------------------------------------*
FORM GT_HU.
  DATA : LT_VENUM TYPE TY_T_VENUM,
         LS_VENUM TYPE TY_VENUM,
         LS_VEPO  TYPE TY_VEPO,
         LS_HU    TYPE TY_HU,
         LS_UP    TYPE TY_HU,
         LS_CONT  TYPE TY_CONT.
  FIELD-SYMBOLS : <LS_HU> TYPE TY_HU.

  REFRESH : GT_HU, GT_VEPO, GT_CONT.

  " MAGRV filtered in memory (faster than VEKP~Z04 MAGRV)
  IF S_EXIDV[] IS NOT INITIAL.
    " HU Number: index VEKP~C (MANDT EXIDV), Created On as filter
    SELECT VENUM EXIDV MAGRV UEVEL STATUS
      INTO TABLE GT_HU
      FROM VEKP
     WHERE EXIDV IN S_EXIDV
       AND ERDAT IN S_ERDAT
      %_HINTS ORACLE 'INDEX("VEKP" "VEKP~C")'
              ORACLE '&max_in_blocking_factor 100&'.
  ELSE.
    " Extension index VEKP~Z02 (MANDT ERDAT) by Created On
    SELECT VENUM EXIDV MAGRV UEVEL STATUS
      INTO TABLE GT_HU
      FROM VEKP
     WHERE ERDAT IN S_ERDAT
      %_HINTS ORACLE 'INDEX("VEKP" "VEKP~Z02")'.
  ENDIF.
  DELETE GT_HU WHERE MAGRV NOT IN S_MAGRV.
  DELETE GT_HU WHERE STATUS = GC_DELETED.
  CHECK GT_HU[] IS NOT INITIAL.
  SORT GT_HU BY VENUM.

  " Content of selected HU
  LOOP AT GT_HU ASSIGNING <LS_HU>.
    CLEAR LS_VENUM.
    LS_VENUM-VENUM = <LS_HU>-VENUM.
    APPEND LS_VENUM TO LT_VENUM.
  ENDLOOP.
  PERFORM READ_VEPO USING LT_VENUM.

  " Lower level HU (HU Box inside Pallet) not yet selected
  REFRESH LT_VENUM.
  LOOP AT GT_VEPO INTO LS_VEPO WHERE VELIN = GC_VELIN_H.
    IF LS_VEPO-UNVEL IS INITIAL.
      CONTINUE.
    ENDIF.
    READ TABLE GT_HU TRANSPORTING NO FIELDS
         WITH KEY VENUM = LS_VEPO-UNVEL BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CLEAR LS_VENUM.
      LS_VENUM-VENUM = LS_VEPO-UNVEL.
      APPEND LS_VENUM TO LT_VENUM.
    ENDIF.
  ENDLOOP.
  SORT LT_VENUM BY VENUM.
  DELETE ADJACENT DUPLICATES FROM LT_VENUM COMPARING VENUM.
  PERFORM READ_VEKP USING LT_VENUM.
  PERFORM READ_VEPO USING LT_VENUM.

  " Higher level HU (Pallet of HU Box) not yet selected
  REFRESH LT_VENUM.
  LOOP AT GT_HU ASSIGNING <LS_HU>.
    IF <LS_HU>-UEVEL IS INITIAL.
      CONTINUE.
    ENDIF.
    READ TABLE GT_HU TRANSPORTING NO FIELDS
         WITH KEY VENUM = <LS_HU>-UEVEL BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CLEAR LS_VENUM.
      LS_VENUM-VENUM = <LS_HU>-UEVEL.
      APPEND LS_VENUM TO LT_VENUM.
    ENDIF.
  ENDLOOP.
  SORT LT_VENUM BY VENUM.
  DELETE ADJACENT DUPLICATES FROM LT_VENUM COMPARING VENUM.
  PERFORM READ_VEKP USING LT_VENUM.
  FREE LT_VENUM.

  " HU number display format (same as ZBMBC)
  LOOP AT GT_HU ASSIGNING <LS_HU>.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_HU>-EXIDV
      IMPORTING
        OUTPUT = <LS_HU>-EXIDV.
  ENDLOOP.

  " Batch content -> HU Box / HU Pallet
  LOOP AT GT_VEPO INTO LS_VEPO WHERE VELIN = GC_VELIN_M.
    IF LS_VEPO-MATNR IS INITIAL OR LS_VEPO-CHARG IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR LS_HU.
    READ TABLE GT_HU INTO LS_HU
         WITH KEY VENUM = LS_VEPO-VENUM BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    CLEAR LS_CONT.
    LS_CONT-MATNR = LS_VEPO-MATNR.
    LS_CONT-WERKS = LS_VEPO-WERKS.
    LS_CONT-CHARG = LS_VEPO-CHARG.
    IF LS_HU-MAGRV = GC_BOX.
      LS_CONT-HUBOX = LS_HU-EXIDV.
      IF LS_HU-UEVEL IS NOT INITIAL.
        CLEAR LS_UP.
        READ TABLE GT_HU INTO LS_UP
             WITH KEY VENUM = LS_HU-UEVEL BINARY SEARCH.
        IF SY-SUBRC = 0 AND LS_UP-MAGRV = GC_PLT.
          LS_CONT-HUPLT = LS_UP-EXIDV.
        ENDIF.
      ENDIF.
    ELSEIF LS_HU-MAGRV = GC_PLT.
      LS_CONT-HUPLT = LS_HU-EXIDV.
    ELSE.
      CONTINUE.
    ENDIF.
    APPEND LS_CONT TO GT_CONT.
  ENDLOOP.

  IF S_WERKS[] IS NOT INITIAL.
    DELETE GT_CONT WHERE WERKS NOT IN S_WERKS.
  ENDIF.
  SORT GT_CONT BY MATNR WERKS CHARG HUBOX HUPLT.
  DELETE ADJACENT DUPLICATES FROM GT_CONT COMPARING ALL FIELDS.

  FREE : GT_HU, GT_VEPO.
ENDFORM.                    "GT_HU

*&---------------------------------------------------------------------*
*&      Form  READ_VEPO
*&---------------------------------------------------------------------*
*       HU item (VEPO~0: MANDT VENUM VEPOS)
*----------------------------------------------------------------------*
FORM READ_VEPO USING UT_VENUM TYPE TY_T_VENUM.
  DATA : LT_VEPO TYPE STANDARD TABLE OF TY_VEPO.

  CHECK UT_VENUM[] IS NOT INITIAL.
  SELECT VENUM VEPOS VELIN UNVEL MATNR CHARG WERKS
    INTO TABLE LT_VEPO
    FROM VEPO
     FOR ALL ENTRIES IN UT_VENUM
   WHERE VENUM = UT_VENUM-VENUM
    %_HINTS ORACLE 'INDEX("VEPO" "VEPO~0")'
            ORACLE '&max_blocking_factor 100&'.
  APPEND LINES OF LT_VEPO TO GT_VEPO.
  FREE LT_VEPO.
ENDFORM.                    "READ_VEPO

*&---------------------------------------------------------------------*
*&      Form  READ_VEKP
*&---------------------------------------------------------------------*
*       HU header by number (VEKP~0: MANDT VENUM)
*----------------------------------------------------------------------*
FORM READ_VEKP USING UT_VENUM TYPE TY_T_VENUM.
  DATA : LT_HU TYPE STANDARD TABLE OF TY_HU.

  CHECK UT_VENUM[] IS NOT INITIAL.
  SELECT VENUM EXIDV MAGRV UEVEL STATUS
    INTO TABLE LT_HU
    FROM VEKP
     FOR ALL ENTRIES IN UT_VENUM
   WHERE VENUM = UT_VENUM-VENUM
    %_HINTS ORACLE 'INDEX("VEKP" "VEKP~0")'
            ORACLE '&max_blocking_factor 100&'.
  DELETE LT_HU WHERE STATUS = GC_DELETED.
  APPEND LINES OF LT_HU TO GT_HU.
  SORT GT_HU BY VENUM.
  FREE LT_HU.
ENDFORM.                    "READ_VEKP

*&---------------------------------------------------------------------*
*&      Form  GT_STOCK
*&---------------------------------------------------------------------*
*       Stock of HU batch, Sloc & SO follow last stock (same as ZBMBC)
*----------------------------------------------------------------------*
FORM GT_STOCK.
  DATA : LT_KEY   TYPE STANDARD TABLE OF TY_KEY,
         LS_KEY   TYPE TY_KEY,
         LT_MATNR TYPE STANDARD TABLE OF TY_MATNR,
         LS_MATNR TYPE TY_MATNR,
         LT_MARA  TYPE STANDARD TABLE OF TY_MATNR.
  FIELD-SYMBOLS : <LS_CONT> TYPE TY_CONT.

  REFRESH : GT_MCHB, GT_MSKA.
  CHECK GT_CONT[] IS NOT INITIAL.

  LOOP AT GT_CONT ASSIGNING <LS_CONT>.
    CLEAR : LS_KEY, LS_MATNR.
    LS_KEY-MATNR   = <LS_CONT>-MATNR.
    LS_KEY-WERKS   = <LS_CONT>-WERKS.
    LS_KEY-CHARG   = <LS_CONT>-CHARG.
    APPEND LS_KEY TO LT_KEY.
    LS_MATNR-MATNR = <LS_CONT>-MATNR.
    APPEND LS_MATNR TO LT_MATNR.
  ENDLOOP.
  SORT LT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING MATNR.

  " Material type same as ZBMBC (MARA~0: MANDT MATNR)
  IF LT_MATNR[] IS NOT INITIAL.
    SELECT MATNR
      INTO TABLE LT_MARA
      FROM MARA
       FOR ALL ENTRIES IN LT_MATNR
     WHERE MATNR = LT_MATNR-MATNR
       AND MTART IN ('ZFGS','ZSFG')
      %_HINTS ORACLE 'INDEX("MARA" "MARA~0")'
              ORACLE '&max_in_blocking_factor 100&&max_blocking_factor 100&'.
  ENDIF.
  FREE LT_MATNR.
  SORT LT_MARA BY MATNR.

  LOOP AT LT_KEY INTO LS_KEY.
    READ TABLE LT_MARA TRANSPORTING NO FIELDS
         WITH KEY MATNR = LS_KEY-MATNR BINARY SEARCH.
    IF SY-SUBRC <> 0.
      DELETE LT_KEY.
    ENDIF.
  ENDLOOP.
  FREE LT_MARA.
  SORT LT_KEY BY MATNR WERKS CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING MATNR WERKS CHARG.

  CHECK LT_KEY[] IS NOT INITIAL.

  " Free stock (MCHB~Z05: MANDT MATNR WERKS CHARG LGORT)
  SELECT MATNR WERKS LGORT CHARG CLABS CINSM CEINM CSPEM
    INTO TABLE GT_MCHB
    FROM MCHB
     FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND WERKS = LT_KEY-WERKS
     AND CHARG = LT_KEY-CHARG
     AND ( CLABS > 0 OR CINSM > 0 OR CEINM > 0 OR CSPEM > 0 )
    %_HINTS ORACLE 'INDEX("MCHB" "MCHB~Z05")'
            ORACLE '&max_blocking_factor 100&'.

  " Sales order stock (MSKA~Z02: MANDT MATNR CHARG WERKS LGORT)
  SELECT MATNR WERKS LGORT CHARG SOBKZ VBELN POSNR KALAB KAINS KAEIN KASPE
    INTO TABLE GT_MSKA
    FROM MSKA
     FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND CHARG = LT_KEY-CHARG
     AND WERKS = LT_KEY-WERKS
     AND ( KALAB > 0 OR KAINS > 0 OR KAEIN > 0 OR KASPE > 0 )
    %_HINTS ORACLE 'INDEX("MSKA" "MSKA~Z02")'
            ORACLE '&max_blocking_factor 100&'.

  FREE LT_KEY.
ENDFORM.                    "GT_STOCK

*&---------------------------------------------------------------------*
*&      Form  GT_OUTPUT
*&---------------------------------------------------------------------*
*       1 row per stock line x HU content
*----------------------------------------------------------------------*
FORM GT_OUTPUT.
  DATA : LS_MCHB TYPE TY_MCHB,
         LS_MSKA TYPE TY_MSKA,
         LS_STK  TYPE TY_OUT.

  REFRESH GT_OUT.
  SORT GT_CONT BY MATNR WERKS CHARG.

  LOOP AT GT_MCHB INTO LS_MCHB.
    CLEAR LS_STK.
    LS_STK-MATNR = LS_MCHB-MATNR.
    LS_STK-WERKS = LS_MCHB-WERKS.
    LS_STK-LGORT = LS_MCHB-LGORT.
    LS_STK-CHARG = LS_MCHB-CHARG.
    LS_STK-LABST = LS_MCHB-CLABS.
    LS_STK-INSME = LS_MCHB-CINSM.
    LS_STK-EINME = LS_MCHB-CEINM.
    LS_STK-SPEME = LS_MCHB-CSPEM.
    PERFORM ADD_OUT USING LS_STK.
  ENDLOOP.

  LOOP AT GT_MSKA INTO LS_MSKA.
    CLEAR LS_STK.
    LS_STK-MATNR = LS_MSKA-MATNR.
    LS_STK-WERKS = LS_MSKA-WERKS.
    LS_STK-LGORT = LS_MSKA-LGORT.
    LS_STK-CHARG = LS_MSKA-CHARG.
    LS_STK-SOBKZ = LS_MSKA-SOBKZ.
    LS_STK-VBELN = LS_MSKA-VBELN.
    LS_STK-POSNR = LS_MSKA-POSNR.
    LS_STK-LABST = LS_MSKA-KALAB.
    LS_STK-INSME = LS_MSKA-KAINS.
    LS_STK-EINME = LS_MSKA-KAEIN.
    LS_STK-SPEME = LS_MSKA-KASPE.
    PERFORM ADD_OUT USING LS_STK.
  ENDLOOP.

  FREE : GT_MCHB, GT_MSKA, GT_CONT.
  SORT GT_OUT BY MATNR WERKS LGORT CHARG.
ENDFORM.                    "GT_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  ADD_OUT
*&---------------------------------------------------------------------*
FORM ADD_OUT USING US_STK TYPE TY_OUT.
  DATA : LS_CONT  TYPE TY_CONT,
         LS_OUT   TYPE TY_OUT,
         LV_TABIX TYPE SY-TABIX.

  READ TABLE GT_CONT TRANSPORTING NO FIELDS
       WITH KEY MATNR = US_STK-MATNR WERKS = US_STK-WERKS CHARG = US_STK-CHARG
       BINARY SEARCH.
  CHECK SY-SUBRC = 0.
  LV_TABIX = SY-TABIX.

  LOOP AT GT_CONT INTO LS_CONT FROM LV_TABIX.
    IF LS_CONT-MATNR <> US_STK-MATNR OR LS_CONT-WERKS <> US_STK-WERKS
       OR LS_CONT-CHARG <> US_STK-CHARG.
      EXIT.
    ENDIF.
    LS_OUT       = US_STK.
    LS_OUT-HUBOX = LS_CONT-HUBOX.
    LS_OUT-HUPLT = LS_CONT-HUPLT.
    APPEND LS_OUT TO GT_OUT.
  ENDLOOP.
ENDFORM.                    "ADD_OUT

*&---------------------------------------------------------------------*
*&      Form  GT_PRELOAD
*&---------------------------------------------------------------------*
*       Mass select once before loop (like ZPPR_BARRIER_PROD_LIST)
*----------------------------------------------------------------------*
FORM GT_PRELOAD.
  DATA : LT_KEY    TYPE STANDARD TABLE OF TY_KEY,
         LS_KEY    TYPE TY_KEY,
         LT_VBELN  TYPE STANDARD TABLE OF TY_VBELN,
         LS_VBELN  TYPE TY_VBELN,
         LT_ADRNR  TYPE STANDARD TABLE OF TY_ADRNR,
         LS_ADRNR  TYPE TY_ADRNR,
         LT_KUNNR  TYPE STANDARD TABLE OF TY_KUNNR,
         LS_KUNNR  TYPE TY_KUNNR,
         LT_MCH1   TYPE STANDARD TABLE OF TY_MCH1,
         LS_MCH1   TYPE TY_MCH1,
         LT_OBJEK  TYPE STANDARD TABLE OF TY_OBJEK,
         LS_OBJEK  TYPE TY_OBJEK,
         LS_OBJ    TYPE TY_OBJ,
         LT_CABN   TYPE STANDARD TABLE OF TY_CABN,
         LS_CABN   TYPE TY_CABN,
         LS_VBPA   TYPE TY_VBPA,
         LS_MSKU   TYPE TY_MSKU.
  FIELD-SYMBOLS : <LS_OUT> TYPE TY_OUT.

  REFRESH : GT_VBAK, GT_VBPA, GT_ADRC, GT_MSKU, GT_KNA1, GT_LQUA,
            GT_OBJ, GT_AUSP, GT_DESC.

  " Key from output
  LOOP AT GT_OUT ASSIGNING <LS_OUT>.
    CLEAR LS_KEY.
    LS_KEY-MATNR = <LS_OUT>-MATNR.
    LS_KEY-WERKS = <LS_OUT>-WERKS.
    LS_KEY-CHARG = <LS_OUT>-CHARG.
    APPEND LS_KEY TO LT_KEY.
    IF <LS_OUT>-VBELN IS NOT INITIAL.
      CLEAR LS_VBELN.
      LS_VBELN-VBELN = <LS_OUT>-VBELN.
      APPEND LS_VBELN TO LT_VBELN.
    ENDIF.
  ENDLOOP.
  DELETE LT_KEY WHERE MATNR IS INITIAL OR CHARG IS INITIAL.
  SORT LT_KEY BY MATNR WERKS CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING MATNR WERKS CHARG.
  SORT LT_VBELN BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_VBELN COMPARING VBELN.

  " Sales Doc Type (VBAK~0: MANDT VBELN)
  IF LT_VBELN[] IS NOT INITIAL.
    SELECT VBELN AUART
      INTO TABLE GT_VBAK
      FROM VBAK
       FOR ALL ENTRIES IN LT_VBELN
     WHERE VBELN = LT_VBELN-VBELN
      %_HINTS ORACLE 'INDEX("VBAK" "VBAK~0")'
              ORACLE '&max_blocking_factor 100&'.
    SORT GT_VBAK BY VBELN.

    " Sold-to address (VBPA~0: MANDT VBELN POSNR PARVW)
    SELECT VBELN POSNR ADRNR
      INTO TABLE GT_VBPA
      FROM VBPA
       FOR ALL ENTRIES IN LT_VBELN
     WHERE VBELN = LT_VBELN-VBELN
       AND PARVW = 'AG'
      %_HINTS ORACLE 'INDEX("VBPA" "VBPA~0")'
              ORACLE '&max_blocking_factor 100&'.
    SORT GT_VBPA BY VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM GT_VBPA COMPARING VBELN.
  ENDIF.
  FREE LT_VBELN.

  LOOP AT GT_VBPA INTO LS_VBPA.
    IF LS_VBPA-ADRNR IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR LS_ADRNR.
    LS_ADRNR-ADDRNUMBER = LS_VBPA-ADRNR.
    APPEND LS_ADRNR TO LT_ADRNR.
  ENDLOOP.
  SORT LT_ADRNR BY ADDRNUMBER.
  DELETE ADJACENT DUPLICATES FROM LT_ADRNR COMPARING ADDRNUMBER.

  " Customer Name (ADRC~0: CLIENT ADDRNUMBER DATE_FROM NATION)
  IF LT_ADRNR[] IS NOT INITIAL.
    SELECT ADDRNUMBER NATION NAME1
      INTO TABLE GT_ADRC
      FROM ADRC
       FOR ALL ENTRIES IN LT_ADRNR
     WHERE ADDRNUMBER = LT_ADRNR-ADDRNUMBER
      %_HINTS ORACLE 'INDEX("ADRC" "ADRC~0")'
              ORACLE '&max_blocking_factor 100&'.
    SORT GT_ADRC BY ADDRNUMBER NATION.
    DELETE ADJACENT DUPLICATES FROM GT_ADRC COMPARING ADDRNUMBER.
  ENDIF.
  FREE LT_ADRNR.

  CHECK LT_KEY[] IS NOT INITIAL.

  " Customer of consignment stock (MSKU~0: MANDT MATNR WERKS CHARG SOBKZ KUNNR)
  SELECT MATNR WERKS CHARG SOBKZ KUNNR
    INTO TABLE GT_MSKU
    FROM MSKU
     FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND WERKS = LT_KEY-WERKS
     AND CHARG = LT_KEY-CHARG
    %_HINTS ORACLE 'INDEX("MSKU" "MSKU~0")'
            ORACLE '&max_blocking_factor 100&'.
  SORT GT_MSKU BY MATNR WERKS CHARG.
  DELETE ADJACENT DUPLICATES FROM GT_MSKU COMPARING MATNR WERKS CHARG.

  LOOP AT GT_MSKU INTO LS_MSKU.
    CLEAR LS_KUNNR.
    LS_KUNNR-KUNNR = LS_MSKU-KUNNR.
    APPEND LS_KUNNR TO LT_KUNNR.
  ENDLOOP.
  SORT LT_KUNNR BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_KUNNR COMPARING KUNNR.

  " KNA1~0: MANDT KUNNR
  IF LT_KUNNR[] IS NOT INITIAL.
    SELECT KUNNR NAME1
      INTO TABLE GT_KNA1
      FROM KNA1
       FOR ALL ENTRIES IN LT_KUNNR
     WHERE KUNNR = LT_KUNNR-KUNNR
      %_HINTS ORACLE 'INDEX("KNA1" "KNA1~0")'
              ORACLE '&max_blocking_factor 100&'.
    SORT GT_KNA1 BY KUNNR.
  ENDIF.
  FREE LT_KUNNR.

  " Storage Bin (LQUA~Z01: MANDT MATNR WERKS CHARG)
  SELECT MATNR WERKS CHARG LGPLA
    INTO TABLE GT_LQUA
    FROM LQUA
     FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND WERKS = LT_KEY-WERKS
     AND CHARG = LT_KEY-CHARG
    %_HINTS ORACLE 'INDEX("LQUA" "LQUA~Z01")'
            ORACLE '&max_blocking_factor 100&'.
  SORT GT_LQUA BY MATNR WERKS CHARG.

  " Characteristic internal number (CABN~1: MANDT ATNAM DATUV)
  SELECT ATINN ATNAM
    INTO TABLE LT_CABN
    FROM CABN
   WHERE ATNAM IN ('ZZTYPE','ZZTHICKNESS','ZZWIDTH','ZZLENGTH','ZZALIAS','ZZCRITERIA')
    %_HINTS ORACLE 'INDEX("CABN" "CABN~1")'.
  LOOP AT LT_CABN INTO LS_CABN.
    CASE LS_CABN-ATNAM.
      WHEN 'ZZTYPE'.      V_ZZTYPE      = LS_CABN-ATINN.
      WHEN 'ZZTHICKNESS'. V_ZZTHICKNESS = LS_CABN-ATINN.
      WHEN 'ZZWIDTH'.     V_ZZWIDTH     = LS_CABN-ATINN.
      WHEN 'ZZLENGTH'.    V_ZZLENGTH    = LS_CABN-ATINN.
      WHEN 'ZZALIAS'.     V_ZZALIAS     = LS_CABN-ATINN.
      WHEN 'ZZCRITERIA'.  V_ZZCRITERIA  = LS_CABN-ATINN.
    ENDCASE.
  ENDLOOP.
  FREE LT_CABN.

  " Description Char (CAWNT) once
  SELECT CAWNT~ATINN CAWN~ATWRT CAWNT~ATWTB
    INTO TABLE GT_DESC
    FROM CAWN
    JOIN CAWNT ON CAWN~ATINN EQ CAWNT~ATINN AND CAWN~ATZHL EQ CAWNT~ATZHL
   WHERE CAWN~ATINN  EQ V_ZZCRITERIA
     AND CAWNT~SPRAS EQ 'E'.
  SORT GT_DESC BY ATINN ATWRT.

  " Batch Object (MCH1~0: MANDT MATNR CHARG)
  SELECT MATNR CHARG CUOBJ_BM
    INTO TABLE LT_MCH1
    FROM MCH1
     FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND CHARG = LT_KEY-CHARG
    %_HINTS ORACLE 'INDEX("MCH1" "MCH1~0")'
            ORACLE '&max_blocking_factor 100&'.
  FREE LT_KEY.

  LOOP AT LT_MCH1 INTO LS_MCH1.
    " Batch without classification object has no AUSP value
    IF LS_MCH1-CUOBJ_BM IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR : LS_OBJ, LS_OBJEK.
    LS_OBJ-MATNR   = LS_MCH1-MATNR.
    LS_OBJ-CHARG   = LS_MCH1-CHARG.
    LS_OBJ-OBJEK   = LS_MCH1-CUOBJ_BM.
    APPEND LS_OBJ TO GT_OBJ.
    LS_OBJEK-OBJEK = LS_MCH1-CUOBJ_BM.
    APPEND LS_OBJEK TO LT_OBJEK.
  ENDLOOP.
  FREE LT_MCH1.
  SORT GT_OBJ BY MATNR CHARG.
  SORT LT_OBJEK BY OBJEK.
  DELETE ADJACENT DUPLICATES FROM LT_OBJEK COMPARING OBJEK.

  " Characteristic (AUSP~N3: MANDT OBJEK KLART ATINN ATWRT)
  IF LT_OBJEK[] IS NOT INITIAL.
    SELECT OBJEK ATINN ATWRT ATFLV
      INTO TABLE GT_AUSP
      FROM AUSP
       FOR ALL ENTRIES IN LT_OBJEK
     WHERE OBJEK = LT_OBJEK-OBJEK
       AND KLART = '023'
       AND ATINN IN (V_ZZTYPE, V_ZZTHICKNESS, V_ZZWIDTH, V_ZZLENGTH, V_ZZALIAS, V_ZZCRITERIA)
      %_HINTS ORACLE 'INDEX("AUSP" "AUSP~N3")'
              ORACLE '&max_in_blocking_factor 100&&max_blocking_factor 100&'.
  ENDIF.
  FREE LT_OBJEK.
  SORT GT_AUSP BY OBJEK ATINN ATWRT.
ENDFORM.                    "GT_PRELOAD

*&---------------------------------------------------------------------*
*&      Form  GT_FILL
*&---------------------------------------------------------------------*
*       Fill output from buffer (BINARY SEARCH)
*----------------------------------------------------------------------*
FORM GT_FILL.
  DATA : LS_VBAK  TYPE TY_VBAK,
         LS_VBPA  TYPE TY_VBPA,
         LS_ADRC  TYPE TY_ADRC,
         LS_MSKU  TYPE TY_MSKU,
         LS_KNA1  TYPE TY_KNA1,
         LS_LQUA  TYPE TY_LQUA,
         LS_OBJ   TYPE TY_OBJ,
         LS_AUSP  TYPE TY_AUSP,
         LS_DESC  TYPE TY_DESC,
         LV_TABIX TYPE SY-TABIX.
  FIELD-SYMBOLS : <LS_OUT> TYPE TY_OUT.

  LOOP AT GT_OUT ASSIGNING <LS_OUT>.
    " Storage Bin
    CLEAR LS_LQUA.
    READ TABLE GT_LQUA INTO LS_LQUA
         WITH KEY MATNR = <LS_OUT>-MATNR WERKS = <LS_OUT>-WERKS CHARG = <LS_OUT>-CHARG
         BINARY SEARCH.
    IF SY-SUBRC = 0.
      <LS_OUT>-LGPLA = LS_LQUA-LGPLA.
    ENDIF.

    " Sales Doc Type & Customer Name
    IF <LS_OUT>-VBELN IS NOT INITIAL AND <LS_OUT>-POSNR IS NOT INITIAL.
      CLEAR LS_VBAK.
      READ TABLE GT_VBAK INTO LS_VBAK
           WITH KEY VBELN = <LS_OUT>-VBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        <LS_OUT>-AUART = LS_VBAK-AUART.
      ENDIF.

      CLEAR LS_VBPA.
      READ TABLE GT_VBPA INTO LS_VBPA
           WITH KEY VBELN = <LS_OUT>-VBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        CLEAR LS_ADRC.
        READ TABLE GT_ADRC INTO LS_ADRC
             WITH KEY ADDRNUMBER = LS_VBPA-ADRNR BINARY SEARCH.
        IF SY-SUBRC = 0.
          <LS_OUT>-NAME1 = LS_ADRC-NAME1.
        ENDIF.
      ENDIF.
    ELSEIF <LS_OUT>-VBELN IS INITIAL AND <LS_OUT>-POSNR IS INITIAL.
      CLEAR LS_MSKU.
      READ TABLE GT_MSKU INTO LS_MSKU
           WITH KEY MATNR = <LS_OUT>-MATNR WERKS = <LS_OUT>-WERKS CHARG = <LS_OUT>-CHARG
           BINARY SEARCH.
      IF SY-SUBRC = 0.
        CLEAR LS_KNA1.
        READ TABLE GT_KNA1 INTO LS_KNA1
             WITH KEY KUNNR = LS_MSKU-KUNNR BINARY SEARCH.
        IF SY-SUBRC = 0.
          <LS_OUT>-NAME1 = LS_KNA1-NAME1.
        ENDIF.
      ENDIF.
    ENDIF.

    " Characteristic
    CLEAR LS_OBJ.
    READ TABLE GT_OBJ INTO LS_OBJ
         WITH KEY MATNR = <LS_OUT>-MATNR CHARG = <LS_OUT>-CHARG BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    READ TABLE GT_AUSP TRANSPORTING NO FIELDS
         WITH KEY OBJEK = LS_OBJ-OBJEK BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    LV_TABIX = SY-TABIX.

    LOOP AT GT_AUSP INTO LS_AUSP FROM LV_TABIX.
      IF LS_AUSP-OBJEK <> LS_OBJ-OBJEK.
        EXIT.
      ENDIF.
      IF LS_AUSP-ATINN = V_ZZTYPE.
        <LS_OUT>-ZZTYPE = LS_AUSP-ATWRT.
      ELSEIF LS_AUSP-ATINN = V_ZZTHICKNESS.
        <LS_OUT>-ZZTHICKNESS = LS_AUSP-ATFLV.
      ELSEIF LS_AUSP-ATINN = V_ZZWIDTH.
        <LS_OUT>-ZZWIDTH = LS_AUSP-ATFLV.
      ELSEIF LS_AUSP-ATINN = V_ZZLENGTH.
        <LS_OUT>-ZZLENGTH = LS_AUSP-ATFLV.
      ELSEIF LS_AUSP-ATINN = V_ZZALIAS.
        <LS_OUT>-ZZALIAS = LS_AUSP-ATWRT.
      ELSEIF LS_AUSP-ATINN = V_ZZCRITERIA.
        " Description from CAWNT; value without text stays blank (same as ZBMBC join)
        CLEAR LS_DESC.
        READ TABLE GT_DESC INTO LS_DESC
             WITH KEY ATINN = LS_AUSP-ATINN ATWRT = LS_AUSP-ATWRT BINARY SEARCH.
        IF SY-SUBRC = 0.
          <LS_OUT>-ZZCRITERIA = LS_DESC-ATWTB.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "GT_FILL

*&---------------------------------------------------------------------*
*&      Form  GT_FREE
*&---------------------------------------------------------------------*
FORM GT_FREE.
  FREE : GT_VBAK, GT_VBPA, GT_ADRC, GT_MSKU, GT_KNA1, GT_LQUA,
         GT_OBJ, GT_AUSP, GT_DESC.
ENDFORM.                    "GT_FREE

*&---------------------------------------------------------------------*
*&      Form  SET_ALV
*&---------------------------------------------------------------------*
FORM SET_ALV.
  DATA : LO_ALV  TYPE REF TO CL_SALV_TABLE,
         LO_COLS TYPE REF TO CL_SALV_COLUMNS_TABLE,
         LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST,
         LX_MSG  TYPE REF TO CX_SALV_MSG,
         LV_MSG  TYPE STRING.

  TRY.
      CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
                              CHANGING  T_TABLE      = GT_OUT ).
    CATCH CX_SALV_MSG INTO LX_MSG.
      LV_MSG = LX_MSG->GET_TEXT( ).
      MESSAGE LV_MSG TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.

  LO_FUNC = LO_ALV->GET_FUNCTIONS( ).
  LO_FUNC->SET_ALL( 'X' ).

  LO_COLS = LO_ALV->GET_COLUMNS( ).
  LO_COLS->SET_OPTIMIZE( 'X' ).

  PERFORM SET_COL USING LO_COLS : 'WERKS'       'Plant',
                                  'MATNR'       'Material No',
                                  'ZZTYPE'      'Type',
                                  'ZZTHICKNESS' 'Thick',
                                  'CHARG'       'Batch',
                                  'ZZWIDTH'     'Width',
                                  'ZZLENGTH'    'Length',
                                  'ZZALIAS'     'TipeAlias',
                                  'ZZCRITERIA'  'CriteriaGrade',
                                  'LGORT'       'Sloc',
                                  'LGPLA'       'Storage Bin',
                                  'VBELN'       'SO No',
                                  'POSNR'       'SO Item',
                                  'AUART'       'Sales Doc Type',
                                  'HUBOX'       'HU Box',
                                  'HUPLT'       'HU Pallet',
                                  'NAME1'       'Customer Name',
                                  'SOBKZ'       'Special Stock',
                                  'LABST'       'Unrestricted',
                                  'INSME'       'Quality Insp.',
                                  'EINME'       'Restricted',
                                  'SPEME'       'Blocked'.

  LO_ALV->DISPLAY( ).
ENDFORM.                    "SET_ALV

*&---------------------------------------------------------------------*
*&      Form  SET_COL
*&---------------------------------------------------------------------*
FORM SET_COL USING UO_COLS TYPE REF TO CL_SALV_COLUMNS_TABLE
                   UV_NAME TYPE C
                   UV_TEXT TYPE C.
  DATA : LO_COL  TYPE REF TO CL_SALV_COLUMN,
         LV_NAME TYPE LVC_FNAME,
         LV_TXTL TYPE SCRTEXT_L,
         LV_TXTM TYPE SCRTEXT_M,
         LV_TXTS TYPE SCRTEXT_S.

  LV_NAME = UV_NAME.
  LV_TXTL = UV_TEXT.
  LV_TXTM = UV_TEXT.
  LV_TXTS = UV_TEXT.
  TRY.
      LO_COL = UO_COLS->GET_COLUMN( LV_NAME ).
      LO_COL->SET_LONG_TEXT( LV_TXTL ).
      LO_COL->SET_MEDIUM_TEXT( LV_TXTM ).
      LO_COL->SET_SHORT_TEXT( LV_TXTS ).
    CATCH CX_SALV_NOT_FOUND.                            "#EC NO_HANDLER
  ENDTRY.
ENDFORM.                    "SET_COL

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL_WMS
*&---------------------------------------------------------------------*
*       Staging Y_ZBMBCSR -> SP merge ke [WHS_130].[dbo].[ZBMBCSR_WMS]
*       (same as ZBMBC Execution Type WMS)
*----------------------------------------------------------------------*
FORM INSERT_SQL_WMS.
  DATA: LV_CON        LIKE DBCON-CON_NAME,
        LV_DBMS       TYPE DBCON_DBMS,
        LV_THICK(20)  TYPE C,
        LV_WIDTH(20)  TYPE C,
        LV_LENGTH(20) TYPE C.

  LV_CON = P_CONN.

  SELECT SINGLE DBMS
         FROM DBCON
         INTO LV_DBMS
         WHERE CON_NAME = LV_CON.
  IF SY-SUBRC <> 0 OR LV_DBMS <> 'MSS'.
    MESSAGE 'DBCO Connection not found..!!' TYPE 'I'.
    EXIT.
  ENDIF.

  EXEC SQL.
    CONNECT TO :LV_CON
  ENDEXEC.
  IF SY-SUBRC <> 0.
    MESSAGE 'Not Connected..!!' TYPE 'I'.
    EXIT.
  ENDIF.

  EXEC SQL.
    SET CONNECTION :LV_CON
  ENDEXEC.

  TRY.
      " Staging dikosongkan, diisi ulang, lalu di-merge oleh SP
      EXEC SQL.
        DELETE FROM Y_ZBMBCSR
      ENDEXEC.

      LOOP AT GT_OUT INTO GS_OUT.
        " Semua kolom staging NVARCHAR(200); angka dikirim sebagai teks
        LV_THICK  = GS_OUT-ZZTHICKNESS.
        LV_WIDTH  = GS_OUT-ZZWIDTH.
        LV_LENGTH = GS_OUT-ZZLENGTH.
        CONDENSE: LV_THICK, LV_WIDTH, LV_LENGTH.

        EXEC SQL.
          INSERT INTO Y_ZBMBCSR ([Plant], [Material No], [Type], [Thick], [Batch], [Width], [Length],
            [TipeAlias], [CriteriaGrade], [Sloc], [Storage Bin], [SO No], [SO Item], [Sales Doc Type],
            [HU Box], [HU Pallet], [Customer Name])
          VALUES (:GS_OUT-WERKS, :GS_OUT-MATNR, :GS_OUT-ZZTYPE, :LV_THICK, :GS_OUT-CHARG,
            :LV_WIDTH, :LV_LENGTH, :GS_OUT-ZZALIAS, :GS_OUT-ZZCRITERIA, :GS_OUT-LGORT,
            :GS_OUT-LGPLA, :GS_OUT-VBELN, :GS_OUT-POSNR, :GS_OUT-AUART,
            :GS_OUT-HUBOX, :GS_OUT-HUPLT, :GS_OUT-NAME1)
        ENDEXEC.
      ENDLOOP.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

      EXEC SQL.
        EXECUTE PROCEDURE dbo.SP_Merge_ZBMBCSR_WMS
      ENDEXEC.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

      MESSAGE 'Penyimpanan Data ke WMS sukses!!!' TYPE 'I'.

    CATCH CX_SY_NATIVE_SQL_ERROR.
      EXEC SQL.
        ROLLBACK WORK
      ENDEXEC.
      MESSAGE 'Error in procedure insert WMS' TYPE 'I'.
  ENDTRY.

  EXEC SQL.
    DISCONNECT :LV_CON
  ENDEXEC.

  REFRESH GT_OUT.
ENDFORM.                    "INSERT_SQL_WMS
