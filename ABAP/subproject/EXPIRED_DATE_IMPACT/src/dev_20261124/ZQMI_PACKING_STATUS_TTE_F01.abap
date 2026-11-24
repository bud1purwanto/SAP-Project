*&---------------------------------------------------------------------*
*&  Include           ZQMI_PACKING_STATUS_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  READ_HANDLING_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_HANDLING_UNIT .
  DATA : VBELN LIKE LIPS-VBELN.
  DATA : FLAG(1).

  IF S_EXIDV[] IS NOT INITIAL.
    SELECT
    VEKP~EXIDV
    VEPO~VENUM
    VEPO~UNVEL

    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV.
  ELSE.
    SELECT
    VEKP~EXIDV
    VEPO~VENUM
    VEPO~UNVEL

    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV
      AND VEKP~ERDAT IN S_ERDAT
      AND VEPO~MATNR IN S_MATNR
      AND VEPO~LGORT IN S_LGORT
      AND VEPO~WERKS = S_WERKS.
  ENDIF.

  IF IT_VEKP[] IS INITIAL.
    EXIT.
  ENDIF.

  LOOP AT IT_VEKP ASSIGNING <FSVEKP> WHERE UNVEL EQ ''.
    <FSVEKP>-UNVEL = <FSVEKP>-VENUM.
  ENDLOOP.

  SELECT
    VEKP~VENUM
    VEKP~MAGRV
    VEPO~UNVEL
    VEPO~CHARG
    VEPO~MATNR
    VEPO~SONUM
    VEPO~WERKS
    INTO CORRESPONDING FIELDS OF TABLE T_VEKP
    FROM VEKP
    INNER JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    FOR ALL ENTRIES IN IT_VEKP
    WHERE VEPO~VENUM = IT_VEKP-UNVEL
      AND VEPO~MATNR IN S_MATNR
      AND VEPO~LGORT IN S_LGORT
      AND VEPO~WERKS = S_WERKS.


  LOOP AT T_VEKP ASSIGNING <FS_VEKP>.
    CLEAR : FLAG.

    IF <FS_VEKP>-CHARG EQ ''.
      DELETE T_VEKP.
      CONTINUE.
    ENDIF.

    CLEAR :VBELN, V_VGBEL.
    IF <FS_VEKP>-MAGRV EQ 'BOX'.
      SELECT SINGLE VEKP~EXIDV
        INTO <FS_VEKP>-EXIDV
        FROM VEKP
        INNER JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE VEPO~UNVEL = <FS_VEKP>-VENUM.
    ELSEIF <FS_VEKP>-MAGRV EQ 'PLT'.
      SELECT SINGLE VEKP~EXIDV
        INTO <FS_VEKP>-EXIDV
        FROM VEKP
        WHERE VEKP~VENUM = <FS_VEKP>-VENUM.
    ENDIF.

    CLEAR : V_PRINT, V_ENSTEHDAT, V_EXP, V_STAT.

    "- Material Doc.
    SELECT MAX( MSEG~MBLNR )
      INTO V_MBLNR
      FROM MSEG
      WHERE MSEG~CHARG = <FS_VEKP>-CHARG
        AND MSEG~BWART IN ('101', '102').

    "- Movement Type and Order
    SELECT SINGLE MSEG~BWART MSEG~AUFNR
      INTO (V_BWART, V_AUFNR)
      FROM MSEG
      WHERE MSEG~MBLNR = V_MBLNR.

    SELECT SINGLE MKPF~BUDAT
      INTO V_BUDAT
      FROM MKPF
      WHERE MKPF~MBLNR = V_MBLNR.

    "- Get Jumbo Roll
    CLEAR : V_MBLNR, V_BWART, V_AUFNR.
    CLEAR : V_MATNR, V_CHARG, V_WERKS.


    V_CHARG = <FS_VEKP>-CHARG.

    CLEAR IS_OK.

    WHILE IS_OK = ''.
      CLEAR: V_MBLNR, V_AUFNR.  "- Add By Jarwo 04.07.2018
      SELECT SINGLE MBLNR AUFNR INTO (V_MBLNR, V_AUFNR) FROM MSEG WHERE CHARG = V_CHARG AND BWART = '101'.
      IF SY-SUBRC = 0.
        SELECT MBLNR AUFNR INTO (V_MBLNR, V_AUFNR) FROM MSEG WHERE CHARG = V_CHARG AND BWART = '101'.
          SELECT SINGLE MBLNR INTO V_MBLNR FROM MSEG WHERE SMBLN = V_MBLNR AND BWART = '102'.
          IF SY-SUBRC NE 0.
            EXIT.
          ELSE.
            CLEAR: V_MBLNR, V_AUFNR.
          ENDIF.
        ENDSELECT.

        IF V_MBLNR = ''.
          DELETE T_VEKP.
          FLAG = 'X'.
          EXIT.
        ENDIF.
      ENDIF.

*      "DO 5 TIMES." COMMENT
*      "- Material Doc.
*      SELECT MAX( MSEG~MBLNR )
*        INTO V_MBLNR
*        FROM MSEG
*        WHERE MSEG~CHARG = V_CHARG
*          AND MSEG~BWART IN ('101', '102').
*
*      "- Movement Type and Order
*      SELECT SINGLE MSEG~BWART MSEG~AUFNR
*        INTO (V_BWART, V_AUFNR)
*        FROM MSEG
*        WHERE MSEG~MBLNR = V_MBLNR.
*
*      IF SY-SUBRC <> 0.
*        EXIT .
*      ENDIF.
*
*      "- Delete Cancel Doc.
*      IF V_BWART EQ '102'.
*        DELETE T_VEKP.
*        FLAG = 'X'.
**        CONTINUE.
*        EXIT.
*
*      ENDIF.

      IF V_AUFNR NE ''.
        CLEAR V_BWART.
        SELECT SINGLE MSEG~MATNR MSEG~CHARG MSEG~WERKS MSEG~BWART
        INTO (V_MATNR, V_CHARG, V_WERKS, V_BWART)
        FROM MSEG
        INNER JOIN AFPO ON MSEG~AUFNR = AFPO~AUFNR
        WHERE AFPO~MILL_OC_AUFNR_U = V_AUFNR
          AND MSEG~BWART IN ('261', '262').

        IF SY-SUBRC <> 0.
          EXIT.
        ENDIF.

        IF V_BWART EQ '262'.
          DELETE T_VEKP.
          FLAG = 'X'.
**          CONTINUE.
          EXIT.

        ENDIF.

        SELECT SINGLE MARA~MATNR
          INTO V_MATNR2
          FROM MARA
          WHERE MARA~MATNR = V_MATNR
            AND MARA~MTART EQ 'ZSFG'
            AND MARA~MATKL BETWEEN '400001' AND '400100'.

        IF SY-SUBRC = 0.
          CLEAR   : IT_CHAR.
          REFRESH : IT_CHAR.
          CALL FUNCTION 'ZCHARACTERISTICS_ZQM001P'
            EXPORTING
              I_VAL_MATNR  = V_MATNR
              I_VAL_CHARGE = V_CHARG
            TABLES
              T_VAL_TAB    = IT_CHAR
            EXCEPTIONS
              NO_OBJECT    = 1
              NO_VALUES    = 2.

          IF SY-SUBRC EQ '0'. "-begin
            "- Roll Number
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              <FS_VEKP>-JRROLL =  <FS_CHAR>-ATWRT.
            ENDIF.
          ENDIF. "-end

          "- add by rimbun
          IS_OK = 'X'.
          "
        ENDIF.

      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.
    " ENDDO.

    IF FLAG EQ 'X'.
      CONTINUE.
    ENDIF.

    IF <FS_VEKP>-SONUM NE ''.
      V_VGBEL = <FS_VEKP>-SONUM(10).

      IF V_VGBEL NE ''.
        SELECT SINGLE VBAK~VBELN
        INTO <FS_VEKP>-VGBEL
        FROM VBAK
        WHERE VBAK~VBELN = V_VGBEL.
      ENDIF.

      IF SY-SUBRC = 0.
        <FS_VEKP>-VGPOS = <FS_VEKP>-SONUM+10(6).
      ENDIF.
    ENDIF.



    IF S_VGBEL IS NOT INITIAL.
      IF <FS_VEKP>-VGBEL NOT IN S_VGBEL.
        DELETE T_VEKP.
        CONTINUE.
      ENDIF.
    ENDIF.

    SELECT SINGLE VEKP~VPOBJKEY " changed by Irma
      INTO <FS_VEKP>-VBELN
      FROM VEKP
      INNER JOIN LIKP ON VEKP~VPOBJKEY = LIKP~VBELN
      WHERE VEKP~EXIDV = <FS_VEKP>-EXIDV
        AND LIKP~LFART IN ('HID', 'HOD', 'HTP', 'ZDLF', 'ZELF', 'ZNL', 'ZSL').

    IF S_VBELN IS NOT INITIAL.
      IF <FS_VEKP>-VBELN NOT IN S_VBELN.
        DELETE T_VEKP.
        CONTINUE.
      ENDIF.
    ENDIF.

    "- Customer
    SELECT SINGLE KNA1~NAME1
      INTO <FS_VEKP>-NAME1
      FROM KNA1
      INNER JOIN VBAK ON KNA1~KUNNR = VBAK~KUNNR
      WHERE VBAK~VBELN = <FS_VEKP>-VGBEL
        AND KNA1~KUNNR IN S_KUNNR.

    IF S_KUNNR IS NOT INITIAL.
      IF <FS_VEKP>-NAME1 EQ ''.
        DELETE T_VEKP.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF R1 = 'X'.
      IF V_CHARG NE ''.
        "- Inspection Lot
        SELECT MAX( QALS~PRUEFLOS )
           INTO <FS_VEKP>-PRUEFLOS
           FROM QALS
           WHERE QALS~CHARG = V_CHARG
             AND QALS~ART = 'Z02'.

        IF SY-SUBRC = 0.
          CLEAR : V_OBJNR.
          SELECT SINGLE JEST~OBJNR
            INTO V_OBJNR
            FROM JEST
            INNER JOIN QALS ON JEST~OBJNR = QALS~OBJNR
            WHERE QALS~PRUEFLOS = <FS_VEKP>-PRUEFLOS
              AND JEST~STAT EQ 'I0224'
              AND JEST~INACT EQ ''.

          IF SY-SUBRC = 0.
            <FS_VEKP>-PRUEFLOS = ''.
          ENDIF.
        ENDIF.

        "- Inspection Lot Ref
        IF <FS_VEKP>-PRUEFLOS = ''.
          SELECT SINGLE ZQM_LOG_GS~PRUEFLOS
            INTO <FS_VEKP>-PRUEFLOS
            FROM ZQM_LOG_GS
            WHERE ZQM_LOG_GS~CHARGAS = <FS_VEKP>-CHARG.
        ENDIF.

        "- Code UD SR / BOPET
        SELECT SINGLE QAVE~VCODE
          INTO <FS_VEKP>-VCODE
          FROM QAVE
          WHERE QAVE~PRUEFLOS = <FS_VEKP>-PRUEFLOS.
      ENDIF.

    ELSEIF R2 = 'X'.
      "- Inspection Lot
      SELECT MAX( QALS~PRUEFLOS )
         INTO <FS_VEKP>-PRUEFLOS
         FROM QALS
         WHERE QALS~CHARG = <FS_VEKP>-CHARG
             AND QALS~ART = 'Z04'.

      IF SY-SUBRC = 0.
        CLEAR : V_OBJNR.
        SELECT SINGLE JEST~OBJNR
          INTO V_OBJNR
          FROM JEST
          INNER JOIN QALS ON JEST~OBJNR = QALS~OBJNR
          WHERE QALS~PRUEFLOS = <FS_VEKP>-PRUEFLOS
            AND JEST~STAT EQ 'I0224'
            AND JEST~INACT EQ ''.

        IF SY-SUBRC = 0.
          <FS_VEKP>-PRUEFLOS = ''.
        ENDIF.
      ENDIF.

      "- Inspection Lot Ref
      IF <FS_VEKP>-PRUEFLOS = ''.
        SELECT SINGLE ZQM_LOG_GS~PRUEFLOS
          INTO <FS_VEKP>-PRUEFLOS
          FROM ZQM_LOG_GS
          WHERE ZQM_LOG_GS~CHARGAS = <FS_VEKP>-CHARG.
      ENDIF.

      "- Code UD SR / NON BOPET
      SELECT SINGLE QAVE~VCODE
        INTO <FS_VEKP>-VCODE
        FROM QAVE
        WHERE QAVE~PRUEFLOS = <FS_VEKP>-PRUEFLOS.
    ENDIF.

    "- HU Status
    CLEAR : V_STAT, V_MAX.
    SELECT MAX( SEQ )
      INTO V_MAX
      FROM ZQM001
      WHERE ZQM001~EXIDV = <FS_VEKP>-EXIDV.

    IF V_MAX NE 0.
      SELECT SINGLE ZQM001~PSTAT
      INTO V_STAT
      FROM ZQM001
      WHERE ZQM001~SEQ = V_MAX.
    ENDIF.

    IF V_STAT = 'P'.
      <FS_VEKP>-ZSTAT = 'Pass'.
    ELSEIF V_STAT  = 'H'.
      <FS_VEKP>-ZSTAT = 'Hold'.
    ELSEIF V_STAT  = ''.
      <FS_VEKP>-ZSTAT = 'Init'.
    ENDIF.

    "- Reason
    SELECT SINGLE ZQM001~NOTE
    INTO <FS_VEKP>-ZNOTE
    FROM ZQM001
    WHERE ZQM001~SEQ = V_MAX.


    "- Print
    SELECT SINGLE ZQM001~PRNT
      INTO <FS_VEKP>-PRNT
      FROM ZQM001
      WHERE ZQM001~SEQ = V_MAX.

    IF <FS_VEKP>-ZSTAT = 'Init'.
      <FS_VEKP>-PRNT = ''.
    ENDIF.


    CLEAR   : IT_CHAR.
    REFRESH : IT_CHAR.
    CALL FUNCTION 'ZCHARACTERISTICS_ZQM001P'
      EXPORTING
        I_VAL_MATNR  = <FS_VEKP>-MATNR
        I_VAL_CHARGE = <FS_VEKP>-CHARG
      TABLES
        T_VAL_TAB    = IT_CHAR
      EXCEPTIONS
        NO_OBJECT    = 1
        NO_VALUES    = 2.

    IF SY-SUBRC EQ '0'.
      "- No. Slit Roll
      IF P_ROLLNR = 'X'.
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_VEKP>-SLROLL =  <FS_CHAR>-ATWRT.
        ENDIF.
      ENDIF.

      CLEAR : V_TYPE.
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTYPE' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        V_TYPE =  <FS_CHAR>-ATWRT.
      ENDIF.

      CLEAR : V_THICK.
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTHICKNESS' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        MOVE <FS_CHAR>-ATFLV TO V_THICK2.
        WRITE V_THICK2 TO V_THICK.
      ENDIF.
    ENDIF.

    "- Type and Thickness
    CONCATENATE V_TYPE V_THICK INTO <FS_VEKP>-KTEXTMAT SEPARATED BY '-'.
    CONDENSE <FS_VEKP>-KTEXTMAT NO-GAPS.

    "- add 23-10-2012
    CLEAR : V_PRUEFLOS.
    SELECT MAX( QALS~PRUEFLOS )
      INTO V_PRUEFLOS
      FROM QALS
      WHERE QALS~CHARG = <FS_VEKP>-CHARG
        AND QALS~ART = 'Z04'.

    IF SY-SUBRC = 0.
      CLEAR : V_OBJNR.
      SELECT SINGLE JEST~OBJNR
        INTO V_OBJNR
        FROM JEST
        INNER JOIN QALS ON JEST~OBJNR = QALS~OBJNR
        WHERE QALS~PRUEFLOS = V_PRUEFLOS
          AND JEST~STAT EQ 'I0224'
          AND JEST~INACT EQ ''.

      IF SY-SUBRC = 0.
        V_PRUEFLOS = ''.
      ENDIF.
    ENDIF.

    "- Inspection Lot Ref
    IF V_PRUEFLOS = ''.
      SELECT SINGLE ZQM_LOG_GS~PRUEFLOS
        INTO V_PRUEFLOS
        FROM ZQM_LOG_GS
        WHERE ZQM_LOG_GS~CHARGAS = <FS_VEKP>-CHARG.
    ENDIF.

    IF V_BUDAT NE '00000000'.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXPIREDLIVE' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        MOVE <FS_CHAR>-ATFLV TO ATFLV1.
        WRITE ATFLV1 TO V_EXP.
        CONDENSE V_EXP NO-GAPS.
        <FS_VEKP>-ZEXP = V_BUDAT + V_EXP.
      ELSE.
        <FS_VEKP>-ZZEXP = 'Not Maintain'.
      ENDIF.
    ELSE.
      <FS_VEKP>-ZZEXP = 'Not Maintain'.
    ENDIF.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <FS_VEKP>-EXIDV
      IMPORTING
        OUTPUT = <FS_VEKP>-EXIDV.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <FS_VEKP>-PRUEFLOS
      IMPORTING
        OUTPUT = <FS_VEKP>-PRUEFLOS.

    IF <FS_VEKP>-VGPOS NE ''.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = <FS_VEKP>-VGPOS
        IMPORTING
          OUTPUT = <FS_VEKP>-VGPOS.

      <FS_VEKP>-ZVGPOS = <FS_VEKP>-VGPOS.
    ELSE.
      <FS_VEKP>-ZVGPOS = ''.
    ENDIF.

  ENDLOOP.

  SORT T_VEKP ASCENDING BY VENUM CHARG.
  DELETE ADJACENT DUPLICATES FROM T_VEKP COMPARING VENUM CHARG.

*baca status QAIN/QAOK by Irma On 16-10-2012
  DATA : PSTAT LIKE HUSSTAT-STAT,
         POBJNR(12),
         VENUM LIKE VEPO-VENUM.

  LOOP AT T_VEKP WHERE EXIDV NE ''.
    CLEAR : PSTAT, POBJNR, VENUM.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = T_VEKP-EXIDV
      IMPORTING
        OUTPUT = T_VEKP-EXIDV.

    SELECT SINGLE VENUM
      INTO VENUM
      FROM VEKP
      WHERE EXIDV EQ  T_VEKP-EXIDV.
    IF VENUM NE ''.
      CONCATENATE 'HU' VENUM INTO POBJNR.
    ENDIF.
    IF POBJNR NE ''.
      SELECT SINGLE STAT
        INTO PSTAT
        FROM HUSSTAT
        WHERE OBJNR EQ POBJNR AND STAT = 'E0001' AND INACT EQ ''.
    ENDIF.
    IF PSTAT EQ 'E0001'.
      T_VEKP-HUSTAT = 'QA IN'.
    ELSE.
      T_VEKP-HUSTAT = 'QA OK'.
    ENDIF.
    CONDENSE T_VEKP-EXIDV.

    MODIFY T_VEKP.
  ENDLOOP.

  CASE P_LIST.
    WHEN 'QA IN'.
      DELETE T_VEKP WHERE HUSTAT EQ 'QA OK'.
    WHEN 'QA OK'.
      DELETE T_VEKP WHERE HUSTAT EQ 'QA IN'.
  ENDCASE.

  PERFORM CEK_COMPLETENESS. "Add by Irma on 16-10-2012
ENDFORM.                    " READ_HANDLING_UNIT



*&---------------------------------------------------------------------*
*&      Form  EDIT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EDIT_STATUS .
  DATA : V_KALAB LIKE MSKA-KALAB,
         V_KASPE LIKE MSKA-KASPE.

  CLEAR   : T_TEMP, LN.
  REFRESH : T_TEMP.

  DESCRIBE LIST NUMBER OF LINES LN.

  GET CURSOR FIELD CFIELD1.
  IF SY-UCOMM =  'PICK' AND CFIELD1 EQ 'WA_VEKP-PRUEFLOS'.
    PERFORM CALL_TRANS .
  ELSE.
    IF SY-UCOMM = 'EDIT'.
      PERFORM GET_SELECTED.

      IF COUNT = 0.
        MESSAGE I000(0K) WITH 'No Data Selected.'.
        EXIT.
      ENDIF.
    ELSE.
      GET CURSOR FIELD CFIELD.
      IF CFIELD = 'WA_VEKP-EXIDV'.
        READ CURRENT LINE FIELD VALUE WA_VEKP-EXIDV.
        READ CURRENT LINE FIELD VALUE WA_VEKP-ZSTAT.
        T_TEMP-EXIDV = WA_VEKP-EXIDV.
        T_TEMP-ZSTAT = WA_VEKP-ZSTAT.
        COLLECT T_TEMP.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.

*- add condition must completed/closed by ALF at 06-02-2014
    DATA: V_HUSTAT LIKE ZPACK_PCL-HUSTAT,
          V_MSG(100).
    LOOP AT T_TEMP WHERE EXIDV NE ''.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = T_TEMP-EXIDV
        IMPORTING
          OUTPUT = T_TEMP-EXIDV.

      SELECT SINGLE B~HUSTAT INTO V_HUSTAT
    FROM VEKP AS A JOIN ZPACK_PCL AS B ON A~VENUM = B~VENUM
    WHERE A~EXIDV = T_TEMP-EXIDV.

      IF SY-SUBRC = 0.
        IF V_HUSTAT = 'O'.
          CONCATENATE 'Status packing HU nomor' T_TEMP-EXIDV+10(10) 'masih Open.' INTO V_MSG SEPARATED BY SPACE.
          MESSAGE V_MSG TYPE 'I'.
          V_HUSTAT = '-'.
          EXIT.
        ELSEIF  V_HUSTAT = 'I'.
          CONCATENATE 'Status packing HU nomor' T_TEMP-EXIDV+10(10) 'masih In Progress.' INTO V_MSG SEPARATED BY SPACE.
          MESSAGE V_MSG TYPE 'I'.
          V_HUSTAT = '-'.
          EXIT.
        ELSE.
        ENDIF.
      ELSE.
        MESSAGE 'Status packing tidak ditemukan.' TYPE 'I'.
        V_HUSTAT = '-'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF V_HUSTAT = '-'.
      EXIT.
    ENDIF.
*- end of add condition must completed/closed

    REFRESH : SEL.

    SEL-TABNAME    = 'ZQM001'.
    SEL-FIELDNAME  = 'PSTAT'.
    SEL-VALUE      = ''.
    APPEND SEL.

    SEL-TABNAME    = 'ZQM001'.
    SEL-FIELDNAME  = 'NOTE'.
    SEL-VALUE      = ''.
    APPEND SEL.

    SEL-TABNAME    = 'ZQM001'.
    SEL-FIELDNAME  = 'NIK'.
    SEL-VALUE      = ''.
    APPEND SEL.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        POPUP_TITLE     = 'Enter QC Packing Status'
        START_COLUMN    = '28'
        START_ROW       = '15'
      IMPORTING
        RETURNCODE      = RETRN
      TABLES
        FIELDS          = SEL
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.


    READ TABLE SEL  WITH KEY FIELDNAME = 'PSTAT'.
    IF SY-SUBRC = 0.
      TSTAT-PSTAT  = SEL-VALUE.
    ENDIF.
    READ TABLE SEL  WITH KEY FIELDNAME = 'NOTE'.
    IF SY-SUBRC = 0.
      TSTAT-NOTE   = SEL-VALUE.
    ENDIF.
    READ TABLE SEL  WITH KEY FIELDNAME = 'NIK'.
    IF SY-SUBRC = 0.
      TSTAT-NIK   = SEL-VALUE.
    ENDIF.

    IF TSTAT-NIK EQ '00000000'.
      MESSAGE 'Masukkan NIK' TYPE 'E'.
      EXIT.
    ENDIF.

    PERFORM CEK_EDITED. "Add by Irma (untuk data yang tidak bisa dichange)
    LOOP AT T_TEMP.
      IF T_TEMP-VBELN EQ ''.
        CLEAR : SIGN, V_EXIDV.
        IF T_TEMP-ZSTAT = 'Init' AND TSTAT-PSTAT = 'H'.
          PERFORM UNRESTR_MOVING USING '0023'.     " 344 (Unrestr. to Blocked)
          IF SIGN NE 'X'.
            T_TEMP-ZSTAT = 'Hold'.
            IF TSTAT-NOTE NE ''.
              T_TEMP-ZNOTE = TSTAT-NOTE.
            ENDIF.

          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF T_TEMP-ZSTAT = 'Init' AND TSTAT-PSTAT = 'P'.
          PERFORM CHECK.
          IF SIGN NE 'X'.
            T_TEMP-ZSTAT = 'Pass'.
            IF TSTAT-NOTE NE ''.
              T_TEMP-ZNOTE = TSTAT-NOTE.
            ENDIF.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF T_TEMP-ZSTAT = 'Hold' AND TSTAT-PSTAT = 'P'.

          PERFORM UNRESTR_MOVING USING '0022'.     " 343 (Blocked to unrestr.)
          IF SIGN NE 'X'.
            T_TEMP-ZSTAT = 'Pass'.
            IF TSTAT-NOTE NE ''.
              T_TEMP-ZNOTE = TSTAT-NOTE.
            ENDIF.

          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF T_TEMP-ZSTAT = 'Pass' AND TSTAT-PSTAT = 'H'.

          PERFORM UNRESTR_MOVING USING '0023'.     " 344 (Unrestr. to Blocked)
          IF SIGN NE 'X'.
            T_TEMP-ZSTAT = 'Hold'.
            IF TSTAT-NOTE NE ''.
              T_TEMP-ZNOTE = TSTAT-NOTE.
            ENDIF.

          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY T_TEMP.
    ENDLOOP.


    LOOP AT T_TEMP.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = T_TEMP-EXIDV
        IMPORTING
          OUTPUT = T_TEMP-EXIDV.

      LOOP AT T_VEKP WHERE EXIDV = T_TEMP-EXIDV.
        T_VEKP-ZSTAT = T_TEMP-ZSTAT.
        T_VEKP-PRNT  = ''.
        IF T_TEMP-ZNOTE NE ''.
          T_VEKP-ZNOTE = T_TEMP-ZNOTE.
        ENDIF.
        MODIFY T_VEKP.
      ENDLOOP.
    ENDLOOP.

  ENDIF.

  IF R1 = 'X'.
    PERFORM DISPLAY_DATA USING ''.
  ELSE.
    PERFORM DISPLAY_DATA_NON USING ''.
  ENDIF.

ENDFORM.                    " EDIT_STATUS
*&---------------------------------------------------------------------*
*&      Form  SELECT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_STATUS .
  CLEAR : SEL, VSTAT.
  REFRESH SEL.

  SEL-TABNAME   = 'ZQM001'.
  SEL-FIELDNAME = 'PSTAT'.
  APPEND SEL.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'Select Only for Status :'
      START_COLUMN    = '34'
      START_ROW       = '08'
    TABLES
      FIELDS          = SEL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.

  READ TABLE SEL  WITH KEY FIELDNAME = 'PSTAT'.
  IF SY-SUBRC = 0.
    G_SELE = SEL-VALUE.
  ELSE.
    CLEAR G_SELE.
  ENDIF.

  IF G_SELE = ''.
    VSTAT = 'Init'.
  ELSEIF G_SELE = 'P'.
    VSTAT = 'Pass'.
  ELSEIF G_SELE = 'H'.
    VSTAT = 'Hold'.
  ENDIF.

  CLEAR C.
  SY-LSIND = SY-LSIND - 1.
  IF R1 = 'X'.
    PERFORM DISPLAY_DATA USING ''.
  ELSE.
    PERFORM DISPLAY_DATA_NON USING ''.
  ENDIF.


ENDFORM.                    " SELECT_STATUS
*&---------------------------------------------------------------------*
*&      Form  DESELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESELECT .

  CLEAR C.
  SY-LSIND = SY-LSIND - 1.
  IF R1 = 'X'.
    PERFORM DISPLAY_DATA USING ''.
  ELSE.
    PERFORM DISPLAY_DATA_NON USING ''.
  ENDIF.


ENDFORM.                    " DESELECT



*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.


  DATA : ROW(4) TYPE N.
  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CASE SY-UCOMM.
    WHEN 'SORTI'.
      LEAVE TO SCREEN 0.

    WHEN 'EDIT'.
      PERFORM EDIT_STATUS.

    WHEN 'SELE'.
      PERFORM SELECT_STATUS.

    WHEN 'DESE'.
      PERFORM DESELECT.

    WHEN 'PRT'.
      PERFORM GET_SELECTED.
      PERFORM PRINT.

    WHEN 'CSTAT'.
      PERFORM CALL_CHANGEHUSTAT.

    WHEN 'PICK'.
      PERFORM CALL_TRANS.

    WHEN 'CLOG'.
      PERFORM GET_DATA.

  ENDCASE.

ENDFORM. "user_command


*&---------------------------------------------------------------------*
*&      Form  UNRESTR_MOVING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0685   text
*----------------------------------------------------------------------*
FORM UNRESTR_MOVING  USING VALUE(P_MOVM).

  SET PARAMETER ID 'WRK' FIELD PLANT.
  SET PARAMETER ID 'LAG' FIELD SLOC.
  GET PARAMETER ID 'HU_ST_INIT' FIELD FL.

  REFRESH : BDCDATA, MSGS.
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'
                            '2000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV 2013TAB_SUB'.
  PERFORM BDC_FIELD   USING 'BDC_CURSOR'
                            'LEMOVHUS-HUWBEVENT'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-HUWBEVENT'
                             P_MOVM.   "
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV 2010HU_FRAME'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV  2017SUB_BUT'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'
                            '=TCVG'.

  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'
                            '2000'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV 2013TAB_SUB'.
  PERFORM BDC_FIELD   USING 'BDC_CURSOR'
                            'LEMOVHUS-EXIDV'.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-HUWBEVENT'
                             P_MOVM.
  PERFORM BDC_FIELD   USING 'LEMOVHUS-EXIDV'
                             T_TEMP-EXIDV.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV  2010HU_FRAME'.
  PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
                            'SAPLLE_MOV   2017SUB_BUT'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'
                            '=TCHC'.
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'
                            '2000'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'
                            '=TCWB'.
  PERFORM BDC_DYNPRO  USING 'SAPLLE_MOV'
                            '2001'.
  PERFORM BDC_FIELD   USING 'BDC_OKCODE'
                            '/ETCBA'.
*
  CALL TRANSACTION 'VLMOVE' USING BDCDATA
                            MODE D_MODE
                            UPDATE 'S'
                            MESSAGES INTO MSGS.
  CLEAR : MSTEXT.
  IF NOT MSGS[] IS INITIAL.
    LOOP AT MSGS INTO WMSGS WHERE MSGNR NE '029'.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          ID   = WMSGS-MSGID
          LANG = SY-LANGU
          NO   = WMSGS-MSGNR
          V1   = WMSGS-MSGV1
          V2   = WMSGS-MSGV2
          V3   = WMSGS-MSGV3
          V4   = WMSGS-MSGV4
        IMPORTING
          MSG  = MSTEXT.
    ENDLOOP.
  ENDIF.

  IF MSTEXT EQ ''.
    PERFORM CHECK.
  ELSE.
    CONCATENATE 'HU' T_TEMP-EXIDV 'tidak dapat dipindahkan, cek status.' INTO V_TEXT SEPARATED BY SPACE.
    MESSAGE I000(0K) WITH V_TEXT.
    SIGN = 'X'.
  ENDIF.

ENDFORM.                    " UNRESTR_MOVING

*----------------------------------------------------------------------*
*        Form bdc_dynpro                                               *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Form bdc_field                                                *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL <> '/'.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  INSERT_WITHOUT_HULO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_WITHOUT_HULO .
  T_VEKP-VENUM  = THU-VENUM.
  T_VEKP-EXIDV  = THU-EXIDV.
  T_VEKP-UNVEL  = THULO-UNVEL.
  T_VEKP-POSNR  = THUITM-POSNR.
  T_VEKP-MATNR  = THULO-MATNR.
  T_VEKP-CHARG  = THULO-CHARG.

ENDFORM.                    " INSERT_WITHOUT_HULO


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA USING VALUE(CHK).
  IF T_VEKP[] IS INITIAL.
    MESSAGE I000(0K) WITH 'No Data Selected.'.
    EXIT.
  ENDIF.

  SET PF-STATUS 'BLIST'.
  SORT T_VEKP ASCENDING BY EXIDV.
  DATA : FLG, I TYPE I.
  VL = SY-VLINE.

  LOOP AT T_VEKP.
    WA_VEKP = T_VEKP.
    MARK01  = CHK.

    IF WA_VEKP-STATODO EQ 'C' AND WA_VEKP-LFART EQ ''.
      WA_VEKP-VBELN = ''.
    ENDIF.

    AT NEW EXIDV.
      FLG = 'X'.
      PERFORM SET_COLOR.
    ENDAT.

    IF FLG = 'X'.
      IF SY-UCOMM = 'SELE' AND T_VEKP-ZSTAT = VSTAT.
        MARK01 = 'X'.
      ELSE.
        MARK01 = ' '.
      ENDIF.
      WRITE : / VL NO-GAP, MARK01 AS CHECKBOX COLOR COL_NEGATIVE.
      IF T_VEKP-PRNT EQ ''.
        WRITE ICON_LED_RED AS ICON.
      ELSE.
        WRITE ICON_LED_GREEN AS ICON.
      ENDIF.
      WRITE :  (12) WA_VEKP-EXIDV NO-GAP COLOR COL_KEY INTENSIFIED,
                VL, (8) WA_VEKP-ZSTAT,
                VL, (9) WA_VEKP-HUSTAT NO-GAP. " BY irma
      WRITE :   42
                VL NO-GAP, (20) WA_VEKP-KTEXTMAT NO-GAP,
                VL NO-GAP, (13) WA_VEKP-CHARG NO-GAP,
                VL NO-GAP, (28) WA_VEKP-SLROLL NO-GAP, "20 by Irma
                VL NO-GAP, (20) WA_VEKP-JRROLL NO-GAP,
                VL NO-GAP, (18) WA_VEKP-PRUEFLOS NO-GAP,
                VL NO-GAP, (10) WA_VEKP-VCODE NO-GAP,
                VL NO-GAP, (13) WA_VEKP-VGBEL NO-GAP,
                VL NO-GAP, (7)  WA_VEKP-ZVGPOS NO-GAP,
                VL NO-GAP, (13) WA_VEKP-VBELN NO-GAP,
                VL NO-GAP, (31) WA_VEKP-NAME1 NO-GAP.
      IF T_VEKP-ZZEXP NE ''.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZZEXP NO-GAP.
      ELSE.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZEXP NO-GAP.
      ENDIF.
      WRITE :    VL NO-GAP, (40) WA_VEKP-ZNOTE NO-GAP.
      WRITE :    VL NO-GAP.
      FLG = ' '.
    ELSE.
      WRITE : / VL NO-GAP, 19 VL, 30 VL.
      WRITE :   42
                  VL NO-GAP, (20) WA_VEKP-KTEXTMAT NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-CHARG NO-GAP,
                  VL NO-GAP, (28) WA_VEKP-SLROLL NO-GAP,
                  VL NO-GAP, (20) WA_VEKP-JRROLL NO-GAP,
                  VL NO-GAP, (18) WA_VEKP-PRUEFLOS NO-GAP,
                  VL NO-GAP, (10) WA_VEKP-VCODE NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-VGBEL NO-GAP,
                  VL NO-GAP, (7)  WA_VEKP-ZVGPOS NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-VBELN NO-GAP,
                  VL NO-GAP, (31) WA_VEKP-NAME1 NO-GAP.
      IF T_VEKP-ZZEXP NE ''.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZZEXP NO-GAP.
      ELSE.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZEXP NO-GAP.
      ENDIF.
      WRITE : VL NO-GAP.
      WRITE : 279 VL NO-GAP.
    ENDIF.
  ENDLOOP.
  WRITE : / SY-ULINE(255).
  SET LEFT SCROLL-BOUNDARY COLUMN 64.
ENDFORM.                    " DISPLAY_DATA


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
    C = 'X'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    CLEAR C.
  ENDIF.

ENDFORM.                    " SET_COLOR


*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HEADER_DATA .
  DATA: VL.
  VL = SY-VLINE.
*  WRITE : 'PT. TRIAS SENTOSA Tbk.'. "disable new company
  WRITE : / 'QM PACKING LIST BOPET', 175 'Page : ', (2) SY-PAGNO.
  SKIP.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE : / SY-ULINE(255).
  WRITE : / VL NO-GAP, '', ICON_PRINT AS ICON,'HU Number   ' NO-GAP,
            VL NO-GAP, 'HU QA Stat'  NO-GAP,
            VL NO-GAP, 'QA IN/QA OK' NO-GAP, "add by Irma
            VL NO-GAP, 'Type/Thickness SR   ' NO-GAP,
            VL NO-GAP, 'Batch SR     '   NO-GAP,
            VL NO-GAP, 'No Slit Roll                ' NO-GAP,
            VL NO-GAP, 'No Jumbo Roll       ' NO-GAP,
            VL NO-GAP, 'JR Inspection Lot '  NO-GAP,
            VL NO-GAP, 'Code UD JR' NO-GAP,
            VL NO-GAP, 'SO Number    ' NO-GAP,
            VL NO-GAP, 'SO Item' NO-GAP,
            VL NO-GAP, 'DO Number    ' NO-GAP,
            VL NO-GAP, 'Customer                       ' NO-GAP,
            VL NO-GAP, 'Expiry Date ' NO-GAP,
            VL NO-GAP, 'Reason                                  ' NO-GAP,
            VL NO-GAP.
  WRITE : / SY-ULINE(255).
  FORMAT RESET INTENSIFIED ON.



ENDFORM.                    " HEADER_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA_NON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0020   text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA_NON  USING    VALUE(CHK).
  IF T_VEKP[] IS INITIAL.
    MESSAGE I000(0K) WITH 'No Data Selected.'.
    EXIT.
  ENDIF.


  SET PF-STATUS 'BLIST'.
  SORT T_VEKP ASCENDING BY EXIDV.
  DATA : FLG, I TYPE I.
  VL = SY-VLINE.

  LOOP AT T_VEKP.
    WA_VEKP = T_VEKP.
    MARK01  = CHK.

    IF WA_VEKP-STATODO EQ 'C' AND WA_VEKP-LFART EQ ''. " add by Irma
      WA_VEKP-VBELN = ''.
    ENDIF.

    AT NEW EXIDV.
      FLG = 'X'.
      PERFORM SET_COLOR.
    ENDAT.

    IF FLG = 'X'.
      IF SY-UCOMM = 'SELE' AND T_VEKP-ZSTAT = VSTAT.
        MARK01 = 'X'.
      ELSE.
        MARK01 = ' '.
      ENDIF.
      WRITE : / VL NO-GAP, MARK01 AS CHECKBOX COLOR COL_NEGATIVE.
      IF T_VEKP-PRNT EQ ''.
        WRITE ICON_LED_RED AS ICON.
      ELSE.
        WRITE ICON_LED_GREEN AS ICON.
      ENDIF.
      WRITE :  (12) WA_VEKP-EXIDV NO-GAP COLOR COL_KEY INTENSIFIED,
                VL ,(8) WA_VEKP-ZSTAT,
                VL ,(11) WA_VEKP-HUSTAT
                NO-GAP.
      WRITE :   42
                VL NO-GAP, (20) WA_VEKP-KTEXTMAT NO-GAP,
                VL NO-GAP, (13) WA_VEKP-CHARG NO-GAP,
                VL NO-GAP, (28) WA_VEKP-SLROLL NO-GAP,
                VL NO-GAP, (18) WA_VEKP-PRUEFLOS NO-GAP,
                VL NO-GAP, (10) WA_VEKP-VCODE NO-GAP,
                VL NO-GAP, (13) WA_VEKP-VGBEL NO-GAP,
                VL NO-GAP, (7)  WA_VEKP-ZVGPOS NO-GAP,
                VL NO-GAP, (13) WA_VEKP-VBELN NO-GAP,
                VL NO-GAP, (31) WA_VEKP-NAME1 NO-GAP.
      IF T_VEKP-ZZEXP NE ''.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZZEXP NO-GAP.
      ELSE.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZEXP NO-GAP.
      ENDIF.
      WRITE:     VL NO-GAP, (61) WA_VEKP-ZNOTE NO-GAP.
      WRITE :    VL NO-GAP.
      FLG = ' '.
    ELSE.
      WRITE : / VL NO-GAP, 19 VL, 30 VL.
      WRITE :   42
                  VL NO-GAP, (20) WA_VEKP-KTEXTMAT NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-CHARG NO-GAP,
                  VL NO-GAP, (28) WA_VEKP-SLROLL NO-GAP,
                  VL NO-GAP, (18) WA_VEKP-PRUEFLOS NO-GAP,
                  VL NO-GAP, (10) WA_VEKP-VCODE NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-VGBEL NO-GAP,
                  VL NO-GAP, (7)  WA_VEKP-ZVGPOS NO-GAP,
                  VL NO-GAP, (13) WA_VEKP-VBELN NO-GAP,
                  VL NO-GAP, (31) WA_VEKP-NAME1 NO-GAP.
      IF T_VEKP-ZZEXP NE ''.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZZEXP NO-GAP.
      ELSE.
        WRITE :       VL NO-GAP, (12) WA_VEKP-ZEXP NO-GAP.
      ENDIF.
      WRITE :    VL NO-GAP. "(40) WA_VEKP-ZNOTE NO-GAP. "commented by Irma
      WRITE : 279 VL NO-GAP.
    ENDIF.
  ENDLOOP.
  WRITE : / SY-ULINE(255).
  SET LEFT SCROLL-BOUNDARY COLUMN 64.
ENDFORM.                    " DISPLAY_DATA_NON


*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_NON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HEADER_DATA_NON .
  DATA: VL.
  VL = SY-VLINE.
*  WRITE : 'PT. TRIAS SENTOSA Tbk.'. "disable new company
  WRITE : / 'QM PACKING LIST NON BOPET', 175 'Page : ', (2) SY-PAGNO.
  SKIP.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE : / SY-ULINE(255), 257 SY-ULINE NO-GAP.
  WRITE : / VL NO-GAP, '', ICON_PRINT AS ICON,'HU Number   ' NO-GAP,
            VL NO-GAP, 'HU QA Stat'  NO-GAP,
            VL NO-GAP, 'QA IN/QA OK' NO-GAP, "Add by Irma
            VL NO-GAP, 'Type/Thickness SR   ' NO-GAP,
            VL NO-GAP, 'Batch SR     '   NO-GAP,
            VL NO-GAP, 'No Slit Roll                ' NO-GAP, "28
            VL NO-GAP, 'SR Inspection Lot ' NO-GAP,
            VL NO-GAP, 'Code UD SR' NO-GAP,
            VL NO-GAP, 'SO Number    ' NO-GAP,
            VL NO-GAP, 'SO Item' NO-GAP,
            VL NO-GAP, 'DO Number    ' NO-GAP,
            VL NO-GAP, 'Customer                       ' NO-GAP,
            VL NO-GAP, 'Expiry Date ' NO-GAP,
            VL NO-GAP, 'Reason                                                       ' NO-GAP,
            VL NO-GAP.
  WRITE : / SY-ULINE(255).
  FORMAT RESET INTENSIFIED ON.

ENDFORM.                    " HEADER_DATA_NON

*&---------------------------------------------------------------------*
*&      Form  CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK.

  CLEAR : WA_ZQM001.
  IF TSTAT-NOTE NE ''.
    WA_ZQM001-NOTE   = TSTAT-NOTE.
  ENDIF.

  IF TSTAT-NIK NE ''.
    WA_ZQM001-NIK   = TSTAT-NIK.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = T_TEMP-EXIDV
    IMPORTING
      OUTPUT = T_TEMP-EXIDV.

  WA_ZQM001-EXIDV  = T_TEMP-EXIDV.
  WA_ZQM001-PSTAT  = TSTAT-PSTAT.
  WA_ZQM001-AEDAT  = SY-DATUM.
  WA_ZQM001-AETIME = SY-UZEIT.

  CLEAR : V_SEQ.
  SELECT MAX( SEQ )
  INTO V_SEQ
  FROM ZQM001.

  IF SY-SUBRC <> 0.
    WA_ZQM001-SEQ = 1.
  ELSE.
    WA_ZQM001-SEQ = V_SEQ + 1.
  ENDIF.



  INSERT INTO ZQM001 VALUES WA_ZQM001.
  COMMIT WORK AND WAIT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = T_TEMP-EXIDV
    IMPORTING
      OUTPUT = T_TEMP-EXIDV.

  CLEAR : V_TEXT.
  CONCATENATE 'HU' T_TEMP-EXIDV 'berhasil dipindahkan.' INTO V_TEXT SEPARATED BY SPACE.
  MESSAGE V_TEXT TYPE 'S'.

ENDFORM.                    " CHECK

*&---------------------------------------------------------------------*
*&      Form  CALL_CHANGEHUSTAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_CHANGEHUSTAT .
  DATA : BEGIN OF IT_EXIDV OCCURS 0,
          EXIDV LIKE VEKP-EXIDV,
         END OF IT_EXIDV.
  DATA : IT_BDCMSGCOLLE LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
         WA_BDCMSGCOLLE LIKE LINE OF IT_BDCMSGCOLLE.
  DATA: BEGIN OF ERRMSG OCCURS 10.
          INCLUDE STRUCTURE BAPIRET2.
  DATA: END OF ERRMSG,
        MESSAGE LIKE BAPIRET2-MESSAGE.

  DATA : CTR TYPE I, IND TYPE I, SELECTED TYPE I.
  CLEAR : IT_EXIDV . REFRESH IT_EXIDV.

  DESCRIBE LIST NUMBER OF LINES CTR.

  IND = 0.
  DO CTR TIMES.
    CLEAR T_TEMP.
    CLEAR MARK01.
    CLEAR WA_VEKP-EXIDV.
    CLEAR WA_VEKP-ZSTAT.
    READ LINE SY-INDEX FIELD VALUE MARK01.
    READ LINE SY-INDEX FIELD VALUE WA_VEKP-EXIDV.
    READ LINE SY-INDEX FIELD VALUE WA_VEKP-ZSTAT.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK01 = 'X' AND WA_VEKP-ZSTAT NE 'Init'.
      IT_EXIDV-EXIDV = WA_VEKP-EXIDV.
      APPEND IT_EXIDV.
      IND = IND + 1.
    ENDIF.

    IF MARK01 = 'X' AND WA_VEKP-ZSTAT EQ 'Init'.
      SELECTED = SELECTED + 1.
    ENDIF.
  ENDDO.

  IF IND = 0.
    IF SELECTED > 0.
      MESSAGE 'HU dengan status Init tidak dapat diubah.' TYPE 'E'.
    ELSE.
      MESSAGE 'No Data Selected.' TYPE 'E'.
    ENDIF.
  ELSE.
    CLEAR IT_BDCMSGCOLLE. REFRESH IT_BDCMSGCOLLE.
    EXPORT IT_EXIDV TO MEMORY ID 'IT_EXIDV'.
    SUBMIT ZQMI_CHANGE_STAT_HU AND RETURN.
    IMPORT IT_BDCMSGCOLLE FROM MEMORY ID 'IT_BDCMSGCOLLE'.
    IF IT_BDCMSGCOLLE[] IS NOT INITIAL.
      CLEAR: WA_BDCMSGCOLLE, ERRMSG.
      REFRESH ERRMSG.

      LOOP AT IT_BDCMSGCOLLE WHERE MSGID NE 'HUDIALOG' AND MSGNR NE '008'.
        ERRMSG-ID  =  IT_BDCMSGCOLLE-MSGID.
        ERRMSG-NUMBER =  IT_BDCMSGCOLLE-MSGNR.
        ERRMSG-MESSAGE_V1 = IT_BDCMSGCOLLE-MSGV1.
        ERRMSG-MESSAGE_V2 = IT_BDCMSGCOLLE-MSGV2.
        ERRMSG-MESSAGE_V3 = IT_BDCMSGCOLLE-MSGV3.
        ERRMSG-MESSAGE_V4 = IT_BDCMSGCOLLE-MSGV4.
        APPEND ERRMSG.
      ENDLOOP.
      IF ERRMSG[] IS NOT INITIAL.
        LOOP AT ERRMSG.
          CLEAR MESSAGE.
          CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
            EXPORTING
              ID         = ERRMSG-ID
              NUMBER     = ERRMSG-NUMBER
              LANGUAGE   = SY-LANGU
              TEXTFORMAT = 'HTM'
              MESSAGE_V1 = ERRMSG-MESSAGE_V1
              MESSAGE_V2 = ERRMSG-MESSAGE_V2
              MESSAGE_V3 = ERRMSG-MESSAGE_V3
              MESSAGE_V4 = ERRMSG-MESSAGE_V4
            IMPORTING
              MESSAGE    = MESSAGE.
          IF MESSAGE NE ''.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF MESSAGE NE ''.
          MESSAGE MESSAGE TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM UPDATE_VEKP.

  IF R1 = 'X'.
    PERFORM DISPLAY_DATA USING ''.
  ELSE.
    PERFORM DISPLAY_DATA_NON USING ''.
  ENDIF.
ENDFORM.                    " CALL_CHANGEHUSTAT

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_TRANS .
  DATA : CFIELD(20),
         CHARG LIKE VEKP-CHARG,
         PRUEFLOS LIKE QALS-PRUEFLOS,
         MATNR LIKE QALS-MATNR.
  DATA : WA_QALS LIKE QALS.

  CLEAR : CFIELD, CHARG, PRUEFLOS, MATNR, WA_QALS.
  GET CURSOR FIELD CFIELD.
  IF CFIELD = 'WA_VEKP-PRUEFLOS'.
    READ CURRENT LINE FIELD VALUE WA_VEKP-PRUEFLOS.

    IF R2 = 'X'.
      PRUEFLOS = SY-LISEL+106(12).
      CHARG = SY-LISEL+63(10).
    ELSE.
      PRUEFLOS = SY-LISEL+127(12).
      CHARG = SY-LISEL+63(10).
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PRUEFLOS
      IMPORTING
        OUTPUT = PRUEFLOS.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PRUEFLOS
      IMPORTING
        OUTPUT = PRUEFLOS.

    SELECT SINGLE *
      INTO WA_QALS
      FROM QALS
      WHERE PRUEFLOS = PRUEFLOS.
    IF SY-SUBRC <> 0.
      MESSAGE 'No data found' TYPE 'E'.
    ELSE.


      SET PARAMETER ID 'QLS' FIELD PRUEFLOS.
      CALL TRANSACTION 'QE03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.                    " CALL_TRANS

*&---------------------------------------------------------------------*
*&      Form  UPDATE_VEKP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_VEKP .
*baca status QAIN/QAOK by Irma On 16-10-2012
  DATA : PSTAT LIKE HUSSTAT-STAT,
         POBJNR(12),
         VENUM LIKE VEPO-VENUM.

  LOOP AT T_VEKP WHERE EXIDV NE ''.
    CLEAR : PSTAT, POBJNR, VENUM.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = T_VEKP-EXIDV
      IMPORTING
        OUTPUT = T_VEKP-EXIDV.

    SELECT SINGLE VENUM
      INTO VENUM
      FROM VEKP
      WHERE EXIDV EQ  T_VEKP-EXIDV.
    IF VENUM NE ''.
      CONCATENATE 'HU' VENUM INTO POBJNR.
    ENDIF.
    IF POBJNR NE ''.
      SELECT SINGLE STAT
        INTO PSTAT
        FROM HUSSTAT
        WHERE OBJNR EQ POBJNR AND STAT = 'E0001' AND INACT EQ ''.
    ENDIF.

    IF PSTAT EQ 'E0001'.
      T_VEKP-HUSTAT = 'QA IN'.
    ELSE.
      T_VEKP-HUSTAT = 'QA OK'.
    ENDIF.

    MODIFY T_VEKP.
  ENDLOOP.
ENDFORM.                    " UPDATE_VEKP


*&---------------------------------------------------------------------*
*&      Form  CEK_EDITED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_EDITED .
  DATA : IT_ODO LIKE T_VEKP OCCURS 0 WITH HEADER LINE,
         VBELN LIKE LIKP-VBELN,
         WA_VBUK LIKE VBUK,
         WA_LIKP LIKE LIKP.

  LOOP AT T_TEMP WHERE VBELN NE ''.
    CLEAR: VBELN, WA_VBUK, WA_LIKP.
    VBELN = T_TEMP-VBELN.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = VBELN
      IMPORTING
        OUTPUT = VBELN.

    SELECT SINGLE *
      INTO WA_VBUK
      FROM VBUK
      WHERE VBELN = VBELN.
    IF WA_VBUK-WBSTK EQ 'C'.
      SELECT SINGLE *
        INTO WA_LIKP
        FROM LIKP
        WHERE VBELN = VBELN AND LFART IN ('ZDLF', 'ZELF').
      IF WA_LIKP-VBELN NE ''.
        DELETE T_TEMP.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CEK_EDITED


*&---------------------------------------------------------------------*
*&      Form  UPDATE_VEKPDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_VEKPDATA .
  DATA : EXIDV LIKE ZQM001-EXIDV,
         WA_ZQM001 LIKE ZQM001.

  LOOP AT T_TEMP.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = T_TEMP-EXIDV
      IMPORTING
        OUTPUT = T_TEMP-EXIDV.

    LOOP AT T_VEKP WHERE EXIDV EQ T_TEMP-EXIDV.
      CLEAR EXIDV.
      CLEAR WA_ZQM001.

      SELECT SINGLE *
        INTO WA_ZQM001
        FROM ZQM001
        WHERE EXIDV EQ T_VEKP-EXIDV  AND PSTAT IN ('P' , 'H').
      IF WA_ZQM001-EXIDV NE ''.
        IF WA_ZQM001-PSTAT EQ 'P'.
          T_VEKP-ZSTAT  = 'Pass'.
        ELSEIF WA_ZQM001-PSTAT EQ 'H'.
          T_VEKP-ZSTAT  = 'Hold'.
        ENDIF.
      ENDIF.
      MODIFY T_VEKP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " UPDATE_VEKPDATA

*&---------------------------------------------------------------------*
*&      Form  CEK_COMPLETENESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_COMPLETENESS .
*  hanya odo nya sudah complete aja yang tampil
  DATA :
         VBELN LIKE LIKP-VBELN,
         WA_VBUK LIKE VBUK,
         WA_LIKP LIKE LIKP.

  LOOP AT T_VEKP WHERE VBELN NE ''.
    CLEAR: VBELN, WA_VBUK, WA_LIKP.
    VBELN = T_VEKP-VBELN.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = VBELN
      IMPORTING
        OUTPUT = VBELN.

    SELECT SINGLE *
      INTO WA_VBUK
      FROM VBUK
      WHERE VBELN = VBELN.
    T_VEKP-STATODO = WA_VBUK-WBSTK.

    IF WA_VBUK-WBSTK EQ 'C'.
      SELECT SINGLE *
        INTO WA_LIKP
        FROM LIKP
        WHERE VBELN = VBELN AND LFART IN ('ZDLF', 'ZELF').
      IF WA_LIKP-VBELN NE ''.
        T_VEKP-LFART = WA_LIKP-LFART.
      ENDIF.
    ENDIF.
    MODIFY T_VEKP.
  ENDLOOP.
ENDFORM.                    " CEK_COMPLETENESS


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA : COUNT TYPE I.

  CLEAR : IT_LOG, T_TEMP, LN.
  REFRESH : IT_LOG, T_TEMP.


  DESCRIBE LIST NUMBER OF LINES LN.
  COUNT = 0.
  DO LN TIMES.
    CLEAR MARK01.
    CLEAR WA_VEKP-EXIDV.
    READ LINE SY-INDEX FIELD VALUE MARK01.
    READ LINE SY-INDEX FIELD VALUE WA_VEKP-EXIDV.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK01 = 'X'.
      T_TEMP-EXIDV = WA_VEKP-EXIDV.
      COLLECT T_TEMP.
      COUNT = COUNT + 1.
    ENDIF.
  ENDDO.

  IF COUNT = 0.
    MESSAGE I000(0K) WITH 'Select at least one line.'.
    EXIT.
  ENDIF.

  LOOP AT T_TEMP.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = T_TEMP-EXIDV
      IMPORTING
        OUTPUT = T_TEMP-EXIDV.

    MODIFY T_TEMP.
  ENDLOOP.


  SELECT *
    FROM ZQM001
    INTO CORRESPONDING FIELDS OF TABLE IT_LOG
    FOR ALL ENTRIES IN T_TEMP
    WHERE ZQM001~EXIDV = T_TEMP-EXIDV.

  PERFORM WRITE_DATA.

ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_DATA .
  IF IT_LOG[] IS INITIAL.
    MESSAGE I000(0K) WITH 'No Data Selected.'.
    EXIT.
  ENDIF.

  SET PF-STATUS ''.

  DATA: VL.
  VL = SY-VLINE.
*  WRITE : 'PT. TRIAS SENTOSA Tbk.'. "disable new company
  WRITE : / 'List of Changes Record', 80 'Page : ', (2) SY-PAGNO.
  SKIP.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE : / SY-ULINE(100).
  WRITE : / VL NO-GAP, 'HU Number '   NO-GAP,
            VL NO-GAP, 'NIK      '    NO-GAP,
            VL NO-GAP, 'Change Date ' NO-GAP,
            VL NO-GAP, 'Change Time ' NO-GAP,
            VL NO-GAP, 'Indicator  '   NO-GAP,
            VL NO-GAP, 'Remarks                                 '  NO-GAP,
            VL NO-GAP.
  WRITE : / SY-ULINE(100).
  FORMAT RESET INTENSIFIED ON.



  SORT IT_LOG ASCENDING BY EXIDV AEDAT AETIME.
  LOOP AT IT_LOG.
    AT NEW EXIDV.
      PERFORM SET_COLOR.
    ENDAT.

    WRITE : / VL NO-GAP, (10) IT_LOG-EXIDV NO-GAP,
              VL NO-GAP, (9)  IT_LOG-NIK NO-GAP,
              VL NO-GAP, (12) IT_LOG-AEDAT NO-GAP,
              VL NO-GAP, (12) IT_LOG-AETIME NO-GAP,
              VL NO-GAP, (5)  IT_LOG-PRNT NO-GAP,
              VL NO-GAP, (5)  IT_LOG-PSTAT NO-GAP,
              VL NO-GAP, (40) IT_LOG-NOTE NO-GAP,
              VL NO-GAP.
  ENDLOOP.
  WRITE : / SY-ULINE(100).

ENDFORM.                    " WRITE_DATA


*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED .
  CLEAR   : T_TEMP.
  REFRESH : T_TEMP.
  DESCRIBE LIST NUMBER OF LINES LN.

  COUNT = 0.
  DO LN TIMES.
    CLEAR   : T_TEMP.
    CLEAR MARK01.
    CLEAR WA_VEKP-EXIDV.
    CLEAR WA_VEKP-ZSTAT.
    READ LINE SY-INDEX FIELD VALUE MARK01.
    READ LINE SY-INDEX FIELD VALUE WA_VEKP-EXIDV.
    READ LINE SY-INDEX FIELD VALUE WA_VEKP-ZSTAT.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK01 = 'X'.
      T_TEMP-EXIDV = WA_VEKP-EXIDV.
      T_TEMP-ZSTAT = WA_VEKP-ZSTAT.
      COLLECT T_TEMP.
      COUNT = COUNT + 1.
    ENDIF.
  ENDDO.

ENDFORM.                    " GET_SELECTED


*&---------------------------------------------------------------------*
*&      Form  PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT .

  LOOP AT T_TEMP.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = T_TEMP-EXIDV
      IMPORTING
        OUTPUT = T_TEMP-EXIDV.

    REFRESH : TAB_LABEL.
    TAB_LABEL-LOW     = T_TEMP-EXIDV.
    TAB_LABEL-SIGN    = 'I'.
    TAB_LABEL-OPTION  = 'EQ'.
    APPEND TAB_LABEL.

    SUBMIT ZMMR_LABELQA WITH P_EXIDV IN TAB_LABEL AND RETURN.

    CLEAR : V_MAX, WA_ZQM001.
    SELECT MAX( SEQ )
      INTO V_MAX
      FROM ZQM001
      WHERE ZQM001~EXIDV = T_TEMP-EXIDV.

    SELECT *
      INTO WA_ZQM001
      FROM ZQM001
      WHERE ZQM001~SEQ = V_MAX.
    ENDSELECT.

    WA_ZQM001-PRNT = 'X'.

    UPDATE ZQM001 FROM WA_ZQM001.
    COMMIT WORK AND WAIT.

    LOOP AT T_VEKP WHERE EXIDV = T_TEMP-EXIDV.
      T_VEKP-PRNT = 'X'.
      MODIFY T_VEKP.
    ENDLOOP.

  ENDLOOP.

  IF R1 = 'X'.
    PERFORM DISPLAY_DATA USING ''.
  ELSE.
    PERFORM DISPLAY_DATA_NON USING ''.
  ENDIF.


ENDFORM.                    " PRINT


*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_AUTH_PLANT USING P_WERKS.
  RET_CODE = '4'.
  AUTHORITY-CHECK OBJECT 'ZQM1'
    ID 'WERKS' FIELD P_WERKS.

  RET_CODE = SY-SUBRC.

ENDFORM.                    " CHECK_AUTH_PLANT