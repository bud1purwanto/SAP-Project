*&---------------------------------------------------------------------*
*&  Report     :  ZQMR_BARRIER_SR_POSITION                             *
*&  Appl. Area :  QM                                                   *
*&  Created by :  J. Budi                                              *
*&  Created on :  9 September 2025                                     *
*&---------------------------------------------------------------------*

REPORT  ZQMI_BARRIER_SR_POSITION.

TYPES: BEGIN OF T_UPLOAD,
       SAMPLE_DATE    TYPE SY-DATUM,
       MATNR          TYPE MATNR,           "Material No
       WERKS          TYPE WERKS_D,         "Plant
       LGORT          TYPE LGORT_D,         "Storage Location
       CHARG          TYPE CHARG_D,         "Batch
       LGPLA          TYPE LGPLA,           "Storage Bin
       TYPE           TYPE ATWRT,           "Type (custom)
       THICKNESS      TYPE I,               "Thick
       WIDTH          TYPE I,               "Width
       LENGTH         TYPE I,               "Length
       MBLNR          TYPE MBLNR,           "Matdoc SR Number
       SMBLN          TYPE MBLNR,           "Matdoc SR Number Cancel
       MJAHR          TYPE MJAHR,           "Matdoc SR Year
       SJAHR          TYPE MJAHR,           "Matdoc SR Year Cancel
       ZEILE          TYPE MBLPO,           "Matdoc SR Item
       SMBLP          TYPE MBLPO,           "Matdoc SR Item Cancel
       BWART          TYPE BWART,           "Movement Type
       DERIVATIVE     TYPE CHAR20,          "Derivitive
       ROLL           TYPE CHAR30,          "No Roll
       POSITION       TYPE CHAR10,          "Position
       01             TYPE I,
       02             TYPE I,
       03             TYPE I,
       04             TYPE I,
       CH1_START      TYPE I,
       CH1_END        TYPE I,
       CH2_START      TYPE I,
       CH2_END        TYPE I,
       CH3_START      TYPE I,
       CH3_END        TYPE I,
       CH4_START      TYPE I,
       CH4_END        TYPE I,
       CH1_POINT      TYPE CHAR10,
       CH2_POINT      TYPE CHAR10,
       CH3_POINT      TYPE CHAR10,
       CH4_POINT      TYPE CHAR10,
       DERIVATIVE2    TYPE CHAR20,          "Derivitive
       QTY            TYPE LABST,           "Quantity
       MATNR_JR       TYPE MATNR,           "Material
       CHARG_JR       TYPE CHARG_D,         "Batch
       ROLL_JR        TYPE ATWRT,           "Rol
       ROLL_JR2       TYPE ATWRT,           "Rol
       WIDTH_JR       TYPE I,               "Width
       TYPE_JR        TYPE ATWRT,           "Type
       ABLAD          TYPE ABLAD,           "MS/SS
       "ALV
       LINE_COLOR     TYPE C LENGTH 4,      "Color
       BOX,                                 "Choice
       ERR,                                 "Error Mark
       ZSTAT          TYPE C LENGTH 4,      "Indicator
       MESS           TYPE C LENGTH 150,    "Message
       END OF T_UPLOAD.

"For Display
TYPES: BEGIN OF T_TAB.
        INCLUDE TYPE T_UPLOAD.
TYPES: CELL_COLOR     TYPE LVC_T_SCOL.
TYPES: END OF T_TAB.

"For Recording
DATA: BEGIN OF IT_QASE OCCURS 0,
       PRUEFLOS       LIKE QASE-PRUEFLOS,        "Inspection Lot
       MERKNR         LIKE QASE-MERKNR,          "Char
       VERWMERKM      LIKE QAMV-VERWMERKM,       "MVTR MIC
       MKVERSION      TYPE QVERSNRMK,            "OTR VERSION
       PROBENR        LIKE QASE-PROBENR,         "Sample/Point
       STUECKNR       LIKE QASE-STUECKNR,        "Cycle
       MESSWERT       TYPE QASE-MESSWERT,        "Measured value
       MBEWERTG       LIKE QASE-MBEWERTG,        "Valuation
       ATTRIBUT       LIKE QASE-ATTRIBUT,        "Deletion Flag
       BUDAT          LIKE QASE-PRUEFDATUV,      "Date
       PRUEFBEMKT     LIKE QASE-PRUEFBEMKT,      "Text
       PRUEFER        LIKE QASE-PRUEFER,         "NIK
       END OF IT_QASE.

DATA: ITAB            TYPE STANDARD TABLE OF T_TAB   WITH HEADER LINE,
      IT_MAIN         LIKE ITAB OCCURS 0 WITH HEADER LINE,
      IT_JR           LIKE ITAB OCCURS 0 WITH HEADER LINE,
      IT_JR_CANC      LIKE ITAB OCCURS 0 WITH HEADER LINE.

"Formula RCL
DATA: BEGIN OF IT_MATNR OCCURS 0,
       MATNR          TYPE MATNR,
       WERKS          TYPE WERKS_D,
       MATKL          TYPE MATKL,
      END OF IT_MATNR.

"Variable
DATA: V_ATINN         TYPE ATINN,
      V_DATE          TYPE SY-DATUM,
      V_TFILL         TYPE I,
      V_WIDTH         TYPE I,
      V_BARRIER_POS   TYPE CHAR3,          "Barrier Position
      V_DERIVATIVE    TYPE CHAR10,
      V_POSITION      TYPE CHAR10,
      V_COUNT         TYPE I,
      V_TRIM          TYPE I,
      V_FIRST,
      V_PROC_EX       TYPE I VALUE 2,
      V_LINE(5),
      V_CODE(5),
      V_MOYE(5),
      V_SEQ(5),
      V_GRADE(5),
      V_DMS(5),
      V_DSS(5),
      V_PMS(5),
      V_PSS(5).

"Short Text Batch
DATA: V_NAME          LIKE THEAD-TDNAME,
      THEAD           LIKE THEAD,
      TLINE           LIKE TLINE OCCURS 0 WITH HEADER LINE.

"Other Internal Table
DATA: WA_CELL_COLOR   TYPE LVC_S_SCOL,
      CELL_COLOUR     LIKE WA_CELL_COLOR-COLOR-COL,
      L_REF_GRID      TYPE REF TO CL_GUI_ALV_GRID.

CONSTANTS:
      ERROR(4)        TYPE C VALUE '@0A@',       "Error
      SUCCES(4)       TYPE C VALUE '@08@',       "Success
      WARNING(4)      TYPE C VALUE '@09@',       "Warning
      GREY(4)         TYPE C VALUE '@EB@'.       "Grey

FIELD-SYMBOLS :
      <FS_VALUE>      TYPE ANY,
      <FS_DETAIL>     LIKE LINE OF ITAB.

"ALV
DATA: OK_CODE         LIKE SY-UCOMM,
      SAVE_OK         LIKE SY-UCOMM,
      DIALOG_BOX      TYPE REF TO CL_GUI_DIALOGBOX_CONTAINER,
      GRID1           TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYOUT       TYPE LVC_S_LAYO,
      G_MAX           TYPE I VALUE 10,
      GT_FIELDCAT     TYPE LVC_T_FCAT,
      GS_VARIANT      TYPE DISVARIANT,
      LT_ROW_NO       TYPE LVC_T_ROID WITH HEADER LINE.

DATA: IT_SR_DATA      LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE,
      IT_SR_DATA2     LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE,
      IT_SR_DATA3     LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE,
      IT_SR_DATA4     LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE,
      IT_SR_DATA5     LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_CHAR OCCURS 0,
      CHARG          TYPE CHARG_D,
      ATINN          TYPE ATINN,
      ATWRT          TYPE ATWRT,
      ATFLV          TYPE ATFLV,
      ATWTB          TYPE ATWTB,
      END OF IT_CHAR.

DATA: IT_CHAR_SR LIKE IT_CHAR OCCURS 0 WITH HEADER LINE.

DATA: V_ZZTYPE             TYPE ATINN,
      V_ZZWIDTH            TYPE ATINN,
      V_ZZNOMORROLL        TYPE ATINN,
      V_ZZDERIVATIVESS     TYPE ATINN,
      V_ZZDERIVATIVEMS     TYPE ATINN,
      V_ZZPOSITIONSS       TYPE ATINN,
      V_ZZPOSITIONMS       TYPE ATINN.

DATA: IT_CUT_OVER     LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE,
      IT_CABN         LIKE CABN OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_AUSP OCCURS 0,
       ATWRT           TYPE ATWRT,
       OBJEK           TYPE OBJNUM,
       CUOBJ           TYPE CUOBJ_BM,
      END OF IT_AUSP.

DATA : BEGIN OF IT_MBLNR OCCURS 0,
            MBLNR TYPE MSEG-MBLNR,
            CHARG TYPE MCH1-CHARG,
            MATNR TYPE MCH1-MATNR,
            MJAHR TYPE MSEG-MJAHR,
            ZEILE TYPE MSEG-ZEILE,
            BWART TYPE MSEG-BWART,
            SMBLN TYPE MSEG-SMBLN,
            SJAHR TYPE MSEG-SJAHR,
            SMBLP TYPE MSEG-SMBLP,
            AUFNR TYPE MSEG-AUFNR,
            CPUDT_MKPF TYPE MSEG-CPUDT_MKPF,
        END OF IT_MBLNR.

TABLES: MKPF, MSEG, AUSP, MARA.

RANGES: R_STATUS      FOR VBAP-VBELN,
        R_CHARG       FOR MSEG-CHARG.

INCLUDE ZABAPALV.

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BUDAT FOR MKPF-BUDAT    MODIF ID B1.
SELECT-OPTIONS: S_WERKS FOR MSEG-WERKS    MODIF ID B1 NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS: S_NOROL FOR AUSP-ATWRT    MODIF ID B1.
SELECT-OPTIONS: S_FTYPE FOR AUSP-ATWRT    MODIF ID B1.
SELECT-OPTIONS: S_CHARG FOR MSEG-CHARG    MODIF ID B1.
SELECTION-SCREEN END OF BLOCK BLK1.

START-OF-SELECTION.
  PERFORM VALIDATION.
  PERFORM GET_DATA.
  PERFORM DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDATION.
  IF S_BUDAT[] IS INITIAL.
    MESSAGE 'Please fill the parameters!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF S_WERKS[] IS INITIAL.
    MESSAGE 'Please fill plant!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_CUT_OVER
      FROM ZMAP_TYPE
     WHERE TCODE    EQ SY-TCODE
       AND TYPE     EQ 'BARRIER'
       AND OPT      EQ 'CUT OVER'
       AND DELETION EQ ''.

  IF IT_CUT_OVER[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_CUT_OVER
      FROM ZMAP_TYPE
     WHERE PROG     EQ SY-CPROG
       AND TYPE     EQ 'BARRIER'
       AND OPT      EQ 'CUT OVER'
       AND DELETION EQ ''.
  ENDIF.

  IF IT_CUT_OVER[] IS NOT INITIAL.
    READ TABLE IT_CUT_OVER INDEX 1.
    IF SY-SUBRC EQ 0.
      LOOP AT S_BUDAT.
        PERFORM CONVERT_DATE_INPUT USING IT_CUT_OVER-VALUE CHANGING IT_CUT_OVER-VALUE.
        IF S_BUDAT-LOW LT IT_CUT_OVER-VALUE.
          MESSAGE IT_CUT_OVER-TEXT5 TYPE 'S' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    "VALIDATION

*&---------------------------------------------------------------------*
*&      Form  SET_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PARAM.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_CABN FROM CABN WHERE ATNAM LIKE 'ZZ%'.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZTYPE'.
  IF SY-SUBRC EQ 0.
    V_ZZTYPE = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZWIDTH'.
  IF SY-SUBRC EQ 0.
    V_ZZWIDTH = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZNOMORROLL'.
  IF SY-SUBRC EQ 0.
    V_ZZNOMORROLL = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZDERIVATIVESS'.
  IF SY-SUBRC EQ 0.
    V_ZZDERIVATIVESS = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZDERIVATIVEMS'.
  IF SY-SUBRC EQ 0.
    V_ZZDERIVATIVEMS = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZPOSITIONSS'.
  IF SY-SUBRC EQ 0.
    V_ZZPOSITIONSS = IT_CABN-ATINN.
  ENDIF.

  READ TABLE IT_CABN WITH KEY ATNAM = 'ZZPOSITIONMS'.
  IF SY-SUBRC EQ 0.
    V_ZZPOSITIONMS = IT_CABN-ATINN.
  ENDIF.
ENDFORM.                    "SET_PARAM

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  REFRESH: ITAB, IT_MATNR, IT_CHAR, IT_AUSP.
  CLEAR: ITAB, IT_MATNR, IT_CHAR, IT_AUSP.

  PERFORM SET_PARAM.

  IF S_CHARG[] IS NOT INITIAL.
    R_CHARG[] = S_CHARG[].
  ENDIF.

  IF S_NOROL[] IS NOT INITIAL.
    SELECT ATWRT OBJEK INTO CORRESPONDING FIELDS OF TABLE IT_AUSP
      FROM AUSP
     WHERE AUSP~ATWRT IN S_NOROL
        AND AUSP~KLART EQ '023'
        AND AUSP~MAFID EQ 'O'
        AND AUSP~ATINN EQ V_ZZNOMORROLL %_HINTS ORACLE 'INDEX("AUSP" "AUSP~N1")'.

    IF IT_AUSP[] IS NOT INITIAL.
      LOOP AT IT_AUSP.
        IT_AUSP-CUOBJ = IT_AUSP-OBJEK.
        MODIFY IT_AUSP.
        CLEAR IT_AUSP.
      ENDLOOP.

      SELECT CHARG AS LOW APPENDING CORRESPONDING FIELDS OF TABLE R_CHARG
        FROM MCH1
         FOR ALL ENTRIES IN IT_AUSP
       WHERE CUOBJ_BM EQ IT_AUSP-CUOBJ
         AND FVDT1    EQ '00000000'
         AND CHARG    IN R_CHARG %_HINTS  ORACLE 'INDEX("MCH1" "MCH1~Z06")'.
    ELSE.
      SY-SUBRC = 4.
    ENDIF.

    IF SY-SUBRC EQ 0.
      R_CHARG-SIGN   = 'I'.
      R_CHARG-OPTION = 'EQ'.
      MODIFY R_CHARG TRANSPORTING SIGN OPTION WHERE SIGN IS INITIAL.
    ELSE.
      CLEAR: R_CHARG.
      REFRESH: R_CHARG.
      R_CHARG-LOW     = 'XXXXXXXXXX'.
      R_CHARG-SIGN   = 'I'.
      R_CHARG-OPTION = 'EQ'.
      APPEND R_CHARG.
    ENDIF.
  ENDIF.

  SELECT MARA~MATNR WERKS MATKL INTO CORRESPONDING FIELDS OF TABLE IT_MATNR
    FROM MARA
    JOIN MARC ON MARC~MATNR EQ MARA~MATNR
   WHERE MARC~WERKS IN S_WERKS
     AND MARA~MATKL LIKE '3%'.

  SORT IT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM IT_MATNR COMPARING MATNR.

  IF IT_MATNR[] IS INITIAL.
    MESSAGE 'Data not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM SET_INDICATOR USING 1 1 1 V_PROC_EX 'Getting Slit Roll Data...'.

  "Get Preview
  SELECT
    MSEG~MATNR
    MSEG~WERKS
    MSEG~LGORT
    MSEG~CHARG
    MSEG~MBLNR
    MSEG~SMBLN
    MSEG~MJAHR
    MSEG~SJAHR
    MSEG~ZEILE
    MSEG~SMBLP
    MSEG~BWART
    MSEG~WERKS
    MSEG~MENGE AS QTY
    AUSP~ATWRT AS DERIVITIVE
    AUFM~MATNR AS MATNR_JR
    AUFM~CHARG AS CHARG_JR
    MKPF~BUDAT AS SAMPLE_DATE
    INTO CORRESPONDING FIELDS OF TABLE IT_MAIN
    FROM MKPF
    JOIN MSEG ON MSEG~MBLNR EQ MKPF~MBLNR AND MSEG~MJAHR EQ MKPF~MJAHR
    JOIN MCH1 ON MCH1~CHARG EQ MSEG~CHARG
    JOIN AUSP ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
    JOIN CABN ON CABN~ATINN EQ AUSP~ATINN
    JOIN AFPO ON MSEG~AUFNR EQ AFPO~MILL_OC_AUFNR_U
    JOIN AUFM ON AFPO~AUFNR EQ AUFM~AUFNR
    FOR ALL ENTRIES IN IT_MATNR
   WHERE MKPF~BUDAT IN S_BUDAT
     AND MSEG~WERKS EQ IT_MATNR-WERKS
     AND MSEG~MATNR EQ IT_MATNR-MATNR
     AND AUFM~CHARG IN R_CHARG
     AND MSEG~BWART IN (101, 102)
     AND MSEG~AUFNR NE ''
     AND AUFM~MATNR LIKE 'JR%'
     AND ( CABN~ATNAM EQ 'ZZDERIVATIVEMS') %_HINTS  ORACLE 'INDEX("MKPF" "MKPF~BUD")'
                                                    ORACLE 'INDEX("MESG" "MSEG~BOM")'
                                                    ORACLE 'INDEX("AUFM" "AUFM~Z01")'.
  "AND AUSP~ATWRT EQ '01' ).

  SORT IT_MAIN BY CHARG_JR.
  DELETE ADJACENT DUPLICATES FROM IT_MAIN COMPARING CHARG_JR.

  IF IT_MAIN[] IS INITIAL.
    MESSAGE 'Data not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "Get Preview
  SELECT
    MSEG~MATNR
    MSEG~WERKS
    MSEG~LGORT
    MSEG~CHARG
    MSEG~MBLNR
    MSEG~SMBLN
    MSEG~MJAHR
    MSEG~SJAHR
    MSEG~ZEILE
    MSEG~SMBLP
    MSEG~BWART
    INTO CORRESPONDING FIELDS OF TABLE IT_JR
    FROM MSEG
    FOR ALL ENTRIES IN IT_MAIN
   WHERE MSEG~WERKS EQ IT_MAIN-WERKS
     AND MSEG~MATNR EQ IT_MAIN-MATNR_JR
     AND MSEG~CHARG EQ IT_MAIN-CHARG_JR
     AND MSEG~BWART IN (101, 102) %_HINTS ORACLE 'INDEX("MESG" "MSEG~Z07")'.

  IT_JR_CANC[] = IT_JR[].
  "Delete Cancel
  DELETE IT_JR_CANC WHERE SMBLN IS INITIAL.
  LOOP AT IT_JR_CANC.
    DELETE IT_JR WHERE MBLNR EQ IT_JR_CANC-SMBLN AND MJAHR EQ IT_JR_CANC-SJAHR AND ZEILE EQ IT_JR_CANC-SMBLP.
  ENDLOOP.
  DELETE IT_JR WHERE SMBLN IS NOT INITIAL OR BWART EQ 102.

  LOOP AT IT_MAIN.
    READ TABLE IT_JR WITH KEY CHARG = IT_MAIN-CHARG_JR.
    IF SY-SUBRC NE 0.
      DELETE IT_MAIN.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  IF IT_MAIN[] IS INITIAL.
    MESSAGE 'Data not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  DESCRIBE TABLE IT_MAIN LINES V_TFILL.

  SELECT CHARG AUSP~ATINN AUSP~ATWRT AUSP~ATFLV
     INTO CORRESPONDING FIELDS OF TABLE IT_CHAR
     FROM MCH1
     JOIN AUSP  ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
    FOR ALL ENTRIES IN IT_MAIN
    WHERE MATNR EQ IT_MAIN-MATNR_JR
      AND CHARG EQ IT_MAIN-CHARG_JR
      AND KLART EQ '023'
      AND AUSP~ATINN IN (V_ZZTYPE, V_ZZWIDTH, V_ZZNOMORROLL).

  CLEAR : IT_MBLNR.
  REFRESH : IT_MBLNR.

  IF IT_MAIN[] IS NOT INITIAL.
    "Subcont Condition. Added by Fany(01.10.2026)
    SELECT AUFNR MSEG~MBLNR MSEG~MJAHR ZEILE CPUDT_MKPF CPUTM_MKPF SMBLN SJAHR SMBLP BWART LIFNR MATNR CHARG MENGE BUDAT_MKPF BKTXT
            INTO CORRESPONDING FIELDS OF TABLE IT_MBLNR
          FROM MSEG
          JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
       FOR ALL ENTRIES IN IT_MAIN
          WHERE BWART IN ('543','541')
          AND MATNR EQ IT_MAIN-MATNR
          AND CHARG EQ IT_MAIN-CHARG %_HINTS  ORACLE 'INDEX("MSEG" "MSEG~Z07")'.

    SORT IT_MBLNR BY MATNR CHARG.
    DELETE ADJACENT DUPLICATES FROM IT_MBLNR COMPARING MATNR CHARG.

    IF IT_MBLNR[] IS NOT INITIAL.
        LOOP AT IT_MAIN.
          READ TABLE IT_MBLNR WITH KEY CHARG = IT_MAIN-CHARG.
          IF SY-SUBRC EQ 0.
            DELETE IT_MAIN.
          ENDIF.
        ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT IT_MAIN.
    CLEAR: IT_SR_DATA, IT_SR_DATA2, IT_SR_DATA3, IT_SR_DATA4, IT_SR_DATA5, V_TRIM, V_FIRST, IT_CHAR_SR.
    REFRESH: IT_SR_DATA, IT_SR_DATA2, IT_SR_DATA3, IT_SR_DATA4, IT_SR_DATA5, IT_CHAR_SR.

    PERFORM SET_INDICATOR USING SY-TABIX V_TFILL 2 V_PROC_EX 'Calculating Slit Roll Data...'.

    READ TABLE IT_CHAR WITH KEY CHARG = IT_MAIN-CHARG_JR ATINN = V_ZZTYPE.
    IF SY-SUBRC EQ 0.
      IT_MAIN-TYPE_JR = IT_CHAR-ATWRT.
    ENDIF.

    IF IT_MAIN-TYPE_JR NOT IN S_FTYPE.
      DELETE IT_MAIN.
      CONTINUE.
    ENDIF.

    READ TABLE IT_CHAR WITH KEY CHARG = IT_MAIN-CHARG_JR ATINN = V_ZZNOMORROLL.
    IF SY-SUBRC EQ 0.
      IT_MAIN-ROLL_JR = IT_CHAR-ATWRT.
    ENDIF.

    READ TABLE IT_CHAR WITH KEY CHARG = IT_MAIN-CHARG_JR ATINN = V_ZZWIDTH.
    IF SY-SUBRC EQ 0.
      IT_MAIN-WIDTH_JR = IT_CHAR-ATFLV.
    ENDIF.

    CALL FUNCTION 'ZQM_GET_BATCH_SR_BY_JR'
      EXPORTING
        CHARGJR = IT_MAIN-CHARG_JR
        SCRAP   = 'X'
      TABLES
        T_SR    = IT_SR_DATA
        T_CABN  = IT_CABN.

    SORT IT_SR_DATA BY DERIVATIVE POSITION DERIVATIVE_SS POSITION_SS ASCENDING.
    DELETE ADJACENT DUPLICATES FROM IT_SR_DATA COMPARING CHARG.

    IT_SR_DATA2[] = IT_SR_DATA[].
    "For Secondary
    IT_SR_DATA3[] = IT_SR_DATA[].
    IT_SR_DATA4[] = IT_SR_DATA[].
    IT_SR_DATA5[] = IT_SR_DATA[].

    SORT IT_SR_DATA BY DERIVATIVE.
    DELETE ADJACENT DUPLICATES FROM IT_SR_DATA COMPARING DERIVATIVE.

    "Get Secondary
    DELETE IT_SR_DATA4 WHERE DERIVATIVE_SS IS INITIAL.
    SORT IT_SR_DATA4 BY DERIVATIVE POSITION DERIVATIVE_SS.
    DELETE ADJACENT DUPLICATES FROM IT_SR_DATA4 COMPARING DERIVATIVE POSITION DERIVATIVE_SS.

    APPEND LINES OF IT_SR_DATA4 TO IT_SR_DATA.

    IF IT_SR_DATA2[] IS NOT INITIAL.
      SELECT CHARG AUSP~ATINN AUSP~ATWRT AUSP~ATFLV
        INTO CORRESPONDING FIELDS OF TABLE IT_CHAR_SR
        FROM MCH1
        JOIN AUSP  ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
       FOR ALL ENTRIES IN IT_SR_DATA2
       WHERE MATNR EQ IT_SR_DATA2-MATNR
         AND CHARG EQ IT_SR_DATA2-CHARG
         AND KLART EQ '023'
         AND AUSP~ATINN IN (V_ZZWIDTH, V_ZZNOMORROLL, V_ZZDERIVATIVESS, V_ZZDERIVATIVEMS, V_ZZPOSITIONSS, V_ZZPOSITIONMS).

    ENDIF.

    LOOP AT IT_SR_DATA.
      CLEAR: V_COUNT.

      MOVE-CORRESPONDING IT_MAIN TO ITAB.

      ITAB-MATNR = IT_SR_DATA-MATNR.
      ITAB-CHARG = IT_SR_DATA-CHARG.
      ITAB-ABLAD = IT_SR_DATA-ABLAD.

      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = ITAB-MATNR
          CHARG = ITAB-CHARG
        IMPORTING
          PDATE = ITAB-SAMPLE_DATE.

      READ TABLE IT_CHAR_SR WITH KEY CHARG = ITAB-CHARG ATINN = V_ZZNOMORROLL.
      IF SY-SUBRC EQ 0.
        ITAB-ROLL = IT_CHAR_SR-ATWRT.
      ENDIF.

      READ TABLE IT_CHAR_SR WITH KEY CHARG = ITAB-CHARG ATINN = V_ZZDERIVATIVEMS.
      IF SY-SUBRC EQ 0.
        ITAB-DERIVATIVE = IT_CHAR_SR-ATWRT.
      ENDIF.

      READ TABLE IT_CHAR_SR WITH KEY CHARG = ITAB-CHARG ATINN = V_ZZPOSITIONMS.
      IF SY-SUBRC EQ 0.
        V_POSITION = IT_CHAR_SR-ATWRT.
      ENDIF.

      ITAB-ROLL_JR2 = ITAB-ROLL_JR.

      LOOP AT IT_SR_DATA2 WHERE DERIVATIVE EQ IT_SR_DATA-DERIVATIVE AND DERIVATIVE_SS EQ IT_SR_DATA-DERIVATIVE_SS.
        CLEAR: V_WIDTH, V_BARRIER_POS, V_LINE, V_CODE, V_MOYE, V_SEQ, V_GRADE, V_DMS, V_PMS, V_DSS, V_PSS.

        READ TABLE IT_CHAR_SR WITH KEY CHARG = IT_SR_DATA2-CHARG ATINN = V_ZZWIDTH.
        IF SY-SUBRC EQ 0.
          V_WIDTH = IT_CHAR_SR-ATFLV.
        ENDIF.

        "For Main Slitting
        IF ITAB-ABLAD EQ 'MS'.
          PERFORM GET_BARRIER_POS USING IT_SR_DATA2-MATNR IT_SR_DATA2-CHARG CHANGING V_BARRIER_POS.

          IF V_BARRIER_POS IS INITIAL.
            PERFORM CALCULATE_BARRIER_POS USING IT_SR_DATA2-MATNR IT_SR_DATA2-CHARG IT_MAIN-MATNR_JR IT_MAIN-CHARG_JR CHANGING V_BARRIER_POS.
          ENDIF.
          "For Secondary Slitting
        ELSE.
          IF IT_SR_DATA2-POSITION NE IT_SR_DATA-POSITION.
            CONTINUE.
          ENDIF.

          READ TABLE IT_SR_DATA3 WITH KEY DERIVATIVE = IT_SR_DATA2-DERIVATIVE POSITION = IT_SR_DATA2-POSITION ABLAD = 'MS'.
          IF SY-SUBRC EQ 0.
            READ TABLE IT_CHAR_SR WITH KEY CHARG = IT_SR_DATA3-CHARG ATINN = V_ZZWIDTH.
            IF SY-SUBRC EQ 0.
              ITAB-WIDTH_JR = IT_CHAR_SR-ATFLV.
            ENDIF.

            PERFORM GET_BARRIER_POS USING IT_SR_DATA3-MATNR IT_SR_DATA3-CHARG CHANGING V_BARRIER_POS.

            IF V_BARRIER_POS IS INITIAL.
              PERFORM CALCULATE_BARRIER_POS USING IT_SR_DATA3-MATNR IT_SR_DATA3-CHARG IT_MAIN-MATNR_JR IT_MAIN-CHARG_JR CHANGING V_BARRIER_POS.
            ENDIF.
          ENDIF.

          READ TABLE IT_CHAR_SR WITH KEY CHARG = IT_SR_DATA2-CHARG ATINN = V_ZZPOSITIONSS.
          IF SY-SUBRC EQ 0.
            V_POSITION = IT_CHAR_SR-ATWRT.
          ENDIF.

          IT_SR_DATA2-POSITION = V_POSITION.
        ENDIF.

        IF IT_SR_DATA2-POSITION EQ '01'.
          ITAB-01 = V_WIDTH.
          ITAB-CH1_POINT = V_BARRIER_POS.
        ELSEIF IT_SR_DATA2-POSITION EQ '02'.
          ITAB-02 = V_WIDTH.
          ITAB-CH2_POINT = V_BARRIER_POS.
        ELSEIF IT_SR_DATA2-POSITION EQ '03'.
          ITAB-03 = V_WIDTH.
          ITAB-CH3_POINT = V_BARRIER_POS.
        ELSEIF IT_SR_DATA2-POSITION EQ '04'.
          ITAB-04 = V_WIDTH.
          ITAB-CH4_POINT = V_BARRIER_POS.
        ENDIF.

        V_COUNT = V_COUNT + V_WIDTH.
      ENDLOOP.

      V_TRIM = ( ITAB-WIDTH_JR - V_COUNT ) / 2.

      IF ITAB-01 IS NOT INITIAL.
        ITAB-CH1_START = V_TRIM.
        ITAB-CH1_END   = V_TRIM + ITAB-01.
      ENDIF.

      IF ITAB-02 IS NOT INITIAL.
        ITAB-CH2_START = V_TRIM + ITAB-01.
        ITAB-CH2_END   = V_TRIM + ITAB-01 + ITAB-02.
      ENDIF.

      IF ITAB-03 IS NOT INITIAL.
        ITAB-CH3_START = V_TRIM + ITAB-01 + ITAB-02.
        ITAB-CH3_END   = V_TRIM + ITAB-01 + ITAB-02 + ITAB-03.
      ENDIF.

      IF ITAB-04 IS NOT INITIAL.
        ITAB-CH4_START = V_TRIM + ITAB-01 + ITAB-02 + ITAB-03.
        ITAB-CH4_END   = V_TRIM + ITAB-01 + ITAB-02 + ITAB-03 + ITAB-04.
      ENDIF.

      SPLIT ITAB-ROLL AT SPACE INTO V_LINE V_CODE V_MOYE V_SEQ V_GRADE V_DMS V_PMS V_DSS V_PSS.

      IF ITAB-ABLAD EQ 'MS'.
        CONCATENATE V_LINE V_CODE V_MOYE V_SEQ V_DMS INTO ITAB-ROLL SEPARATED BY SPACE.
      ELSE.
        CONCATENATE V_LINE V_CODE V_MOYE V_SEQ V_DMS V_PMS V_DSS INTO ITAB-ROLL SEPARATED BY SPACE.
      ENDIF.

      ITAB-DERIVATIVE2 = ITAB-DERIVATIVE.

      APPEND ITAB.
      CLEAR ITAB.
    ENDLOOP.
  ENDLOOP.

  IF ITAB[] IS INITIAL.
    MESSAGE 'Data not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF ITAB[] IS NOT INITIAL.
    PERFORM REFRESH.
  ENDIF.
ENDFORM.                    "GET_PREVIEW


*&---------------------------------------------------------------------*
*&      Form  GET_BARRIER_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR        text
*      -->CHARG        text
*      -->BARRIER_POS  text
*----------------------------------------------------------------------*
FORM GET_BARRIER_POS USING MATNR CHARG CHANGING BARRIER_POS.
  CLEAR: V_NAME, THEAD, TLINE.
  REFRESH: TLINE.

  "Check Barrier
  V_NAME+0(10)    = MATNR.
  V_NAME+22(10)   = CHARG.

  THEAD-TDID      = 'VERM'.
  THEAD-TDSPRAS   = SY-LANGU.
  THEAD-TDNAME    = V_NAME.
  THEAD-TDOBJECT  = 'CHARGE'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = THEAD-TDID
      LANGUAGE                = THEAD-TDSPRAS
      NAME                    = THEAD-TDNAME
      OBJECT                  = THEAD-TDOBJECT
    TABLES
      LINES                   = TLINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  READ TABLE TLINE INDEX 1.
  IF SY-SUBRC EQ 0.
    BARRIER_POS = TLINE-TDLINE.
  ENDIF.
ENDFORM.                    "GET_BARRIER_POS

*&---------------------------------------------------------------------*
*&      Form  CALCULATE_BARRIER_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SR           text
*      -->MATNR_SR     text
*      -->CHARG_SR     text
*      -->MATNR_JR     text
*      -->CHARG_JR     text
*      -->BARRIER_POS  text
*----------------------------------------------------------------------*
FORM CALCULATE_BARRIER_POS USING MATNR_SR CHARG_SR MATNR_JR CHARG_JR CHANGING BARRIER_POS.
  CALL FUNCTION 'ZQM_GET_BARRIER_POS'
    EXPORTING
      MATNR_SR    = MATNR_SR
      CHARG_SR    = CHARG_SR
      MATNR_JR    = MATNR_JR
      CHARG_JR    = CHARG_JR
    IMPORTING
      BARRIER_POS = BARRIER_POS
    TABLES
      IT_SR       = IT_SR_DATA5
      IT_CABN     = IT_CABN.
ENDFORM.                    "CALCULATE_BARRIER_POS

*&---------------------------------------------------------------------*
*&      Form  REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH.
  SORT ITAB BY ROLL_JR ASCENDING ABLAD ASCENDING DERIVATIVE ASCENDING.
  LOOP AT ITAB.

    IF ITAB-ZSTAT IS INITIAL.
      ITAB-ZSTAT = GREY.
    ENDIF.

    MODIFY ITAB.
    CLEAR ITAB.
  ENDLOOP.
ENDFORM.                    "REFRESH

*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BAPI_COMMIT .
  CALL FUNCTION 'DB_COMMIT'.
  CALL FUNCTION 'DEQUEUE_ALL'
    EXPORTING
      _SYNCHRON = 'X'.
  COMMIT WORK AND WAIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.                    "BAPI_COMMIT

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_COLOURS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->COLUMN_NAME  text
*      -->REMARK       text
*----------------------------------------------------------------------*
FORM SET_CELL_COLOURS TABLES CELL_COLOUR USING COLUMN_NAME COLOR .
  WA_CELL_COLOR-FNAME = COLUMN_NAME.
  WA_CELL_COLOR-COLOR-COL = COLOR.  "Yellow, Range: 1-7
  WA_CELL_COLOR-COLOR-INT = 1.
  WA_CELL_COLOR-COLOR-INV = 1.
  APPEND WA_CELL_COLOR TO CELL_COLOUR.
  CLEAR: WA_CELL_COLOR.
ENDFORM.                    "SET_CELL_COLOURS

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG_PREVIEW.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL_PREVIEW.
ENDFORM.                    "DISPLAY_alv

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_PREVIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_PREVIEW.
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
    'ROLL_JR'         ''  ''    '' '12'   'Input Roll'            '' '' '' '',
    'WIDTH_JR'        ''  ''    '' '8'    'Input Width'           '' '' '' '',
    'ABLAD'           ''  ''    '' '4'    'MS/SS'                 '' '' '' '',
    'DERIVATIVE'      ''  ''    '' '4'    'b'                     '' '' '' '',
    '01'              ''  ''    '' '5'    '01'                    '' '' '' '',
    '02'              ''  ''    '' '5'    '02'                    '' '' '' '',
    '03'              ''  ''    '' '5'    '03'                    '' '' '' '',
    '04'              ''  ''    '' '5'    '04'                    '' '' '' '',
    'SAMPLE_DATE'     ''  ''    '' '10'   'Sample Received'       '' '' '' '',
    'DERIVATIVE2'     ''  ''    '' '8'    'Derivative'            '' '' '' '',
    'ROLL'            ''  ''    '' '18'   'No Roll & Derivative'  '' '' '' '',
    'CH1_START'       ''  ''    '' '8'    '1Ch Start'             '' '' '' '',
    'CH1_END'         ''  ''    '' '8'    '1Ch End'               '' '' '' '',
    'CH2_START'       ''  ''    '' '8'    '2Ch Start'             '' '' '' '',
    'CH2_END'         ''  ''    '' '8'    '2Ch End'               '' '' '' '',
    'CH3_START'       ''  ''    '' '8'    '3Ch Start'             '' '' '' '',
    'CH3_END'         ''  ''    '' '8'    '3Ch End'               '' '' '' '',
    'CH4_START'       ''  ''    '' '8'    '4Ch Start'             '' '' '' '',
    'CH4_END'         ''  ''    '' '8'    '4Ch End'               '' '' '' '',
    'CH1_POINT'       ''  ''    '' '8'    '1Ch Point'             '' '' '' '',
    'CH2_POINT'       ''  ''    '' '8'    '2Ch Point'             '' '' '' '',
    'CH3_POINT'       ''  ''    '' '8'    '3Ch Point'             '' '' '' '',
    'CH4_POINT'       ''  ''    '' '8'    '4Ch Point'             '' '' '' ''.

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME EQ 'CHARG'
                                            OR FIELDNAME EQ 'DERIVATIVE'
                                            OR FIELDNAME EQ 'DERIVATIVE2'
                                            OR FIELDNAME EQ 'POSITION'.

*  T_FIELDCAT-JUST = 'C'.
*  MODIFY T_FIELDCAT TRANSPORTING JUST WHERE FIELDNAME NE 'MESS'.

  T_SORT-SPOS      = 1.
  T_SORT-FIELDNAME = 'ROLL_JR'.
  APPEND T_SORT.

  T_FIELDCAT-JUST = 'L'.
  MODIFY T_FIELDCAT TRANSPORTING JUST WHERE FIELDNAME EQ 'ROLL_JR'
                                         OR FIELDNAME EQ 'ABLAD'
                                         OR FIELDNAME EQ 'SAMPLE_DATE'
                                         OR FIELDNAME EQ 'ROLL'
                                         OR FIELDNAME EQ 'CH1_POINT'
                                         OR FIELDNAME EQ 'CH2_POINT'
                                         OR FIELDNAME EQ 'CH3_POINT'
                                         OR FIELDNAME EQ 'CH4_POINT'.

  T_FIELDCAT-JUST = 'R'.
  MODIFY T_FIELDCAT TRANSPORTING JUST WHERE FIELDNAME EQ 'WIDTH_JR'
                                         OR FIELDNAME EQ 'DERIVATIVE'
                                         OR FIELDNAME EQ '01'
                                         OR FIELDNAME EQ '02'
                                         OR FIELDNAME EQ '03'
                                         OR FIELDNAME EQ '04'
                                         OR FIELDNAME EQ 'DERIVATIVE'
                                         OR FIELDNAME EQ 'CH1_START'
                                         OR FIELDNAME EQ 'CH1_END'
                                         OR FIELDNAME EQ 'CH2_START'
                                         OR FIELDNAME EQ 'CH2_END'
                                         OR FIELDNAME EQ 'CH3_START'
                                         OR FIELDNAME EQ 'CH3_END'
                                         OR FIELDNAME EQ 'CH4_START'
                                         OR FIELDNAME EQ 'CH4_END'.

















ENDFORM.                    "F_FIELD_CATALOG_PREVIEW

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_PREVIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT.
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA                 = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT   = ''.
  WA_LAYOUT-SUBTOTALS_TEXT        = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT           = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME         = 'BOX'.
  WA_LAYOUT-CELL_MERGE            = 'X'.
  WA_LAYOUT-INFO_FIELDNAME        = 'LINE_COLOR'.
  WA_LAYOUT-COLTAB_FIELDNAME      = 'CELL_COLOR'.
ENDFORM.                    "F_LAYOUT_PREVIEW

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_PREVIEW.
  DATA: LWA_SORT  TYPE LVC_S_SORT.

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_PREVIEW'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " f_list_detail

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN 'REFRESH'.
      PERFORM GET_DATA.
    WHEN 'EXEC'.
      PERFORM COLLECT_DATA.
  ENDCASE.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  COLLECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM COLLECT_DATA.
  READ TABLE ITAB WITH KEY BOX = 'X' ERR = ''.
  IF SY-SUBRC EQ 0.
    CALL SCREEN 2000 STARTING AT 20 01.
  ENDIF.
ENDFORM.                    "COLLECT_DATA

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_PREVIEW USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PASS_FAIL' EXCLUDING 'EXEC'.
  SET TITLEBAR  'PASS_FAIL'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DATE     text
*      -->O_DATE     text
*----------------------------------------------------------------------*
FORM CONVERT_DATE_INPUT USING I_DATE CHANGING O_DATE.
  CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
    EXPORTING
      INPUT  = I_DATE
    IMPORTING
      OUTPUT = O_DATE.
ENDFORM.                    "CONVERT_DATE_INPUT

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DATE     text
*      -->O_DATE     text
*----------------------------------------------------------------------*
FORM CONVERT_DATE_OUTPUT USING I_DATE CHANGING O_DATE.
  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      INPUT  = I_DATE
    IMPORTING
      OUTPUT = O_DATE.
ENDFORM.                    "CONVERT_DATE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_ERROR.
  LOOP AT ITAB WHERE BOX = 'X' AND ERR = ''.
    ITAB-MESS = 'Transaction Success'.
    ITAB-ZSTAT  = SUCCES.
    MODIFY ITAB.
    CLEAR ITAB.
  ENDLOOP.
ENDFORM.                    "CHECK_ERROR

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DELAYING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS_DELAYING .
  DATA : X1 TYPE P DECIMALS 4.                              "#EC NEEDED
  DO 80000 TIMES.
    X1 = SQRT( SY-INDEX ) / SQRT( SY-INDEX ).
  ENDDO.
  WAIT UP TO 1 SECONDS. "ADD DELAY TIME
ENDFORM.                    "PROCESS_DELAYING

*&---------------------------------------------------------------------*
*&      Form  SET_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INDEX          text
*      -->COUNT_INDEX    text
*      -->PROCESS        text
*      -->COUNT_PROCESS  text
*      -->TEXT           text
*----------------------------------------------------------------------*
FORM SET_INDICATOR USING INDEX COUNT_INDEX PROCESS COUNT_PROCESS TEXT.
  DATA: PERCENT TYPE P.
  CLEAR: PERCENT.
  PERCENT =  ( ( INDEX + ( COUNT_INDEX * PROCESS ) - COUNT_INDEX ) / ( COUNT_INDEX * COUNT_PROCESS ) )  * 100.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PERCENT
      TEXT       = TEXT.
ENDFORM.                    "SET_INDICATOR


*&---------------------------------------------------------------------*
*&      Form  CONVERSION_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INPUT      text
*      -->OUTPUT     text
*----------------------------------------------------------------------*
FORM CONVERSION_INPUT USING INPUT CHANGING OUTPUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = INPUT
    IMPORTING
      OUTPUT = OUTPUT.
ENDFORM.                    "CONVERSION_INPUT

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INPUT      text
*      -->OUTPUT     text
*----------------------------------------------------------------------*
FORM CONVERSION_OUTPUT USING INPUT CHANGING OUTPUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = INPUT
    IMPORTING
      OUTPUT = OUTPUT.
ENDFORM.                    "CONVERSION_OUTPUT