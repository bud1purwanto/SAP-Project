ENHANCEMENT 1  .

**********************************************************
*** Created by: Yulius
*** Created on: 30.06.2016
*** Usage: Mengecek konsistensi anatara qty order dengan
***        qty characteristic
***********************************************************

DATA : IT_CHAR LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
       ZWEIGHT TYPE P DECIMALS 3,
       ZWEIGHT2 TYPE STRING,
       ZROLL TYPE ATWTB,
       ZSATUAN(5) TYPE C,
       ZCONVERSIONROLLKG TYPE ATWTB,
       ZTOTALM2 TYPE ATWTB,
       ZORDERQTY TYPE ATWTB,
       ZMSG1(100) TYPE C,
       ZMSG2(100) TYPE C,
       ZMSG3(100) TYPE C,
       ZITEM(3) TYPE C,
       ZTEMP TYPE P DECIMALS 2,
       IT_BASEUNIT TYPE T006 OCCURS 0.

IF SY-TCODE = 'VA01' OR SY-TCODE = 'VA02' OR SY-TCODE = 'VA21' OR SY-TCODE = 'VA22'.
  IF VBAK-AUART NE 'ZDCD' AND VBAK-AUART NE 'ZECD' AND
     VBAK-AUART NE 'ZDCM' AND VBAK-AUART NE 'ZECM' AND
     VBAK-AUART NE 'ZDKE' AND VBAK-AUART NE 'ZDKE' AND
     VBAK-AUART NE 'ZDKP' AND VBAK-AUART NE 'ZDKP' AND
     VBAK-AUART NE 'ZDKR' AND VBAK-AUART NE 'ZDKR'.

LOOP AT XVBAP WHERE UPDKZ NE 'D'.
    CLEAR : IT_CHAR,ZROLL,ZSATUAN,ZCONVERSIONROLLKG,ZTOTALM2.
    REFRESH : IT_CHAR.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE                   = XVBAP-CUOBJ
     TABLES
       CONFIGURATION               = IT_CHAR
     EXCEPTIONS
       INSTANCE_NOT_FOUND          = 1
       INTERNAL_ERROR              = 2
       NO_CLASS_ALLOCATION         = 3
       INSTANCE_NOT_VALID          = 4
       OTHERS                      = 5
              .
    IF SY-SUBRC = 0.
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZROLL ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZROLL WITH SPACE.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZCONVERSIONROLLKG ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZCONVERSIONROLLKG WITH SPACE.

    CASE XVBAP-VRKME.
      WHEN 'KG'.
        ZWEIGHT = ZROLL * ZCONVERSIONROLLKG.
     WHEN 'ROL'.
        ZWEIGHT = ZROLL * 1000.
      WHEN 'M2'.
        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTOTALM2'.
        SPLIT IT_CHAR-ATWTB AT SPACE INTO ZTOTALM2 ZSATUAN.
        REPLACE ALL OCCURRENCES OF ',' IN ZTOTALM2 WITH SPACE.
        ZTEMP = ZTOTALM2.

        CALL FUNCTION 'ROUND'
          EXPORTING
           DECIMALS            = 3
            INPUT               = ZTEMP
           SIGN                = '+'
         IMPORTING
          OUTPUT              = ZWEIGHT.
    WHEN 'LB'.
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZORDERQTY'.
      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZORDERQTY ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZORDERQTY WITH SPACE.
      ZWEIGHT = ZORDERQTY * ZROLL.
    WHEN OTHERS.
      ZWEIGHT = XVBAP-KWMENG.
    ENDCASE.

      IF XVBAP-KWMENG <> ZWEIGHT.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT         = XVBAP-POSNR
         IMPORTING
           OUTPUT        = ZITEM.

        ZWEIGHT2 = ZWEIGHT.
        ZSATUAN = XVBAP-VRKME.
          CONCATENATE 'Kolom Order Quantity untuk item' ZITEM 'Berbeda dengan Characteristic' INTO ZMSG1 SEPARATED BY SPACE.
          CONCATENATE 'Jumlah total order quantity yang benar' ZWEIGHT2 XVBAP-VRKME INTO ZMSG2 SEPARATED BY SPACE.
          CONCATENATE 'Please correct item' ZITEM INTO ZMSG3 SEPARATED BY SPACE.

          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
        EXPORTING
*         TITEL        = ' '
          TEXTLINE1    = ZMSG1
          TEXTLINE2    = ZMSG2
*          TEXTLINE3    = ZMSG3
          START_COLUMN = 35.


          FCODE = 'ENT1'.
          MESSAGE ZMSG3 TYPE 'E'.

        ENDIF.

    ENDIF.
ENDLOOP.
ENDIF.
ENDIF.


******************************************************
* Created by: PST_MONICA
* Created on: 31.08.2012
* Usage: Req. Type untuk Trading = kosong bukan KEL
******************************************************

IF XVBAK-AUART EQ 'ZDTR' OR XVBAK-AUART EQ 'ZETR'.
  LOOP AT XVBAP.
    IF XVBAP-BEDAE NE ' '.
      MESSAGE 'Field RqTy (Requirement Type) in tab Procurement Tab untuk transaksi Third Party harus kosong.' TYPE 'E'.
      XVBAP-BEDAE = ''.
      MODIFY XVBAP.
    ENDIF.
  ENDLOOP.
ENDIF.


**********************************************************
* Created by: J. Budi x Ryanhr
* Created on: 04.2023
* Usage: Validasi Tab Prod Line
**********************************************************

  TYPES: BEGIN OF T_TAB,
         VBELN        TYPE VBAP-VBELN,            "SO Number
         POSNR        TYPE VBAP-POSNR,            "SO Item
         ZDATE TYPE VBAP-ZDATE,
         ZLINE TYPE VBAP-ZLINE,
         END OF T_TAB.

   DATA: ITAB TYPE STANDARD TABLE OF T_TAB,
         WA_TAB LIKE LINE OF ITAB,
         IT_ZLINE TYPE STANDARD TABLE OF CAWN WITH HEADER LINE,
         V_PRODLINE LIKE CABN-ATINN.

  DATA: V_BUKRS LIKE T001K-BUKRS,
        V_MATKL LIKE MARA-MATKL.

  SELECT SINGLE ATINN INTO V_PRODLINE FROM CABN WHERE ATNAM = 'ZZPRODLINE'.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZLINE FROM CAWN WHERE ATINN EQ V_PRODLINE.

  LOOP AT XVBAP WHERE UPDKZ NE 'D'.
      IF VBAK-AUART EQ 'ZDOR' OR VBAK-AUART EQ 'ZEOR' OR VBAK-AUART EQ 'ZDKB' OR VBAK-AUART EQ 'ZEKB' OR VBAK-AUART EQ 'ZDSO' OR
         VBAK-AUART EQ 'ZESO' OR VBAK-AUART EQ 'ZINV' OR VBAK-AUART EQ 'ZDSD' OR VBAK-AUART EQ 'ZESD'.
         SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR EQ XVBAP-MATNR AND MATKL LIKE '3%'.
         IF SY-SUBRC EQ 0 AND XVBAP-ZDATE IS INITIAL AND XVBAP-ZLINE IS INITIAL .
           MESSAGE 'Tanggal dan Line produksi harus diisi' TYPE 'E'.
         ENDIF.
      ENDIF.

      IF XVBAP-ZDATE EQ 00000000 OR XVBAP-ZDATE EQ ' 0000000'.
        CLEAR XVBAP-ZDATE.
      ENDIF.

      "Check Firts Grade and Second Grade (Only first frade to check mapping)
      SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR EQ XVBAP-MATNR AND MATKL LIKE '3%'.
      IF SY-SUBRC EQ 0.
        IF XVBAP-MATNR+0(2) NE 'SR'.
          CLEAR: XVBAP-ZDATE, XVBAP-ZLINE.
          MODIFY XVBAP.
        ENDIF.
      ENDIF.

      "Validasi Inputan
      IF XVBAP-ZLINE IS NOT INITIAL.
        READ TABLE IT_ZLINE WITH KEY ATWRT = XVBAP-ZLINE.
        IF SY-SUBRC NE 0.
          MESSAGE 'Line produksi tidak sesuai' TYPE 'E'.
        ENDIF.
      ENDIF.

      IF XVBAP-ZDATE IS NOT INITIAL AND XVBAP-ZLINE IS INITIAL.
        MESSAGE 'Line produksi harus diisi bersamaan dengan tanggal' TYPE 'E'.
      ENDIF.

      IF XVBAP-ZDATE IS INITIAL AND XVBAP-ZLINE IS NOT INITIAL.
        MESSAGE 'Tanggal produksi harus diisi bersamaan dengan line' TYPE 'E'.
      ENDIF.

      IF XVBAP-ZDATE IS NOT INITIAL.
        IF VBAP-ZDATE+0(4) EQ 0000 AND VBAP-ZDATE+4(2) EQ 00.
          CONTINUE.
        ENDIF.

        CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
          EXPORTING
            DATE                            = XVBAP-ZDATE
         EXCEPTIONS
            PLAUSIBILITY_CHECK_FAILED       = 1.

        IF SY-SUBRC NE 0.
          MESSAGE 'Tanggal tidak valid' TYPE 'E'.
        ENDIF.

      ENDIF.
  ENDLOOP.

**********************************************************
* Created by: Fina Oktavia Manurung, edited by: PST_MONICA
* Created on: 31.08.2012
* Usage: Validasi Unit Price jika < VPRS
**********************************************************

DATA : V_KWERT LIKE KONV-KWERT,
       V_KWERT1 LIKE KONV-KWERT,
       V_ITEM LIKE VBAP-POSEX,
       V_TEMP TYPE STRING,
       V_TEXT TYPE STRING,
       Z_TEXT3 TYPE STRING,
       Z_TEMP TYPE STRING,
       COUNTER TYPE N,
       COUNTER1 TYPE N,
       ZMESSAGE TYPE STRING,
       Z_POSNR LIKE VBAP-POSNR,
       Z_POSNR1 LIKE VBAP-POSNR.

  COUNTER = 0.
  COUNTER1 = 0.

LOOP AT XVBAP WHERE UPDKZ NE 'D'.



  Z_POSNR = XVBAP-POSNR.

  LOOP AT XKOMV WHERE KSCHL EQ 'VPRS' AND
    KPOSN EQ Z_POSNR.

    IF SY-SUBRC = 0.
      V_KWERT = XKOMV-KWERT.
    ENDIF.

    LOOP AT XKOMV WHERE KPOSN EQ Z_POSNR AND
      ( KSCHL EQ 'ZD00' OR
      KSCHL EQ 'ZE00' ).

      IF SY-SUBRC = 0.
        V_KWERT1 = XKOMV-KWERT.
      ENDIF.
    ENDLOOP.


  ENDLOOP.

IF V_KWERT1 < V_KWERT.

   V_ITEM = XVBAP-POSNR.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT         = V_ITEM
   IMPORTING
      OUTPUT        = V_ITEM.

   CONCATENATE V_ITEM ',' INTO V_TEMP.
   CONCATENATE V_TEXT V_TEMP INTO V_TEXT SEPARATED BY SPACE.

   COUNTER = COUNTER + 1.

  ENDIF.
ENDLOOP.

IF COUNTER > 0.

  CONCATENATE 'PO line:' V_TEXT 'unit price lebih kecil dari VPRS' INTO ZMESSAGE SEPARATED BY SPACE.
  MESSAGE ZMESSAGE TYPE 'W'.

ENDIF.



************************************************
**             Validasi Route
************************************************
IF VBAK-AUART EQ 'ZEQT' OR VBAK-AUART EQ 'ZEOR'.
  LOOP AT XVBAP WHERE UPDKZ NE 'D'.
      IF XVBAP-ROUTE EQ ''.
      COUNTER1 = COUNTER1 + 1.
      Z_POSNR1 = XVBAP-POSNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT         = Z_POSNR1
    IMPORTING
      OUTPUT        = Z_POSNR1.


     CONCATENATE Z_POSNR1 ',' INTO Z_TEMP.

       CONCATENATE Z_TEXT3 Z_TEMP INTO Z_TEXT3 SEPARATED BY SPACE.

    ENDIF.

  ENDLOOP.

ENDIF.

IF COUNTER1 > 0.
  CONCATENATE 'Route line: ' Z_TEXT3 'belum diisi' INTO Z_TEMP SEPARATED BY SPACE.
  MESSAGE Z_TEMP TYPE 'W'.
ENDIF.


**********************************************************
*** Created by: PST_MONICA
*** Created on: 17.09.2012
*** Usage: Mengganti nilai Denominator & Nominator, dan
***        update net weight & gross weight
***********************************************************

DATA:
     ZINSTANCE LIKE INOB-CUOBJ,
     ZCUOBJ LIKE VBAP-CUOBJ,
     ZVBELN2 LIKE VBAK-VBELN,
     ZKGPERROL TYPE STRING,
     ZPENYEBUT TYPE STRING,
     ZPEMBILANG TYPE STRING,
     ZTOTALWEIGHT TYPE ATWTB,"  TYPE STRING,
     ZKGPERPACK TYPE STRING,
     ZNUMBEROFPACK TYPE STRING,
     Z_TEXT1(30) ,
     Z_TEXT2(30),
     Z_WEIGHT(30),
     Z_WEIGHT1 LIKE VBAP-NTGEW,
     Z_WEIGHT2 TYPE P LENGTH 13 DECIMALS 4,
     Z_TOTAL TYPE P LENGTH 15 DECIMALS 3,
     Z_CONPAC TYPE P LENGTH 8 DECIMALS 3,
     Z_NUM   TYPE N LENGTH 15,
     V_CONV TYPE F,
     V_CONV1 TYPE F,
     Z_NOMIN LIKE CALE-ABSDATE,
     Z_DENOM LIKE CALE-ABSDATE,
     Z_KWMENG LIKE VBAP-KWMENG,
     Z_UMVKN LIKE VBAP-UMVKN,
     Z_UMVKZ LIKE VBAP-UMVKZ,
     ZCOMMA TYPE STRING,
     ZCOMMA1 TYPE STRING,
     ZCOUNTRSTR TYPE P,
     "ADDED BY FATHIR ON 11.06.2020
     " variabel untuk error message userexit Create/Change SO
     ZMSG TYPE STRING,    " message
     ZPOSNR(5).           " SO item

DATA : IT_TEMP LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
       LEN TYPE I,
       V_RIB TYPE STRING,
       V_PUL TYPE STRING.


LOOP AT XVBAP WHERE UPDKZ NE 'D'.

  IF XVBAP-VRKME EQ 'ROL' OR
    XVBAP-VRKME EQ 'M2' OR
    XVBAP-VRKME EQ 'PAK' OR
    XVBAP-VRKME EQ 'LB'.

    CLEAR ZCUOBJ.
    CLEAR IT_TEMP.
    REFRESH IT_TEMP.

    ZCUOBJ = XVBAP-CUOBJ.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE                      = ZCUOBJ
*         BUSINESS_OBJECT             =
*          LANGUAGE                   = SY-LANGU
*         PRINT_SALES                 = ' '
*         PRINT_PURCHASE              = ' '
*         PRINT_ENGINEERING           = ' '
*         IDOC_MODE                   = ' '
*         ANW_SICHT                   = ' '
*         EXCL_IND                    = ' '
*         IV_INVALID_POSSIBLE         = ' '
*         IV_MAX_MASSPROCESSING       = 0
*         IV_EXPLICIT_ORGAREA         = ' '
*         IV_NO_DESCRIPTION           = ' '
*         IV_USER                     = ' '
*         IV_NO_VALUE_CHECK           = 'X'
*         IV_NO_DIALOG                = ' '
*         IV_DISPLAY_WARNING          = ' '
*         MILL_SE_RECALC              =
*         MILL_SE_EVAL_DK             =
*       IMPORTING
*         /SAPMP/CONF_RECORD          =
     TABLES
       CONFIGURATION               = IT_TEMP
*         CONFIGURATION_IDOC          =
*       CHANGING
*         MILL_SE_FATTR               =
     EXCEPTIONS
       INSTANCE_NOT_FOUND          = 1
       INTERNAL_ERROR              = 2
       NO_CLASS_ALLOCATION         = 3
       INSTANCE_NOT_VALID          = 4
       OTHERS                      = 5
              .
    IF SY-SUBRC <> 0.
       CONTINUE.
* Implement suitable error handling here
    ENDIF.

  IF XVBAP-VRKME EQ 'ROL' OR XVBAP-VRKME EQ 'PAK'.

    "- ROL
    IF XVBAP-VRKME EQ 'ROL'.

      "- Penyebut
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPENYEBUTBARU'.
    IF SY-SUBRC = 0.
    ENDIF.

    ZPENYEBUT = IT_TEMP-ATWRT.

    IF ZPENYEBUT NE ''.
      SPLIT ZPENYEBUT AT SPACE INTO ZPENYEBUT Z_TEXT1.

      DATA : USR01_EXP LIKE USR01.
      DATA : RIBUAN   TYPE C,
             PULUHAN  TYPE C,
             VPUL     TYPE STRING,
             VRIB     TYPE STRING.

      CLEAR : USR01_EXP, RIBUAN, PULUHAN.
      CALL FUNCTION 'CETA_USR01_READ'
        EXPORTING
          BNAME     = SY-UNAME
        IMPORTING
          USR01_EXP = USR01_EXP
        EXCEPTIONS
          NO_ENTRY  = 1
          OTHERS    = 2.

      IF USR01_EXP-DCPFM EQ ''.
        RIBUAN  = '.'.
        PULUHAN = ','.
      ELSEIF USR01_EXP-DCPFM EQ 'X'.
        RIBUAN  = ','.
        PULUHAN = '.'.
      ELSEIF USR01_EXP-DCPFM EQ 'Y'.
        RIBUAN  = SPACE.
        PULUHAN = ','.
      ENDIF.

      REPLACE RIBUAN WITH '' INTO ZPENYEBUT.
      CONDENSE ZPENYEBUT NO-GAPS.

    ENDIF.

    "- Pembilang
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZPEMBILANGBARU'.
    IF SY-SUBRC = 0.
    ENDIF.

    ZPEMBILANG = IT_TEMP-ATWRT.

    IF ZPEMBILANG NE ''.
    SPLIT ZPEMBILANG AT SPACE INTO ZPEMBILANG Z_TEXT2.

      CLEAR : USR01_EXP, RIBUAN, PULUHAN.
      CALL FUNCTION 'CETA_USR01_READ'
        EXPORTING
          BNAME     = SY-UNAME
        IMPORTING
          USR01_EXP = USR01_EXP
        EXCEPTIONS
          NO_ENTRY  = 1
          OTHERS    = 2.

      IF USR01_EXP-DCPFM EQ ''.
        RIBUAN  = '.'.
        PULUHAN = ','.
      ELSEIF USR01_EXP-DCPFM EQ 'X'.
        RIBUAN  = ','.
        PULUHAN = '.'.
      ELSEIF USR01_EXP-DCPFM EQ 'Y'.
        RIBUAN  = SPACE.
        PULUHAN = ','.
      ENDIF.

      REPLACE RIBUAN WITH '' INTO ZPEMBILANG.
      CONDENSE ZPEMBILANG NO-GAPS.

    ENDIF.

    IF XVBAK-VBTYP NE 'K'.

      Z_KWMENG = XVBAP-KWMENG.
      XVBAP-UMVKN = ZPENYEBUT. "- Penyebut
      XVBAP-UMVKZ = ZPEMBILANG. "- Pembilang

    ELSE.
      "Credit Memo Request
      Z_KWMENG = XVBAP-ZMENG.
      XVBAP-UMZIN = ZPENYEBUT.
      XVBAP-UMZIZ = ZPEMBILANG.

    ENDIF.

      Z_UMVKN = ZPENYEBUT.
      Z_UMVKZ = ZPEMBILANG.


      Z_KWMENG = Z_KWMENG * Z_UMVKZ / Z_UMVKN.

    "- Pack
    ELSEIF XVBAP-VRKME EQ 'PAK'.

      "- Kg per Pack
      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
      IF SY-SUBRC = 0.
      ENDIF.

      ZKGPERPACK = IT_TEMP-ATWRT.

      CLEAR: Z_TEXT2.
      IF ZKGPERPACK NE ''.
        SPLIT ZKGPERPACK AT SPACE INTO ZKGPERPACK Z_TEXT2.

        CLEAR : USR01_EXP, RIBUAN, PULUHAN.
        CALL FUNCTION 'CETA_USR01_READ'
          EXPORTING
            BNAME     = SY-UNAME
          IMPORTING
            USR01_EXP = USR01_EXP
          EXCEPTIONS
            NO_ENTRY  = 1
          OTHERS    = 2.

        IF USR01_EXP-DCPFM EQ ''.
          RIBUAN  = '.'.
          PULUHAN = ','.
        ELSEIF USR01_EXP-DCPFM EQ 'X'.
          RIBUAN  = ','.
          PULUHAN = '.'.
        ELSEIF USR01_EXP-DCPFM EQ 'Y'.
          RIBUAN  = SPACE.
          PULUHAN = ','.
        ENDIF.

        REPLACE RIBUAN WITH '' INTO ZKGPERPACK.
        CONDENSE ZKGPERPACK NO-GAPS.
      ENDIF.

      DATA: ZDENOMIN TYPE F,
            ZNOMIN TYPE F,
            ZDENOMOUT LIKE CALE-ABSDATE,
            ZNOMOUT LIKE CALE-ABSDATE.

      ZNOMIN = 1.
      ZDENOMIN = ZKGPERPACK.

      CALL FUNCTION 'CONVERT_TO_FRACT5'
        EXPORTING
          NOMIN                     = ZNOMIN
          DENOMIN                   = ZDENOMIN
       IMPORTING
         NOMOUT                    = ZNOMOUT
         DENOMOUT                  = ZDENOMOUT
       EXCEPTIONS
         CONVERSION_OVERFLOW       = 1
         OTHERS                    = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      ZPENYEBUT = ZNOMOUT.
      ZPEMBILANG = ZDENOMOUT.

      IF XVBAK-VBTYP NE 'K'.
        Z_KWMENG = XVBAP-KWMENG.
        XVBAP-UMVKN = ZPENYEBUT. "- Penyebut
        XVBAP-UMVKZ = ZPEMBILANG. "- Pembilang
      ELSE.
        Z_KWMENG = XVBAP-ZMENG.
        XVBAP-UMZIN = ZPENYEBUT.
        XVBAP-UMZIZ = ZPEMBILANG.
      ENDIF.

*      "- Jumlah Pack
*      READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZNUMOFPACK'.
*      IF SY-SUBRC = 0.
*      ENDIF.
*
*      ZNUMBEROFPACK = IT_TEMP-ATWRT.

      Z_UMVKN = ZPENYEBUT.
      Z_UMVKZ = ZPEMBILANG.

      Z_KWMENG = Z_KWMENG * Z_UMVKZ / Z_UMVKN.

*      ZNUMBEROFPACK = Z_KWMENG.
*
*      Z_KWMENG = ZKGPERPACK * ZNUMBEROFPACK.

    ENDIF.


    CALL FUNCTION 'ROUND'
      EXPORTING
          DECIMALS            = 2
          INPUT               = Z_KWMENG
          SIGN                = '+'
      IMPORTING
          OUTPUT              = Z_KWMENG
      EXCEPTIONS
          INPUT_INVALID       = 1
          OVERFLOW            = 2
          TYPE_INVALID        = 3
      OTHERS              = 4
          .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

     XVBAP-NTGEW = Z_KWMENG.
     XVBAP-BRGEW = Z_KWMENG.

  " UoM M2 & LB
  ELSEIF XVBAP-VRKME EQ 'M2' OR
    XVBAP-VRKME EQ 'LB'.

    IF XVBAK-VBTYP NE 'K'.

  "- Weight dari Karakteristik
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
    IF SY-SUBRC = 0.
    ENDIF.

    ZTOTALWEIGHT = IT_TEMP-ATWTB.

    IF ZTOTALWEIGHT NE ''.

      SPLIT ZTOTALWEIGHT AT SPACE INTO ZTOTALWEIGHT Z_TEXT2.

      CLEAR : USR01_EXP, RIBUAN, PULUHAN.
      CALL FUNCTION 'CETA_USR01_READ'
        EXPORTING
          BNAME     = SY-UNAME
        IMPORTING
          USR01_EXP = USR01_EXP
        EXCEPTIONS
          NO_ENTRY  = 1
          OTHERS    = 2.

      IF USR01_EXP-DCPFM EQ ''.
        RIBUAN  = '.'.
        PULUHAN = ','.
      ELSEIF USR01_EXP-DCPFM EQ 'X'.
        RIBUAN  = ','.
        PULUHAN = '.'.
      ELSEIF USR01_EXP-DCPFM EQ 'Y'.
        RIBUAN  = SPACE.
        PULUHAN = ','.
      ENDIF.

      REPLACE RIBUAN WITH '' INTO ZTOTALWEIGHT.
      CONDENSE ZTOTALWEIGHT NO-GAPS.

      CLEAR: V_RIB, V_PUL, LEN.
      SPLIT ZTOTALWEIGHT AT PULUHAN INTO V_RIB V_PUL.
      LEN = STRLEN( V_PUL ).

      IF LEN = 1.
        CONCATENATE ZTOTALWEIGHT '00' INTO ZTOTALWEIGHT.
      ELSEIF LEN = 2.
        CONCATENATE ZTOTALWEIGHT '0' INTO ZTOTALWEIGHT.
      ENDIF.
*      CONCATENATE ZTOTALWEIGHT '0' INTO ZTOTALWEIGHT.
      CONDENSE ZTOTALWEIGHT NO-GAPS.

      Z_KWMENG = ZTOTALWEIGHT.

    ENDIF.

     XVBAP-NTGEW = Z_KWMENG.
     XVBAP-BRGEW = Z_KWMENG.

    ENDIF.

  ENDIF.

  MODIFY XVBAP.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDIF.

  "ADDED BY FATHIR ON 11.06.2020
  " Validasi Order Qty vs Net Weight
  IF SY-TCODE = 'VA01' OR
     SY-TCODE = 'VA02' OR
     SY-TCODE = 'ZVA02S' OR
     SY-TCODE = 'ZSD113' OR
     SY-TCODE = 'ZSD114' OR
     SY-TCODE = 'ZIC009'.

    IF XVBAP-VRKME NE 'KG'.   "ADDED BY FATHIR ON 26.08.2020 - skip validasi selain uom KG
      CONTINUE.
    ENDIF.

    "ADDED BY FATHIR ON 09.07.2020
    " validasi order qty vs net weight
    " di screen dengan kondisi nilai header XVBAK dikosongkan
    IF XVBAK-AUART EQ ''.

      " skip validasi jika target qty terisi
      IF XVBAP-ZMENG > 0.
      ELSE.

        IF XVBAP-KWMENG > 0.
          Z_KWMENG = XVBAP-KWMENG.  " order qty

          " validasi Order Qty (converted ke Kg) dengan Net Weight
          IF Z_KWMENG <> XVBAP-NTGEW.

            " convert output SO item
            " untuk kebutuhan Message
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                INPUT         = XVBAP-POSNR
              IMPORTING
                OUTPUT        = ZPOSNR.

            CONCATENATE 'Order Quantity and Net Weight are different! Check Item' ZPOSNR INTO ZMSG SEPARATED BY SPACE.
            MESSAGE ZMSG TYPE 'E' DISPLAY LIKE 'I'.
          ENDIF.
        ENDIF.

      ENDIF.
    ELSE.

      " validasi di screen utama (nilai header XVBAK terisi)
      IF XVBAK-AUART NE 'ZDCD' AND
         XVBAK-AUART NE 'ZDCM' AND
         XVBAK-AUART NE 'ZECD' AND
         XVBAK-AUART NE 'ZECM'.

        Z_KWMENG = XVBAP-KWMENG.  " order qty

        " bandingkan Order Qty (converted ke Kg) dengan Net Weight
        IF Z_KWMENG <> XVBAP-NTGEW.

          " convert output SO item
          " untuk kebutuhan Message
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT         = XVBAP-POSNR
            IMPORTING
              OUTPUT        = ZPOSNR.

          CONCATENATE 'Order Quantity and Net Weight are different! Check Item' ZPOSNR INTO ZMSG SEPARATED BY SPACE.
          MESSAGE ZMSG TYPE 'E' DISPLAY LIKE 'I'.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.
ENDLOOP.


ENDENHANCEMENT.
