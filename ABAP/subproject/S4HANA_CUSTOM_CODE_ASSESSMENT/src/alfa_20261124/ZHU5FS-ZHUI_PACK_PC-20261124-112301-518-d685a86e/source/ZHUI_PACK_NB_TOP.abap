*&---------------------------------------------------------------------*
*&  Include           ZHU_PACK_NB_TOP                                *
*&---------------------------------------------------------------------*

PROGRAM  ZHU_PACK_PC.

INCLUDE ZHUI_PACKINST_CONSTANTS.

************************************************************************
* Tables definition
************************************************************************
TABLES : ZPACK,            "Packing Instruction
         ZPACK00,*ZPACK00, "Comm. Structure
         HUM_PROFILE_S,    "Name of the Packing Station Profile
         HUPAST_T,         "Packing Station Profile
        *HUPAST_T,                                          "#EC NEEDED
*        humseg,           "
         MARA,             "Material Master
         MAKT,             "
         VBAK,             "Sales Order Hdr
         VBAP,             "Sales Order Item
         KNA1,             "Customer
         MCHA,                                      "#EC NEEDED Batches
         MSKA,             "Sales Order Stock
         VEKP,             "HU Header
         VEPO,             "HU Itm
         VEVW,             "Where-Used List for Handling Units
         MSEG,                                              "#EC NEEDED
         ZQM001.           "QC Packing Status

TABLES : T001W,            "Plant
         T001L,            "Storage Locations
         *T001L,
         NAST.                                              "#EC NEEDED
*        usr01.
*        rctms.

CONSTANTS:
  C_USEMIRROR TYPE FLAG VALUE SPACE. "-- STORE ALL VEKP~EXIDV DATA IN MEMORY

************************************************************************
* Variables definition
************************************************************************
TYPES:
  BEGIN OF GT_EXIDV,
    CHARG TYPE CHARG_D,
    EXIDV TYPE EXIDV,
  END OF GT_EXIDV,

  BEGIN OF GT_CHARG,
    CHARG TYPE CHARG_D,
  END OF GT_CHARG.

DATA:
  IT_EXIDV TYPE SORTED TABLE OF GT_EXIDV
    WITH UNIQUE KEY CHARG EXIDV
    WITH HEADER LINE,

  IT_CHARG TYPE HASHED TABLE OF GT_CHARG
    WITH UNIQUE KEY CHARG
    WITH HEADER LINE.

DATA : CTR1 TYPE I,
       CTR2 TYPE I,
       CTR3 TYPE I,
       VINS0(3) TYPE N,
       VINS1(3) TYPE N,
       VINS2(3) TYPE N,
       ANS,
       FLG,                                                 "#EC NEEDED
       GSONUM LIKE VEPO-SONUM,
       GTABIX LIKE SY-TABIX,
       CHR1ST LIKE ZPACK00,    "First Batch Characteristics
       TABIX LIKE SY-TABIX,    "Locally used
       DLASTVBELN  TYPE VBELN,
       DLASTPOSNR  TYPE POSNR,
       D_MATERIALTYPEOK TYPE FLAG,
       D_FATALERR TYPE FLAG.

DATA GS_MODE(1).

* for HU
DATA :
*      hdrproposal TYPE bapihuhdrproposal,
       ITMPROPOSAL TYPE BAPIHUITMPROPOSAL OCCURS 2 WITH HEADER LINE, "#EC NEEDED
       HUHDR       TYPE BAPIHUHEADER,
       HUITM       TYPE BAPIHUITEM,
       HUKEY       TYPE BAPIHUKEY-HU_EXID,
       RETRN       LIKE BAPIRET2 OCCURS 2 WITH HEADER LINE.

" Added by William at 23.02.2026 (for unpallet)
DATA: V_EXIDV_UNPALLET LIKE VEKP-EXIDV.
DATA: V_WERK1_UNPALLET LIKE ZHU_MAPP-WERK1.
DATA: V_LGOR1_UNPALLET LIKE ZHU_MAPP-LGOR1.
DATA: V_WERK2_UNPALLET LIKE ZHU_MAPP-WERK2.
DATA: V_LGOR2_UNPALLET LIKE ZHU_MAPP-LGOR2.
" End added by William at 23.02.2026 (for unpallet)

************************************************************************
* Internal Table definition
************************************************************************
TYPES :
      BEGIN OF COMM1,
        POSNR LIKE ZPACK-POSNR,
        INS0  LIKE ZPACK00-ZINS01,
        INS1  LIKE ZPACK00-ZINS02,
        INS2  LIKE ZPACK00-ZINS03,
        INST  LIKE ZPACK00-MATNR,
        ZMENG LIKE ZPACK00-ZMENG,
        EXID  LIKE ZPACK00-EXIDV,
        STAT  LIKE ZPACK00-STAT,
        TABIX LIKE SY-TABIX,
        SELE  TYPE CHAR01,
      END OF COMM1.

DATA :
*       hu_com    TYPE comm1 OCCURS 0 WITH HEADER LINE,
       HU_COM    TYPE STANDARD TABLE OF COMM1
                   WITH NON-UNIQUE KEY POSNR INS0 INS1 INS2 INST EXID STAT
                   WITH HEADER LINE,
       HU_TMP    TYPE COMM1 OCCURS 0 WITH HEADER LINE,
       HU_PACK   TYPE COMM1 OCCURS 0 WITH HEADER LINE,
       HU_HU     TYPE COMM1 OCCURS 0 WITH HEADER LINE,
       HU_NEU    TYPE COMM1 OCCURS 0 WITH HEADER LINE.

DATA: BDCDATA LIKE BDCDATA    OCCURS 10 WITH HEADER LINE.

************************************************************************
* Screen Control Section
************************************************************************
CONTROLS: TCTR01 TYPE TABLEVIEW USING SCREEN 200.

DATA : MAXLINE TYPE I,
       MAXLOOP TYPE I,
       PAGEBEGIN LIKE SY-LOOPC,
       POINTER LIKE SY-STEPL,
       OK_CODE LIKE SY-UCOMM,
       GCHAR(01),  "Global Characteristic
       VSELEK(01),
       BUTT01(04), "Prev Page    = PGUP
       BUTT02(04), "Next Page    = PGDN
       BUTT03(04), "Prev Line    = PREV
       BUTT04(04), "Next Line    = NEXT
       BUTT05(04), "Deselect all = DESE
       BUTT06(04), "First Page   = TOP
       BUTT07(04). "Last Page    = END

DATA : READ_IDX LIKE SY-STEPL,
       WA    LIKE HU_COM,
       PACKG LIKE MCMARKED_VALUES OCCURS 2 WITH HEADER LINE.


DATA: BEGIN OF IT_VENUM OCCURS 0,
      VENUM LIKE VEKP-VENUM,
      END OF IT_VENUM.


DATA : RB1 TYPE C,
       RB2 TYPE C,
       STATUS(2),
       ERROR,
       V_WERKS TYPE VEPO-WERKS,
       V_LGORT TYPE VEPO-LGORT,
       VCHARG TYPE ZPACK00-CHARGDC,
       V_SO TYPE VBRP-VBELN,
       SHEET,
       BUT_UNPACK,
       VLOCK TYPE ZTLOCK-LOOBJ.

TYPES :
  BEGIN OF ST_FORMSG,
    MSGID  LIKE SY-MSGID,
    MSGTY  LIKE SY-MSGTY,
    MSGNO  LIKE SY-MSGNO,
    MSGV1  LIKE SY-MSGV1,
    MSGV2  LIKE SY-MSGV2,
    MSGV3  LIKE SY-MSGV3,
    MSGV4  LIKE SY-MSGV4,
    LINENO TYPE MESG-ZEILE,
  END OF ST_FORMSG.

DATA : TA_ERROR TYPE TABLE OF ST_FORMSG,
       WA_ERROR TYPE ST_FORMSG.

DATA : OPT LIKE CTU_PARAMS.