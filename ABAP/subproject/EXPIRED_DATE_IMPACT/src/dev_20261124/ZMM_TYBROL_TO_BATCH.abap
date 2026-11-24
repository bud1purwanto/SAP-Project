*&---------------------------------------------------------------------*
*&  Report     :  ZMM_TYBROL_TO_BATCH                                  *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  19 April 2018                                        *
*&---------------------------------------------------------------------*

REPORT  ZMM_TYBROL_TO_BATCH                      .
TABLES: MCH1, AUSP.
DATA: V_COUNT LIKE SY-TABIX.

DATA: BEGIN OF ITAB OCCURS 0,
      MATNR LIKE MCHA-MATNR,
      CHARG LIKE MCHA-CHARG,
      ROLTYB(12), "Toyobo Roll Number
      TYPE(8), "Film Type
      LOTTYB(8), "Lot Number
      ROLTRS(30), "Trias Roll Number
      WIDTH(12), "Width of Film
      LENGT(12), "Length of Film
      WEIGHT(12), "Weight of Film
      TREAT(35), "Treatment
      GRDATE LIKE SY-DATUM, "GR Date
      AUFNR LIKE AFPO-AUFNR, "Order Number

      BOX(1),
      END OF ITAB.

DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.

DATA: V_ATROL LIKE CABN-ATINN,
      V_ATLOT LIKE CABN-ATINN,
      V_ATWEI LIKE CABN-ATINN.

DATA: V_LIVE(6),
      V_NUM TYPE P DECIMALS 3,
      V_WEI LIKE AUSP-ATFLV.

"Added By Aldi 08.04.2020 (CR: TRDK917038)
DATA : V_MENGE101 LIKE MSEG-MENGE,  "Qty GRN
       V_MENGE102 LIKE MSEG-MENGE,  "Qty Cancel GRN
       V_MENGETOTAL LIKE MSEG-MENGE. "Quantity Total GRN-Cancel

INCLUDE ZABAPALV.                " Include Function ALV.

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : P_ROLNO FOR AUSP-ATWRT NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK BLK1.

START-OF-SELECTION.
  PERFORM F_GET_DATA.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA.
  DATA: V_SMBLN LIKE MSEG-SMBLN,
        V_MBLNR LIKE MSEG-MBLNR.

  SELECT SINGLE ATINN INTO V_ATROL FROM CABN WHERE ATNAM = 'ZZNOROLLTOYOBO'.
  SELECT SINGLE ATINN INTO V_ATLOT FROM CABN WHERE ATNAM = 'ZZNOLOTTOYOBO'.
  SELECT SINGLE ATINN INTO V_ATWEI FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.

  SELECT A~MATNR A~CHARG B~ATWRT INTO TABLE ITAB
    FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
    WHERE B~KLART = '023' AND B~ATINN = V_ATROL AND B~ATWRT IN P_ROLNO.

  LOOP AT ITAB.
    REFRESH: IT_CHAR.

    CALL FUNCTION 'ZCHARACTERISTICS'
      EXPORTING
        I_VAL_MATNR  = ITAB-MATNR
        I_VAL_CHARGE = ITAB-CHARG
      TABLES
        T_VAL_TAB    = IT_CHAR
      EXCEPTIONS
        NO_OBJECT    = 1
        NO_VALUES    = 2
        T_L_E1       = 3
        T_L_E2       = 4.

    IF IT_CHAR[] IS INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC = 0.
      ITAB-TYPE =  IT_CHAR-ATWRT.
    ENDIF.

    CLEAR: V_NUM.
    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC = 0.
      V_NUM = IT_CHAR-ATFLV.
      WRITE V_NUM TO ITAB-WIDTH DECIMALS 0.
    ENDIF.

    CLEAR: V_NUM.
    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC = 0.
      V_NUM = IT_CHAR-ATFLV.
      WRITE V_NUM TO ITAB-LENGT DECIMALS 0.
    ENDIF.

    CLEAR: V_LIVE.
    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZEXPIREDLIVE'.
    IF SY-SUBRC = 0.
      V_LIVE =  IT_CHAR-ATWRT.
    ENDIF.

    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTREATMENT'.
    IF SY-SUBRC = 0.
      ITAB-TREAT =  IT_CHAR-ATWTB.
    ENDIF.

    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC = 0.
      ITAB-ROLTRS =  IT_CHAR-ATWRT.
    ENDIF.

*--
    SELECT SINGLE B~ATWRT INTO  ITAB-LOTTYB
      FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
      WHERE B~KLART = '023' AND B~ATINN = V_ATLOT AND A~CHARG = ITAB-CHARG AND A~MATNR = ITAB-MATNR.

    CLEAR: V_NUM, V_WEI.
    SELECT SINGLE B~ATFLV INTO  V_WEI  "ITAB-WEIGHT
      FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
      WHERE B~KLART = '023' AND B~ATINN = V_ATWEI AND A~CHARG = ITAB-CHARG AND A~MATNR = ITAB-MATNR.
    V_NUM = V_WEI.
    WRITE V_NUM TO ITAB-WEIGHT DECIMALS 2.

    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = ITAB-MATNR
        CHARG = ITAB-CHARG
      IMPORTING
        PDATE = ITAB-GRDATE.

    IF ITAB-GRDATE NE '00000000'.
      ITAB-GRDATE = ITAB-GRDATE + V_LIVE.
    ENDIF.

    "*---START - Modified By Aldi 08.04.2020 (CR: TRDK917038)
    CLEAR: V_MBLNR, V_SMBLN, V_MENGE101, V_MENGE102, V_MENGETOTAL.

    SELECT AUFNR MBLNR INTO (ITAB-AUFNR, V_MBLNR) FROM MSEG WHERE CHARG = ITAB-CHARG AND BWART = '101'.
*      SELECT SINGLE SMBLN INTO V_SMBLN FROM MSEG WHERE SMBLN = V_MBLNR AND BWART = '102'.
*      IF V_SMBLN EQ ''.
*        EXIT.
*      ELSEIF V_SMBLN NE ''.
*        ITAB-AUFNR = 'BATAL'.
*      ENDIF.

      "Added By Aldi 08.04.2020 (CR: TRDK917038)
      "Menghitung Qty batch secara pergerakan GRN(101)-Cancel(102)
      SELECT SUM( MENGE ) INTO V_MENGE101 FROM MSEG WHERE CHARG = ITAB-CHARG AND BWART = '101'.
      SELECT SUM( MENGE ) INTO V_MENGE102 FROM MSEG WHERE CHARG = ITAB-CHARG AND BWART = '102'.
      "Variable menampung Qty batch, apabila Qty dari perhitungan Pergerakan 101 & 102
      V_MENGETOTAL = V_MENGE101 - V_MENGE102.

      IF V_MENGETOTAL > 0. "Jika Value lebih dari 0 dianggap GRN
        EXIT.
      ELSE. "Bernilai 0 dianggap cancel
        ITAB-AUFNR = 'BATAL'.
      ENDIF.
    "*---END - Modified By Aldi 08.04.2020 (CR: TRDK917038)
    ENDSELECT.

    MODIFY ITAB.

  ENDLOOP.

  DELETE ITAB WHERE AUFNR = 'BATAL'.
ENDFORM.                    "f_get_data


*--- Display Items
FORM F_DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
   'TYPE'  '' ''  '' '8'  'Type'           '' '' '' '',
   'AUFNR'  '' ''  '' '16'  'Order Number'  '' 'X' '' '',
   'MATNR'  '' ''  '' '10'  'Material'           '' ' ' '' '',
   'CHARG'  '' ''  '' '10'  'Batch'           '' 'X' '' '',
   'LOTTYB'  '' ''  '' '10'  'Toyobo Lot No.'           '' '' '' '',
   'ROLTYB'  '' ''  '' '12'  'Toyobo Rol No.'           '' '' '' '',
   'ROLTRS'  '' ''  '' '28'  'Trias Rol No.'           '' '' '' '',
   'WIDTH'  '' ''  '' '10'  'Width'           '' '' '' '',
   'LENGT'  '' ''  '' '10'  'Length'           '' '' '' '',
   'WEIGHT'  '' ''  '' '10'  'Weight'           '' '' '' '',
   'TREAT'  '' ''  '' '18'  'Treatment'           '' '' '' '',
   'GRDATE'  '' ''  '' '12'  'GR date'           '' '' '' ''.

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG'.
ENDFORM.                    " f_field_catalog

*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " f_layout


*&---------------------------------------------------------------------*
*&      Form  f_list_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
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
*  DATA: LT_HUS TYPE HUM_VENUM_T.
*
*  SY-LSIND = 0.


  DATA: LS_OUTTAB LIKE ITAB,
          LS_CELLTAB TYPE LVC_S_STYL.

  READ TABLE ITAB INTO LS_OUTTAB INDEX FU_SELFIELD-TABINDEX.  "ES_ROW_NO-ROW_ID.
  IF FU_SELFIELD-FIELDNAME = 'CHARG'.
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        TCODE  = 'MSC3N'
      EXCEPTIONS
        OK     = 1
        NOT_OK = 2
        OTHERS = 3.
    IF SY-SUBRC <> 1.
      MESSAGE 'Anda tidak memiliki authorisasi untuk menjalankan T-code MSC3N' TYPE 'I'.
      EXIT.
    ENDIF.

    SET PARAMETER ID 'MAT' FIELD LS_OUTTAB-MATNR.
    SET PARAMETER ID 'CHA' FIELD LS_OUTTAB-CHARG.
    CALL TRANSACTION 'MSC3N' AND SKIP FIRST SCREEN.
  ELSEIF FU_SELFIELD-FIELDNAME = 'AUFNR'.
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        TCODE  = 'COR3'
      EXCEPTIONS
        OK     = 1
        NOT_OK = 2
        OTHERS = 3.
    IF SY-SUBRC <> 1.
      MESSAGE 'Anda tidak memiliki authorisasi untuk menjalankan T-code COR3' TYPE 'I'.
      EXIT.
    ENDIF.

    SET PARAMETER ID 'BR1' FIELD LS_OUTTAB-AUFNR.
    CALL TRANSACTION 'COR3' AND SKIP FIRST SCREEN.
  ENDIF.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS