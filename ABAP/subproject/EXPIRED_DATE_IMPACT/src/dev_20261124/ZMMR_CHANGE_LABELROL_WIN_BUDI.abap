*&---------------------------------------------------------------------*
*& Report ZMMR_CHANGE_LABELROL_WIN
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Change No Roll & Last GR
* Application Area - PP
* ABAPer           - Jarwo
* Date             - 24.08.2017
*----------------------------------------------------------------------*
* Amendment History                                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
* 002 | 03.06.21 | J. Budi     |            | KT&G Roll no and add JET *
*----------------------------------------------------------------------*

REPORT ZMMR_CHANGE_LABELROL_WIN.

INCLUDE ZABAPALV.

TABLES: MCHB.

DATA: IT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT   TYPE SLIS_FIELDCAT_ALV,
      IT_LAYOUT     TYPE SLIS_LAYOUT_ALV,
      T_SORTS       TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.

DATA: V_FORMNAME    TYPE TDSFNAME,
      V_FUNCNAME    TYPE RS38L_FNAM.

DATA: V_TAB         TYPE API_VALI OCCURS 0 WITH HEADER LINE.

DATA: CONTROL_PARAMETERS TYPE SSFCTRLOP,
      OUTPUT_OPTIONS     TYPE SSFCOMPOP.

TYPES: BEGIN OF TY_UPLOAD,
        CHARG       LIKE MSEG-CHARG,
        NOROLL      LIKE AUSP-ATWRT,
        LASTGR(10)  TYPE C,
        OLDNOROLL   LIKE AUSP-ATWRT,
        TYLABEL     LIKE AUSP-ATWRT,
        NMLABEL     LIKE AUSP-ATWRT,
        MATNR       LIKE MARA-MATNR,
        BOX(1),
      END OF TY_UPLOAD.

DATA: IT_UPLOAD TYPE TY_UPLOAD OCCURS 0 WITH HEADER LINE.

DATA: V_VBELN       LIKE MSKA-VBELN,
      V_POSNR       LIKE MSKA-POSNR,
      V_POSTDATE    LIKE MKPF-BUDAT,
      V_SYM         TYPE STRING,
      V_ROW         TYPE P,
      V_COPY        TYPE P,
      V_BLN(2)      TYPE C,
      V_THN(4)      TYPE C,
      V_USB(7)      TYPE C,
      V_SPLIT(10),
      VCODE(10).

DATA: ITAB LIKE ZLABEL_WINDOWS OCCURS 0 WITH HEADER LINE.

DATA: V_KTNGCODE    LIKE ZDETAIL_KTNG-KTNGCODE,
      V_COMPANY     LIKE ZDETAIL_KTNG-COMPANY,
      V_JRDATE      LIKE ZDETAIL_KTNG-JRDATE,
      V_JRNUMB      LIKE ZDETAIL_KTNG-JRNUMB,
      V_MIDROLL     LIKE ZDETAIL_KTNG-MIDROLL,
      V_SLITTMCN    LIKE ZDETAIL_KTNG-SLITT_MCHN,
      V_TS          LIKE ZDETAIL_KTNG-TS,
      V_PS          LIKE ZDETAIL_KTNG-PS.

DATA: V_ATNROL      LIKE CABN-ATINN,
      V_ATNLABEL    LIKE CABN-ATINN.

SELECTION-SCREEN BEGIN OF BLOCK UP1 WITH FRAME TITLE TEXT-100.
PARAMETERS: FILENAME LIKE RLGRAP-FILENAME DEFAULT 'D:\Documents\PT. Trias Sentosa\Kerjaan\Helpdesk\Label\zlabel90\TESZLABEL91.txt'.
PARAMETERS: P_COPIES TYPE N LENGTH 3 DEFAULT '1' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK UP1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILENAME.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'JAL:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = FILENAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.
  PERFORM UP_TEMPLATE.
  PERFORM GET_ROLL.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  up_template
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UP_TEMPLATE.
  DATA: FILENAME1 TYPE STRING.

  FILENAME1 = FILENAME.

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
    MESSAGE I000(0K) WITH 'File cannot be opened'.
    LEAVE TO SCREEN 0.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM IT_UPLOAD COMPARING CHARG.

ENDFORM.                    "up_template

*&---------------------------------------------------------------------*
*&      Form  get_roll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ROLL.
  SELECT SINGLE ATINN INTO V_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO V_ATNLABEL FROM CABN WHERE ATNAM = 'ZZLABEL'.

  LOOP AT IT_UPLOAD.
    SELECT SINGLE MATNR INTO IT_UPLOAD-MATNR FROM MCHA WHERE CHARG = IT_UPLOAD-CHARG.

    SELECT SINGLE  AUSP~ATWRT INTO IT_UPLOAD-OLDNOROLL
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = IT_UPLOAD-MATNR AND MCH1~CHARG = IT_UPLOAD-CHARG AND AUSP~ATINN = V_ATNROL.

    SELECT SINGLE  AUSP~ATWRT INTO IT_UPLOAD-TYLABEL
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = IT_UPLOAD-MATNR AND MCH1~CHARG = IT_UPLOAD-CHARG AND AUSP~ATINN = V_ATNLABEL.

    MODIFY IT_UPLOAD TRANSPORTING OLDNOROLL MATNR TYLABEL WHERE CHARG = IT_UPLOAD-CHARG.
  ENDLOOP.

  SORT IT_UPLOAD BY TYLABEL.
ENDFORM.                    "get_roll

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "f_display_alv

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_UPLOAD' :
   'CHARG'      '' ''  '' '15'  'Batch'           '' '' '' '',
   'MATNR'      '' ''  '' '25'  'Material'        '' ' ' '' '',
   'OLDNOROLL'  '' ''  '' '25'  'Old Roll'        '' ' ' '' '',
   'NOROLL'     '' ''  '' '25'  'New Roll'        '' ' ' '' '',
   'LASTGR'     '' ''  '' '10'  'GR Date'         '' ' ' '' '',
   'TYLABEL'    '' ''  '' '10'  'Label'           '' ' ' '' '' .

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG'.

  LOOP AT IT_UPLOAD WHERE NOROLL NE ''.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'OLDNOROLL'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'NOROLL'.
  ENDIF.

  LOOP AT IT_UPLOAD WHERE LASTGR NE ''.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'LASTGR'.
  ENDIF.
ENDFORM.                    "F_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    "F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.

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
      T_OUTTAB                 = IT_UPLOAD
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  CLEAR IT_UPLOAD.

ENDFORM.                    "F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_UCOMM     text
*      -->FU_SELFIELD  text
*----------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN 'PRINT'.
      PERFORM GET_DATA.
      PERFORM PRINT_DATA.
  ENDCASE.
  FU_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  get_data_A132
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  REFRESH: ITAB.
  CLEAR: ITAB.

  LOOP AT IT_UPLOAD WHERE BOX = 'X'.
    REFRESH: V_TAB.
    CLEAR: V_TAB, V_POSTDATE, VCODE.

    IF IT_UPLOAD-CHARG IS NOT INITIAL AND IT_UPLOAD-MATNR IS NOT INITIAL.
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = IT_UPLOAD-MATNR
          I_VAL_CHARGE   = IT_UPLOAD-CHARG
        TABLES
          T_VAL_TAB      = V_TAB
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.
    ENDIF.

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      CONCATENATE 'ZLABELROL_' V_TAB-ATWRT INTO V_FORMNAME.
      IT_UPLOAD-NMLABEL = V_TAB-ATWTB.
      MODIFY IT_UPLOAD.
    ENDIF.

    SELECT SINGLE VBELN POSNR INTO (ITAB-VVBELN, ITAB-VPOSNR)
      FROM MSKA
     WHERE MATNR = IT_UPLOAD-MATNR
       AND CHARG = IT_UPLOAD-CHARG
       AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

    IF SY-SUBRC = 0.
      IF IT_UPLOAD-NMLABEL CS 'Gudang Garam'.
        SELECT SINGLE KDMAT INTO ITAB-VPARTNO FROM VBAP WHERE VBELN = ITAB-VVBELN AND POSNR = ITAB-VPOSNR.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VVBELN
        IMPORTING
          OUTPUT = ITAB-VVBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VPOSNR
        IMPORTING
          OUTPUT = ITAB-VPOSNR.

      CONCATENATE ITAB-VVBELN ITAB-VPOSNR INTO ITAB-VSONUM_ITEM SEPARATED BY '/'.
    ENDIF.

    ITAB-VDERIVATIVEMS  = '00'.
    ITAB-VPOSITIONMS    = '00'.
    ITAB-VDERIVATIVESS  = '00'.
    ITAB-VPOSITIONSS    = '00'.

    LOOP AT V_TAB.
      IF V_TAB-ATNAM        = 'ZZDERIVATIVEMS'.
        ITAB-VDERIVATIVEMS  = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM    = 'ZZPOSITIONMS'.
        ITAB-VPOSITIONMS    = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM    = 'ZZDERIVATIVESS'.
        ITAB-VDERIVATIVESS  = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM    = 'ZZPOSITIONSS'.
        ITAB-VPOSITIONSS    = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM    = 'ZZGRADE'.
        ITAB-VGRADE         = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM    = 'ZZCODE'.
        IF IT_UPLOAD-NMLABEL CS 'Gudang Garam'.
          ITAB-VTYPE        = V_TAB-ATWTB.
        ELSEIF IT_UPLOAD-NMLABEL CS 'JET'.
          READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
          IF SY-SUBRC = 0.
            VCODE = V_TAB-ATWRT.
          ELSE.
            VCODE = V_TAB-ATWTB.
          ENDIF.
        ENDIF.
      ELSEIF V_TAB-ATNAM = 'ZZTYPE'.
        IF IT_UPLOAD-NMLABEL CS 'KT&G'.
          ITAB-VTYPE        = V_TAB-ATWTB.
        ENDIF.
      ELSEIF V_TAB-ATNAM    = 'ZZALIAS'.
        IF IT_UPLOAD-NMLABEL CS 'Gudang Garam'.
          ITAB-VTYPE        = V_TAB-ATWTB.
        ELSEIF IT_UPLOAD-NMLABEL CS 'KT&G'.
          SPLIT V_TAB-ATWTB AT '-' INTO ITAB-VTYPE V_SPLIT.
        ENDIF.
      ELSEIF V_TAB-ATNAM    = 'ZZWIDTH'.
        ITAB-VWIDTH         = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZLENGTH'.
        ITAB-VLENGTH        = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZCORE'.
        CONCATENATE V_TAB-ATWRT '"' INTO ITAB-VCORE.
      ELSEIF V_TAB-ATNAM    = 'ZZTHICKNESS'.
        ITAB-VTHICK         = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZNOMORROLL'.
        ITAB-VROLL          = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZCONVERSIONROLLKG'.
        WRITE V_TAB-ATFLV TO ITAB-VNWEIGHT EXPONENT 0 DECIMALS 2.
        CONDENSE ITAB-VNWEIGHT.
      ELSEIF V_TAB-ATNAM    = 'ZZINSIDE'.
        ITAB-VINSIDE        = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZOUTSIDE'.
        ITAB-VOUTSIDE       = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM    = 'ZZSPLICE-1'.
        IF IT_UPLOAD-NMLABEL CS 'Gudang Garam'.
          ITAB-VJOINT       = 'Y'.
        ELSEIF IT_UPLOAD-NMLABEL CS 'JET'.
          ITAB-VPARTNO      = V_TAB-ATWRT.
        ENDIF.
      ELSEIF V_TAB-ATNAM    = 'ZZEXPIREDLIVE'.
        ITAB-VLIVE          = V_TAB-ATWTB.
      ENDIF.
    ENDLOOP.

    CONCATENATE IT_UPLOAD-CHARG ITAB-VDERIVATIVEMS ITAB-VPOSITIONMS ITAB-VDERIVATIVESS  ITAB-VPOSITIONSS INTO ITAB-VBARCODETRIAS.

    CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
      EXPORTING
        INPUT          = ITAB-VBARCODETRIAS
      IMPORTING
        OUTPUT         = ITAB-VBARCODETRIAS
      EXCEPTIONS
        INVALID_FORMAT = 1
        OTHERS         = 2.

    CONCATENATE IT_UPLOAD-CHARG '-' ITAB-VBARCODETRIAS INTO ITAB-VBARCTEXTTRIAS.

    IF ITAB-VLIVE NE ''.
      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = IT_UPLOAD-MATNR
          CHARG = IT_UPLOAD-CHARG
        IMPORTING
          PDATE = V_POSTDATE.

      ITAB-VPOSTDATE = V_POSTDATE.
      IF SY-SUBRC = 0.
        ITAB-VEXPDATE = ITAB-VPOSTDATE + ITAB-VLIVE.
        CONCATENATE ITAB-VEXPDATE+0(4) '.' ITAB-VEXPDATE+4(2) INTO ITAB-VUSED.
      ENDIF.
    ENDIF.

    ITAB-VBATCH         = IT_UPLOAD-CHARG.

    READ TABLE IT_UPLOAD WITH KEY CHARG = IT_UPLOAD-CHARG.
    IF SY-SUBRC = 0 AND IT_UPLOAD-NOROLL NE ''.
      ITAB-VROLL          = IT_UPLOAD-NOROLL.
    ENDIF.

    READ TABLE IT_UPLOAD WITH KEY CHARG = IT_UPLOAD-CHARG.
    IF SY-SUBRC = 0 AND IT_UPLOAD-LASTGR NE ''.
      CLEAR: V_BLN,V_THN,V_USB.
      V_BLN = IT_UPLOAD-LASTGR+3(2).
      V_THN = IT_UPLOAD-LASTGR+6(4).
      CONCATENATE V_THN '.' V_BLN INTO V_USB.
      ITAB-VUSED          = V_USB.
    ENDIF.

    IF IT_UPLOAD-NMLABEL CS 'KT&G'.
      IF ITAB-VSONUM_ITEM NE ''.
        PERFORM GET_KTNG_NUMBER.
      ENDIF.
    ENDIF.

    IF IT_UPLOAD-NMLABEL CS 'JET'.
      IF ITAB-VPARTNO IS INITIAL.
        ITAB-VPARTNO = 'Ø'.
      ENDIF.
      IF VCODE IS NOT INITIAL.
        SELECT SINGLE SYMB1 FROM ZLABELSYMBOL INTO V_SYM WHERE FTYPE = VCODE.
      ENDIF.
    ENDIF.

    DO P_COPIES TIMES.
      APPEND ITAB.
    ENDDO.
    CLEAR: ITAB.
  ENDLOOP.
ENDFORM.                    "get_data_a132

*&---------------------------------------------------------------------*
*&      Form  GET_KTNG_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_KTNG_NUMBER.
  CLEAR: V_KTNGCODE, V_COMPANY, V_JRDATE, V_JRNUMB, V_MIDROLL, V_SLITTMCN, V_TS, V_PS, V_VBELN, V_POSNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ITAB-VVBELN
    IMPORTING
      OUTPUT = V_VBELN.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ITAB-VPOSNR
    IMPORTING
      OUTPUT = V_POSNR.

  SELECT SINGLE KTNGCODE COMPANY JRDATE JRNUMB MIDROLL SLITT_MCHN TS PS
    INTO (V_KTNGCODE, V_COMPANY, V_JRDATE, V_JRNUMB, V_MIDROLL, V_SLITTMCN, V_TS, V_PS)
    FROM ZDETAIL_KTNG
   WHERE SONUM    EQ V_VBELN
     AND SOITEM   EQ V_POSNR
     AND BATCH    EQ IT_UPLOAD-CHARG
     AND DELETION EQ ''.

  CONCATENATE V_KTNGCODE V_COMPANY V_JRDATE V_JRNUMB V_MIDROLL V_SLITTMCN V_TS V_PS INTO ITAB-VBARCTEXTCUST SEPARATED BY '-'.
  CONCATENATE V_KTNGCODE V_COMPANY V_JRDATE V_JRNUMB V_MIDROLL V_SLITTMCN V_TS V_PS '1' INTO ITAB-VBARCODECUST.
ENDFORM.                    "GET_KTNG_NUMBER


*&---------------------------------------------------------------------*
*&      Form  PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_DATA.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CLEAR: V_ROW.
  DESCRIBE TABLE ITAB LINES V_ROW.

  CONTROL_PARAMETERS-NO_DIALOG  = 'X'.
  CONTROL_PARAMETERS-PREVIEW    = 'X'.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
      V_ROW              = V_ROW
      V_COPY             = V_COPY
      V_SYM              = V_SYM
    TABLES
      ITAB               = ITAB.

ENDFORM.                    "PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    "F_GUI_STATUS