*&---------------------------------------------------------------------*
*&  Include           ZPPC_UP_BOM_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZPPI_UPLOAD_BOM_TOP                               Report ZPPI_UPLOAD_BOM
*&
*&---------------------------------------------------------------------*

REPORT   ZPPC_UP_BOM_.

CONSTANTS : GCF_E1(4) TYPE C VALUE '@0A@',
            GCF_S1(4) TYPE C VALUE '@08@'.

DATA : BEGIN OF IT_HBOM OCCURS 0,
        MATNR(18) TYPE C,
        WERKS(4) TYPE C,
        STLAN(1) TYPE C,
        STLAL(2) TYPE C,
        DATUV(10) TYPE C,
        ZTEXT(40) TYPE C,
        BMENG(13) TYPE C,
        IDNRK(18) TYPE C,
        MENGE(13) TYPE C,
        MEINS(3) TYPE C,
        LGORT(4) TYPE C,
        REKRS(1) TYPE C,
        ZSTAT(4) TYPE C ,
        ZDESC(50) TYPE C,
        FLAG(1) TYPE C,
       END OF IT_HBOM.

DATA :IT_IBOM LIKE TABLE OF IT_HBOM WITH HEADER LINE,
      WA_BOM LIKE LINE OF IT_HBOM.


DATA : COUNTER TYPE I VALUE '1',
       N(3),
       DD      TYPE C LENGTH 2,
       MM      TYPE C LENGTH 2,
       YYYY    TYPE C LENGTH 4,
       DATE    TYPE C LENGTH 8,
       EKS(3)  TYPE C.

"DATA FOR BDC
DATA : IT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
       IT_BDCMSGCOLL LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

DATA: CTUMODE LIKE CTU_PARAMS-DISMODE, "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
      CUPDATE LIKE CTU_PARAMS-UPDMODE, "S: synchronously "A: asynchronously "L: local
      OPT     LIKE CTU_PARAMS.

DATA  : P_FILE  TYPE STRING,
        FNAME   TYPE STRING,
        FPATH   TYPE IBIPPARMS-PATH.

CONSTANTS : CIDNRK(11) TYPE C VALUE 'RC29P-IDNRK',
            CMENGE(11) TYPE C VALUE 'RC29P-MENGE',
            CMEINS(11) TYPE C VALUE 'RC29P-MEINS',
            CPOSTP(11) TYPE C VALUE 'RC29P-POSTP'.

DATA : VIDNRK(15) TYPE C ,
       VMENGE(15) TYPE C ,
       VMEINS(15) TYPE C ,
       VPOSTP(15) TYPE C .

DATA : CR(1) TYPE C,
       CH(1) TYPE C.

DATA : POSNR TYPE RC29P-POSNR,
         IPOSNR TYPE I,
         VLINE TYPE I,
         ITTEMP LIKE TABLE OF IT_IBOM WITH HEADER LINE,
         VMATNR TYPE MAST-MATNR.

"-DATA FOR BAPI
DATA : T_STPO TYPE TABLE OF STPO_API02 WITH HEADER LINE,
       MATERIAL     TYPE CSAP_MBOM-MATNR,
       PLANT        TYPE CSAP_MBOM-WERKS,
       BOM_USAGE    TYPE CSAP_MBOM-STLAN,
       ALTERNATIVE  TYPE CSAP_MBOM-STLAL,
       V_COMP TYPE I.

DATA  IS_CLOSE(1) TYPE C.