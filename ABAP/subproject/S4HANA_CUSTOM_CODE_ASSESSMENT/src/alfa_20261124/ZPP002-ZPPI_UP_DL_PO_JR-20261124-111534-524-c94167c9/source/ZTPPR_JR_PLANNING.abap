*&---------------------------------------------------------------------*
*& Report  ZPPR_JR_PLANNING
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTPPR_JR_PLANNING.
INCLUDE ZINCL_ERP_SQL.

TABLES : CRHD,AFKO,AUFK.

DATA : BEGIN OF IT_EXEC OCCURS 0,
        ICON TYPE ICON-ID,
        ISTAT TYPE TJ02T-ISTAT,
        WERKS LIKE AUFK-WERKS,
        AUFNR LIKE AUFK-AUFNR,
        AUART LIKE AUFK-AUART,
        PLNBEZ LIKE AFKO-PLNBEZ,
        MAKTX LIKE MAKT-MAKTX,
        GSTRP LIKE AFKO-GSTRP,
        GSUZP LIKE AFKO-GSUZP,
        OBJNR LIKE AUFK-OBJNR,
        TXT04 LIKE TJ02T-TXT04,
        ZSTAT LIKE TJ02T-TXT30,
        ARBPL LIKE CRHD-ARBPL,
        GAMNG LIKE AFKO-GAMNG,
        GMEIN LIKE AFKO-GMEIN,
       END OF IT_EXEC.

TYPES : BEGIN OF T_DATA,
          AUFNR TYPE AUFK-AUFNR,
          AUART TYPE AUFK-AUART,
          WERKS TYPE AUFK-WERKS,
          ARBPL TYPE CRHD-ARBPL,
          GSTRP TYPE AFKO-GSTRP,
          GSUZP TYPE AFKO-GSUZP,
          PLNBEZ TYPE AFKO-PLNBEZ,
          MAKTX TYPE MAKT-MAKTX,
          GAMNG TYPE AFKO-GAMNG,
          GMEIN(30),
          ZCODE(30),
          ZTYPE(30),
          ZWIDTH(30),
          ZLENGTH(30),
          ZLINE(30),
          ZTREAT(30),
          ZCUSTM(30),
          ZNOSHEET(30),
          ZQTY(30),
          ZSTAT(30),
       END OF T_DATA.

DATA : IT_DATA TYPE T_DATA OCCURS 0 WITH HEADER LINE.

DATA : V_ATINN LIKE CAWN-ATINN,
       ZVENTRIES LIKE STANDARD TABLE OF VTENTRIES WITH HEADER LINE.

SELECT-OPTIONS : S_ARBPL FOR CRHD-ARBPL NO-DISPLAY.
SELECT-OPTIONS : S_GSTRP FOR AFKO-GSTRP NO-DISPLAY.
SELECT-OPTIONS : S_AUFNR FOR AUFK-AUFNR OBLIGATORY.

START-OF-SELECTION.
  PERFORM CHECK_SERVER.
  WAIT UP TO 3 SECONDS.
  PERFORM GET_DATA.
  INSERT_LOG_SQL IT_DATA AUFNR 'ZTPP002'.

  IF IT_DATA[] IS INITIAL.
    VARSTATUS = '0'. VARMSG = ''.
    PERFORM UPDATE_LOG_SQL.
  ELSE.
    PERFORM INSERT_SQL.
    PERFORM UPDATE_LOG_SQL.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  DATA :  DTHICK LIKE CAWNT-ATWTB,
         PTHICK TYPE P DECIMALS 2,
         DDENS LIKE CAWNT-ATWTB,
         PDENS TYPE P DECIMALS 2,
         ZPBASAL TYPE F,
         ZPYASAL TYPE F,
         ZPBBARU LIKE CALE-ABSDATE,
         ZPYBARU LIKE CALE-ABSDATE,
         FTXTQTY TYPE P DECIMALS 3 VALUE 0.

  SELECT DISTINCT AUFK~WERKS AUFK~AUFNR AFKO~PLNBEZ AFKO~GSTRP AFKO~GSUZP AUFK~OBJNR AUFK~AUART CRHD~ARBPL AFKO~GAMNG AFKO~GMEIN AUFK~AUTYP AS ICON
    INTO CORRESPONDING FIELDS OF TABLE IT_EXEC
  FROM CRHD
    JOIN AFVC ON CRHD~OBJID = AFVC~ARBID
    JOIN AFKO ON AFKO~AUFPL = AFVC~AUFPL
    JOIN AUFK ON AUFK~AUFNR = AFKO~AUFNR
  WHERE "CRHD~ARBPL IN S_ARBPL AND
*        AFKO~GSTRP IN S_GSTRP AND
        AUFK~AUFNR IN S_AUFNR.

  DELETE IT_EXEC WHERE ICON NE '40'.
  IT_EXEC-ICON = ''.
  MODIFY IT_EXEC TRANSPORTING ICON WHERE ICON NE ''.

  DELETE IT_EXEC WHERE
    AUART NE 'ZP01'
    AND AUART NE 'ZP02'
    AND AUART NE 'ZP03'
    AND AUART NE 'ZP04'
    AND AUART NE 'ZP05'
    AND AUART NE 'ZP06'
    AND AUART NE 'ZP07'
    AND AUART NE 'ZP08'
    AND AUART NE 'ZP09'
    AND AUART NE 'ZP10'
    AND AUART NE 'ZP11'
    AND AUART NE 'ZP12'     "ADDED FOR EXLAM 16.01.2019 - ADD ORDER TYPE ZP12
    " Added by William at 24.07.2022 (OPP7 CPP1)
    AND AUART NE 'ZP13'
    AND AUART NE 'ZP14'
    AND AUART NE 'ZP15'
    AND AUART NE 'ZP16'
    AND AUART NE 'ZP17'
    AND AUART NE 'ZP18'
    " End added by William at 24.07.2022 (OPP7 CPP1)
    AND AUART NE 'ZTR1'
    AND AUART NE 'ZTR2'
    AND AUART NE 'ZTR3'
    AND AUART NE 'ZTR4'
    AND AUART NE 'ZTR5'
    AND AUART NE 'ZTR6'
    AND AUART NE 'ZTR7'    "ADDED FOR EXLAM 16.01.2019 - ADD ORDER TYPE ZTR7
    " Added by William at 24.07.2022 (OPP7 CPP1)
    AND AUART NE 'ZTR8'
    AND AUART NE 'ZTR9'
    AND AUART NE 'ZTRA'
    AND AUART NE 'ZTRB'
    AND AUART NE 'ZTRC'
    " End added by William at 24.07.2022 (OPP7 CPP1)\
    AND AUART NE 'ZTRD' "Add New Laminator
    .

  LOOP AT IT_EXEC.
    SELECT SINGLE ISTAT TXT30 TXT04 "COMPLETE STATUS
      INTO (IT_EXEC-ISTAT,IT_EXEC-ZSTAT, IT_EXEC-TXT04)
    FROM TJ02T
      JOIN JEST ON JEST~STAT = TJ02T~ISTAT
    WHERE OBJNR = IT_EXEC-OBJNR AND
          SPRAS = 'E' AND
          INACT NE 'X' AND
          TXT04 = 'TECO'.
    MODIFY IT_EXEC.
  ENDLOOP.

  DELETE IT_EXEC WHERE TXT04 = 'TECO'.

  LOOP AT IT_EXEC.
    SELECT SINGLE MAKTX
      INTO IT_EXEC-MAKTX
    FROM MAKT
      WHERE MATNR = IT_EXEC-PLNBEZ.

    PERFORM GET_STAT_ORDER USING IT_EXEC-OBJNR IT_EXEC-AUFNR CHANGING IT_EXEC-ZSTAT.
    MODIFY IT_EXEC.

    MOVE-CORRESPONDING IT_EXEC TO IT_DATA.

    SELECT SINGLE ZCODE ZWIDTH ZLENGTH ZLINE ZTREAT ZCUSTM ZNOSHEET
      INTO (IT_DATA-ZCODE,IT_DATA-ZWIDTH,IT_DATA-ZLENGTH,IT_DATA-ZLINE,IT_DATA-ZTREAT,IT_DATA-ZCUSTM, IT_DATA-ZNOSHEET)
    FROM AUFK
      WHERE AUFNR = IT_EXEC-AUFNR.

    WRITE IT_DATA-ZWIDTH TO IT_DATA-ZWIDTH NO-ZERO RIGHT-JUSTIFIED.
    WRITE IT_DATA-ZLENGTH TO IT_DATA-ZLENGTH NO-ZERO RIGHT-JUSTIFIED.

*THICKNESS*******************************************************
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZCODE'
      IMPORTING
        OUTPUT = V_ATINN.

    SELECT SINGLE CAWNT~ATWTB
      INTO (IT_DATA-ZTYPE)
    FROM CAWNT
     JOIN CAWN ON CAWN~ATINN = CAWNT~ATINN AND
                  CAWN~ATZHL = CAWNT~ATZHL
    WHERE ATWRT = IT_DATA-ZCODE AND
          CAWN~ATINN = V_ATINN AND
          CAWNT~SPRAS = 'E'.

*HITUNG QTY PLAN***************************************************
    IF IT_DATA-ZCODE IS NOT INITIAL.
      CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
        EXPORTING
          VAR_TABLE       = 'ZZCODE'
*         CHANGE_NO       =
*         DATE            =
        TABLES
          VAR_TAB_ENTRIES = ZVENTRIES
        EXCEPTIONS
          ERROR           = 1
          OTHERS          = 2.

      CONDENSE IT_DATA-ZCODE.
      READ TABLE ZVENTRIES WITH KEY VTVALUE = IT_DATA-ZCODE.
      IF SY-SUBRC = 0.
        DELETE ZVENTRIES WHERE VTLINENO NE ZVENTRIES-VTLINENO.
        READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZGRAMMAGE'.
        IF SY-SUBRC = 0.
          MOVE ZVENTRIES-VTVALUE TO DTHICK.
          PDENS = 1.
          MOVE DTHICK TO PTHICK.

          IF DTHICK IS INITIAL.
            READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'.
            IF SY-SUBRC = 0.
              MOVE ZVENTRIES-VTVALUE TO DTHICK.
              REPLACE ALL OCCURRENCES OF ',' IN DTHICK WITH ''.
              MOVE DTHICK TO PTHICK.
            ENDIF.
            READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'.
            IF SY-SUBRC = 0.
              MOVE ZVENTRIES-VTVALUE TO DDENS.
              REPLACE ALL OCCURRENCES OF ',' IN DDENS WITH ''.
              MOVE DDENS TO PDENS.
            ENDIF.
          ENDIF.
        ELSE.
          READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZTHICKNESS'.
          IF SY-SUBRC = 0.
            MOVE ZVENTRIES-VTVALUE TO DTHICK.
            REPLACE ALL OCCURRENCES OF ',' IN DTHICK WITH ''.
            MOVE DTHICK TO PTHICK.
          ENDIF.
          READ TABLE ZVENTRIES WITH KEY VTCHARACT = 'ZZDENSITY'.
          IF SY-SUBRC = 0.
            MOVE ZVENTRIES-VTVALUE TO DDENS.
            REPLACE ALL OCCURRENCES OF ',' IN DDENS WITH ''.
            MOVE DDENS TO PDENS.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF IT_DATA-AUART = 'ZP11'.
      ZPBASAL = ( IT_DATA-ZWIDTH * IT_DATA-ZLENGTH * PDENS * PTHICK * IT_DATA-ZNOSHEET ).
      ZPYASAL = 1000000000.
    ELSE.
      ZPBASAL = ( IT_DATA-ZWIDTH * IT_DATA-ZLENGTH * PDENS * PTHICK ).
      ZPYASAL = 1000000.
    ENDIF.

    FTXTQTY = ZPBASAL / ZPYASAL * IT_DATA-GAMNG.

    CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
      EXPORTING
        I_VALUE        = FTXTQTY
        I_DECIMALS     = 2
      IMPORTING
        O_NOMINATOR    = ZPBBARU
        O_DENOMINATOR  = ZPYBARU
        O_VALUE        = FTXTQTY
      EXCEPTIONS
        INPUT_INVALID  = 1
        OUTPUT_INVALID = 2
        OVERFLOW       = 3
        OTHERS         = 4.
    IT_DATA-ZQTY = FTXTQTY.
    APPEND IT_DATA.
  ENDLOOP.

  CONVERT_DATE IT_DATA GSTRP.
ENDFORM.                    "GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_STAT_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZOBJNR     text
*      -->ZAUFNR     text
*      -->ZSTAT      text
*----------------------------------------------------------------------*
FORM GET_STAT_ORDER USING ZOBJNR ZAUFNR CHANGING ZSTAT.
  DATA : DSTTXT LIKE BSVX-STTXT,
         VPSMNG LIKE AFPO-PSMNG,
         VWEMNG LIKE AFPO-WEMNG.

  CALL FUNCTION 'AIP9_STATUS_READ'
    EXPORTING
      I_OBJNR = ZOBJNR
    IMPORTING
      E_SYSST = DSTTXT.

  IF DSTTXT CP '*PCNF*' OR DSTTXT CP '*PDLV*' OR DSTTXT CP '*GMPS*'.
    ZSTAT = 'In Progress'.
  ELSEIF DSTTXT CP '*CRTD*' OR DSTTXT CP '*REL*'.
    ZSTAT = 'Created'.
  ENDIF.

  IF ZAUFNR IS NOT INITIAL.
    SELECT SINGLE PSMNG WEMNG
      INTO (VPSMNG,VWEMNG)
    FROM AFPO
      WHERE AUFNR = ZAUFNR.

    IF VPSMNG LE VWEMNG.
      ZSTAT = 'Completed'.
    ENDIF.
  ENDIF.
ENDFORM.                    "GET_STAT_ORDER

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL.

  LOOP AT IT_DATA.
    EXEC SQL.
      INSERT INTO TMP.RPT_ZPP002
      ([Order],
       OrderType,
       Plant,
       Workctr,
       BasStart,
       BasicStart,
       Material,
       Descr,
       Targetqty,
       Unit,
       FilmCode,
       FilmType,
       Width,
       Length,
       Line,
       Treatment,
       Customer,
       Numberofsheet,
       PlanningQtyinKG,
       Status,
       LastUpdated)
       VALUES
       (:IT_DATA-AUFNR,
        :IT_DATA-AUART,
        :IT_DATA-WERKS,
        :IT_DATA-ARBPL,
        :IT_DATA-GSTRP,
        :IT_DATA-GSUZP,
        :IT_DATA-PLNBEZ,
        :IT_DATA-MAKTX,
        :IT_DATA-GAMNG,
        :IT_DATA-GMEIN,
        :IT_DATA-ZCODE,
        :IT_DATA-ZTYPE,
        :IT_DATA-ZWIDTH,
        :IT_DATA-ZLENGTH,
        :IT_DATA-ZLINE,
        :IT_DATA-ZTREAT,
        :IT_DATA-ZCUSTM,
        :IT_DATA-ZNOSHEET,
        :IT_DATA-ZQTY,
        :IT_DATA-ZSTAT,
        :VARDATETIME)
    ENDEXEC.
  ENDLOOP.


  IF SY-SUBRC = 0.
    EXEC SQL.
      COMMIT WORK
    ENDEXEC.
    VARSTATUS = '1'. VARMSG = ''.
  ELSE.
    VARSTATUS = '0'. VARMSG = ''.
  ENDIF.

ENDFORM.                    "INSERT_SQL