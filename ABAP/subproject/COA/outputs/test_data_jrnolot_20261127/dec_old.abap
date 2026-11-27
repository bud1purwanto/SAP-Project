REPORT ZTMP.
DATA: ATINN_ROLL TYPE AUSP-ATINN.
DATA: BEGIN OF GT_JRPREV OCCURS 0, CHARG TYPE CHARG_D,
      LOT TYPE QALS-PRUEFLOS, END OF GT_JRPREV.
DATA: LV_F TYPE QALS-PRUEFLOS, LV_D TYPE MCH1-ERSDA, LV_J TYPE CHARG_D.
START-OF-SELECTION.
SELECT SINGLE ATINN INTO ATINN_ROLL FROM CABN
  WHERE ATNAM = 'ZZNOMORROLL'.
* A: roll 5 AAA 076 001 hanya ada 2016 (lot 9481 ada hasil)
LV_D = '20160710'.
PERFORM JR_PREV_CHECK USING '5 AAA 076' 1 LV_D ATINN_ROLL
  CHANGING LV_F.
WRITE: / 'A ref 2016 -> 5 AAA 076 001:', LV_F.
LV_D = '20260710'.
PERFORM JR_PREV_CHECK USING '5 AAA 076' 1 LV_D ATINN_ROLL
  CHANGING LV_F.
WRITE: / 'B ref 2026 -> 5 AAA 076 001:', LV_F.
* C: roll 4 AAB 076 009 ada 2016 dan 2026
LV_D = '20260805'.
PERFORM JR_PREV_CHECK USING '4 AAB 076' 9 LV_D ATINN_ROLL
  CHANGING LV_F.
WRITE: / 'C ref 2026 -> 4 AAB 076 009:', LV_F.
* D-F: JR nyata
DEFINE JRT.
  CLEAR LV_F. REFRESH GT_JRPREV. LV_J = &1.
  PERFORM GET_JR_PREV_LOT USING LV_J CHANGING LV_F.
  WRITE: / 'JR', LV_J, '->', LV_F.
END-OF-DEFINITION.
JRT '0000405990'. JRT '0000353010'. JRT '0000352995'.
FORM GET_JR_PREV_LOT USING P_BATCH TYPE CHARG_D
                     CHANGING P_LOT TYPE QALS-PRUEFLOS.
  DATA: LV_HAS TYPE C,
        LV_ATR TYPE AUSP-ATINN,
        LV_CUOBJ TYPE MCH1-CUOBJ_BM,
        LV_REF TYPE MCH1-ERSDA,
        LV_OBJEK TYPE AUSP-OBJEK,
        LV_ROLL TYPE AUSP-ATWRT,
        LV_LINES TYPE I,
        LV_IX TYPE I,
        LV_HEAD(50) TYPE C,
        LV_MY(10) TYPE C,
        LV_SEQC(10) TYPE C,
        LV_SEQ TYPE I,
        LV_MM TYPE I,
        LV_YY TYPE I,
        LV_PMY(3) TYPE C,
        LV_PREF(60) TYPE C,
        LV_PPREF(60) TYPE C,
        LV_REST TYPE I,
        LV_IDX TYPE I,
        LV_LAST TYPE I,
        LV_FOUND TYPE QALS-PRUEFLOS,
        LV_N2(2) TYPE N,
        LV_N1(1) TYPE N,
        LV_PAT TYPE AUSP-ATWRT,
        LV_YEAR(4) TYPE C.
  DATA: BEGIN OF LT_PART OCCURS 0,
          P(50) TYPE C,
        END OF LT_PART.
  DATA: BEGIN OF LT_AU OCCURS 0,
          OBJEK TYPE AUSP-OBJEK,
          ATWRT TYPE AUSP-ATWRT,
        END OF LT_AU.
  DATA: BEGIN OF LT_PV OCCURS 0,
          SEQ TYPE I,
          ERSDA TYPE MCH1-ERSDA,
          DIFF TYPE I,
        END OF LT_PV.

  IF P_BATCH IS INITIAL.
    RETURN.
  ENDIF.

  " Lot sendiri sudah punya hasil -> pakai lot sendiri.
  IF P_LOT IS NOT INITIAL.
    PERFORM JR_LOT_HAS_RESULT USING P_LOT CHANGING LV_HAS.
    IF LV_HAS = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

  READ TABLE GT_JRPREV WITH KEY CHARG = P_BATCH.
  IF SY-SUBRC = 0.
    IF GT_JRPREV-LOT IS NOT INITIAL.
      P_LOT = GT_JRPREV-LOT.
    ENDIF.
    RETURN.
  ENDIF.

  LV_ATR = ATINN_ROLL.
  IF LV_ATR IS INITIAL.
    SELECT SINGLE ATINN INTO LV_ATR FROM CABN
      WHERE ATNAM = 'ZZNOMORROLL'.
  ENDIF.

  CLEAR LV_FOUND.
  SELECT SINGLE CUOBJ_BM ERSDA INTO (LV_CUOBJ, LV_REF)
    FROM MCH1 WHERE CHARG = P_BATCH.
  IF SY-SUBRC = 0 AND LV_CUOBJ IS NOT INITIAL
     AND LV_ATR IS NOT INITIAL.
    LV_OBJEK = LV_CUOBJ.
    SELECT SINGLE ATWRT INTO LV_ROLL FROM AUSP
      WHERE OBJEK = LV_OBJEK AND ATINN = LV_ATR
        AND KLART = '023' AND MAFID = 'O'.
  ENDIF.

  IF LV_ROLL IS NOT INITIAL.
    " Pecah: <head...> <MMY> <seq>
    SPLIT LV_ROLL AT SPACE INTO TABLE LT_PART.
    DELETE LT_PART WHERE P IS INITIAL.
    DESCRIBE TABLE LT_PART LINES LV_LINES.
    IF LV_LINES >= 3.
      READ TABLE LT_PART INDEX LV_LINES.
      LV_SEQC = LT_PART-P.
      LV_IX = LV_LINES - 1.
      READ TABLE LT_PART INDEX LV_IX.
      LV_MY = LT_PART-P.
      CLEAR LV_HEAD.
      LOOP AT LT_PART FROM 1 TO LV_IX.
        IF SY-TABIX = LV_IX.
          EXIT.
        ENDIF.
        IF LV_HEAD IS INITIAL.
          LV_HEAD = LT_PART-P.
        ELSE.
          CONCATENATE LV_HEAD LT_PART-P INTO LV_HEAD
            SEPARATED BY SPACE.
        ENDIF.
      ENDLOOP.

      IF LV_SEQC CO '0123456789 ' AND LV_SEQC IS NOT INITIAL
         AND STRLEN( LV_MY ) = 3 AND LV_MY CO '0123456789 '.
        LV_SEQ = LV_SEQC.
        LV_MM = LV_MY(2).
        LV_YY = LV_MY+2(1).
        CONCATENATE LV_HEAD LV_MY INTO LV_PREF SEPARATED BY SPACE.
        LV_REST = 20.

        " 1) Bulan yang sama: seq-1 turun sampai 001.
        LV_IDX = LV_SEQ - 1.
        WHILE LV_IDX >= 1 AND LV_REST > 0 AND LV_FOUND IS INITIAL.
          PERFORM JR_PREV_CHECK USING LV_PREF LV_IDX LV_REF LV_ATR
                                CHANGING LV_FOUND.
          LV_IDX = LV_IDX - 1.
          LV_REST = LV_REST - 1.
        ENDWHILE.

        " 2) Sisa jatah: 1 bulan sebelumnya, dari sequence terakhir.
        IF LV_FOUND IS INITIAL AND LV_REST > 0
           AND LV_MM >= 1 AND LV_MM <= 12.
          LV_MM = LV_MM - 1.
          IF LV_MM = 0.
            LV_MM = 12.
            LV_YY = LV_YY - 1.
            IF LV_YY < 0.
              LV_YY = 9.
            ENDIF.
          ENDIF.
          LV_N2 = LV_MM.
          LV_N1 = LV_YY.
          CONCATENATE LV_N2 LV_N1 INTO LV_PMY.
          CONCATENATE LV_HEAD LV_PMY INTO LV_PPREF
            SEPARATED BY SPACE.
          CONCATENATE LV_PPREF '___' INTO LV_PAT
            SEPARATED BY SPACE.

          REFRESH LT_AU.
          SELECT OBJEK ATWRT INTO TABLE LT_AU FROM AUSP
            WHERE ATINN = LV_ATR
              AND KLART = '023'
              AND MAFID = 'O'
              AND ATWRT LIKE LV_PAT.

          " Sequence terakhir: hanya batch dengan tahun terdekat.
          REFRESH LT_PV.
          LOOP AT LT_AU.
            CLEAR: LT_PV, LV_SEQC.
            SPLIT LT_AU-ATWRT AT SPACE INTO TABLE LT_PART.
            DELETE LT_PART WHERE P IS INITIAL.
            DESCRIBE TABLE LT_PART LINES LV_LINES.
            READ TABLE LT_PART INDEX LV_LINES.
            LV_SEQC = LT_PART-P.
            IF LV_SEQC CN '0123456789 ' OR LV_SEQC IS INITIAL.
              CONTINUE.
            ENDIF.
            LT_PV-SEQ = LV_SEQC.
            LV_CUOBJ = LT_AU-OBJEK.
            SELECT SINGLE ERSDA INTO LT_PV-ERSDA FROM MCH1
              WHERE CUOBJ_BM = LV_CUOBJ.
            IF SY-SUBRC <> 0.
              CONTINUE.
            ENDIF.
            LT_PV-DIFF = ABS( LT_PV-ERSDA - LV_REF ).
            APPEND LT_PV.
          ENDLOOP.

          IF LT_PV[] IS NOT INITIAL.
            SORT LT_PV BY DIFF ASCENDING.
            READ TABLE LT_PV INDEX 1.
            LV_YEAR = LT_PV-ERSDA(4).
            LV_LAST = 0.
            LOOP AT LT_PV.
              IF LT_PV-ERSDA(4) = LV_YEAR AND LT_PV-SEQ > LV_LAST.
                LV_LAST = LT_PV-SEQ.
              ENDIF.
            ENDLOOP.

            LV_IDX = LV_LAST.
            WHILE LV_IDX >= 1 AND LV_REST > 0
              AND LV_FOUND IS INITIAL.
              PERFORM JR_PREV_CHECK USING LV_PPREF LV_IDX LV_REF
                                          LV_ATR
                                    CHANGING LV_FOUND.
              LV_IDX = LV_IDX - 1.
              LV_REST = LV_REST - 1.
            ENDWHILE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR GT_JRPREV.
  GT_JRPREV-CHARG = P_BATCH.
  GT_JRPREV-LOT = LV_FOUND.
  APPEND GT_JRPREV.

  IF LV_FOUND IS NOT INITIAL.
    P_LOT = LV_FOUND.
  ENDIF.
ENDFORM.                    "GET_JR_PREV_LOT

*&---------------------------------------------------------------------*
*&      Form  JR_PREV_CHECK
*&---------------------------------------------------------------------*
* Satu kandidat roll <P_PREF> <P_IDX 3 digit>. Roll yang sama bisa
* punya >1 batch: tahun = batch ERSDA terdekat ke P_REF, lalu semua
* batch tahun itu dicek (terbaru dulu); ambil lot Z02/Z03 terbaru
* yang punya hasil.
*----------------------------------------------------------------------*
FORM JR_PREV_CHECK USING P_PREF P_IDX TYPE I P_REF TYPE MCH1-ERSDA
                         P_ATR TYPE AUSP-ATINN
                   CHANGING P_FOUND TYPE QALS-PRUEFLOS.
  DATA: LV_S(3) TYPE N,
        LV_ROLL TYPE AUSP-ATWRT,
        LV_CUOBJ TYPE MCH1-CUOBJ_BM,
        LV_DIFF TYPE I,
        LV_BEST TYPE I,
        LV_YEAR(4) TYPE C,
        LV_HAS TYPE C.
  DATA: BEGIN OF LT_OB OCCURS 0,
          OBJEK TYPE AUSP-OBJEK,
        END OF LT_OB.
  DATA: BEGIN OF LT_MC OCCURS 0,
          CHARG TYPE MCH1-CHARG,
          ERSDA TYPE MCH1-ERSDA,
        END OF LT_MC.
  DATA: BEGIN OF LT_ALL OCCURS 0,
          CHARG TYPE MCH1-CHARG,
          ERSDA TYPE MCH1-ERSDA,
          YEAR(4) TYPE C,
        END OF LT_ALL.
  DATA: BEGIN OF LT_QL OCCURS 0,
          PRUEFLOS TYPE QALS-PRUEFLOS,
        END OF LT_QL.

  CLEAR P_FOUND.
  IF P_IDX < 1 OR P_IDX > 999.
    RETURN.
  ENDIF.
  LV_S = P_IDX.
  CONCATENATE P_PREF LV_S INTO LV_ROLL SEPARATED BY SPACE.

  SELECT OBJEK INTO TABLE LT_OB FROM AUSP
    WHERE ATINN = P_ATR
      AND ATWRT = LV_ROLL
      AND KLART = '023'
      AND MAFID = 'O'.
  IF LT_OB[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH LT_ALL.
  LV_BEST = -1.
  LOOP AT LT_OB.
    LV_CUOBJ = LT_OB-OBJEK.
    REFRESH LT_MC.
    SELECT CHARG ERSDA INTO TABLE LT_MC FROM MCH1
      WHERE CUOBJ_BM = LV_CUOBJ.
    LOOP AT LT_MC.
      LT_ALL-CHARG = LT_MC-CHARG.
      LT_ALL-ERSDA = LT_MC-ERSDA.
      LT_ALL-YEAR = LT_MC-ERSDA(4).
      APPEND LT_ALL.
      LV_DIFF = ABS( LT_MC-ERSDA - P_REF ).
      IF LV_BEST < 0 OR LV_DIFF < LV_BEST.
        LV_BEST = LV_DIFF.
        LV_YEAR = LT_MC-ERSDA(4).
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  IF LT_ALL[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT LT_ALL BY CHARG DESCENDING.
  LOOP AT LT_ALL WHERE YEAR = LV_YEAR.
    REFRESH LT_QL.
    SELECT PRUEFLOS INTO TABLE LT_QL FROM QALS
      WHERE CHARG = LT_ALL-CHARG
        AND ( ART = 'Z02' OR ART = 'Z03' ).
    SORT LT_QL BY PRUEFLOS DESCENDING.
    LOOP AT LT_QL.
      PERFORM JR_LOT_HAS_RESULT USING LT_QL-PRUEFLOS
                                CHANGING LV_HAS.
      IF LV_HAS = 'X'.
        P_FOUND = LT_QL-PRUEFLOS.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF P_FOUND IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "JR_PREV_CHECK

*&---------------------------------------------------------------------*
*&      Form  JR_LOT_HAS_RESULT
*&---------------------------------------------------------------------*
FORM JR_LOT_HAS_RESULT USING P_LOT TYPE QALS-PRUEFLOS
                       CHANGING P_HAS TYPE C.
  DATA: LV_CNT TYPE I.
  CLEAR P_HAS.
  IF P_LOT IS INITIAL.
    RETURN.
  ENDIF.
  SELECT COUNT( * ) INTO LV_CNT FROM QAMR
    WHERE PRUEFLOS = P_LOT AND ANZWERTG > 0.
  IF LV_CNT > 0.
    P_HAS = 'X'.
  ENDIF.
ENDFORM.                    "JR_LOT_HAS_RESULT
