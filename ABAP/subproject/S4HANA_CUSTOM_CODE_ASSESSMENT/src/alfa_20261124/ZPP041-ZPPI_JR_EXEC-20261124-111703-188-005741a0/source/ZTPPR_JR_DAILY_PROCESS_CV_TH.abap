*----------------------------------------------------------------------*
* Report ZPPR_JR_DAILY_PROCESS_CV_TH_LM
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : Report Jumbo Roll Harian ( Converting, Thermal, Laminating )
*
* Application Area - PP
* ABAPer           - Fina Oktavia Manurung
* Date             - October 25, 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*
REPORT ZTPPR_JR_DAILY_PROCESS_CV_TH.
INCLUDE ZINCL_ERP_SQL.

TABLES : MSEG, MKPF, MARA.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_MATNR FOR MSEG-MATNR NO-DISPLAY,
                 S_WERKS FOR MSEG-WERKS NO-DISPLAY,
                 S_LGORT FOR MSEG-LGORT NO-DISPLAY,
                 S_BUDAT FOR MKPF-BUDAT NO-DISPLAY,
                 S_MATKL FOR MARA-MATKL NO-DISPLAY DEFAULT '400001' TO '400099',
                 S_CHARG FOR MSEG-CHARG OBLIGATORY.
SELECTION-SCREEN END OF BLOCK BLOCK1.

TYPES : BEGIN OF IT_JUMBO,
          AUFNR LIKE AFRU-AUFNR,
          WERKS LIKE AUFK-WERKS,
          MATNR LIKE MARA-MATNR,
          CHARG LIKE AFPO-CHARG,
          MENGE LIKE MSEG-MENGE,
          LGORT LIKE AFPO-LGORT,
          MBLNR LIKE MSEG-MBLNR,
          SMBLN LIKE MSEG-SMBLN,
          ZCODE(25),
          ZWIDTH(25),
          ZINSIDE(25),
          ZOUTSIDE(25),
          ZLENGTH(25),
          ZGRADE(25),
          ZCONV(25),
          ZNROLL(30),
          BUDAT LIKE MKPF-BUDAT,
          CPUTM LIKE MKPF-CPUTM,
          ISDZ LIKE AFRU-ISDZ,
          IEDZ LIKE AFRU-IEDZ,
          ZGROUP(6),
          ZSHIFT(7),
          PERNR(8),
          ZSTATUS(10),
          ZROLL1(30),
          ZROLL2(30),
          ZROLL3(30),
          ZROLL4(30),
          ZLINE(5),
          ZWINDER(30),
          ZLAB(30),
        END OF IT_JUMBO.

TYPES : BEGIN OF IT_BATCH,
          MBLNR LIKE MSEG-MBLNR,
          SMBLN LIKE MSEG-SMBLN,
          CHARG LIKE MSEG-CHARG,
        END OF IT_BATCH.

DATA : ITAB TYPE IT_JUMBO OCCURS 0 WITH HEADER LINE.
DATA : ITAB_TEMP TYPE IT_JUMBO OCCURS 0 WITH HEADER LINE.

DATA : IT_BATCH TYPE IT_BATCH OCCURS 0 WITH HEADER LINE.

"- Batch Characteristic
DATA : V_TAB     LIKE API_VALI OCCURS 0 WITH HEADER LINE.

"- Read Text
DATA : IT_LINES LIKE TLINE OCCURS 0 WITH HEADER LINE.
DATA : V_NAME LIKE THEAD-TDNAME,
       V_CHARG(50),
       V_LENGTH TYPE I,
       V_PRUEFLOS LIKE QALS-PRUEFLOS.
DATA : WA_LINES LIKE LINE OF IT_LINES.


DATA : V_MBLNR LIKE MSEG-MBLNR,
       V_BWART LIKE MSEG-BWART,
       V_NIK   LIKE AFRU-PERNR.

DATA : V_NO TYPE I VALUE 0,
       V_CONV1(20),
       V_CONV2(20).

DATA : FLAG(1).
DATA : V_COUNT TYPE I,
       V_MENGE LIKE MSEG-MENGE,
       V_OK    LIKE MSEG-MENGE,
       V_NOTOK LIKE MSEG-MENGE.
DATA : V_BATCH(100).

DATA : V_LENGTH1 TYPE P DECIMALS 0,
       V_TEMP1(20),
       V_TEMP2(20),
       V_WEIGHT(20),
       V_SGTXT LIKE MSEG-SGTXT.

DATA : P_MATNR LIKE MCHB-MATNR.
DATA : P_CHARG LIKE MCHB-CHARG.

DATA :   V_TOT_WEIGHT_MATNR TYPE P DECIMALS 3 VALUE 0,
         V_TOT_WEIGHT_GRADEOK TYPE P DECIMALS 3 VALUE 0,
         V_TOT_WEIGHT_GRADESCRAP TYPE P DECIMALS 3 VALUE 0,
         V_TOT_WEIGHT_GRADENULL TYPE P DECIMALS 3 VALUE 0,

         V_GRANDTOT_WEIGHT_MATNR TYPE P DECIMALS 3 VALUE 0,
         V_GRANDTOT_WEIGHT_GRADEOK TYPE P DECIMALS 3 VALUE 0,
         V_GRANDTOT_WEIGHT_GRADESCRAP TYPE P DECIMALS 3 VALUE 0,
         V_GRANDTOT_WEIGHT_GRADENULL TYPE P DECIMALS 3 VALUE 0.

DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
FIELD-SYMBOLS : <FS_ITAB> LIKE LINE OF ITAB.
FIELD-SYMBOLS : <FS_CHAR> LIKE LINE OF IT_CHAR.
DATA : ATFLV2 TYPE P LENGTH 9.
DATA : VLENGTH TYPE P LENGTH 9.

INITIALIZATION.
*  S_BUDAT-HIGH = SY-DATUM.
*  APPEND S_BUDAT.

AT SELECTION-SCREEN ON S_MATKL.
  IF S_MATKL-LOW NE SPACE.
    IF NOT S_MATKL-LOW BETWEEN '400001' AND '400099' .
      MESSAGE 'MATERIAL GROUP IS NOT JUMBO ROLL' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF S_MATKL-HIGH NE SPACE.
    IF NOT S_MATKL-HIGH BETWEEN '400001' AND '400099' .
      MESSAGE 'MATERIAL GROUP IS NOT JUMBO ROLL' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  PERFORM CHECK_SERVER.
  PERFORM GET_DATA.
  INSERT_LOG_SQL ITAB CHARG 'ZTPP011'.
  IF ITAB[] IS INITIAL.
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
*   LV =  100 / 0.
  CLEAR : ITAB.
  REFRESH : ITAB.

  SELECT
    MKPF~BUDAT
    MKPF~CPUTM
    MSEG~MBLNR
    MSEG~CHARG
    MSEG~LGORT
    MSEG~MENGE
    MSEG~MATNR
    MSEG~AUFNR
    MSEG~WERKS
    AUFK~AUART AS ZLINE
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    FROM MKPF
    JOIN MSEG ON MSEG~MBLNR = MKPF~MBLNR
    JOIN MARA ON MARA~MATNR = MSEG~MATNR
    JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
      WHERE MSEG~MATNR IN S_MATNR
      AND AUFK~WERKS IN S_WERKS
      AND MARA~MATKL IN S_MATKL
      AND MSEG~LGORT IN S_LGORT
      AND MKPF~BUDAT IN S_BUDAT
      AND MSEG~CHARG IN S_CHARG
      AND MSEG~BWART EQ '101'.

  DELETE ITAB WHERE
  ZLINE NE 'ZP01'
AND ZLINE NE 'ZP02'
AND ZLINE NE 'ZP03'
AND ZLINE NE 'ZP04'
AND ZLINE NE 'ZP05'
AND ZLINE NE 'ZP06'
AND ZLINE NE 'ZP07'
AND ZLINE NE 'ZP08'
AND ZLINE NE 'ZP09'
AND ZLINE NE 'ZP10'
AND ZLINE NE 'ZP11'
AND ZLINE NE 'ZP12'     "ADDED FOR EXLAM 21.01.2019 - ADD ORDER TYPE ZP12
" Added by William at 24.07.2022 (OPP7 CPP1)
AND ZLINE NE 'ZP13'
AND ZLINE NE 'ZP14'
AND ZLINE NE 'ZP15'
AND ZLINE NE 'ZP16'
AND ZLINE NE 'ZP17'
AND ZLINE NE 'ZP18'
" End added by William at 24.07.2022 (OPP7 CPP1)
AND ZLINE NE 'ZTR1'
AND ZLINE NE 'ZTR2'
AND ZLINE NE 'ZTR3'
AND ZLINE NE 'ZTR4'
AND ZLINE NE 'ZTR5'
AND ZLINE NE 'ZTR6'
AND ZLINE NE 'ZTR7'     "ADDED FOR EXLAM 21.01.2019 - ADD ORDER TYPE ZTR7
" Added by William at 24.07.2022 (OPP7 CPP1)
AND ZLINE NE 'ZTR8'
AND ZLINE NE 'ZTR9'
AND ZLINE NE 'ZTRA'
AND ZLINE NE 'ZTRB'
AND ZLINE NE 'ZTRC'
" End added by William at 24.07.2022 (OPP7 CPP1)
AND ZLINE NE 'ZTRD' "<Dila 11.02.2025> Add New Laminator #2 #3
AND ZLINE NE 'ZP90'.

  ITAB-ZLINE = ''.
  MODIFY ITAB TRANSPORTING ZLINE WHERE ZLINE NE ''.

  LOOP AT ITAB ASSIGNING <FS_ITAB>.
    "- Cancel GR
    SELECT SINGLE MSEG~MBLNR
      INTO V_MBLNR
      FROM MSEG
      WHERE MSEG~SMBLN = <FS_ITAB>-MBLNR.

    IF SY-SUBRC = 0.
      <FS_ITAB>-SMBLN = V_MBLNR.
*      DELETE ITAB.
*      CONTINUE.
    ENDIF.

    "- Start Time , Finish Time , Personel Number
    SELECT SINGLE AFRU~ISDZ AFRU~IEDZ AFRU~PERNR
      INTO (<FS_ITAB>-ISDZ, <FS_ITAB>-IEDZ, V_NIK)
      FROM AFRU
      WHERE AFRU~LTXA1 = <FS_ITAB>-MBLNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_NIK
      IMPORTING
        OUTPUT = <FS_ITAB>-PERNR.

    "- Shift
    IF <FS_ITAB>-IEDZ BETWEEN '000001' AND '070000'.
      <FS_ITAB>-ZSHIFT = 'Shift1'.
    ELSEIF <FS_ITAB>-IEDZ BETWEEN '070001' AND '153000'.
      <FS_ITAB>-ZSHIFT = 'Shift2'.
    ELSEIF <FS_ITAB>-IEDZ BETWEEN '153001' AND '240000'.
      <FS_ITAB>-ZSHIFT = 'Shift3'.
    ELSEIF <FS_ITAB>-IEDZ EQ '000000'.
      <FS_ITAB>-ZSHIFT = 'Shift1'.
    ENDIF.

    "- Group
    SELECT SINGLE ZGROUP~ZZGROUP
      INTO <FS_ITAB>-ZGROUP
      FROM ZGROUP
      WHERE ZGROUP~ZZTANGGAL = <FS_ITAB>-BUDAT
        AND ZZJAM_MASUK <= <FS_ITAB>-IEDZ
        AND ZZJAM_KELUAR >= <FS_ITAB>-IEDZ.

    "- Length, Weight
    CLEAR : V_SGTXT, V_TEMP1, V_TEMP2, V_LENGTH1.
    SELECT SINGLE MSEG~SGTXT
      INTO V_SGTXT
      FROM MSEG
      WHERE MSEG~CHARG = <FS_ITAB>-CHARG
        AND MSEG~BWART EQ '101'.

    SPLIT V_SGTXT AT '-' INTO V_TEMP1 V_TEMP2.
    CONDENSE V_TEMP1 NO-GAPS.
    CONDENSE V_TEMP2 NO-GAPS.
    REPLACE ALL OCCURRENCES OF ',' IN V_TEMP1 WITH ' '.
    REPLACE ALL OCCURRENCES OF ',' IN V_TEMP2 WITH ' '.

    V_LENGTH1 = V_TEMP1.
    IF V_LENGTH1 <> 0.
      WRITE V_LENGTH1 TO <FS_ITAB>-ZLENGTH.
    ELSE.
      <FS_ITAB>-ZLENGTH = ''.
    ENDIF.

    WRITE V_TEMP2 TO <FS_ITAB>-ZCONV.

    "- Storage Location
    SELECT SINGLE MSEG~LGORT
      INTO <FS_ITAB>-LGORT
      FROM MSEG
      WHERE MSEG~CHARG = <FS_ITAB>-CHARG.


    "- Characteristic
    IF <FS_ITAB>-CHARG NE ''.
      CLEAR : IT_CHAR.
      REFRESH : IT_CHAR.
      CALL FUNCTION 'ZCHARACTERISTICS_ZPP011'
        EXPORTING
          I_VAL_MATNR  = <FS_ITAB>-MATNR
          I_VAL_CHARGE = <FS_ITAB>-CHARG
        TABLES
          T_VAL_TAB    = IT_CHAR
        EXCEPTIONS
          NO_OBJECT    = 1
          NO_VALUES    = 2.

      IF SY-SUBRC EQ '0'.
        "- Width
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          WRITE ATFLV2 TO <FS_ITAB>-ZWIDTH.
          CONDENSE <FS_ITAB>-ZWIDTH NO-GAPS.
        ENDIF.

        "- Nomor Roll
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZNROLL = <FS_CHAR>-ATWRT.
        ENDIF.

        "- Code
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZCODE' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZCODE = <FS_CHAR>-ATWTB.
        ENDIF.

        "- Inside
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZINSIDE' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZINSIDE = <FS_CHAR>-ATWTB.
        ENDIF.

        "- Outside
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZOUTSIDE' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZOUTSIDE = <FS_CHAR>-ATWTB.
        ENDIF.

        "- Length
        CLEAR : VLENGTH.
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZLENGTH' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO VLENGTH.
        ENDIF.

        "- Status
        IF VLENGTH <> 0.
          <FS_ITAB>-ZSTATUS = 'Complete'.
        ELSE.
          <FS_ITAB>-ZSTATUS = 'NA'.
        ENDIF.

        "- Grade
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZGRADEJR' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZGRADE = <FS_CHAR>-ATWTB.
        ENDIF.

        "- Line
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZPRODLINE' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_ITAB>-ZLINE = <FS_CHAR>-ATWRT.
        ENDIF.

      ENDIF.
    ENDIF.

    "- Roll Input
    IF <FS_ITAB>-ZNROLL NE ''.
      CLEAR : IT_BATCH, V_BATCH.
      REFRESH : IT_BATCH.
      SELECT
        MSEG~MBLNR
        MSEG~CHARG
        INTO CORRESPONDING FIELDS OF TABLE IT_BATCH
        FROM MSEG
        INNER JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
        WHERE MSEG~AUFNR = <FS_ITAB>-AUFNR
          AND ( MSEG~BWART EQ '261' OR MSEG~BWART EQ '901' )
          AND MSEG~CHARG NE ''
          AND MKPF~BKTXT = <FS_ITAB>-ZNROLL.

      LOOP AT IT_BATCH.
        AT NEW MBLNR.
          "- Cancel Mat.Doc
          SELECT SINGLE MSEG~SMBLN
            INTO IT_BATCH-SMBLN
            FROM MSEG
            WHERE MSEG~SMBLN = IT_BATCH-MBLNR.

          IF SY-SUBRC = 0.
            DELETE IT_BATCH.
            CONTINUE.
          ENDIF.
        ENDAT.
      ENDLOOP.
      SORT IT_BATCH ASCENDING BY CHARG.
      DELETE ADJACENT DUPLICATES FROM IT_BATCH COMPARING CHARG.

      LOOP AT IT_BATCH.
        CONCATENATE IT_BATCH-CHARG V_BATCH INTO V_BATCH SEPARATED BY ','.
      ENDLOOP.
      CONDENSE V_BATCH NO-GAPS.

      SPLIT V_BATCH AT ',' INTO <FS_ITAB>-ZROLL1 <FS_ITAB>-ZROLL2 <FS_ITAB>-ZROLL3 <FS_ITAB>-ZROLL4.
    ENDIF.

    "- Roll Input 1
    IF <FS_ITAB>-ZROLL1 NE ''.
      PERFORM GET_MATERIAL USING <FS_ITAB>-ZROLL1.
      PERFORM GET_NOROLL USING P_CHARG P_MATNR CHANGING <FS_ITAB>-ZROLL1.
    ENDIF.

    "- Roll Input 2
    IF <FS_ITAB>-ZROLL2 NE ''.
      PERFORM GET_MATERIAL USING <FS_ITAB>-ZROLL2.
      PERFORM GET_NOROLL USING P_CHARG P_MATNR CHANGING <FS_ITAB>-ZROLL2.
    ENDIF.

    "- Roll Input 3
    IF <FS_ITAB>-ZROLL1 NE ''.
      PERFORM GET_MATERIAL USING <FS_ITAB>-ZROLL3.
      PERFORM GET_NOROLL USING P_CHARG P_MATNR CHANGING <FS_ITAB>-ZROLL3.
    ENDIF.

    "- Roll Input 4
    IF <FS_ITAB>-ZROLL1 NE ''.
      PERFORM GET_MATERIAL USING <FS_ITAB>-ZROLL4.
      PERFORM GET_NOROLL USING P_CHARG P_MATNR CHANGING <FS_ITAB>-ZROLL4.
    ENDIF.

    "- Keterangan Winder
    CLEAR : V_NAME, V_LENGTH, V_CHARG, IT_LINES, WA_LINES.
    REFRESH : IT_LINES.

    V_CHARG = <FS_ITAB>-CHARG.
    CONDENSE V_CHARG NO-GAPS.

    V_LENGTH = 22 - STRLEN( <FS_ITAB>-MATNR ).
    SHIFT V_CHARG BY V_LENGTH PLACES RIGHT.
    CONCATENATE <FS_ITAB>-MATNR V_CHARG INTO V_NAME.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'VERM'
        LANGUAGE                = 'E'
        NAME                    = V_NAME
        OBJECT                  = 'CHARGE'
      TABLES
        LINES                   = IT_LINES
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.

    READ TABLE IT_LINES INTO WA_LINES.
    IF SY-SUBRC = 0.
      <FS_ITAB>-ZWINDER = WA_LINES-TDLINE.
    ENDIF.

    "- Lab Info
    CLEAR : V_NAME, V_PRUEFLOS, IT_LINES, WA_LINES.
    REFRESH : IT_LINES.

    SELECT SINGLE QALS~PRUEFLOS
      INTO V_PRUEFLOS
      FROM QALS
      WHERE QALS~CHARG = <FS_ITAB>-CHARG
        AND QALS~HERKUNFT = '04'.

    CONCATENATE SY-MANDT V_PRUEFLOS 'L' INTO V_NAME.
    CONDENSE V_NAME NO-GAPS.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'QAVE'
        LANGUAGE                = 'E'
        NAME                    = V_NAME
        OBJECT                  = 'QPRUEFLOS'
      TABLES
        LINES                   = IT_LINES
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.

    READ TABLE IT_LINES INTO WA_LINES.
    IF SY-SUBRC = 0.
      <FS_ITAB>-ZLAB = WA_LINES-TDLINE.
    ENDIF.

  ENDLOOP.

  ITAB-BUDAT = '19000101'.
  MODIFY ITAB TRANSPORTING BUDAT WHERE BUDAT = 00000000.
ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  GET_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_ZROLL  text
*----------------------------------------------------------------------*
FORM GET_MATERIAL  USING    P_ITAB_ZROLL.
  CLEAR : P_MATNR, P_CHARG.

  P_CHARG = P_ITAB_ZROLL(10).

  SELECT SINGLE MCHB~MATNR
    INTO P_MATNR
    FROM MCHB
    WHERE MCHB~CHARG = P_CHARG.

ENDFORM.                    " GET_MATERIAL


*&---------------------------------------------------------------------*
*&      Form  GET_NOROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CHARG    text
*      -->P_MATNR    text
*      -->ZROLL      text
*----------------------------------------------------------------------*
FORM GET_NOROLL  USING    P_CHARG
                          P_MATNR
                 CHANGING ZROLL.

  IF P_CHARG NE ''.
    CLEAR : IT_CHAR.
    REFRESH : IT_CHAR.
    CALL FUNCTION 'ZCHARACTERISTICS_ZPP011'
      EXPORTING
        I_VAL_MATNR  = P_MATNR
        I_VAL_CHARGE = P_CHARG
      TABLES
        T_VAL_TAB    = IT_CHAR
      EXCEPTIONS
        NO_OBJECT    = 1
        NO_VALUES    = 2.

    IF SY-SUBRC EQ '0'.
      "- Nomor Roll
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        ZROLL = <FS_CHAR>-ATWRT.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    " GET_NOROLL

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL.

  LOOP AT ITAB.
    EXEC SQL.
      INSERT INTO TMP.RPT_ZPP011
      (
       [Order],
       Plant,
       Material,
       Batch,
       Quantity,
       StorLoc,
       MatDoc1,
       MatDoc2,
       FilmCode,
       Width,
       InsideTreatment,
       OutsideTreatment,
       Length,
       Grade,
       Weight,
       NoRoll,
       PostingDate,
       Time,
       Actstart,
       Actfinish,
       [Group],
       Shift,
       NIK,
       Status,
       RolInput1,
       RolInput2,
       RolInput3,
       RolInput4,
       LineDescription,
       KeteranganWinder,
       LabInfo,
       LastUpdated
       )
     VALUES
     (
      :ITAB-AUFNR ,
      :ITAB-WERKS ,
      :ITAB-MATNR ,
      :ITAB-CHARG ,
      :ITAB-MENGE ,
      :ITAB-LGORT ,
      :ITAB-MBLNR ,
      :ITAB-SMBLN ,
      :ITAB-ZCODE,
      :ITAB-ZWIDTH,
      :ITAB-ZINSIDE,
      :ITAB-ZOUTSIDE,
      :ITAB-ZLENGTH,
      :ITAB-ZGRADE,
      :ITAB-ZCONV,
      :ITAB-ZNROLL,
      :ITAB-BUDAT,
      :ITAB-CPUTM,
      :ITAB-ISDZ ,
      :ITAB-IEDZ ,
      :ITAB-ZGROUP,
      :ITAB-ZSHIFT,
      :ITAB-PERNR,
      :ITAB-ZSTATUS,
      :ITAB-ZROLL1,
      :ITAB-ZROLL2,
      :ITAB-ZROLL3,
      :ITAB-ZROLL4,
      :ITAB-ZLINE,
      :ITAB-ZWINDER,
      :ITAB-ZLAB,
      :VARDATETIME
     )
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