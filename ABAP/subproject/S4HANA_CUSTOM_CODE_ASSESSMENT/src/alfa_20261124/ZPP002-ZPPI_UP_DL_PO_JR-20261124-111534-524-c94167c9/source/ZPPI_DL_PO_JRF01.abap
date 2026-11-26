*&---------------------------------------------------------------------*
*&  Include           ZPPI_DL_PO_JRF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR : IT_ITEM, IT_JEST, IT_REPORT, IT_REPORT2, IT_REPORT3, IT_REPORT4,
          IT_REPORT5, IT_REPORT6, IT_REPORT7, IT_REPORT8,IT_DETAIL,LT_LAYOUT,LT_FIELDCATLOG,LT_FIELDCATLOG.
  REFRESH : IT_ITEM, IT_JEST, IT_REPORT, IT_REPORT2, IT_REPORT3, IT_REPORT4,
            IT_REPORT5, IT_REPORT6, IT_REPORT7, IT_REPORT8,IT_DETAIL.

  SELECT AUFK~AUFNR     AS AUFNR
         AFKO~PLNBEZ    AS PLNBEZ
         AUFK~WERKS     AS WERKS
         AUFK~AUART     AS AUART
         AFKO~GAMNG     AS GAMNG
         AFKO~GMEIN     AS GMEIN
         AFKO~GSTRP     AS GSTRP
         AFKO~GSUZP     AS GSUZP
         AFPO~VERID     AS VERID
         AUFK~ZCODE     AS ZCODE
         AUFK~ZWIDTH    AS ZWIDTH1
         AUFK~ZLENGTH   AS ZLENGTH1
         AUFK~ZTREAT    AS ZTREAT
         AUFK~ZLINE     AS ZLINE
         AUFK~ZMONTH    AS ZMONTH
         AUFK~ZCUSTM    AS ZCUSTM
         AUFK~ZNOSHEET  AS ZNOSHEET
         AFKO~SBMNG     AS SBMNG
         AFKO~SBMEH     AS SBMEH
         AUFK~OBJNR     AS OBJNR
         AFPO~MEINS     AS MEINS
         AFPO~AMEIN     AS AMEIN
         AFPO~WEMNG     AS WEMNG
*         AFKO~BMEINS    AS AMEIN
         AFKO~GSTRI     AS GSTRI
         AFKO~GSUZI     AS GSUZI
    FROM AFKO
    JOIN AUFK ON AFKO~AUFNR = AUFK~AUFNR
    JOIN AFPO ON AFKO~AUFNR = AFPO~AUFNR
    INTO CORRESPONDING FIELDS OF TABLE IT_ITEM
    WHERE AUFK~ZLINE IN ZLINE
    AND   AUFK~AUFNR IN AUFNR
    AND   AUFK~ZCODE IN ZCODE
    AND   AUFK~AUTYP = '40'
    AND   AUFK~AUART IN ('ZP01', 'ZP02', 'ZP03', 'ZP04', 'ZP05', 'ZP06', 'ZP07', 'ZP08', 'ZP09', 'ZP10', 'ZP11', 'ZP12',
                         'ZP90', 'ZTR1', 'ZTR2','ZTR3','ZTR4','ZTR5','ZTR6','ZTR7',     "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                         'ZP13', 'ZP14', 'ZP15', 'ZP16', 'ZP17', 'ZP18', 'ZTR8', 'ZTR9', 'ZTRA', 'ZTRB', 'ZTRC', 'ZTRD')  "Added by William at 24.07.2022 (OPP7 CPP1)
    AND   AFKO~GSTRP IN GSTRP.

  DESCRIBE TABLE IT_ITEM LINES LINE.

  IF LINE NE 0.

    SELECT OBJNR AS OBJNR
           STAT  AS STAT
           INACT AS INACT
      FROM JEST
      INTO CORRESPONDING FIELDS OF TABLE IT_JEST
      FOR ALL ENTRIES IN IT_ITEM
      WHERE OBJNR = IT_ITEM-OBJNR AND
            INACT = ' '.

    SORT IT_ITEM BY AUFNR ASCENDING.

    LOOP AT IT_ITEM ASSIGNING <FS_ITEM>.
      CLEAR : WEIGHT, LENGTH.
      WEIGHT = <FS_ITEM>-ZWIDTH1.
      REPLACE ALL OCCURRENCES OF ',' IN WEIGHT WITH SPACE.
      <FS_ITEM>-ZWIDTH = WEIGHT.

      LENGTH = <FS_ITEM>-ZLENGTH1.
      REPLACE ALL OCCURRENCES OF ',' IN LENGTH WITH SPACE.
      <FS_ITEM>-ZLENGTH = LENGTH.


      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          OBJNR = <FS_ITEM>-OBJNR
          SPRAS = 'E'
        IMPORTING
          LINE  = SLINE.

      <FS_ITEM>-ISTAT1 = SLINE.

      READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                  STAT = 'I0045'.
      IF SY-SUBRC EQ 0.
        <FS_ITEM>-ISTAT2 = 'TECO'.
      ELSE.
        READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                    STAT = 'I0009'.
        IF SY-SUBRC NE 0.
          READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                      STAT = 'I0012'.
        ENDIF.

        IF SY-SUBRC EQ 0.
          <FS_ITEM>-ISTAT2 = 'Completed'.
        ELSE.
          READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                      STAT = 'I0010'.
          IF SY-SUBRC NE 0.
            READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                        STAT = 'I0074'.
          ENDIF.

          IF SY-SUBRC NE 0.
            READ TABLE IT_JEST WITH KEY OBJNR = <FS_ITEM>-OBJNR
                                        STAT = 'I0321'.
          ENDIF.

          IF SY-SUBRC EQ 0.
            <FS_ITEM>-ISTAT2 = 'In Progress'.
          ELSE.
            <FS_ITEM>-ISTAT2 = 'Created'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF R1 EQ ' '.
      DELETE IT_ITEM WHERE ISTAT2 EQ 'Created'.
    ENDIF.

    IF R2 EQ ' '.
      DELETE IT_ITEM WHERE ISTAT2 EQ 'In Progress'.
    ENDIF.

    IF R3 EQ ' '.
      DELETE IT_ITEM WHERE ISTAT2 EQ 'Completed'.
    ENDIF.

    IF R4 EQ ' '.
      DELETE IT_ITEM WHERE ISTAT2 EQ 'TECO'.
    ENDIF.

    SORT IT_ITEM BY AUFNR ASCENDING.
    DESCRIBE TABLE IT_ITEM LINES LINE.

    IF LINE NE 0.
      SELECT AFRU~AUFNR AS AUFNR
             AFRU~RUECK AS RUECK
             AFRU~RMZHL AS RMZHL
             AFRU~ISDD  AS ISDD
             AFRU~ISDZ  AS ISDZ
             AFRU~IEDD  AS IEDD
             AFRU~IEDZ  AS IEDZ
             AFRU~PERNR AS PERNR
        FROM AFRU
        INTO CORRESPONDING FIELDS OF TABLE IT_REPORT2
        FOR ALL ENTRIES IN IT_ITEM
        WHERE AFRU~AUFNR = IT_ITEM-AUFNR AND
              AFRU~STOKZ = ' ' AND
              AFRU~STZHL = ' ' AND
              AFRU~ISDD IN ISDD.
    ENDIF.

    SORT IT_REPORT2 BY AUFNR ASCENDING.

    LOOP AT IT_ITEM ASSIGNING <FS_ITEM>.
      LOOP AT IT_REPORT2 ASSIGNING <FS_REPORT2>
                 WHERE AUFNR = <FS_ITEM>-AUFNR.

        IT_REPORT3         = <FS_REPORT2>.
        IT_REPORT3-PLNBEZ  = <FS_ITEM>-PLNBEZ.
        IT_REPORT3-WERKS   = <FS_ITEM>-WERKS.
        IT_REPORT3-AUART   = <FS_ITEM>-AUART.
        IT_REPORT3-GAMNG   = <FS_ITEM>-GAMNG.
        IT_REPORT3-GMEIN   = <FS_ITEM>-GMEIN.
        IT_REPORT3-GSTRP   = <FS_ITEM>-GSTRP.
        IT_REPORT3-GSUZP   = <FS_ITEM>-GSUZP.
        IT_REPORT3-VERID   = <FS_ITEM>-VERID.
        IT_REPORT3-ZCODE   = <FS_ITEM>-ZCODE.
        IT_REPORT3-ZWIDTH  = <FS_ITEM>-ZWIDTH.
        IT_REPORT3-ZLENGTH = <FS_ITEM>-ZLENGTH.
        IT_REPORT3-ZTREAT  = <FS_ITEM>-ZTREAT.
        IT_REPORT3-ZLINE   = <FS_ITEM>-ZLINE.
        IT_REPORT3-ZMONTH  = <FS_ITEM>-ZMONTH.
        IT_REPORT3-ZCUSTM  = <FS_ITEM>-ZCUSTM.
        IT_REPORT3-ISTAT1  = <FS_ITEM>-ISTAT1.
        IT_REPORT3-ISTAT2  = <FS_ITEM>-ISTAT2.
        IT_REPORT3-OBJNR   = <FS_ITEM>-OBJNR.
        IT_REPORT3-AMEIN   = <FS_ITEM>-AMEIN.
        IT_REPORT3-GSTRI   = <FS_ITEM>-GSTRI.
        IT_REPORT3-GSUZI   = <FS_ITEM>-GSUZI.
        IT_REPORT3-WEMNG   = <FS_ITEM>-WEMNG.
        IT_REPORT3-ISM01   = <FS_ITEM>-ISM01.
*        IT_REPORT3-IEDD    = <FS_ITEM>-IEDD.
*        IT_REPORT3-IEDZ    = <FS_ITEM>-IEDZ.
        IT_REPORT3-LENGTH_I = <FS_ITEM>-LENGTH_I.
        IT_REPORT3-WEIGHT_I = <FS_ITEM>-WEIGHT_I.
        APPEND IT_REPORT3.
        CLEAR: IT_REPORT3.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        IT_REPORT3         = <FS_ITEM>.
        APPEND IT_REPORT3.
        CLEAR: IT_REPORT3.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT IT_REPORT3 BY AUFNR ASCENDING.
  DESCRIBE TABLE IT_REPORT3 LINES LINE.

  IF LINE NE 0.
    SELECT AFRU~AUFNR AS AUFNR
           AFRU~RUECK AS RUECK
           AFRU~RMZHL AS RMZHL
           AFRU~IEDD  AS IEDD
           AFRU~IEDZ  AS IEDZ
           MSEG~ERFMG AS ERFMG
           MSEG~ERFME AS ERFME
           MSEG~CHARG AS CHARG
           MSEG~MBLNR AS MBLNR
           MSEG~MJAHR AS MJAHR
           MSEG~ZEILE AS ZEILE
      FROM AFRU
      JOIN MSEG ON AFRU~LTXA1 = MSEG~MBLNR
*      LEFT OUTER JOIN AFWI ON AFRU~RUECK = AFWI~RUECK AND
*                   AFRU~RMZHL = AFWI~RMZHL
*      JOIN MSEG ON AFWI~MBLNR = MSEG~MBLNR AND
*                   AFWI~MJAHR = MSEG~MJAHR AND
*                   AFWI~MBLPO = MSEG~ZEILE
      INTO CORRESPONDING FIELDS OF TABLE IT_REPORT4
      FOR ALL ENTRIES IN IT_REPORT3
      WHERE AFRU~AUFNR = IT_REPORT3-AUFNR AND
            AFRU~STOKZ = ' ' AND
            AFRU~STZHL = ' ' AND
            AFRU~ISDD IN ISDD AND
            MSEG~BWART = '101'.
  ENDIF.

  SORT IT_REPORT4 BY AUFNR ASCENDING.

  LOOP AT IT_REPORT3 ASSIGNING <FS_REPORT3>.
    LOOP AT IT_REPORT4 ASSIGNING <FS_REPORT4> WHERE RUECK = <FS_REPORT3>-RUECK AND
                                                    RMZHL = <FS_REPORT3>-RMZHL AND
                                                    AUFNR = <FS_REPORT3>-AUFNR.


      IT_REPORT5          = <FS_REPORT4>.
      IT_REPORT5-PLNBEZ   = <FS_REPORT3>-PLNBEZ.
      IT_REPORT5-WERKS    = <FS_REPORT3>-WERKS.
      IT_REPORT5-AUART    = <FS_REPORT3>-AUART.
      IT_REPORT5-GAMNG    = <FS_REPORT3>-GAMNG.
      IT_REPORT5-GMEIN    = <FS_REPORT3>-GMEIN.
      IT_REPORT5-GSTRP    = <FS_REPORT3>-GSTRP.
      IT_REPORT5-GSUZP    = <FS_REPORT3>-GSUZP.
      IT_REPORT5-VERID    = <FS_REPORT3>-VERID.
      IT_REPORT5-ZCODE    = <FS_REPORT3>-ZCODE.
      IT_REPORT5-ZWIDTH   = <FS_REPORT3>-ZWIDTH.
      IT_REPORT5-ZLENGTH  = <FS_REPORT3>-ZLENGTH.
      IT_REPORT5-ZTREAT   = <FS_REPORT3>-ZTREAT.
      IT_REPORT5-ZLINE    = <FS_REPORT3>-ZLINE.
      IT_REPORT5-ZMONTH   = <FS_REPORT3>-ZMONTH.
      IT_REPORT5-ZCUSTM   = <FS_REPORT3>-ZCUSTM.
      IT_REPORT5-ISTAT1   = <FS_REPORT3>-ISTAT1.
      IT_REPORT5-ISTAT2   = <FS_REPORT3>-ISTAT2.
      IT_REPORT5-OBJNR    = <FS_REPORT3>-OBJNR.
      IT_REPORT5-ZZWIDTH  = <FS_REPORT3>-ZZWIDTH.
      IT_REPORT5-ZZLENGTH = <FS_REPORT3>-ZZLENGTH.
      IT_REPORT5-ISDD     = <FS_REPORT3>-ISDD.
      IT_REPORT5-ISDZ     = <FS_REPORT3>-ISDZ.
      IT_REPORT5-PERNR    = <FS_REPORT3>-PERNR.
      IT_REPORT5-AMEIN    = <FS_REPORT3>-AMEIN.
      IT_REPORT5-GSTRI    = <FS_REPORT3>-GSTRI.
      IT_REPORT5-GSUZI    = <FS_REPORT3>-GSUZI.
      IT_REPORT5-WEMNG    = <FS_REPORT3>-WEMNG.
      IT_REPORT5-ISM01    = <FS_REPORT3>-ISM01.
*      IT_REPORT5-IEDD     = <FS_REPORT3>-IEDD.
*      IT_REPORT5-IEDZ     = <FS_REPORT3>-IEDZ.
      IT_REPORT5-LENGTH_I = <FS_REPORT3>-LENGTH_I.
      IT_REPORT5-WEIGHT_I = <FS_REPORT3>-WEIGHT_I.
      CLEAR: T_VAL_TAB, TA_BATCH.
      REFRESH: T_VAL_TAB, TA_BATCH.
      IF IT_REPORT5-CHARG NE ''.

        CLEAR : MBLNR,SGTXT,LENGTH,WEIGHT.
        SELECT MBLNR SGTXT INTO (MBLNR,SGTXT)
          FROM MSEG
          WHERE AUFNR = IT_REPORT5-AUFNR
          AND   BWART = '101'
          AND   CHARG = IT_REPORT5-CHARG
        ORDER BY MBLNR DESCENDING.
        ENDSELECT.
        SPLIT SGTXT AT '-' INTO LENGTH WEIGHT.
        IT_REPORT5-LENGTH_I = LENGTH .
        IT_REPORT5-WEIGHT_I = WEIGHT .

        CALL FUNCTION 'VB_INIT'.
        CALL FUNCTION 'VB_BATCH_GET_DETAIL'
          EXPORTING
            MATNR              = IT_REPORT5-PLNBEZ
            CHARG              = IT_REPORT5-CHARG
            WERKS              = IT_REPORT5-WERKS
            GET_CLASSIFICATION = 'X'
          TABLES
            CHAR_OF_BATCH      = TA_BATCH.

        IF SY-SUBRC <> 0.
        ENDIF.
        IF TA_BATCH IS NOT INITIAL.
*            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCODE'.
*            IF SY-SUBRC EQ 0.
*              IT_REPORT5-ZZCODE = WA_BATCH-ATWTB.
*            ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZNOMORROLL'.
          IF SY-SUBRC EQ 0.
            IT_REPORT5-ZZNOMORROLL = WA_BATCH-ATWTB.
          ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZWIDTH'.
          IF SY-SUBRC EQ 0.
            CLEAR : LENGTH.
            LENGTH = WA_BATCH-ATWTB.
            REPLACE ALL OCCURRENCES OF ',' IN LENGTH WITH SPACE.
            IT_REPORT5-ZZWIDTH = LENGTH.
*            IT_REPORT5-ZZWIDTH = WA_BATCH-ATWTB.
          ENDIF.
          IF IT_REPORT5-AUART = 'ZP11'.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTHSHT'.
            IF SY-SUBRC EQ 0.
              IT_REPORT5-ZZLENGTH = WA_BATCH-ATWTB.
            ENDIF.
          ELSE.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTH'.
            IF SY-SUBRC EQ 0.
              CLEAR : LENGTH.
              LENGTH = WA_BATCH-ATWTB.
              REPLACE ALL OCCURRENCES OF ',' IN LENGTH WITH SPACE.
              IT_REPORT5-ZZLENGTH = LENGTH.
*              IT_REPORT5-ZZLENGTH = WA_BATCH-ATWTB.
            ENDIF.
          ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZGRADEJR'.
          IF SY-SUBRC EQ 0.
            IT_REPORT5-ZZGRADEJR = WA_BATCH-ATWTB.
          ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
          IF SY-SUBRC EQ 0.
            SPLIT WA_BATCH-ATWTB AT SPACE INTO IT_REPORT5-ZZCONVERSION IT_REPORT5-ZZCONVERSION2.
            REPLACE ALL OCCURRENCES OF ',' IN IT_REPORT5-ZZCONVERSION WITH SPACE.
            IT_REPORT5-ZZCONVERSION1 = IT_REPORT5-ZZCONVERSION.
          ELSE.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
            IF SY-SUBRC EQ 0.
              SPLIT WA_BATCH-ATWTB AT SPACE INTO IT_REPORT5-ZZCONVERSION IT_REPORT5-ZZCONVERSION2.
              REPLACE ALL OCCURRENCES OF ',' IN IT_REPORT5-ZZCONVERSION WITH SPACE.
              IT_REPORT5-ZZCONVERSION1 = IT_REPORT5-ZZCONVERSION.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR : BWART1,BWART2,MBLNR.
      SELECT MENGE MEINS BWART MBLNR INTO (IT_REPORT5-MENGE,IT_REPORT5-MEINS,BWART,MBLNR)
        FROM MSEG
        WHERE AUFNR  = <FS_REPORT4>-AUFNR
        AND   BWART  IN ('101','102')
        AND   CHARG = <FS_REPORT4>-CHARG.

        IF BWART = '101'.
          BWART1 = 'X'.
        ELSEIF BWART = '102'.
          BWART2 = 'X'.
        ENDIF.

        CLEAR : BWART.
      ENDSELECT.

      IF BWART1 = 'X' AND BWART2 = 'X'.
        IT_REPORT5-ISM01 = IT_REPORT5-MENGE = IT_REPORT5-MEINS = ''.
      ELSE.
        SELECT SINGLE AFRU~ISM01 INTO IT_REPORT5-ISM01
          FROM AFWI
          JOIN AFRU ON AFWI~RUECK = AFRU~RUECK
          WHERE MBLNR = MBLNR.
        IF SY-SUBRC NE 0.
          SELECT SINGLE AFRU~ISM01 INTO IT_REPORT5-ISM01
              FROM AFRU
              WHERE AFRU~LTXA1 = MBLNR.
        ENDIF.
*        ENDIF.
      ENDIF.


      APPEND: IT_REPORT5.
      CLEAR: IT_REPORT5.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      IT_REPORT5          = <FS_REPORT3>.
      IT_REPORT5-ZZLENGTH = IT_REPORT5-ZZWIDTH = '' .
      APPEND: IT_REPORT5.
      CLEAR: IT_REPORT5.
    ENDIF.
  ENDLOOP.

  SORT IT_REPORT5 BY AUFNR ASCENDING.

  IT_REPORT6[] = IT_REPORT5[].

  DELETE IT_REPORT5 WHERE RUECK NE '0000000000' AND ERFME EQ ' '. "Confirm sukses GR sukses dan
  "Confirm gagal GR gagal cek table AFWI untuk Goods Movementnya

  DELETE IT_REPORT6 WHERE RUECK EQ ' ' OR ( RUECK NE ' ' AND ERFME NE ' ' ). "Confirm sukses GR gagal cek table AFRU untuk Goods Movementnya

  SORT IT_REPORT6 BY AUFNR ASCENDING.
  DESCRIBE TABLE IT_REPORT6 LINES LINE.

  IF LINE NE 0.
    SELECT AFRU~AUFNR AS AUFNR
           AFRU~RUECK AS RUECK
           AFRU~RMZHL AS RMZHL
           AFRU~IEDD  AS IEDD
           AFRU~IEDZ  AS IEDZ
           MSEG~ERFMG AS ERFMG
           MSEG~ERFME AS ERFME
           MSEG~CHARG AS CHARG
           MSEG~MBLNR AS MBLNR
           MSEG~MJAHR AS MJAHR
           MSEG~ZEILE AS ZEILE
      FROM AFRU
*      JOIN MSEG ON AFRU~WABLNR = MSEG~MBLNR
      JOIN MSEG ON AFRU~LTXA1 = MSEG~MBLNR
      INTO CORRESPONDING FIELDS OF TABLE IT_REPORT7
      FOR ALL ENTRIES IN IT_REPORT6
      WHERE AFRU~AUFNR = IT_REPORT6-AUFNR AND
            AFRU~STOKZ = ' ' AND
            AFRU~STZHL = ' ' AND
            AFRU~ISDD IN ISDD AND
            MSEG~BWART = '101'.
  ENDIF.

  SORT IT_REPORT7 BY AUFNR ASCENDING.

  LOOP AT IT_REPORT6 ASSIGNING <FS_REPORT6>.
    LOOP AT IT_REPORT7 ASSIGNING <FS_REPORT7> WHERE RUECK = <FS_REPORT6>-RUECK AND
                                                    RMZHL = <FS_REPORT6>-RMZHL AND
                                                    AUFNR = <FS_REPORT6>-AUFNR.

      IT_REPORT8          = <FS_REPORT7>.
      IT_REPORT8-PLNBEZ   = <FS_REPORT6>-PLNBEZ.
      IT_REPORT8-WERKS    = <FS_REPORT6>-WERKS.
      IT_REPORT8-AUART    = <FS_REPORT6>-AUART.
      IT_REPORT8-GAMNG    = <FS_REPORT6>-GAMNG.
      IT_REPORT8-GMEIN    = <FS_REPORT6>-GMEIN.
      IT_REPORT8-GSTRP    = <FS_REPORT6>-GSTRP.
      IT_REPORT8-GSUZP    = <FS_REPORT6>-GSUZP.
      IT_REPORT8-VERID    = <FS_REPORT6>-VERID.
      IT_REPORT8-ZCODE    = <FS_REPORT6>-ZCODE.
      IT_REPORT8-ZWIDTH   = <FS_REPORT6>-ZWIDTH.
      IT_REPORT8-ZLENGTH  = <FS_REPORT6>-ZLENGTH.
      IT_REPORT8-ZTREAT   = <FS_REPORT6>-ZTREAT.
      IT_REPORT8-ZLINE    = <FS_REPORT6>-ZLINE.
      IT_REPORT8-ZMONTH   = <FS_REPORT6>-ZMONTH.
      IT_REPORT8-ZCUSTM   = <FS_REPORT6>-ZCUSTM.
      IT_REPORT8-ISTAT1   = <FS_REPORT6>-ISTAT1.
      IT_REPORT8-ISTAT2   = <FS_REPORT6>-ISTAT2.
      IT_REPORT8-OBJNR    = <FS_REPORT6>-OBJNR.
      IT_REPORT8-ZZWIDTH  = <FS_REPORT6>-ZZWIDTH.
      IT_REPORT8-ZZLENGTH = <FS_REPORT6>-ZZLENGTH.
      IT_REPORT8-ISDD     = <FS_REPORT6>-ISDD.
      IT_REPORT8-ISDZ     = <FS_REPORT6>-ISDZ.
      IT_REPORT8-PERNR    = <FS_REPORT6>-PERNR.
      IT_REPORT8-AMEIN    = <FS_REPORT6>-AMEIN.
      IT_REPORT8-GSTRI    = <FS_REPORT6>-GSTRI.
      IT_REPORT8-GSUZI    = <FS_REPORT6>-GSUZI.
      IT_REPORT8-WEMNG    = <FS_REPORT6>-WEMNG.
      IT_REPORT8-ISM01    = <FS_REPORT6>-ISM01.
*      IT_REPORT8-IEDD     = <FS_REPORT6>-IEDD.
*      IT_REPORT8-IEDZ     = <FS_REPORT6>-IEDZ.
      IT_REPORT8-LENGTH_I = <FS_REPORT6>-LENGTH_I.
      IT_REPORT8-WEIGHT_I = <FS_REPORT6>-WEIGHT_I.
      CLEAR: T_VAL_TAB, TA_BATCH.
      REFRESH: T_VAL_TAB, TA_BATCH.
      IF IT_REPORT8-CHARG NE ''.

        CLEAR : MBLNR,SGTXT,LENGTH,WEIGHT.
        SELECT MBLNR SGTXT INTO (MBLNR,SGTXT)
          FROM MSEG
          WHERE AUFNR = IT_REPORT8-AUFNR
          AND   BWART = '101'
          AND   CHARG = IT_REPORT8-CHARG
        ORDER BY MBLNR DESCENDING.
        ENDSELECT.
        SPLIT SGTXT AT '-' INTO LENGTH WEIGHT.
        IT_REPORT8-LENGTH_I = LENGTH .
        IT_REPORT8-WEIGHT_I = WEIGHT .

        CALL FUNCTION 'VB_INIT'.
        CALL FUNCTION 'VB_BATCH_GET_DETAIL'
          EXPORTING
            MATNR              = IT_REPORT8-PLNBEZ
            CHARG              = IT_REPORT8-CHARG
            WERKS              = IT_REPORT8-WERKS
            GET_CLASSIFICATION = 'X'
          TABLES
            CHAR_OF_BATCH      = TA_BATCH.

        IF SY-SUBRC <> 0.
        ENDIF.
        IF TA_BATCH IS NOT INITIAL.
*            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCODE'.
*            IF SY-SUBRC EQ 0.
*              IT_REPORT8-ZZCODE = WA_BATCH-ATWTB.
*            ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZNOMORROLL'.
          IF SY-SUBRC EQ 0.
            IT_REPORT8-ZZNOMORROLL = WA_BATCH-ATWTB.
          ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZWIDTH'.
          IF SY-SUBRC EQ 0.
            IT_REPORT8-ZZWIDTH = WA_BATCH-ATWTB.
          ENDIF.
          IF IT_REPORT8-AUART = 'ZP11'.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTHSHT'.
            IF SY-SUBRC EQ 0.
              IT_REPORT8-ZZLENGTH = WA_BATCH-ATWTB.
            ENDIF.
          ELSE.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTH'.
            IF SY-SUBRC EQ 0.
              IT_REPORT8-ZZLENGTH = WA_BATCH-ATWTB.
            ENDIF.
          ENDIF.
          READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
          IF SY-SUBRC EQ 0.
            SPLIT WA_BATCH-ATWTB AT SPACE INTO IT_REPORT5-ZZCONVERSION IT_REPORT5-ZZCONVERSION2.
            REPLACE ALL OCCURRENCES OF ',' IN IT_REPORT5-ZZCONVERSION WITH SPACE.
            IT_REPORT5-ZZCONVERSION1 = IT_REPORT5-ZZCONVERSION.
          ELSE.
            READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
            IF SY-SUBRC EQ 0.
              SPLIT WA_BATCH-ATWTB AT SPACE INTO IT_REPORT5-ZZCONVERSION IT_REPORT5-ZZCONVERSION2.
              REPLACE ALL OCCURRENCES OF ',' IN IT_REPORT5-ZZCONVERSION WITH SPACE.
              IT_REPORT5-ZZCONVERSION1 = IT_REPORT5-ZZCONVERSION.
            ENDIF.
          ENDIF.
        ENDIF.

        CLEAR : BWART1,BWART2.
        SELECT MENGE MEINS BWART MBLNR INTO (IT_REPORT8-MENGE,IT_REPORT8-MEINS,BWART,MBLNR)
          FROM MSEG
          WHERE AUFNR  = <FS_REPORT7>-AUFNR
          AND   BWART  IN ('101','102')
          AND   CHARG = <FS_REPORT7>-CHARG.

          IF BWART = '101'.
            BWART1 = 'X'.
          ELSEIF BWART = '102'.
            BWART2 = 'X'.
          ENDIF.
          CLEAR : BWART.
        ENDSELECT.

        IF BWART1 = 'X' AND BWART2 = 'X'.
          IT_REPORT8-ISM01 = IT_REPORT8-MENGE = IT_REPORT8-MEINS = ''.
        ELSE.
          SELECT SINGLE AFRU~ISM01 INTO IT_REPORT8-ISM01
            FROM AFWI
            JOIN AFRU ON AFWI~RUECK = AFRU~RUECK
            WHERE MBLNR = MBLNR.
          IF SY-SUBRC NE 0.
            SELECT SINGLE AFRU~ISM01 INTO IT_REPORT8-ISM01
                FROM AFRU
                WHERE AFRU~LTXA1 = MBLNR.
          ENDIF.
        ENDIF.

      ENDIF.


      APPEND: IT_REPORT8.
      CLEAR: IT_REPORT8.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      IT_REPORT8          = <FS_REPORT6>.
      IT_REPORT8-ZZLENGTH = IT_REPORT8-ZZWIDTH = ''.
      APPEND: IT_REPORT8.
      CLEAR: IT_REPORT8.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF IT_REPORT5 TO IT_REPORT.
  APPEND LINES OF IT_REPORT8 TO IT_REPORT.

  SORT IT_REPORT BY AUFNR ISDD ISDZ ASCENDING.

  IT_REPORT5[] = IT_REPORT8[] = IT_REPORT[].

  LOOP AT IT_REPORT.
    CLEAR : QTYGR,TOLENG,TOCON,MBLNR,LENGTH_GR,WEIGHT_GR.

    IT_REPORT-LENGTH = IT_REPORT-ZZLENGTH.
    IT_REPORT-WIDTH  = IT_REPORT-ZZWIDTH.
    LOOP AT IT_REPORT8 WHERE AUFNR = IT_REPORT-AUFNR.
*      QTYGR  = QTYGR + IT_REPORT8-ERFMG.
      TOLENG = TOLENG + IT_REPORT8-ZZLENGTH.
      TOCON  = TOCON + IT_REPORT8-ZZCONVERSION1.
      LENGTH_GR = LENGTH_GR + IT_REPORT8-LENGTH_I.
      WEIGHT_GR = WEIGHT_GR + IT_REPORT8-WEIGHT_I.
    ENDLOOP.
*    IT_REPORT-ERFMG         = QTYGR.

    SELECT SINGLE CAWNT~ATWTB INTO IT_REPORT-ZZCODE
       FROM CAWNT
       JOIN CAWN ON CAWNT~ATZHL = CAWN~ATZHL
       AND  CAWN~ATINN = CAWNT~ATINN
       WHERE CAWN~ATWRT = IT_REPORT-ZCODE.

    CLEAR : CLABS.
    IF IT_REPORT-CHARG NE ''.
      SELECT CLABS CINSM  INTO (CLABS,CINSM)
         FROM MCHB
         WHERE CHARG = IT_REPORT-CHARG
         AND   MATNR = IT_REPORT-PLNBEZ
         AND   WERKS = IT_REPORT-WERKS.
        STOCK = CLABS + CINSM.
        CLEAR : CLABS,CINSM.
      ENDSELECT.
      IF STOCK = 0.
*          IT_REPORT-STOCK = 'Not Available'.
        IT_REPORT-STOCK = 0.
      ELSE.
        IT_REPORT-STOCK = STOCK.
*          IT_REPORT-STOCK = 'Available'.
      ENDIF.
    ELSE.
      IT_REPORT-STOCK = 0.
*       IT_REPORT-STOCK = 'Not Available'.
    ENDIF.

    IT_REPORT-ZZLENGTH       = TOLENG.
    IT_REPORT-TOT_CONVERSION = TOCON.
    IT_REPORT-LENGTH_H       = LENGTH_GR.
    IT_REPORT-WEIGHT_H       = WEIGHT_GR.
    MODIFY IT_REPORT.
  ENDLOOP.

  IT_REPORT5[] = IT_REPORT8[] = IT_REPORT[].
  DELETE ADJACENT DUPLICATES FROM IT_REPORT COMPARING AUFNR ZZWIDTH.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV .
  T_PRINT-NO_PRINT_SELINFOS = 'X'.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  WA_VARIANTE-REPORT = D_REPID.
  PERFORM F_LAYOUT.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_SORT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " ALV

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
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
*     I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_REPORT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
*  REFRESH FT_EXTAB.
*  CLEAR FT_EXTAB.
  DATA : T_EXTAB TYPE  SLIS_EXTAB OCCURS 0 WITH HEADER LINE.
  T_EXTAB-FCODE = '&XXL'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&OL0'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&OAD'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&AVE'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&AQW'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&ALL'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&EB9'.
*  APPEND T_EXTAB.
*  T_EXTAB-FCODE = 'REFRESH'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&INFO'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&SAL'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&UMC'.
  APPEND T_EXTAB.
  T_EXTAB-FCODE = '&SUM'.
  APPEND T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING T_EXTAB.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.
  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN 'REFRESH'.
      CLEAR: FU_UCOMM.
      FU_SELFIELD-REFRESH = 'X'.
      PERFORM GET_DATA.
      PERFORM ALV_HIE.
      LEAVE SCREEN.
    WHEN 'TECO'.
      CLEAR: FU_UCOMM, TORDERKEY, MESSAGE, TA_MESSAGE.
      REFRESH: TORDERKEY, TA_MESSAGE.
      LOOP AT IT_DETAIL WHERE MARK = 'X'.
*      READ TABLE IT_REPORT INDEX FU_SELFIELD-TABINDEX.
        TORDERKEY-ORDER_NUMBER = IT_DETAIL-AUFNR.
        APPEND TORDERKEY.
      ENDLOOP.
      CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
        TABLES
          ORDERS        = TORDERKEY
          DETAIL_RETURN = IT_RET.

      READ TABLE IT_RET WITH KEY TYPE = 'E'.

      IF SY-SUBRC NE 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        IF SY-SUBRC EQ 0.
          LINENO = 0.
          LOOP AT IT_RET.
            LINENO = LINENO + 1.
            TA_MESSAGE-MSGID  = IT_RET-ID.
            TA_MESSAGE-MSGTY  = IT_RET-TYPE.
            TA_MESSAGE-MSGNO  = IT_RET-NUMBER.
            TA_MESSAGE-MSGV1  = IT_RET-MESSAGE_V1.
            TA_MESSAGE-MSGV2  = IT_RET-MESSAGE_V2.
            TA_MESSAGE-MSGV3  = IT_RET-MESSAGE_V3.
            TA_MESSAGE-MSGV4  = IT_RET-MESSAGE_V4.
            TA_MESSAGE-LINENO = LINENO.
            APPEND TA_MESSAGE.
            CLEAR TA_MESSAGE.
          ENDLOOP.

          CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
            TABLES
              I_MESSAGE_TAB = TA_MESSAGE.
        ELSE.
          CONCATENATE 'TECO Process Order' IT_REPORT-AUFNR 'Gagal!' INTO MESSAGE SEPARATED BY SPACE.
          MESSAGE MESSAGE TYPE 'I'.
        ENDIF.
      ELSE.
        LOOP AT IT_RET.
          LINENO = LINENO + 1.
          TA_MESSAGE-MSGID  = IT_RET-ID.
          TA_MESSAGE-MSGTY  = IT_RET-TYPE.
          TA_MESSAGE-MSGNO  = IT_RET-NUMBER.
          TA_MESSAGE-MSGV1  = IT_RET-MESSAGE_V1.
          TA_MESSAGE-MSGV2  = IT_RET-MESSAGE_V2.
          TA_MESSAGE-MSGV3  = IT_RET-MESSAGE_V3.
          TA_MESSAGE-MSGV4  = IT_RET-MESSAGE_V4.
          TA_MESSAGE-LINENO = LINENO.
          APPEND TA_MESSAGE.
          CLEAR TA_MESSAGE.
        ENDLOOP.

        CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
          TABLES
            I_MESSAGE_TAB = TA_MESSAGE.
      ENDIF.
    WHEN '&IC1'.
*      CLEAR: FU_UCOMM.
*      READ TABLE IT_REPORT INDEX FU_SELFIELD-TABINDEX.
*      IF SY-SUBRC EQ 0.
*        IT_DETAIL[] = IT_REPORT5[].
*        DELETE IT_DETAIL WHERE AUFNR NE IT_REPORT-AUFNR.
*        PERFORM DETAIL_DISPLAY.
*      ENDIF.
    WHEN '&EXCEL'.
      PERFORM F_IMPORT_EXCEL.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-BOX_FIELDNAME = 'MARK'.
  WA_LAYOUT-BOX_TABNAME = 'IT_REPORT'.
*  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-NUMC_SUM = 'X'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG2 USING 'IT_REPORT' :
   'AUFNR'  '' ''  '' '15' 'PO NO.'   '' '' 'X' '' ,
   'ZLINE'  '' ''  '' '20' 'Production Line'   '' ' ' 'X' '' ,
   'ZCODE'  '' ''  '' '30' 'Type Film'   '' ' ' 'X' '' ,
   'ZWIDTH'  '' ''  '' '20' 'Width'   '' ' ' 'X' 'X' ,
   'ZLENGTH'  '' ''  '' '20' 'Length'   '' ' ' 'X' 'X' ,
   'ZTREAT'  '' ''  '' '20' 'Treatment'   '' ' ' 'X' '' ,
   'GAMNG'  '' ''  '' '16' 'Quantity Plan PO'   '' ' ' 'X' '' ,
   'GMEIN'  '' ''  '' '5' 'UoM'   '' ' ' 'X' '' ,
   'ZCUSTM'  '' ''  '' '20' 'Customer'   '' ' ' 'X' '' ,
   'GSTRP'  '' ''  '' '10' 'Start Date'   '' ' ' 'X' '' ,
   'GSUZP'  '' ''  '' '10' 'Start Time'   '' ' ' 'X' '' ,
   'WEMNG'  '' ''  '' '13' 'QTY GR'   '' '' 'X' '' ,
   'AMEIN'  '' ''  '' '20' 'UOM'   '' ' ' 'X' '' , "-> new
   'ZZWIDTH'  '' ''  '' '20' 'Width Actual'   '' '' 'X' 'X' ,
   'ZZLENGTH'  '' ''  '' '20' 'Total Length Actual'   '' '' 'X' 'X' ,
   'ZZCONVERSION1'  '' ''  '' '20' 'Total Weight Actual'   '' '' 'X' 'X' ,
   'ISTAT2'  '' ''  '' '10' 'Status'   '' ' ' 'X' '' .


*   'PLNBEZ'  '' ''  '' '18' 'Material'   '' ' ' 'X' '' , "-> hide
*   'WERKS'  '' ''  '' '4' 'Plant'   '' ' ' 'X' '' , "-> hide
*   'AUART'  '' ''  '' '10' 'Order Type'   '' ' ' 'X' '' , "-> hide
*   'VERID'  '' ''  '' '13' 'Prod. Version'   '' ' ' 'X' '' , "-> hide
*   'ZMONTH'  '' ''  '' '20' 'Bulan/Tahun Produksi'   '' ' ' 'X' '' , "->hide
*   'ZNOSHEET'  '' ''  '' '20' 'Number of Sheets'   '' ' ' 'X' '' , "-> new
*   'SBMNG'  '' ''  '' '20' 'Qty Plan PO'   '' ' ' 'X' '' ,  "-> new "->hide
*   'SBMEH'  '' ''  '' '20' 'UOM'   '' ' ' 'X' '' ,  "-> new "->hide
*   'ERFME'  '' ''  '' '6' 'UoM GR'   '' '' 'X' '' , "->hide
*   'MENGE'  '' ''  '' '20' 'QTY GR'   '' ' ' 'X' '' ,  "-> new "->hide
*   'MEINS'  '' ''  '' '20' 'UOM'   '' ' ' 'X' '' ,  "-> new "->hide
*   'ISDD'  '' ''  '' '22' 'Actual Production Date'   '' ' ' 'X' '' , "->hide
*   'ISDZ'  '' ''  '' '22' 'Actual Production Time'   '' ' ' 'X' 'X' , "->hide
*   'CHARG'  '' ''  '' '10' 'Batch'   '' ' ' 'X' '' , "->hide
*   'PERNR'  '' ''  '' '10' 'NIK'   '' ' ' 'X' 'X' , "->hide
*   'ZZGRADEJR'  '' ''  '' '20' 'Status JR'   '' ' ' 'X' '' ,  "-> new "->hide
*   'ISTAT1'  '' ''  '' '50' 'System Status'   '' ' ' 'X' '' , "->hide

ENDFORM.                    " F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F4_ZLINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_ZLINE .
  SELECT ZLINE FROM AUFK INTO TABLE IT_ZLINE.
  SORT IT_ZLINE BY ZLINE.
  DELETE ADJACENT DUPLICATES FROM IT_ZLINE COMPARING ALL FIELDS.
  DELETE IT_ZLINE WHERE ZLINE EQ ' '.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLINE'
      DYNPPROG        = SY-CPROG  "Program
      DYNPNR          = SY-DYNNR  "Dynpro number
      DYNPROFIELD     = 'ZLINE'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IT_ZLINE
      RETURN_TAB      = IT_RETURN1
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.                    " F4_ZLINE
*&---------------------------------------------------------------------*
*&      Form  F4_ZCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_ZCODE .
  SELECT ZCODE FROM AUFK INTO TABLE IT_ZCODE.
  SORT IT_ZCODE BY ZCODE.
  DELETE ADJACENT DUPLICATES FROM IT_ZCODE COMPARING ALL FIELDS.
  DELETE IT_ZCODE WHERE ZCODE EQ ' '.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZCODE'
      DYNPPROG        = SY-CPROG  "Program
      DYNPNR          = SY-DYNNR  "Dynpro number
      DYNPROFIELD     = 'ZCODE'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IT_ZCODE
      RETURN_TAB      = IT_RETURN2
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.                    " F4_ZCODE
*&---------------------------------------------------------------------*
*&      Form  CHECK_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_STATUS .
  CLEAR: IT_STAT.
  REFRESH: IT_STAT.

  IT_STAT-OPTION = 'EQ'.
  IT_STAT-SIGN = 'I'.

  IF R1 = 'X'.
    IT_STAT-LOW = 'I0001'.
    APPEND IT_STAT.

    IT_STAT-LOW = 'I0002'.
    APPEND IT_STAT.
  ENDIF.

  IF R2 = 'X'.
    IT_STAT-LOW = 'I0010'.
    APPEND IT_STAT.

    IT_STAT-LOW = 'I0074'.
    APPEND IT_STAT.

    IT_STAT-LOW = 'I0321'.
    APPEND IT_STAT.
  ENDIF.

  IF R3 = 'X'.
    IT_STAT-LOW = 'I0009'.
    APPEND IT_STAT.

    IT_STAT-LOW = 'I0012'.
    APPEND IT_STAT.
  ENDIF.

  IF R4 = 'X'.
    IT_STAT-LOW = 'I0045'.
    APPEND IT_STAT.
  ENDIF.
ENDFORM.                    " CHECK_STATUS
*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SORT .
  CLEAR: T_SORT.
  REFRESH: T_SORT.

  T_SORT-FIELDNAME = 'AUFNR'.
  T_SORT-TABNAME   = 'IT_REPORT'.
  T_SORT-UP        = 'X'.
  T_SORT-SUBTOT    = 'X'.
  APPEND T_SORT.
ENDFORM.                    " F_SORT