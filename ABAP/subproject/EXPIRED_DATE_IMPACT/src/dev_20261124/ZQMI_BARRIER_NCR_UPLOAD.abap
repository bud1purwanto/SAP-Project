*&---------------------------------------------------------------------*
*&  Report     :  ZQMI_BARRIER_NCR_UPLOAD                              *
*&  Appl. Area :  QM                                                   *
*&  Created by :  J. Budi                                              *
*&  Created on :  24 September 2025                                        *
*&---------------------------------------------------------------------*

REPORT  ZQMI_BARRIER_NCR_UPLOAD.

TYPES: BEGIN OF T_UPLOAD,
       MATNR          TYPE MATNR,            "Material No
       WERKS          TYPE CHAR100,         "Plant
       LGORT          TYPE CHAR100,         "Storage Location
       CHARG          TYPE CHARG_D,         "Batch
       TYPE           TYPE CHAR100,         "Type (custom)
       THICKNESS      TYPE CHAR100,         "Thick
       WIDTH          TYPE CHAR100,         "Width
       LENGTH         TYPE CHAR100,         "Length
       BL_STOCK_KG    TYPE CHAR100,         "Blocked Stock (KG)
       BL_SR          TYPE CHAR100,         "Blocked (SR)
       BL_REASON      TYPE CHAR100,         "Blocked Reason
       BL_COMMENT     TYPE CHAR100,         "Blocked Comment
       DERIVITIVE     TYPE CHAR100,         "Derivitive
       ROLL_DERV      TYPE CHAR100,         "No Roll & Derivitive
       POSITION       TYPE CHAR100,         "Position
*       DEVICE         TYPE CHAR100,         "Device
       BARRIER_POS    TYPE CHAR100,         "Barrier Position
       TIMES          TYPE CHAR100,         "Total Times
       BARRIER_R      TYPE CHAR100,         "Barrier Result R
       BARRIER_C      TYPE CHAR100,         "Barrier Result C
       BARRIER_L      TYPE CHAR100,         "Barrier Result L
       JUDGEMENT      TYPE CHAR100,         "Judgement
       NCR_APPROVAL   TYPE CHAR15,          "NCR Approval
       MVTR_R         TYPE C LENGTH 10,     "MVTR R Position
       MVTR_C         TYPE C LENGTH 10,     "MVTR C Position
       MVTR_L         TYPE C LENGTH 10,     "MVTR L Position
       OTR_R          TYPE C LENGTH 10,     "OTR R Position
       OTR_C          TYPE C LENGTH 10,     "OTR C Position
       OTR_L          TYPE C LENGTH 10,     "OTR L Position
       PRUEFLOS_R     TYPE CHAR100,         "Barrier Lot R
       PRUEFLOS_C     TYPE CHAR100,         "Barrier Lot C
       PRUEFLOS_L     TYPE CHAR100,         "Barrier Lot L
       DATETIME_R     TYPE CHAR100,         "Barrier Datetime R
       DATETIME_C     TYPE CHAR100,         "Barrier Datetime C
       DATETIME_L     TYPE CHAR100,         "Barrier Datetime C
       DATETIME_JUDG  TYPE CHAR100,         "Judgement Time
       CAN_BE_SHIP    LIKE QAVE-VCODE,      "Can Be Ship
       NO_PO          TYPE CHAR1,           "No PO
       QTY            TYPE LABST,           "Quantity
       MATNR_JR       TYPE MATNR,           "Material
       CHARG_JR       TYPE CHARG_D,         "Batch
       WIDTH_JR       TYPE I,               "Width
       MBLNR          TYPE MBLNR,           "Matdoc SR Number
       SMBLN          TYPE MBLNR,           "Matdoc SR Number Cancel
       MJAHR          TYPE MJAHR,           "Matdoc SR Year
       SJAHR          TYPE MJAHR,           "Matdoc SR Year Cancel
       ZEILE          TYPE MBLPO,           "Matdoc SR Item
       SMBLP          TYPE MBLPO,           "Matdoc SR Item Cancel
       BWART          TYPE BWART,           "Movement Type
       ROLL           TYPE CHAR30,          "No Roll
       DERIVITIVE_SS  TYPE CHAR20,          "Derivitive
       POSITION_SS    TYPE CHAR10,          "Position
       TIMES_R        TYPE QASE-PROBENR,    "Times R Position
       TIMES_C        TYPE QASE-PROBENR,    "Times C Position
       TIMES_L        TYPE QASE-PROBENR,    "Times L Positio
       TIMES_NOT_PAS  TYPE QASE-PROBENR,    "Total Times no Pass
       "Characteristic
       COMB_NO        TYPE ATWRT,           "Comb. No
       PACKING        TYPE ATWTB,           "Packing
       TREATMENT      TYPE ATWTB,           "Treatment
       CORE           TYPE ATWTB,           "Core
       GRADE          TYPE ATWRT,           "Grade
       KATEGORI       TYPE ATWRT,           "Kategori
       CRITERIA       TYPE ATWTB,           "Criteria
       ALIAS          TYPE ATWRT,           "Tipe Alias
       UNREST_KG      TYPE LABST,           "Unrest (Kg)
       UNREST_ROLL    TYPE I,               "Unrest (Roll)
       QINSP_KG       TYPE LABST,           "Quality Inspection (Kg)
       QINSP_ROLL     TYPE I,               "Quality Inspection (Roll)
       TIPE_LABEL     TYPE ATWRT,           "Tipe Label
       EXPIRED_DATE   TYPE SY-DATUM,        "Expired Date
       PROD_DATE      TYPE SY-DATUM,        "Production Date
       GR_DATE        TYPE SY-DATUM,        "GR Date
       SPECIAL_TOUCH  TYPE ATWRT,           "Special Touch-1
       VENDOR_BATCH   TYPE LICHN,           "Vendor Batch
       PRODUCTION_NUM TYPE CHAR30,          "Production Number
       NO_ROL_TOYOBO  TYPE ATWRT,           "No Rol Toyobo
       NO_LOT_TOYOBO  TYPE ATWRT,           "No Lot Toyobo
       NO_ROL_MOS     TYPE ATWRT,           "No Rol MOS-T-SS
       "Custom ALV
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
      IT_CHECK_CANC   LIKE ITAB OCCURS 0 WITH HEADER LINE,
      IT_UPLOAD       TYPE STANDARD TABLE OF T_UPLOAD   WITH HEADER LINE,
      IT_INSPECTION   TYPE STANDARD TABLE OF T_TAB   WITH HEADER LINE,
      IT_COUNT_ROW    TYPE STANDARD TABLE OF T_TAB   WITH HEADER LINE,
      IT_MVTR         LIKE IT_QASE OCCURS 0 WITH HEADER LINE,
      IT_OTR          LIKE IT_QASE OCCURS 0 WITH HEADER LINE,
      WA_JUDGEMENT    LIKE ZLOG_BARRIER,
      IT_JUDGEMENT    LIKE ZLOG_BARRIER OCCURS 0 WITH HEADER LINE.

"Formula RCL
DATA: BEGIN OF IT_MATNR OCCURS 0,
       MATNR          TYPE MATNR,
       WERKS          TYPE WERKS_D,
       MATKL          TYPE MATKL,
      END OF IT_MATNR.

"Variable
DATA: FILENAME1       TYPE STRING,
      V_ATINN         TYPE ATINN,
      V_TEMP(50),
      V_CHARG         TYPE CHARG_D,
      V_MVTR          TYPE P DECIMALS 3,
      V_OTR           TYPE P DECIMALS 3,
      V_TIMES         LIKE QASE-PROBENR,
      V_DATE          TYPE SY-DATUM,
      V_TIME          TYPE SY-UZEIT,
      V_TFILL         TYPE I,
      V_PROC_EX       TYPE I VALUE 3,
      V_KTEXTLOS      LIKE QALS-KTEXTLOS,
      V_PRUEFLOS      LIKE QALS-PRUEFLOS,
      V_CANCELLED     TYPE I,
      V_COLUMN(20),
      V_LINE(5),
      V_CODE(5),
      V_MOYE(5),
      V_SEQ(5),
      V_GRADE(5),
      V_DMS(5),
      V_DSS(5),
      V_PMS(5),
      V_PSS(5),
      V_STOP,
      V_ERR,
      V_COUNT         TYPE I,
      V_TRIM          TYPE I,
      V_POS(2),
      ACCEPT,
      REJECT.

"Usage Decision
DATA: V_VCODE         LIKE QAVE-VCODE,
      V_PASS          LIKE QAVE-VCODE VALUE   'PASS',
      V_FAIL          LIKE QAVE-VCODE VALUE   'FAIL',
      V_SCRAP         TYPE C LENGTH 10 VALUE  'SCRAP',
      V_NCR           TYPE C LENGTH 10 VALUE  'NCR',
      V_NOT           TYPE C LENGTH 10 VALUE  'NOT YET',
      V_OK            LIKE QAVE-VCODE VALUE   'OK',
      V_NO            LIKE QAVE-VCODE VALUE   'NO',
      V_NG            LIKE QAVE-VCODE VALUE   'NG',
      V_APPROVED      TYPE C LENGTH 10 VALUE  'Approved',
      V_NOT_APPROVED  TYPE C LENGTH 15 VALUE  'Not Approved'.

DATA: IT_SHIPMENT     LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE,
      BLOCKED_STATUS  TYPE C LENGTH 30.

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

DATA: BEGIN OF IT_CHAR OCCURS 0,
       CHARG          TYPE CHARG_D,
       ATINN          TYPE ATINN,
       ATWRT          TYPE ATWRT,
       ATFLV          TYPE ATFLV,
       ATWTB          TYPE ATWTB,
      END OF IT_CHAR.

DATA: IT_CHAR_DESC    LIKE IT_CHAR OCCURS 0 WITH HEADER LINE.

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

"Judgement
DATA: BEGIN OF IT_RANK OCCURS 0,
       VALUATION      TYPE ATWRT,
       VCODE          TYPE QAVE-VCODE,
       ALIAS          TYPE ATWRT,
       COLOR          TYPE ATWRT,
       END OF IT_RANK.

DATA: BEGIN OF IT_RANK_FINAL OCCURS 0,
       VALUATION      TYPE I,
       VCODE          TYPE QAVE-VCODE,
       ALIAS          TYPE ATWRT,
       COLOR          TYPE ATWRT,
       END OF IT_RANK_FINAL.

DATA: IT_SR_DATA LIKE ZQM_GET_BATCH_SR OCCURS 0 WITH HEADER LINE.

DATA: V_ZZTYPE             TYPE ATINN,
      V_ZZTHICKNESS        TYPE ATINN,
      V_ZZWIDTH            TYPE ATINN,
      V_ZZLENGTH           TYPE ATINN,
      V_ZZNOMORROLL        TYPE ATINN,
      V_ZZDERIVATIVESS     TYPE ATINN,
      V_ZZDERIVATIVEMS     TYPE ATINN,
      V_ZZPOSITIONSS       TYPE ATINN,
      V_ZZPOSITIONMS       TYPE ATINN,
      V_ZZTYBCOMBINATIONNO TYPE ATINN,
      V_ZZGRADE            TYPE ATINN,
      V_ZZTAILORED         TYPE ATINN,
      V_ZZALIAS            TYPE ATINN,
      V_ZZLABEL            TYPE ATINN,
      V_ZZSPECIALTOUCH-1   TYPE ATINN,
      V_ZZNOROLLTOYOBO     TYPE ATINN,
      V_ZZNOLOTTOYOBO      TYPE ATINN,
      V_ZZNOROLLTOYOBO2    TYPE ATINN,
      V_ZZEXPIREDLIVE      TYPE ATINN,
      V_ZZCRITERIA         TYPE ATINN,
      V_ZZPACKING          TYPE ATINN,
      V_ZZTREATMENT        TYPE ATINN,
      V_ZZCORE             TYPE ATINN,
      V_VALUE TYPE P DECIMALS 3.

TABLES: MKPF, MSEG, AUSP, MARA.

RANGES: R_STATUS      FOR VBAP-VBELN.
RANGES: R_NCR_AP      FOR ZLOG_BARRIER-NCRAPPROVAL.
RANGES: R_DESC        FOR CABN-ATINN.

INCLUDE ZABAPALV.

SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-001.
PARAMETERS: FILENAME LIKE RLGRAP-FILENAME LOWER CASE MODIF ID B4 DEFAULT 'D:\'.
SELECTION-SCREEN END OF BLOCK BLK3.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_PAS   AS CHECKBOX MODIF ID B2 DEFAULT ''.
PARAMETERS: P_NCR   AS CHECKBOX MODIF ID B3 DEFAULT 'X'.
PARAMETERS: P_FAIL  AS CHECKBOX MODIF ID B2 DEFAULT ''.
PARAMETERS: P_NOT   AS CHECKBOX MODIF ID B2 DEFAULT ''.
SELECTION-SCREEN END OF BLOCK BLK2.

AT SELECTION-SCREEN OUTPUT.
  SET TITLEBAR  'NCR_UPLOAD'.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'B2' OR SCREEN-GROUP1 = 'B2' OR SCREEN-GROUP1 = 'B2'.
      SCREEN-INPUT  = 0.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ELSEIF SCREEN-GROUP1 = 'B3'.
      SCREEN-INPUT  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILENAME.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MODE             = 'O'
      TITLE            = 'Select File'
    IMPORTING
      FILENAME         = FILENAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.
  PERFORM VALIDATION.
  PERFORM GET_PARAM.
  PERFORM GET_UPLOAD.
  PERFORM GET_DATA_BARU.
  PERFORM DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDATION.
  IF FILENAME IS INITIAL.
    MESSAGE 'Please choose the file!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    "VALIDATION

*&---------------------------------------------------------------------*
*&      Form  CONFIRMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONFIRMATION.
  DATA: V_ANSWER.

  READ TABLE ITAB WITH KEY BOX = 'X'.
  IF SY-SUBRC NE 0.
    LEAVE SCREEN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Confirmation'
      TEXT_QUESTION         = 'Are you sure want to execute?'
      TEXT_BUTTON_1         = 'Yes'
      TEXT_BUTTON_2         = 'No'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = ''
    IMPORTING
      ANSWER                = V_ANSWER.

  IF V_ANSWER EQ 2.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.                    "CONFIRMATION
*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_UPLOAD.
  CLEAR : ITAB.
  REFRESH : ITAB.

  MOVE FILENAME TO FILENAME1.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FILENAME1
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = IT_UPLOAD
    EXCEPTIONS
      CONVERSION_ERROR    = 1
      INVALID_TABLE_WIDTH = 2
      INVALID_TYPE        = 3
      NO_BATCH            = 4
      UNKNOWN_ERROR       = 5
      FILE_OPEN_ERROR     = 6
      FILE_READ_ERROR     = 7
      OTHERS              = 8.

  IF SY-SUBRC <> 0.
    MESSAGE 'File cannot be opened!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT IT_UPLOAD.
    MOVE-CORRESPONDING IT_UPLOAD TO ITAB.

    PERFORM CONVERSION USING ITAB-MVTR_R CHANGING ITAB-MVTR_R.
    PERFORM CONVERSION USING ITAB-MVTR_C CHANGING ITAB-MVTR_C.
    PERFORM CONVERSION USING ITAB-MVTR_L CHANGING ITAB-MVTR_L.
    PERFORM CONVERSION USING ITAB-OTR_R CHANGING ITAB-OTR_R.
    PERFORM CONVERSION USING ITAB-OTR_C CHANGING ITAB-OTR_C.
    PERFORM CONVERSION USING ITAB-OTR_L CHANGING ITAB-OTR_L.


    APPEND ITAB.
    CLEAR ITAB.
  ENDLOOP.
ENDFORM.                    "VALIDATION

*&---------------------------------------------------------------------*
*&      Form  CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INPUT      text
*      -->OUTPUT     text
*----------------------------------------------------------------------*
FORM CONVERSION USING INPUT CHANGING OUTPUT.
  IF INPUT EQ '-'.
    OUTPUT = INPUT.
    EXIT.
  ENDIF.

  CLEAR: V_VALUE.
  V_VALUE = INPUT.
  OUTPUT = V_VALUE.
ENDFORM.                    "GET_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  GET_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PARAM.
  REFRESH: IT_RANK, R_DESC.
  CLEAR: IT_RANK, R_DESC.

  SELECT
      VALUE AS VCODE
      TEXT1 AS VALUATION
      TEXT2 AS ALIAS
      TEXT3 AS COLOR
      INTO CORRESPONDING FIELDS OF TABLE IT_RANK
      FROM ZMAP_TYPE
     WHERE TCODE    EQ SY-TCODE
       AND TYPE     EQ 'BARRIER'
       AND OPT      EQ 'JUDGEMENT'
       AND DELETION EQ ''.

  IF IT_RANK[] IS INITIAL.
    SELECT
      VALUE AS VCODE
      TEXT1 AS VALUATION
      TEXT2 AS ALIAS
      TEXT3 AS COLOR
      INTO CORRESPONDING FIELDS OF TABLE IT_RANK
      FROM ZMAP_TYPE
     WHERE PROG     EQ SY-CPROG
       AND TYPE     EQ 'BARRIER'
       AND OPT      EQ 'JUDGEMENT'
       AND DELETION EQ ''.
  ENDIF.

  IF IT_RANK[] IS INITIAL.
    MESSAGE 'Mapping Barrier Judgement not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_PAS EQ 'X'.
    R_STATUS-LOW = V_PASS.
    APPEND R_STATUS.

    READ TABLE IT_RANK WITH KEY VCODE = R_STATUS-LOW.
    IF SY-SUBRC EQ 0 AND IT_RANK-ALIAS IS NOT INITIAL.
      R_STATUS-LOW = IT_RANK-ALIAS.
      APPEND R_STATUS.
    ENDIF.
  ENDIF.

  IF P_FAIL EQ 'X'.
    R_STATUS-LOW = V_FAIL.
    APPEND R_STATUS.

    READ TABLE IT_RANK WITH KEY VCODE = R_STATUS-LOW.
    IF SY-SUBRC EQ 0 AND IT_RANK-ALIAS IS NOT INITIAL.
      R_STATUS-LOW = IT_RANK-ALIAS.
      APPEND R_STATUS.
    ENDIF.
  ENDIF.

  IF P_NCR EQ 'X'.
    R_STATUS-LOW = V_NCR.
    APPEND R_STATUS.

    READ TABLE IT_RANK WITH KEY VCODE = R_STATUS-LOW.
    IF SY-SUBRC EQ 0 AND IT_RANK-ALIAS IS NOT INITIAL.
      R_STATUS-LOW = IT_RANK-ALIAS.
      APPEND R_STATUS.
    ENDIF.
  ENDIF.

  IF P_NOT EQ 'X'.
    R_STATUS-LOW = V_NOT.
    APPEND R_STATUS.

    READ TABLE IT_RANK WITH KEY VCODE = R_STATUS-LOW.
    IF SY-SUBRC EQ 0 AND IT_RANK-ALIAS IS NOT INITIAL.
      R_STATUS-LOW = IT_RANK-ALIAS.
      APPEND R_STATUS.
    ENDIF.
  ENDIF.

  IF R_STATUS[] IS NOT INITIAL.
    R_STATUS-SIGN   = 'I'.
    R_STATUS-OPTION = 'EQ'.
    MODIFY R_STATUS TRANSPORTING OPTION SIGN WHERE SIGN = ''.
  ENDIF.

  CLEAR: IT_SHIPMENT.
  REFRESH: IT_SHIPMENT.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_SHIPMENT
    FROM ZMAP_TYPE
   WHERE TCODE    EQ SY-TCODE
     AND TYPE     EQ 'BARRIER'
     AND OPT      EQ 'SHIPMENT'
     AND DELETION EQ ''.

  IF IT_SHIPMENT[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_SHIPMENT
      FROM ZMAP_TYPE
     WHERE PROG   EQ SY-CPROG
       AND TYPE   EQ 'BARRIER'
       AND OPT    EQ 'SHIPMENT'
       AND DELETION EQ ''.
  ENDIF.

  IF IT_SHIPMENT[] IS INITIAL.
    MESSAGE 'Mapping can be ship not found!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT IT_SHIPMENT WHERE TEXT3 IS NOT INITIAL.
    R_NCR_AP-LOW    = IT_SHIPMENT-TEXT3.
    R_NCR_AP-SIGN   = 'I'.
    R_NCR_AP-OPTION = 'EQ'.
    APPEND R_NCR_AP.
  ENDLOOP.

  SELECT SINGLE ATINN INTO V_ZZTYPE              FROM CABN WHERE ATNAM = 'ZZTYPE'.
  SELECT SINGLE ATINN INTO V_ZZTHICKNESS         FROM CABN WHERE ATNAM = 'ZZTHICKNESS'.
  SELECT SINGLE ATINN INTO V_ZZWIDTH             FROM CABN WHERE ATNAM = 'ZZWIDTH'.
  SELECT SINGLE ATINN INTO V_ZZLENGTH            FROM CABN WHERE ATNAM = 'ZZLENGTH'.
  SELECT SINGLE ATINN INTO V_ZZNOMORROLL         FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO V_ZZDERIVATIVESS      FROM CABN WHERE ATNAM = 'ZZDERIVATIVESS'.
  SELECT SINGLE ATINN INTO V_ZZDERIVATIVEMS      FROM CABN WHERE ATNAM = 'ZZDERIVATIVEMS'.
  SELECT SINGLE ATINN INTO V_ZZPOSITIONSS        FROM CABN WHERE ATNAM = 'ZZPOSITIONSS'.
  SELECT SINGLE ATINN INTO V_ZZPOSITIONMS        FROM CABN WHERE ATNAM = 'ZZPOSITIONMS'.
  SELECT SINGLE ATINN INTO V_ZZTYBCOMBINATIONNO  FROM CABN WHERE ATNAM = 'ZZTYBCOMBINATIONNO'.
  SELECT SINGLE ATINN INTO V_ZZGRADE             FROM CABN WHERE ATNAM = 'ZZGRADE'.
  SELECT SINGLE ATINN INTO V_ZZTAILORED          FROM CABN WHERE ATNAM = 'ZZTAILORED'.
  SELECT SINGLE ATINN INTO V_ZZALIAS             FROM CABN WHERE ATNAM = 'ZZALIAS'.
  SELECT SINGLE ATINN INTO V_ZZLABEL             FROM CABN WHERE ATNAM = 'ZZLABEL'.
  SELECT SINGLE ATINN INTO V_ZZSPECIALTOUCH-1    FROM CABN WHERE ATNAM = 'ZZSPECIALTOUCH-1'.
  SELECT SINGLE ATINN INTO V_ZZNOROLLTOYOBO      FROM CABN WHERE ATNAM = 'ZZNOROLLTOYOBO'.
  SELECT SINGLE ATINN INTO V_ZZNOLOTTOYOBO       FROM CABN WHERE ATNAM = 'ZZNOLOTTOYOBO'.
  SELECT SINGLE ATINN INTO V_ZZNOROLLTOYOBO2     FROM CABN WHERE ATNAM = 'ZZNOROLLTOYOBO2'.
  SELECT SINGLE ATINN INTO V_ZZEXPIREDLIVE       FROM CABN WHERE ATNAM = 'ZZEXPIREDLIVE'.

  "Atwtb
  SELECT SINGLE ATINN INTO V_ZZCRITERIA          FROM CABN WHERE ATNAM = 'ZZCRITERIA'.
  SELECT SINGLE ATINN INTO V_ZZPACKING           FROM CABN WHERE ATNAM = 'ZZPACKING'.
  SELECT SINGLE ATINN INTO V_ZZTREATMENT         FROM CABN WHERE ATNAM = 'ZZTREATMENT'.
  SELECT SINGLE ATINN INTO V_ZZCORE              FROM CABN WHERE ATNAM = 'ZZCORE'.

  R_DESC-LOW = V_ZZCRITERIA.
  APPEND R_DESC.

  R_DESC-LOW = V_ZZPACKING.
  APPEND R_DESC.

  R_DESC-LOW = V_ZZPACKING.
  APPEND R_DESC.

  R_DESC-LOW = V_ZZCORE.
  APPEND R_DESC.

  IF R_DESC[] IS NOT INITIAL.
    R_DESC-SIGN   = 'I'.
    R_DESC-OPTION = 'EQ'.
    MODIFY R_DESC TRANSPORTING OPTION SIGN WHERE SIGN = ''.
  ENDIF.
ENDFORM.                    "GET_PARAM

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BARU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_BARU.
  LOOP AT ITAB.

    PERFORM CONVERSION_INPUT USING ITAB-CHARG CHANGING ITAB-CHARG.

    IF ITAB-NCR_APPROVAL NOT IN R_NCR_AP.
      ITAB-MESS  = 'Please fill NCR Approval with defined value..!'.
      ITAB-ZSTAT = ERROR.
      ITAB-ERR   = 'X'.
      MODIFY ITAB.
      CLEAR ITAB.
      CONTINUE.
    ENDIF.

    PERFORM GENERATE_COLUMN_COLOUR USING 'BARRIER_R' ITAB-BARRIER_R.
    PERFORM GENERATE_COLUMN_COLOUR USING 'BARRIER_C' ITAB-BARRIER_C.
    PERFORM GENERATE_COLUMN_COLOUR USING 'BARRIER_L' ITAB-BARRIER_L.
    PERFORM GENERATE_COLUMN_COLOUR USING 'JUDGEMENT' ITAB-JUDGEMENT.

    MODIFY ITAB.
    CLEAR ITAB.
  ENDLOOP.

  IF ITAB[] IS NOT INITIAL.
    PERFORM REFRESH.
  ENDIF.
ENDFORM.                    "GET_DATA_BARU

*&---------------------------------------------------------------------*
*&      Form  GET_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR        text
*      -->WERKS        text
*      -->CHARG        text
*      -->LGORT        text
*      -->UNREST_KG    text
*      -->UNREST_ROLL  text
*      -->QINSP_KG     text
*      -->QINSP_ROLL   text
*      -->BL_STOCK_KG  text
*      -->BL_SR        text
*      -->BL_REASON    text
*      -->BL_COMMENT   text
*----------------------------------------------------------------------*
FORM GET_STOCK USING MATNR WERKS CHARG LGORT CHANGING UNREST_KG UNREST_ROLL QINSP_KG QINSP_ROLL BL_STOCK_KG BL_SR BL_REASON BL_COMMENT.

  SELECT SINGLE CLABS CINSM CSPEM
    INTO (UNREST_KG, QINSP_KG, BL_STOCK_KG)
    FROM MCHB
   WHERE MATNR EQ MATNR AND
         WERKS EQ WERKS AND
         LGORT EQ LGORT AND
         CHARG EQ CHARG.

  IF UNREST_KG IS NOT INITIAL.
    UNREST_ROLL = 1.
  ENDIF.

  IF QINSP_KG IS NOT INITIAL.
    QINSP_ROLL = 1.
  ENDIF.

  IF BL_STOCK_KG IS NOT INITIAL.
    BL_SR = 1.

    SELECT SGTXT INTO BL_REASON
      FROM MSEG
     WHERE CHARG EQ CHARG
       AND BWART = '344'.
    ENDSELECT.

    SPLIT BL_REASON AT '_' INTO BL_REASON BL_COMMENT.
  ENDIF.
ENDFORM.                    "GET_BLOCKED_STOCK

*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_JR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ROLL       text
*      -->MATNR      text
*      -->CHARG      text
*----------------------------------------------------------------------*
FORM GET_BATCH_JR USING CHARG_S CHANGING MATNR CHARG.
  CALL FUNCTION 'ZQM_GET_BATCH_JR_BY_SR'
    EXPORTING
      CHARG_S = CHARG_S
    IMPORTING
      MATNR_J = MATNR
      CHARG_J = CHARG.

*  CLEAR: V_LINE, V_CODE, V_MOYE, V_SEQ, V_GRADE, V_DMS, V_DSS, V_PMS, V_PSS, V_TEMP.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*    EXPORTING
*      INPUT  = 'ZZNOMORROLL'
*    IMPORTING
*      OUTPUT = V_ATINN.
*
*  SPLIT ROLL AT SPACE INTO V_LINE V_CODE V_MOYE V_SEQ V_GRADE V_DMS V_PMS V_DSS V_PSS.
*
*  "For JR
*  CONCATENATE V_LINE V_CODE V_MOYE V_SEQ INTO ROLL_JR SEPARATED BY SPACE.
*
*  SELECT MATNR CHARG
*    INTO (MATNR, CHARG)
*    FROM MCH1
*    JOIN AUSP ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
*   WHERE AUSP~ATWRT = ROLL_JR
*     AND MCH1~FVDT1 = '00000000'
*     AND AUSP~KLART = '023'
*     AND AUSP~MAFID = 'O'
*     AND AUSP~ATINN = V_ATINN.
*  ENDSELECT.
ENDFORM.                    "GET_BATCH_JR

*&---------------------------------------------------------------------*
*&      Form  GET_UD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PRUEFLOS_R text
*      -->PRUEFLOS_C text
*      -->PRUEFLOS_L text
*      -->BARRIER_R  text
*      -->BARRIER_C  text
*      -->BARRIER_L  text
*----------------------------------------------------------------------*
FORM GET_UD USING CHARG CHANGING PRUEFLOS_R PRUEFLOS_C PRUEFLOS_L BARRIER_R BARRIER_C BARRIER_L DATETIME_R DATETIME_C DATETIME_L.
  REFRESH: IT_SR_DATA.
  CLEAR: IT_SR_DATA, V_CHARG.

  CALL FUNCTION 'ZQM_GET_BATCH_SR_BY_JR'
    EXPORTING
      CHARGJR = CHARG
    TABLES
      T_SR    = IT_SR_DATA.

  READ TABLE IT_SR_DATA WITH KEY GRADE = '1' ABLAD = 'MS'.
  IF SY-SUBRC EQ 0.
    SELECT QALS~PRUEFLOS VCODE KTEXTLOS VAEDATUM VEZEITAEN
      INTO (V_PRUEFLOS, V_VCODE, V_KTEXTLOS, V_DATE, V_TIME)
      FROM QALS
      JOIN QAVE ON QAVE~PRUEFLOS EQ QALS~PRUEFLOS
       WHERE CHARG = IT_SR_DATA-CHARG
       AND ART       EQ 'ZE04'
       AND HERKUNFT  EQ '05'
       AND ( KTEXTLOS LIKE '|R|%'   OR KTEXTLOS LIKE '|C|%'    OR KTEXTLOS LIKE '|L|%' ).

      SELECT COUNT(*)
        INTO V_CANCELLED
        FROM JEST
        JOIN QALS   ON JEST~OBJNR = QALS~OBJNR
        JOIN TJ02T  ON JEST~STAT  = TJ02T~ISTAT
       WHERE QALS~PRUEFLOS = V_PRUEFLOS
         AND TJ02T~TXT04 EQ 'LTCA'
         AND TJ02T~SPRAS EQ 'E'.

      IF V_KTEXTLOS EQ '|R|' AND SY-SUBRC NE 0.
        PRUEFLOS_R = V_PRUEFLOS.
        BARRIER_R  = V_VCODE.
        CONCATENATE V_DATE V_TIME INTO DATETIME_R.
      ELSEIF V_KTEXTLOS EQ '|C|' AND SY-SUBRC NE 0.
        PRUEFLOS_C = V_PRUEFLOS.
        BARRIER_C  = V_VCODE.
        CONCATENATE V_DATE V_TIME INTO DATETIME_C.
      ELSEIF V_KTEXTLOS EQ '|L|' AND SY-SUBRC NE 0.
        PRUEFLOS_L = V_PRUEFLOS.
        BARRIER_L  = V_VCODE.
        CONCATENATE V_DATE V_TIME INTO DATETIME_L.
      ENDIF.
      CLEAR: V_PRUEFLOS, V_VCODE, V_KTEXTLOS, V_DATE, V_TIME.
    ENDSELECT.
  ENDIF.
ENDFORM.                    "GET_UD

*&---------------------------------------------------------------------*
*&      Form  GET_APPROVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PRUEFLOS_R text
*      -->PRUEFLOS_C text
*      -->PRUEFLOS_L text
*      -->ERR        text
*      -->ZSTAT      text
*      -->MESS       text
*----------------------------------------------------------------------*
FORM GET_APPROVAL USING BARRIER_POS PRUEFLOS_R PRUEFLOS_C PRUEFLOS_L CHANGING ERR ZSTAT MESS.
  IF BARRIER_POS CS 'R'.
    CLEAR: V_VCODE, V_TIMES.
    SELECT VCODE PROBENR
      INTO (V_VCODE, V_TIMES)
      FROM QAPP
     WHERE PRUEFLOS EQ PRUEFLOS_R
     ORDER BY PROBENR.
    ENDSELECT.

    IF V_VCODE+0(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_R '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for R Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_R '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for R Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+0(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_R '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for R Position not approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_R '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for R Position not approved...!'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF BARRIER_POS CS 'C'.
    CLEAR: V_VCODE, V_TIMES.
    SELECT VCODE PROBENR
      INTO (V_VCODE, V_TIMES)
      FROM QAPP
     WHERE PRUEFLOS EQ PRUEFLOS_C
     ORDER BY PROBENR.
    ENDSELECT.

    IF V_VCODE+0(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_C '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for C Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_C '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for C Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+0(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_C '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for C Position not approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_C '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for C Position not approved...!'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF BARRIER_POS CS 'L'.
    CLEAR: V_VCODE, V_TIMES.
    SELECT VCODE PROBENR
      INTO (V_VCODE, V_TIMES)
      FROM QAPP
     WHERE PRUEFLOS EQ PRUEFLOS_L
     ORDER BY PROBENR.
    ENDSELECT.

    IF V_VCODE+0(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_L '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for L Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NO.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_L '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for L Position not yet approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+0(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_L '%MVTR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'MVTR for L Position not approved...!'.
      ENDIF.
    ENDIF.

    IF V_VCODE+2(2) EQ V_NG.
      CLEAR: V_ERR.
      PERFORM CHECK_QASE_PERTIMES USING PRUEFLOS_L '%O2TR%' V_TIMES CHANGING V_ERR.
      IF V_ERR IS INITIAL.
        ERR   = 'X'.
        MESS  = 'OTR for L Position not approved...!'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "GET_APPROVAL

*&---------------------------------------------------------------------*
*&      Form  CHECK_QASE_PERTIMES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PRUEFLOS   text
*      -->INSPECTION text
*      -->TIMES      text
*      -->V_ERR      text
*----------------------------------------------------------------------*
FORM CHECK_QASE_PERTIMES USING PRUEFLOS INSPECTION TIMES CHANGING ERR.
  CLEAR: IT_QASE.
  REFRESH: IT_QASE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_QASE
    FROM QASE
    JOIN QAMV ON QASE~PRUEFLOS EQ QAMV~PRUEFLOS AND QASE~MERKNR EQ QAMV~MERKNR
   WHERE QASE~PRUEFLOS EQ    PRUEFLOS
     AND VERWMERKM     LIKE  INSPECTION
     AND PROBENR       EQ    TIMES.

  IF SY-SUBRC NE 0.
    ERR = 'X'.
  ENDIF.
ENDFORM.                    "CHECK_QASE_PERTIMES
*&---------------------------------------------------------------------*
*&      Form  GET_JUDGEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR         text
*      -->CHARG         text
*      -->JUDGEMENT     text
*      -->NCR_APPROVAL  text
*      -->CAN_BE_SHIP   text
*      -->NO_PO         text
*----------------------------------------------------------------------*
FORM GET_JUDGEMENT USING MATNR CHARG DATETIME_R DATETIME_C DATETIME_L CHANGING JUDGEMENT NCR_APPROVAL CAN_BE_SHIP DATETIME.
  "Check Barrier
  CLEAR: V_DATE, V_TIME, IT_JUDGEMENT.
  REFRESH: IT_JUDGEMENT.

  SELECT *
     INTO CORRESPONDING FIELDS OF TABLE IT_JUDGEMENT
     FROM ZLOG_BARRIER
    WHERE MATNR    EQ ITAB-MATNR
      AND CHARG    EQ ITAB-CHARG
      AND DELETION EQ ''.

  LOOP AT IT_JUDGEMENT.
    CONCATENATE IT_JUDGEMENT-CPUDT IT_JUDGEMENT-CPUTM INTO DATETIME.

    IF DATETIME GE DATETIME_R AND DATETIME GE DATETIME_C AND DATETIME GE DATETIME_L.
      JUDGEMENT     = IT_JUDGEMENT-JUDGEMENT.
      NCR_APPROVAL  = IT_JUDGEMENT-NCRAPPROVAL.
      CAN_BE_SHIP   = IT_JUDGEMENT-CANBESHIP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "GET_JUDGEMENT

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
*&      Form  INSERT_BARRIER_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR        text
*      -->CHARG        text
*      -->BARRIER_POS  text
*----------------------------------------------------------------------*
FORM INSERT_BARRIER_POS USING MATNR CHARG BARRIER_POS.
  CLEAR: V_NAME, THEAD, TLINE.
  REFRESH: TLINE.

  V_NAME+0(10)    = MATNR.
  V_NAME+22(10)   = CHARG.

  THEAD-TDID      = 'VERM'.
  THEAD-TDSPRAS   = SY-LANGU.
  THEAD-TDNAME    = V_NAME.
  THEAD-TDOBJECT  = 'CHARGE'.

  "Set data
  TLINE-TDFORMAT  = '*'.
  TLINE-TDLINE    = BARRIER_POS.
  CONDENSE TLINE-TDLINE NO-GAPS.
  APPEND TLINE.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = THEAD
      SAVEMODE_DIRECT = 'X'
    TABLES
      LINES           = TLINE
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBIECT          = 4
      OTHERS          = 5.
ENDFORM.                    "INSERT_BARRIER_POS

*&---------------------------------------------------------------------*
*&      Form  INSERT_JUDGEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR      text
*      -->CHARG      text
*      -->JUDGEMENT  text
*----------------------------------------------------------------------*
FORM INSERT_JUDGEMENT USING MATNR CHARG JUDGEMENT.
  CLEAR: WA_JUDGEMENT.

  SELECT * INTO CORRESPONDING FIELDS OF WA_JUDGEMENT
    FROM ZLOG_BARRIER
   WHERE MATNR    EQ MATNR
     AND CHARG    EQ CHARG
     AND DELETION EQ ''.
  ENDSELECT.

  IF SY-SUBRC EQ 0.
    WA_JUDGEMENT-DELETION   = 'X'.
    WA_JUDGEMENT-AEDAT      = SY-DATUM.
    WA_JUDGEMENT-PSOTM      = SY-UZEIT.
    WA_JUDGEMENT-AENAM      = SY-UNAME.

    CALL FUNCTION 'TERMINAL_ID_GET'
      EXPORTING
        USERNAME = SY-UNAME
      IMPORTING
        TERMINAL = WA_JUDGEMENT-TERM2.

    MODIFY ZLOG_BARRIER FROM WA_JUDGEMENT.
    COMMIT WORK AND WAIT.
  ENDIF.

  CLEAR: WA_JUDGEMENT-AEDAT, WA_JUDGEMENT-PSOTM, WA_JUDGEMENT-AENAM, WA_JUDGEMENT-TERM2.

  "Then Insert
  WA_JUDGEMENT-MATNR      = MATNR.
  WA_JUDGEMENT-CHARG      = CHARG.
  WA_JUDGEMENT-JUDGEMENT  = JUDGEMENT.
  WA_JUDGEMENT-DELETION   = ''.
  WA_JUDGEMENT-CPUDT      = SY-DATUM.
  WA_JUDGEMENT-CPUTM      = SY-UZEIT.
  WA_JUDGEMENT-USNAM      = SY-UNAME.

  CALL FUNCTION 'TERMINAL_ID_GET'
    EXPORTING
      USERNAME = SY-UNAME
    IMPORTING
      TERMINAL = WA_JUDGEMENT-TERM1.

  ADD 1 TO WA_JUDGEMENT-VERSION.

  PERFORM CONVERSION_INPUT USING WA_JUDGEMENT-VERSION CHANGING WA_JUDGEMENT-VERSION.

  INSERT ZLOG_BARRIER FROM WA_JUDGEMENT.
  COMMIT WORK AND WAIT.
ENDFORM.                    "INSERT_JUDGEMENT

*&---------------------------------------------------------------------*
*&      Form  GET_MVTR_OTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BARRIER_POS  text
*      -->PRUEFLOS_R   text
*      -->PRUEFLOS_C   text
*      -->PRUEFLOS_L   text
*      -->MVTR_R       text
*      -->OTR_R        text
*      -->MVTR_C       text
*      -->OTR_C        text
*      -->MVTR_L       text
*      -->OTR_L        text
*----------------------------------------------------------------------*
FORM GET_MVTR_OTR USING BARRIER_POS PRUEFLOS_R PRUEFLOS_C PRUEFLOS_L BARRIER_R BARRIER_C BARRIER_L CHANGING DEVICE MVTR_R OTR_R TIMES_R MVTR_C OTR_C TIMES_C MVTR_L OTR_L TIMES_L TIMES TIMES_NOT_PAS.
  CLEAR: IT_QASE, IT_MVTR, IT_OTR, V_COUNT.
  REFRESH: IT_QASE, IT_MVTR, IT_OTR.

  IF BARRIER_POS CS 'R'.
    PERFORM GET_LAST_QASE USING PRUEFLOS_R CHANGING DEVICE MVTR_R OTR_R TIMES_R.
    V_COUNT = ITAB-TIMES_R.
    TIMES = V_COUNT.
    CONDENSE TIMES NO-GAPS.

    IF BARRIER_R NE V_PASS.
      TIMES_NOT_PAS = V_COUNT.
    ENDIF.
  ELSE.
    MVTR_R = '-'.
    OTR_R  = '-'.
  ENDIF.

  IF BARRIER_POS CS 'C'.
    PERFORM GET_LAST_QASE USING PRUEFLOS_C CHANGING DEVICE MVTR_C OTR_C TIMES_C.
    V_COUNT = ITAB-TIMES_C.
    IF TIMES IS INITIAL.
      TIMES = V_COUNT.
    ELSE.
      TIMES = TIMES && '|' && V_COUNT.
    ENDIF.
    CONDENSE TIMES NO-GAPS.
    IF BARRIER_C NE V_PASS.
      IF V_COUNT LT TIMES_NOT_PAS OR TIMES_NOT_PAS IS INITIAL.
        TIMES_NOT_PAS = V_COUNT.
      ENDIF.
    ENDIF.

  ELSE.
    MVTR_C = '-'.
    OTR_C  = '-'.
  ENDIF.

  IF BARRIER_POS CS 'L'.
    PERFORM GET_LAST_QASE USING PRUEFLOS_L CHANGING DEVICE MVTR_L OTR_L TIMES_L.
    V_COUNT = ITAB-TIMES_L.
    IF TIMES IS INITIAL.
      TIMES = V_COUNT.
    ELSE.
      TIMES = TIMES && '|' && V_COUNT.
    ENDIF.
    CONDENSE TIMES NO-GAPS.
    IF V_COUNT LT TIMES_NOT_PAS OR TIMES_NOT_PAS IS INITIAL.
      TIMES_NOT_PAS = V_COUNT.
    ENDIF.
  ELSE.
    MVTR_L = '-'.
    OTR_L  = '-'.
  ENDIF.
ENDFORM.                    "GET_MVTR_OTR

*&---------------------------------------------------------------------*
*&      Form  GET_LAST_QASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PRUEFLOS   text
*      -->MVTR       text
*      -->OTR        text
*----------------------------------------------------------------------*
FORM GET_LAST_QASE USING PRUEFLOS CHANGING DEVICE MVTR OTR TIMES.
  CLEAR: IT_QASE, IT_MVTR, IT_OTR, V_MVTR, V_OTR, V_TIMES.
  REFRESH: IT_QASE, IT_MVTR, IT_OTR.

  "Get Data MVTR and OTR
  SELECT QASE~PRUEFLOS QASE~MERKNR VERWMERKM PROBENR STUECKNR MESSWERT MBEWERTG ATTRIBUT PRUEFBEMKT
    INTO CORRESPONDING FIELDS OF TABLE IT_QASE
    FROM QASE
    JOIN QAMV ON QAMV~PRUEFLOS EQ QASE~PRUEFLOS AND QAMV~VORGLFNR EQ QASE~VORGLFNR AND QAMV~MERKNR EQ QASE~MERKNR
   WHERE QASE~PRUEFLOS EQ PRUEFLOS.

  "Sort Data Recording to MVTR and OTR
  DELETE IT_QASE WHERE ATTRIBUT IS NOT INITIAL. "Deletion
  IT_MVTR[] = IT_QASE[].
  IT_OTR[]  = IT_QASE[].

  DELETE IT_MVTR WHERE VERWMERKM NS 'MVTR'.
  DELETE IT_OTR  WHERE VERWMERKM NS 'OTR' AND VERWMERKM NS 'O2TR'.

  "Sorting By Times and Cycle
  SORT IT_MVTR BY PROBENR DESCENDING STUECKNR DESCENDING.
  SORT IT_OTR  BY PROBENR DESCENDING STUECKNR DESCENDING.

  READ TABLE IT_MVTR INDEX 1.
  IF SY-SUBRC EQ 0.
    V_MVTR   = IT_MVTR-MESSWERT.
    MVTR     = V_MVTR.
    V_TIMES  = IT_MVTR-PROBENR.

    IF IT_MVTR-PRUEFBEMKT IS NOT INITIAL.
      DEVICE   = IT_MVTR-PRUEFBEMKT.
    ENDIF.
  ENDIF.

  READ TABLE IT_OTR INDEX 1.
  IF SY-SUBRC EQ 0.
    V_OTR    = IT_OTR-MESSWERT.
    OTR      = V_OTR.
    TIMES    = IT_OTR-PROBENR.

    IF IT_OTR-PRUEFBEMKT IS NOT INITIAL.
      DEVICE   = IT_OTR-PRUEFBEMKT.
    ENDIF.
  ENDIF.

  IF V_TIMES GT TIMES.
    TIMES = V_TIMES.
  ENDIF.
ENDFORM.                    "GET_MVTR_OTR

*&---------------------------------------------------------------------*
*&      Form  GET_SHIPMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BL_STOCK_KG   text
*      -->JUDGEMENT     text
*      -->NCR_APPROVAL  text
*      -->CAN_BE_SHIP   text
*----------------------------------------------------------------------*
FORM GET_SHIPMENT USING BL_STOCK_KG JUDGEMENT NCR_APPROVAL CHANGING CAN_BE_SHIP.
  CLEAR: CAN_BE_SHIP.

  IF BL_STOCK_KG IS NOT INITIAL.
    BLOCKED_STATUS = 'Blocked'.
  ELSE.
    BLOCKED_STATUS = 'Not Blocked'.
  ENDIF.

  READ TABLE IT_RANK WITH KEY ALIAS = JUDGEMENT.
  IF SY-SUBRC EQ 0.
    READ TABLE IT_SHIPMENT WITH KEY TEXT1 = BLOCKED_STATUS TEXT2 = IT_RANK-VCODE TEXT3 = NCR_APPROVAL.
    IF SY-SUBRC EQ 0.
      CAN_BE_SHIP = IT_SHIPMENT-TEXT4.
    ENDIF.
  ELSE.
    READ TABLE IT_SHIPMENT WITH KEY TEXT1 = BLOCKED_STATUS TEXT2 = JUDGEMENT TEXT3 = NCR_APPROVAL.
    IF SY-SUBRC EQ 0.
      CAN_BE_SHIP = IT_SHIPMENT-TEXT4.
    ENDIF.
  ENDIF.

  CLEAR: WA_JUDGEMENT.

  SELECT * INTO CORRESPONDING FIELDS OF WA_JUDGEMENT
    FROM ZLOG_BARRIER
   WHERE MATNR    EQ ITAB-MATNR
     AND CHARG    EQ ITAB-CHARG
     AND DELETION EQ ''.
  ENDSELECT.

  IF SY-SUBRC EQ 0.
    WA_JUDGEMENT-CANBESHIP    = CAN_BE_SHIP.
    WA_JUDGEMENT-AEDAT        = SY-DATUM.
    WA_JUDGEMENT-PSOTM        = SY-UZEIT.
    WA_JUDGEMENT-AENAM        = SY-UNAME.

    CALL FUNCTION 'TERMINAL_ID_GET'
      EXPORTING
        USERNAME = SY-UNAME
      IMPORTING
        TERMINAL = WA_JUDGEMENT-TERM2.

    MODIFY ZLOG_BARRIER FROM WA_JUDGEMENT.
    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " GET_SHIPMENT

*&---------------------------------------------------------------------*
*&      Form  REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH.
  LOOP AT ITAB.

    IF ITAB-ZSTAT IS INITIAL.
      ITAB-ZSTAT = GREY.
    ENDIF.

    MODIFY ITAB.
    CLEAR ITAB.
  ENDLOOP.
ENDFORM.                    "REFRESH

*&---------------------------------------------------------------------*
*&      Form  GENERATE_COLUMN_COLOUR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->JUDGEMENT  text
*----------------------------------------------------------------------*
FORM GENERATE_COLUMN_COLOUR USING COLUMN JUDGEMENT.
  CLEAR: CELL_COLOUR.

  CONDENSE JUDGEMENT NO-GAPS.

  READ TABLE IT_RANK WITH KEY VCODE = JUDGEMENT.
  IF SY-SUBRC EQ 0.
    CELL_COLOUR =  IT_RANK-COLOR.
  ELSE.
    READ TABLE IT_RANK WITH KEY ALIAS = JUDGEMENT.
    IF SY-SUBRC EQ 0.
      CELL_COLOUR =  IT_RANK-COLOR.
    ENDIF.
  ENDIF.

*  IF JUDGEMENT EQ V_PASS.
*    CELL_COLOUR     = 5.
*  ELSEIF JUDGEMENT EQ V_NCR.
*    CELL_COLOUR     = 3.
*  ELSEIF JUDGEMENT EQ V_FAIL OR JUDGEMENT EQ V_SCRAP.
*    CELL_COLOUR     = 6.
*  ENDIF.

  IF CELL_COLOUR IS NOT INITIAL.
    PERFORM SET_CELL_COLOURS TABLES ITAB-CELL_COLOR USING COLUMN CELL_COLOUR.
  ENDIF.
ENDFORM.                    "GENERATE_COLUMN_COLOUR

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
    'ZSTAT'           'X' 'X'  '' '8'    'Status'                '' '' '' '',
    'MATNR'           'X' 'X'  '' '8'    'Material'              '' '' '' '',
    'WERKS'           ''  'X'  '' '4'    'Plant'                 '' '' '' '',
    'LGORT'           ''  'X'  '' '4'    'Sloc'                  '' '' '' '',
    'CHARG'           ''  'X'  '' '10'   'Batch'                 '' '' '' '',
    'TYPE'            ''  ''   '' '7'    'Type'                  '' '' '' '',
    'THICKNESS'       ''  ''   '' '4'    'Thick'                 '' '' '' '',
    'WIDTH'           ''  ''   '' '4'    'Width'                 '' '' '' '',
    'LENGTH'          ''  ''   '' '6'    'Length'                '' '' '' '',
    'BL_STOCK_KG'     ''  ''   '' '10'   'Blocked Stock (KG)'    '' '' '' '',
    'BL_SR'           ''  ''   '' '5'    'Blocked (SR)'          '' '' '' '',
    'BL_REASON'       ''  ''   '' '15'   'Blocked Reason'        '' '' '' '',
    'BL_COMMENT'      ''  ''   '' '30'   'Blocked Comment'       '' '' '' '',
    'ROLL_DERV'       ''  ''   '' '15'   'No Roll & Derivitive'  '' '' '' '',
    'DERIVITIVE'      ''  ''   '' '6'    'Derivative'            '' '' '' '',
    'POSITION'        ''  ''   '' '6'    'Position'              '' '' '' '',
*    'DEVICE'          ''  ''   '' '10'   'Device'              '' '' '' '',
    'BARRIER_POS'     ''  ''   '' '12'   'Barrier Position'      '' '' '' '',
    'TIMES'           ''  ''   '' '6'    'Times'                 '' '' '' '',
    'BARRIER_R'       ''  ''   '' '13'   'Barrier Result R'      '' '' '' '',
    'BARRIER_C'       ''  ''   '' '13'   'Barrier Result C'      '' '' '' '',
    'BARRIER_L'       ''  ''   '' '13'   'Barrier Result L'      '' '' '' '',
    'JUDGEMENT'       ''  ''   '' '10'   'Judgement'             '' '' '' '',
    'NCR_APPROVAL'    ''  ''   '' '15'   'NCR Approval'          '' '' '' '',
    'MVTR_R'          ''  ''   '' '10'   'MVTR-R'                '' '' '' '',
    'MVTR_C'          ''  ''   '' '10'   'MVTR-C'                '' '' '' '',
    'MVTR_L'          ''  ''   '' '10'   'MVTR-L'                '' '' '' '',
    'OTR_R'           ''  ''   '' '10'   'OTR-R'                 '' '' '' '',
    'OTR_C'           ''  ''   '' '10'   'OTR-C'                 '' '' '' '',
    'OTR_L'           ''  ''   '' '10'   'OTR-L'                 '' '' '' '',
    'MESS'            ''  ''   '' '50'   'Message'               '' '' '' ''.

  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
    'COMB_NO'          ''  ''  'X' '10'   'Comb. No'           '' '' '' '',
    'PACKING'          ''  ''  'X' '10'   'Packing'            '' '' '' '',
    'TREATMENT'        ''  ''  'X' '20'   'Treatment'          '' '' '' '',
    'CORE'             ''  ''  'X' '10'   'Core'               '' '' '' '',
    'GRADE'            ''  ''  'X' '10'   'Grade'              '' '' '' '',
    'KATEGORI'         ''  ''  'X' '5'    'Kategori'           '' '' '' '',
    'CRITERIA'         ''  ''  'X' '8'    'Criteria'           '' '' '' '',
    'ALIAS'            ''  ''  'X' '10'   'Tipe Alias'         '' '' '' '',
    'UNREST_KG'        ''  ''  'X' '15'   'Unrest (Kg)'        '' '' '' '',
    'UNREST_ROLL'      ''  ''  'X' '15'   'Unrest (Roll)'      '' '' '' '',
    'QINSP_KG'         ''  ''  'X' '15'   'QI (Kg)'            '' '' '' '',
    'QINSP_ROLL'       ''  ''  'X' '15'   'QI (Roll)'          '' '' '' '',
    'TIPE_LABEL'       ''  ''  'X' '6'    'Label'              '' '' '' '',
    'EXPIRED_DATE'     ''  ''  'X' '8'    'Expired Date'       '' '' '' '',
    'PROD_DATE'        ''  ''  'X' '8'    'Production Date'    '' '' '' '',
    'GR_DATE'          ''  ''  'X' '8'    'GR Date'            '' '' '' '',
    'SPECIAL_TOUCH'    ''  ''  'X' '8'    'Special Touch-1'    '' '' '' '',
    'VENDOR_BATCH'     ''  ''  'X' '15'   'Vendor Batch'       '' '' '' '',
    'PRODUCTION_NUM'   ''  ''  'X' '20'   'Production Number'  '' '' '' '',
    'NO_ROL_TOYOBO'    ''  ''  'X' '10'   'No Rol Toyobo'      '' '' '' '',
    'NO_LOT_TOYOBO'    ''  ''  'X' '10'   'No Lot Toyobo'      '' '' '' '',
    'NO_ROL_MOS'       ''  ''  'X' '10'   'No Rol MOS-T-SS'    '' '' '' ''.


  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME EQ 'CHARG'
                                            OR FIELDNAME EQ 'BL_STOCK_KG'
                                            OR FIELDNAME EQ 'BL_SR'
                                            OR FIELDNAME EQ 'UNREST_KG'
                                            OR FIELDNAME EQ 'UNREST_ROLL'
                                            OR FIELDNAME EQ 'QINSP_KG'
                                            OR FIELDNAME EQ 'QINSP_ROLL'
                                            OR FIELDNAME EQ 'DERIVITIVE'
                                            OR FIELDNAME EQ 'POSITION'.

  T_FIELDCAT-JUST = 'C'.
  MODIFY T_FIELDCAT TRANSPORTING JUST WHERE FIELDNAME NE 'MESS'.

  T_FIELDCAT-FIX_COLUMN = ''.
  MODIFY T_FIELDCAT TRANSPORTING FIX_COLUMN WHERE FIELDNAME NE 'MATNR'
                                              AND FIELDNAME NE 'WERKS'
                                              AND FIELDNAME NE 'LGORT'
                                              AND FIELDNAME NE 'CHARG'
                                              AND FIELDNAME NE 'LGPLA'
                                              AND FIELDNAME NE 'EXIDV'
                                              AND FIELDNAME NE 'TYPE'.

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
      PERFORM GET_DATA_BARU.
    WHEN 'EXEC'.
*      PERFORM COLLECT_DATA.
      PERFORM CONFIRMATION.
      PERFORM APPROVAL.
      PERFORM REFRESH.
      PERFORM CHECK_ERROR.
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

*&---------------------------------------------------------------------*
*&      Form  APPROVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPROVAL.
  LOOP AT ITAB WHERE BOX EQ 'X' AND ERR EQ ''.
    CLEAR: WA_JUDGEMENT.

    SELECT * INTO CORRESPONDING FIELDS OF WA_JUDGEMENT
      FROM ZLOG_BARRIER
     WHERE MATNR    EQ ITAB-MATNR
       AND CHARG    EQ ITAB-CHARG
       AND DELETION EQ ''.
    ENDSELECT.

    IF SY-SUBRC EQ 0.
      WA_JUDGEMENT-NCRAPPROVAL  = ITAB-NCR_APPROVAL.
      WA_JUDGEMENT-AEDAT        = SY-DATUM.
      WA_JUDGEMENT-PSOTM        = SY-UZEIT.
      WA_JUDGEMENT-AENAM        = SY-UNAME.

      CALL FUNCTION 'TERMINAL_ID_GET'
        EXPORTING
          USERNAME = SY-UNAME
        IMPORTING
          TERMINAL = WA_JUDGEMENT-TERM2.

      MODIFY ZLOG_BARRIER FROM WA_JUDGEMENT.

      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ITAB-ZSTAT = ERROR.
        ITAB-MESS  = 'Upload NCR Failed..!'.
        ITAB-ERR   = 'X'.
      ENDIF.
    ELSE.
      ITAB-ZSTAT = ERROR.
      ITAB-MESS  = 'NCR Data ZLOG not found..!'.
      ITAB-ERR   = 'X'.
    ENDIF.

    MODIFY ITAB.
    CLEAR ITAB.
  ENDLOOP.
ENDFORM.                    "APPROVAL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_PREVIEW USING FT_EXTAB TYPE SLIS_T_EXTAB.

  SET PF-STATUS 'PASS_FAIL' EXCLUDING 'REFRESH'.
  SET TITLEBAR  'NCR_UPLOAD'.
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
*&      Form  GET_DETAIL_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR      text
*      -->CHARG      text
*      -->ATNAM      text
*      -->VALUE      text
*----------------------------------------------------------------------*
FORM GET_DETAIL_CHARACTERISTIC USING MATNR CHARG ATNAM CHANGING VALUE.
  DATA: V_ATWRT TYPE ATWRT,
        V_ATFLV TYPE ATFLV,
        V_ATINN TYPE ATINN.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = ATNAM.

  SELECT SINGLE ATWRT ATFLV INTO (V_ATWRT, V_ATFLV)
    FROM MCH1
    JOIN AUSP ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
   WHERE MATNR EQ MATNR
     AND CHARG EQ CHARG
     AND ATINN EQ V_ATINN.

  IF V_ATFLV IS NOT INITIAL.
    VALUE = V_ATFLV.
  ELSE.
    VALUE = V_ATWRT.
  ENDIF.
ENDFORM.                    "GET_DETAIL_CHARACTERISTIC

*&---------------------------------------------------------------------*
*&      Form  GET_DESCRIPTION_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR      text
*      -->CHARG      text
*      -->ATNAM      text
*      -->VALUE      text
*----------------------------------------------------------------------*
FORM GET_DESCRIPTION_CHARACTERISTIC USING MATNR CHARG ATNAM CHANGING VALUE.
  DATA: V_ATINN TYPE ATINN.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = ATNAM.

  SELECT SINGLE ATWTB INTO VALUE
    FROM MCH1
    JOIN AUSP  ON AUSP~OBJEK EQ MCH1~CUOBJ_BM
    JOIN CAWN  ON CAWN~ATINN EQ AUSP~ATINN AND CAWN~ATWRT EQ AUSP~ATWRT
    JOIN CAWNT ON CAWNT~ATINN EQ CAWN~ATINN AND CAWNT~ATZHL EQ CAWN~ATZHL
   WHERE MATNR EQ MATNR
     AND CHARG EQ CHARG
     AND AUSP~ATINN EQ V_ATINN.
ENDFORM.                    "GET_DESCRIPTION_CHARACTERISTIC

*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR         text
*      -->CHARG         text
*      -->PROD_DATE     text
*      -->GR_DATE       text
*      -->EXPIRED_DATE  text
*----------------------------------------------------------------------*
FORM GET_DATE USING MATNR CHARG PROD_DATE CHANGING GR_DATE EXPIRED_DATE.
  CLEAR: V_COUNT.

  GR_DATE = PROD_DATE.

  READ TABLE IT_CHAR WITH KEY CHARG = CHARG ATINN = V_ZZEXPIREDLIVE.
  IF SY-SUBRC EQ 0.
    V_COUNT = IT_CHAR-ATFLV.
  ENDIF.

  EXPIRED_DATE = PROD_DATE + V_COUNT.
ENDFORM.                    "GET_DATE

*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR         text
*      -->CHARG         text
*      -->VENDOR_BATCH  text
*----------------------------------------------------------------------*
FORM GET_VENDOR_BATCH USING MATNR CHARG CHANGING VENDOR_BATCH.
  SELECT SINGLE LICHA INTO VENDOR_BATCH FROM MCH1 WHERE MATNR EQ MATNR AND CHARG EQ CHARG.
ENDFORM.                    "GET_VENDOR_BATCH
*&---------------------------------------------------------------------*
*&      Form  GET_PRODUCTION_NUMBER_TYB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR           text
*      -->CHARG           text
*      -->NO_ROL_TOYOBO   text
*      -->NO_LOT_TOYOBO   text
*      -->PRODUCTION_NUM  text
*----------------------------------------------------------------------*
FORM GET_PRODUCTION_NUMBER_TYB USING MATNR CHARG NO_ROL_TOYOBO NO_LOT_TOYOBO CHANGING PRODUCTION_NUM.
  CLEAR: V_DATE, V_CODE.
  CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
    EXPORTING
      MATNR = MATNR
      CHARG = CHARG
    IMPORTING
      PDATE = V_DATE.
  CONCATENATE V_DATE+3(1) V_DATE+4(2) INTO V_CODE.

  CONCATENATE V_CODE NO_ROL_TOYOBO NO_LOT_TOYOBO '000' INTO PRODUCTION_NUM.
ENDFORM.                    "GET_PRODUCTION_NUMBER_TYB
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
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.
  SET PF-STATUS 'MAIN200'.
  SET TITLEBAR 'MAIN200'.
ENDMODULE.                 " STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.
  CASE SY-UCOMM.
    WHEN 'BTN_CANCEL'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'BTN_SAVE'.
*      PERFORM SET_APPROVAL.
      PERFORM APPROVAL.
      PERFORM REFRESH.
      PERFORM CHECK_ERROR.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_2000  INPUT