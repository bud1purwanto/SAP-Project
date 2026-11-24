*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_BY_CHAR_F01
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
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'CHARV'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = IT_F4
      RETURN_TAB   = IT_RETURN.
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
    SELECT DISTINCT MCHB~MATNR MCHB~WERKS MCHB~LGORT MCHB~CHARG
      INTO CORRESPONDING FIELDS OF TABLE IT_ZBMBC
    FROM MCHB
      JOIN MARA ON MARA~MATNR = MCHB~MATNR
    WHERE MCHB~MATNR IN S_MATNR AND
          WERKS IN S_WERKS AND
          LGORT IN S_LGORT AND
          CHARG IN S_CHARG AND
          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
          MTART IN S_MTART.

    SELECT DISTINCT MSKA~MATNR WERKS LGORT CHARG SOBKZ MSKA~VBELN MSKA~POSNR AUART
      INTO CORRESPONDING FIELDS OF TABLE TMP_ZBMBC
    FROM MSKA
      JOIN MARA ON MARA~MATNR = MSKA~MATNR
      JOIN VBAK ON VBAK~VBELN = MSKA~VBELN
    WHERE MSKA~MATNR IN S_MATNR AND
          WERKS IN S_WERKS AND
          LGORT IN S_LGORT AND
          CHARG IN S_CHARG AND
          CHARG NE '' AND
          MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
          MTART IN S_MTART.

    LOOP AT TMP_ZBMBC ASSIGNING <FS_ZBMBC> WHERE CHARG NE ' '.
      SELECT SINGLE LGPLA INTO <FS_ZBMBC>-LGPLA
        FROM LIPS
      WHERE VBELN = <FS_ZBMBC>-VBELN AND
            POSNR = <FS_ZBMBC>-POSNR.
    ENDLOOP.

    APPEND LINES OF TMP_ZBMBC TO IT_ZBMBC.
    DELETE ADJACENT DUPLICATES FROM IT_ZBMBC COMPARING ALL FIELDS.

  ELSE.

    SELECT DISTINCT MSKA~MATNR WERKS LGORT CHARG SOBKZ MSKA~VBELN POSNR VBAK~AUART
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
            MTART IN ('ZFGS','ZRAW','ZSFG','ZPCK') AND
            SOBKZ IN S_SOBKZ.
  ENDIF.

*  COLLECT ALL CATEGORY####################################################
  IF LINES( IT_ZBMBC ) > 0.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ
                    KULAB AS LABST
                    KUINS AS INSME
                    KUEIN AS EINME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MSKU
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.
*=====================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ
                    LBLAB AS LABST
                    LBINS AS INSME
                    LBEIN AS EINME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MSLB
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG.

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
        APPEND IT_ZBMBC.
      ENDLOOP.
    ENDIF.
*===================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ LGORT
                    SLABS AS LABST
                    SINSM AS INSME
                    SEINM AS EINME
                    SSPEM AS SPEME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MKOL
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG AND
          LGORT = IT_ZBMBC-LGORT.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.
*====================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ LGORT
                    PRLAB AS LABST
                    PRINS AS INSME
                    PREIN AS EINME
                    PRSPE AS SPEME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MSPR
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG AND
          LGORT = IT_ZBMBC-LGORT.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.

*=====================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ LGORT
                    SDLAB AS LABST
                    SDINS AS INSME
                    SDEIN AS EINME
                    SDSPE AS SPEME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MCSD
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG AND
          LGORT = IT_ZBMBC-LGORT.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.

*=====================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG LGORT
                    CLABS AS LABST
                    CINSM AS INSME
                    CEINM AS EINME
                    CSPEM AS SPEME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MCHB
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG AND
          LGORT = IT_ZBMBC-LGORT.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.

*=======================================================
    REFRESH TMP_COLLECT.
    SELECT DISTINCT MATNR WERKS CHARG SOBKZ LGORT VBELN POSNR
                    KALAB AS LABST
                    KAINS AS INSME
                    KAEIN AS EINME
                    KASPE AS SPEME
      INTO CORRESPONDING FIELDS OF TABLE TMP_COLLECT
    FROM MSKA
      FOR ALL ENTRIES IN IT_ZBMBC
    WHERE SOBKZ IN S_SOBKZ AND
          MATNR = IT_ZBMBC-MATNR AND
          WERKS = IT_ZBMBC-WERKS AND
          CHARG = IT_ZBMBC-CHARG AND
          LGORT = IT_ZBMBC-LGORT.

    LOOP AT TMP_COLLECT ASSIGNING <FS_TMP_COLLECT>.
      COLLECT <FS_TMP_COLLECT> INTO IT_COLLECT.
    ENDLOOP.
  ENDIF.

  DELETE IT_COLLECT WHERE SOBKZ = 'K'.
  DELETE IT_COLLECT WHERE SOBKZ = 'M'.
  DELETE IT_COLLECT WHERE SOBKZ = 'Q'.
*######################################################################

*  DELETE BASE ON SELECTION SCREEN###############################################################
  IF S_SOBKZ IS NOT INITIAL.

    DELETE IT_COLLECT WHERE SOBKZ NOT IN S_SOBKZ.

    LOOP AT IT_COLLECT ASSIGNING <FS_COLLECT>.
      LOOP AT IT_ZBMBC ASSIGNING <FS_ZBMBC>  WHERE MATNR = <FS_COLLECT>-MATNR AND WERKS = <FS_COLLECT>-WERKS
                       AND CHARG = <FS_COLLECT>-CHARG AND LGORT = <FS_COLLECT>-LGORT.
        <FS_ZBMBC>-DIND = 'X'.
      ENDLOOP.
    ENDLOOP.
    DELETE IT_ZBMBC WHERE DIND NE 'X'.
  ENDIF.

  IF P_ZERO IS NOT INITIAL.
    LOOP AT IT_COLLECT ASSIGNING <FS_COLLECT> WHERE LABST = 0 AND INSME = 0 AND SPEME = 0.
      DELETE IT_ZBMBC WHERE MATNR = <FS_COLLECT>-MATNR AND WERKS = <FS_COLLECT>-WERKS
                      AND CHARG = <FS_COLLECT>-CHARG AND LGORT = <FS_COLLECT>-LGORT
                      AND SOBKZ = <FS_COLLECT>-SOBKZ AND VBELN = <FS_COLLECT>-VBELN
                      AND POSNR = <FS_COLLECT>-POSNR.
    ENDLOOP.
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

*--- start comment
*    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
*      EXPORTING
*        I_VAL_MATNR    = <FS_ZBMBC>-MATNR
*        I_VAL_WERKS    = <FS_ZBMBC>-WERKS
*        I_VAL_CHARGE   = <FS_ZBMBC>-CHARG
*      TABLES
*        T_VAL_TAB      = ZVAL
*      EXCEPTIONS
*        NO_CLASS       = 1
*        INTERNAL_ERROR = 2
*        NO_VALUES      = 3
*        NO_CHARS       = 4
*        OTHERS         = 5.
*
**    Cur length####################################
*    CLEAR DLENG.

*    PERFORM GT_CUR_LEN USING <FS_ZBMBC>-MATNR <FS_ZBMBC>-CHARG CHANGING <FS_ZBMBC>-ZZCLEN.

*    #################################################

*    PERFORM RD_CHAR2 USING 'ZZTYPE' CHANGING <FS_ZBMBC>-ZZTYP <FS_ZBMBC>-ZZTYP2.
*
*    IF S_ATWRT1 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZTYP2 NOT IN S_ATWRT1.
*      CONTINUE.
*    ENDIF.
*
*    PERFORM RD_CHAR USING 'ZZTHICKNESS' CHANGING <FS_ZBMBC>-ZZTCK.
*    MOVE <FS_ZBMBC>-ZZTCK TO <FS_ZBMBC>-ZZTCK2.
*
*    IF S_ATWRT2 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZTCK2 NOT IN S_ATWRT2.
*      CONTINUE.
*    ENDIF.
*
*    PERFORM RD_CHAR USING 'ZZWIDTH' CHANGING <FS_ZBMBC>-ZZWDT.
*    REPLACE ALL OCCURRENCES OF ',' IN <FS_ZBMBC>-ZZWDT WITH ''.
*
*    IF S_ATWRT3 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZWDT NOT IN S_ATWRT3.
*      CONTINUE.
*    ENDIF.
*
*    "JIKA 2 DIGIT AWAL MATERIAL NUMBER = SH (SHEET)
*    CLEAR : JMATNR, AMATNR, LEN, R_STRING, P_STRING.
*    P_STRING = <FS_ZBMBC>-MATNR.
*    CALL FUNCTION 'STRING_REVERSE'
*      EXPORTING
*        STRING  = P_STRING
*        LANG    = 'E'
*      IMPORTING
*        RSTRING = R_STRING.
*    AMATNR = R_STRING.
*    LEN = STRLEN( AMATNR ).
*    LEN = LEN - 2.
*    JMATNR = AMATNR+LEN(2).

*    IF JMATNR = 'HS'.
*      PERFORM RD_CHAR USING 'ZZLENGTHSHT' CHANGING <FS_ZBMBC>-ZZLEN.
*      REPLACE ALL OCCURRENCES OF ',' IN <FS_ZBMBC>-ZZLEN WITH ''.
*    ELSE.
*      PERFORM RD_CHAR USING 'ZZLENGTH' CHANGING <FS_ZBMBC>-ZZLEN.
*      REPLACE ALL OCCURRENCES OF ',' IN <FS_ZBMBC>-ZZLEN WITH ''.
*    ENDIF.
*
*    IF S_ATWRT4 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZLEN NOT IN S_ATWRT4.
*    ENDIF.
*
*    PERFORM RD_CHAR2 USING 'ZZCORE' CHANGING <FS_ZBMBC>-ZZCORE <FS_ZBMBC>-ZZCORE2.
*    IF S_ATWRT6 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZCORE2 NOT IN S_ATWRT6.
*    ENDIF.
*
*    PERFORM RD_CHAR USING 'ZZCRITERIA' CHANGING <FS_ZBMBC>-ZZCRIT.
*    PERFORM RD_CHAR USING 'ZZPACKING' CHANGING <FS_ZBMBC>-ZZPACK.
*    PERFORM RD_CHAR USING 'ZZNOMORROLL' CHANGING <FS_ZBMBC>-ZZNOJR.
*    PERFORM RD_CHAR2 USING 'ZZTREATMENT' CHANGING <FS_ZBMBC>-ZZTRT <FS_ZBMBC>-ZZTRT2.
*    IF S_ATWRT5 IS NOT INITIAL.
*      DELETE IT_ZBMBC WHERE ZZTRT2 NOT IN S_ATWRT5.
*      CONTINUE.
*    ENDIF.
*
*
*    PERFORM RD_CHAR USING 'ZZSPLICE-1' CHANGING <FS_ZBMBC>-ZZSPLC1.
*    PERFORM RD_CHAR USING 'ZZSPLICE-2' CHANGING <FS_ZBMBC>-ZZSPLC2.
*    PERFORM RD_CHAR USING 'ZZSPLICE-3' CHANGING <FS_ZBMBC>-ZZSPLC3.
*    PERFORM RD_CHAR USING 'ZZALIAS' CHANGING <FS_ZBMBC>-ZZALIAS.
*    PERFORM RD_CHAR USING 'ZZLABEL' CHANGING <FS_ZBMBC>-ZZLBL.
*    PERFORM RD_CHAR USING 'ZZEXPIREDLIVE' CHANGING <FS_ZBMBC>-ZZEXDT.

*--- Comment dulu


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
          NO_VALUES    = 2.
      IF SY-SUBRC EQ '0'.
        "- Tipe
        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZTYPE =  <FS_CHAR>-ATWRT.
        ENDIF.

        "- Thickness
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTHICKNESS'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV1.
          MOVE  ATFLV1 TO <FS_ZBMBC>-ZZTHICKNESS .
        ENDIF.

        "- Width
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH'   ASSIGNING <FS_CHAR> .
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_ZBMBC>-ZZWIDTH =  ATFLV2.
        ENDIF.

        "- Length
        IF <FS_ZBMBC>-MATNR(2) EQ 'SH'.
          READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZLENGTHSHT'   ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
          ENDIF.
        ELSE.
          READ TABLE  IT_CHAR WITH  KEY ATNAM = 'ZZLENGTH'   ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            <FS_ZBMBC>-ZZLENGTH =  ATFLV2.
          ENDIF.
        ENDIF.

        "- Core.
        READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCORE'   ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ZBMBC>-ZZCORE =  <FS_CHAR>-ATWTB.
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
          <FS_ZBMBC>-ZZLABEL =  <FS_CHAR>-ATWTB.
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

      ENDIF.
    ENDIF.
** ----




    READ TABLE IT_COLLECT WITH KEY MATNR = <FS_ZBMBC>-MATNR CHARG = <FS_ZBMBC>-CHARG WERKS = <FS_ZBMBC>-WERKS
                                  LGORT = <FS_ZBMBC>-LGORT VBELN = <FS_ZBMBC>-VBELN POSNR = <FS_ZBMBC>-POSNR
    ASSIGNING <FS_COLLECT>.

    IF SY-SUBRC = 0.
      <FS_ZBMBC>-SOBKZ = <FS_COLLECT>-SOBKZ.
      <FS_ZBMBC>-LABST = <FS_COLLECT>-LABST.
      IF <FS_COLLECT>-LABST NE 0.
        <FS_ZBMBC>-LROLL = 1.
      ENDIF.
      <FS_ZBMBC>-INSME = <FS_COLLECT>-INSME.
      IF <FS_COLLECT>-INSME NE 0.
        <FS_ZBMBC>-IROLL = 1.
      ENDIF.
      <FS_ZBMBC>-SPEME = <FS_COLLECT>-SPEME.
      IF <FS_COLLECT>-SPEME NE 0.
        <FS_ZBMBC>-BROLL = 1.
      ENDIF.
    ENDIF.

    IF <FS_ZBMBC>-VBELN IS NOT INITIAL AND <FS_ZBMBC>-POSNR IS NOT INITIAL.
      SELECT SINGLE BEZEI INTO <FS_ZBMBC>-BEZEI
        FROM TVAGT
      JOIN VBAP ON VBAP~ABGRU = TVAGT~ABGRU
      WHERE SPRAS = 'E' AND
            VBELN = <FS_ZBMBC>-VBELN AND
            POSNR = <FS_ZBMBC>-POSNR.

      SELECT SINGLE NAME1 INTO <FS_ZBMBC>-NAME1
        FROM KNA1
      JOIN VBAK ON VBAK~KUNNR = KNA1~KUNNR
      JOIN VBAP ON VBAP~VBELN = VBAK~VBELN
        WHERE VBAP~VBELN = <FS_ZBMBC>-VBELN AND
              VBAP~POSNR = <FS_ZBMBC>-POSNR.

    ELSEIF <FS_ZBMBC>-VBELN IS INITIAL AND <FS_ZBMBC>-POSNR IS INITIAL.
      SELECT SINGLE NAME1 INTO <FS_ZBMBC>-NAME1
        FROM KNA1
      JOIN MSKU ON MSKU~KUNNR = KNA1~KUNNR
        WHERE MSKU~MATNR = <FS_ZBMBC>-MATNR AND
              MSKU~WERKS = <FS_ZBMBC>-WERKS AND
              MSKU~CHARG = <FS_ZBMBC>-CHARG.
    ENDIF.

    SELECT SINGLE ERSDA INTO <FS_ZBMBC>-ERSDA
      FROM MCH1
    WHERE MATNR = <FS_ZBMBC>-MATNR AND
          CHARG = <FS_ZBMBC>-CHARG.

    <FS_ZBMBC>-DEXDT = <FS_ZBMBC>-ERSDA + <FS_ZBMBC>-ZZEXPIREDLIVE.
  ENDLOOP.

  SORT IT_ZBMBC BY MATNR WERKS LGORT CHARG.
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
         'HUPLT' '' '' C_NO '' 'HU Pallet' '' 'X' ''.

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
         'ZZALIAS' '' '' C_NO '' 'Tipe Alias' '' '' '',
         'ZZLABEL' '' '' C_NO '' 'Tipe Label' '' '' '',
         'DEXDT' '' '' C_NO '' 'Expired Date' '' '' '',
         'ERSDA' '' '' C_NO '' 'Production Date' '' '' ''.

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
      LOOP AT IT_ZBMBC ASSIGNING <FS_ZBMBC>.
        EXEC SQL.
*          INSERT INTO XZBMBC(Col001,Col002,Col003,Col004,Col005,Col006,Col007,Col008,Col009,Col010,Col011,Col012,Col013,Col014,Col015,Col016,Col017,
*                                  Col018,Col019,Col020,Col021,Col022,Col023,Col024,Col025,Col026,Col027,Col028,Col029,Col030,Col031,Col032,Col033,Col034,Col035)
*            VALUES (:<FS_ZBMBC>-MATNR,:<FS_ZBMBC>-WERKS,:<FS_ZBMBC>-LGORT,:<FS_ZBMBC>-CHARG,:<FS_ZBMBC>-SOBKZ,:<FS_ZBMBC>-LGPLA,:<FS_ZBMBC>-VBELN,:<FS_ZBMBC>-POSNR,
*                    :<FS_ZBMBC>-AUART,:<FS_ZBMBC>-HUBOX,:<FS_ZBMBC>-HUPLT,:<FS_ZBMBC>-ZZTYP,:<FS_ZBMBC>-ZZTCK,:<FS_ZBMBC>-ZZWDT,:<FS_ZBMBC>-ZZLEN,:<FS_ZBMBC>-ZZCORE,
*                    :<FS_ZBMBC>-ZZCRIT,:<FS_ZBMBC>-ZZPACK,:<FS_ZBMBC>-ZZNOJR,:<FS_ZBMBC>-ZZTRT,:<FS_ZBMBC>-LABST,:<FS_ZBMBC>-LROLL,:<FS_ZBMBC>-INSME,:<FS_ZBMBC>-IROLL,
*                    :<FS_ZBMBC>-SPEME,:<FS_ZBMBC>-BROLL,:<FS_ZBMBC>-BEZEI,:<FS_ZBMBC>-NAME1,:<FS_ZBMBC>-ZZSPLC1,:<FS_ZBMBC>-ZZSPLC2,:<FS_ZBMBC>-ZZSPLC3,:<FS_ZBMBC>-ZZALIAS,
*                    :<FS_ZBMBC>-ZZLBL,:<FS_ZBMBC>-DEXDT,:<FS_ZBMBC>-ERSDA)
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

**  -- 3-1-12
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