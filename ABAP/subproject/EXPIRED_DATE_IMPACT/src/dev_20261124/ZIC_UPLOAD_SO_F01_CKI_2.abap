*&---------------------------------------------------------------------*
*&  Include           ZIC_UPLOAD_SO_F01_CKI
*&---------------------------------------------------------------------*

FORM F_PROCESS_DATA.
  PERFORM F_GET_UPLOAD_FILE.
  PERFORM F_CATALOG_DATA.
  PERFORM F_DISPLAY_DATA.
ENDFORM.                    "F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_UPLOAD_FILE.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = P_SOURCE
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB2.
ENDFORM.                    "F_UPLOAD_FILE

*&---------------------------------------------------------------------*
*&      Form  F_CATALOG_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CATALOG_DATA.

  "Modify sorting ITAB by Afir 08.12.2020
  UNASSIGN <FS_ITAB2>.
  LOOP AT ITAB2 ASSIGNING <FS_ITAB2>.
    <FS_ITAB2>-NGROUP = <FS_ITAB2>-ZGROUP_PR.
    IF <FS_ITAB2>-ZPRITEM NE ''.
      <FS_ITAB2>-NPRITEM = <FS_ITAB2>-ZPRITEM.
    ELSE.
      <FS_ITAB2>-NPRITEM = <FS_ITAB2>-ZPRITEMREF.
    ENDIF.
  ENDLOOP.
  SORT ITAB2 BY NGROUP NPRITEM.
  "End Modify sorting ITAB by Afir 08.12.2020

  V_FIELDCAT = 'ITAB2'.

  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING V_FIELDCAT :
  'ZGROUP_PR'        '' ''  '' '10'   'Group'                  '' ' ' '' 'X' 'C710',
  'ZPRNO'            '' ''  '' '10'   'Doc.Ref'                '' ' ' '' 'X' 'C710',
  'ZPRITEMREF'        '' ''  '' '10'  'Doc.Ref Item'           '' ' ' '' 'X' 'C710',
  'ZPRTYPE'          '' ''  '' '4'    'PR Type'                '' ' ' '' '' 'C710',
  'ZPRITEM'          '' ''  '' '4'    'PR Item'                '' ' ' '' '' 'C710',
  'ZFILMTYPE_PR'     '' ''  '' '4'    'Type Film'              '' ' ' '' '' 'C710',
  'ZTHICK_PR'        '' ''  '' '10'   'Thickness'              '' ' ' '' '' 'C710',
  'ZROLL_PR'         '' ''  '' '4'    'Jmlh. Roll FGS'         '' ' ' '' '' 'C710',
  'ZRM_PR'           '' ''  '' '7'    'Jmlh. RM'               '' ' ' '' '' 'C710',
  'ZUOM_PR'          '' ''  '' '4'    'Unit'                   '' ' ' '' '' 'C710',
  'ZDLVDATE_PR'      '' ''  '' '10'   'Delivery Date PR'       '' ' ' '' '' 'C710',
  'ZPLANT'           '' ''  '' '10'   'Plant'                  '' ' ' '' '' 'C710',
  'ZPGR_PR'          '' ''  '' '4'    'Purch. Group'           '' ' ' '' '' 'C710',
  'ZREQUESTER_PR'    '' ''  '' '20'   'Requester'              '' ' ' '' '' 'C710',
  'ZCORE_PR'         '' ''  '' '75'   'Core'                   '' ' ' '' '' 'C710',
  'ZWIDTH_PR'        '' ''  '' '75'   'Lebar'                  '' ' ' '' '' 'C710',
  'ZLENGTH_PR'       '' ''  '' '75'   'Panjang'                '' ' ' '' '' 'C710',
  'ZTREAT_PR'        '' ''  '' '75'   'Treatment'              '' ' ' '' '' 'C710',
  'ZGRDFILM_PR'      '' ''  '' '10'   'Grade Film'             '' ' ' '' '' 'C710',
  'ZALIAS_PR'        '' ''  '' '75'   'Alias'                  '' ' ' '' '' 'C710',
  'ZTYPLBL_PR'       '' ''  '' '75'   'Type Label'             '' ' ' '' '' 'C710',
  'ZSPCTOUCH1_PR'    '' ''  '' '75'   'Special Touch 1'        '' ' ' '' '' 'C710',
  'ZSPCTOUCH2_PR'    '' ''  '' '75'   'Special Touch 2'        '' ' ' '' '' 'C710',
  'ZSPCTOUCH3_PR'    '' ''  '' '75'   'Special Touch 3'        '' ' ' '' '' 'C710',
  'ZPACK_PR'         '' ''  '' '75'   'Packing'                '' ' ' '' '' 'C710',
  'ZEXTLENGTH_PR'    '' ''  '' '75'   'Extra Length'           '' ' ' '' '' 'C710',
  'ZKDPACK_PR'       '' ''  '' '75'   'Kode Pack'              '' ' ' '' '' 'C710',
  'ZCUST_PR'         '' ''  '' '75'   'Customer'               '' ' ' '' '' 'C710',
  'ZPO_CUST'         '' ''  '' '75'   'No. PO'                 '' ' ' '' '' 'C710',
  'ZSKU_CODE'        '' ''  '' '75'   'Kode SKU'               '' ' ' '' '' 'C710'.

  PERFORM F_ALV_FIELDCATG_ICON USING V_FIELDCAT :
   " PO
   'ZPOTYPE'          '' ''  '' '4'    'PO Type'                '' ' ' '' '' 'C510',
   'ZVENDOR'          '' ''  '' '4'    'Vendor'                 '' ' ' '' '' 'C510',
   'ZEKORG'           '' ''  '' '4'    'Purch. Organization'    '' ' ' '' '' 'C510',
*   'ZNETPR'           '' ''  '' '16'   'Net Price'              '' ' ' '' '' 'C510',
*   'ZCURR_PO'         '' ''  '' '75'   'Currency'               '' ' ' '' '' 'C510',
   'ZUOMPRICE_PO'     '' ''  '' '75'   'Order Price UoM'        '' ' ' '' '' 'C510',
   'ZFREECHARGE_PO'   '' ''  '' '75'   'Free of Charge'         '' ' ' '' '' 'C510',
   'ZDLVTOLERANCE'    '' ''  '' '10'   'Deliv. Tolerance'       '' ' ' '' '' 'C510',
   'ZMWSKZ'           '' ''  '' '2'    'Tax Code'               '' ' ' '' '' 'C510',
   'ZSLSPERSON'       '' ''  '' '30'   'Sales Person'           '' ' ' '' '' 'C510'.

  CLEAR WA_LAYOUT.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
ENDFORM.                    "F_CATALOG_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*      -->FU_ICON    text
*      -->FU_COLOR   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_FIXCL
                                FU_COLOR.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = ''.
  T_FIELDCAT-FIX_COLUMN    = FU_FIXCL.
  T_FIELDCAT-EMPHASIZE     = FU_COLOR.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    "F_ALV_FIELDCATG_ICON

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZPF_STATUS_DISP'.
ENDFORM.                    "SET_PF_STATUS_500

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_DATA.
  CLEAR V_FLAG.
  V_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = V_REPID
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
    TABLES
      T_OUTTAB                 = ITAB2
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    "F_DISPLAY_DATA

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
    WHEN  'EXEC'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Confirmation'
          TEXT_QUESTION         = 'Apakah anda yakin akan melanjutkan proses ini?'
          TEXT_BUTTON_1         = 'Ya'
          TEXT_BUTTON_2         = 'Tidak'
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = ''
        IMPORTING
          ANSWER                = V_ANSWER.

      IF V_ANSWER EQ '1' AND V_INDC NE 'X'.
        PERFORM F_PROCESS_CREATE.
        PERFORM DISP_ALV.
      ELSEIF V_ANSWER NE '' AND V_INDC EQ 'X'.
        MESSAGE 'Tidak bisa re-eksekusi template upload..!' TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ELSE.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
    WHEN '&IC1'.
      PERFORM F_CLICK_TCODE USING FU_SELFIELD.
    WHEN 'BACK'.
      CALL TRANSACTION 'ZIC008'.
    WHEN 'EXIT' OR 'CLOSE'.
      LEAVE PROGRAM.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_CREATE.

  PERFORM SEPARATE_DATA.

  IF RB_BG2 EQ 'X'.
    PERFORM F_PROCESS_INPUT. "Create from PR

  ELSEIF RB_PR2 EQ 'X'.
    ITAB_PR4[] = ITAB_PR[].
    DELETE ADJACENT DUPLICATES FROM ITAB_PR4 COMPARING ZGROUP_PR.
    LOOP AT ITAB_PR4 INTO WA_PR WHERE ZPRNO IS NOT INITIAL. "Cek jika di template menggunakan PR yg sudah jadi
      PERFORM F_PR_CREATED. "Create dengan inputan PR jadi
      IF V_FLAG NE 'X'.
        PERFORM F_PROCESS_PO. "Create PO
      ENDIF.
      IF V_FLAG EQ 'X'.
        EXIT.
*        ELSE.
*          PERFORM F_PROCESS_SO_IC. "Create SO Intercompany
      ENDIF.
    ENDLOOP.
*    ELSEIF RB_PO2 EQ 'X'.
  ENDIF.

  ITAB_PR4[] = ITAB_PR[].
  DELETE ADJACENT DUPLICATES FROM ITAB_PR4 COMPARING ZGROUP_PR.
  LOOP AT ITAB_PR4 INTO WA_PR WHERE ZPRNO IS NOT INITIAL.
    PERFORM F_PO_CREATED.
    IF V_FLAG NE 'X'.
*      PERFORM F_PROCESS_SO_IC.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "F_PROCESS_CREATE

*&---------------------------------------------------------------------*
*&      Form  SEPARATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SEPARATE_DATA.
  CLEAR  : ITAB_SO, WA_SO.
  REFRESH: ITAB_SO.

  LOOP AT ITAB2 INTO WA_ITAB2.
    "For PR
    ITAB_PR-ZGROUP_PR       = WA_ITAB2-ZGROUP_PR.
    ITAB_PR-ZPRNO           = WA_ITAB2-ZPRNO.
    ITAB_PR-ZPRITEMREF      = WA_ITAB2-ZPRITEMREF.
    ITAB_PR-ZPRTYPE         = WA_ITAB2-ZPRTYPE.
    ITAB_PR-ZPRITEM         = WA_ITAB2-ZPRITEM.
    ITAB_PR-ZFILMTYPE_PR    = WA_ITAB2-ZFILMTYPE_PR.
    ITAB_PR-ZTHICK_PR       = WA_ITAB2-ZTHICK_PR.
    ITAB_PR-ZINOUT_PR       = 'O'."WA_ITAB2-ZINOUT_PR'.
    ITAB_PR-ZROLL_PR        = WA_ITAB2-ZROLL_PR.
    ITAB_PR-ZQTYRM_PR       = WA_ITAB2-ZRM_PR.
    ITAB_PR-ZUOM_PR         = WA_ITAB2-ZUOM_PR.
    ITAB_PR-ZDLVDATE_PR     = WA_ITAB2-ZDLVDATE_PR.
    ITAB_PR-ZPLANT          = WA_ITAB2-ZPLANT.
    ITAB_PR-ZPGR_PR         = WA_ITAB2-ZPGR_PR.
    ITAB_PR-ZREQUESTER_PR   = WA_ITAB2-ZREQUESTER_PR.
    ITAB_PR-ZCORE_PR        = WA_ITAB2-ZCORE_PR.
    ITAB_PR-ZWIDTH_PR       = WA_ITAB2-ZWIDTH_PR.
    ITAB_PR-ZLENGTH_PR      = WA_ITAB2-ZLENGTH_PR.
    ITAB_PR-ZTREAT_PR       = WA_ITAB2-ZTREAT_PR.
    ITAB_PR-ZGRDFILM_PR     = WA_ITAB2-ZGRDFILM_PR.
    ITAB_PR-ZALIAS_PR       = WA_ITAB2-ZALIAS_PR.
    ITAB_PR-ZTYPLBL_PR      = WA_ITAB2-ZTYPLBL_PR.
    ITAB_PR-ZSPCTOUCH1_PR   = WA_ITAB2-ZSPCTOUCH1_PR.
    ITAB_PR-ZSPCTOUCH2_PR   = WA_ITAB2-ZSPCTOUCH2_PR.
    ITAB_PR-ZSPCTOUCH3_PR   = WA_ITAB2-ZSPCTOUCH3_PR.
    ITAB_PR-ZPACK_PR        = WA_ITAB2-ZPACK_PR.
    ITAB_PR-ZEXTLENGTH_PR   = WA_ITAB2-ZEXTLENGTH_PR.
    ITAB_PR-ZKDPACK_PR      = WA_ITAB2-ZKDPACK_PR.
    ITAB_PR-ZCUST_PR        = WA_ITAB2-ZCUST_PR.
    ITAB_PR-ZPO_CUST        = WA_ITAB2-ZPO_CUST.
    ITAB_PR-ZSKU_CODE       = WA_ITAB2-ZSKU_CODE.
    ITAB_PR-NGROUP          = WA_ITAB2-ZGROUP_PR.

    IF WA_ITAB2-ZPRITEM EQ ''.
      ITAB_PR-ZPRITEM = WA_ITAB2-ZPRITEMREF.
    ENDIF.
    APPEND ITAB_PR.

    "For PO
    ITAB_PO-ZGROUP_PO       = WA_ITAB2-ZGROUP_PR.

    IF WA_ITAB2-ZPRNO EQ ''.
      ITAB_PO-ZPOITEM       = WA_ITAB2-ZPRITEM.
    ELSE.
      ITAB_PO-ZPOITEM       = WA_ITAB2-ZPRITEMREF.
    ENDIF.

*      IF RB_PO2 EQ 'X'.
    ITAB_PO-ZPO_NUMBER    = WA_ITAB2-ZPRNO.
    ITAB_PO-ZPOITEM       = WA_ITAB2-ZPRITEMREF.
*      ENDIF.

    ITAB_PO-ZPOTYPE         = WA_ITAB2-ZPOTYPE.
    ITAB_PO-ZVENDOR         = WA_ITAB2-ZVENDOR.
    ITAB_PO-ZEKORG          = WA_ITAB2-ZEKORG.
*    ITAB_PO-ZNETPR          = WA_ITAB2-ZNETPR.
*    ITAB_PO-ZCURR_PO        = WA_ITAB2-ZCURR_PO.
    ITAB_PO-ZUOMPRICE_PO    = WA_ITAB2-ZUOMPRICE_PO.
    ITAB_PO-ZDLVTOLERANCE   = WA_ITAB2-ZDLVTOLERANCE.
    ITAB_PO-ZFREECHARGE_PO  = WA_ITAB2-ZFREECHARGE_PO.
    ITAB_PO-ZMWSKZ          = WA_ITAB2-ZMWSKZ.
    ITAB_PO-ZSLSPERSON      = WA_ITAB2-ZSLSPERSON.
    ITAB_PO-NGROUP          = WA_ITAB2-ZGROUP_PR.
    APPEND ITAB_PO.

    "For SO Intercompany
*      ITAB_SOI-ZGROUP_SOI       = WA_ITAB2-ZGROUP_PR.

*      IF WA_ITAB2-ZPRNO EQ ''.
*        ITAB_SOI-ZSOITEM_SOI    = WA_ITAB2-ZPRITEM.
*        ITAB_SOI-ZSOITEMREF_SOI = WA_ITAB2-ZPRITEM.
*      ELSE.
*        ITAB_SOI-ZSOITEM_SOI    = WA_ITAB2-ZPRITEMREF.
*        ITAB_SOI-ZSOITEMREF_SOI = WA_ITAB2-ZPRITEMREF.
*      ENDIF.

*      ITAB_SOI-ZORDTYPE_SOI     = WA_ITAB2-ZORDTYPE_SOI.
*      ITAB_SOI-ZSLSORG_SOI      = WA_ITAB2-ZSLSORG_SOI.
*      ITAB_SOI-ZDISTCHANEL_SOI  = WA_ITAB2-ZDISTCHANEL_SOI.
*      ITAB_SOI-ZDIVISION_SOI    = WA_ITAB2-ZDIVISION_SOI.
*      ITAB_SOI-ZTYPE_SOI        = WA_ITAB2-ZTYPE_SOI.
*      ITAB_SOI-ZPECAHSCH_SOI    = WA_ITAB2-ZPECAHSCH_SOI.
*      ITAB_SOI-ZPLANT_SOI       = WA_ITAB2-ZPLANT_SOI.
*      ITAB_SOI-ZSHPPOINT_SOI    = WA_ITAB2-ZSHPPOINT_SOI.
*      ITAB_SOI-ZSCHLINE_SOI     = WA_ITAB2-ZSCHLINE_SOI.
*      ITAB_SOI-ZCUST_SOI        = WA_ITAB2-ZCUST_SOI.
*      ITAB_SOI-ZSHIPH_SOI       = WA_ITAB2-ZSHIPH_SOI.
*      ITAB_SOI-ZTYPE_SOI        = WA_ITAB2-ZTYPE_SOI.
*      ITAB_SOI-ZALIAS_SOI       = WA_ITAB2-ZALIAS_SOI.
*      ITAB_SOI-ZINOUT_SOI       = WA_ITAB2-ZINOUT_SOI.
*      ITAB_SOI-ZDLVDATE_SOI     = WA_ITAB2-ZDLVDATE_PR.
*      ITAB_SOI-ZCRITERIA_SOI    = WA_ITAB2-ZCRITERIA_SOI.
*      ITAB_SOI-ZTYPLBL_SOI      = WA_ITAB2-ZTYPLBL_SOI.
*      ITAB_SOI-NGROUP           = WA_ITAB2-ZGROUP_PR.
*      APPEND ITAB_SOI.
  ENDLOOP.
ENDFORM.                    "SEPARATE_DATA

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SO_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS_SO_CUST.
*  PERFORM VALIDATE_SO.
  PERFORM F_VALIDATE_PR.
  PERFORM F_VALIDATE_PO.
*  PERFORM F_VALIDATE_SOI.

  IF V_FLAG NE 'X'.
*    PERFORM PROCESS_SO.
  ENDIF.
ENDFORM.                    "PROCESS_SO_CUST

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDATE_SO.

  ITAB_SO_HEAD[] = ITAB_SO_DETAIL[] = ITAB_SO_SCH[] = ITAB_SCH_DETAIL[] = ITAB_SO[].

  LOOP AT ITAB_SO INTO WA_SO WHERE ZSO IS INITIAL.

    PERFORM F_CHANGEDATE USING WA_SO-ZPODATE_SO CHANGING V_PODATE.
    IF V_PODATE LT SY-DATUM.
      PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Check Tanggal PO' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    PERFORM F_CHANGEDATE USING WA_SO-ZDLVDATE_SO CHANGING V_DLVDATE.
    IF V_DLVDATE LT SY-DATUM.
      PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Check Tanggal Delivery' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    IF V_PODATE GT V_DLVDATE.
      PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Tanggal Delivery harus lebih besar dari tanggal PO' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    SELECT SINGLE KNA1~KUNNR INTO V_KUNNR FROM KNA1 WHERE KNA1~KUNNR = WA_SO-ZCUST_SO.
    IF SY-SUBRC NE 0.
      PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sold to Party tidak ada' 'Error' ''.
      V_FLAG = 'X'.
    ELSE.
      SELECT SINGLE KNVV~WAERS INTO V_WAERS FROM KNVV WHERE KNVV~KUNNR = V_KUNNR.
      IF SY-SUBRC NE 0.
        PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Currency Salah' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.
      SELECT SINGLE KNVV~VKORG INTO V_VKORG FROM KNVV WHERE KNVV~KUNNR = V_KUNNR AND KNVV~VKORG = WA_SO-ZSLSORG_SO.
      IF SY-SUBRC NE 0.
        PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sales Organization untuk Sold to party ini tidak ada' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.
    ENDIF.

    CLEAR: V_KUNNR, V_VKORG.
    SELECT SINGLE KNA1~KUNNR INTO V_KUNNR FROM KNA1 WHERE KNA1~KUNNR = WA_SO-ZSHIPH_SO.
    IF SY-SUBRC NE 0.
      SELECT SINGLE KNVV~VKORG INTO V_VKORG FROM KNVV WHERE KNVV~KUNNR = V_KUNNR AND KNVV~VKORG = WA_SO-ZSLSORG_SO.
      IF SY-SUBRC NE 0.
        PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sales Organization untuk Ship-to-Party ini tidak ada' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM ITAB_SO_HEAD COMPARING ZPO ZORDTYPE_SO ZSLSORG_SO ZDISTCHANEL_SO ZDIVISION_SO ZPODATE_SO ZCUST_SO ZSHIPH_SO
  ZPLANT_SO ZUOM_SO ZPOLINE_SO ZTYPE_SO ZTHICK_SO ZCORE_SO ZROLL_SO ZTYPLBL_SO ZTREAT_SO ZWIDTH_SO ZLENGTH_SO ZCRITERIA_SO ZEXTLENGTH_SO ZPACK_SO ZPRICE_SO
  ZCURR_SO ZUOMPRICE_SO ZKDPACK_SO ZSPCTOUCH1_SO ZSPCTOUCH2_SO ZSPCTOUCH3_SO ZALIAS_SO ZINOUT_SO ZSOITEM.

  LOOP AT ITAB_SO_HEAD INTO WA_SO_HEAD.
    LOOP AT ITAB_SO_DETAIL INTO  WA_SO_DETAIL
                           WHERE ZPO EQ WA_SO_HEAD-ZPO
                           AND   ZSOITEM EQ WA_SO_HEAD-ZSOITEM
                           AND   ZGROUP_SO EQ WA_SO_HEAD-ZGROUP_SO.


      V_PO     = WA_SO_DETAIL-ZPO.
      V_SOITEM = WA_SO_DETAIL-ZSOITEM.

      "Deklarasi Cek Header
      V_ORDTYPE_SO    = WA_SO_DETAIL-ZORDTYPE_SO.
      V_SLSORG_SO     = WA_SO_DETAIL-ZSLSORG_SO.
      V_DISTCHANEL_SO = WA_SO_DETAIL-ZDISTCHANEL_SO.
      V_DIVISION_SO   = WA_SO_DETAIL-ZDIVISION_SO.
      V_PODATE        = WA_SO_DETAIL-ZPODATE_SO.
      V_CUST_SO       = WA_SO_DETAIL-ZCUST_SO.
      V_SHIPH_SO      = WA_SO_DETAIL-ZSHIPH_SO.
      V_PLANT_SO      = WA_SO_DETAIL-ZPLANT_SO.
      "End deklarasi Cek Header

      V_POLINE        = WA_SO_DETAIL-ZPOLINE_SO.
      V_SCHLINE_SO    = WA_SO_DETAIL-ZSCHLINE_SO.
      V_DLVDATE_SO    = WA_SO_DETAIL-ZDLVDATE_SO.
      V_UOM           = WA_SO_DETAIL-ZUOM_SO.
      V_TYPE_SO       = WA_SO_DETAIL-ZTYPE_SO.
      V_THICK         = WA_SO_DETAIL-ZTHICK_SO.
      V_CORE          = WA_SO_DETAIL-ZCORE_SO.
      V_NOROLL        = WA_SO_DETAIL-ZROLL_SO.
      V_TYPLBL_SO     = WA_SO_DETAIL-ZTYPLBL_SO.
      V_TREAT         = WA_SO_DETAIL-ZTREAT_SO.
      V_WIDTH         = WA_SO_DETAIL-ZWIDTH_SO.
      V_LENGTH        = WA_SO_DETAIL-ZLENGTH_SO.
      V_CRITERIA      = WA_SO_DETAIL-ZCRITERIA_SO.
      V_EXTLENGTH     = WA_SO_DETAIL-ZEXTLENGTH_SO.
      V_PACK          = WA_SO_DETAIL-ZPACK_SO.
      V_PRICE_SO      = WA_SO_DETAIL-ZPRICE_SO.
      V_CURR_SO       = WA_SO_DETAIL-ZCURR_SO.
      V_UOMPRICE_SO   = WA_SO_DETAIL-ZUOMPRICE_SO.
      V_KDPACK        = WA_SO_DETAIL-ZKDPACK_SO.
      V_SPECIALTOUCH1 = WA_SO_DETAIL-ZSPCTOUCH1_SO.
      V_SPECIALTOUCH2 = WA_SO_DETAIL-ZSPCTOUCH2_SO.
      V_SPECIALTOUCH3 = WA_SO_DETAIL-ZSPCTOUCH3_SO.
      V_ALIAS_SO      = WA_SO_DETAIL-ZALIAS_SO.
      V_INOUT_SO      = WA_SO_DETAIL-ZINOUT_SO.
      V_ROUTE         = WA_SO_DETAIL-ZROUTE_SO.

      "Cek Error for Header
      IF V_ORDTYPE_SO NE V_ORDTYPE_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Order Type Berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SLSORG_SO NE V_SLSORG_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sales Organization ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_DISTCHANEL_SO NE V_DISTCHANEL_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Distribution Channel ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_DIVISION_SO NE V_DIVISION_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Division ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_PODATE NE V_PODATE_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Tanggal PO ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_CUST_SO NE V_CUST_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sold to party ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SHIPH_SO NE V_SHIPH_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Ship to party ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_PLANT_SO NE V_PLANT_SO_OLD AND V_PO EQ V_PO_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Plant ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      CONCATENATE V_POLINE '0' INTO V_POLINECHECK.
      IF V_POLINECHECK NE V_SOITEM.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'PO Line ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SCHLINE_SO EQ V_SCHLINE_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Schedule line tidak boleh sama' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_DLVDATE_SO EQ V_DLVDATE_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Tanggal delivery date tidak boleh sama' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_UOM NE V_UOM_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sales unit ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_TYPE_SO NE V_TYPE_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Type film ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_THICK NE V_THICK_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Thickness ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_CORE NE V_CORE_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Diameter Core ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_NOROLL NE V_NOROLL_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Juml. Rol SO Item ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_TYPLBL_SO NE V_TYPLBL_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Type label ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_TREAT NE V_TREAT_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Treatment ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_WIDTH NE V_WIDTH_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Lebar film ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_LENGTH NE V_LENGTH_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Panjang film ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_CRITERIA NE V_CRITERIA_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Criteria film ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_EXTLENGTH NE V_EXTLENGTH_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Extralength ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_PACK NE V_PACK_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Jenis packing ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_PRICE_SO NE V_PRICE_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Price ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_CURR_SO NE V_CURR_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Currency ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_UOMPRICE_SO NE V_UOMPRICE_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Sales unit price ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_KDPACK NE V_KDPACK_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Kode pack ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SPECIALTOUCH1 NE V_SPECIALTOUCH1_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Special touch 1 ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SPECIALTOUCH2 NE V_SPECIALTOUCH2_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Special touch 2 ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_SPECIALTOUCH3 NE V_SPECIALTOUCH3_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Special touch 3 ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_ALIAS_SO NE V_ALIAS_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Alias ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_INOUT_SO NE V_INOUT_SO_OLD AND V_PO EQ V_PO_OLD AND V_SOITEM = V_SOITEM_OLD.
        PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Inhouse ada yang berbeda' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.
      " End Cek Error Item SO

      V_PO_OLD       = V_PO.
      V_SOITEM_OLD   = V_SOITEM.

      "Variabel Cek Header
      V_ORDTYPE_SO_OLD      = V_ORDTYPE_SO.
      V_SLSORG_SO_OLD       = V_SLSORG_SO.
      V_DISTCHANEL_SO_OLD   = V_DISTCHANEL_SO.
      V_DIVISION_SO_OLD     = V_DIVISION_SO.
      V_PODATE_OLD          = V_PODATE.
      V_CUST_SO_OLD         = V_CUST_SO.
      V_SHIPH_SO_OLD        = V_SHIPH_SO.
      V_PLANT_SO_OLD        = V_PLANT_SO.
      "End Deklarasi Cek Header

      V_POLINE_OLD          = V_POLINE.
      V_SCHLINE_SO_OLD      = V_SCHLINE_SO.
      V_DLVDATE_SO_OLD      = V_DLVDATE_SO.
      V_UOM_OLD             = V_UOM.
      V_TYPE_SO_OLD         = V_TYPE_SO.
      V_THICK_OLD           = V_THICK.
      V_CORE_OLD            = V_CORE.
      V_NOROLL_OLD          = V_NOROLL.
      V_TYPLBL_SO_OLD       = V_TYPLBL_SO.
      V_TREAT_OLD           = V_TREAT.
      V_WIDTH_OLD           = V_WIDTH.
      V_LENGTH_OLD          = V_LENGTH.
      V_CRITERIA_OLD        = V_CRITERIA.
      V_EXTLENGTH_OLD       = V_EXTLENGTH.
      V_PACK_OLD            = V_PACK.
      V_PRICE_SO_OLD        = V_PRICE_SO.
      V_CURR_SO_OLD         = V_CURR_SO.
      V_UOMPRICE_SO_OLD     = V_UOMPRICE_SO.
      V_KDPACK_OLD          = V_KDPACK.
      V_SPECIALTOUCH1_OLD   = V_SPECIALTOUCH1.
      V_SPECIALTOUCH2_OLD   = V_SPECIALTOUCH2.
      V_SPECIALTOUCH3_OLD   = V_SPECIALTOUCH3.
      V_ALIAS_SO_OLD        = V_ALIAS_SO.
      V_INOUT_SO_OLD        = V_INOUT_SO.
      V_ROUTE_OLD           = V_ROUTE.

      CLEAR WA_SO_DETAIL.
      " End Komparasi Antar Data SO

      DELETE ADJACENT DUPLICATES FROM ITAB_SO_SCH COMPARING ZPO ZSOITEM.
      LOOP AT ITAB_SO_SCH INTO WA_SO_SCH.
        IF WA_SO_SCH-ZINOUT_SO NE ''.
          CLEAR :  V_OLD_SCH, V_SCH, V_JML.
          LOOP AT ITAB_SCH_DETAIL INTO WA_SCH_DETAIL
                                  WHERE ZPO EQ WA_SO_SCH-ZPO
                                  AND   ZSOITEM EQ WA_SO_SCH-ZSOITEM.

            V_SCH = WA_SCH_DETAIL-ZPECAHSCH_SO.
            V_JML = V_JML + V_SCH.

            V_OLD_SCH = V_SCH.
          ENDLOOP.
          IF WA_SO_SCH-ZROLL_SO <> V_JML.
            PERFORM FILL_DISP_ALV2 USING WA_SO_DETAIL-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Cek jumlah pecah schedule line dengan jumlah ROL yang dimasukkan' 'Error' ''.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    "VALIDATE_SO

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_VALIDATE_PR.
  DATA: V_DATE TYPE SY-DATUM,
        V_ITEM(5) TYPE N,
        V_IDX TYPE N,
        V_LENGTH TYPE I,
        V_MATKL TYPE MARA-MATKL,
        V_MATNR TYPE MARA-MATNR,
        V_ATWTB TYPE CAWNT-ATWTB,
        V_FTYPE TYPE CAWNT-ATWTB.
  RANGES: R_DATUM FOR SY-DATUM.

  " Validasi PR
  ITAB_PR3[] = ITAB_PR[].
  DELETE ADJACENT DUPLICATES FROM ITAB_PR COMPARING ZGROUP_PR ZPRITEM.
  LOOP AT ITAB_PR INTO WA_PR.
    IF WA_PR-ZPRTYPE NE 'PR18'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'PR Type Not Correct' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.
    IF WA_PR-ZPGR_PR NE 'P99'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'PR Group Not Correct' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    IF WA_PR-ZPLANT NE '1000'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Plant Harus 1000' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    IF WA_PR-ZCUST_PR = ''.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Customer Wajib Diisi' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    IF WA_PR-ZPO_CUST = ''.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'No. PO Wajib Diisi' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

*    CONCATENATE 'SR' WA_PR-ZFILMTYPE_PR 'O' INTO V_MATNR.
    CONCATENATE WA_PR-ZFILMTYPE_PR '-' WA_PR-ZTHICK_PR INTO V_FTYPE.

    SELECT CAWN~ATWRT
      INTO V_ATWTB
      FROM CAWN JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
      JOIN CABN ON CAWN~ATINN = CABN~ATINN
      WHERE CABN~ATNAM = 'ZZCODE' AND CAWNT~ATWTB = V_FTYPE.
    ENDSELECT.

    CONCATENATE 'SR' V_ATWTB 'O' INTO V_MATNR.

    SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR = V_MATNR.

    IF V_MATKL EQ '300020' AND WA_PR-ZSKU_CODE = ''.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Kode SKU Wajib Diisi' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    IF V_MATKL NE '300020' AND WA_PR-ZSKU_CODE IS NOT INITIAL.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Kode SKU Tidak Boleh Diisi' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    PERFORM F_CHANGEDATE USING WA_PR-ZDLVDATE_PR CHANGING V_DATE.
    IF V_DATE LT SY-DATUM.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Tanggal tidak boleh masa lampau' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    V_LENGTH = STRLEN( WA_PR-ZPO_CUST ).

    IF V_LENGTH > 30.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Panjang No. PO lebih dari 30 digit' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

    LOOP AT ITAB_PR3 INTO WA_PR2 WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR
                                   AND ZPRITEM EQ WA_PR-ZPRITEM..

      IF V_IDX EQ ''.
        V_IDX   = 1 .
        V_ITEM  = WA_PR2-ZPRITEM.
        PERFORM F_CHANGEDATE USING WA_PR2-ZDLVDATE_PR CHANGING V_DATE.

        R_DATUM-OPTION  = 'EQ'.
        R_DATUM-SIGN    = 'I'.
        R_DATUM-LOW     = V_DATE.
        APPEND R_DATUM.

      ELSEIF V_IDX GE 1.
        IF V_ITEM EQ WA_PR2-ZPRITEM.
          PERFORM F_CHANGEDATE USING WA_PR2-ZDLVDATE_PR CHANGING V_DATE.
          IF V_DATE IN R_DATUM.
            PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Tanggal Sch.Line tidak boleh sama' 'Error' ''.
            V_FLAG = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.
    CLEAR: V_IDX, R_DATUM.
    REFRESH R_DATUM.
  ENDLOOP.

  IF V_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    "F_VALIDATE_PR

*&---------------------------------------------------------------------*
*&      Form  f_validate_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_VALIDATE_PO.

  " Validasi PO
  LOOP AT ITAB_PO INTO WA_PO.
*    IF WA_PO-ZPOTYPE NE 'PO21'.
    IF WA_PO-ZPOTYPE NE 'PO25'. "Laminator
      PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_ERROR '' '' '' '' 'PO type salah' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.

*    IF RB_PO EQ 'X' OR RB_PO2 EQ 'X'.
*    SELECT BSTKD INTO V_BSTKD FROM VBKD WHERE BSTKD EQ WA_PO-ZPO_NUMBER.
*    ENDSELECT.
*    IF SY-SUBRC EQ 0.
*      PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_ERROR '' '' '' '' 'PO sudah ada SO Intercompanny' 'Error' ''.
*      V_FLAG = 'X'.
*    ENDIF.
*    ENDIF.

*    SELECT SINGLE EKOTX INTO V_EKOTX FROM T024E WHERE EKORG EQ WA_PO-ZEKORG.
*    IF V_EKOTX CP '*Local'.
*      IF WA_PO-ZMWSKZ EQ 'V1' OR WA_PO-ZMWSKZ EQ 'V5' OR WA_PO-ZMWSKZ EQ 'V8'. "added by annisa wibowo for V8 PPN 12 at 24.12.2024
*      ELSE.
*        PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_ERROR '' '' '' '' 'PO Tax Code Harus V1/V5/V8' 'Error' ''.
*        V_FLAG = 'X'.
*      ENDIF.
*    ENDIF.

  ENDLOOP.

  IF V_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    "f_validate_po

*&---------------------------------------------------------------------*
*&      Form  f_validate_soi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_VALIDATE_SOI.
  " Cek Order Type & Dist.Chanel SO IC
  LOOP AT ITAB_SOI INTO WA_SOI.
    IF WA_SOI-ZORDTYPE_SOI NE 'ZDOR'.
      PERFORM FILL_DISP_ALV2 USING WA_SOI-ZGROUP_SOI WA_SOI-ZSOITEM_SOI C_ICON_ERROR '' '' '' '' 'Order Type Salah' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.
    IF WA_SOI-ZDISTCHANEL_SOI NE '03'.
      PERFORM FILL_DISP_ALV2 USING WA_SOI-ZGROUP_SOI WA_SOI-ZSOITEM_SOI C_ICON_ERROR '' '' '' '' 'Dist.Chanel Salah' 'Error' ''.
      V_FLAG = 'X'.
    ENDIF.
  ENDLOOP.

  IF V_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    "f_validate_soi

*&---------------------------------------------------------------------*
*&      Form  VALIDASI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_VALIDASI_STATUS USING V_SONUM
                             V_NOMOR
                             V_ITEM
                             V_INDC.
  CLEAR: V_SONUM1, V_IHREZ.

  DATA V_BSTKD TYPE VBKD-BSTKD.

  V_SONUM = V_SONUM1 = V_SONUM.
  V_NOMOR = V_SONUM1 = V_NOMOR.

  SELECT SINGLE BSTKD INTO V_BSTKD FROM VBKD WHERE BSTKD EQ V_NOMOR.
  IF SY-SUBRC EQ 0.
    V_FLAG = 'X'.
  ENDIF.
ENDFORM.                    "VALIDASI_STATUS

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS_SO.
  CLEAR V_INDC.
  ITAB_DETAIL_SO[] = ITAB_CHANGE_SO[] = ITAB_SO[].
  DELETE ADJACENT DUPLICATES FROM ITAB_SO COMPARING ZPO.
  DELETE ADJACENT DUPLICATES FROM ITAB_DETAIL_SO COMPARING ZPO ZSOITEM.

  LOOP AT ITAB_SO INTO WA_SO WHERE ZSO IS INITIAL.
    CLEAR: T_QUOTE_HEADER_IN, TAB_QUOTE_PARTNR, IT_RETURN_CREATE_SO, TAB_QUOT_COND, WA_EXTENSIONIN, EXTENSIONIN.

    "Fill Header data SO
    T_QUOTE_HEADER_IN-DOC_TYPE    = WA_SO-ZORDTYPE_SO.
    T_QUOTE_HEADER_IN-SALES_ORG   = WA_SO-ZSLSORG_SO.
    T_QUOTE_HEADER_IN-DIVISION    = WA_SO-ZDIVISION_SO.
    T_QUOTE_HEADER_IN-DISTR_CHAN  = WA_SO-ZDISTCHANEL_SO.
    T_QUOTE_HEADER_IN-PURCH_NO_C  = WA_SO-ZPO.
    T_QUOTE_HEADER_IN-CURRENCY    = WA_SO-ZCURR_SO.
    T_QUOTE_HEADER_IN-PURCH_DATE  = SY-DATUM.
    PERFORM F_CHANGEDATE USING WA_SO-ZDLVDATE_SO CHANGING  T_QUOTE_HEADER_IN-REQ_DATE_H.
    PERFORM F_CHANGEDATE USING WA_SO-ZPODATE_SO  CHANGING  T_QUOTE_HEADER_IN-QT_VALID_T.
    APPEND T_QUOTE_HEADER_IN.

    "Fill Data Partner SO
    WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_SO-ZCUST_SO.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.

    WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_SO-ZSHIPH_SO.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.

    CLEAR : V_KALKS, V_WAERK, V_KALVG, V_KARTV, TAB_ITEMS, TAB_QUOTE_REF,
         TAB_QUOTE_REFINST, TAB_QUOTE_INST, TAB_QUOTE_VALUE, IT_RETURN_CREATE_SO,
         TAB_ITEMS_SCHED, TAB_SCHEDULES_INX.

    LOOP AT ITAB_DETAIL_SO INTO WA_DETAIL_SO WHERE ZPO EQ WA_SO-ZPO.
      CONCATENATE WA_DETAIL_SO-ZTYPE_SO '-' WA_DETAIL_SO-ZTHICK_SO INTO V_ATWTB.
      V_MAKTX = V_ATWTB.

      SELECT CAWN~ATWRT
        INTO V_ATWTB
        FROM CAWN JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
        WHERE CAWN~ATINN EQ '0000000811' AND CAWNT~ATWTB = V_ATWTB.
      ENDSELECT.

      IF SY-SUBRC NE 0.
        PERFORM FILL_DISP_ALV2 USING WA_SO-ZGROUP_SO WA_SO-ZSOITEM C_ICON_ERROR '' '' '' '' 'Material tidak Ditemukan' 'Error' ''.
        V_FLAG = 'X'.
      ENDIF.

      IF V_FLAG EQ 'X'.
        EXIT.
      ENDIF.

      " Generate material number
      IF WA_DETAIL_SO-ZINOUT_SO EQ 'I'.
        CONCATENATE 'SR' V_ATWTB 'I' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SO-ZINOUT_SO EQ 'X'.
        CONCATENATE 'SR' V_ATWTB 'X' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SO-ZINOUT_SO EQ ''.
        V_MATNR = WA_DETAIL_SO-ZTYPE_SO.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SO-ZINOUT_SO EQ 'O'.
        CONCATENATE 'SR' V_ATWTB 'O' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ENDIF.

      SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR = V_MATNR.
      LV_STR = V_MATKL(1).

      "Search item data
      SELECT SINGLE MVKE~MTPOS
        INTO V_MTPOS
        FROM MVKE
        WHERE MATNR = V_MATNR.

      SELECT SINGLE T184~PSTYV
        INTO V_PSTYV
        FROM T184
        WHERE AUART = WA_DETAIL_SO-ZORDTYPE_SO
        AND MTPOS = V_MTPOS
        AND VWPOS = ''
        AND UEPST = ''.

      SELECT SINGLE KNVV~KALKS
        INTO V_KALKS
        FROM KNVV
        WHERE KUNNR = WA_DETAIL_SO-ZCUST_SO
        AND VKORG = WA_DETAIL_SO-ZSLSORG_SO.

      SELECT SINGLE TVAK~KALVG
        INTO V_KALVG
        FROM TVAK
        WHERE AUART = WA_DETAIL_SO-ZORDTYPE_SO.

      SELECT SINGLE T683V~KARTV
        INTO V_KARTV
        FROM T683V
        WHERE VKORG = WA_DETAIL_SO-ZSLSORG_SO
        AND VTWEG = WA_DETAIL_SO-ZDISTCHANEL_SO
        AND SPART = WA_DETAIL_SO-ZDIVISION_SO
        AND KALVG = V_KALVG
        AND KALKS = V_KALKS.

      "Start Item for SO Data
      WA_ITEM-PO_ITM_NO  = WA_DETAIL_SO-ZPOLINE_SO.
      WA_ITEM-ITM_NUMBER = WA_DETAIL_SO-ZSOITEM.
      WA_ITEM-PLANT      = WA_DETAIL_SO-ZPLANT_SO.
      WA_ITEM-SHIP_POINT = WA_DETAIL_SO-ZSHPPOINT_SO.
      WA_ITEM-SALES_UNIT = WA_DETAIL_SO-ZUOM_SO.
      WA_ITEM-MATERIAL   = V_MATNR.
      WA_ITEM-ITEM_CATEG = V_PSTYV.
      WA_ITEM-ROUTE      = WA_DETAIL_SO-ZROUTE_SO.

      IF V_KALVG EQ 5.
        WA_ITEM-TARGET_QU   = WA_DETAIL_SO-ZUOM_SO.
        WA_ITEM-TARGET_QTY  = WA_DETAIL_SO-ZROLL_SO.
      ENDIF.
      APPEND WA_ITEM TO TAB_ITEMS.
      CLEAR WA_ITEM.
      "End Item

      "Start of Configuration Data
      WA_QUOTE_REF-POSEX     = WA_DETAIL_SO-ZPOLINE_SO.
      WA_QUOTE_REF-CONFIG_ID = WA_DETAIL_SO-ZSOITEM.
      WA_QUOTE_REF-ROOT_ID   = '00000001'.
      APPEND WA_QUOTE_REF TO TAB_QUOTE_REF.
      CLEAR  WA_QUOTE_REF.
      "End of Configuration Data

      "Start Refinst
      WA_QUOTE_REFINST-POSEX     = WA_DETAIL_SO-ZPOLINE_SO.
      WA_QUOTE_REFINST-CONFIG_ID = WA_DETAIL_SO-ZSOITEM.
      WA_QUOTE_REFINST-INST_ID   = '00000001'.
      APPEND WA_QUOTE_REFINST TO TAB_QUOTE_REFINST.
      CLEAR WA_QUOTE_REFINST.
      "End of Refinst

      "Start Attributes Value
      IF LV_STR EQ '3' AND V_KALVG NE 5.
        IF WA_DETAIL_SO-ZUOM_SO CS 'ROL' OR
           WA_DETAIL_SO-ZUOM_SO CS 'LB'  OR
           WA_DETAIL_SO-ZUOM_SO CS 'M2'  OR
           WA_DETAIL_SO-ZUOM_SO CS 'KG'.

          IF WA_DETAIL_SO-ZROLL_SO NE ''.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZNUMBEROFROLL' WA_DETAIL_SO-ZROLL_SO.
          ENDIF.
        ENDIF.
        " Type Film
        IF WA_DETAIL_SO-ZTYPE_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZTYPE' WA_DETAIL_SO-ZTYPE_SO.
        ENDIF.

        " Diameter Core
        IF WA_DETAIL_SO-ZCORE_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZCORE' WA_DETAIL_SO-ZCORE_SO.
        ENDIF.

        " Type Label
        IF WA_DETAIL_SO-ZTYPLBL_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZLABEL' WA_DETAIL_SO-ZTYPLBL_SO.
        ENDIF.

        " Treatment
        IF WA_DETAIL_SO-ZTREAT_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZTREATMENT' WA_DETAIL_SO-ZTREAT_SO.
        ENDIF.

        " Lebar
        IF WA_DETAIL_SO-ZWIDTH_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZWIDTH' WA_DETAIL_SO-ZWIDTH_SO.
        ENDIF.

        " Panjang
        IF WA_DETAIL_SO-ZLENGTH_SO NE ''.
          IF WA_DETAIL_SO-ZUOM_SO CS 'PAK'.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZLENGTHSHT' WA_DETAIL_SO-ZLENGTH_SO.
          ELSE.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZLENGTH' WA_DETAIL_SO-ZLENGTH_SO.
          ENDIF.
        ENDIF.

        " Kriteria
        IF WA_DETAIL_SO-ZCRITERIA_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZCRITERIA' WA_DETAIL_SO-ZCRITERIA_SO.
        ENDIF.

        " Extra length
        IF WA_DETAIL_SO-ZEXTLENGTH_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZEXLENGTH' WA_DETAIL_SO-ZEXTLENGTH_SO.
        ENDIF.

        " Packing
        IF WA_DETAIL_SO-ZPACK_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZPACKING' WA_DETAIL_SO-ZPACK_SO.
        ENDIF.

        " Kode Pack
        IF WA_DETAIL_SO-ZKDPACK_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZPACKINGCODE' WA_DETAIL_SO-ZKDPACK_SO.
        ENDIF.

        " Special Touch-1
        IF WA_DETAIL_SO-ZSPCTOUCH1_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZSPECIALTOUCH-1' WA_DETAIL_SO-ZSPCTOUCH1_SO.
        ENDIF.

        " Special Touch-2
        IF WA_DETAIL_SO-ZSPCTOUCH2_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZSPECIALTOUCH-2' WA_DETAIL_SO-ZSPCTOUCH2_SO.
        ENDIF.

        " Special Touch-3
        IF WA_DETAIL_SO-ZSPCTOUCH3_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZSPECIALTOUCH-3' WA_DETAIL_SO-ZSPCTOUCH3_SO.
        ENDIF.

        " Alias
        IF WA_DETAIL_SO-ZALIAS_SO NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SO-ZSOITEM 'ZZALIAS' WA_DETAIL_SO-ZALIAS_SO.
        ENDIF.
      ENDIF.
      "End Attributes Value


      "Condition Price
      IF V_KALVG = 5 AND WA_DETAIL_SO-ZDISTCHANEL_SO EQ '01' .
        WA_QUOT_COND-COND_TYPE   = 'ZDD0'.
      ELSEIF V_KALVG = 5 AND WA_DETAIL_SO-ZDISTCHANEL_SO EQ '02' .
        WA_QUOT_COND-COND_TYPE   = 'ZED0'.
      ELSE.
        WA_QUOT_COND-COND_TYPE   = V_KARTV.
      ENDIF.
      WA_QUOT_COND-ITM_NUMBER  = WA_DETAIL_SO-ZSOITEM.
      WA_QUOT_COND-CURRENCY    = WA_DETAIL_SO-ZCURR_SO.
      WA_QUOT_COND-COND_VALUE  = WA_DETAIL_SO-ZPRICE_SO.
      WA_QUOT_COND-COND_UNIT   = WA_DETAIL_SO-ZUOMPRICE_SO.
      APPEND WA_QUOT_COND TO TAB_QUOT_COND.
      CLEAR WA_QUOT_COND.

      IF LV_STR = 'B'.
        PERFORM F_CHANGEDATE USING WA_DETAIL_SO-ZDLVDATE_SO CHANGING WA_ITEMS_SCHED-REQ_DATE.
        WA_ITEMS_SCHED-ITM_NUMBER = WA_DETAIL_SO-ZSOITEM.
        WA_ITEMS_SCHED-REQ_QTY    = WA_DETAIL_SO-ZROLL_SO.
        WA_ITEMS_SCHED-REQ_DATE   = WA_ITEMS_SCHED-REQ_DATE.
        WA_ITEMS_SCHED-DATE_TYPE  = '1'.
        WA_ITEMS_SCHED-SCHED_LINE = 1.
        APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
        CLEAR WA_ITEMS_SCHED.

        WA_SCHEDULES_INX-ITM_NUMBER  = WA_DETAIL_SO-ZSOITEM.
        WA_SCHEDULES_INX-SCHED_LINE  = 1.
        WA_SCHEDULES_INX-UPDATEFLAG  = 'I'.
        WA_SCHEDULES_INX-REQ_QTY     = 'X'.
        WA_SCHEDULES_INX-REQ_DATE    = 'X'.
        APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
        CLEAR WA_SCHEDULES_INX.
      ENDIF.

      IF WA_DETAIL_SO-ZDATE IS INITIAL.
        WA_DETAIL_SO-ZDATE = '00000000'.
      ENDIF.

      IF WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZDOR' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZEOR' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZDKB' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZEKB' OR
         WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZDSO' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZESO' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZINV' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZDSD' OR WA_DETAIL_SO-ZORDTYPE_SO EQ 'ZESD'.
        IF WA_DETAIL_SO-ZDATE IS INITIAL OR WA_DETAIL_SO-ZDATE EQ '00000000'..
          PERFORM F_CHANGEDATE USING WA_DETAIL_SO-ZDLVDATE_SO CHANGING WA_DETAIL_SO-ZDATE.
        ELSE.
          PERFORM F_CHANGEDATE USING WA_DETAIL_SO-ZDATE CHANGING WA_DETAIL_SO-ZDATE.
        ENDIF.

        CLEAR: V_BUKRS.
        IF WA_DETAIL_SO-ZLINE IS INITIAL.
          SELECT SINGLE BUKRS INTO V_BUKRS FROM T001K WHERE BWKEY EQ WA_DETAIL_SO-ZPLANT_SO.
          IF SY-SUBRC EQ 0.
            SELECT SINGLE ZLINE INTO WA_DETAIL_SO-ZLINE FROM ZMAP_PRODLINE WHERE BUKRS EQ V_BUKRS AND MATNR EQ V_MATNR.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM F_CHANGEDATE USING WA_DETAIL_SO-ZDATE CHANGING WA_DETAIL_SO-ZDATE.
      ENDIF.

      "Extension Field
      WA_BAPE_VBAP-POSNR  = WA_DETAIL_SO-ZSOITEM.
      WA_BAPE_VBAP-ZDATE  = WA_DETAIL_SO-ZDATE.
      WA_BAPE_VBAP-ZLINE  = WA_DETAIL_SO-ZLINE.
      WA_EXTENSIONIN-STRUCTURE = 'BAPE_VBAP'.
      WA_EXTENSIONIN-VALUEPART1 = WA_BAPE_VBAP.
      APPEND WA_EXTENSIONIN TO EXTENSIONIN.

      WA_BAPE_VBAPX-POSNR  = WA_DETAIL_SO-ZSOITEM.
      WA_BAPE_VBAPX-ZDATE  = 'X'.
      WA_BAPE_VBAPX-ZLINE  = 'X'.
      WA_EXTENSIONIN-STRUCTURE = 'BAPE_VBAPX'.
      WA_EXTENSIONIN-VALUEPART1 = WA_BAPE_VBAPX.
      APPEND WA_EXTENSIONIN TO EXTENSIONIN.
    ENDLOOP.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

    "----Start Create SO Number
    IF WA_DETAIL_SO-ZPO NE ''.
      CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
        EXPORTING
          SALES_HEADER_IN     = T_QUOTE_HEADER_IN
        IMPORTING
          SALESDOCUMENT_EX    = V_SO
        TABLES
          RETURN              = IT_RET
          SALES_ITEMS_IN      = TAB_ITEMS
          SALES_PARTNERS      = TAB_QUOTE_PARTNR
          SALES_SCHEDULES_IN  = TAB_ITEMS_SCHED
          SALES_SCHEDULES_INX = TAB_SCHEDULES_INX
          SALES_CONDITIONS_IN = TAB_QUOT_COND
          SALES_CFGS_REF      = TAB_QUOTE_REF
          SALES_CFGS_INST     = TAB_QUOTE_INST
          SALES_CFGS_VALUE    = TAB_QUOTE_VALUE
          SALES_CFGS_REFINST  = TAB_QUOTE_REFINST
          EXTENSIONIN         = EXTENSIONIN.

      READ TABLE IT_RET WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0.
        CLEAR V_MSG.
        V_MSG = IT_RET-MESSAGE.
        CONCATENATE 'SO Customer Not Created: ' V_MSG INTO V_MSG SEPARATED BY SPACE.
        PERFORM FILL_DISP_ALV2 USING WA_DETAIL_SO-ZGROUP_SO WA_DETAIL_SO-ZSOITEM C_ICON_ERROR '' '' '' '' V_MSG 'Error' ''.
        V_FLAG = 'X'.
      ELSE.
        LOOP AT ITAB_DETAIL_SO INTO WA_DETAIL_SO WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.
          CONCATENATE V_SO WA_DETAIL_SO-ZSOITEM INTO V_OBJNUM SEPARATED BY '-'.
          PERFORM FILL_DISP_ALV2 USING WA_DETAIL_SO-ZGROUP_SO WA_DETAIL_SO-ZSOITEM C_ICON_SUCCESS V_OBJNUM '' '' '' 'SO Customer Created' 'Success' ''.
        ENDLOOP.

        PERFORM COMMIT.

        WA_SO-ZMATNR = V_MATNR.
        WA_SO-ZSO    = V_SO.
        MODIFY ITAB_SO FROM WA_SO TRANSPORTING ZSO ZMATNR WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.
        MODIFY ITAB_DETAIL_SO FROM WA_SO TRANSPORTING ZSO ZMATNR WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.

        IF LV_STR NE 'B'.
          PERFORM F_CHANGE_SO. "---Change SO Customer---"
        ENDIF.
      ENDIF.
    ENDIF. "End Create SO

    PERFORM F_PROCESS_PR.
    IF V_FLAG EQ 'X'.
      EXIT.
    ELSE.
      LOOP AT ITAB_PR INTO WA_PR WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR.
        PERFORM F_ADD_ORDATA USING WA_SO-ZSO WA_PR-ZPRNO WA_PR-ZPRITEM 'PR'.
      ENDLOOP.

      PERFORM F_PROCESS_PO.
      IF V_FLAG EQ 'X'.
        EXIT.
      ELSE.
        LOOP AT ITAB_PO INTO WA_PO WHERE ZGROUP_PO EQ WA_SO-ZGROUP_SO.
          PERFORM F_ADD_ORDATA USING WA_SO-ZSO WA_PO-ZPO_NUMBER WA_PO-ZPOITEM 'PO'.
        ENDLOOP.

*        PERFORM F_PROCESS_SO_IC.
        IF V_FLAG EQ 'X'.
          EXIT.
        ELSE.
          LOOP AT ITAB_SOI INTO WA_SOI WHERE ZGROUP_SOI EQ WA_SOI-ZGROUP_SOI.
            PERFORM F_ADD_ORDATA USING WA_SO-ZSO WA_SOI-ZSO WA_SOI-ZSOITEM_SOI 'SO'.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "PROCESS_SO

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CHANGE_SO.

  LOOP AT ITAB_CHANGE_SO INTO WA_CHANGE_SO WHERE ZPO EQ WA_SO-ZPO.

    CLEAR   : ZCUOBJ, IT_TEMP, V_KALKS, V_KALVG, V_KARTV, ZZWEIGTHTOT, ZJMLROLL,
              TAB_ITEMS_SCHED,TAB_SCHEDULES_INX, ZWEIGHT, ZORDERQTY, ZSATUAN, ZTOTALM2, ZZCONV.
    REFRESH : IT_TEMP.

    SELECT SINGLE VBAP~CUOBJ
      INTO ZCUOBJ
      FROM VBAP
      WHERE VBAP~VBELN = V_SO
      AND VBAP~POSNR = WA_CHANGE_SO-ZSOITEM.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = ZCUOBJ
      TABLES
        CONFIGURATION       = IT_TEMP
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
    SPLIT IT_TEMP-ATWTB AT SPACE INTO ZZCONV ZSATUAN.
    REPLACE ALL OCCURRENCES OF ',' IN ZZCONV WITH SPACE.

    ZJMLROLL    = WA_CHANGE_SO-ZPECAHSCH_SO.
    ZJMLROLL_M2 = WA_CHANGE_SO-ZROLL_SO.

    CASE WA_CHANGE_SO-ZUOM_SO.
      WHEN 'KG'.
        ZZWEIGTHTOT = ZJMLROLL * ZZCONV.
      WHEN 'ROL'.
        ZZWEIGTHTOT = ZJMLROLL.
      WHEN 'M2'.
        READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTOTALM2'.
        SPLIT IT_TEMP-ATWTB AT SPACE INTO ZTOTALM2 ZSATUAN.
        REPLACE ALL OCCURRENCES OF ',' IN ZTOTALM2 WITH SPACE.
        CALL FUNCTION 'ROUND'
          EXPORTING
            DECIMALS = 3
            INPUT    = ZTOTALM2
            SIGN     = '+'
          IMPORTING
            OUTPUT   = ZWEIGHT.
        ZZWEIGTHTOT = ( ZWEIGHT / ZJMLROLL_M2 ) * ZJMLROLL.
      WHEN 'LB'.
        READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZORDERQTY'.
        SPLIT IT_TEMP-ATWTB AT SPACE INTO ZORDERQTY ZSATUAN.
        ZZWEIGTHTOT = ZORDERQTY * ZJMLROLL.
    ENDCASE.

    PERFORM F_CHANGEDATE USING WA_CHANGE_SO-ZDLVDATE_SO CHANGING WA_ITEMS_SCHED-REQ_DATE.

    WA_ITEMS_SCHED-ITM_NUMBER     = WA_CHANGE_SO-ZSOITEM.
    WA_ITEMS_SCHED-SCHED_LINE     = WA_CHANGE_SO-ZSCHLINE_SO.
    WA_ITEMS_SCHED-REQ_QTY        = ZZWEIGTHTOT.
    WA_ITEMS_SCHED-REQ_DATE       = WA_ITEMS_SCHED-REQ_DATE.
    WA_ITEMS_SCHED-DATE_TYPE      = '1'.
    APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
    CLEAR WA_ITEMS_SCHED.

    WA_SCHEDULES_INX-ITM_NUMBER   = WA_CHANGE_SO-ZSOITEM.
    WA_SCHEDULES_INX-SCHED_LINE   = WA_CHANGE_SO-ZSCHLINE_SO.
    WA_SCHEDULES_INX-UPDATEFLAG   = 'I'.
    WA_SCHEDULES_INX-REQ_QTY      = 'X'.
    WA_SCHEDULES_INX-REQ_DATE     = 'X'.
    APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
    CLEAR WA_SCHEDULES_INX.

    PERFORM F_COMMIT_SO.

    CLEAR: WA_CHANGE_SO.
    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "F_CHANGE_SO

*&---------------------------------------------------------------------*
*&      Form  F_COMMIT_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_COMMIT_SO.
  CLEAR: V_NUMBER, V_ITEM, V_PLANT.

  REFRESH : IT_BAPISDH1X, IT_RET.

  IT_BAPISDH1X-UPDATEFLAG = 'U'.
  COLLECT IT_BAPISDH1X.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      SALESDOCUMENT    = V_SO
      ORDER_HEADER_INX = IT_BAPISDH1X
    TABLES
      RETURN           = IT_RET
      SCHEDULE_LINESX  = TAB_SCHEDULES_INX
      SCHEDULE_LINES   = TAB_ITEMS_SCHED.

  READ TABLE IT_RET WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0.
    LOOP AT ITAB_SO_DETAIL INTO WA_DETAIL_SO WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.
      WA_ITEMS-ICON    = C_ICON_ERROR.

      WA_DISP-MSG = 'Change SO Intercompany Error'.

      MODIFY IT_DISP FROM WA_DISP TRANSPORTING MSG WHERE GROUP EQ WA_DETAIL_SO-ZGROUP_SO
                                                     AND ITEM  EQ WA_DETAIL_SO-ZSOITEM.

    ENDLOOP.
    PERFORM F_EXIT.
  ELSE.
    PERFORM COMMIT.
  ENDIF.
ENDFORM.                    "F_COMMIT_SO

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_PR.

*  IF RB1 EQ 'X' AND RB_SO EQ 'X'.
*    ITAB_DETAIL_SO[] = ITAB_CHANGE_SO[] = ITAB_SO[].
**    DELETE ADJACENT DUPLICATES FROM ITAB_SO COMPARING ZSO.
*    DELETE ADJACENT DUPLICATES FROM ITAB_DETAIL_SO COMPARING ZSO ZSOITEMREF.
*  ENDIF.

  LOOP AT ITAB_DETAIL_SO INTO WA_DETAIL_SO WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.

    IF V_MAKTX IS INITIAL.
      REPLACE ALL OCCURRENCES OF '.0' IN WA_DETAIL_SO-ZTHICK_SO WITH ''.
      CONCATENATE WA_DETAIL_SO-ZTYPE_SO '-' WA_DETAIL_SO-ZTHICK_SO INTO V_MAKTX.
    ENDIF.

    WA_PR-ZPRTYPE = 'PR18'.
    WA_PR-ZUOM_PR   = WA_DETAIL_SO-ZUOM_SO.

    CLEAR V_SONUM1.
    V_SONUM1 = WA_DETAIL_SO-ZSO.

    "Get Order QTY
    IF WA_PR-ZUOM_PR EQ 'ROL'.
      SELECT SINGLE NTGEW INTO V_KWMENG FROM VBAP WHERE VBELN EQ V_SONUM1 AND POSNR EQ WA_DETAIL_SO-ZSOITEM.
    ELSE.
      SELECT SINGLE KWMENG INTO V_KWMENG FROM VBAP WHERE VBELN EQ V_SONUM1 AND POSNR EQ WA_DETAIL_SO-ZSOITEM.
    ENDIF.

    WA_PR-ZQTY_PR   = V_KWMENG. CONDENSE WA_PR-ZQTY_PR.
    WA_PR-ZPLANT    = WA_DETAIL_SO-ZPLANT_SO.
    WA_PR-ZPGR_PR   = 'P99'.
    REPLACE ALL OCCURRENCES OF '.0' IN WA_DETAIL_SO-ZTHICK_SO WITH ''.
    WA_PR-ZTHICK_PR = WA_DETAIL_SO-ZTHICK_SO.
    WA_PR-ZSO       = WA_DETAIL_SO-ZSO.

    "Get Expired Life SO
    SELECT SINGLE CUOBJ FROM VBAP INTO V_CUOBJ WHERE VBELN EQ V_SONUM1 AND POSNR EQ WA_DETAIL_SO-ZSOITEM.

    CALL FUNCTION 'VELO01_GET_CONFIGURATION'
      EXPORTING
        CUOBJ_NUMBER = V_CUOBJ
      TABLES
        CUVAL_ET     = CUVAL_ET.

    READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
    WA_PR-ZEXPLIFE_PR   = CUVAL_ET-ATWRT.

    WA_PR-ZCORE_PR      = WA_DETAIL_SO-ZCORE_SO.
    WA_PR-ZWIDTH_PR     = WA_DETAIL_SO-ZWIDTH_SO.
    WA_PR-ZLENGTH_PR    = WA_DETAIL_SO-ZLENGTH_SO.
    WA_PR-ZTREAT_PR     = WA_DETAIL_SO-ZTREAT_SO.
    WA_PR-ZROLL_PR      = WA_DETAIL_SO-ZROLL_SO.
    WA_PR-ZCRITERIA_PR  = WA_DETAIL_SO-ZCRITERIA_SO.
    WA_PR-ZALIAS_PR     = WA_DETAIL_SO-ZALIAS_SO.
    WA_PR-ZTYPLBL_PR    = WA_DETAIL_SO-ZTYPLBL_SO.
    WA_PR-ZSPCTOUCH1_PR = WA_DETAIL_SO-ZSPCTOUCH1_SO.
    WA_PR-ZSPCTOUCH2_PR = WA_DETAIL_SO-ZSPCTOUCH2_SO.
    WA_PR-ZSPCTOUCH3_PR = WA_DETAIL_SO-ZSPCTOUCH3_SO.
    WA_PR-ZEXTLENGTH_PR = WA_DETAIL_SO-ZEXTLENGTH_SO.
    WA_PR-ZKDPACK_PR    = WA_DETAIL_SO-ZKDPACK_SO.
    WA_PR-ZPACK_PR      = WA_DETAIL_SO-ZPACK_SO.

    "Generate Material
    READ TABLE ITAB_PR WITH KEY ZGROUP_PR = WA_DETAIL_SO-ZGROUP_SO
                                       ZPRITEM   = WA_DETAIL_SO-ZSOITEM.

    CONCATENATE ITAB_PR-ZFILMTYPE_PR '-' WA_DETAIL_SO-ZTHICK_SO INTO V_ATWTB.
    SELECT CAWN~ATWRT
      INTO V_ATWTB
      FROM CAWN JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
      WHERE CAWN~ATINN EQ '0000000811' AND CAWNT~ATWTB = V_ATWTB.
    ENDSELECT.

    CONCATENATE 'SR' V_ATWTB ITAB_PR-ZINOUT_PR INTO V_MATPR.
    WA_PR-ZMATNR = V_MATPR.

    MODIFY ITAB_PR FROM WA_PR   TRANSPORTING ZQTY_PR ZPRTYPE ZUOM_PR ZPLANT
                                ZPGR_PR ZTHICK_PR ZSO ZCORE_PR ZWIDTH_PR
                                ZLENGTH_PR ZTREAT_PR ZROLL_PR ZCRITERIA_PR
                                ZALIAS_PR ZTYPLBL_PR ZSPCTOUCH1_PR ZSPCTOUCH2_PR
                                ZSPCTOUCH3_PR ZEXTLENGTH_PR ZKDPACK_PR ZPACK_PR
                                ZMATNR ZEXPLIFE_PR
    WHERE ZPRITEM   EQ WA_DETAIL_SO-ZSOITEM
      AND ZGROUP_PR EQ WA_DETAIL_SO-ZGROUP_SO.

*-----Create PR-----*

    READ TABLE ITAB_PR INTO WA_PR WITH KEY ZGROUP_PR = WA_DETAIL_SO-ZGROUP_SO
                                           ZPRITEM   = WA_DETAIL_SO-ZSOITEM.

    WA_PRHEADER-PR_TYPE   = WA_PR-ZPRTYPE.
    APPEND WA_PRHEADER TO IT_PRHEADER.

    WA_PRHEADERX-PR_TYPE    = 'X'.
    WA_PRHEADERX-ITEM_INTVL = 'X'.
    APPEND WA_PRHEADERX TO IT_PRHEADERX.

    WA_PRITEM-PREQ_ITEM   = WA_PR-ZPRITEM.
    WA_PRITEM-PUR_GROUP   = WA_PR-ZPGR_PR.
    WA_PRITEM-MATERIAL    = WA_PR-ZMATNR.
    WA_PRITEM-PLANT       = WA_PR-ZPLANT.
    WA_PRITEM-TRACKINGNO  = WA_DETAIL_SO-ZSO.
    WA_PRITEM-QUANTITY    = WA_PR-ZQTY_PR.
    WA_PRITEM-PREQ_NAME   = WA_PR-ZREQUESTER_PR.

    CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
      EXPORTING
        INPUT  = WA_PR-ZDLVDATE_PR
      IMPORTING
        OUTPUT = V_EINDT.

    WA_PRITEM-DELIV_DATE = V_EINDT.
    APPEND WA_PRITEM TO IT_PRITEM.

  ENDLOOP.

  PERFORM CREATE_PR.
ENDFORM.                    "F_PROCESS_PR

*&---------------------------------------------------------------------*
*&      Form  CREATE_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_PR.
  CLEAR: V_NUMBER, V_ITEM, V_PLANT, WA_ITEMS, V_OBJNUM, V_PRNO, V_FLAG.

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER  = WA_PRHEADER
      PRHEADERX = WA_PRHEADERX
    IMPORTING
      NUMBER    = V_PRNO
    TABLES
      RETURN    = IT_RET
      PRITEM    = IT_PRITEM
      PRITEMX   = IT_PRITEMX.

  READ TABLE IT_RET WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0.
    V_MSG = IT_RET-MESSAGE.

    PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'PR Not Created' 'Error' V_MSG.
    PERFORM F_EXIT.
  ELSE.

    LOOP AT ITAB_PR INTO WA_PR WHERE ZGROUP_PR EQ WA_PR2-ZGROUP_PR.
      CONCATENATE V_PRNO WA_PR-ZPRITEM INTO V_OBJNUM SEPARATED BY '-'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_SUCCESS '' V_OBJNUM '' '' 'PR Created' 'Success' ''.
    ENDLOOP.
    PERFORM COMMIT.
  ENDIF.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  WA_PR-ZPRNO = V_PRNO.
  MODIFY ITAB_PR FROM WA_PR TRANSPORTING ZPRNO WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR.

  ITAB_PR2[] = ITAB_PR[].
  DELETE ADJACENT DUPLICATES FROM ITAB_PR2 COMPARING ZGROUP_PR ZPRITEM.

  DESCRIBE TABLE ITAB_PR LINES V_LINES.

*------Insert Characteristic PR-----*
  CLEAR DYN_COND.
  DYN_COND = 'ZGROUP_PR EQ WA_PR-ZGROUP_PR'.

  LOOP AT ITAB_PR2 INTO WA_PR WHERE (DYN_COND).
    CLEAR: VTEXT, V_PERCENT, V_MATNR.

    SELECT SINGLE MAKTX FROM MAKT INTO V_MAKTX WHERE MATNR EQ WA_PR-ZMATNR.

    IF V_COUNTER EQ 0.
      V_COUNTER = 1.
    ELSE.
      V_COUNTER = V_COUNTER + 1.
    ENDIF.

    V_PERCENT = V_COUNTER / V_LINES * 100.
    CONCATENATE V_COUNTER 'OF' V_LINES ': Change PR Per Item' INTO VTEXT SEPARATED BY SPACE.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PERCENT
        TEXT       = VTEXT.

    WAIT UP TO 1 SECONDS.

    IF WA_PR-ZMATNR(2) = 'SR'.

      CTUMODE = 'N'.
      CLEAR   : BDCDATA.
      REFRESH : BDCDATA.
      PERFORM OPEN_GROUP.
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0105'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-BANFN'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=AB'.
      PERFORM BDC_FIELD       USING 'EBAN-BANFN'          WA_PR-ZPRNO.         "PR
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RM06B-BNFPO'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-KNTTP(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0102'.
      PERFORM BDC_FIELD       USING 'EBAN-TXZ01'          V_MAKTX.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-MENGE'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_DYNPRO      USING 'SAPLCEI0'            '0109'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RCTMS-MWERT(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BACK'.

      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'     'ZZTHICKNESS'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'     WA_PR-ZTHICK_PR.     "Thickness
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'     'ZZEXPIREDLIVE'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'     WA_PR-ZEXPLIFE_PR.   "Exp.Life.
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'     'ZZCORE'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'     WA_PR-ZCORE_PR.      "Core
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'     'ZZWIDTH'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'     WA_PR-ZWIDTH_PR.     "Width
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'     'ZZLENGTH'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'     WA_PR-ZLENGTH_PR.    "Length
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'     'ZZTREATMENT'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'     WA_PR-ZTREAT_PR.     "Treatment
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'     'ZZGRADE'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'     WA_PR-ZGRDFILM_PR.   "Grade
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(08)'     'ZZNUMBEROFROLL'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(08)'     WA_PR-ZROLL_PR.      "Number of Roll
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)'     'ZZCRITERIA'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'     WA_PR-ZCRITERIA_PR.  "Criteria
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(10)'     'ZZALIAS'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(10)'     WA_PR-ZALIAS_PR.     "Alias

      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RM06B-BNFPO'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-KNTTP(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0102'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-MENGE'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_DYNPRO      USING 'SAPLCEI0'            '0109'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RCTMS-MWERT(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BACK'.

      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'     'ZZLABEL'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'     WA_PR-ZTYPLBL_PR.    "Label
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'     'ZZPACKINGCODE'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'     WA_PR-ZKDPACK_PR.    "Kode Pack
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'     'ZZPACKING'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'     WA_PR-ZPACK_PR.      "Packing
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'     'ZZEXLENGTH'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'     WA_PR-ZEXTLENGTH_PR. "Extra Length
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'     'ZZSPECIALTOUCH-1'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'     WA_PR-ZSPCTOUCH1_PR. "Special Touch 1
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'     'ZZSPECIALTOUCH-2'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'     WA_PR-ZSPCTOUCH2_PR. "Special Touch 2
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'     'ZZSPECIALTOUCH-3'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'     WA_PR-ZSPCTOUCH3_PR. "Special Touch 3
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(08)'     'ZZCUSTOMER'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(08)'     WA_PR-ZCUST_PR. "Customer
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)'     'ZZPOCUSTOMER'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'     WA_PR-ZPO_CUST. "No. PO Customer
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(10)'     'ZZSKU'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(10)'     WA_PR-ZSKU_CODE. "Kode SKU

      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BU'.
      PERFORM BDC_TRANSACTION USING 'ME52'.
    ELSE.
      CTUMODE = 'N'.
      CLEAR   : BDCDATA.
      REFRESH : BDCDATA.
      PERFORM OPEN_GROUP.
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0105'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-BANFN'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=AB'.
      PERFORM BDC_FIELD       USING 'EBAN-BANFN'          WA_PR-ZPRNO.         "PR
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RM06B-BNFPO'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-KNTTP(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0102'.
      PERFORM BDC_FIELD       USING 'EBAN-TXZ01'          V_MAKTX.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-MENGE'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_DYNPRO      USING 'SAPLCEI0'            '0109'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RCTMS-MWERT(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BACK'.

*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'     'ZZTHICKNESS'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'     WA_PR-ZTHICK_PR.     "Thickness
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'     'ZZEXPIREDLIVE'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'     WA_PR-ZEXPLIFE_PR.   "Exp.Life.
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'     'ZZCORE'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'     WA_PR-ZCORE_PR.      "Core
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'     'ZZWIDTH'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'     WA_PR-ZWIDTH_PR.     "Width
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'     'ZZLENGTH'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'     WA_PR-ZLENGTH_PR.    "Length
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'     'ZZTREATMENT'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'     WA_PR-ZTREAT_PR.     "Treatment
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'     'ZZGRADE'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'     WA_PR-ZGRDFILM_PR.   "Grade
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(08)'     'ZZNUMBEROFROLL'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(08)'     WA_PR-ZROLL_PR.      "Number of Roll
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)'     'ZZCRITERIA'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'     WA_PR-ZCRITERIA_PR.  "Criteria
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(10)'     'ZZALIAS'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(10)'     WA_PR-ZALIAS_PR.     "Alias

      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RM06B-BNFPO'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-KNTTP(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_FIELD       USING 'RM06B-BNFPO'         WA_PR-ZPRITEM.       "Item
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0102'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'EBAN-MENGE'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=KONF'.
      PERFORM BDC_DYNPRO      USING 'SAPLCEI0'            '0109'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'          'RCTMS-MWERT(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BACK'.

      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'     'ZZCUSTOMER'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'     WA_PR-ZCUST_PR.    "Customer
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(09)'     'ZZPOCUSTOMER'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(09)'     WA_PR-ZPO_CUST. "No. PO Customer
      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(10)'     'ZZSKU'.
      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(10)'     WA_PR-ZSKU_CODE. "Kode SKU
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'     'ZZLABEL'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'     WA_PR-ZTYPLBL_PR.    "Label
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(02)'     'ZZPACKINGCODE'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'     WA_PR-ZKDPACK_PR.    "Kode Pack
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(03)'     'ZZPACKING'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'     WA_PR-ZPACK_PR.      "Packing
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(04)'     'ZZEXLENGTH'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'     WA_PR-ZEXTLENGTH_PR. "Extra Length
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(05)'     'ZZSPECIALTOUCH-1'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'     WA_PR-ZSPCTOUCH1_PR. "Special Touch 1
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(06)'     'ZZSPECIALTOUCH-2'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'     WA_PR-ZSPCTOUCH2_PR. "Special Touch 2
*      PERFORM BDC_FIELD       USING 'RCTMS-MNAME(07)'     'ZZSPECIALTOUCH-3'.
*      PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'     WA_PR-ZSPCTOUCH3_PR. "Special Touch 3

      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '/00'.
      PERFORM BDC_DYNPRO      USING 'SAPMM06B'            '0106'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'          '=BU'.
      PERFORM BDC_TRANSACTION USING 'ME52'.
    ENDIF.


    PERFORM CLOSE_GROUP.
    READ TABLE MESSTAB WITH KEY  MSGTYP = 'E'.
    IF SY-SUBRC EQ 0.
      PERFORM F_READ_BDC_MSG.

      V_MESSAGE = IT_RET-MESSAGE.

      WA_DISP-ICON = C_ICON_ERROR.
      CONCATENATE 'Error.' 'Release PR Failed' '(' V_MESSAGE ')' INTO WA_DISP-MSG.

      MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON MSG WHERE GROUP EQ WA_PR-ZGROUP_PR
                                                          AND ITEM  EQ WA_PR-ZPRITEM.
      PERFORM F_EXIT.
    ENDIF.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

    "Release PR
    CLEAR: V_PRNO, V_PRITM.
    V_PRNO  = WA_PR-ZPRNO.
    V_PRITM = WA_PR-ZPRITEM.

    CLEAR : IT_RET. REFRESH : IT_RET.
    CLEAR: V_NUMBER, V_ITEM, V_PLANT.
    CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
      EXPORTING
        NUMBER   = V_PRNO
        REL_CODE = 'MD'
        ITEM     = V_PRITM
      TABLES
        RETURN   = IT_RET.
    READ TABLE IT_RET WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
      V_MESSAGE = IT_RET-MESSAGE.

      WA_DISP-ICON = C_ICON_ERROR.
      CONCATENATE 'Error.' 'Release PR Failed' '(' V_MESSAGE ')' INTO WA_DISP-MSG.

      MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON MSG WHERE GROUP EQ WA_PR-ZGROUP_PR
                                                          AND ITEM  EQ WA_PR-ZPRITEM.
      PERFORM F_EXIT.
    ELSE.
      PERFORM COMMIT.
    ENDIF.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

    WAIT UP TO 1 SECONDS.

    CLEAR : IT_RET. REFRESH : IT_RET.
    CLEAR : V_NUMBER, V_ITEM, V_PLANT.
    CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
      EXPORTING
        NUMBER   = V_PRNO
        REL_CODE = 'CS'
        ITEM     = V_PRITM
      TABLES
        RETURN   = IT_RET.
    READ TABLE IT_RET WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
      V_MESSAGE = IT_RET-MESSAGE.

      WA_DISP-ICON = C_ICON_ERROR.
      CONCATENATE 'Error.' 'Release PR Failed' '(' V_MESSAGE ')' INTO WA_DISP-MSG.

      MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON MSG WHERE GROUP EQ WA_PR-ZGROUP_PR
                                                          AND ITEM  EQ WA_PR-ZPRITEM.
      PERFORM F_EXIT.
    ELSE.
      PERFORM COMMIT.
    ENDIF.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  REFRESH: IT_PRITEM, IT_PRITEMX, IT_PRHEADER, IT_PRHEADERX, IT_RET.
  CLEAR  : WA_PRITEM, WA_PRITEMX, WA_PRHEADER, WA_PRHEADERX.
ENDFORM.                    "CREATE_PR

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_PO.
  CLEAR DYN_COND.

  DYN_COND = 'ZGROUP_PO = WA_PR-ZGROUP_PR'.

  DELETE ADJACENT DUPLICATES FROM ITAB_PO COMPARING ZGROUP_PO ZPOITEM.

  LOOP AT ITAB_PO INTO WA_PO WHERE (DYN_COND).

    CLEAR: V_CUOBJ, CUVAL_ET, V_MAKTX.
    REFRESH CUVAL_ET.

    IF RB_BG2 EQ 'X'.
      DYN_COND2 = 'ZPRITEM'.
    ELSEIF RB_PR2 EQ 'X'.
      DYN_COND2 = 'ZPRITEMREF'.
*      DYN_COND2 = 'ZGROUP_PR = WA_PO-ZGROUP_PO AND ZPRITEMREF = WA_PO-ZPOITEM'.
    ENDIF.

*    READ TABLE ITAB_PR INTO WA_PR WITH KEY ZGROUP_PR     = WA_PO-ZGROUP_PO
*                                           (DYN_COND2)   = WA_PO-ZPOITEM.

    LOOP AT ITAB_PR INTO WA_PR WHERE ZGROUP_PR     = WA_PO-ZGROUP_PO.
*                                           (DYN_COND2)   = WA_PO-ZPOITEM.
      SELECT SINGLE CUOBJ FROM EBAN INTO V_CUOBJ WHERE BANFN EQ WA_PR-ZPRNO AND BNFPO EQ WA_PR-ZPRITEM.

      CALL FUNCTION 'VELO01_GET_CONFIGURATION'
        EXPORTING
          CUOBJ_NUMBER = V_CUOBJ
        TABLES
          CUVAL_ET     = CUVAL_ET.

      SELECT SINGLE WERKS FROM EBAN  INTO V_WERKS WHERE BANFN EQ WA_PR-ZPRNO AND BNFPO EQ WA_PR-ZPRITEM.
      SELECT SINGLE BUKRS FROM T001K INTO V_BUKRS WHERE BWKEY EQ V_WERKS.

      SHIFT WA_PR-ZPRITEM LEFT DELETING LEADING '0'.
      WA_PO-ZPOITEM      = WA_PR-ZPRITEM.
      WA_PO-ZPOQTY       = WA_PR-ZQTY_PR.
      WA_PO-ZPGR_PO      = WA_PR-ZPGR_PR.
      WA_PO-ZFILMTYPE_PO = WA_PR-ZFILMTYPE_PR.
      WA_PO-ZUOM_PO      = WA_PR-ZUOM_PR.
      WA_PO-ZDLVDATE_PO  = WA_PR-ZDLVDATE_PR.
      WA_PO-ZPLANT_PO    = WA_PR-ZPLANT.
      WA_PO-ZCOMPCODE    = V_BUKRS.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCODE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZKDFILM_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTYPEFILM_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZTHICKNESS'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTHICK_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZEXPLIFE_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCORE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCORE_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZWIDTH_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZLENGTH_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZTREATMENT'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTREAT_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZINSIDE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZINSIDE_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZOUTSIDE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZOUTSIDE_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCONVERSIONMTRKG'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCONVMKG_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCONVROLLKG_PO = CUVAL_ET-ATWRT.
        REPLACE ALL OCCURRENCES OF 'Kg/Rol' IN WA_PO-ZCONVROLLKG_PO WITH ''.
        CONDENSE WA_PO-ZCONVROLLKG_PO.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZGRADE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZGRDFILM_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZWEIGTH_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZROLL_PO = CUVAL_ET-ATWRT.
        REPLACE ALL OCCURRENCES OF 'ROL' IN WA_PO-ZROLL_PO WITH ''.
        CONDENSE WA_PO-ZROLL_PO.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZTOTALM2'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCONVM2_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCRITERIA'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCRITERIA_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZALIAS'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZALIAS_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZDENSITY'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZDENSITY_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZGRAMMAGE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZGRAMMAGE_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZLABEL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTYPLBL_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH1_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZSPECIALTOUCH-2'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH2_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH3_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZPACKING'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZPACK_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZCONVERSIONROLLM2'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCONVROLLM2_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZEXLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZEXTLENGTH_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZWEIGHTEL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZEXTWEIGHT_PO = CUVAL_ET-ATWRT.
      ENDIF.

      READ TABLE CUVAL_ET WITH KEY ATNAM = 'ZZPACKINGCODE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZKDPACK_PO = CUVAL_ET-ATWRT.
      ENDIF.

      MODIFY ITAB_PO FROM WA_PO TRANSPORTING ZKDFILM_PO ZTYPEFILM_PO ZTHICK_PO ZEXPLIFE_PO ZCORE_PO ZWIDTH_PO ZLENGTH_PO
                                             ZTREAT_PO ZINSIDE_PO ZOUTSIDE_PO ZCONVMKG_PO ZCONVROLLKG_PO ZGRDFILM_PO ZWEIGTH_PO
                                             ZROLL_PO ZCONVM2_PO ZCRITERIA_PO ZALIAS_PO ZDENSITY_PO ZGRAMMAGE_PO ZTYPLBL_PO
                                             ZSPCTOUCH1_PO ZSPCTOUCH2_PO ZSPCTOUCH3_PO ZPACK_PO ZCONVROLLM2_PO ZEXTLENGTH_PO
                                             ZEXTWEIGHT_PO ZKDPACK_PO ZPOITEM ZPOQTY ZPGR_PO ZPLANT_PO ZCOMPCODE
                                             ZFILMTYPE_PO ZUOM_PO ZDLVDATE_PO
      WHERE ZGROUP_PO EQ WA_PO-ZGROUP_PO AND ZPOITEM EQ WA_PO-ZPOITEM.

      WA_POHEADER-COMP_CODE   = V_BUKRS.
      WA_POHEADER-DOC_TYPE    = WA_PO-ZPOTYPE.
      WA_POHEADER-VENDOR      = WA_PO-ZVENDOR.
      WA_POHEADER-PURCH_ORG   = WA_PO-ZEKORG.
      WA_POHEADER-PUR_GROUP   = WA_PO-ZPGR_PO.
*        WA_POHEADER-CURRENCY    = WA_PO-ZCURR_PO.
      WA_POHEADER-SALES_PERS  = WA_PO-ZSLSPERSON.
      APPEND WA_POHEADER TO IT_POHEADER.

      WA_POHEADERX-COMP_CODE   = 'X'.
      WA_POHEADERX-DOC_TYPE    = 'X'.
      WA_POHEADERX-VENDOR      = 'X'.
      WA_POHEADERX-PURCH_ORG   = 'X'.
      WA_POHEADERX-PUR_GROUP   = 'X'.
*        WA_POHEADERX-CURRENCY    = 'X'.
      WA_POHEADERX-SALES_PERS  = 'X'.
      APPEND WA_POHEADERX TO IT_POHEADERX.

      WA_POITEM-PO_ITEM       = WA_PO-ZPOITEM.
      WA_POITEM-PLANT         = WA_PO-ZPLANT_PO.
      WA_POITEM-QUANTITY      = WA_PO-ZPOQTY.
*        WA_POITEM-NET_PRICE      = WA_PO-ZNETPR.
      WA_POITEM-TAX_CODE      = WA_PO-ZMWSKZ.
      WA_POITEM-OVER_DLV_TOL  = WA_PO-ZDLVTOLERANCE.
      WA_POITEM-PREQ_NO       = WA_PR-ZPRNO.
      WA_POITEM-PREQ_ITEM     = WA_PR-ZPRITEM.
      WA_POITEM-FREE_ITEM     = WA_PO-ZFREECHARGE_PO.

      SELECT SINGLE MAKTX FROM MAKT INTO V_MAKTX WHERE MATNR EQ WA_PR-ZMATNR.

      CONCATENATE WA_PO-ZWIDTH_PO'mm*' WA_PO-ZLENGTH_PO'm*' WA_PO-ZROLL_PO'R' INTO V_SHRT_TXT.
      REPLACE ALL OCCURRENCES OF ',' IN V_SHRT_TXT WITH ''.
      CONCATENATE V_MAKTX V_SHRT_TXT INTO V_SHRT_TXT SEPARATED BY SPACE.
      WA_POITEM-SHORT_TEXT    = V_SHRT_TXT.
      APPEND WA_POITEM TO IT_POITEM.

      WA_POITEMX-PO_ITEM       = WA_PR-ZPRITEM.
      WA_POITEMX-PO_ITEMX      = 'X'.
      WA_POITEMX-PLANT         = 'X'.
      WA_POITEMX-QUANTITY      = 'X'.
*        WA_POITEMX-NET_PRICE     = 'X'.
      WA_POITEMX-TAX_CODE      = 'X'.
      WA_POITEMX-OVER_DLV_TOL  = 'X'.
      WA_POITEMX-PREQ_NO       = 'X'.
      WA_POITEMX-PREQ_ITEM     = 'X'.
      WA_POITEMX-SHORT_TEXT    = 'X'.
      WA_POITEMX-FREE_ITEM     = 'X'.
      APPEND WA_POITEMX TO IT_POITEMX.

    ENDLOOP.

  ENDLOOP.

  PERFORM F_CREATE_PO.
  CLEAR V_MAKTX.

ENDFORM.                    "F_PROCESS_PO

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PO_ZPRITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_PO_ZPRITEM.

ENDFORM.                    "F_PROCESS_PO_ZPRITEM

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CREATE_PO.

  CLEAR: V_PONUM, V_NUMBER, V_ITEM, V_PLANT, V_MSG.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      POHEADER         = WA_POHEADER
      POHEADERX        = WA_POHEADERX
      NO_PRICE_FROM_PO = 'X'
    IMPORTING
      EXPPURCHASEORDER = V_PONUM
    TABLES
      RETURN           = IT_RET
      POITEM           = IT_POITEM
      POITEMX          = IT_POITEMX.

  READ TABLE IT_RET INTO WA_RET WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0.
    V_MSG = WA_RET-MESSAGE.

    PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_ERROR '' '' '' '' 'PO Not Created' 'Error' V_MSG.
    PERFORM F_EXIT.
  ELSE.
    LOOP AT ITAB_PR2 INTO WA_PR WHERE ZGROUP_PR EQ WA_PO-ZGROUP_PO.
      CONCATENATE V_PONUM WA_PR-ZPRITEM INTO V_OBJNUM SEPARATED BY '-'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_SUCCESS '' '' V_OBJNUM '' 'PO Created' 'Success' ''.
    ENDLOOP.
    PERFORM COMMIT.
  ENDIF.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  WA_PO-ZPO_NUMBER = V_PONUM.
  MODIFY ITAB_PO FROM WA_PO TRANSPORTING ZPO_NUMBER WHERE ZGROUP_PO EQ WA_SO-ZGROUP_SO
                                                       OR ZGROUP_PO EQ WA_PR-ZGROUP_PR.

  SELECT SINGLE BUKRS FROM EKPO INTO V_BUKRS WHERE EBELN EQ WA_PO-ZPO_NUMBER.

  CLEAR   : WA_POHEADER, WA_POHEADERX, WA_POITEM, WA_POITEMX.
  REFRESH : IT_POHEADER, IT_POHEADERX, IT_POITEM, IT_POITEMX.

  WA_POHEADER-PO_NUMBER = WA_PO-ZPO_NUMBER.
  WA_POHEADER-COMP_CODE = V_BUKRS.
  APPEND WA_POHEADER TO IT_POHEADER.

  WA_POHEADERX-PO_NUMBER = 'X'.
  WA_POHEADERX-COMP_CODE = 'X'.
  APPEND WA_POHEADERX TO IT_POHEADERX.

  WA_POITEM-PO_ITEM     = WA_PO-ZPOITEM.
*  WA_POITEM-NET_PRICE   = WA_PO-ZNETPR.
  APPEND WA_POITEM TO IT_POITEM.

  WA_POITEMX-PO_ITEM    = WA_PO-ZPOITEM.
  WA_POITEMX-PO_ITEMX   = 'X'.
*  WA_POITEMX-NET_PRICE  = 'X'.
  APPEND WA_POITEMX TO IT_POITEMX.

  CLEAR IT_RET.
  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = WA_PO-ZPO_NUMBER
      POHEADER      = IT_POHEADER
      POHEADERX     = IT_POHEADERX
    TABLES
      RETURN        = IT_RET
      POITEM        = IT_POITEM
      POITEMX       = IT_POITEMX.

  READ TABLE IT_RET WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0.
    V_MESSAGE = IT_RET-MESSAGE.

    WA_DISP-ICON = C_ICON_ERROR.
    CONCATENATE 'Error.' 'Change PO Failed' '('V_MESSAGE')' INTO WA_DISP-MSG.
    MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON MSG WHERE GROUP EQ WA_PR-ZGROUP_PR AND ITEM EQ WA_PR-ZPRITEM.
    PERFORM F_EXIT.
  ELSE.
    PERFORM COMMIT.
  ENDIF.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  "Release PO
  CLEAR : IT_RET. REFRESH : IT_RET.
  CLEAR : V_NUMBER, V_ITEM, V_PLANT.

*  CALL FUNCTION 'BAPI_PO_RELEASE'
*    EXPORTING
*      PURCHASEORDER = WA_PO-ZPO_NUMBER
*      PO_REL_CODE   = '01'
*    TABLES
*      RETURN        = IT_RET.
*  READ TABLE IT_RET WITH KEY TYPE = 'E'.
*  IF SY-SUBRC EQ 0.
*    V_MESSAGE = IT_RET-MESSAGE.
*
*    WA_DISP-ICON = C_ICON_ERROR.
*    CONCATENATE 'Error.' 'Release PO Failed' '('V_MESSAGE')' INTO WA_DISP-MSG.
*    MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON MSG WHERE GROUP EQ WA_PR-ZGROUP_PR AND ITEM EQ WA_PR-ZPRITEM.
*
*    PERFORM F_EXIT.
*  ELSE.
*    PERFORM COMMIT.
*  ENDIF.

  REFRESH: IT_POITEM, IT_POITEMX, IT_PRHEADER, IT_PRHEADERX, IT_RET.
  CLEAR  : WA_POITEM, WA_POITEMX, WA_PRHEADER, WA_PRHEADERX.

ENDFORM.                    "F_CREATE_PO

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SOI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_SO_IC.
  CLEAR DYN_COND.

  DYN_COND = 'ZGROUP_SOI = WA_PR-ZGROUP_PR'.

  LOOP AT ITAB_SOI INTO WA_SOI WHERE (DYN_COND).

    IF RB_PR2 EQ 'X'.
      WA_SOI-ZSOITEM_SOI = V_POSNR = WA_SOI-ZSOITEM_SOI.

      ITAB_PR2[] = ITAB_PR[].
      SORT ITAB_PR2 BY NGROUP.
      DELETE ADJACENT DUPLICATES FROM ITAB_PR2 COMPARING ZGROUP_PR ZPRITEM.

*      ELSEIF RB_PO2 EQ 'X'.
      SORT ITAB_PO BY NGROUP.
      READ TABLE ITAB_PO WITH KEY ZGROUP_PO = WA_SOI-ZGROUP_SOI
                                  ZPOITEM   = WA_SOI-ZSOITEM_SOI.

      WA_SOI-ZROLL_SOI      = ITAB_PO-ZROLL_PO.
      WA_SOI-ZKDPACK_SOI    = ITAB_PO-ZKDPACK_PO.
      WA_SOI-ZEXTLENGTH_SOI = ITAB_PO-ZEXTLENGTH_PO.
      WA_SOI-ZUOM_SOI       = ITAB_PO-ZUOM_PO.

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          INPUT  = ITAB_PO-ZDLVDATE_PO
        IMPORTING
          OUTPUT = WA_SOI-ZDLVDATE_SOI.

      IF WA_SOI-ZPOLINE_SOI EQ ''.
        V_LEN  = STRLEN( ITAB_PO-ZPOITEM ).
        V_LEN  = V_LEN - 1.
        WA_SOI-ZPOLINE_SOI = ITAB_PO-ZPOITEM(V_LEN).
      ENDIF.

      MODIFY ITAB_SOI FROM WA_SOI TRANSPORTING ZDLVDATE_SOI ZPOLINE_SOI ZROLL_SOI ZKDPACK_SOI ZEXTLENGTH_SOI ZUOM_SOI
      WHERE ZGROUP_SOI EQ WA_SOI-ZGROUP_SOI AND ZSOITEM_SOI EQ WA_SOI-ZSOITEM_SOI.

      ITAB_PO2[] = ITAB_PO[].
      SORT ITAB_PO2 BY NGROUP ASCENDING.
      DELETE ADJACENT DUPLICATES FROM ITAB_PO2 COMPARING ZGROUP_PO ZPOITEM.
    ENDIF.

    SORT ITAB_PO BY NGROUP.
    READ TABLE ITAB_PO WITH KEY ZGROUP_PO = WA_SOI-ZGROUP_SOI
                                ZPOITEM   = WA_SOI-ZSOITEM_SOI.

    WA_SOI-ZPOREF_SOI  = ITAB_PO-ZPO_NUMBER.

    CLEAR V_BEDAT.
    SELECT SINGLE BEDAT FROM EKKO INTO V_BEDAT WHERE EBELN EQ WA_SOI-ZPOREF_SOI.
    IF SY-SUBRC EQ 0.
      WA_SOI-ZPODATEREF_SOI  = V_BEDAT.
    ENDIF.

    WA_SOI-ZUOM_SOI        = ITAB_PO-ZUOM_PO.

    WA_SOI-ZSOITEM_SOI     = ITAB_PO-ZPOITEM.
    WA_SOI-ZTHICK_SOI      = ITAB_PO-ZTHICK_PO.
    WA_SOI-ZCORE_SOI       = ITAB_PO-ZCORE_PO.
    WA_SOI-ZTREAT_SOI      = ITAB_PO-ZTREAT_PO.
    WA_SOI-ZWIDTH_SOI      = ITAB_PO-ZWIDTH_PO.
    WA_SOI-ZLENGTH_SOI     = ITAB_PO-ZLENGTH_PO.
    WA_SOI-ZGRDFILM_SOI    = ITAB_PO-ZGRDFILM_PO.
    WA_SOI-ZPACK_SOI       = ITAB_PO-ZPACK_PO.
*    WA_SOI-ZPRICE_SOI      = ITAB_PO-ZNETPR.
*    WA_SOI-ZCURR_SOI       = ITAB_PO-ZCURR_PO.
    WA_SOI-ZUOMPRICE_SOI   = ITAB_PO-ZUOMPRICE_PO.
    WA_SOI-ZKDPACK_SOI     = ITAB_PO-ZKDPACK_PO.
    WA_SOI-ZSPCTOUCH1_SOI  = ITAB_PO-ZSPCTOUCH1_PO.
    WA_SOI-ZSPCTOUCH2_SOI  = ITAB_PO-ZSPCTOUCH2_PO.
    WA_SOI-ZSPCTOUCH3_SOI  = ITAB_PO-ZSPCTOUCH3_PO.

    MODIFY ITAB_SOI FROM WA_SOI TRANSPORTING ZSOITEM_SOI ZPLANT_SOI ZUOM_SOI ZTHICK_SOI ZCORE_SOI ZTREAT_SOI ZWIDTH_SOI
                                             ZLENGTH_SOI ZEXTLENGTH_SOI ZPACK_SOI ZPRICE_SOI ZCURR_SOI ZUOMPRICE_SOI ZKDPACK_SOI
                                             ZSPCTOUCH1_SOI ZSPCTOUCH2_SOI ZSPCTOUCH3_SOI ZPOREF_SOI ZPODATEREF_SOI ZGRDFILM_SOI ZTYPLBL_SOI ZROLL_SOI
    WHERE ZGROUP_SOI EQ WA_SOI-ZGROUP_SOI AND ZSOITEM_SOI EQ WA_SOI-ZSOITEM_SOI.

  ENDLOOP.

  PERFORM F_CREATE_IC.
ENDFORM.                    "PROCESS_SOI

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_IC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CREATE_IC.
  CLEAR   :T_QUOTE_HEADER_IN, V_SO, IT_RETURN_CREATE_SO, TAB_ITEMS, TAB_QUOTE_PARTNR, TAB_ITEMS_SCHED, TAB_SCHEDULES_INX,
           TAB_QUOT_COND, TAB_QUOTE_REF, TAB_QUOTE_INST, TAB_QUOTE_VALUE, TAB_QUOTE_REFINST.
  REFRESH :T_QUOTE_HEADER_IN, IT_RETURN_CREATE_SO, TAB_ITEMS, TAB_QUOTE_PARTNR, TAB_ITEMS_SCHED, TAB_SCHEDULES_INX,
           TAB_QUOT_COND, TAB_QUOTE_REF, TAB_QUOTE_INST, TAB_QUOTE_VALUE, TAB_QUOTE_REFINST.

  ITAB_DETAIL_SOI[] = ITAB_CHANGE_SOI[] = ITAB_SOI2[] = ITAB_SOI[].

  DELETE ADJACENT DUPLICATES FROM ITAB_SOI2       COMPARING ZGROUP_SOI.             "COMPARING ZPOREF_SOI.
  DELETE ADJACENT DUPLICATES FROM ITAB_DETAIL_SOI COMPARING ZGROUP_SOI ZSOITEM_SOI. "COMPARING ZPOREF_SOI ZSOITEM_SOI.

  CLEAR DYN_COND.

  DYN_COND = 'ZGROUP_SOI = WA_PR-ZGROUP_PR'.

  LOOP AT ITAB_SOI2 INTO WA_SOI WHERE (DYN_COND).
    CLEAR : T_QUOTE_HEADER_IN, TAB_QUOTE_PARTNR, IT_RETURN_CREATE_SO, TAB_QUOT_COND.
    REFRESH : IT_RETURN_CREATE_SO, EXTENSIONIN.

    "START HEADER
    T_QUOTE_HEADER_IN-DOC_TYPE    = WA_SOI-ZORDTYPE_SOI.
    T_QUOTE_HEADER_IN-SALES_ORG   = WA_SOI-ZSLSORG_SOI.
    T_QUOTE_HEADER_IN-DIVISION    = WA_SOI-ZDIVISION_SOI.
    T_QUOTE_HEADER_IN-DISTR_CHAN  = WA_SOI-ZDISTCHANEL_SOI.
    T_QUOTE_HEADER_IN-PURCH_NO_C  = WA_SOI-ZPOREF_SOI.
    T_QUOTE_HEADER_IN-CURRENCY    = WA_SOI-ZCURR_SOI.
    T_QUOTE_HEADER_IN-PURCH_DATE  = SY-DATUM.
    PERFORM F_CHANGEDATE USING WA_SOI-ZDLVDATE_SOI CHANGING T_QUOTE_HEADER_IN-REQ_DATE_H.
    T_QUOTE_HEADER_IN-QT_VALID_T  = WA_SOI-ZPODATEREF_SOI.

    "START PARTNER
    WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_SOI-ZCUST_SOI.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.

    WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_SOI-ZSHIPH_SOI.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.
    "END PARTNER

    CLEAR : V_KALKS, V_WAERK, V_KALVG, V_KARTV, V_MATNR, TAB_ITEMS, TAB_QUOTE_REF, TAB_QUOTE_REFINST, TAB_QUOTE_INST, TAB_QUOTE_VALUE, IT_RETURN_CREATE_SO, TAB_ITEMS_SCHED, TAB_SCHEDULES_INX, WA_EXTENSIONIN, EXTENSIONIN.

    LOOP AT ITAB_DETAIL_SOI INTO WA_DETAIL_SOI WHERE ZPOREF_SOI = WA_SOI-ZPOREF_SOI.
      REPLACE ALL OCCURRENCES OF '.0' IN WA_DETAIL_SOI-ZTHICK_SOI WITH ''.
      CONCATENATE WA_DETAIL_SOI-ZTYPE_SOI '-' WA_DETAIL_SOI-ZTHICK_SOI INTO V_ATWTB.

      SELECT CAWN~ATWRT
             INTO V_ATWTB
             FROM CAWN JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
             WHERE CAWN~ATINN EQ '0000000811' AND CAWNT~ATWTB = V_ATWTB.
      ENDSELECT.

      IF SY-SUBRC NE 0.
        IF RB_BG2 EQ 'X' OR RB_PR2 EQ 'X'.
          PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Material tidak Ditemukan' 'Error' ''.
          V_FLAG = 'X'.
        ENDIF.
      ENDIF.

      IF V_FLAG EQ 'X'.
        EXIT.
      ENDIF.

      IF WA_DETAIL_SOI-ZINOUT_SOI EQ 'I'.
        CONCATENATE 'SR' V_ATWTB 'I' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SOI-ZINOUT_SOI EQ 'X'.
        CONCATENATE 'SR' V_ATWTB 'X' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SOI-ZINOUT_SOI EQ ''.
        V_MATNR = WA_DETAIL_SO-ZTYPE_SO.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_DETAIL_SOI-ZINOUT_SOI EQ 'O'.
        CONCATENATE 'SR' V_ATWTB 'O' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ENDIF.

      SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR = V_MATNR.
      LV_STR = V_MATKL(1).

      "Mencari item category
      SELECT SINGLE MVKE~MTPOS
        INTO V_MTPOS
        FROM MVKE
        WHERE MATNR = V_MATNR.

      SELECT SINGLE T184~PSTYV
        INTO V_PSTYV
        FROM T184
        WHERE AUART = WA_DETAIL_SOI-ZORDTYPE_SOI
        AND MTPOS = V_MTPOS
        AND VWPOS = ''
        AND UEPST = ''.

      SELECT SINGLE KNVV~KALKS
        INTO V_KALKS
        FROM KNVV
        WHERE KUNNR = WA_DETAIL_SOI-ZCUST_SOI
        AND VKORG = WA_DETAIL_SOI-ZSLSORG_SOI.

      SELECT SINGLE TVAK~KALVG
        INTO V_KALVG
        FROM TVAK
        WHERE AUART = WA_DETAIL_SOI-ZORDTYPE_SOI.

      SELECT SINGLE T683V~KARTV
        INTO V_KARTV
        FROM T683V
        WHERE VKORG = WA_DETAIL_SOI-ZSLSORG_SOI
        AND VTWEG = WA_DETAIL_SOI-ZDISTCHANEL_SOI
        AND SPART = WA_DETAIL_SOI-ZDIVISION_SOI
        AND KALVG = V_KALVG
        AND KALKS = V_KALKS.

*      MOVE WA_DETAIL_SOI-ZSOITEM_SOI TO V_POLINE.
*      REPLACE ALL OCCURRENCES OF '0' IN V_POLINE WITH ''.
      MOVE WA_DETAIL_SOI-ZPOLINE_SOI TO V_POLINE.
      SHIFT V_POLINE LEFT DELETING LEADING '0'.


      WA_ITEM-PO_ITM_NO   = V_POLINE.
      WA_ITEM-ITM_NUMBER  = WA_DETAIL_SOI-ZSOITEMREF_SOI.
      WA_ITEM-PLANT       = WA_DETAIL_SOI-ZPLANT_SOI.
      WA_ITEM-SHIP_POINT  = WA_DETAIL_SOI-ZSHPPOINT_SOI.
      WA_ITEM-SALES_UNIT  = WA_DETAIL_SOI-ZUOM_SOI.
      WA_ITEM-MATERIAL    = V_MATNR.
      WA_ITEM-ITEM_CATEG  = V_PSTYV.
      WA_ITEM-ROUTE       = 103014.

      CONCATENATE WA_DETAIL_SOI-ZPOREF_SOI '-' WA_DETAIL_SOI-ZSOITEM_SOI INTO WA_ITEM-PURCH_NO_S.
      CONDENSE WA_ITEM-PURCH_NO_S.

*      IF RB2 EQ 'X'.
      WA_ITEM-REF_1_S   = 'INPUTAN'.
*      ELSE.
*        V_SO = WA_DETAIL_SOI-ZSOREF_SOI.
*        SHIFT V_SO LEFT DELETING LEADING '0'.
*        IF WA_DETAIL_SOI-ZSOITEMREF_SOI NE ''.
*          CONCATENATE V_SO '-' WA_DETAIL_SOI-ZSOITEMREF_SOI INTO WA_ITEM-REF_1_S.
*        ELSE.
*          CONCATENATE V_SO '-' WA_DETAIL_SOI-ZSOITEM_SOI INTO WA_ITEM-REF_1_S.
*        ENDIF.
*        CONDENSE WA_ITEM-REF_1_S.
*      ENDIF.

      IF V_KALVG EQ 5.
        WA_ITEM-TARGET_QU  = WA_DETAIL_SOI-ZUOM_SOI.
        WA_ITEM-TARGET_QTY = WA_DETAIL_SOI-ZROLL_SOI.
      ENDIF.
      APPEND WA_ITEM TO TAB_ITEMS.
      CLEAR WA_ITEM.

      "START CONFIGURATION
      WA_QUOTE_REF-POSEX     = WA_DETAIL_SOI-ZPOLINE_SOI.
      IF RB_PR2 EQ 'X'.
        SHIFT WA_QUOTE_REF-POSEX LEFT DELETING LEADING '0'.
      ENDIF.
      WA_QUOTE_REF-CONFIG_ID = WA_DETAIL_SOI-ZSOITEM_SOI.
      WA_QUOTE_REF-ROOT_ID   = '00000001'.
      APPEND WA_QUOTE_REF TO TAB_QUOTE_REF.
      CLEAR  WA_QUOTE_REF.
      "END CONFIGURATION

      "START REFINST
      WA_QUOTE_REFINST-POSEX     = WA_DETAIL_SOI-ZPOLINE_SOI.
      IF RB_PR2 EQ 'X'.
        SHIFT WA_QUOTE_REFINST-POSEX LEFT DELETING LEADING '0'.
      ENDIF.
      WA_QUOTE_REFINST-CONFIG_ID = WA_DETAIL_SOI-ZSOITEM_SOI.
      WA_QUOTE_REFINST-INST_ID   = '00000001'.
      APPEND WA_QUOTE_REFINST TO TAB_QUOTE_REFINST.
      CLEAR WA_QUOTE_REFINST.
      "END REFINST

      "Start Attributes Value
      IF LV_STR EQ '3' AND V_KALVG NE 5.
        IF WA_DETAIL_SOI-ZUOM_SOI CS 'ROL' OR
           WA_DETAIL_SOI-ZUOM_SOI CS 'LB'  OR
           WA_DETAIL_SOI-ZUOM_SOI CS 'M2'  OR
           WA_DETAIL_SOI-ZUOM_SOI CS 'KG'.

          IF WA_DETAIL_SOI-ZROLL_SOI NE ''.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZNUMBEROFROLL' WA_DETAIL_SOI-ZROLL_SOI.
          ENDIF.
        ENDIF.
        " Type Film
        IF WA_DETAIL_SOI-ZTYPE_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZTYPE' WA_DETAIL_SOI-ZTYPE_SOI.
        ENDIF.

        " Diameter Core
        IF WA_DETAIL_SOI-ZCORE_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZCORE' WA_DETAIL_SOI-ZCORE_SOI.
        ENDIF.

        " Type Label
        IF WA_DETAIL_SOI-ZTYPLBL_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZLABEL' WA_DETAIL_SOI-ZTYPLBL_SOI.
        ENDIF.

        " Treatment
        IF WA_DETAIL_SOI-ZTREAT_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZTREATMENT' WA_DETAIL_SOI-ZTREAT_SOI.
        ENDIF.

        " Lebar
        IF WA_DETAIL_SOI-ZWIDTH_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZWIDTH' WA_DETAIL_SOI-ZWIDTH_SOI.
        ENDIF.

        " Panjang
        IF WA_DETAIL_SOI-ZLENGTH_SOI NE ''.
          IF WA_DETAIL_SOI-ZUOM_SOI CS 'PAK'.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZLENGTHSHT' WA_DETAIL_SOI-ZLENGTH_SOI.
          ELSE.
            PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZLENGTH' WA_DETAIL_SOI-ZLENGTH_SOI.
          ENDIF.
        ENDIF.

        " Kriteria
        IF WA_DETAIL_SOI-ZCRITERIA_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZCRITERIA' WA_DETAIL_SOI-ZCRITERIA_SOI.
        ENDIF.

        " Extra length
        IF WA_DETAIL_SOI-ZEXTLENGTH_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZEXLENGTH' WA_DETAIL_SOI-ZEXTLENGTH_SOI.
        ENDIF.

        " Packing
        IF WA_DETAIL_SOI-ZPACK_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZPACKING' WA_DETAIL_SOI-ZPACK_SOI.
        ENDIF.

        " Kode Pack
        IF WA_DETAIL_SOI-ZKDPACK_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZPACKINGCODE' WA_DETAIL_SOI-ZKDPACK_SOI.
        ENDIF.

        " Special Touch-1
        IF WA_DETAIL_SOI-ZSPCTOUCH1_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZSPECIALTOUCH-1' WA_DETAIL_SOI-ZSPCTOUCH1_SOI.
        ENDIF.

        " Special Touch-2
        IF WA_DETAIL_SOI-ZSPCTOUCH2_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZSPECIALTOUCH-2' WA_DETAIL_SOI-ZSPCTOUCH2_SOI.
        ENDIF.

        " Special Touch-3
        IF WA_DETAIL_SOI-ZSPCTOUCH3_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZSPECIALTOUCH-3' WA_DETAIL_SOI-ZSPCTOUCH3_SOI.
        ENDIF.

        " Alias
        IF WA_DETAIL_SOI-ZALIAS_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZALIAS' WA_DETAIL_SOI-ZALIAS_SOI.
        ENDIF.

        " Thickness
        IF WA_DETAIL_SOI-ZTHICK_SOI NE ''.
          PERFORM F_FILL_CHAR USING WA_DETAIL_SOI-ZSOITEM_SOI 'ZZTHICKNESS' WA_DETAIL_SOI-ZTHICK_SOI.
        ENDIF.

      ENDIF.
      "End Attributes Value

      "CONDITION PRICE
      IF V_KALVG = 5 AND WA_DETAIL_SOI-ZDISTCHANEL_SOI EQ '01' .
        WA_QUOT_COND-COND_TYPE   = 'ZDD0'.
      ELSEIF V_KALVG = 5 AND WA_DETAIL_SOI-ZDISTCHANEL_SOI EQ '02' .
        WA_QUOT_COND-COND_TYPE   = 'ZED0'.
      ELSE.
        WA_QUOT_COND-COND_TYPE   = V_KARTV.
      ENDIF.

      WA_QUOT_COND-ITM_NUMBER  = WA_DETAIL_SOI-ZSOITEM_SOI.
      WA_QUOT_COND-CURRENCY    = WA_DETAIL_SOI-ZCURR_SOI.
      WA_QUOT_COND-COND_VALUE  = WA_DETAIL_SOI-ZPRICE_SOI.
      WA_QUOT_COND-COND_UNIT   = WA_DETAIL_SOI-ZUOMPRICE_SOI.
      APPEND WA_QUOT_COND TO TAB_QUOT_COND.
      CLEAR WA_QUOT_COND.

      IF LV_STR = 'B'.
        PERFORM F_CHANGEDATE USING WA_DETAIL_SOI-ZDLVDATE_SOI CHANGING WA_ITEMS_SCHED-REQ_DATE.
        WA_ITEMS_SCHED-ITM_NUMBER = WA_DETAIL_SOI-ZSOITEM_SOI.
        WA_ITEMS_SCHED-REQ_QTY    = WA_DETAIL_SOI-ZROLL_SOI.
        WA_ITEMS_SCHED-REQ_DATE   = WA_ITEMS_SCHED-REQ_DATE.
        WA_ITEMS_SCHED-DATE_TYPE  = '1'.
        WA_ITEMS_SCHED-SCHED_LINE = 1.
        APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
        CLEAR WA_ITEMS_SCHED.

        WA_SCHEDULES_INX-ITM_NUMBER = WA_DETAIL_SOI-ZSOITEM_SOI.
        WA_SCHEDULES_INX-SCHED_LINE  =  1.
        WA_SCHEDULES_INX-UPDATEFLAG  = 'I'.
        WA_SCHEDULES_INX-REQ_QTY     = 'X'.
        WA_SCHEDULES_INX-REQ_DATE    = 'X'.
        APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
        CLEAR WA_SCHEDULES_INX.
      ENDIF.

      IF WA_DETAIL_SOI-ZDATE IS INITIAL.
        WA_DETAIL_SOI-ZDATE = '00000000'.
      ENDIF.

      IF WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZDOR' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZEOR' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZDKB' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZEKB' OR
         WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZDSO' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZESO' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZINV' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZDSD' OR WA_DETAIL_SOI-ZORDTYPE_SOI EQ 'ZESD'.
        IF WA_DETAIL_SOI-ZDATE IS INITIAL OR WA_DETAIL_SOI-ZDATE EQ '00000000'..
          PERFORM F_CHANGEDATE USING WA_DETAIL_SOI-ZDLVDATE_SOI CHANGING WA_DETAIL_SOI-ZDATE.
        ELSE.
          PERFORM F_CHANGEDATE USING WA_DETAIL_SOI-ZDATE CHANGING WA_DETAIL_SOI-ZDATE.
        ENDIF.

        CLEAR: V_BUKRS.
        IF WA_DETAIL_SOI-ZLINE IS INITIAL.
          SELECT SINGLE BUKRS INTO V_BUKRS FROM T001K WHERE BWKEY EQ WA_DETAIL_SOI-ZPLANT_SOI.
          IF SY-SUBRC EQ 0.
            SELECT SINGLE ZLINE INTO WA_DETAIL_SOI-ZLINE FROM ZMAP_PRODLINE WHERE BUKRS EQ V_BUKRS AND MATNR EQ V_MATNR.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM F_CHANGEDATE USING WA_DETAIL_SOI-ZDATE CHANGING WA_DETAIL_SOI-ZDATE.
      ENDIF.

      "Extension Field
      WA_BAPE_VBAP-POSNR  = WA_DETAIL_SOI-ZSOITEM_SOI.
      WA_BAPE_VBAP-ZDATE  = WA_DETAIL_SOI-ZDATE.
      WA_BAPE_VBAP-ZLINE  = WA_DETAIL_SOI-ZLINE.
      WA_EXTENSIONIN-STRUCTURE = 'BAPE_VBAP'.
      WA_EXTENSIONIN-VALUEPART1 = WA_BAPE_VBAP.
      APPEND WA_EXTENSIONIN TO EXTENSIONIN.

      WA_BAPE_VBAPX-POSNR  = WA_DETAIL_SOI-ZSOITEM_SOI.
      WA_BAPE_VBAPX-ZDATE  = 'X'.
      WA_BAPE_VBAPX-ZLINE  = 'X'.
      WA_EXTENSIONIN-STRUCTURE = 'BAPE_VBAPX'.
      WA_EXTENSIONIN-VALUEPART1 = WA_BAPE_VBAPX.
      APPEND WA_EXTENSIONIN TO EXTENSIONIN.

    ENDLOOP.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

    "----Create SO Number Intercompany using BAPI
    IF WA_DETAIL_SOI-ZPOREF_SOI NE ''.
      CLEAR: WA_ITEMS.

      CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
        EXPORTING
          SALES_HEADER_IN     = T_QUOTE_HEADER_IN
        IMPORTING
          SALESDOCUMENT_EX    = V_SO
        TABLES
          RETURN              = IT_RET
          SALES_ITEMS_IN      = TAB_ITEMS
          SALES_PARTNERS      = TAB_QUOTE_PARTNR
          SALES_SCHEDULES_IN  = TAB_ITEMS_SCHED
          SALES_SCHEDULES_INX = TAB_SCHEDULES_INX
          SALES_CONDITIONS_IN = TAB_QUOT_COND
          SALES_CFGS_REF      = TAB_QUOTE_REF
          SALES_CFGS_INST     = TAB_QUOTE_INST
          SALES_CFGS_VALUE    = TAB_QUOTE_VALUE
          SALES_CFGS_REFINST  = TAB_QUOTE_REFINST
          EXTENSIONIN         = EXTENSIONIN.

      WA_SOI-ZSO = V_SO.
      MODIFY ITAB_SOI FROM WA_SOI TRANSPORTING ZSO WHERE ZPOREF_SOI EQ WA_SOI-ZPOREF_SOI.

      READ TABLE IT_RET WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0.
        CLEAR V_MSG.
        V_MSG = IT_RET-MESSAGE.

        PERFORM F_EXIT.
      ELSE.
        IF RB_BG2 EQ 'X' OR RB_PR2 EQ 'X'.
          LOOP AT ITAB_PR2 INTO WA_PR WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR.
            CONCATENATE V_SO WA_PR-ZPRITEM INTO V_OBJNUM SEPARATED BY '-'.
            PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_SUCCESS '' '' '' V_OBJNUM 'SO Intercompany Created' 'Success' ''.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
    PERFORM COMMIT.
*  ENDIF.

    "----Change SO Intercompany----"
    IF LV_STR NE 'B' AND V_SO NE ''.
      PERFORM F_CHANGE_SOI.
    ENDIF.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.
    CLEAR : WA_DETAIL_SOI.
  ENDLOOP.

ENDFORM.                    "F_CREATE_IC

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SOI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CHANGE_SOI.

  CLEAR DYN_COND.

  IF RB_BG2 EQ 'X' OR RB_PR2 EQ 'X'.
    DYN_COND = 'ZPRNO = WA_PR-ZPRNO'.
  ENDIF.
*ENDIF.

  LOOP AT ITAB_CHANGE_SOI INTO WA_CHANGE_SOI WHERE (DYN_COND).

    CLEAR : ZCUOBJ, IT_TEMP, V_KALKS, V_KALVG, V_KARTV, ZZWEIGTHTOT, ZJMLROLL,
            TAB_ITEMS_SCHED,TAB_SCHEDULES_INX, ZWEIGHT, ZORDERQTY, ZSATUAN, ZTOTALM2, ZZCONV.

    REFRESH : IT_TEMP,TAB_CFGS_INST.
    CLEAR   : IT_TEMP.

    SELECT SINGLE VBAP~CUOBJ
                  INTO ZCUOBJ
                  FROM VBAP
                  WHERE VBAP~VBELN = V_SO
                  AND VBAP~POSNR   = WA_CHANGE_SOI-ZSOITEM_SOI.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = ZCUOBJ
      TABLES
        CONFIGURATION       = IT_TEMP
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
    SPLIT IT_TEMP-ATWTB AT SPACE INTO ZZCONV ZSATUAN.
    REPLACE ALL OCCURRENCES OF ',' IN ZZCONV WITH SPACE.

    ZJMLROLL    = WA_CHANGE_SOI-ZPECAHSCH_SOI.
    ZJMLROLL_M2 = WA_CHANGE_SOI-ZROLL_SOI.

    CASE WA_CHANGE_SOI-ZUOM_SOI.
      WHEN 'KG'.
        ZZWEIGTHTOT = ZJMLROLL * ZZCONV.
      WHEN 'ROL'.
        ZZWEIGTHTOT = ZJMLROLL.
      WHEN 'M2'.
        READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTOTALM2'.
        SPLIT IT_TEMP-ATWTB AT SPACE INTO ZTOTALM2 ZSATUAN.
        REPLACE ALL OCCURRENCES OF ',' IN ZTOTALM2 WITH SPACE.
        CALL FUNCTION 'ROUND'
          EXPORTING
            DECIMALS = 3
            INPUT    = ZTOTALM2
            SIGN     = '+'
          IMPORTING
            OUTPUT   = ZWEIGHT.
        ZZWEIGTHTOT = ( ZWEIGHT / ZJMLROLL_M2 ) * ZJMLROLL.
      WHEN 'LB'.
        READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZORDERQTY'.
        SPLIT IT_TEMP-ATWTB AT SPACE INTO ZORDERQTY ZSATUAN.
        ZZWEIGTHTOT = ZORDERQTY * ZJMLROLL.
    ENDCASE.

    PERFORM F_CHANGEDATE USING WA_CHANGE_SOI-ZDLVDATE_SOI CHANGING WA_ITEMS_SCHED-REQ_DATE.

    WA_ITEMS_SCHED-ITM_NUMBER     = WA_CHANGE_SOI-ZSOITEM_SOI.
    WA_ITEMS_SCHED-SCHED_LINE     = WA_CHANGE_SOI-ZSCHLINE_SOI.
    WA_ITEMS_SCHED-REQ_QTY        = ZZWEIGTHTOT.
    WA_ITEMS_SCHED-REQ_DATE       = WA_ITEMS_SCHED-REQ_DATE.
    WA_ITEMS_SCHED-DATE_TYPE      = '1'.
    APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
    CLEAR WA_ITEMS_SCHED.

    WA_SCHEDULES_INX-ITM_NUMBER   = WA_CHANGE_SOI-ZSOITEM_SOI.
    WA_SCHEDULES_INX-SCHED_LINE   = WA_CHANGE_SOI-ZSCHLINE_SOI.
    WA_SCHEDULES_INX-UPDATEFLAG   = 'I'.
    WA_SCHEDULES_INX-REQ_QTY      = 'X'.
    WA_SCHEDULES_INX-REQ_DATE     = 'X'.
    APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
    CLEAR WA_SCHEDULES_INX.

    PERFORM F_COMMIT_SO.
    CLEAR: WA_CHANGE_SO.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  CLEAR  : TAB_ITEMS_SCHED, TAB_SCHEDULES_INX.
  REFRESH: TAB_ITEMS_SCHED, TAB_SCHEDULES_INX.

ENDFORM.                    "F_CHANGE_SOI

*&---------------------------------------------------------------------*
*&      Form  F_SO_CREATED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_SO_CREATED.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_PR. "Validasi PR
  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_PO. "Validasi PO
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_SOI. "Validasi SO IC
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  ITAB_SO2[] = ITAB_SO[].
  DELETE ADJACENT DUPLICATES FROM ITAB_SO2 COMPARING ZGROUP_SO ZSOITEMREF.

  LOOP AT ITAB_SO2 INTO WA_SO2 WHERE ZGROUP_SO EQ WA_SO-ZGROUP_SO.
    CLEAR V_FLAG.

    IF V_FLAG EQ 'X'.
      PERFORM FILL_DISP_ALV2 USING WA_SO2-ZGROUP_SO WA_SO2-ZSOITEM C_ICON_ERROR '' '' '' '' 'PR Already Created' 'Error' ''.
      EXIT.
    ENDIF.

    CLEAR V_OBJNUM.
    CONCATENATE WA_SO2-ZSO '-' WA_SO2-ZSOITEMREF INTO V_OBJNUM.
    PERFORM FILL_DISP_ALV2 USING WA_SO2-ZGROUP_SO WA_SO2-ZSOITEM C_ICON_WARNING V_OBJNUM '' '' '' '' '' ''.

    PERFORM F_CONVERSION_ALPHA_INPUT USING WA_SO2-ZSO CHANGING WA_SO2-ZSO.
    MODIFY ITAB_SO FROM WA_SO2 TRANSPORTING ZSO WHERE ZGROUP_SO EQ WA_SO2-ZGROUP_SO.

    CLEAR R_ETENR. REFRESH R_ETENR.
    SELECT ETENR INTO V_ETENR FROM VBEP WHERE VBELN EQ WA_SO2-ZSO AND POSNR EQ WA_SO2-ZSOITEMREF.
      R_ETENR-OPTION  = 'EQ'.
      R_ETENR-SIGN    = 'I'.
      R_ETENR-LOW     = V_ETENR.
      APPEND R_ETENR.
    ENDSELECT.

    DESCRIBE TABLE R_ETENR LINES V_LINES.

    SELECT SINGLE A~AUART A~VKORG A~VTWEG A~SPART
                  A~BSTNK A~BSTDK B~POSNR B~WERKS
                  B~VSTEL A~KUNNR B~VRKME
                  A~STWAE B~MATNR B~NETPR
                  B~KWMENG C~WMENG
      INTO       (WA_SO2-ZORDTYPE_SO,WA_SO2-ZSLSORG_SO,WA_SO2-ZDISTCHANEL_SO,WA_SO2-ZDIVISION_SO,
                  WA_SO2-ZPO,V_BSTDK,WA_SO2-ZSOITEM,WA_SO2-ZPLANT_SO,
                  WA_SO2-ZSHPPOINT_SO,WA_SO2-ZCUST_SO,WA_SO2-ZUOM_SO,
                  V_STWAE,WA_SO2-ZMATNR,V_NETPR,
                  V_KWMENG,V_QTYSCH)
      FROM VBAK AS A JOIN VBAP AS B ON A~VBELN EQ B~VBELN
                     JOIN VBEP AS C ON B~VBELN EQ C~VBELN
      WHERE B~VBELN EQ WA_SO2-ZSO AND B~POSNR EQ WA_SO2-ZSOITEMREF.

    SELECT SINGLE KUNNR INTO V_SHIPT FROM VBPA WHERE VBELN EQ WA_SO2-ZSO AND PARVW EQ 'WE'.

    WA_SO2-ZSHIPH_SO    = V_SHIPT.
    WA_SO2-ZPODATE_SO   = V_BSTDK.
    WA_SO2-ZPRICE_SO    = V_NETPR.
    REPLACE ALL OCCURRENCES OF '.' IN WA_SO2-ZPRICE_SO WITH ''.
    CONDENSE WA_SO2-ZPRICE_SO.

    WA_SO2-ZCURR_SO     = V_STWAE.
    WA_SO2-ZINOUT_SO    = WA_SO2-ZMATNR+5(1).
    WA_SO2-ZSOITEM      = WA_SO2-ZSOITEMREF.
    SHIFT WA_SO2-ZSOITEM LEFT DELETING LEADING '0'.

    SELECT SINGLE VBAP~CUOBJ
       INTO V_CUOBJ
       FROM VBAP
       WHERE VBAP~VBELN = WA_SO2-ZSO
       AND VBAP~POSNR   = WA_SO2-ZSOITEM.

    CLEAR IT_TEMP. REFRESH IT_TEMP.
    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = V_CUOBJ
      TABLES
        CONFIGURATION       = IT_TEMP
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZTYPE_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTHICKNESS'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZTHICK_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCORE'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZCORE_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZROLL_SO = IT_TEMP-ATWRT.
      REPLACE ALL OCCURRENCES OF 'ROL' IN WA_SO2-ZROLL_SO WITH ''.
      V_QTYROL = V_KWMENG / WA_SO2-ZROLL_SO.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZTYPLBL_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTREATMENT'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZTREAT_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZWIDTH_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZLENGTH_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCRITERIA'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZCRITERIA_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZEXLENGTH'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZEXTLENGTH_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKING'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZPACK_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZORDERUOM'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZUOMPRICE_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKINGCODE'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZKDPACK_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZSPCTOUCH1_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-2'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZSPCTOUCH2_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZSPCTOUCH3_SO = IT_TEMP-ATWRT.
    ENDIF.

    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC EQ 0.
      WA_SO2-ZALIAS_SO = IT_TEMP-ATWRT.
    ENDIF.

    UNASSIGN <FS_SO>.
    LOOP AT ITAB_SO ASSIGNING <FS_SO> WHERE ZSOITEMREF EQ WA_SO2-ZSOITEMREF.
      CLEAR: V_EDATU.

      IF V_INDEX EQ ''.
        V_INDEX = 1.
      ELSE.
        V_INDEX = V_INDEX + 1.
      ENDIF.

      READ TABLE R_ETENR INDEX V_INDEX.
      <FS_SO>-ZSCHLINE_SO = R_ETENR-LOW.

      SELECT SINGLE WMENG EDATU FROM VBEP INTO (V_WMENG,V_EDATU) WHERE
        VBELN EQ <FS_SO>-ZSO AND POSNR EQ <FS_SO>-ZSOITEMREF
        AND ETENR EQ <FS_SO>-ZSCHLINE_SO.

      V_ROLL   = V_WMENG / V_QTYROL.
      <FS_SO>-ZPECAHSCH_SO = V_ROLL.
      CONDENSE <FS_SO>-ZPECAHSCH_SO.

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          INPUT  = V_EDATU
        IMPORTING
          OUTPUT = <FS_SO>-ZDLVDATE_SO.
    ENDLOOP.
    CLEAR V_INDEX.

    MODIFY ITAB_SO FROM WA_SO2 TRANSPORTING ZORDTYPE_SO ZSLSORG_SO ZDISTCHANEL_SO ZDIVISION_SO
                                           ZPO ZPODATE_SO ZSOITEM ZPLANT_SO
                                           ZSHPPOINT_SO ZDLVDATE_SO ZCUST_SO ZSHIPH_SO
                                           ZUOM_SO ZINOUT_SO ZPRICE_SO ZCURR_SO
                                           ZMATNR ZSOITEM ZUOM_SO

                                           ZTYPE_SO ZTHICK_SO ZCORE_SO ZROLL_SO
                                           ZTYPLBL_SO ZTREAT_SO ZWIDTH_SO ZLENGTH_SO
                                           ZCRITERIA_SO ZEXTLENGTH_SO ZPACK_SO ZUOMPRICE_SO
                                           ZKDPACK_SO ZSPCTOUCH1_SO ZSPCTOUCH2_SO ZSPCTOUCH3_SO
                                           ZALIAS_SO
                                 WHERE ZSO EQ WA_SO2-ZSO
                                   AND ZSOITEMREF EQ WA_SO2-ZSOITEMREF
                                   AND ZGROUP_SO EQ WA_SO2-ZGROUP_SO.
  ENDLOOP.

ENDFORM.                    "F_SO_CREATED


*&---------------------------------------------------------------------*
*&      Form  F_PR_CREATED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PR_CREATED.

  DATA: V_MENGE TYPE EBAN-MENGE,
        V_LFDAT TYPE EBAN-LFDAT,
        V_PRNO(10) TYPE N.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_PO. "Validasi PO
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

*  PERFORM F_VALIDATE_SOI. "Validasi SO IC
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  CLEAR: DYN_COND, V_FLAG.

  DYN_COND = 'ZGROUP_PR EQ WA_PR-ZGROUP_PR'.

  LOOP AT ITAB_PR INTO WA_PR WHERE (DYN_COND).

    IF V_FLAG EQ 'X'.
      PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'PO already Created' 'Error' ''.
      EXIT.
    ENDIF.

    CLEAR: V_OBJNUM, V_OBJNUM2.

    CONCATENATE WA_PR-ZPRNO '-' WA_PR-ZPRITEM INTO V_OBJNUM.
    PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_WARNING V_OBJNUM2 V_OBJNUM '' '' '' '' ''.

    CLEAR V_PRNO.
    WA_PR-ZPRNO = V_PRNO = WA_PR-ZPRNO.
    SELECT SINGLE A~BSART A~MENGE A~MEINS A~LFDAT
                  A~WERKS A~EKGRP A~AFNAM A~MATNR
      INTO (WA_PR-ZPRTYPE,V_MENGE,WA_PR-ZUOM_PR,V_LFDAT,
           WA_PR-ZPLANT,WA_PR-ZPGR_PR,WA_PR-ZREQUESTER_PR,WA_PR-ZMATNR)
      FROM EBAN AS A WHERE A~BANFN EQ WA_PR-ZPRNO
       AND A~BNFPO EQ WA_PR-ZPRITEMREF.

    WA_PR-ZQTY_PR     = V_MENGE.
    CONDENSE WA_PR-ZQTY_PR.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = V_LFDAT
      IMPORTING
        DATE_EXTERNAL = WA_PR-ZDLVDATE_PR.

    WA_PR-ZINOUT_PR   = WA_PR-ZMATNR+5(1).
    WA_PR-ZPRITEM     = WA_PR-ZPRITEMREF.

    SELECT SINGLE EBAN~CUOBJ
            INTO ZCUOBJ
            FROM EBAN
            WHERE EBAN~BANFN = WA_PR-ZPRNO
            AND EBAN~BNFPO   = WA_PR-ZPRITEMREF.

    CLEAR IT_TEMP. REFRESH IT_TEMP.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = ZCUOBJ
      TABLES
        CONFIGURATION       = IT_TEMP
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.

    IF SY-SUBRC EQ 0.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZFILMTYPE_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTHICKNESS'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZTHICK_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZEXPLIFE_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCORE'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZCORE_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZWIDTH_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZLENGTH_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTREATMENT'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZTREAT_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZGRADE'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZGRDFILM_PR  = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZROLL_PR = IT_TEMP-ATWRT.
        REPLACE ALL OCCURRENCES OF 'ROL' IN WA_PR-ZROLL_PR WITH ''.
        CONDENSE WA_PR-ZROLL_PR.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLABEL'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZTYPLBL_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZSPCTOUCH1_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-2'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZSPCTOUCH2_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZSPCTOUCH3_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZEXLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZEXTLENGTH_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKINGCODE'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZKDPACK_PR = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKING'.
      IF SY-SUBRC EQ 0.
        WA_PR-ZPACK_PR = IT_TEMP-ATWRT.
      ENDIF.
    ENDIF.

    MODIFY ITAB_PR FROM WA_PR TRANSPORTING ZPRTYPE ZQTY_PR ZUOM_PR ZDLVDATE_PR
                                           ZPLANT  ZPGR_PR ZREQUESTER_PR ZMATNR
                                           ZINOUT_PR ZFILMTYPE_PR ZTHICK_PR ZEXPLIFE_PR
                                           ZCORE_PR ZWIDTH_PR ZLENGTH_PR ZTREAT_PR
                                           ZGRDFILM_PR ZROLL_PR ZTYPLBL_PR ZSPCTOUCH1_PR
                                           ZSPCTOUCH2_PR ZSPCTOUCH3_PR ZEXTLENGTH_PR
                                           ZKDPACK_PR ZPACK_PR ZPRITEM ZPRNO
   WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR
     AND ZPRITEMREF EQ WA_PR-ZPRITEMREF.
  ENDLOOP.

  ITAB_PR2[] = ITAB_PR[].
  SORT ITAB_PR2 BY NGROUP ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ITAB_PR2 COMPARING ZGROUP_PR ZPRITEM.

ENDFORM.                    "F_PR_CREATED

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PROCESS_INPUT.

  CLEAR: V_MAKTX.

  DATA: V_BSART TYPE T161T-BSART,
        V_BATXT TYPE T161T-BATXT,
        V_TYPE TYPE CAWNT-ATWTB.

  PERFORM F_VALIDATE_PR. "Validasi PR
  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_PO. "Validasi PO
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_SOI. "Validasi SO IC
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  ITAB_PR3[] = ITAB_PR[].

  DELETE ADJACENT DUPLICATES FROM ITAB_PR3  COMPARING ZGROUP_PR.
  DELETE ADJACENT DUPLICATES FROM ITAB_PR   COMPARING ZGROUP_PR ZPRITEM.

  CLEAR WA_PR.
  LOOP AT ITAB_PR3 INTO WA_PR2 WHERE ZPRNO IS INITIAL.
    SELECT SINGLE BATXT FROM T161T INTO V_BATXT WHERE SPRAS EQ 'EN' AND BSART EQ WA_PR2-ZPRTYPE.
    IF SY-SUBRC NE 0.
      SELECT SINGLE BSART FROM T161T INTO V_BSART WHERE SPRAS EQ 'EN' AND BATXT EQ WA_PR2-ZPRTYPE.
      WA_PR2-ZPRTYPE = V_BSART.
    ENDIF.

    WA_PRHEADER-PR_TYPE   = WA_PR2-ZPRTYPE.
    APPEND WA_PRHEADER TO IT_PRHEADER.

    WA_PRHEADERX-PR_TYPE    = 'X'.
    WA_PRHEADERX-ITEM_INTVL = 'X'.
    APPEND WA_PRHEADERX TO IT_PRHEADERX.

    LOOP AT ITAB_PR INTO WA_PR WHERE ZGROUP_PR EQ WA_PR2-ZGROUP_PR.
*      V_ZCODE     = WA_PR-ZFILMTYPE_PR.
      V_ZLENGHT   = WA_PR-ZLENGTH_PR.
      V_ZWIDTH    = WA_PR-ZWIDTH_PR.
      V_ZROLL     = WA_PR-ZROLL_PR.

*      Added by Dila <10.06.2025> karena ketika ZCODE menggunakan filmtype data yang diambil lebih dari 1
      CONCATENATE WA_PR-ZFILMTYPE_PR '-' WA_PR-ZTHICK_PR INTO V_TYPE.

      SELECT SINGLE ATWRT INTO V_ZCODE
        FROM CAWNT
        JOIN CAWN ON CAWNT~ATINN = CAWN~ATINN AND CAWNT~ATZHL = CAWN~ATZHL
        WHERE CAWNT~ATWTB = V_TYPE.
*      End Added

      SELECT SINGLE VALC INTO V_ZCODE2 FROM CUVTAB_VALC WHERE VALC EQ V_ZCODE.

      IF SY-SUBRC EQ 0.
        " If characteristic config found, this item is for Char. Value = Slitt Roll
        PERFORM F_READ_CHAR USING V_ZCODE CHANGING V_ZQTY V_ZLENGHT V_ZWIDTH V_ZROLL V_EXPLIV.

        WA_PR-ZQTY_PR = V_ZQTY.

        CONCATENATE WA_PR-ZFILMTYPE_PR '-' WA_PR-ZTHICK_PR INTO V_ATWTB.
        SELECT CAWN~ATWRT
          INTO V_ATWTB
          FROM CAWN JOIN CAWNT ON CAWN~ATINN = CAWNT~ATINN AND CAWN~ATZHL = CAWNT~ATZHL
          WHERE CAWN~ATINN EQ '0000000811' AND CAWNT~ATWTB = V_ATWTB.
        ENDSELECT.

        IF SY-SUBRC NE 0.
          PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Material Tidak Ditemukan' 'Error' ''.
          V_FLAG = 'X'.
        ENDIF.

        IF V_FLAG EQ 'X'.
          EXIT.
        ENDIF.

        " Generate material number
        IF WA_PR-ZINOUT_PR EQ 'I'.
          CONCATENATE 'SR' V_ATWTB 'I' INTO V_MATNR.
          CONDENSE V_MATNR NO-GAPS.
        ELSEIF WA_PR-ZINOUT_PR EQ 'X'.
          CONCATENATE 'SR' V_ATWTB 'X' INTO V_MATNR.
          CONDENSE V_MATNR NO-GAPS.
        ELSEIF WA_PR-ZINOUT_PR EQ ''.
          V_MATNR = WA_DETAIL_SO-ZTYPE_SO.
          CONDENSE V_MATNR NO-GAPS.
        ELSEIF WA_PR-ZINOUT_PR EQ 'O'.
          CONCATENATE 'SR' V_ATWTB 'O' INTO V_MATNR.
          CONDENSE V_MATNR NO-GAPS.
        ENDIF.

        " Check if material is on MatGroup OSC
        CLEAR : V_MATKL.
        SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR = V_MATNR AND MATKL IN ('300020','300021','300022','300023').

        IF SY-SUBRC NE 0.
          PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Material bukan dari Material Group OSC' 'Error' ''.
          V_FLAG = 'X'.
        ENDIF.

        IF V_FLAG EQ 'X'.
          EXIT.
        ENDIF.

        WA_PR-ZMATNR       = V_MATNR.
        WA_PR-ZEXPLIFE_PR  = V_EXPLIV.

        MODIFY ITAB_PR FROM WA_PR TRANSPORTING ZMATNR ZPRTYPE ZQTY_PR ZEXPLIFE_PR ZTHICK_PR
                                         WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR
                                           AND ZPRITEM EQ WA_PR-ZPRITEM.
      ELSE.
        " If characteristic config not found, this item is for Char. Value = Other Material (not FGS)
        CLEAR : V_MATKL, V_MATNR.

        V_MATNR = WA_PR-ZFILMTYPE_PR.
        " Check if material is on MatGroup OSC
        SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR = V_MATNR AND MATKL IN ('230007','230008').

        IF SY-SUBRC NE 0.
          PERFORM FILL_DISP_ALV2 USING WA_PR-ZGROUP_PR WA_PR-ZPRITEM C_ICON_ERROR '' '' '' '' 'Material bukan dari Material Group OSC' 'Error' ''.
          V_FLAG = 'X'.
        ENDIF.

        IF V_FLAG EQ 'X'.
          EXIT.
        ENDIF.

        WA_PR-ZMATNR  = V_MATNR.
        WA_PR-ZQTY_PR = WA_PR-ZQTYRM_PR.
        MODIFY ITAB_PR FROM WA_PR TRANSPORTING ZMATNR ZQTY_PR
                                         WHERE ZGROUP_PR EQ WA_PR-ZGROUP_PR
                                           AND ZPRITEM EQ WA_PR-ZPRITEM.
      ENDIF.



      WA_PRITEM-PREQ_ITEM   = WA_PR-ZPRITEM.
      WA_PRITEM-PUR_GROUP   = WA_PR-ZPGR_PR.
      WA_PRITEM-MATERIAL    = WA_PR-ZMATNR.
      WA_PRITEM-PLANT       = WA_PR-ZPLANT.
      WA_PRITEM-QUANTITY    = WA_PR-ZQTY_PR.
      WA_PRITEM-PREQ_NAME   = WA_PR-ZREQUESTER_PR.

      CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
        EXPORTING
          INPUT  = WA_PR-ZDLVDATE_PR
        IMPORTING
          OUTPUT = V_EINDT.

      WA_PRITEM-DELIV_DATE = V_EINDT.
      APPEND WA_PRITEM TO IT_PRITEM.
    ENDLOOP.

    IF V_FLAG EQ 'X'.
      EXIT.
    ENDIF.

    IF V_MAKTX IS INITIAL.
      REPLACE ALL OCCURRENCES OF '.0' IN WA_PR-ZTHICK_PR WITH ''.
      CONCATENATE WA_PR-ZFILMTYPE_PR '-' WA_PR-ZTHICK_PR INTO V_MAKTX.
    ENDIF.

    SELECT SINGLE MAKTX FROM MAKT INTO V_MAKTX WHERE MATNR EQ V_MATNR.
    PERFORM CREATE_PR.

    IF V_FLAG NE 'X'.
      PERFORM F_PROCESS_PO.
      IF V_FLAG NE 'X'.
*        PERFORM F_PROCESS_SO_IC.
      ELSE.
        PERFORM F_EXIT.
      ENDIF.
    ELSE.
      PERFORM F_EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "F_PROCESS_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PO_CREATED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PO_CREATED.
  DATA: V_NETPR TYPE EKPO-NETPR,
        V_WAERS TYPE EKKO-WAERS,
        V_QTY   TYPE EKPO-MENGE,
        V_UNIT  TYPE EKPO-MEINS,
        V_EINDT TYPE EKET-EINDT.

  IF V_FLAG EQ 'X'.
    EXIT.
  ENDIF.

  PERFORM F_VALIDATE_PO. "Validasi PO
  IF V_FLAG = 'X'.
    PERFORM F_EXIT.
    EXIT.
  ENDIF.

  CLEAR: DYN_COND.

  DYN_COND = 'ZGROUP_PO EQ WA_PR-ZGROUP_PR'.

  LOOP AT ITAB_PO INTO WA_PO WHERE (DYN_COND).
    CLEAR: V_PONUM, V_NETPR, V_WAERS, V_QTY, V_EINDT, V_FLAG.

*    IF RB1 EQ 'X'.
*      PERFORM F_VALIDASI_STATUS USING WA_SO-ZSOCUST WA_PO-ZPO_NUMBER WA_PO-ZPOITEM 'SO'.
*    ENDIF.

    IF V_FLAG EQ 'X'.
      PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_ERROR '' '' '' '' 'SO IC already created' 'Error' ''.
      EXIT.
    ENDIF.

    CLEAR: V_OBJNUM,V_OBJNUM2,V_NUMBER.

*    IF RB1 EQ 'X' AND RB_PO EQ 'X'.
*      CONCATENATE WA_SO-ZSOCUST '-' WA_PO-ZPOITEM INTO V_OBJNUM2.
*      SELECT SINGLE BANFN INTO V_NUMBER FROM EKPO WHERE EBELN EQ WA_PO-ZPO_NUMBER AND BNFPO EQ WA_PO-ZPOITEM.
*      CONCATENATE V_NUMBER '-' WA_PO-ZPOITEM INTO V_OBJNUM3.
*    ELSEIF RB2 EQ 'X' AND RB_PO2 EQ 'X'.
    SELECT SINGLE BANFN INTO V_NUMBER FROM EKPO WHERE EBELN EQ WA_PO-ZPO_NUMBER AND BNFPO EQ WA_PO-ZPOITEM.
    CONCATENATE V_NUMBER '-' WA_PO-ZPOITEM INTO V_OBJNUM3.
*    ENDIF.

    CONCATENATE WA_PO-ZPO_NUMBER '-' WA_PO-ZPOITEM INTO V_OBJNUM.
    PERFORM FILL_DISP_ALV2 USING WA_PO-ZGROUP_PO WA_PO-ZPOITEM C_ICON_WARNING V_OBJNUM2 V_OBJNUM3 V_OBJNUM '' '' '' ''.


    V_PONUM = WA_PO-ZPO_NUMBER.
    SELECT SINGLE A~BSART A~LIFNR A~EKORG A~EKGRP
                  A~BUKRS B~EBELP B~MENGE B~MEINS
                  C~EINDT B~WERKS B~NETPR A~WAERS
                  B~MWSKZ A~VERKF B~GEWEI
            INTO (WA_PO-ZPOTYPE, WA_PO-ZVENDOR, WA_PO-ZEKORG, WA_PO-ZPGR_PO,
                  WA_PO-ZCOMPCODE, WA_PO-ZPOITEM, V_QTY, V_UNIT,
                  V_EINDT, WA_PO-ZPLANT_PO, V_NETPR, V_WAERS,
                  WA_PO-ZMWSKZ, WA_PO-ZSLSPERSON, WA_PO-ZUOM_PO)
      FROM EKKO AS A JOIN EKPO AS B ON A~EBELN EQ B~EBELN
                     JOIN EKET AS C ON B~EBELN EQ C~EBELN AND B~EBELP EQ C~EBELP
      WHERE A~EBELN EQ WA_PO-ZPO_NUMBER
        AND B~EBELP EQ WA_PO-ZPOITEM.

    IF V_WAERS EQ 'IDR'.
      V_NETPR = V_NETPR * 100.
    ENDIF.

*    WA_PO-ZNETPR      = V_NETPR. CONDENSE WA_PO-ZNETPR.
*    WA_PO-ZCURR_PO    = V_WAERS.
    WA_PO-ZPOQTY      = V_QTY.   CONDENSE WA_PO-ZPOQTY.
    WA_PO-ZDLVDATE_PO = V_EINDT.


    SELECT SINGLE CUOBJ FROM EKPO INTO V_CUOBJ WHERE EBELN EQ WA_PO-ZPO_NUMBER AND EBELP EQ WA_PO-ZPOITEM.

    CLEAR IT_TEMP. REFRESH IT_TEMP.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = V_CUOBJ
      TABLES
        CONFIGURATION       = IT_TEMP
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.

    IF SY-SUBRC EQ 0.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTYPEFILM_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTHICKNESS'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTHICK_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZEXPLIFE_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCORE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZCORE_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZWIDTH_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZLENGTH_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTREATMENT'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTREAT_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZGRADE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZGRDFILM_PO  = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZROLL_PO = IT_TEMP-ATWRT.
        REPLACE ALL OCCURRENCES OF 'ROL' IN WA_PO-ZROLL_PO WITH ''.
        CONDENSE WA_PO-ZROLL_PO.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLABEL'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZTYPLBL_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH1_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-2'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH2_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZSPCTOUCH3_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZEXLENGTH'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZEXTLENGTH_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKINGCODE'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZKDPACK_PO = IT_TEMP-ATWRT.
      ENDIF.

      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPACKING'.
      IF SY-SUBRC EQ 0.
        WA_PO-ZPACK_PO = IT_TEMP-ATWRT.
      ENDIF.
    ENDIF.

    SHIFT WA_PO-ZPOITEM LEFT DELETING LEADING '0'.
    MODIFY ITAB_PO FROM WA_PO TRANSPORTING ZPOTYPE ZVENDOR ZEKORG ZPGR_PO
*                                           ZCOMPCODE ZPOITEM ZPOQTY ZUOM_PO ZCURR_PO
*                                           ZDLVDATE_PO ZPLANT_PO ZNETPR
                                           ZCOMPCODE ZPOITEM ZPOQTY ZUOM_PO
                                           ZDLVDATE_PO ZPLANT_PO
                                           ZMWSKZ ZSLSPERSON ZTYPEFILM_PO
                                           ZTHICK_PO ZEXPLIFE_PO ZCORE_PO
                                           ZWIDTH_PO ZLENGTH_PO ZTREAT_PO
                                           ZGRDFILM_PO ZROLL_PO ZTYPLBL_PO
                                           ZSPCTOUCH1_PO ZSPCTOUCH2_PO ZSPCTOUCH3_PO
                                           ZEXTLENGTH_PO ZKDPACK_PO ZPACK_PO
                                           WHERE ZPO_NUMBER EQ WA_PO-ZPO_NUMBER
                                             AND ZPOITEM EQ WA_PO-ZPOITEM.
  ENDLOOP.

  ITAB_PO2[] = ITAB_PO[].
  SORT ITAB_PO2 BY NGROUP ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ITAB_PO2 COMPARING ZGROUP_PO ZPOITEM.

ENDFORM.                    "F_PO_CREATED

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ORDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_ADD_ORDATA USING V_SONUM
                        V_NOMOR
                        V_ITEM
                        V_KET.

  V_SONUM = V_SONUM1 = V_SONUM.
  REFRESH : IT_BAPISDH1X, IT_RET, TAB_ITEMS, TAB_ITEMSX.

  IT_BAPISDH1X-UPDATEFLAG = 'U'.
  COLLECT IT_BAPISDH1X.

  WA_ITEM-ITM_NUMBER = V_ITEM.
  CONCATENATE V_KET V_NOMOR INTO WA_ITEM-REF_1_S.
  APPEND WA_ITEM TO TAB_ITEMS.

  WA_ITEMX-ITM_NUMBER = V_ITEM.
  WA_ITEMX-REF_1_S    = 'X'.
  WA_ITEMX-UPDATEFLAG = 'X'.
  APPEND WA_ITEMX TO TAB_ITEMSX.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      SALESDOCUMENT    = V_SONUM
      ORDER_HEADER_INX = IT_BAPISDH1X
    TABLES
      RETURN           = IT_RET
      ORDER_ITEM_IN    = TAB_ITEMS
      ORDER_ITEM_INX   = TAB_ITEMSX.

  READ TABLE IT_RET WITH KEY MESSAGE = 'E'.
  IF SY-SUBRC EQ 0.
  ELSE.
    PERFORM COMMIT.

  ENDIF.

  REFRESH : IT_BAPISDH1X, IT_RET, TAB_ITEMS, TAB_ITEMSX.
  CLEAR   : WA_ITEM, WA_ITEMX, IT_BAPISDH1X, IT_RET, TAB_ITEMS, TAB_ITEMSX.

ENDFORM.                    "F_ADD_ORDATA

*&---------------------------------------------------------------------*
*&      Form  F_FILL_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CONFIG     text
*      -->CHAR       text
*      -->VALUE      text
*----------------------------------------------------------------------*
FORM F_FILL_CHAR USING CONFIG TYPE BAPICUVAL-CONFIG_ID
                       CHAR TYPE   BAPICUVAL-CHARC
                       VALUE TYPE  TY_ITAB-ZSPCTOUCH1_SO.
  WA_QUOTE_VALUE-CONFIG_ID = CONFIG.
  WA_QUOTE_VALUE-INST_ID   = '00000001'.
  WA_QUOTE_VALUE-CHARC     = CHAR.
  WA_QUOTE_VALUE-VALUE     = VALUE.
  APPEND WA_QUOTE_VALUE TO TAB_QUOTE_VALUE.
  CLEAR WA_QUOTE_VALUE.
ENDFORM.                    "F_FILL_CHAR

*&---------------------------------------------------------------------*
*&      Form  CHANGEDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM F_CHANGEDATE USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_SDATE_INPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "CHANGEDATE

*&---------------------------------------------------------------------*
*&      Form  fill_disp_alv2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GROUP      text
*      -->SOCUST     text
*      -->PRNUM      text
*      -->PONUM      text
*      -->SOIC       text
*----------------------------------------------------------------------*
FORM FILL_DISP_ALV2 USING GROUP  TYPE TY_DISP-GROUP
                          ITEM   TYPE TY_DISP-ITEM
                          ICON   TYPE TY_DISP-ICON
                          SOCUST TYPE TY_DISP-SOCUST
                          PRNUM  TYPE TY_DISP-PRNUM
                          PONUM  TYPE TY_DISP-PONUM
                          SOIC   TYPE TY_DISP-SOIC
                          MSG    TYPE TY_DISP-MSG
                          MSG2   TYPE TY_DISP-MSG
                          MSG3   TYPE TY_DISP-MSG.

  DATA: V_FIELD TYPE STRING,
        V_KET1  TYPE STRING,
        V_KET2  TYPE STRING,
        V_OBJNUM TYPE STRING,
        V_CONDT TYPE STRING,
        V_GRITEM(11).

  CLEAR: V_FIELD, V_GRITEM, V_CONDT.

  SHIFT ITEM LEFT DELETING LEADING '0'.
  CONCATENATE GROUP ITEM INTO V_GRITEM.

  IF SOCUST NE ''.
    V_FIELD = 'SOCUST'.
    SPLIT SOCUST AT '-' INTO V_KET1 V_KET2.
    SHIFT V_KET1 LEFT DELETING LEADING '0'. SHIFT V_KET2 LEFT DELETING LEADING '0'.
    CONCATENATE V_KET1 '-' V_KET2 INTO SOCUST.
  ENDIF.

  IF PRNUM NE ''.
    V_FIELD = 'PRNUM'.
    SPLIT PRNUM AT '-' INTO V_KET1 V_KET2.
    SHIFT V_KET1 LEFT DELETING LEADING '0'. SHIFT V_KET2 LEFT DELETING LEADING '0'.
    CONCATENATE V_KET1 '-' V_KET2 INTO PRNUM.
  ENDIF.

  IF PONUM NE ''.
    V_FIELD = 'PONUM'.
    SPLIT PONUM AT '-' INTO V_KET1 V_KET2.
    SHIFT V_KET1 LEFT DELETING LEADING '0'. SHIFT V_KET2 LEFT DELETING LEADING '0'.
    CONCATENATE V_KET1 '-' V_KET2 INTO PONUM.
  ENDIF.

  IF SOIC NE ''.
    V_FIELD = 'SOIC'.
    SPLIT SOIC AT '-' INTO V_KET1 V_KET2.
    SHIFT V_KET1 LEFT DELETING LEADING '0'. SHIFT V_KET2 LEFT DELETING LEADING '0'.
    CONCATENATE V_KET1 '-' V_KET2 INTO SOIC.
  ENDIF.

  CLEAR: V_KET1, V_KET2.

  IF IT_DISP[] IS INITIAL.
    WA_DISP-GROUP   = GROUP.
    WA_DISP-ITEM    = ITEM.
    WA_DISP-ICON    = ICON.
    WA_DISP-SOCUST  = SOCUST.
    WA_DISP-PRNUM   = PRNUM.
    WA_DISP-PONUM   = PONUM.
    WA_DISP-SOIC    = SOIC.
    WA_DISP-MSG     = MSG.
    WA_DISP-GRITEM  = V_GRITEM.
    APPEND WA_DISP TO IT_DISP.
  ELSE.
    READ TABLE IT_DISP INTO WA_DISP WITH KEY GROUP  = GROUP ITEM = ITEM.
    IF SY-SUBRC EQ 0.
      IF WA_DISP-ITEM EQ ITEM.

        IF MSG2 EQ 'Error'.
          READ TABLE IT_DISP ASSIGNING <FS_DISP> WITH KEY GRITEM = V_GRITEM.
          <FS_DISP>-ICON = C_ICON_WARNING.
          MSG2 = 'Warning'.
          WA_DISP-ICON = C_ICON_WARNING.
        ELSEIF MSG2 EQ 'Success'.
          READ TABLE IT_DISP ASSIGNING <FS_DISP> WITH KEY GRITEM = V_GRITEM.
          <FS_DISP>-ICON = C_ICON_SUCCESS.
          MSG2 = 'Success'.
          WA_DISP-ICON = C_ICON_SUCCESS.
        ELSEIF MSG2 EQ ''.
          EXIT.
        ENDIF.

        WA_DISP-SOCUST  = SOCUST.
        WA_DISP-PRNUM   = PRNUM.
        WA_DISP-PONUM   = PONUM.
        WA_DISP-SOIC    = SOIC.

        IF WA_DISP-MSG CA '.'.
          SPLIT WA_DISP-MSG AT '.' INTO V_KET1 V_KET2.
          CONCATENATE MSG2 '.' V_KET2 ',' MSG INTO WA_DISP-MSG.
        ELSE.
          IF WA_DISP-MSG EQ ''.
            CONCATENATE MSG2 '.' MSG INTO WA_DISP-MSG.
          ELSE.
            CONCATENATE MSG2 '.' WA_DISP-MSG ',' MSG INTO WA_DISP-MSG.
          ENDIF.
        ENDIF.

        IF MSG3 NE ''.
          CONCATENATE WA_DISP-MSG '(' V_MSG ')' INTO WA_DISP-MSG.
        ENDIF.

        IF MSG2 EQ 'Warning'.
          V_CONDT = 'GROUP EQ GROUP'.
        ELSE.
          V_CONDT = 'GROUP EQ GROUP AND ITEM EQ ITEM'.
        ENDIF.

        MODIFY IT_DISP FROM WA_DISP TRANSPORTING ICON (V_FIELD) MSG WHERE (V_CONDT). "GROUP EQ GROUP AND ITEM EQ ITEM.
      ELSE.
        WA_DISP-GROUP   = GROUP.
        WA_DISP-ITEM    = ITEM.
        WA_DISP-ICON    = ICON.
        WA_DISP-SOCUST  = SOCUST.
        WA_DISP-PRNUM   = PRNUM.
        WA_DISP-PONUM   = PONUM.
        WA_DISP-SOIC    = SOIC.
        WA_DISP-MSG     = MSG.
        WA_DISP-GRITEM  = V_GRITEM.
        APPEND WA_DISP TO IT_DISP.
      ENDIF.
    ELSE.
      WA_DISP-GROUP   = GROUP.
      WA_DISP-ITEM    = ITEM.
      WA_DISP-ICON    = ICON.
      WA_DISP-SOCUST  = SOCUST.
      WA_DISP-PRNUM   = PRNUM.
      WA_DISP-PONUM   = PONUM.
      WA_DISP-SOIC    = SOIC.
      WA_DISP-MSG     = MSG.
      WA_DISP-GRITEM  = V_GRITEM.
      APPEND WA_DISP TO IT_DISP.
    ENDIF.
  ENDIF.

ENDFORM.                    "fill_disp_alv2
*&---------------------------------------------------------------------*
*&      Form  FILL_DISP_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GROUP      text
*      -->VBELN      text
*      -->POSNR      text
*      -->WERKS      text
*      -->ICON       text
*      -->TRANS      text
*      -->OBJ        text
*      -->MSG        text
*----------------------------------------------------------------------*
FORM FILL_DISP_ALV USING GROUP TYPE TY_HEADER-GROUP
                         VBELN TYPE TY_HEADER-VBELN
                         POSNR TYPE TY_ITAB-ZSOITEM
                         WERKS TYPE TY_ITAB-ZPLANT_SO
                         ICON  TYPE TY_ITEMS-ICON
                         TRANS TYPE TY_ITEMS-TRANS
                         OBJ   TYPE TY_ITEMS-OBJ_NUM
                         MSG   TYPE TY_ITEMS-MESSAGE.

  WA_HEADER-GROUP  = GROUP.
  WA_HEADER-VBELN  = VBELN.
  WA_HEADER-POSNR  = POSNR.
  WA_HEADER-WERKS  = WERKS.

  SHIFT WA_HEADER-VBELN LEFT DELETING LEADING '0'.
  SHIFT WA_HEADER-POSNR LEFT DELETING LEADING '0'.

  APPEND WA_HEADER TO IT_HEADER.

  WA_ITEMS-GROUP   = GROUP.
  WA_ITEMS-ICON    = ICON.
  WA_ITEMS-VBELN   = VBELN.
  WA_ITEMS-POSNR   = POSNR.
  WA_ITEMS-TRANS   = TRANS.
  WA_ITEMS-OBJ_NUM = OBJ.
  WA_ITEMS-MESSAGE = MSG.

  SHIFT WA_ITEMS-OBJ_NUM LEFT DELETING LEADING '0'.
  SHIFT WA_ITEMS-VBELN   LEFT DELETING LEADING '0'.
  SHIFT WA_ITEMS-POSNR   LEFT DELETING LEADING '0'.

  APPEND WA_ITEMS TO IT_ITEMS.

  SORT IT_HEADER.
  DELETE ADJACENT DUPLICATES FROM IT_HEADER COMPARING GROUP VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM IT_ITEMS COMPARING GROUP VBELN POSNR TRANS OBJ_NUM.
ENDFORM.                    "FILL_DISP_ALV

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_DISP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_DISP.
  REFRESH: T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON  USING 'IT_DISP':
   'ICON'     '' ''  '' '10'   'Status'                '' '' '' '' '',
   'GROUP'    '' ''  '' '10'   'Group'                 '' '' '' '' '',
   'ITEM'     '' ''  '' '10'   'Item'                  '' '' '' '' '',
   'PRNUM'    '' ''  '' '15'   'Purch.Req'             '' 'X' '' '' '',
   'PONUM'    '' ''  '' '15'   'Purch.Order'           '' 'X' '' '' '',
   'MSG'      '' ''  '' '50'   'Message'               '' '' '' '' ''.

ENDFORM.                    "F_FIELD_DISP

*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT_DISP.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-INFO_FIELDNAME    = 'COLOR'.
  WA_LAYOUT-COLTAB_FIELDNAME  = 'CELLCOLOR'.
ENDFORM.                    "f_layout

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DISP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DISP.

  V_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = V_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS2'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
    TABLES
      T_OUTTAB                 = IT_DISP
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_LIST_DISP

*&---------------------------------------------------------------------*
*&      Form  DISP_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISP_ALV.
  V_INDC = 'X'.
  IF V_FLAG EQ 'X'.
    PERFORM F_ERROR_DISP.
  ENDIF.
  PERFORM F_FIELD_DISP.
  PERFORM F_LAYOUT_DISP.
  PERFORM F_LIST_DISP.

ENDFORM.                    "DISP_ALV

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS2 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZPF_STATUS_ALVH'.
ENDFORM.                    "SET_PF_STATUS_500

*&---------------------------------------------------------------------*
*&      Form  F_READ_BDC_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_READ_BDC_MSG.
  DATA:  BDC_MSG(135) TYPE C.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = BDC_MSG.

  CLEAR IT_RET. REFRESH IT_RET.
  IT_RET-TYPE    = MESSTAB-MSGTYP.
  IT_RET-MESSAGE = BDC_MSG.

ENDFORM.                    "F_READ_BDC_MSG

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PARAM      text
*      -->RETURN     text
*----------------------------------------------------------------------*
FORM F_CONVERSION_ALPHA_INPUT USING PARAM CHANGING RETURN.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PARAM
    IMPORTING
      OUTPUT = RETURN.

ENDFORM.                    "CONVERSION_ALPHA_INPUT

*&---------------------------------------------------------------------*
*&      Form  COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
  COMMIT WORK AND WAIT.
ENDFORM.                    "COMMIT

*&---------------------------------------------------------------------*
*&      Form  F_READ_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_CODE     text
*      -->V_QTY      text
*      -->V_LENGHT   text
*      -->V_WIDTH    text
*      -->V_ROLL     text
*      -->V_THICK2   text
*      -->V_EXPLIV2  text
*----------------------------------------------------------------------*
FORM F_READ_CHAR USING V_CODE  TYPE CUVTAB_VALC-VALC
          CHANGING V_QTY       TYPE AUSP-ATWRT
                   V_LENGHT    TYPE AUSP-ATWRT
                   V_WIDTH     TYPE AUSP-ATWRT
                   V_ROLL      TYPE AUSP-ATWRT
                   V_EXPLIV2   TYPE AUSP-ATWRT.

  DATA: V_THICK TYPE P DECIMALS 1,
        V_DENSI TYPE P DECIMALS 2,
        V_GRAM  TYPE P DECIMALS 2,
        V_EXPLIV TYPE P DECIMALS 0,
        V_KG TYPE F,
        V_KG1 TYPE P DECIMALS 2,
        V_ROUND TYPE P DECIMALS 2.

  V_THICK = WA_PR-ZTHICK_PR.
  SELECT  VTINT SLNID ATINN INTO TABLE ICHAR FROM CUVTAB_VALC WHERE VALC EQ V_CODE.

  " If characteristic config not found, stop.
  " Usually process stopped because Char. Value = Material
  IF SY-SUBRC NE 0.
    CLEAR: V_QTY, V_LENGHT, V_WIDTH, V_ROLL, V_EXPLIV2.
    EXIT.
  ENDIF.

  SELECT A~VTINT A~SLNID A~ATINN A~VAL_FROM B~ATNAM INTO TABLE ICHAR
    FROM CUVTAB_VALN AS A LEFT JOIN CABN AS B ON A~ATINN = B~ATINN
    FOR ALL ENTRIES IN ICHAR
   WHERE VTINT = ICHAR-VTINT AND
         SLNID = ICHAR-SLNID.

  LOOP AT ICHAR.
    CASE ICHAR-ATNAM.
      WHEN 'ZZDENSITY'.
        V_DENSI = ICHAR-VAL_FROM.
      WHEN 'ZZGRAMMAGE'.
        V_GRAM = ICHAR-VAL_FROM.
      WHEN 'ZZEXPIREDLIVE'.
        V_EXPLIV =   ICHAR-VAL_FROM.
        V_EXPLIV2 = V_EXPLIV.
        CONDENSE V_EXPLIV2.
    ENDCASE.
  ENDLOOP.

*  V_KG = ( V_LENGHT * V_WIDTH * V_THICK * V_DENSI ) / 1000000.
  V_KG = ( V_LENGHT * V_WIDTH * V_GRAM ) / 1000000.
  CALL FUNCTION 'Z_MMUR_ROUND_FOR_FRACT5'
    EXPORTING
      I_VALUE        = V_KG
      I_DECIMALS     = '2'
    IMPORTING
      O_VALUE        = V_ROUND
    EXCEPTIONS
      INPUT_INVALID  = 1
      OUTPUT_INVALID = 2
      OVERFLOWS      = 3
      OTHERS         = 4.

  V_KG1   = V_ROUND.
  V_ROUND = V_ROUND * V_ROLL.
  V_QTY   = V_ROUND.
  CONDENSE V_QTY.
ENDFORM.                    "F_READ_CHAR

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_EXIT.
  V_FLAG = 'X'.
  EXIT.
ENDFORM.                    "F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_DISP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_ERROR_DISP.
  DATA: V_COUNT(5) TYPE I,
        V_COUNT1(5) TYPE I.

  CLEAR WA_DISP.

  IF RB_BG2 EQ 'X'.
    V_MSG = 'Error.PR Not Created, PO Not Created Not Created'.
  ELSEIF RB_PR2 EQ 'X'.
    V_MSG = 'Error.PO Not Created Not Created'.
  ENDIF.

  IT_DISP2[] = IT_DISP[].
  SORT IT_DISP2 DESCENDING.
  READ TABLE IT_DISP2 INTO WA_DISP INDEX 1.


  SORT ITAB_PR BY NGROUP DESCENDING.
  READ TABLE ITAB_PR INTO WA_PR INDEX 1.

  IF WA_DISP-GROUP EQ WA_PR-ZGROUP_PR.
    EXIT.
  ENDIF.

  DO WA_DISP-GROUP TIMES.
    IF V_COUNT EQ ''.
      V_COUNT = WA_DISP-GROUP.
    ELSE.
      V_COUNT = WA_DISP2-GROUP.
    ENDIF.
    V_COUNT1 = V_COUNT + 1.

    IF V_COUNT1 LE WA_PR-ZGROUP_PR.
      WA_DISP2-GROUP   = V_COUNT1. CONDENSE WA_DISP-GROUP.
      WA_DISP2-ICON    = C_ICON_ERROR.
      WA_DISP2-MSG     = V_MSG.
      APPEND WA_DISP2 TO IT_DISP.
    ENDIF.
  ENDDO.
ENDFORM.                    "F_ERROR_DISP


*&---------------------------------------------------------------------*
*&      Form  F_CLICK_TCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_SELFIELD  text
*----------------------------------------------------------------------*
FORM F_CLICK_TCODE USING FU_SELFIELD TYPE SLIS_SELFIELD.

  CLEAR   : BDCDATA, V_TCODE, V_PARAMID, V_VALUE.
  REFRESH : BDCDATA.

  IF FU_SELFIELD-TABNAME EQ 'IT_DISP'.
    READ TABLE IT_DISP INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_DISP>.
    IF FU_SELFIELD-FIELDNAME EQ 'SOCUST'.
      V_TCODE     = 'VA03'.
      V_PARAMID   = 'AUN'.
      V_VALUE     = <FS_DISP>-SOCUST.
    ELSEIF FU_SELFIELD-FIELDNAME EQ 'PRNUM'.
      V_TCODE   = 'ME53N'.
      V_PARAMID = 'BAN'.
      V_VALUE     = <FS_DISP>-PRNUM.
    ELSEIF FU_SELFIELD-FIELDNAME EQ 'PONUM'.
      V_TCODE   = 'ME23N'.
      V_PARAMID = 'BES'.
      V_VALUE     = <FS_DISP>-PONUM.
    ELSEIF FU_SELFIELD-FIELDNAME EQ 'SOIC'.
      V_TCODE     = 'VA03'.
      V_PARAMID   = 'AUN'.
      V_VALUE     = <FS_DISP>-SOIC.
    ENDIF.
  ENDIF.

  IF V_VALUE EQ ''.
    EXIT.
  ENDIF.

  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
      TCODE  = V_TCODE
    EXCEPTIONS
      OK     = 1
      NOT_OK = 2
      OTHERS = 3.
  IF SY-SUBRC > 1.
    MESSAGE I063(VO) WITH V_TCODE.
  ELSE.
    SPLIT V_VALUE AT '-' INTO V_NUMBER V_ITEM.
    SET PARAMETER ID V_PARAMID FIELD V_NUMBER.
    CALL TRANSACTION V_TCODE AND SKIP FIRST SCREEN.

  ENDIF.
ENDFORM.                    "CLICK_TCODE