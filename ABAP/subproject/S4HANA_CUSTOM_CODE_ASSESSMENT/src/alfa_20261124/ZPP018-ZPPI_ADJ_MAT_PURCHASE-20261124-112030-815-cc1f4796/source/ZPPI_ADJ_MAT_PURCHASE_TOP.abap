*&---------------------------------------------------------------------*
*& Include ZPPI_RESLIT_ROLL_TOP                              Report ZPPI_RESLIT_ROLL
*&
*&---------------------------------------------------------------------*

REPORT   ZPPI_ADJ_MAT_PURCHASE.

TABLES: MCHB, MKPF, PLOGI, T001W, MSEG.
TYPE-POOLS: ICON.

data: OK_CODE  LIKE sy-ucomm,
      ok_7100  LIKE sy-ucomm,
      ok_7200  LIKE sy-ucomm,
      ok_7220  LIKE sy-ucomm,
      ok_7300  LIKE sy-ucomm,
      vmess    TYPE string,
      mblnr_gi LIKE mseg-mblnr,
      mjahr_gi LIKE mseg-mjahr,
      tanggal  TYPE c LENGTH 10,
      num      TYPE c LENGTH 3,
      mgodis,
      rstdis,
      flag,
      flg,
      flagmjahr,
      canc,
      canct,
      dscitm   TYPE i,
      d_pilih  TYPE i,
      n        TYPE i,
      RIBUAN   TYPE C,
      PULUHAN  TYPE C,
      v_vbeln  LIKE vbap-vbeln,
      v_matnr  LIKE vbap-matnr,
      v_stlal  LIKE mkal-stlal,
      v_posnr  LIKE vbap-posnr,
      v_lengt  TYPE P LENGTH 15 DECIMALS 3,
      V_AUFART TYPE AUFART,
      V_ATINN  LIKE CAWNT-ATINN,
      V_ATZHL  LIKE CAWNT-ATZHL.
DATA: C_QUANT(16),
      PROC_ORD    TYPE AUFNR,
      V_PROC_ORD  TYPE AUFNR,
      BATCH_GR    LIKE BAPIBATCHKEY-BATCH,
      LENGTHAWAL  TYPE CHAR16,
*      LENGTHAKHIR TYPE CHAR16,
*      EXTRALENGTH TYPE CHAR5,
      V_SGTXT     TYPE SGTXT,
      V_CONV      LIKE AUSP-ATWRT.
DATA: fcode TYPE TABLE OF sy-ucomm.
DATA: V_DYNINDEX  TYPE SY-STEPL,
      WA_DYNPREAD TYPE DYNPREAD,
      T_DYNPREAD  LIKE DYNPREAD OCCURS 0.
*data declarations for ALV
DATA:LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
     LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
     LS_FIELDCATLOG TYPE SLIS_FIELDCAT_ALV,
     LT_FIELDCATLOG TYPE SLIS_T_FIELDCAT_ALV,
     LT_LAYOUT TYPE SLIS_LAYOUT_ALV.
DATA: MATERIAL    LIKE  CSAP_MBOM-MATNR,
      PLANT       LIKE  CSAP_MBOM-WERKS,
      BOM_USAGE   LIKE  CSAP_MBOM-STLAN,
      ALTERNATIVE LIKE  CSAP_MBOM-STLAL.

TYPES: BEGIN OF s_maintain,
  flags  TYPE flag,        "Status select/deselect
  nomor  TYPE P LENGTH 3,  "Nomor urut
  mblnr  LIKE mseg-mblnr,  "Mat.Doc GR PO
  mjahr  LIKE mseg-mjahr,  "Mat.Doc Year GR PO
  zeile  LIKE mseg-zeile,  "Mat.Doc Item GR PO
  matnr  LIKE mchb-matnr,  "Material Number
  charg  LIKE mchb-charg,  "Batch
  film   LIKE cawn-atwrt,  "Characteristic tipe film
  filmcd LIKE cawn-atwrt,  "Kode characteristic tipe film
  length LIKE cawn-atwrt,  "Characteristic zzlength (Panjang Awal)
  conv   LIKE cawn-atwrt,  "Characteristic zzconversionrollkg
  menge  LIKE mseg-menge,  "Berat PO
  clabs  LIKE mchb-clabs,  "Stok Aktual
  indc   TYPE icon_d,      "Icon Indicator
  lgort  LIKE mchb-lgort,  "Sloc GI/GR
  mtrpo  LIKE mara-matnr,  "Material Process Order
  verid  LIKE afpo-verid,  "Production Version
  hdrlvl,                  "Header Indicator Per Mat Doc Per Material
  mblnrc,                  "Indicator Cancelation Mat Doc
  btchgr LIKE mchb-charg,  "Batch GR
  selected,                "Indicator Selected
END OF s_maintain.

TYPES: BEGIN OF s_display,
  flags  TYPE flag,        "Status select/deselect
  mblnr  LIKE mseg-mblnr,  "Mat.Doc Purchase Order
  mjahr  LIKE mseg-mjahr,  "Mat.Doc Year Purchase Order
  ebeln  LIKE mseg-ebeln,  "Purchase Order Number
  matnr  LIKE mseg-matnr,  "Material Number Purchase Order
  aufnr  LIKE mseg-aufnr,  "Order Number
  bwart  LIKE mseg-bwart,  "Movement Type
  mblnr2 LIKE mseg-mblnr,  "Material Document Process Order
  mjahr2 LIKE mseg-mjahr,  "Material Document Year Process Order
  zeile2 LIKE mseg-zeile,  "Material Doc.Item Process Order
  matnr2 LIKE mseg-matnr,  "Material Number
  menge  LIKE mseg-menge,  "Quantity
  charg  LIKE mseg-charg,  "Batch
  sgtxt  LIKE mseg-sgtxt,  "Gabungan dari tipe film,panjang awal,panjang akhir,extralength
  filmcd LIKE cawn-atwrt,  "Kode characteristic tipe film
  film   LIKE cawn-atwrt,  "Characteristic tipe film
  lgort  LIKE mseg-lgort,  "Sloc
  budat_mkpf LIKE mseg-budat_mkpf, "Posting Date
  bktxt  LIKE mkpf-bktxt,  "NIK
  verid  LIKE MKAL-VERID,  "Production Version
  length LIKE cawn-atwrt,  "Characteristic zzlength (Panjang Awal)
  lengta TYPE cawn-atwrt,  "Panjang Akhir (Panjang Awal - Extra Length)
  exleng TYPE cawn-atwrt,  "Extra Length
  indc   TYPE icon_d,      "Cancel Indicator
  mat_kdauf LIKE mseg-mat_kdauf, "Sales Order
  mat_kdpos LIKE mseg-mat_kdpos, "Sales order item
END OF s_display.

TYPES: BEGIN OF s_displayh,
  mblnr  LIKE mseg-mblnr,  "Mat.Doc Purchase Order
  mjahr  LIKE mseg-mjahr,  "Mat.Doc Year Purchase Order
  mblnrc,                  "Indicator Cancelation Mat Doc
END OF s_displayh.

DATA: it_maintain   TYPE STANDARD TABLE OF s_maintain WITH HEADER LINE,
      tmp_maintain  TYPE STANDARD TABLE OF s_maintain WITH HEADER LINE,
      tmp_maintain2 TYPE STANDARD TABLE OF s_maintain WITH HEADER LINE,
      wa_maintain   TYPE s_maintain,
      it_display    TYPE STANDARD TABLE OF s_display  WITH HEADER LINE,
      it_displayh   TYPE STANDARD TABLE OF s_displayh WITH HEADER LINE,
      it_cancel     TYPE STANDARD TABLE OF s_display  WITH HEADER LINE,
      CHAR_OF_BATCH LIKE CLBATCH OCCURS 0 WITH HEADER LINE,
      WA_CHAR_OF_BATCH TYPE CLBATCH.
DATA: RA_CHARACT TYPE RANGE OF ATNAM,
      WA_CHARACT LIKE LINE OF RA_CHARACT.
DATA: T_STPO  LIKE  STPO_API02 OCCURS 0.
FIELD-SYMBOLS: <fs_maintain> LIKE LINE OF it_maintain,
               <fs_display>  LIKE LINE OF it_display,
               <fs_displayh> LIKE LINE OF it_displayh,
               <fs_cancel>   LIKE LINE OF it_cancel,
               <fs_stpo>     LIKE LINE OF t_stpo,
               <FS_CHAR_OF_BATCH> TYPE CLBATCH,
               <fs_tmpmaintain>   LIKE LINE OF tmp_maintain,
               <fs_tmpmaintain2>  LIKE LINE OF tmp_maintain.

DATA: BEGIN OF IT_LOG OCCURS 0,
        nomor  TYPE P LENGTH 3,  "Nomor urut
        mblnr  LIKE mseg-mblnr,  "Mat.Doc GR PO
        mjahr  LIKE mseg-mjahr,  "Mat.Doc Year GR PO
        matnr  LIKE mchb-matnr,  "Material Number
        charg  LIKE mchb-charg,  "Batch
        prord  TYPE string,      "Create Process Order
        gibtch TYPE string,      "GI Batch
        crbtch TYPE string,      "Create Batch Baru Utk GR
        setchr TYPE string,      "Set Characteristic Batch Baru
        grbtch TYPE string,      "GR Batch Baru
        teco   TYPE string,      "TECO Order
      END OF IT_LOG.
DATA: LS_SUBRC LIKE SY-SUBRC,
      IT_CHAR  LIKE BAPI1003_ALLOC_VALUES_CHAR OCCURS 0 WITH HEADER LINE,
      WA_CHAR2 LIKE LINE OF IT_CHAR.
DATA: wa_sort    TYPE slis_sortinfo_alv,
      it_sortcat TYPE TABLE OF slis_sortinfo_alv.
DATA: L_MSTRING(480).
DATA: VCLASS LIKE KLAH-CLASS,
      VKLART LIKE KLAH-KLART,
      VOBTAB LIKE TCLT-OBTAB,
      VOBJEC LIKE KSSK-OBJEK,
      VSMBLN LIKE MSEG-SMBLN,
      VCHARG LIKE VEPO-CHARG,
      VKALAB LIKE MSKA-KALAB,
      VCLABS LIKE MCHB-CLABS,
      VPERNR LIKE PA0001-PERNR,
      VWERKS LIKE T001W-WERKS,
      I_GRID_TITLE TYPE LVC_TITLE.
DATA: IT_RETURN2 LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      IT_NUM     LIKE BAPI1003_ALLOC_VALUES_NUM  OCCURS 0 WITH HEADER LINE,
      IT_CURR    LIKE BAPI1003_ALLOC_VALUES_CURR OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_TEST OCCURS 0,
        mblnr  LIKE mseg-mblnr,  "Mat.Doc PO
        ebeln  LIKE mseg-ebeln,  "PO Number
        matnr  LIKE mseg-matnr,  "Material PO
        aufnr  LIKE mseg-aufnr,  "Order Number
        bwart  LIKE mseg-bwart,  "Movement Type
        mblnr2 LIKE mseg-mblnr,  "Mat.Doc Proc.Ord
        matnr2 LIKE mseg-matnr,  "Material Proc.Order
        menge  LIKE mseg-menge,  "Quantity
        charg  LIKE mchb-charg,  "Batch
        cancgr TYPE string,      "Cancel GR
        cancgi TYPE string,      "Cancel GI
      END OF IT_TEST.

*For Create Process Order
*******DATA: BEGIN OF ORDERDATA_PRO OCCURS 0.
*******        INCLUDE STRUCTURE BAPI_PI_ORDER_CREATE.
*******DATA: END OF ORDERDATA_PRO.
*******DATA: BEGIN OF RETURN_PRO OCCURS 0.
*******        INCLUDE STRUCTURE BAPIRET2.
*******DATA: END OF RETURN_PRO.
*******DATA: ORDER_NUMBER LIKE BAPI_ORDER_KEY-ORDER_NUMBER,
*******      ORDER_TYPE   LIKE BAPI_ORDER_COPY-ORDER_TYPE.

*Batch Input Processing
DATA: BEGIN OF BDCDATA OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCDATA.

DATA: BEGIN OF MESSTAB OCCURS 0.
        INCLUDE STRUCTURE BDCMSGCOLL.
DATA: END OF MESSTAB.
DATA  V_BDCMODE VALUE 'E'.

DATA: OPT LIKE CTU_PARAMS. " Add By Will 11.01.2012

* For GI
DATA: BEGIN OF GMHEAD_GI.
        INCLUDE STRUCTURE BAPI2017_GM_HEAD_01.
DATA: END OF GMHEAD_GI.

DATA: BEGIN OF GMCODE_GI.
        INCLUDE STRUCTURE BAPI2017_GM_CODE.
DATA: END OF GMCODE_GI.

DATA: BEGIN OF MTHEAD_GI.
        INCLUDE STRUCTURE BAPI2017_GM_HEAD_RET.
DATA: END OF MTHEAD_GI.

DATA: BEGIN OF ITAB_GI OCCURS 0.
        INCLUDE STRUCTURE BAPI2017_GM_ITEM_CREATE.
DATA: END OF ITAB_GI.

DATA: BEGIN OF ERRMSG_GI OCCURS 100.
        INCLUDE STRUCTURE BAPIRET2.
DATA: END OF ERRMSG_GI.

* For Create Batch
DATA: BEGIN OF RETURN2 OCCURS 100.
        INCLUDE STRUCTURE BAPIRET2.
DATA: END OF RETURN2.

* For GR
DATA: BEGIN OF GMHEAD_GR.
        INCLUDE STRUCTURE BAPI2017_GM_HEAD_01.
DATA: END OF GMHEAD_GR.

DATA: BEGIN OF GMCODE_GR.
        INCLUDE STRUCTURE BAPI2017_GM_CODE.
DATA: END OF GMCODE_GR.

DATA: BEGIN OF MTHEAD_GR.
        INCLUDE STRUCTURE BAPI2017_GM_HEAD_RET.
DATA: END OF MTHEAD_GR.

DATA: BEGIN OF ITAB_GR OCCURS 0.
        INCLUDE STRUCTURE BAPI2017_GM_ITEM_CREATE.
DATA: END OF ITAB_GR.

DATA: BEGIN OF ERRMSG_GR OCCURS 100.
        INCLUDE STRUCTURE BAPIRET2.
DATA: END OF ERRMSG_GR.

*For TECO Order
DATA: MESSAGE_TABLE LIKE COACTMSG OCCURS 0 WITH HEADER LINE,
      CAUFVTAB LIKE CAUFV OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF TECO_RETURN OCCURS 0.
        INCLUDE STRUCTURE BAPIRET2.
DATA: END OF TECO_RETURN.

DATA: BEGIN OF TECO_ORDERS OCCURS 100.
        INCLUDE STRUCTURE BAPI_ORDER_KEY.
DATA: END OF TECO_ORDERS.

DATA: BEGIN OF TECO_DEAIL_RETURN OCCURS 0.
        INCLUDE STRUCTURE BAPI_ORDER_RETURN.
DATA: END OF TECO_DEAIL_RETURN.

* For Cancel GI
DATA: MATERIALDOCUMENT LIKE BAPI2017_GM_HEAD_02-MAT_DOC,
      MATDOCUMENTYEAR  LIKE BAPI2017_GM_HEAD_02-DOC_YEAR,
      GOODSMVT_HEADRET LIKE BAPI2017_GM_HEAD_RET.

DATA: BEGIN OF RETURN OCCURS 0.
        INCLUDE STRUCTURE BAPIRET2.
DATA: END OF RETURN.

* For Printing Batch
RANGES: R_BATCH FOR MCH1-CHARG.

* For F4 VERID
DATA: BEGIN OF IT_VERID OCCURS 0,
          MATNR LIKE MKAL-MATNR,
          WERKS LIKE MKAL-WERKS,
          VERID LIKE MKAL-VERID,
          COMPONENT LIKE STPO_API02-COMPONENT,
        END OF IT_VERID.
FIELD-SYMBOLS: <fs_verid> LIKE LINE OF it_verid.

*-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Add internal table to contain Order, Batch, Matdoc GI/GR
DATA: BEGIN OF IT_AGSGRN OCCURS 0,
        AUFNR LIKE AUFK-AUFNR,
        CHARG LIKE MCH1-CHARG,
        MBLNR LIKE MKPF-MBLNR,
      END OF IT_AGSGRN.
DATA: IT_AGSPARAM LIKE STANDARD TABLE OF IT_AGSGRN.
*-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Add internal table to contain Order, Batch, Matdoc GI/GR


SELECTION-SCREEN BEGIN OF SCREEN 7110 AS SUBSCREEN." NO INTERVALS.
SELECTION-SCREEN BEGIN OF BLOCK blck_maintain WITH FRAME TITLE text-001.
  select-options:
                so_plant for t001w-werks NO-EXTENSION NO INTERVALS,
                so_mblnr for mseg-mblnr,
                so_mjahr for mseg-mjahr  NO-EXTENSION NO INTERVALS,
                so_posdt for mkpf-budat  DEFAULT sy-datum NO-EXTENSION NO INTERVALS,
                so_nik   for plogi-objid NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK blck_maintain.
SELECTION-SCREEN END OF SCREEN 7110.

SELECTION-SCREEN BEGIN OF SCREEN 7210 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK blck_display WITH FRAME TITLE text-002.
  select-options:
                s_plant  for t001w-werks NO-EXTENSION NO INTERVALS, "Plant
                s_posdt  for mkpf-budat  DEFAULT sy-datum," NO-EXTENSION NO INTERVALS, "Posting Date
                s_ebeln  for mseg-ebeln, "Purchase Order Number
                s_mblnr  for mseg-mblnr, "Mat.Doc Purchase Order
                s_mjahr  for mseg-mjahr  NO-EXTENSION NO INTERVALS, "Mat.Doc Purchase Order Year
                s_mblnr2 for mseg-mblnr, "Mat.Doc Process Order
                s_mjahr2 for mseg-mjahr  NO-EXTENSION NO INTERVALS, "Mat.Doc Process Order Year
                s_nik    for plogi-objid NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK blck_display.
SELECTION-SCREEN END OF SCREEN 7210.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_MAINTAIN' ITSELF
CONTROLS: TC_MAINTAIN TYPE TABLEVIEW USING SCREEN 7100.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_MAINTAIN'
DATA:     G_TC_MAINTAIN_LINES  LIKE SY-LOOPC.
DATA W_TCONTROL LIKE LINE OF TC_MAINTAIN-COLS.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_CANCEL' ITSELF
CONTROLS: TC_CANCEL TYPE TABLEVIEW USING SCREEN 7220.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_CANCEL'
DATA:     G_TC_CANCEL_LINES  LIKE SY-LOOPC.