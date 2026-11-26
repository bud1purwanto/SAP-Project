*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_LIST_F01
*&---------------------------------------------------------------------*
DATA : VTLINENO TYPE VTLINENO5.
DATA : CUOBJ TYPE INOB-CUOBJ.
DATA ITAB_VALUES TYPE TABLE OF CONF_OUT WITH HEADER LINE.
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       process to create output data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
CONSTANTS GB_DISPLAY_ITEMS TYPE FLAG VALUE C_NO.

*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_REPORT .
  TYPES:
    BEGIN OF LT_PARTNERS,
      VBELN LIKE VBPA-VBELN,
      PARVW LIKE VBPA-PARVW,
      NAME1 LIKE KNA1-NAME1,
    END OF LT_PARTNERS.

  DATA:
    ITAB_PARTNERS TYPE HASHED TABLE OF LT_PARTNERS
      WITH UNIQUE KEY VBELN PARVW
      WITH HEADER LINE.

  IF R1 = C_YES.
    S_PINST-LOW    = 'N'.
    S_PINST-SIGN   = 'I'.
    S_PINST-OPTION = 'EQ'.
    APPEND S_PINST.
  ENDIF.
  IF R2 = C_YES.
    S_PINST-LOW     = 'A'.
    S_PINST-SIGN    = 'I'.
    S_PINST-OPTION  = 'EQ'.
    APPEND S_PINST.
  ENDIF.
  IF R3 = C_YES.
    S_PINST-LOW     = 'I'.
    S_PINST-SIGN    = 'I'.
    S_PINST-OPTION  = 'EQ'.
    APPEND S_PINST.
  ENDIF.
  IF R4 = C_YES.
    S_PINST-LOW     = 'C'.
    S_PINST-SIGN    = 'I'.
    S_PINST-OPTION  = 'EQ'.
    APPEND S_PINST.
  ENDIF.

  SELECT
    ZPACK_PCH~PINNR
    ZPACK_PCH~VBELN
    ZPACK_PCH~POSNR
    ZPACK_PCH~WERKS
    ZPACK_PCH~LGORT
    ZPACK_PCH~DESCR
    ZPACK_PCH~PINST
    ZPACK_PCH~CRNAM
    ZPACK_PCH~CRDAT
    ZPACK_PCH~CRTIM
    ZPACK_PCH~AENAM
    ZPACK_PCH~AEDAT
    ZPACK_PCH~AETIM
    ZPACK_PCH~ZZCRITERIABF
    ZPACK_PCH~ZZCRITERIA1
    ZPACK_PCH~ZZCRITERIA2
    ZPACK_PCH~ZZCRITERIAR
    ZPACK_PCH~ZZCORE3
    ZPACK_PCH~ZZCORE6
    ZPACK_PCH~ZZSHEET
  INTO CORRESPONDING FIELDS OF TABLE
    ITAB_OUTPUT
  FROM ZPACK_PCH
  WHERE ZPACK_PCH~PINNR IN S_PINNR
    AND ZPACK_PCH~VBELN IN S_VBELN
    AND ZPACK_PCH~POSNR IN S_POSNR
    AND ZPACK_PCH~WERKS IN S_WERKS
    AND ZPACK_PCH~LGORT IN S_LGORT
    AND ZPACK_PCH~PINST IN S_PINST
    AND ZPACK_PCH~CRNAM IN S_CRNAM
    AND ZPACK_PCH~CRDAT IN S_CRDAT.

  IF ( SY-SUBRC EQ 0 ).
    IF ( GB_DISPLAY_ITEMS = C_YES ).
      SELECT
        ZPACK_PC~PINNR
        ZPACK_PC~ZINS01
        ZPACK_PC~ZINS02
        ZPACK_PC~ZINS03
        ZPACK_PC~MATNR
        MAKT~MAKTX
        ZPACK_PC~ZMENG
        ZPACK_PC~MEINS
      INTO TABLE
        ITAB_OUTPUT_ITEM
      FROM ZPACK_PC
        INNER JOIN MAKT ON ZPACK_PC~MATNR = MAKT~MATNR
      FOR ALL ENTRIES IN ITAB_OUTPUT
      WHERE ZPACK_PC~PINNR = ITAB_OUTPUT-PINNR.

    ENDIF.

*   load shipto and soldto partners into itab
    SELECT VBELN PARVW NAME1
      INTO TABLE ITAB_PARTNERS
      FROM VBPA
        INNER JOIN KNA1 ON VBPA~KUNNR = KNA1~KUNNR
      FOR ALL ENTRIES IN ITAB_OUTPUT
      WHERE VBPA~VBELN = ITAB_OUTPUT-VBELN
        AND VBPA~PARVW IN (C_PARTNER_SHIPTO, C_PARTNER_SOLDTO).

    LOOP AT ITAB_OUTPUT.

*     read and set shipto name
      READ TABLE ITAB_PARTNERS
        WITH KEY
          VBELN = ITAB_OUTPUT-VBELN
          PARVW = C_PARTNER_SHIPTO.

      IF SY-SUBRC EQ 0.
        ITAB_OUTPUT-SHIPTO = ITAB_PARTNERS-NAME1.
      ENDIF.

*     read and set soldto name
      READ TABLE ITAB_PARTNERS
        WITH KEY
          VBELN = ITAB_OUTPUT-VBELN
          PARVW = C_PARTNER_SOLDTO.

      IF SY-SUBRC EQ 0.
        ITAB_OUTPUT-SOLDTO = ITAB_PARTNERS-NAME1.
      ENDIF.

*     convert status to text
      CASE ITAB_OUTPUT-PINST.
        WHEN C_PINST_INACTIVE.    ITAB_OUTPUT-STATUS = 'Inactive'.
        WHEN C_PINST_ACTIVE.      ITAB_OUTPUT-STATUS = 'Active'.
        WHEN C_PINST_INPROGRESS.  ITAB_OUTPUT-STATUS = 'In Progress'.
        WHEN C_PINST_COMPLETED.   ITAB_OUTPUT-STATUS = 'Completed'.
      ENDCASE.

*     material
      SELECT SINGLE MATNR INTO ITAB_OUTPUT-MATNR
        FROM ZPACK_PCH
        WHERE PINNR  = ITAB_OUTPUT-PINNR.

      IF SY-TABIX = 0.
        CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
          EXPORTING
            VAR_TABLE       = 'ZZCODE'
          TABLES
            VAR_TAB_ENTRIES = VTENTRIES.
      ENDIF.

      READ TABLE VTENTRIES WITH KEY VTCHARACT = 'ZZCODE'
                                    VTVALUE   = ITAB_OUTPUT-MATNR+2(3).
      IF SY-SUBRC = 0.
        VTLINENO = VTENTRIES-VTLINENO.

*    tipe
        READ TABLE VTENTRIES WITH KEY VTLINENO    = VTLINENO
                                      VTCHARACT = 'ZZTYPE'.
        ITAB_OUTPUT-ZZTYPE = VTENTRIES-VTVALUE.

*    thickness
        READ TABLE VTENTRIES WITH KEY VTLINENO    = VTLINENO
                                      VTCHARACT = 'ZZTHICKNESS'.
        ITAB_OUTPUT-ZZTHICKNESS = VTENTRIES-VTVALUE.
      ENDIF.

      IF ITAB_OUTPUT-VBELN NE ''.
        CLEAR : CUOBJ,ITAB_VALUES.
        REFRESH : ITAB_VALUES.
        SELECT SINGLE CUOBJ INTO CUOBJ
         FROM VBAP
         WHERE VBELN = ITAB_OUTPUT-VBELN
         AND   POSNR = ITAB_OUTPUT-POSNR.

        CALL FUNCTION 'VC_I_GET_CONFIGURATION'
          EXPORTING
            INSTANCE       = CUOBJ
          TABLES
            CONFIGURATION  = ITAB_VALUES
          EXCEPTIONS
            NO_CLASS       = 1
            INTERNAL_ERROR = 2
            NO_VALUES      = 3
            NO_CHARS       = 4
            OTHERS         = 5.

        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCORE'.
        IF SY-SUBRC EQ 0.
          ITAB_OUTPUT-ZZCORE = ITAB_VALUES-ATWRT.
        ENDIF.
        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZCRITERIA'.
        IF SY-SUBRC EQ 0.
          ITAB_OUTPUT-ZZCRITERIA = ITAB_VALUES-ATWTB.
        ENDIF.
        READ TABLE ITAB_VALUES WITH KEY ATNAM = 'ZZPACKING'.
        IF SY-SUBRC EQ 0.
          IF ITAB_VALUES-ATWRT = 'SP'.
            ITAB_OUTPUT-PACKING = 'Pallet'.
          ELSEIF ITAB_VALUES-ATWRT = 'BB'.
            ITAB_OUTPUT-PACKING = 'Box'.
          ELSEIF ITAB_VALUES-ATWRT = 'BK'.
            ITAB_OUTPUT-PACKING = 'Box'.
          ENDIF.
        ENDIF.

      ENDIF.


*    core
      IF ITAB_OUTPUT-ZZSHEET NE SPACE.
        ITAB_OUTPUT-ZZCORE = 'Sheet'.
      ELSEIF ITAB_OUTPUT-ZZCORE6 NE SPACE.
        ITAB_OUTPUT-ZZCORE = '6'.
      ELSEIF ITAB_OUTPUT-ZZCORE3 NE SPACE.
        ITAB_OUTPUT-ZZCORE = '3'.
      ENDIF.

*    Criteria
      IF ITAB_OUTPUT-ZZCRITERIABF NE SPACE.
        ITAB_OUTPUT-ZZCRITERIA = 'Base Film'.
      ELSEIF ITAB_OUTPUT-ZZCRITERIA1 NE SPACE.
        ITAB_OUTPUT-ZZCRITERIA = 'First Grade'.
      ELSEIF ITAB_OUTPUT-ZZCRITERIA2 NE SPACE.
        ITAB_OUTPUT-ZZCRITERIA = 'Second Grade'.
      ELSEIF ITAB_OUTPUT-ZZCRITERIAR NE SPACE.
        ITAB_OUTPUT-ZZCRITERIA = 'RW/RS'.
      ENDIF.

*    sistem packing
      CLEAR : T_SIS. REFRESH : T_SIS.
      IF ITAB_OUTPUT-VBELN = ''.
        SELECT INILVL ZMENG
          INTO TABLE T_SIS
          FROM ZPACK_PC
          WHERE PINNR = ITAB_OUTPUT-PINNR.
      ENDIF.

      CLEAR : QTY_PALL, QTY_BOX , LVL1, LVL2 , LVL3.
      LOOP AT T_SIS.
*        IF T_SIS-INILVL = 1.
*          QTY_PALL = QTY_PALL + T_SIS-ZMENG.
*        ELSEIF T_SIS-INILVL = 2.
*          QTY_BOX  = QTY_BOX + T_SIS-ZMENG.
*        ENDIF.
        IF T_SIS-INILVL = 1.
          LVL1 = 'X'.
        ELSEIF T_SIS-INILVL = 2.
          LVL2 = 'X'.
        ELSEIF T_SIS-INILVL = 3.
          LVL3 = 'X'.
        ENDIF.
      ENDLOOP.

*      QTYBP = QTY_BOX / QTY_PALL.
      IF ( LVL1 NE '' AND LVL3 NE '' AND LVL2 = '' ).
        ITAB_OUTPUT-PACKING = 'Pallet'.
      ELSEIF ( LVL1 NE '' AND LVL2 NE '' AND LVL3 NE  ''  ).
        ITAB_OUTPUT-PACKING = 'Box'.
      ENDIF.

      MODIFY ITAB_OUTPUT.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " f_process_report


*&---------------------------------------------------------------------*
*&      Form  f_write_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_WRITE_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " f_write_data

*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB_OUTPUT' :
   'PINNR'       '' ''  '' '12' 'Pck Instruction'  '' 'X' '' '',
   'VBELN'       '' ''  '' '12' 'Sales Order'      '' '' '' '',
   'POSNR'       '' ''  '' '6'  'SO Item'          '' '' '' '',
   'SOLDTO'      '' ''  '' '30' 'Sold-to Party'    '' '' '' '',
   'SHIPTO'      '' ''  '' '30' 'Ship-to Party'    '' '' '' '',
   'STATUS'      '' ''  '' '10' 'Status'           '' '' '' '',
   'DESCR'       '' ''  '' '40' 'Notes'            '' '' '' '',
   'ZZTYPE'      '' ''  '' '20' 'Tipe'             '' '' '' '',
   'ZZTHICKNESS' '' ''  '' '20' 'Thickness'        '' '' '' '',
   'MATNR'       '' ''  '' '30' 'Material Number'  '' '' '' '',
   'ZZCORE'      '' ''  '' '10' 'Core'             '' '' '' '',
   'ZZCRITERIA'  '' ''  '' '10' 'Criteria'         '' '' '' '',
   'PACKING'     '' ''  '' '18' 'Sistem Packing'   '' '' '' '',
   'CRNAM'       '' ''  '' '20' 'Created By'       '' '' '' '',
   'CRDAT'       '' ''  '' '15' 'Created Date'     '' '' '' '',
   'CRTIM'       '' ''  '' '15'  'Created Time'     '' '' '' '',
   'AENAM'       '' ''  '' '20' 'Last Changed By'  '' '' '' '',
   'AEDAT'       '' ''  '' '20' 'Last Change Date' '' '' '' '',
   'AETIM'       '' ''  '' '20'  'Last Change On '  '' ''  '' ''.

  IF GB_DISPLAY_ITEMS = C_YES.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB_OUTPUT_ITEM' :
     'ZINS01'  '' ''  '' '2'  'L1'                   '' '' '' '',
     'ZINS02'  '' ''  '' '2'  'L2'                   '' '' '' '',
     'ZINS03'  '' ''  '' '2'  'L3'                   '' '' '' '',
     'MATNR'   '' ''  '' '10' 'Material No.'         '' '' '' '',
     'MAKTX'   '' ''  '' '30' 'Material Description' '' '' '' '',
     'ZMENG'   '' ''  '' '18' 'Quantity'             '' '' '' '',
     'MEINS'   '' ''  '' '4'  'UoM'                  '' '' '' ''.

  ENDIF.

ENDFORM.                    "f_field_catalog


*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-ZEBRA               = C_YES.
  WA_LAYOUT-CONFIRMATION_PROMPT = C_NO.
  WA_LAYOUT-SUBTOTALS_TEXT      = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT         = 'Total'.
  WA_LAYOUT-CELL_MERGE          = C_YES.
*  WA_LAYOUT-COLWIDTH_OPTIMIZE   = C_YES.

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
  D_REPID                    = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  WA_KEYINFO-HEADER01        = 'PINNR'.
  WA_KEYINFO-ITEM01          = 'PINNR'.

  IF GB_DISPLAY_ITEMS = C_YES.
    CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
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
        I_TABNAME_HEADER         = 'ITAB_OUTPUT'
        I_TABNAME_ITEM           = 'ITAB_OUTPUT_ITEM'
        IS_KEYINFO               = WA_KEYINFO
        I_BYPASSING_BUFFER       = 'X'
      TABLES
        T_OUTTAB_HEADER          = ITAB_OUTPUT
        T_OUTTAB_ITEM            = ITAB_OUTPUT_ITEM
      EXCEPTIONS
        PROGRAM_ERROR            = 1
        OTHERS                   = 2.

  ELSE.
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
        T_OUTTAB                 = ITAB_OUTPUT
      EXCEPTIONS
        PROGRAM_ERROR            = 1
        OTHERS                   = 2.

  ENDIF.

ENDFORM.                    " f_list_detail


*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA LT_HUS TYPE HUM_VENUM_T.
  DATA OPT TYPE CTU_PARAMS.
  DATA : FLAG_START VALUE 'X'.

  OPT-RACOMMIT = 'X'.
  OPT-NOBINPT  = 'X'.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.


  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&IC1'.  "-- hotspot click
      READ TABLE ITAB_OUTPUT INDEX FU_SELFIELD-TABINDEX.
      IF SY-SUBRC EQ 0.
        REFRESH ITAB_BDC.
        FREE MEMORY ID 'ZHUI'.
        EXPORT FLAG_START TO MEMORY ID 'ZHUI'.
        IF ITAB_OUTPUT-VBELN  IS INITIAL.
          PERFORM BDC_DYNPRO      USING 'ZHUI_PACKINST' '9000'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=DISPLAY'.
          PERFORM BDC_FIELD       USING 'ZPACK_PCH-PINNR'
                                        ITAB_OUTPUT-PINNR.

          CALL TRANSACTION 'ZHU4FS' USING ITAB_BDC OPTIONS FROM OPT.

        ELSE.
          PERFORM BDC_DYNPRO  USING 'ZHUI_PACKINST' '9000'.
          PERFORM BDC_FIELD   USING 'BDC_OKCODE'
                                    '=DISPLAY'.
          PERFORM BDC_FIELD   USING 'ZPACK_PCH-VBELN'
                                     ITAB_OUTPUT-VBELN.
          PERFORM BDC_FIELD   USING 'ZPACK_PCH-POSNR'
                                     ITAB_OUTPUT-POSNR.

          CALL TRANSACTION 'ZHU4SO' USING ITAB_BDC OPTIONS FROM OPT.
        ENDIF.

      ENDIF.
  ENDCASE.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  REFRESH FT_EXTAB.

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING FT_EXTAB.

ENDFORM.                    " F_ALV_STATUS


*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR ITAB_BDC.
  ITAB_BDC-PROGRAM  = PROGRAM.
  ITAB_BDC-DYNPRO   = DYNPRO.
  ITAB_BDC-DYNBEGIN = 'X'.

  APPEND ITAB_BDC.

ENDFORM.                    " BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0181   text
*      -->P_0182   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

  CLEAR ITAB_BDC.
  ITAB_BDC-FNAM = FNAM.
  ITAB_BDC-FVAL = FVAL.

  APPEND ITAB_BDC.

ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F4_SPOSNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_SPOSNR .
  SELECT PINNR
         VBELN
         POSNR
         PINST
         ZPACK_PCH~MATNR
         DESCR
         MAKTX AS MAKTX
  FROM ZPACK_PCH
  LEFT OUTER JOIN MAKT ON ZPACK_PCH~MATNR = MAKT~MATNR
  INTO CORRESPONDING FIELDS OF TABLE T_HELP
  WHERE POSNR NE ''.

  SORT T_HELP BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM T_HELP COMPARING VBELN POSNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'POSNR'
      DYNPPROG        = SY-CPROG  "Program
      DYNPNR          = SY-DYNNR  "Dynpro number
      DYNPROFIELD     = 'POSNR'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = T_HELP
      RETURN_TAB      = IT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.                    " F4_SPOSNR
*&---------------------------------------------------------------------*
*&      Form  F4_SVBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_SVBELN .
  SELECT PINNR
         VBELN
         POSNR
         PINST
         ZPACK_PCH~MATNR
         DESCR
         MAKTX AS MAKTX
  FROM ZPACK_PCH
  LEFT OUTER JOIN MAKT ON ZPACK_PCH~MATNR = MAKT~MATNR
  INTO CORRESPONDING FIELDS OF TABLE T_HELP
  WHERE POSNR NE ''.

  SORT T_HELP BY VBELN .
  DELETE ADJACENT DUPLICATES FROM T_HELP COMPARING VBELN .

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VBELN'
      DYNPPROG        = SY-CPROG  "Program
      DYNPNR          = SY-DYNNR  "Dynpro number
      DYNPROFIELD     = 'VBELN'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = T_HELP
      RETURN_TAB      = IT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.                    " F4_SVBELN

*&---------------------------------------------------------------------*
*&      Form  CHECK_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_PLANT.
  DATA: FLAG TYPE STRING,
        PLANT LIKE VBAP-WERKS.

  GET PARAMETER ID 'TSOURCE' FIELD TCODE.

  IF TCODE EQ 'ZHU4FS' OR TCODE EQ 'ZHU4SO'.
    IF S_VBELN IS NOT INITIAL.
      PERFORM CHECK_SO.
    ENDIF.

    PLANT = 'TTA2'.
    IF PLANT IN S_WERKS.
      MESSAGE 'Plant TTA tidak sesuai dengan Tcode yang di gunakan!' TYPE 'I'.
      STOP.
    ENDIF.

    IF TCODE EQ 'ZHU4SO'.
      IF S_VBELN[] IS INITIAL.

      ELSE.
        CLEAR S_WERKS.
        REFRESH S_WERKS.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    "CHECK_PLANT

*&---------------------------------------------------------------------*
*&      Form  CHECK_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SO.
  DATA: MSG TYPE STRING,
         SLSORG LIKE VBAK-VKORG.

  DATA : BEGIN OF IT_VBAK OCCURS 0,
          VBELN TYPE VBAK-VBELN,
          VKORG TYPE VBAK-VKORG,
         END OF IT_VBAK.

  SLSORG = '1000'.
  SELECT VBELN VKORG FROM VBAK INTO CORRESPONDING FIELDS OF TABLE IT_VBAK
    WHERE VBELN IN S_VBELN.

  LOOP AT IT_VBAK.
    IF SLSORG NE IT_VBAK-VKORG.
      CONCATENATE 'SO' IT_VBAK-VBELN 'Tidak Berasal Dari Trias' INTO MSG SEPARATED BY SPACE.
      MESSAGE MSG TYPE 'I'.
      STOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "CHECK_SO