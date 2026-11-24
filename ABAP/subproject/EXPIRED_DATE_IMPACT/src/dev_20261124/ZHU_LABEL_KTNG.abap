*&---------------------------------------------------------------------*
*& Report      : ZHU_LABEL_KTNG                                        *
*&  Appl. Area : MM                                                    *
*&  Created by : Abdillah "afir" Firdaus                               *
*&  Created on : 15 January 2018                                       *
*&---------------------------------------------------------------------*

REPORT  ZHU_LABEL_KTNG.

TABLES:VEKP.
INCLUDE ZABAPALV.


TYPES: BEGIN OF IT_HUX.
        INCLUDE STRUCTURE ZLABEL_WINDOWS.
TYPES: MSG(100),
       LINE_COLOR(4) TYPE C, "Color for corresponding line
       BOX(1),
      END OF IT_HUX.

*- Variabel
DATA: IT_PRINT TYPE IT_HUX OCCURS 0 WITH HEADER LINE,
      IT_PRINT3 TYPE IT_HUX OCCURS 0 WITH HEADER LINE.
*- Get Data
DATA : BEGIN OF ITAB OCCURS 10,
       VENUM LIKE VEKP-VENUM,
       CHARG LIKE MCH1-CHARG,
       EXIDV TYPE N LENGTH 20,      "LIKE vekp-exidv,    "HU number
*       EXIDV LIKE VEKP-EXIDV,
       BSTKD LIKE VBKD-BSTKD,       "PO number
       BSTKD_E LIKE VBKD-BSTKD_E,   "PO number
       PRTNO(40),                   "karakteristik SO (special touch-1)
       PRTDC(40),                   "Part Description
       PRTSP(64),                   "Part specification
       PROLL TYPE P DECIMALS 0,     "roll per pallet
       PDATE LIKE SY-DATUM,         "Berisi tanggal GR batch dengan format MM/YYYY
       EDATE LIKE SY-DATUM,         "Berisi tanggal Used Before Batch dengan format MM/YYYY
       ZTYPE(10),
       ZCORE(2),
       LENGT(20),
       WIDTH(20),
       THICK(20),
       ZCONV LIKE API_VALI-ATWRT,
       MATNR LIKE MCH1-MATNR,
       VLIVE TYPE P DECIMALS 0,
       SONUM LIKE VEPO-SONUM,
       PALID LIKE ZHMS-PALID,
       ERDAT LIKE LIKP-ERDAT,
       KDMAT LIKE LIPS-KDMAT,
       BOX(1),
END OF ITAB.

DATA: V_ERDAT LIKE LIPS-ERDAT.

DATA: IT_EXIDV TYPE HUM_EXIDV_T.

DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
      IT_VEPO2 LIKE VEPOVB OCCURS 0 WITH HEADER LINE,
      WA_VEPO TYPE VEPOVB OCCURS 0 WITH HEADER LINE.

DATA : V_FORMNAME  TYPE TDSFNAME  VALUE 'ZHU_LABEL_KTNG',
       V_FUNCNAME  TYPE RS38L_FNAM,
       CONTROL_PARAMETERS TYPE SSFCTRLOP,
       OUTPUT_OPTIONS TYPE SSFCOMPOP.

*- variable get live
DATA: BEGIN OF IT_BUDAT OCCURS 0,
        MBLNR LIKE MSEG-MBLNR,
        MATNR LIKE MSEG-MATNR,
        SMBLN LIKE MSEG-SMBLN,
        BWART LIKE MSEG-BWART,
        CHARG LIKE MSEG-CHARG,
        BUDAT LIKE MSEG-BUDAT_MKPF,
  END OF IT_BUDAT.

DATA: ITAB2 LIKE IT_BUDAT OCCURS 0  WITH HEADER LINE.

DATA I_BATCH LIKE API_VALI OCCURS 0 WITH HEADER LINE.
DATA: V_MSG(70),
      V_MSG2(70),
      V_PDATE(10),
      V_EDATE(10).

" Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: P_EXIDV FOR VEKP-EXIDV NO INTERVALS.
SELECTION-SCREEN END OF BLOCK BLK1.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM DISPLAY_DATA.

END-OF-SELECTION.

  " GET DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  DATA: V_ROLL TYPE P DECIMALS 0.

  IF P_EXIDV[] IS INITIAL.
    MESSAGE 'Parameter HU harus diisi !' TYPE 'I'.
  ENDIF.

  LOOP AT P_EXIDV.
    CLEAR   : IT_PRINT, IT_EXIDV, ITAB.
    REFRESH : IT_EXIDV, ITAB.

    SHIFT P_EXIDV LEFT BY 3 PLACES.
    APPEND P_EXIDV TO IT_EXIDV.

    CALL FUNCTION 'HU_GET_HUS_DB'
      EXPORTING
        IT_HU_NUMBERS = IT_EXIDV
      IMPORTING
*       ET_HU_HEADER  =
        ET_HU_ITEMS   = IT_VEPO.

    DATA: V_ROUND TYPE P DECIMALS 2,
          V_VENUM LIKE VEKP-VENUM.

    IT_VEPO2[] = IT_VEPO[].


*---get quantity and expired
    SELECT SINGLE VENUM INTO V_VENUM FROM VEKP WHERE EXIDV = P_EXIDV.

*--- GET PART NUMBER.
    CLEAR: IT_VEPO2-SONUM.
    LOOP AT IT_VEPO2 WHERE SONUM NE '' AND VENUM = V_VENUM.
    ENDLOOP.

    IF SY-SUBRC NE 0.
      LOOP AT IT_VEPO INTO IT_VEPO2 WHERE VENUM = V_VENUM.
        LOOP AT IT_VEPO2 WHERE SONUM NE '' AND VENUM = IT_VEPO2-UNVEL.
        ENDLOOP.
        EXIT.
      ENDLOOP.
    ENDIF.

    SELECT SINGLE KDMAT INTO IT_PRINT-VPARTNO FROM VBAP WHERE VBELN = IT_VEPO2-SONUM+0(10) AND POSNR = IT_VEPO2-SONUM+10(6).

    IF IT_PRINT-VPARTNO = ''.
      IT_PRINT-LINE_COLOR = 'C610'.
      V_MSG = 'Customer Number Kosong'.
      IT_PRINT-MSG = V_MSG.
    ELSE.
      IT_PRINT-LINE_COLOR = 'C100'.
    ENDIF.

*--- get Tanggal DO

    SELECT SINGLE ERDAT INTO V_ERDAT FROM LIPS WHERE VBELN = IT_VEPO2-VBELN AND CHARG = IT_VEPO2-CHARG.
    WRITE V_ERDAT TO   IT_PRINT-VBARCODECUST DD/MM/YYYY.
*  IT_PRINT-VBARCODECUST = V_ERDAT.

    LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM AND VEMNG > 0.
      ITAB-VENUM = WA_VEPO-VENUM.
      ITAB-CHARG = WA_VEPO-CHARG.

      APPEND ITAB.
    ENDLOOP.

    LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM AND VEMNG EQ 0.
      LOOP AT IT_VEPO2 WHERE VENUM = WA_VEPO-UNVEL.
        ITAB-VENUM = IT_VEPO2-VENUM.
        ITAB-CHARG = IT_VEPO2-CHARG.

        APPEND ITAB.

      ENDLOOP.

    ENDLOOP.

    DESCRIBE TABLE ITAB LINES IT_PRINT-VROLL.
    CONDENSE IT_PRINT-VROLL.

*---- get expired live
    PERFORM GET_LIVE.
    PERFORM GET_SOCHAR.

    WRITE P_EXIDV-LOW TO IT_PRINT-VVBELN NO-ZERO.
*  IT_PRINT-VVBELN = P_EXIDV.


    APPEND IT_PRINT.

  ENDLOOP.
ENDFORM.                    "GET_DATA

*--- get live
FORM GET_LIVE.

  CLEAR: I_BATCH, V_MSG, IT_BUDAT.
  REFRESH: I_BATCH, IT_BUDAT.

  DELETE IT_VEPO2 WHERE VEMNG = 0.
  SELECT MBLNR MATNR SMBLN BWART CHARG BUDAT_MKPF INTO TABLE IT_BUDAT FROM MSEG
  FOR ALL ENTRIES IN IT_VEPO2 WHERE CHARG = IT_VEPO2-CHARG AND BWART IN (101,102).

  ITAB2[] = IT_BUDAT[].
  LOOP AT ITAB2 WHERE SMBLN NE ''.
    DELETE IT_BUDAT WHERE MBLNR = ITAB2-SMBLN.
  ENDLOOP.

  IF IT_BUDAT[] IS INITIAL.
    CLEAR: ITAB-EDATE.
    IT_PRINT-LINE_COLOR = 'C610'.
    CONCATENATE 'Batch No.' IT_BUDAT-CHARG 'tidak ada GRN 101' ',' IT_PRINT-MSG INTO IT_PRINT-MSG SEPARATED BY SPACE.
*    IT_PRINT-MSG = V_MSG.
    EXIT.
  ENDIF.

  SORT IT_BUDAT BY BUDAT DESCENDING.
  READ TABLE IT_BUDAT INDEX 1.
  ITAB-PDATE = IT_BUDAT-BUDAT.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR  = IT_BUDAT-MATNR
      I_VAL_CHARGE = IT_BUDAT-CHARG
    TABLES
      T_VAL_TAB    = I_BATCH.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE I_BATCH WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
    IF SY-SUBRC = 0.
      ITAB-VLIVE = I_BATCH-ATWRT.
    ENDIF.

    ITAB-EDATE = ITAB-PDATE + ITAB-VLIVE.
  ENDIF.

  WRITE ITAB-PDATE  TO V_PDATE DD/MM/YYYY.
  WRITE ITAB-EDATE  TO V_EDATE DD/MM/YYYY.
  CONCATENATE IT_PRINT-VBARCODECUST '/' V_PDATE '/' V_EDATE INTO IT_PRINT-VBARCODECUST SEPARATED BY SPACE.

ENDFORM.                    "get_live

*--get type
FORM GET_SOCHAR.

  DATA: V_CUOBJ LIKE VEPO-CUOBJ,
        V_ROUND TYPE P DECIMALS 0.

  DATA: I_CHAR TYPE CUXE1CUVAL OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE CUOBJ INTO V_CUOBJ FROM VBAP WHERE VBELN = IT_VEPO2-SONUM+0(10) AND POSNR = IT_VEPO2-SONUM+10(6).


  CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
    EXPORTING
      INSTANCE                = V_CUOBJ
    TABLES
      ET_VALUE                = I_CHAR
    EXCEPTIONS
      MATERIAL_HAS_NO_PROFIL  = 1
      NO_CONFIGURATION_PARAMS = 2
      FATAL_ERROR             = 3
      OTHERS                  = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    CLEAR: ITAB-ZTYPE, ITAB-ZTYPE, ITAB-THICK, ITAB-WIDTH,
           ITAB-LENGT, ITAB-ZCORE, ITAB-ZCONV, ITAB-PROLL.
    LOOP AT I_CHAR.
      CASE I_CHAR-CHARC.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value_txt.
        WHEN 'ZZTYPE'.
          ITAB-ZTYPE = I_CHAR-VALUE.
        WHEN 'ZZTHICKNESS'.
          V_ROUND = I_CHAR-VALUE.
          WRITE V_ROUND TO ITAB-THICK LEFT-JUSTIFIED.
        WHEN 'ZZWIDTH'.
          ITAB-WIDTH = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-WIDTH  WITH '.'.
        WHEN 'ZZLENGTH'.
          ITAB-LENGT = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-LENGT  WITH '.'.
        WHEN 'ZZCORE'.
          ITAB-ZCORE = I_CHAR-VALUE_TXT.
        WHEN 'ZZCONVERSIONROLLKG'.
          ITAB-ZCONV = I_CHAR-VALUE.
          REPLACE ',' WITH '' INTO ITAB-ZCONV.   "T005X
          CONDENSE ITAB-ZCONV NO-GAPS.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value.

      ENDCASE.
    ENDLOOP.

    CONCATENATE ITAB-ZTYPE '-' ITAB-THICK INTO IT_PRINT-VTYPE SEPARATED BY SPACE.
    CONCATENATE ITAB-WIDTH 'mm x' ITAB-LENGT 'm'  INTO IT_PRINT-VWIDTH SEPARATED BY SPACE.

  ENDIF.
ENDFORM.                    "GET_SOCHAR

*- Display

FORM DISPLAY_DATA.

  IF IT_PRINT[] IS INITIAL.
    MESSAGE 'Tidak ada data.' TYPE 'I' DISPLAY LIKE 'W'.
  ELSE.
    PERFORM F_FIELD_CATALOG.
    PERFORM F_LAYOUT.
    PERFORM F_LIST_DETAIL.
  ENDIF.
ENDFORM.                    "DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_PRINT' :
    'VPARTNO'   '' ''  '' '10'  'Costumer No.' ''  '' '' '',
    'VTYPE'    '' ''  '' ''  'Product Name Type'    ''  '' '' '',
    'VWIDTH'    '' ''  '' ''  'Prodouct Name Width'    ''  '' '' '',
    'VROLL'   '' ''  '' '10'  'Roll' ''  '' '' '',
    'VBARCODECUST'   '' ''  '' '30'  'Ship Date/Prod Date/Exp.Date' ''  '' '' '',
    'VVBELN'    '' ''  '' '12'  'HU Number'           ''  '' '' '',
    'MSG'    '' ''  '' '25'  'Note'           ''  '' '' ''.
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
  WA_LAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.
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
      T_OUTTAB                 = IT_PRINT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

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
      READ TABLE IT_PRINT WITH KEY BOX = 'X' LINE_COLOR = 'C610'.
      IF SY-SUBRC = 0.
        CONCATENATE 'Maaf' IT_PRINT-MSG  INTO V_MSG2 SEPARATED BY SPACE.
        MESSAGE V_MSG2 TYPE 'I'.
*        MESSAGE 'Customer Code Kosong / Periksa Customer Material di SO item !' TYPE 'I'.
        EXIT.
      ENDIF.
      CLEAR: IT_PRINT3.
      REFRESH:IT_PRINT3.

      LOOP AT IT_PRINT WHERE  BOX = 'X'.
        IT_PRINT3-VPARTNO = IT_PRINT-VPARTNO.
        IT_PRINT3-VTYPE = IT_PRINT-VTYPE.
        IT_PRINT3-VWIDTH = IT_PRINT-VWIDTH.
        IT_PRINT3-VROLL = IT_PRINT-VROLL.
        IT_PRINT3-VBARCODECUST = IT_PRINT-VBARCODECUST.
        IT_PRINT3-VVBELN = IT_PRINT-VVBELN.
        APPEND IT_PRINT3.
        CLEAR IT_PRINT3.
      ENDLOOP.

      IF IT_PRINT3[] IS NOT INITIAL.
        PERFORM PRINT.
      ENDIF.
  ENDCASE.
  FU_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "F_USER_COMMAND

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

*- Print

FORM PRINT.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
    TABLES
      ITAB               = IT_PRINT3.
ENDFORM.                    "print