*&---------------------------------------------------------------------*
*&  Report     :  ZMMI_GRN_SUBCON_TTE                                  *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  15 May 2020                                          *
*&---------------------------------------------------------------------*

REPORT  ZMMI_GRN_SUBCON_TTE.
TABLES: EKKO.

DATA : BEGIN OF ITAB OCCURS 0,
         EBELN    LIKE EKPO-EBELN,  "Purchasing Order
         EBELP    LIKE EKPO-EBELP,  "PO Item
         JRMATNR  LIKE MARA-MATNR,  "Material Component
         JRBATCH1 LIKE MCH1-CHARG,  "Batch Component 1
         BDMNG    LIKE RESB-BDMNG,  "Reserv Qty
         MATNR    LIKE MARA-MATNR,  "Material  O
         CHARG    LIKE MCH1-CHARG,  "Batch O
         MBLNR    LIKE MSEG-MBLNR,  "Matdoc GRN
         MATNRX   LIKE MARA-MATNR,  "Material X
         CHARGX   LIKE MCH1-CHARG,  "Material X
         MBLNRX   LIKE MSEG-MBLNR,  "Matdoc X
         RSPOS    LIKE RESB-RSPOS,  "Res Item
         JRBATCH2 LIKE MCH1-CHARG,  "Batch Component 2
         JRBATCH3 LIKE MCH1-CHARG,  "Batch Component 3
         JRTOT    LIKE RESB-BDMNG,  "Total Weight
         VBELN    LIKE LIKP-VBELN,  "DO
         AUFNR    LIKE MSEG-AUFNR,  "Order
         ARBPL    LIKE CRHD-ARBPL,  "Resource
         ZZCODE(30),                "Film Code
         ZZGRADE(30),               "Grade
         ZZMONTHYEAR(30),           "Month Year
         ZZCORE(30),                "Core
         ZZNOMORROLL(30),           "Trias Roll Number
         ZZPOSITIONMS(30),          "Position
         ZZPRODLINE(30),            "Production Line
         ZZPACKING(30),             "Packing
         ZZPACKINGCODE(30),         "Packing Code
         ZZLENGTH(30),              "Length O
         ZZWIDTH(30),               "Width O
         ZZSEQUENCENBR(30),         "Jumbo Roll Number
         ZZSPLICE1(30),             "Join 1
         ZZSPLICE2(30),             "Join 2
         ZZLABEL(30),               "Label Code
         ZZEXPIREDLIVE(30),         "Expired Live
         ZZSLITTINGSETNO(30),       "Trias Machine + Derivative Tyb
         ZZNOROLLTOYOBO(30),        "Toyobo Roll Number
         ZZNOLOTTOYOBO(30),         "Toyobo Lot Number
         ZZTREATMENT(30),           "Treatment
         SHORT(30),                 "Short Text
         WERKS    LIKE MCHB-WERKS,  "Plant
         CDATE    LIKE SY-DATUM,    "Date
         SROKG    LIKE MCHB-CLABS,  "mat-O weight
         SROTOT   LIKE MCHB-CLABS,  "mat-O weight
         JRKG1    LIKE MCHB-CLABS,  "JR GI
         JRKG2    LIKE MCHB-CLABS,  "JR GI
         JRKG3    LIKE MCHB-CLABS,  "JR GI
         LINES(3),                  "Lines
         REMARK(100),               "Remark
         ERR(1),                    "Error Status
         ICONS(4),                  "Icons
         BOX(1),                    "Box (X)
END OF ITAB.

DATA: ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_INPUT OCCURS 0,
      EBELN LIKE EKPO-EBELN,
      EBELP LIKE EKPO-EBELP,
      SROTOT LIKE RESB-BDMNG,
  END OF IT_INPUT.

DATA: V_DATE(10),
      V_TXT20(20),
      V_ATKG LIKE AUSP-ATINN,
      V_SMBLN LIKE MSEG-SMBLN,
      V_EBELN LIKE EKPO-EBELN,  "PO number
      V_EBELP LIKE EKPO-EBELP,  "PO item
      V_ARKTX LIKE LIPS-ARKTX,  "DO Service
      V_MBLNR LIKE MSEG-MBLNR,
      V_ANSWER(2),
      V_TIPE(1) VALUE '0'.

*- BDC
DATA : IT_BDCDATA    LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
       BDCDATA LIKE BDCDATA    OCCURS 10 WITH HEADER LINE,
       IT_BDCMSGCOLL LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       OPT TYPE CTU_PARAMS,
       MODE TYPE CTU_PARAMS.

CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.  "for event handling

DATA: OK_CODE LIKE SY-UCOMM,
      SAVE_OK LIKE SY-UCOMM,
      DIALOG_BOX  TYPE REF TO CL_GUI_DIALOGBOX_CONTAINER,
      GRID1  TYPE REF TO CL_GUI_ALV_GRID,
      G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GS_LAYOUT TYPE LVC_S_LAYO,
      G_MAX TYPE I VALUE 10,
      GT_FIELDCAT TYPE LVC_T_FCAT,
      G_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER,
      GS_VARIANT TYPE DISVARIANT,
      LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK A1001 WITH FRAME TITLE TEXT-100.
SELECT-OPTIONS: P_EBELN FOR EKKO-EBELN NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK A1001.

CALL SCREEN 100.

END-OF-SELECTION.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS: CATCH_DOUBLECLICK
             FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
             IMPORTING
                E_COLUMN
                ES_ROW_NO
                SENDER.
ENDCLASS.                    "lcl_event_receiver DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD CATCH_DOUBLECLICK.
    DATA: LS_OUTTAB LIKE ITAB,
            LS_CELLTAB TYPE LVC_S_STYL.

    READ TABLE ITAB INTO LS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
    IF SY-SUBRC = 0.
*      IF E_COLUMN-FIELDNAME EQ 'PRUEFLOS'.
*        SET PARAMETER ID 'QLS' FIELD LS_OUTTAB-PRUEFLOS.
*        CALL TRANSACTION 'QA03' AND SKIP FIRST SCREEN.
*      ENDIF.
    ENDIF.
  ENDMETHOD.                    "catch_doubleclick
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION


*----------------------------------------------------------------------*
*  MODULE awal OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE AWAL OUTPUT.
  IF SY-UCOMM = ''.
    PERFORM GET_DATA.
    PERFORM DISPLAY_ALV.
  ENDIF.
ENDMODULE.                    "awal OUTPUT

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  SELECT SINGLE ATINN INTO V_ATKG FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.

  SELECT EBELN EBELP MATNR AS JRMATNR CHARG BDMNG RSPOS INTO CORRESPONDING FIELDS OF TABLE ITAB2 FROM RESB WHERE EBELN IN P_EBELN.
  SORT ITAB2 BY EBELN EBELP RSPOS.
  LOOP AT ITAB2.
    IF ITAB-EBELN = ITAB2-EBELN AND ITAB-EBELP = ITAB2-EBELP.
      ITAB2-JRTOT = ITAB-JRTOT + ITAB2-BDMNG.
      MODIFY ITAB2 TRANSPORTING JRTOT WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP.
    ELSE.
      ITAB2-JRTOT = ITAB2-BDMNG.
      MODIFY ITAB2 TRANSPORTING JRTOT WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP.

    ENDIF.

    IF ITAB2-RSPOS = '0001'.
      ITAB2-JRBATCH1 = ITAB2-CHARG.

      SELECT SINGLE B~ATFLV INTO ITAB2-JRKG1
        FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
       WHERE A~CHARG = ITAB2-JRBATCH1 AND B~ATINN = V_ATKG.

      MODIFY ITAB2 TRANSPORTING JRBATCH1 JRKG1 WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP.
    ENDIF.
    IF ITAB2-RSPOS = '0002'.
      ITAB2-JRBATCH2 = ITAB2-CHARG.

      SELECT SINGLE B~ATFLV INTO ITAB2-JRKG2
        FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
       WHERE A~CHARG = ITAB2-JRBATCH2 AND B~ATINN = V_ATKG.

      MODIFY ITAB2 TRANSPORTING JRBATCH2 JRKG2 WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP.
    ENDIF.
    IF ITAB2-RSPOS = '0003'.
      ITAB2-JRBATCH3 = ITAB2-CHARG.

      SELECT SINGLE B~ATFLV INTO ITAB2-JRKG3
        FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
       WHERE A~CHARG = ITAB2-JRBATCH3 AND B~ATINN = V_ATKG.

      MODIFY ITAB2 TRANSPORTING JRBATCH3 JRKG3 WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP.
    ENDIF.

    ITAB-EBELN = ITAB2-EBELN.
    ITAB-EBELP = ITAB2-EBELP.
    ITAB-JRTOT = ITAB2-BDMNG.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM ITAB2 COMPARING EBELN EBELP.

*- deleted PO
  LOOP AT ITAB2.
    SELECT SINGLE EBELN INTO ITAB2-EBELN FROM EKPO
     WHERE EBELN = ITAB2-EBELN AND EBELP = ITAB2-EBELP AND LOEKZ = 'L'.
    IF SY-SUBRC = 0.
      DELETE ITAB2.
    ENDIF.
  ENDLOOP.

  LOOP AT ITAB2 WHERE JRBATCH1 NE ''.
    ITAB = ITAB2.
    SELECT MATNR CHARG INTO (ITAB-MATNR, ITAB-CHARG) FROM MCH1 WHERE LICHA = ITAB-JRBATCH1.
      APPEND ITAB.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      SELECT MATNR CHARG INTO (ITAB-MATNR, ITAB-CHARG) FROM MCH1 WHERE LICHA = ITAB-JRBATCH2.
        APPEND ITAB.
      ENDSELECT.
      IF SY-SUBRC NE 0.
        SELECT MATNR CHARG INTO (ITAB-MATNR, ITAB-CHARG) FROM MCH1 WHERE LICHA = ITAB-JRBATCH3.
          APPEND ITAB.
        ENDSELECT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 0.
  ENDIF.

  V_TIPE = '0'.

  PERFORM GET_REF.
  PERFORM GET_SRBATCH_WEIGHT.
  SORT ITAB BY EBELN EBELP CHARG.
ENDFORM.                    "get_data

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      SET SCREEN 0.

    WHEN 'GRN'.
      PERFORM SELECT_LINES.
      PERFORM GET_DOSERVICE.
      PERFORM F_GRN.
      CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.
    WHEN 'OTX'.
      PERFORM SELECT_LINES.
      PERFORM F_OTOX.
      CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.

  ENDCASE.

  CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.
ENDMODULE.                 " USER_COMMAND_0100  INPUT


*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV.
  DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.

  PERFORM PREPARE_LAYOUT CHANGING GS_LAYOUT .
  PERFORM PREPARE_FIELD_CATALOG CHANGING GT_FIELDCAT .
  PERFORM EXCLUDE_TB_FUNCTIONS CHANGING LT_EXCLUDE.

  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.

  CREATE OBJECT GRID1
    EXPORTING
      I_PARENT = DIALOG_BOX.


  CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = ITAB[]
      IT_FIELDCATALOG      = GT_FIELDCAT.

  CREATE OBJECT G_EVENT_RECEIVER.
  SET HANDLER G_EVENT_RECEIVER->CATCH_DOUBLECLICK FOR GRID1.

ENDFORM.                    "display_alv


*&---------------------------------------------------------------------*
*&      Form  prepare_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM PREPARE_LAYOUT  CHANGING P_GS_LAYOUT TYPE LVC_S_LAYO.
  P_GS_LAYOUT-ZEBRA = '' .
  P_GS_LAYOUT-SMALLTITLE = 'X' .
  P_GS_LAYOUT-BOX_FNAME = 'BOX'.
  P_GS_LAYOUT-EDIT = ''.
  P_GS_LAYOUT-SEL_MODE = 'A'.
  P_GS_LAYOUT-INFO_FNAME = 'LINE_COLOR'.

  GS_VARIANT-REPORT = SY-REPID.
ENDFORM.                    " prepare_layout



*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'MAIN100'.
ENDMODULE.                 " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FCAT     text
*----------------------------------------------------------------------*
FORM PREPARE_FIELD_CATALOG  CHANGING P_FCAT TYPE LVC_T_FCAT .
  DATA: V_POS LIKE SY-TABIX.
  DATA M_FIELDCAT TYPE LVC_S_FCAT .

  CLEAR: M_FIELDCAT, V_POS.
  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-TABNAME = 'ITAB'.
  M_FIELDCAT-FIELDNAME = 'ICONS'.
  M_FIELDCAT-OUTPUTLEN = 4.
  M_FIELDCAT-REPTEXT = 'Status'.
  M_FIELDCAT-KEY = ''.
  APPEND M_FIELDCAT TO P_FCAT.

  CLEAR: M_FIELDCAT, V_POS.
  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'EBELN'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'PO NUmber'.
  APPEND M_FIELDCAT TO P_FCAT.

  CLEAR: M_FIELDCAT, V_POS.
  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'EBELP'.
  M_FIELDCAT-OUTPUTLEN = 6.
  M_FIELDCAT-REPTEXT = 'PO Item'.
  APPEND M_FIELDCAT TO P_FCAT.

  CLEAR: M_FIELDCAT, V_POS.
  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'JRMATNR'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Mat Component'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'JRBATCH1'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Inputan-1'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'JRBATCH2'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Inputan-2'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'JRBATCH3'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Inputan-3'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'JRTOT'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Inputan (KG)'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'MATNR'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'SR Material'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'CHARG'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'SR Batch'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'SROKG'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'SR weight'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'MBLNR'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'GRN doc.'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'MATNRX'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Material-X'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'CHARGX'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Batch mat-X'.
  APPEND M_FIELDCAT TO P_FCAT.


  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'MBLNRX'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'GRN doc. Mat-X'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'ZZNOMORROLL'.
  M_FIELDCAT-OUTPUTLEN = 22.
  M_FIELDCAT-REPTEXT = 'Roll Trias'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'ZZNOROLLTOYOBO'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Roll Number'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'ZZNOLOTTOYOBO'.
  M_FIELDCAT-OUTPUTLEN = 10.
  M_FIELDCAT-REPTEXT = 'Lot Number'.
  APPEND M_FIELDCAT TO P_FCAT.

  V_POS = V_POS + 1.
  M_FIELDCAT-COL_POS = V_POS.
  M_FIELDCAT-FIELDNAME = 'REMARK'.
  M_FIELDCAT-OUTPUTLEN = 50.
  M_FIELDCAT-REPTEXT = 'Remark'.
  APPEND M_FIELDCAT TO P_FCAT.

ENDFORM.                    "prepare_field_catalog


*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
ENDFORM.                               " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROG       text
*      -->SCR        text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO


*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  SELECT_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_LINES.
  ITAB-BOX = ''.
  MODIFY ITAB TRANSPORTING BOX WHERE BOX NE ''.

  CALL METHOD GRID1->CHECK_CHANGED_DATA.

  CALL METHOD GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO[].

  LOOP AT LT_ROW_NO.
    READ TABLE ITAB INDEX LT_ROW_NO-ROW_ID.
    IF SY-SUBRC = 0.
      ITAB-BOX = 'X'.
      MODIFY ITAB INDEX LT_ROW_NO-ROW_ID.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "set_lineselection



*&---------------------------------------------------------------------*
*&      Form  f_grn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GRN.
  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM+0(4) INTO V_DATE SEPARATED BY '.'.
  SORT ITAB BY EBELN EBELP CHARG.

  LOOP AT ITAB WHERE BOX = 'X' AND CHARG NE '' AND VBELN NE '' AND ERR = ''.
    REFRESH: IT_BDCDATA, IT_BDCMSGCOLL.
    CLEAR: IT_BDCDATA, IT_BDCMSGCOLL.

    IF ITAB-MBLNR IS NOT INITIAL.
      ITAB-REMARK = 'Batch telah di GRN'.
      ITAB-ICONS = '@09@'.  " Y:'@09@' G:'@08@'
      MODIFY ITAB.
      CONTINUE.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_GO'.
    PERFORM BDC_FIELD       USING 'GODYNPRO-ACTION'         'A01'.
    PERFORM BDC_FIELD       USING 'GODYNPRO-REFDOC'         'R01'.
    PERFORM BDC_FIELD       USING 'GODEFAULT_TV-BWART'      '101'.
    PERFORM BDC_FIELD       USING 'GOHEAD-MUEBS'            'ZMM1'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GODYNPRO-PO_ITEM'.
    PERFORM BDC_FIELD       USING 'GODYNPRO-PO_NUMBER'      ITAB-EBELN.
    PERFORM BDC_FIELD       USING 'GODYNPRO-PO_ITEM'        ITAB-EBELP.
*    PERFORM BDC_FIELD       USING 'GOHEAD-WEVER'            '1'.
*    PERFORM BDC_FIELD       USING 'GOHEAD-XNAPR'            ''.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                 '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '=MIGO_OK_DETAIL_CLOSE'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_GO'.
    PERFORM BDC_FIELD       USING 'GOITEM-TAKE_IT(01'       'X'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=MIGO_OK_EXPAND'.

    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GOITEM-EXPAND(01)'.

*    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_ZEILE'   '   1'.
*    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_TAKE'    'X'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_GO'.
*    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GOITEM-ERFMG'.
    V_TXT20 = ITAB-SROKG. CONDENSE V_TXT20.
    PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(01)'            V_TXT20. "qty batch

    IF ITAB-RSPOS = '0001'.
      V_TXT20 = ITAB-JRKG1. CONDENSE V_TXT20.
      PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(02)'            V_TXT20. "qty batch

      IF ITAB-JRBATCH2 NE ''.
        V_TXT20 = ITAB-JRKG2. CONDENSE V_TXT20.
        PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(03)'            V_TXT20. "qty batch
      ENDIF.
      IF ITAB-JRBATCH3 NE ''.
        V_TXT20 = ITAB-JRKG3. CONDENSE V_TXT20.
        PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(04)'            V_TXT20. "qty batch
      ENDIF.
    ELSE.
      V_TXT20 = '0'.
      PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(02)'            V_TXT20. "qty batch

      IF ITAB-JRBATCH2 NE ''.
        V_TXT20 = '0'.
        PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(03)'            V_TXT20. "qty batch
      ENDIF.
      IF ITAB-JRBATCH3 NE ''.
        V_TXT20 = '0'.
        PERFORM BDC_FIELD       USING 'GOITEM-ERFMG(04)'            V_TXT20. "qty batch
      ENDIF.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=MIGO_OK_DETAIL_OPEN'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_GO'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GOITEM-WEMPF'.
    PERFORM BDC_FIELD       USING 'GOITEM-LGOBE'            '2804'.
    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_TAKE'    'X'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_GO'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GOITEM-CHARG'.
    PERFORM BDC_FIELD       USING 'GOITEM-CHARG'            ITAB-CHARG.
*    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_TAKE'    'X'.

    PERFORM BDC_DYNPRO      USING 'SAPLMIGO'                '0001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'              '=OK_POST1'.
    PERFORM BDC_FIELD       USING 'GODEFAULT_TV-BWART'      '101'.
    PERFORM BDC_FIELD       USING 'GOHEAD-BLDAT'            V_DATE.
    PERFORM BDC_FIELD       USING 'GOHEAD-LFSNR'            ITAB-VBELN.
    PERFORM BDC_FIELD       USING 'GOHEAD-BUDAT'            V_DATE.
    PERFORM BDC_FIELD       USING 'GOHEAD-BKTXT'            SY-UNAME.
    PERFORM BDC_FIELD       USING 'GOHEAD-WEVER'            '1'.
    PERFORM BDC_FIELD       USING 'GOHEAD-XNAPR'            ''.
    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_ZEILE'   '   1'.
    PERFORM BDC_FIELD       USING 'GOITEM-MIGO_ELIKZ'       '1'.
    PERFORM BDC_FIELD       USING 'GOITEM-BWART'            '101'.
    PERFORM BDC_FIELD       USING 'GOITEM-MIGO_INSMK'       ''.
    PERFORM BDC_FIELD       USING 'GOITEM-LGOBE'            '2804'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'              'GOITEM-CHARG'.
    PERFORM BDC_FIELD       USING 'GODYNPRO-DETAIL_TAKE'    'X'.

    OPT-DISMODE = 'N'.
    CALL TRANSACTION 'MIGO_GR' USING IT_BDCDATA OPTIONS FROM OPT MESSAGES INTO IT_BDCMSGCOLL.

    READ TABLE IT_BDCMSGCOLL WITH KEY MSGNR = '012'.
    IF SY-SUBRC EQ 0.
      ITAB-MBLNR = IT_BDCMSGCOLL-MSGV1.
      SELECT SINGLE TEXT INTO ITAB-REMARK FROM T100 WHERE SPRSL = 'E' AND ARBGB = 'MIGO' AND MSGNR = '012'.
      IF SY-SUBRC = 0.
        REPLACE FIRST OCCURRENCE OF '&' IN ITAB-REMARK WITH IT_BDCMSGCOLL-MSGV1.
        ITAB-ICONS = '@08@'.
        ITAB-ERR = 'X'.
      ENDIF.
    ELSE.
      READ TABLE IT_BDCMSGCOLL INDEX 1.
      IF IT_BDCMSGCOLL-MSGNR EQ '064' AND IT_BDCMSGCOLL-MSGID EQ 'M7'.
        CONCATENATE 'PO' IT_BDCMSGCOLL-MSGV1 '/' ITAB-JRBATCH1 'sudah penuh' INTO ITAB-REMARK SEPARATED BY SPACE.
      ELSEIF IT_BDCMSGCOLL-MSGNR EQ '344' AND IT_BDCMSGCOLL-MSGID EQ '00' OR IT_BDCMSGCOLL IS INITIAL.
        CONCATENATE 'Error saat GRN PO' ITAB-EBELN INTO ITAB-REMARK SEPARATED BY SPACE.
      ELSE.
        SELECT SINGLE TEXT INTO ITAB-REMARK FROM T100
        WHERE SPRSL = 'E' AND ARBGB = IT_BDCMSGCOLL-MSGID AND MSGNR = IT_BDCMSGCOLL-MSGNR.
      ENDIF.

      ITAB-ICONS = '@0A@'.  " Y:'@09@' G:'@08@'
      REPLACE FIRST OCCURRENCE OF '&' IN ITAB-REMARK WITH IT_BDCMSGCOLL-MSGV1.
      REPLACE FIRST OCCURRENCE OF '&' IN ITAB-REMARK WITH IT_BDCMSGCOLL-MSGV2.
    ENDIF.

    MODIFY ITAB.
  ENDLOOP.
  SORT ITAB BY EBELN EBELP CHARG.
ENDFORM.                    "f_grn

*&---------------------------------------------------------------------*
*&      Form  f_otox
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_OTOX.
  DATA: V_YEAR(4).
  V_YEAR = SY-DATUM+0(4).

  LOOP AT ITAB WHERE BOX = 'X' AND MBLNR NE '' AND CHARGX = ''.
    CONCATENATE ITAB-MATNR+0(5) 'X' INTO ITAB-MATNRX.
    REFRESH: IT_BDCDATA, IT_BDCMSGCOLL.
    CLEAR: IT_BDCDATA, IT_BDCMSGCOLL.

    PERFORM BDC_DYNPRO      USING 'ZPPI_ADJ_MAT_PURCHASE'      '7000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'                 '=BTNGO'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'                 'RB_MAINTAIN'.
    PERFORM BDC_FIELD       USING 'RB_MAINTAIN'                'X'.

    PERFORM BDC_DYNPRO      USING 'ZPPI_ADJ_MAT_PURCHASE'      '7100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'                 '=BTN_MGO'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'                 'SO_NIK-LOW'.
    PERFORM BDC_FIELD       USING 'SO_PLANT-LOW'               'TTE'.
    PERFORM BDC_FIELD       USING 'SO_MBLNR-LOW'               ITAB-MBLNR.   "'5000066135'.
    PERFORM BDC_FIELD       USING 'SO_MJAHR-LOW'               V_YEAR.  "'2020'.
    PERFORM BDC_FIELD       USING 'SO_NIK-LOW'                 '     943'.

    PERFORM BDC_DYNPRO      USING 'ZPPI_ADJ_MAT_PURCHASE'      '7100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'                 '=POST'.
    PERFORM BDC_FIELD       USING 'SO_MJAHR-LOW'               V_YEAR.   "'2020'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'                 'WA_MAINTAIN-VERID(01)'.
    PERFORM BDC_FIELD       USING 'WA_MAINTAIN-MTRPO(01)'      ITAB-MATNRX.   "'SRRABX'.
    PERFORM BDC_FIELD       USING 'WA_MAINTAIN-VERID(01)'      '0001'.
    PERFORM BDC_FIELD       USING 'WA_MAINTAIN-FLAGS(01)'      'X'.

    OPT-DISMODE = 'N'.
    OPT-UPDMODE  = 'S'.
    OPT-RACOMMIT = 'X'.

    CALL TRANSACTION 'ZPP018' USING IT_BDCDATA OPTIONS FROM OPT MESSAGES INTO IT_BDCMSGCOLL.
    READ TABLE IT_BDCMSGCOLL WITH KEY MSGNR = '176' MSGID = 'C2'.
    IF SY-SUBRC = 0.
      ITAB-REMARK = 'O to X sukses'.
      ITAB-ICONS = '@08@'.
      ITAB-ERR = 'X'.
      V_TIPE = '1'.
    ELSE.
      READ TABLE IT_BDCMSGCOLL INDEX 1.
      ITAB-REMARK = IT_BDCMSGCOLL-MSGV1.
      ITAB-ERR = 'X'.
      ITAB-ICONS = '@0A@'.
    ENDIF.
    MODIFY ITAB.
  ENDLOOP.

  PERFORM GET_MATX.
ENDFORM.                    "f_otox

*&---------------------------------------------------------------------*
*&      Form  get_ref
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_REF.
*- GRN
  LOOP AT ITAB.
    CLEAR ITAB-MBLNR.
    SELECT SINGLE MBLNR INTO ITAB-MBLNR FROM MSEG WHERE EBELN = ITAB-EBELN AND EBELP = ITAB-EBELP AND BWART = '101' AND CHARG = ITAB-CHARG
       AND MBLNR NOT IN ( SELECT SMBLN FROM MSEG WHERE EBELN = ITAB-EBELN AND EBELP = ITAB-EBELP AND BWART EQ '102' AND CHARG = ITAB-CHARG ).

    IF SY-SUBRC NE 0.
      CLEAR: ITAB-MBLNR.
      ITAB-MBLNR = ''.
    ENDIF.

    MODIFY ITAB.
  ENDLOOP.

*- O to X
  PERFORM GET_MATX.
ENDFORM.                    "get_ref



*&---------------------------------------------------------------------*
*&      Form  get_do_service
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DOSERVICE.
  SORT ITAB BY EBELN.
  LOOP AT ITAB WHERE EBELN NE ''.
    IF ITAB-EBELN = V_EBELN.
      CONTINUE.
    ENDIF.

    CONCATENATE 'SBC' ITAB-EBELN INTO V_ARKTX.
    CONDENSE V_ARKTX.
    SELECT SINGLE A~VBELN INTO ITAB-VBELN
      FROM LIKP AS A JOIN LIPS AS B ON A~VBELN = B~VBELN
      WHERE A~LFART = 'ZDSV' AND B~ARKTX = V_ARKTX.
    IF SY-SUBRC EQ 0.
      WRITE ITAB-VBELN TO ITAB-VBELN NO-ZERO.
      MODIFY ITAB TRANSPORTING VBELN WHERE EBELN = ITAB-EBELN.
    ELSE.
      CONCATENATE 'PO number' V_ARKTX 'tidak ada di DO Service' INTO ITAB-REMARK SEPARATED BY SPACE.
      ITAB-ICONS = '@0A@'.
      MODIFY ITAB TRANSPORTING ICONS REMARK WHERE EBELN = ITAB-EBELN.
    ENDIF.
    V_EBELN = ITAB-EBELN.
  ENDLOOP.

ENDFORM.                    "get_do_service

*&---------------------------------------------------------------------*
*&      Form  get_matx
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MATX.
  LOOP AT ITAB WHERE MBLNR NE ''.
    CLEAR: ITAB-MATNRX, ITAB-CHARGX, ITAB-MBLNRX.
    SELECT AUFNR INTO ITAB-AUFNR FROM MSEG WHERE CHARG = ITAB-CHARG AND BWART = '261' AND
      MBLNR NOT IN ( SELECT SMBLN FROM MSEG WHERE CHARG = ITAB-CHARG AND BWART EQ '262' ).
      SELECT CHARG INTO ITAB-CHARGX FROM MSEG WHERE AUFNR = ITAB-AUFNR AND BWART = '101'.
        SELECT MATNR CHARG MBLNR INTO (ITAB-MATNRX, ITAB-CHARGX, ITAB-MBLNRX) FROM MSEG WHERE CHARG = ITAB-CHARGX AND BWART = '101'.
          SELECT SINGLE MBLNR INTO V_SMBLN FROM MSEG WHERE SMBLN = ITAB-MBLNRX.
          IF SY-SUBRC EQ 0.
            CLEAR: ITAB-MATNRX, ITAB-CHARGX, ITAB-MBLNRX.
          ELSE.
            EXIT.
          ENDIF.
        ENDSELECT.
        EXIT.
      ENDSELECT.   "101
      EXIT.
    ENDSELECT.    "261

    IF ITAB-MBLNR IS NOT INITIAL AND ITAB-MBLNRX IS NOT INITIAL AND V_TIPE EQ '0'.
      ITAB-REMARK = 'Transaksi selesai'.
      ITAB-ERR = 'X'.
      ITAB-ICONS = '@09@'.  " Y:'@09@' G:'@08@'
      MODIFY ITAB.

    ENDIF.

    IF ITAB-MATNRX IS NOT INITIAL AND ITAB-CHARGX IS NOT INITIAL.
      PERFORM GET_CHARACTERISTIC USING ITAB-MATNRX ITAB-CHARGX CHANGING ITAB-ZZNOMORROLL ITAB-ZZNOROLLTOYOBO ITAB-ZZNOLOTTOYOBO.
    ENDIF.

    MODIFY ITAB.
  ENDLOOP.
ENDFORM.                    "get_matx

*&---------------------------------------------------------------------*
*&      Form  GET_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MATNR      text
*      -->CHARG      text
*      -->ROLTR      text
*      -->NOROL      text
*      -->NOLOT      text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC USING MATNR CHARG CHANGING ROLTR NOROL NOLOT.
  DATA: IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
  DATA: V_ZZNOLOTTOYOBO   LIKE CABN-ATINN,
        V_ZZNOROLLTOYOBO  LIKE CABN-ATINN,
        V_ZZNOMORROLL     LIKE CABN-ATINN.

  SELECT SINGLE ATINN INTO V_ZZNOROLLTOYOBO FROM CABN WHERE ATNAM = 'ZZNOROLLTOYOBO'.
  SELECT SINGLE ATINN INTO V_ZZNOLOTTOYOBO  FROM CABN WHERE ATNAM = 'ZZNOLOTTOYOBO'.
  SELECT SINGLE ATINN INTO V_ZZNOMORROLL    FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.

  "Get Char X
  SELECT
    AUSP~ATINN AS ATINN
    AUSP~ATWRT AS ATWRT
    AUSP~ATFLV AS ATFLV
  FROM AUSP JOIN MCH1 ON AUSP~OBJEK  = MCH1~CUOBJ_BM
  INTO CORRESPONDING FIELDS OF TABLE IT_CHAR
  WHERE MCH1~MATNR = MATNR
    AND MCH1~CHARG = CHARG
    AND AUSP~KLART = '023'
    AND AUSP~ATINN IN (V_ZZNOROLLTOYOBO, V_ZZNOLOTTOYOBO, V_ZZNOMORROLL).

  IF SY-SUBRC EQ 0.
    LOOP AT IT_CHAR.
      IF IT_CHAR-ATINN      = V_ZZNOMORROLL.
        ROLTR               = IT_CHAR-ATWRT.
      ELSEIF IT_CHAR-ATINN  = V_ZZNOROLLTOYOBO.
        NOROL               = IT_CHAR-ATWRT.
      ELSEIF IT_CHAR-ATINN  = V_ZZNOLOTTOYOBO.
        NOLOT               = IT_CHAR-ATWRT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "GET_CHARACTERISTIC

*&---------------------------------------------------------------------*
*&      Form  get_srbatch_weight
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SRBATCH_WEIGHT.
  DATA: V_SISA LIKE MCHB-CLABS.

*- SROKG
  LOOP AT ITAB.
    SELECT SINGLE B~ATFLV INTO ITAB-SROKG
      FROM MCH1 AS A JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
      WHERE A~CHARG = ITAB-CHARG AND B~ATINN = V_ATKG.

    MODIFY ITAB.
  ENDLOOP.

*- SROtot
  SORT ITAB BY EBELN EBELP CHARG.
  LOOP AT ITAB.
    IT_INPUT-EBELN = ITAB-EBELN.
    IT_INPUT-EBELP = ITAB-EBELP.
    IT_INPUT-SROTOT = ITAB-SROKG.
    COLLECT IT_INPUT.
  ENDLOOP.

  LOOP AT IT_INPUT.
    CLEAR ITAB2-RSPOS.
    LOOP AT ITAB WHERE EBELN = IT_INPUT-EBELN AND EBELP = IT_INPUT-EBELP.
      ITAB2-RSPOS = ITAB2-RSPOS + 1.
      ITAB-RSPOS = ITAB2-RSPOS.
      MODIFY ITAB TRANSPORTING RSPOS WHERE EBELN = ITAB-EBELN AND EBELP = ITAB-EBELP AND CHARG = ITAB-CHARG.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "get_srbatch_weight

*INCLUDE ZMMI_GRN_SUBCON_TTE_USER_COI01.