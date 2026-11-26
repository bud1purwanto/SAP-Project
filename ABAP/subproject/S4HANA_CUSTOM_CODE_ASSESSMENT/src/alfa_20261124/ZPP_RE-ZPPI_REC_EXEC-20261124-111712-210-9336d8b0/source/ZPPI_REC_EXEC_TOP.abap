*----------------------------------------------------------------------*
* Include ZPPI_REC_EXEC_TOP
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Include table, variable, data &
*                    selection screen definition
* Application Area - PP
* ABAPer           - Anthony W
* Date             - Sept 17, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*----------------------------------------------------------------------*
PROGRAM  ZPPI_REC_EXEC.

TABLES: AUFK, AFPO, RCRDE, ZTMAP_MATRECYCLE, ZTMAP_SLOCRR, ZTMAP_SLOCREC.
TYPE-POOLS: ICON.

DATA: OK_CODE LIKE SY-UCOMM.
DATA: RB_CRTD(1), RB_CNCL(1), RB_ERROR(1).

TYPES: BEGIN OF s_recycle01,
    flags  TYPE flag,        " Status select/deselect
    nomor  TYPE zsprnum,     " Nomor table
    matnr  TYPE matnr,       " Material Number
    maktx  TYPE maktx,       " Material Desc.
    matrr  TYPE matnr,       " Material Raw Recycle
    maktr  TYPE maktx,       " Material Raw Recycle Desc.
    quant  TYPE ERFMG,       " Quantity/Jumlah material
    meins  TYPE meins,       " Base Unit of Measure
    werks  TYPE werks_d,     " Plant
    lgort  TYPE lgort_d,     " Storage Location GI
    lgort2 TYPE lgort_d,     " Storage Location GR
    grund  TYPE mb_grbew,    " Reason for Movement
    film   LIKE cawn-atwrt,  " Characteristic tipe film
    line   LIKE cawn-atwrt,  " Characteristic prod. line
    tgl    TYPE dats,        " Tanggal Kupas
END OF s_recycle01.

DATA: it_recycle01 TYPE STANDARD TABLE OF s_recycle01 WITH HEADER LINE,
      wa_recycle01 LIKE LINE OF it_recycle01.

DATA: ZPOSDATE  LIKE MKPF-BUDAT,
      ZRESOURCE LIKE RCRDE-RESOURCE,
      ZPLANT    LIKE T001W-WERKS,
      ZMATNR    LIKE MARA-MATNR,
      ZQTY      LIKE MSEG-MENGE,
      ZOPERATOR TYPE C LENGTH 13,
      ZSHIFT    TYPE C LENGTH 1,
      ZGROUP    TYPE C LENGTH 1,
      VMATNR    LIKE MARA-MATNR,
      FLAG,
      MSG_ERROR TYPE C LENGTH 250,
      VLGORT    TYPE C LENGTH 4,
      VLGORT2   TYPE C LENGTH 4,
      VARBPL    LIKE CRHD-ARBPL,
      VGRUND    LIKE T157D-GRUND,
      VCOUNT    TYPE I,
      VCOUNT2   TYPE I,
      VERROR    TYPE C LENGTH 1,
      VOBJID LIKE HRP1001-OBJID.

TYPES: BEGIN OF s_cancel01,
    flags    TYPE flag,        " Status select/deselect
    aufnr    TYPE aufnr,       " Order Number
    matnr    TYPE matnr,       " Material Number
    maktx    TYPE maktx,       " Material Desc.
    bwart    TYPE bwart,       " Movement Type
    budat    TYPE budat,       " Posting Date
    werks    TYPE werks_d,     " Plant
    sttxt    TYPE j_stext,     " System status line
    quant    TYPE ERFMG,       " Quantity/Jumlah material
    resource LIKE rcrde-resource, " Resource
    meins    TYPE meins,       " Base Unit of Measure
    uname    TYPE c LENGTH 13, " Username
    tgl      TYPE dats,        " Tanggal Kupas,
    ablad    TYPE ablad,
    objnr    type j_objnr,
    mblnr    type mblnr,
    bktxt    type bktxt,
    lgort    type lgort_d,
END OF s_cancel01.

DATA: it_cancel01 TYPE STANDARD TABLE OF s_cancel01 WITH HEADER LINE,
      wa_cancel01 LIKE LINE OF it_cancel01,
      it_cancel02 like it_cancel01 OCCURS 0 WITH HEADER LINE,
      it_cancel03 like it_cancel01 OCCURS 0 WITH HEADER LINE,
      it_cancelgr like it_cancel01 OCCURS 0 WITH HEADER LINE..

DATA : it_mard TYPE STANDARD TABLE OF mard WITH HEADER LINE. "Check Stock. Add by IT-FANY (28.10.2026)

TYPES: BEGIN OF s_error01,
    flags  TYPE flag,        " Status select/deselect
    nomor  TYPE zsprnum,     " Nomor table
    matnr  TYPE matnr,       " Material Number
    maktx  TYPE maktx,       " Material Desc.
    matrr  TYPE matnr,       " Material Raw Recycle
    maktr  TYPE maktx,       " Material Raw Recycle Desc.
    quant  TYPE ERFMG,       " Quantity/Jumlah material
    meins  TYPE meins,       " Base Unit of Measure
    werks  TYPE werks_d,     " Plant
    lgort  TYPE lgort_d,     " Storage Location GI
    lgort2 TYPE lgort_d,     " Storage Location GR
    labst  TYPE labst,       " Stock
    grund  TYPE mb_grbew,    " Reason for Movement
    film   LIKE cawn-atwrt,  " Characteristic tipe film
    line   LIKE cawn-atwrt,  " Characteristic prod. line
    tgl    TYPE dats,        " Tanggal Kupas
    aufnr  LIKE aufk-aufnr,  " Order Number
    wempf  type wempf,       " Resource
    stat   type c LENGTH 4,  " Status
    bwart  type bwartwe,     " Movement Type
END OF s_error01.

DATA: it_error01 TYPE STANDARD TABLE OF s_error01 WITH HEADER LINE,
      wa_error01 LIKE LINE OF it_error01,
      it_error02 like it_error01 OCCURS 0 WITH HEADER LINE,
      IT_ZERROR01 LIKE ZERROR_LOG OCCURS 0 WITH HEADER LINE,
      MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

DATA: it_value TYPE TABLE OF bapicharactvaluesdescr WITH HEADER LINE,
      d_retvalue TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
      it_value2 TYPE TABLE OF bapicharactvaluesdescr WITH HEADER LINE,
      d_retvalue2 TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE.

DATA: BEGIN OF IT_DISPLAY OCCURS 0,
        AUFNR LIKE AUFK-AUFNR,
        MATNR LIKE MARA-MATNR,
        BWART LIKE MSEG-BWART,
        matrr TYPE matnr,       " Material Raw Recycle
        BUDAT LIKE MKPF-BUDAT,
        BLDAT LIKE MKPF-BLDAT,
        CPUDT LIKE MKPF-CPUDT,
        CPUTM LIKE MKPF-CPUTM,
        USNAM TYPE C LENGTH 13,
        WERKS LIKE MSEG-WERKS,
        LGORT LIKE MSEG-LGORT,
        MENGE LIKE MSEG-MENGE,
        MEINS LIKE MSEG-MEINS,
        WEMPF TYPE WEMPF,
        LINE  TYPE ZSPR_LINE,
        FILM  TYPE ZZFILM,
        TGL   TYPE DATS,
        MBLNR LIKE MSEG-MBLNR,
        MJAHR LIKE MSEG-MJAHR,
        GRUND TYPE MB_GRBEW,
    MSG_TYPE  TYPE C LENGTH 1,
    MSG_DESC  TYPE C LENGTH 200,
        ICON  TYPE C LENGTH 4,
       matnr2 type matnr,       " Display Material Number
    vterminal type c LENGTH 30,
      END OF IT_DISPLAY.

FIELD-SYMBOLS: <fs_display> LIKE LINE OF it_display.

DATA: BEGIN OF IT_ORDER OCCURS 0,
        zorder_number TYPE aufnr," Order Number
      END OF IT_ORDER.

"DATA FOR BAPI_PROCORD_CREATE
DATA: ZORDER_NUMBER LIKE BAPI_ORDER_KEY-ORDER_NUMBER,
      ZORDERDATA    TYPE BAPI_PI_ORDER_CREATE OCCURS 0 WITH HEADER LINE,
      IT_RETURN     LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      IT_RETURN2    LIKE BAPI_ORDER_RETURN OCCURS 0  WITH HEADER LINE,
      ZRETURN       LIKE BAPIRET2,
      WA_DISPLAY    LIKE IT_DISPLAY.

"DATA FOR BAPI_GOODSMVT_CREATE
DATA : THEADER LIKE BAPI2017_GM_HEAD_01 OCCURS 0 WITH HEADER LINE,
*       IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
       TITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE,
       IT_RET LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
       MATDOC LIKE BAPI2017_GM_HEAD_RET-MAT_DOC,
       MATYEAR LIKE BAPI2017_GM_HEAD_RET-DOC_YEAR.

DATA: IT_HEADERRET LIKE BAPI2017_GM_HEAD_RET.

  DATA:    VORDER_TYPE LIKE AUFK-AUART,
           VITTEM_TEXT TYPE SGTXT,
           VMAKTX LIKE MAKT-MAKTX,
           VMAKTR LIKE MAKT-MAKTX,
           VDISPLAY TYPE C LENGTH 1,
           VMBLNR LIKE MKPF-MBLNR,
           d_charval like cawn-atwrt,
           VTOTAL LIKE MSEG-MENGE,
           VBKTXT LIKE MKPF-BKTXT,
           VTERMINAL type string,
           VALIDATION(1) TYPE C.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_RECYCLE01' ITSELF
CONTROLS: ZTC_RECYCLE01 TYPE TABLEVIEW USING SCREEN 7100.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_RECYCLE01'
DATA:     G_ZTC_RECYCLE01_LINES  LIKE SY-LOOPC.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_CANCEL01' ITSELF
CONTROLS: ZTC_CANCEL01 TYPE TABLEVIEW USING SCREEN 7200.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_CANCEL01'
DATA:     G_ZTC_CANCEL01_LINES  LIKE SY-LOOPC.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_ERRHAND' ITSELF
CONTROLS: ZTC_ERRHAND TYPE TABLEVIEW USING SCREEN 7300.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_ERRHAND'
DATA:     G_ZTC_ERRHAND_LINES  LIKE SY-LOOPC.

type-pools: slis.
  data: gs_layout type slis_layout_alv,
        g_exit_caused_by_caller,
        gs_exit_caused_by_user type slis_exit_by_user,
        gt_fieldcat type slis_t_fieldcat_alv with header line,
        g_repid like sy-repid,
        y_print type slis_print_alv.

  data:
        gt_events type slis_t_event,
        gt_list_top_of_page type slis_t_listheader,
        g_status_set type slis_formname value 'PF_STATUS_SET',
        g_user_command type slis_formname value 'USER_COMMAND',
        g_top_of_page type slis_formname value 'TOP_OF_PAGE',
        g_top_of_list type slis_formname value 'TOP_OF_LIST',
        g_end_of_list type slis_formname value 'END_OF_LIST'.

  data : gs_variant like disvariant, g_save.

  DATA : IT_MAP_SLOCREC LIKE ZTMAP_SLOCREC OCCURS 0.
  DATA : WA_MAP_SLOCREC LIKE LINE OF IT_MAP_SLOCREC.
  DATA : GT_VRM_LGORT_GR TYPE VRM_VALUES.
  DATA : WA_VRM_LGORT_GR LIKE LINE OF GT_VRM_LGORT_GR.

  SELECTION-SCREEN BEGIN OF SCREEN 7310 AS SUBSCREEN.
    SELECTION-SCREEN BEGIN OF BLOCK spr_error WITH FRAME TITLE FRMT7310.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT6.
        SELECT-OPTIONS: so_plnt2 FOR afpo-dwerk OBLIGATORY NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (15) TXT11.
        PARAMETERS: znik type c length 13 OBLIGATORY.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT7.
        SELECT-OPTIONS: so_res2  FOR rcrde-resource NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT8.
        SELECT-OPTIONS: so_psdt2 FOR aufk-erdat NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT SY-DATUM.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT13.
        SELECT-OPTIONS: so_bldat FOR aufk-erdat OBLIGATORY DEFAULT SY-DATUM.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT9.
        SELECT-OPTIONS: so_mtnr2 FOR afpo-matnr NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT10.
        SELECT-OPTIONS: so_lgort FOR afpo-lgort NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT12.
        SELECT-OPTIONS: zaufnr FOR aufk-aufnr NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

    SELECTION-SCREEN END OF BLOCK spr_error.
  SELECTION-SCREEN END OF SCREEN 7310.


  SELECTION-SCREEN BEGIN OF SCREEN 7210 AS SUBSCREEN.
    SELECTION-SCREEN BEGIN OF BLOCK spr_cancel WITH FRAME TITLE FRMT7210.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT1.
        SELECT-OPTIONS: so_plant FOR afpo-dwerk OBLIGATORY.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT2.
        SELECT-OPTIONS: so_matnr FOR afpo-matnr.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT3.
        SELECT-OPTIONS: so_aufnr FOR afpo-aufnr.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT4.
        SELECT-OPTIONS: so_res   FOR rcrde-resource NO INTERVALS NO-EXTENSION.
      SELECTION-SCREEN END OF LINE.

      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (12) TXT5.
        SELECT-OPTIONS: so_posdt FOR aufk-erdat NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT SY-DATUM.
      SELECTION-SCREEN END OF LINE.

    SELECTION-SCREEN END OF BLOCK spr_cancel.
  SELECTION-SCREEN END OF SCREEN 7210.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_RES2-LOW.
  PERFORM GET_RESOURCE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_RES-LOW.
  PERFORM GET_RESOURCE2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_LGORT-LOW.
  PERFORM GET_SO_LGORT.

FORM GET_RESOURCE.

DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
          WERKS TYPE CRHD-WERKS,
          ARBPL TYPE CRHD-ARBPL,
      END OF IT_DETAIL2.

DATA: dynfields type table of dynpread with header line.

  dynfields-fieldname = 'SO_PLNT2-LOW'.
  append dynfields.

  call function 'DYNP_VALUES_READ'
       exporting
            dyname               = sy-cprog
            dynumb               = sy-dynnr
            translate_to_upper   = 'X'
       tables
            dynpfields           = dynfields
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            stepl_not_found      = 10
            others               = 11.


  read table dynfields with key fieldname = 'SO_PLNT2-LOW'.
  SO_PLNT2-LOW = dynfields-fieldvalue.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
    FROM ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = SO_PLNT2-LOW.

  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ARBPL'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = sy-repid
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ARBPL'
    TABLES
      VALUE_TAB    = IT_DETAIL2.

ENDFORM.


FORM GET_RESOURCE2.

DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
          WERKS TYPE CRHD-WERKS,
          ARBPL TYPE CRHD-ARBPL,
      END OF IT_DETAIL2.

DATA: dynfields type table of dynpread with header line.

  dynfields-fieldname = 'SO_PLANT-LOW'.
  append dynfields.

  call function 'DYNP_VALUES_READ'
       exporting
            dyname               = sy-cprog
            dynumb               = sy-dynnr
            translate_to_upper   = 'X'
       tables
            dynpfields           = dynfields
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            stepl_not_found      = 10
            others               = 11.


  read table dynfields with key fieldname = 'SO_PLANT-LOW'.
  SO_PLANT-LOW = dynfields-fieldvalue.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
    FROM ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = SO_PLANT-LOW.

  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ARBPL'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = sy-repid
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ARBPL'
    TABLES
      VALUE_TAB    = IT_DETAIL2.

ENDFORM.


FORM GET_SO_LGORT.

DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
          WERKS TYPE CRHD-WERKS,
          ARBPL TYPE CRHD-ARBPL,
          ZRRLGORT TYPE LGORT_D,
      END OF IT_DETAIL2.

DATA: dynfields like dynpread OCCURS 0 with header line.

  dynfields-fieldname = 'SO_PLNT2-LOW'.
  append dynfields.
  dynfields-fieldname = 'SO_RES2-LOW'.
  append dynfields.

  call function 'DYNP_VALUES_READ'
       exporting
            dyname               = sy-cprog
            dynumb               = sy-dynnr
            translate_to_upper   = 'X'
       tables
            dynpfields           = dynfields
       exceptions
            invalid_abapworkarea = 1
            invalid_dynprofield  = 2
            invalid_dynproname   = 3
            invalid_dynpronummer = 4
            invalid_request      = 5
            no_fielddescription  = 6
            invalid_parameter    = 7
            undefind_error       = 8
            double_conversion    = 9
            stepl_not_found      = 10
            others               = 11.

  read table dynfields with key fieldname = 'SO_PLNT2-LOW'.
  SO_PLNT2-LOW = dynfields-fieldvalue.
  read table dynfields with key fieldname = 'SO_RES2-LOW'.
  SO_RES2-LOW = dynfields-fieldvalue.

     SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~ZRRLGORT
       INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
       FROM  ZTMAP_SLOCREC
       WHERE ZTMAP_SLOCREC~WERKS = SO_PLNT2-LOW
       AND   ZTMAP_SLOCREC~ARBPL = SO_RES2-LOW.

  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ZRRLGORT'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = sy-repid
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ZRRLGORT'
    TABLES
      VALUE_TAB    = IT_DETAIL2.

ENDFORM.