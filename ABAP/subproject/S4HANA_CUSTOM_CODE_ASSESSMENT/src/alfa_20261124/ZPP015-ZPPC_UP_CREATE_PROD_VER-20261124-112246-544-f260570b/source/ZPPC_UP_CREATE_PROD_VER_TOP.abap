*&---------------------------------------------------------------------*
*& Include ZPPC_UP_CREATE_PROD_VER_TOP                       Report ZPPC_UP_CREATE_PROD_VER
*&
*&---------------------------------------------------------------------*

REPORT   ZPPC_UP_CREATE_PROD_VER.
INCLUDE Z_PROG_INFO.             "Program Documentation

CONSTANTS : GCF_E1(4) TYPE C VALUE '@0A@',
            GCF_S1(4) TYPE C VALUE '@08@'.

*data for create  production plan
DATA : BEGIN OF IT_HPVER OCCURS 0,
        WERKS(4) TYPE C,
        MATNR(18) TYPE C,
        VERID(4) TYPE C,
        TEXT1(50) TYPE C,
        ADATU(10) TYPE C,
        BDATU(10) TYPE C,
        PLNTY(1) TYPE C,
        PLNNR(8) TYPE C,
        ALNAL(2) TYPE C,
        STLAL(2) TYPE C,
        STLAN(1) TYPE C,
        ZSTAT(4) TYPE C ,
        ZDESC(50) TYPE C,
       END OF IT_HPVER.

DATA : CR(1) TYPE C,
       CH(1) TYPE C.

DATA : COUNTER TYPE I VALUE '1',
       N(3),
       DD      TYPE C LENGTH 2,
       MM      TYPE C LENGTH 2,
       YYYY    TYPE C LENGTH 4,
       DATE    TYPE C LENGTH 8,
       EKS(3)  TYPE C.

"DATA FOR BDC
DATA : IT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
       IT_BDCMSGCOLL LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
       IT_IPVER LIKE TABLE OF IT_HPVER WITH HEADER LINE.

DATA  : P_FILE  TYPE STRING,
        FNAME   TYPE STRING,
        V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZPPC_UP_CREATE_PROD_VER',
        FPATH   TYPE IBIPPARMS-PATH.

CONSTANTS : CPLNTY(17) TYPE C VALUE 'MKAL_EXPAND-PLNTY',
            CMATNR(17) TYPE C VALUE 'MKAL_EXPAND-MATNR',
            CVERID(17) TYPE C VALUE 'MKAL_EXPAND-VERID',
            CTEXT1(17) TYPE C VALUE 'MKAL_EXPAND-TEXT1',
            CADATU(17) TYPE C VALUE 'MKAL_EXPAND-ADATU',
            CBDATU(17) TYPE C VALUE 'MKAL_EXPAND-BDATU',
            CBSTMI(17) TYPE C VALUE 'MKAL_EXPAND-BSTMI',
            CBSTMA(17) TYPE C VALUE 'MKAL_EXPAND-BSTMA',
            CSTLAL(17) TYPE C VALUE 'MKAL_EXPAND-STLAL',
            CSTLAN(17) TYPE C VALUE 'MKAL_EXPAND-STLAN',
            CPLNNR(17) TYPE C VALUE 'MKAL_EXPAND-PLNNR',
            CALNAL(17) TYPE C VALUE 'MKAL_EXPAND-ALNAL',
            CMARK(16) TYPE C VALUE 'MKAL_EXPAND-MARK'.


DATA :      VPLNTY(21) TYPE C ,
            VMATNR(21) TYPE C ,
            VVERID(21) TYPE C ,
            VTEXT1(21) TYPE C ,
            VADATU(21) TYPE C ,
            VBDATU(21) TYPE C ,
            VBSTMI(21) TYPE C ,
            VBSTMA(21) TYPE C ,
            VSTLAL(21) TYPE C ,
            VSTLAN(21) TYPE C ,
            VPLNNR(21) TYPE C ,
            VALNAL(21) TYPE C ,
            VMARK(20) TYPE C .