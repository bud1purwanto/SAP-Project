*&---------------------------------------------------------------------*
*&  Report     :  ZPP_SR_INPUT                                         *
*&  Appl. Area :  PP                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  16 March   2018                                      *
*&---------------------------------------------------------------------*

REPORT  ZPP_SR_INPUT                       .
TABLES: MSEG, AUSP.

DATA: BEGIN OF ITAB OCCURS 0,
      MBLNR LIKE MSEG-MBLNR,
      MATNR LIKE MSEG-MATNR,
      CHARG LIKE MCH1-CHARG,
      AUFNR LIKE AFPO-AUFNR,  "original
      ZEILE LIKE MSEG-ZEILE,
      XBLNR_MKPF LIKE MSEG-XBLNR_MKPF,
      SGTXT LIKE MSEG-SGTXT,
      ROLNO LIKE AUSP-ATWRT,
      LENGT TYPE P,    " SR length
      COMBI LIKE AFPO-AUFNR,  "Combine
      CHARG1 LIKE MSEG-CHARG,
      JOIN1 TYPE P, "LIKE AUSP-ATFLV,
      ROLNO1 LIKE AUSP-ATWRT,
      ROLNO2 LIKE AUSP-ATWRT,
      CHARG2 LIKE MSEG-CHARG,
      JOIN2 TYPE P, "LIKE AUSP-ATFLV,
      CHARG3 LIKE MSEG-CHARG,
      ROLNO3 LIKE AUSP-ATWRT,
      JOIN3 TYPE P, "LIKE AUSP-ATFLV,
      SPLICE1 TYPE P,
      SPLICE2 TYPE P,
      SPLICE3 TYPE P,
      AUART LIKE AUFK-AUART,  "order type
      BOX(1),
      LINE_COLOR   TYPE C LENGTH 4,
      END OF ITAB.

DATA: ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE,
      V_CHARG LIKE MSEG-CHARG,
      V_MBLNR LIKE MSEG-MBLNR.

DATA: BEGIN OF IT_CANCEL OCCURS 0,
      SMBLN LIKE MSEG-SMBLN,
  END OF IT_CANCEL.

DATA: BEGIN OF IT_AFPO OCCURS 0,
      COMBI LIKE AFPO-AUFNR,
      ORIGI LIKE AFPO-MILL_OC_AUFNR_U,
  END OF IT_AFPO.

INCLUDE ZABAPALV.                " Include Function ALV.

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : P_CHARG FOR MSEG-CHARG.
SELECT-OPTIONS : P_ROLNO FOR AUSP-ATWRT NO INTERVALS.
SELECTION-SCREEN END OF BLOCK BLK1.



*--------------
START-OF-SELECTION.
  PERFORM F_GET_DATA.

  CHECK ITAB[] IS NOT INITIAL.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA.
  DATA: V_ROLNO LIKE AUSP-ATINN,
        V_ZSPLICE1 LIKE AUSP-ATINN,
        V_ZSPLICE2 LIKE AUSP-ATINN,
        V_ZSPLICE3 LIKE AUSP-ATINN,
        V_ZZLENGTH LIKE AUSP-ATINN.

  DATA: L_EX_REF TYPE REF TO CX_ROOT,
        MSG_TEXT TYPE STRING.

  SELECT SINGLE ATINN INTO V_ROLNO FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO V_ZSPLICE1 FROM CABN WHERE ATNAM = 'ZZSPLICE-1'.
  SELECT SINGLE ATINN INTO V_ZSPLICE2 FROM CABN WHERE ATNAM = 'ZZSPLICE-2'.
  SELECT SINGLE ATINN INTO V_ZSPLICE3 FROM CABN WHERE ATNAM = 'ZZSPLICE-3'.
  SELECT SINGLE ATINN INTO V_ZZLENGTH FROM CABN WHERE ATNAM = 'ZZLENGTH'.

  IF P_ROLNO[] IS NOT INITIAL.
    REFRESH: P_CHARG.
    CLEAR: P_CHARG.
    SELECT MCH1~CHARG AS LOW INTO CORRESPONDING FIELDS OF TABLE P_CHARG
                FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE AUSP~ATWRT IN P_ROLNO AND AUSP~KLART = '023' AND AUSP~ATINN = V_ROLNO.
    IF SY-SUBRC = 0.
      P_CHARG-SIGN = 'I'.
      P_CHARG-OPTION = 'EQ'.
      MODIFY P_CHARG TRANSPORTING SIGN OPTION WHERE LOW NE ''.
    ELSE.
      MESSAGE 'Data tidak ditemukan' TYPE 'I'.
      STOP.
    ENDIF.
  ENDIF.

*- get original
  SELECT MSEG~MBLNR MSEG~MATNR MSEG~CHARG MSEG~AUFNR AUFK~AUART
    INTO CORRESPONDING FIELDS OF TABLE ITAB
    FROM MSEG
    JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
    WHERE MSEG~CHARG IN P_CHARG AND ( MSEG~BWART = '101' OR MSEG~BWART = '531' ).

  SELECT SMBLN INTO TABLE IT_CANCEL FROM MSEG
    WHERE CHARG IN P_CHARG AND ( BWART = '102' OR BWART = '532' ).

  LOOP AT IT_CANCEL.
    DELETE ITAB WHERE MBLNR = IT_CANCEL-SMBLN.
  ENDLOOP.

  IF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan...!' TYPE 'I'.
    EXIT.
  ENDIF.

*- mat to mat
  SELECT AFPO~AUFNR AFPO~MILL_OC_AUFNR_U INTO TABLE IT_AFPO FROM AFPO
    JOIN AUFK ON AFPO~AUFNR = AUFK~AUFNR
    FOR ALL ENTRIES IN ITAB
    WHERE AFPO~AUFNR = ITAB-AUFNR
      AND AUART = 'ZMM1'.

*- get combine
  SELECT AFPO~AUFNR AFPO~MILL_OC_AUFNR_U APPENDING TABLE IT_AFPO FROM AFPO
    JOIN AUFK ON AFPO~AUFNR = AUFK~AUFNR
    FOR ALL ENTRIES IN ITAB
    WHERE AFPO~MILL_OC_AUFNR_U = ITAB-AUFNR
      AND AUART <> 'ZMM1'.

  IF IT_AFPO[] IS INITIAL.
    MESSAGE 'Production Order tidak ditemukan...!' TYPE 'I'.
    EXIT.
  ENDIF.

  LOOP AT IT_AFPO.
    ITAB-COMBI = IT_AFPO-COMBI.
    MODIFY ITAB TRANSPORTING COMBI WHERE AUFNR = IT_AFPO-COMBI AND AUART = 'ZMM1'.  "mat to mat
    MODIFY ITAB TRANSPORTING COMBI WHERE AUFNR = IT_AFPO-ORIGI AND AUART <> 'ZMM1'. "combine
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM IT_AFPO COMPARING COMBI.

  SELECT MBLNR MATNR CHARG AUFNR ZEILE XBLNR_MKPF SGTXT INTO TABLE ITAB2 FROM MSEG
    FOR ALL ENTRIES IN IT_AFPO WHERE AUFNR = IT_AFPO-COMBI AND BWART = '261'.

  DELETE ITAB2 WHERE XBLNR_MKPF+0(3) = 'SCR'.

  SORT ITAB2 BY AUFNR.
  SELECT SMBLN INTO TABLE IT_CANCEL FROM MSEG
    FOR ALL ENTRIES IN IT_AFPO WHERE AUFNR = IT_AFPO-COMBI AND BWART = '262'.

  LOOP AT IT_CANCEL.
    DELETE ITAB2 WHERE MBLNR = IT_CANCEL-SMBLN.
  ENDLOOP.


  LOOP AT ITAB.
*- get SR Roll
    SELECT SINGLE AUSP~ATWRT INTO ITAB-ROLNO
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = V_ROLNO.

    MODIFY ITAB.
  ENDLOOP.

*- get join
  SORT ITAB2 BY MBLNR ZEILE.
  DATA: V_NUM(2), V_POS1(12), V_POS2(12).
  LOOP AT ITAB.
    CLEAR V_NUM.

*- get SR splice
    SELECT SINGLE AUSP~ATFLV INTO ITAB-SPLICE1
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = V_ZSPLICE1.
    SELECT SINGLE AUSP~ATFLV INTO ITAB-SPLICE2
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = V_ZSPLICE2.
    SELECT SINGLE AUSP~ATFLV INTO ITAB-SPLICE3
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = V_ZSPLICE3.
*- get Length SR
    SELECT SINGLE AUSP~ATFLV INTO ITAB-LENGT
      FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
      WHERE MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = V_ZZLENGTH.

    MODIFY ITAB.
    LOOP AT ITAB2 WHERE AUFNR = ITAB-COMBI.
      TRY.
          V_NUM = V_NUM + 1.
          IF V_NUM = 1.
            ITAB-CHARG1 = ITAB2-CHARG.
            CONDENSE ITAB2-SGTXT.
            CLEAR: V_POS1.
            SPLIT ITAB2-SGTXT AT ';' INTO V_POS1 V_POS2.
            ITAB-JOIN1 = V_POS1.

            SELECT SINGLE AUSP~ATWRT INTO ITAB-ROLNO1
              FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
              WHERE MCH1~CHARG = ITAB2-CHARG AND AUSP~ATINN = V_ROLNO.

          ELSEIF V_NUM = 2.
            ITAB-CHARG2 = ITAB2-CHARG.
            CONDENSE ITAB2-SGTXT.
            CLEAR: V_POS1.
            SPLIT ITAB2-SGTXT AT ';' INTO V_POS1 V_POS2.
            ITAB-JOIN2 = V_POS1.

            SELECT SINGLE AUSP~ATWRT INTO ITAB-ROLNO2
              FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
              WHERE MCH1~CHARG = ITAB2-CHARG AND AUSP~ATINN = V_ROLNO.

            "Menghapus Scrap
            IF ITAB-SPLICE1 IS INITIAL.
              CLEAR: V_CHARG, V_MBLNR.
              SELECT SINGLE MBLNR INTO V_MBLNR FROM MSEG WHERE BWART = '261' AND AUFNR = ITAB-AUFNR AND CHARG = ITAB-CHARG2 AND SGTXT LIKE '%;%'.
              IF SY-SUBRC EQ 0.
                SELECT SINGLE CHARG INTO V_CHARG FROM MSEG WHERE BWART = '531' AND AUFNR = ITAB-AUFNR AND CHARG = '' AND MBLNR = V_MBLNR.
                IF SY-SUBRC EQ 0.
                  ITAB-CHARG2 = ''.
                  ITAB-ROLNO2 = ''.
                  ITAB-JOIN2  = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSEIF V_NUM = 3.
            ITAB-CHARG3 = ITAB2-CHARG.
            CONDENSE ITAB2-SGTXT.
            CLEAR: V_POS1.
            SPLIT ITAB2-SGTXT AT ';' INTO V_POS1 V_POS2.
            ITAB-JOIN3 = V_POS1.

            SELECT SINGLE AUSP~ATWRT INTO ITAB-ROLNO3
              FROM MCH1 JOIN AUSP ON MCH1~CUOBJ_BM = AUSP~OBJEK
              WHERE MCH1~CHARG = ITAB2-CHARG AND AUSP~ATINN = V_ROLNO.

            "Menghapus Scrap
            IF ITAB-SPLICE2 IS INITIAL.
              CLEAR: V_CHARG, V_MBLNR.
              SELECT SINGLE MBLNR INTO V_MBLNR FROM MSEG WHERE BWART = '261' AND AUFNR = ITAB-AUFNR AND CHARG = ITAB-CHARG3 AND SGTXT LIKE '%;%'.
              IF SY-SUBRC EQ 0.
                SELECT SINGLE CHARG INTO V_CHARG FROM MSEG WHERE BWART = '531' AND AUFNR = ITAB-AUFNR AND CHARG = '' AND MBLNR = V_MBLNR.
                IF SY-SUBRC EQ 0.
                  ITAB-CHARG3 = ''.
                  ITAB-ROLNO3 = ''.
                  ITAB-JOIN3  = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
          ENDIF.

        CATCH CX_SY_CONVERSION_NO_NUMBER INTO L_EX_REF.
          MSG_TEXT = L_EX_REF->GET_TEXT( ).
          CONCATENATE ITAB-CHARG MSG_TEXT INTO MSG_TEXT SEPARATED BY ': '.
          MESSAGE MSG_TEXT TYPE 'I'.
          CLEAR: MSG_TEXT, L_EX_REF.

          STOP.
      ENDTRY.
    ENDLOOP.
    MODIFY ITAB.
  ENDLOOP.
  REFRESH: ITAB2, IT_AFPO.
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
  READ TABLE ITAB INDEX 1.
  IF ITAB-AUART NE 'ZMM1'.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
      'AUFNR'   '' ''  '' '16'  'Original Order'      '' 'X' '' '',
      'COMBI'   '' ''  '' '16'  'Combine Order'       '' '' '' '',
      'CHARG'   '' ''  '' '12'  'Batch SR'            '' 'X' '' '',
      'ROLNO'   '' ''  '' '22'  'Nomor Roll SR'       '' ' ' '' '',
      'LENGT'   '' ''  '' '10'  'SR Length'           '' '' '' '',
      'CHARG1'  '' ''  '' '12'  'Batch input-1'       '' ' ' '' '',
      'ROLNO1'  '' ''  '' '20'  'Roll Input 1'        '' ' ' '' '',
      'JOIN1'   '' ''  '' '10'  'Consume-1'           '' ' ' '' '',
      'CHARG2'  '' ''  '' '12'  'Batch input-2'       '' ' ' '' '',
      'ROLNO2'  '' ''  '' '20'  'Roll Input 2'        '' ' ' '' '',
      'JOIN2'   '' ''  '' '10'  'Consume-2'           '' ' ' '' '',
      'CHARG3'  '' ''  '' '12'  'Batch input-3'       '' ' ' '' '',
      'ROLNO3'  '' ''  '' '20'  'Roll Input 3'        '' ' ' '' '',
      'JOIN3'   '' ''  '' '10'  'Consume-3'           '' ' ' '' '',
      'SPLICE1' '' ''  '' '10'  'Splice-1'            '' ' ' '' '',
      'SPLICE2' '' ''  '' '10'  'Splice-2'            '' ' ' '' '',
      'SPLICE3' '' ''  '' '10'  'Splice-3'            '' ' ' '' ''.
  ELSE.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
      'AUFNR'   '' ''  '' '16'  'Order'               '' 'X' '' '',
      'CHARG'   '' ''  '' '12'  'Batch SR'            '' 'X' '' '',
      'ROLNO'   '' ''  '' '22'  'Nomor Roll SR'       '' ' ' '' '',
      'LENGT'   '' ''  '' '10'  'SR Length'           '' '' '' '',
      'CHARG1'  '' ''  '' '12'  'Batch input-1'       '' ' ' '' '',
      'ROLNO1'  '' ''  '' '20'  'Roll Input 1'        '' ' ' '' '',
      'JOIN1'   '' ''  '' '10'  'Consume-1'           '' ' ' '' '',
      'CHARG2'  '' ''  '' '12'  'Batch input-2'       '' ' ' '' '',
      'ROLNO2'  '' ''  '' '20'  'Roll Input 2'        '' ' ' '' '',
      'JOIN2'   '' ''  '' '10'  'Consume-2'           '' ' ' '' '',
      'CHARG3'  '' ''  '' '12'  'Batch input-3'       '' ' ' '' '',
      'ROLNO3'  '' ''  '' '20'  'Roll Input 3'        '' ' ' '' '',
      'JOIN3'   '' ''  '' '10'  'Consume-3'           '' ' ' '' '',
      'SPLICE1' '' ''  '' '10'  'Splice-1'            '' ' ' '' '',
      'SPLICE2' '' ''  '' '10'  'Splice-2'            '' ' ' '' '',
      'SPLICE3' '' ''  '' '10'  'Splice-3'            '' ' ' '' ''.
  ENDIF.

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG1'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG2'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG3'.

  LOOP AT ITAB.
    IF ITAB-CHARG1 = '' OR ITAB-JOIN1 EQ 0.
      ITAB-LINE_COLOR = 'C600'. "red
      MODIFY ITAB.
    ELSEIF "( ITAB-CHARG1 NE '' AND ITAB-JOIN1 = 0 ) OR
       ( ITAB-CHARG2 NE '' AND ITAB-JOIN2 = 0 ) OR
       ( ITAB-CHARG3 NE '' AND ITAB-JOIN3 = 0 ).
      ITAB-LINE_COLOR = 'C600'. "red
      MODIFY ITAB.
    ELSEIF ( ITAB-CHARG2 NE '' AND ITAB-SPLICE1 = 0 ) OR
       ( ITAB-CHARG3 NE '' AND ITAB-SPLICE2 = 0 ).
      ITAB-LINE_COLOR = 'C600'. "red
      MODIFY ITAB.
    ELSEIF ITAB-AUFNR = '' OR ITAB-COMBI = ''.
      ITAB-LINE_COLOR = 'C610'. "red
      MODIFY ITAB.
    ELSE.
    ENDIF.
  ENDLOOP.
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
  WA_LAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.
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

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&IC1'.
      READ TABLE ITAB INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'ITAB-AUFNR'. "OR 'ITAB-COMBI'.
          SET PARAMETER ID 'BR1' FIELD ITAB-AUFNR.
          CALL TRANSACTION 'COR3' AND SKIP FIRST SCREEN.
        WHEN 'ITAB-CHARG' OR 'ITAB-CHARG'.
          SET PARAMETER ID 'MAT' FIELD ITAB-MATNR.
          SET PARAMETER ID 'CHA' FIELD ITAB-CHARG.
          CALL TRANSACTION 'MSC3N' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

*  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS