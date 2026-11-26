***********************************************************************
*   Program    :  ZTYB_LABEL
*   Appl. Area :  PP
*   Created by :  Mualifi
*   Created on :  11 November 2014
***********************************************************************
REPORT  ZTTYB_LABEL NO STANDARD PAGE HEADING .
INCLUDE ZINCL_ERP_SQL.
TABLES : ZMRTYB.

DATA: BEGIN OF ITAB OCCURS 0.
        INCLUDE STRUCTURE ZMRTYB.
DATA: BROLNO(30),
        BLOT(10),
        BROL(16),
        BMR LIKE MCH1-CHARG,
        TYPE(10),
        BOX(1),
END OF ITAB.

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
                P_CPUDT FOR ZMRTYB-CPUDT NO-DISPLAY,
                P_ARBPL FOR ZMRTYB-ARBPL NO-DISPLAY,
                P_CHARG FOR ZMRTYB-CHARG OBLIGATORY.
SELECTION-SCREEN END OF BLOCK 1.

START-OF-SELECTION.

  PERFORM CHECK_SERVER.
  PERFORM GET_DATA.
  INSERT_LOG_SQL ITAB CHARG 'ZTTYB03A'.
  IF ITAB[] IS INITIAL.
    VARSTATUS = '0'. "VARMSG = 'ZTTYB03A'.
    PERFORM UPDATE_LOG_SQL.
  ELSE.
    PERFORM INSERT_SQL.
    PERFORM UPDATE_LOG_SQL.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  SELECT * INTO TABLE ITAB FROM ZMRTYB
    WHERE  CPUDT IN P_CPUDT AND
           ARBPL IN P_ARBPL AND
           CHARG IN P_CHARG.

  LOOP AT ITAB.
    SELECT SINGLE  AUSP~ATWRT AS ATWRT
      FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
      JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
      INTO ITAB-BLOT
    WHERE MCH1~MATNR  = ITAB-MATNR
    AND   MCH1~CHARG  = ITAB-CHARG
      AND   CABN~ATNAM = 'ZZNOLOTTOYOBO'.

    SELECT SINGLE  AUSP~ATWRT AS ATWRT
      FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
      JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
      INTO  ITAB-BROL
    WHERE MCH1~MATNR  = ITAB-MATNR
    AND   MCH1~CHARG  = ITAB-CHARG
      AND   CABN~ATNAM = 'ZZNOROLLTOYOBO'.

    SELECT SINGLE  AUSP~ATWRT AS ATWRT
      FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
      JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
      INTO  ITAB-BMR
    WHERE MCH1~MATNR  = ITAB-MATNR
    AND   MCH1~CHARG  = ITAB-CHARG
      AND   CABN~ATNAM = 'ZZSPECIALTOUCH-1'.

    SELECT SINGLE  AUSP~ATWRT AS ATWRT
      FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
      JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
      INTO  ITAB-BROLNO
    WHERE MCH1~MATNR  = ITAB-MATNR
    AND   MCH1~CHARG  = ITAB-CHARG
      AND   CABN~ATNAM = 'ZZNOMORROLL'.

    SELECT SINGLE  AUSP~ATWRT AS ATWRT
      FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN
      JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK
      INTO  ITAB-TYPE
    WHERE MCH1~MATNR  = ITAB-MATNR
    AND   MCH1~CHARG  = ITAB-CHARG
      AND   CABN~ATNAM = 'ZZTYPE'.

    MODIFY ITAB.
  ENDLOOP.

  ITAB-CPUDT = '19000101'.
  MODIFY ITAB TRANSPORTING CPUDT WHERE CPUDT = 00000000.

ENDFORM.                    "get_data

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL.

  LOOP AT ITAB.
    EXEC SQL.
      INSERT INTO TMP.RPT_ZTYB03A
      (
        Batch1,
        Enteredon,
        Material,
        WorkCenter,
        Enteredat,
        [Order],
        MaterialDoc,
        SequencenumberLot,
        SequencenumberRol,
        LotNumber,
        RolNumber,
        Batch2,
        JRNumber,
        Batch3,
        GRUlang,
        Notes,
        NoRoll,
        NoLotToyobo,
        NoRolToyobo,
        SpecialTouch1,
        Type,
        LastUpdated
      )
     VALUES
     (
      :ITAB-CHARG,
      :ITAB-CPUDT,
      :ITAB-MATNR,
      :ITAB-ARBPL,
      :ITAB-CPUTM,
      :ITAB-AUFNR,
      :ITAB-MBLNR,
      :ITAB-SEQLOT,
      :ITAB-SEQROL,
      :ITAB-LOTNO,
      :ITAB-ROLNO,
      :ITAB-MOTHER,
      :ITAB-JRNO,
      :ITAB-CHARG2,
      :ITAB-RERUN,
      :ITAB-NOTES,
      :ITAB-BROLNO,
      :ITAB-BLOT,
      :ITAB-BROL,
      :ITAB-BMR,
      :ITAB-TYPE,
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