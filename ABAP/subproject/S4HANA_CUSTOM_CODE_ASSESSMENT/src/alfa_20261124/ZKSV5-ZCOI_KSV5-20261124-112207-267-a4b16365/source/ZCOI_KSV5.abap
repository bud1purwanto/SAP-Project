*&---------------------------------------------------------------------*
*& Created by : Mualifi
*& Created on : 18-02-2013
*& Program    : ZCOI_KSU5
*& Desc.      : Run BDC KSU5 dan KSV5
*&--------------------------------------------------------------------- *
REPORT  ZCOI_KSV5.

TABLES: COSL.

DATA: BEGIN OF ITAB OCCURS 0,
      VCOAREA(8),   "add for new company
      RKSCYC LIKE RKAL1-RKSCYC,
      VALID_FROM(10),
      KOSTL TYPE N LENGTH 10,
      POBSR TYPE P DECIMALS 2,   " procent
      POBSRT(10), "TYPE P DECIMALS 2,   " procent
      SDATE LIKE T811C-SDATE,
END OF ITAB.

DATA: V_CYCLE LIKE RKAL1-RKSCYC,
      V_SDATE LIKE T811C-SDATE,
      V_EDATE LIKE T811C-EDATE,
      V_START_DATE(10),
      V_END_DATE(10).

DATA: BEGIN OF IT_CYCLE OCCURS 0,
      RKSCYC LIKE RKAL1-RKSCYC,
      SDATE LIKE T811C-SDATE,
      EDATE LIKE T811C-EDATE,
END OF IT_CYCLE.

DATA: V_KOSTL TYPE P DECIMALS 0,
      T_KOSTL(10).

DATA : FNAME TYPE STRING,
       FPATH TYPE IBIPPARMS-PATH.

DATA: S_OPTIONS TYPE CTU_PARAMS.
DATA: BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.

DATA: ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE,  "add for new company
      VLINE TYPE I,
      VMSG(50).

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_GJAHR LIKE COSL-GJAHR DEFAULT '2013'.
PARAMETERS: P_MONTH TYPE N LENGTH 2 DEFAULT '1'.
SELECTION-SCREEN END OF BLOCK BLK1.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: RB_KSU5 RADIOBUTTON GROUP GRB.
PARAMETERS: RB_KSV5 RADIOBUTTON GROUP GRB.
SELECTION-SCREEN END OF BLOCK BLK2.

START-OF-SELECTION.
  PERFORM F_UPLOAD.
  PERFORM CEK_KOSTL.
  PERFORM BUILD_CYCLE_LIST.
  PERFORM CEK_CYCLE.

  LOOP AT IT_CYCLE.
    V_CYCLE = IT_CYCLE-RKSCYC.
    V_SDATE = IT_CYCLE-SDATE.
    V_EDATE = IT_CYCLE-EDATE.
    CLEAR: V_START_DATE, V_END_DATE.
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = V_SDATE
      IMPORTING
        DATE_EXTERNAL = V_START_DATE.
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = V_EDATE
      IMPORTING
        DATE_EXTERNAL = V_END_DATE.
    PERFORM RESET_VALUE.
    PERFORM RUN_BDC.
  ENDLOOP.


*&---------------------------------------------------------------------*
*&      Form  f_upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_UPLOAD.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = FPATH.

  MOVE FPATH TO FNAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB.

** add new
  PERFORM CEK_TEMPLATE.
  IF VMSG IS NOT INITIAL.
    MESSAGE VMSG TYPE 'E'.
    EXIT.
  ENDIF.
** end add new

  LOOP AT ITAB.
    PERFORM CONVERT_VALID_FROM USING ITAB-VALID_FROM
                               CHANGING ITAB-SDATE.
    IF ITAB-POBSR = 0.
      ITAB-POBSRT = '00.01'.
    ELSE.
      ITAB-POBSRT = ITAB-POBSR.
      CONDENSE ITAB-POBSRT NO-GAPS.
    ENDIF.
    MODIFY ITAB.
  ENDLOOP.
ENDFORM.                    "f_upload

*&---------------------------------------------------------------------*
*&      Form  cek_kostl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_KOSTL.
  DATA: IT_NODE  LIKE SETNODE OCCURS 0 WITH HEADER LINE.
  DATA: IT_NODE1  LIKE SETNODE OCCURS 0 WITH HEADER LINE.
  DATA: IT_NODE2  LIKE SETNODE OCCURS 0 WITH HEADER LINE.
  DATA: IT_LEAF LIKE SETLEAF OCCURS 0  WITH HEADER LINE.

  REFRESH: IT_NODE, IT_NODE1, IT_NODE2.
  SELECT * INTO TABLE IT_NODE1 FROM SETNODE WHERE SUBCLASS = ITAB-VCOAREA AND SETNAME = 'TSPLIT'. "add for new company
  IF SY-SUBRC NE 0.
    MESSAGE 'Cost center group TSPLIT tidak ditemukan' TYPE 'E'.
  ENDIF.

  LOOP AT IT_NODE1.
    IT_NODE-SETNAME = IT_NODE1-SUBSETNAME.
    APPEND IT_NODE.
  ENDLOOP.

  IT_NODE2[] = IT_NODE1[].
  REFRESH: IT_NODE1.

  DO 5 TIMES.
    REFRESH IT_NODE1.
    SELECT * INTO TABLE IT_NODE1 FROM SETNODE FOR ALL ENTRIES IN IT_NODE2
      WHERE SETNAME = IT_NODE2-SUBSETNAME.

    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    REFRESH IT_NODE2.
    LOOP AT IT_NODE1.
      IT_NODE-SETNAME = IT_NODE1-SUBSETNAME.
      APPEND IT_NODE.
    ENDLOOP.
    IT_NODE2[] = IT_NODE1[].

  ENDDO.

*-- get result
  SELECT * INTO TABLE IT_LEAF FROM SETLEAF
    FOR ALL ENTRIES IN IT_NODE WHERE SETNAME = IT_NODE-SETNAME.

  LOOP AT ITAB.
    READ TABLE IT_LEAF WITH KEY VALFROM = ITAB-KOSTL.
    IF SY-SUBRC NE 0.
      DELETE ITAB WHERE KOSTL = ITAB-KOSTL.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "cek_kostl



*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD



*&---------------------------------------------------------------------*
*&      Form  run_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM RUN_BDC.
  REFRESH: BDCDATA.
  CLEAR: BDCDATA.

  PERFORM BDC_DYNPRO      USING 'SAPMKGA2' '0101'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '/ECHA'.
  PERFORM BDC_FIELD       USING 'RKGA2U-TEST' ' '.

  PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0103'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '=ENA'.
  PERFORM BDC_FIELD       USING 'RKAL1-KSCYC'                             V_CYCLE. "'ZT0005'.
*  PERFORM BDC_FIELD       USING 'T811C-SDATE'                             V_START_DATE.

  DATA: V_FIRST TYPE C.

  CLEAR V_FIRST.
  LOOP AT ITAB WHERE RKSCYC = V_CYCLE
                 AND SDATE = V_SDATE.
    IF V_FIRST IS INITIAL.
      V_FIRST = 'X'.
      PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0201'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=BIGS'.
*      PERFORM BDC_FIELD       USING 'T811C-EDATE'           '01.12.2099'.
      PERFORM BDC_FIELD       USING 'T811C-EDATE'           V_END_DATE.
    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPMKAL1'                '0300'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=BIGS'.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPMKAL1'              '0333'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'            'RSTXP_TDFIND(02)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=GOON'.
    V_KOSTL = ITAB-KOSTL.
    T_KOSTL = V_KOSTL.
    PERFORM BDC_FIELD       USING 'RSTXP_TDFIND(02)'      T_KOSTL.
    PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0334'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'            'KGALS-NAME(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=PICK'.

    PERFORM BDC_DYNPRO      USING 'SAPMKAL1'              '0300'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=SAVE'.
    IF ITAB-POBSRT = 0.
      PERFORM BDC_FIELD       USING 'KGALS-ACTIVE'            'X'.
    ENDIF.
    PERFORM BDC_FIELD       USING 'KGALS-SPERCENT'        ITAB-POBSRT.
  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0300'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                                '/EEND'.

  PERFORM BDC_DYNPRO      USING 'SAPMKGA2' '0101'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                                '/EF15'.

  S_OPTIONS-DISMODE = 'E'.
  S_OPTIONS-NOBINPT = 'X'.

  IF RB_KSU5 = 'X'.
    CALL TRANSACTION 'KSU5' USING BDCDATA OPTIONS FROM S_OPTIONS.
  ELSE.
    CALL TRANSACTION 'KSV5' USING BDCDATA OPTIONS FROM S_OPTIONS.
  ENDIF.
ENDFORM.                    "run_bdc2




*&---------------------------------------------------------------------*
*&      Form  uncheck_active
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM RESET_VALUE.
  REFRESH: BDCDATA.
  CLEAR: BDCDATA.
  PERFORM BDC_DYNPRO      USING 'SAPMKGA2' '0101'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '/ECHA'.
  PERFORM BDC_FIELD       USING 'RKGA2U-TEST' ' '.

  PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0103'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '=ENA'.
  PERFORM BDC_FIELD       USING 'RKAL1-KSCYC'                             V_CYCLE. "'ZT0005'.
*  PERFORM BDC_FIELD       USING 'T811C-SDATE'                             V_START_DATE.

  DATA: V_FIRST TYPE C.

  CLEAR V_FIRST.
  LOOP AT ITAB WHERE RKSCYC = V_CYCLE
                 AND SDATE = V_SDATE.
    IF V_FIRST IS INITIAL.
      V_FIRST = 'X'.
      PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0201'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=BIGS'.
*      PERFORM BDC_FIELD       USING 'T811C-EDATE'           '01.12.2099'.
      PERFORM BDC_FIELD       USING 'T811C-EDATE'           V_END_DATE.
    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPMKAL1'                '0300'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=BIGS'.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPMKAL1'              '0333'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'            'RSTXP_TDFIND(02)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=GOON'.
    V_KOSTL = ITAB-KOSTL.
    T_KOSTL = V_KOSTL.
    PERFORM BDC_FIELD       USING 'RSTXP_TDFIND(02)'      T_KOSTL.
    PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0334'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'            'KGALS-NAME(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=PICK'.

    PERFORM BDC_DYNPRO      USING 'SAPMKAL1'              '0300'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'            '=SAVE'.
    PERFORM BDC_FIELD       USING 'KGALS-ACTIVE'            ' '.
    PERFORM BDC_FIELD       USING 'KGALS-SPERCENT'        '0.01'. "ITAB-POBSRT'.

  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPMKAL1' '0300'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                                '/EEND'.

  PERFORM BDC_DYNPRO      USING 'SAPMKGA2' '0101'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'                                '/EF15'.

  S_OPTIONS-DISMODE = 'E'.
  S_OPTIONS-NOBINPT = 'X'.

  IF RB_KSU5 = 'X'.
    CALL TRANSACTION 'KSU5' USING BDCDATA OPTIONS FROM S_OPTIONS.
  ELSE.
    CALL TRANSACTION 'KSV5' USING BDCDATA OPTIONS FROM S_OPTIONS.
  ENDIF.
ENDFORM.                    "uncheck_active

*&---------------------------------------------------------------------*
*&      Form  cek_template
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_TEMPLATE.
  CLEAR: ITAB2, VMSG.
  REFRESH: ITAB2.

  ITAB2[] = ITAB[].
  DELETE ADJACENT DUPLICATES FROM ITAB2 COMPARING VCOAREA.
  DESCRIBE TABLE ITAB2 LINES VLINE.

  IF VLINE > 1.
    VMSG = 'CEK TEMPLATE FIELD CO AREA' .
    EXIT.
  ENDIF.
ENDFORM.                    "cek_template

*&---------------------------------------------------------------------*
*&      Form  BUILD_CYCLE_LIST
*&---------------------------------------------------------------------*
*& Build unique target cycles supplied in the upload template.
*&---------------------------------------------------------------------*
FORM BUILD_CYCLE_LIST.
  CLEAR IT_CYCLE.
  REFRESH IT_CYCLE.

  LOOP AT ITAB.
    READ TABLE IT_CYCLE WITH KEY RKSCYC = ITAB-RKSCYC
                                 SDATE = ITAB-SDATE
      TRANSPORTING NO FIELDS.
    IF SY-SUBRC <> 0.
      IT_CYCLE-RKSCYC = ITAB-RKSCYC.
      IT_CYCLE-SDATE = ITAB-SDATE.
      APPEND IT_CYCLE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "BUILD_CYCLE_LIST

*&---------------------------------------------------------------------*
*&      Form  CEK_CYCLE
*&---------------------------------------------------------------------*
*& Validate cycles in the upload template against T811C.
*&---------------------------------------------------------------------*
FORM CEK_CYCLE.
  DATA: V_CYCLE_CHECK LIKE RKAL1-RKSCYC,
        V_FULL_CYCLE(18).

  LOOP AT IT_CYCLE.
    CLEAR: V_CYCLE_CHECK, V_FULL_CYCLE.
    CONCATENATE ITAB-VCOAREA IT_CYCLE-RKSCYC INTO V_FULL_CYCLE.
    SELECT SINGLE CYCLE EDATE INTO (V_CYCLE_CHECK, IT_CYCLE-EDATE)
      FROM T811C
      WHERE TAB   = 'CCSS'
        AND CYCLE = V_FULL_CYCLE
        AND SDATE = IT_CYCLE-SDATE.
    IF SY-SUBRC <> 0.
      CONCATENATE 'Cycle/Valid From tidak ditemukan:' IT_CYCLE-RKSCYC
        INTO VMSG SEPARATED BY SPACE.
      MESSAGE VMSG TYPE 'E'.
    ENDIF.
    MODIFY IT_CYCLE.
  ENDLOOP.
ENDFORM.                    "CEK_CYCLE

*&---------------------------------------------------------------------*
*& Convert template Valid From from DD.MM.YYYY to SAP internal DATS.
*& USING I_DATE is the uploaded text; CHANGING C_DATE is YYYYMMDD.
*&---------------------------------------------------------------------*
FORM CONVERT_VALID_FROM USING I_DATE CHANGING C_DATE.
  DATA: V_DATE(8).

  IF I_DATE+2(1) <> '.' OR I_DATE+5(1) <> '.'.
    MESSAGE 'Valid From harus berformat DD.MM.YYYY' TYPE 'E'.
  ENDIF.

  CONCATENATE I_DATE+6(4) I_DATE+3(2) I_DATE(2)
    INTO V_DATE.
  C_DATE = V_DATE.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      DATE                      = C_DATE
    EXCEPTIONS
      PLAUSIBILITY_CHECK_FAILED = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE 'Valid From bukan tanggal kalender yang valid' TYPE 'E'.
  ENDIF.
ENDFORM.                    "CONVERT_VALID_FROM