*&---------------------------------------------------------------------*
*& Include ZPPI_UPLOAD_MASTERRECIPE_TOP
*& Report ZPPI_UPLOAD_MASTERRECIPE
*&---------------------------------------------------------------------*

REPORT   ZPPI_UPLOAD_MASTERRECIPE.

*DATA : A TYPE DECFLOAT34. " LENGTH 31 DECIMALS 2.

CONSTANTS : GCF_E1(4) TYPE C VALUE '@0A@',
            GCF_S1(4) TYPE C VALUE '@08@'.

DATA :  BEGIN OF IT_HMR OCCURS 0,
          PLNNR(8) TYPE C,
          MATNR(18) TYPE C,
          WERKS(4) TYPE C,
          PLNAL(2) TYPE C,
          VORNR(4) TYPE C,
          PVZNR(4) TYPE C,
          PHFLG(1) TYPE C,
          PHSEQ(2) TYPE C,
          ARBPL(8) TYPE C,
          STEUS(4) TYPE C,
          BMSCH(13) TYPE C,
          MEINH(3) TYPE C,
          VGW01(9) TYPE C,
          VGE01(3) TYPE C,
          VGW02(9) TYPE C,
          VGE02(3) TYPE C,
          VGW03(9) TYPE C,
          VGE03(3) TYPE C,
          VGW04(9) TYPE C,
          VGE04(3) TYPE C,
          VGW05(9) TYPE C,
          VGE05(3) TYPE C,
          VGW06(9) TYPE C,
          VGE06(3) TYPE C,
          LTXA1(40) TYPE C, "FOR CARPENTER
          EKORG(4) TYPE C,
          PLIFZ(3) TYPE C,
          MATKL(9) TYPE C,
          EKGRP(3) TYPE C,
          LIFNR(10) TYPE C,
          PEINH(5) TYPE C,
          PREIS(11) TYPE C,
          SAKTO(10) TYPE C,
          WAERS(5) TYPE C,
          ZSTAT(7) TYPE C ,
          ZDESC(150) TYPE C,
          FLAG(1) TYPE C,
        END OF IT_HMR.

DATA : BEGIN OF IT_DELHMR OCCURS 0,
          MATNR(18) TYPE C,
          MAT_WERKS(4) TYPE C,
          PLNTY(1) TYPE C,
          PLNNR(8) TYPE C,
          PLNAL(2) TYPE C,
          WERKS(4) TYPE C,
          STATU(10) TYPE C,
          VERWE(3) TYPE C,
          FLG_RESET(1) TYPE C,
          FLG_CHECK(1) TYPE C,
          FLG_PROT(1) TYPE C,
          ZSTAT(7) TYPE C ,
          ZDESC(150) TYPE C,
       END OF IT_DELHMR.

DATA : IT_IMR LIKE TABLE OF IT_HMR WITH HEADER LINE.
DATA : IT_DELIMR LIKE TABLE OF IT_DELHMR WITH HEADER LINE.

DATA : COUNTER TYPE I VALUE '1',
       N(3),
       DD      TYPE C LENGTH 2,
       MM      TYPE C LENGTH 2,
       YYYY    TYPE C LENGTH 4,
       DATE    TYPE C LENGTH 8,
       EKS(3)  TYPE C,
       VCURSOR TYPE C LENGTH 20,
      VCURSOR2 TYPE C LENGTH 20.

"DATA FOR BDC
DATA : IT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
       IT_BDCMSGCOLL LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

DATA  : P_FILE  TYPE STRING,
        FNAME   TYPE STRING,
        FPATH   TYPE IBIPPARMS-PATH,
        ZFPATH  TYPE STRING,
        OPT     LIKE CTU_PARAMS.


DATA : RCH(1) TYPE C,
       RCR(1) TYPE C,
       CSR(1) TYPE C,
       CCR(1) TYPE C,
       RB1(1) TYPE C,
       RB2(1) TYPE C,
       RB3(1) TYPE C.

CONSTANTS : CPHFLG(11) TYPE C VALUE 'PLPOD-PHFLG',
            CPVZNR(11) TYPE C VALUE 'PLPOD-PVZNR',
            CPHSEQ(11) TYPE C VALUE 'PLPOD-PHSEQ',
            CARBPL(11) TYPE C VALUE 'PLPOD-ARBPL',
            CSTEUS(11) TYPE C VALUE 'PLPOD-STEUS',
            CLTXA1(11) TYPE C VALUE 'PLPOD-LTXA1',
            CBMSCH(11) TYPE C VALUE 'PLPOD-BMSCH',
            CMEINH(11) TYPE C VALUE 'PLPOD-MEINH',
            CVGW01(11) TYPE C VALUE 'PLPOD-VGW01',
            CVGE01(11) TYPE C VALUE 'PLPOD-VGE01',
            CVGW02(11) TYPE C VALUE 'PLPOD-VGW02',
            CVGE02(11) TYPE C VALUE 'PLPOD-VGE02',
            CVGW03(11) TYPE C VALUE 'PLPOD-VGW03',
            CVGE03(11) TYPE C VALUE 'PLPOD-VGE03',
            CVGW04(11) TYPE C VALUE 'PLPOD-VGW04',
            CVGE04(11) TYPE C VALUE 'PLPOD-VGE04',
            CVGW05(11) TYPE C VALUE 'PLPOD-VGW05',
            CVGE05(11) TYPE C VALUE 'PLPOD-VGE05',
            CVGW06(11) TYPE C VALUE 'PLPOD-VGW06',
            CVGE06(11) TYPE C VALUE 'PLPOD-VGE06'
            .

DATA      : VPHFLG(15) TYPE C ,
            VPVZNR(15) TYPE C ,
            VPHSEQ(15) TYPE C ,
            VARBPL(15) TYPE C ,
            VSTEUS(15) TYPE C ,
            VLTXA1(15) TYPE C ,
            VBMSCH(15) TYPE C ,
            VMEINH(15) TYPE C ,
            VVGW01(15) TYPE C ,
            VVGE01(15) TYPE C ,
            VVGW02(15) TYPE C ,
            VVGE02(15) TYPE C ,
            VVGW03(15) TYPE C ,
            VVGE03(15) TYPE C ,
            VVGW04(15) TYPE C ,
            VVGE04(15) TYPE C ,
            VVGW05(15) TYPE C ,
            VVGE05(15) TYPE C ,
            VVGW06(15) TYPE C ,
            VVGE06(15) TYPE C
            .

DATA: BEGIN OF IT_DETAIL OCCURS 0,
        MATNR(18) TYPE C,
        WERKS(4)  TYPE C,
        PLNAL(2)  TYPE C,
        VORNR(4)  TYPE C,
        PVZNR(4)  TYPE C,
        PHFLG(1)  TYPE C,
        PHSEQ(2)  TYPE C,
        ARBPL(8)  TYPE C,
        STEUS(4)  TYPE C,
        BMSCH(16) TYPE C,
        MEINH(3)  TYPE C,
        VGW01(9)  TYPE C,
        VGE01(3)  TYPE C,
        VGW02(9)  TYPE C,
        VGE02(3)  TYPE C,
        VGW03(9)  TYPE C,
        VGE03(3)  TYPE C,
        VGW04(9)  TYPE C,
        VGE04(3)  TYPE C,
        VGW05(9)  TYPE C,
        VGE05(3)  TYPE C,
        VGW06(9)  TYPE C,
        VGE06(3)  TYPE C,
        LTXA1(40) TYPE C,
        EKORG(4)  TYPE C,
        MATKL(9)  TYPE C,
        EKGRP(3)  TYPE C,
        LIFNR(10) TYPE C,
        PEINH(8)  TYPE C,
        PREIS(16) TYPE C,
        SAKTO(10) TYPE C,
        WAERS(5)  TYPE C,
        NEWOP(1)  TYPE C,
     END OF IT_DETAIL.

DATA : ITTEMP LIKE TABLE OF IT_HMR WITH HEADER LINE,
       VLINE TYPE I,
       VPLNNR TYPE PLKO-PLNNR,
       IT_DETAIL2 LIKE IT_DETAIL OCCURS 0 WITH HEADER LINE.