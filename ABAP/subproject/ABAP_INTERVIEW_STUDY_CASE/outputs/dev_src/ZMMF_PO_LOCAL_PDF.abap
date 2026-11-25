*&---------------------------------------------------------------------*
*& Created by : Mualifi
*& Created on : 18-02-2013
*& Program    : ZMMF_PO_LOCAL_PDF
*& Desc.      : Print PO Local in PDF
*&              modify from ZMMF_PO_LOCAL
*&---------------------------------------------------------------------*
REPORT  ZMMF_PO_LOCAL_PDF.

TABLES : LFA1, EKKO, EKPO, ADRC, MAKT,
         NAST,                          "Messages
         *NAST,                         "Messages
         TNAPR,                         "Programs & Forms
         ITCPO,                         "Communicationarea for Spool
         ARC_PARAMS,                    "Archive parameters
         TOA_DARA,                      "Archive parameters
         ADDR_KEY,                      "Adressnumber for ADDRESS
         T001W,
         T001L,
         *TNAPR,
         THEAD.                                             "#EC NEEDED

"-CHANGE DOCUMENT
TYPES : BEGIN OF TYREV,
          NOPO TYPE CDOBJECTV,
          NODOC TYPE CDCHANGENR,
          UDATE LIKE CDHDR-UDATE,
          FNAME TYPE FDNAME,
          FLAG(1) TYPE C,
        END OF TYREV.

DATA: BEGIN OF I_TLINE OCCURS 0.
        INCLUDE STRUCTURE TLINE.
DATA: END OF I_TLINE.

DATA : BEGIN OF IT_PO OCCURS 0,
          EBELN LIKE EKKO-EBELN,
          EBELP LIKE EKPO-EBELP,
          EKORG LIKE EKKO-EKORG,
          WAERS LIKE EKKO-WAERS,
          LIFNR LIKE EKKO-LIFNR,
          KNUMV LIKE EKKO-KNUMV,
          AEDAT LIKE EKKO-AEDAT,
          ZTERM LIKE EKKO-ZTERM,
          TEXT1 LIKE T052U-TEXT1,
          MENGE LIKE EKPO-MENGE,
          MEINS LIKE EKPO-MEINS,
          MATNR LIKE EKPO-MATNR,
          TXZ01 LIKE EKPO-TXZ01,
          WERKS LIKE EKPO-WERKS,
          LGORT LIKE EKPO-LGORT,
          BEDNR LIKE EKPO-BEDNR,
          BANFN LIKE EKPO-BANFN,
          MWSKZ LIKE EKPO-MWSKZ,
          BSART LIKE EKKO-BSART,
          VERKF LIKE EKKO-VERKF,
          EKGRP LIKE EKKO-EKGRP,
          PEINH LIKE EKPO-PEINH,
          BPRME LIKE EKPO-BPRME,
          CHARG LIKE EKET-CHARG,
       END OF IT_PO.

DATA : BEGIN OF IT_EKET OCCURS 0,
 EBELN LIKE EKET-EBELN,
 EBELP LIKE EKET-EBELP,
 EINDT LIKE EKET-EINDT,
END OF IT_EKET.

DATA : BEGIN OF IT_KONV OCCURS 0,
    KNUMV LIKE KONV-KNUMV,
    KPOSN LIKE KONV-KPOSN,
    KSCHL LIKE KONV-KSCHL,
    KBETR LIKE KONV-KBETR,
    KWERT LIKE KONV-KWERT,
    WAERS LIKE KONV-WAERS,
    NETPR LIKE EKPO-NETPR,
    NETWR LIKE EKPO-NETWR,
    DISC1 LIKE KONV-KBETR,    "ADD BY JALU 06.02.2013
    DISC2 LIKE KONV-KBETR,    "ADD BY JALU 06.02.2013
    BEDAT LIKE EKKO-BEDAT,    "ADD BY JARWO 19.03.2018
END OF IT_KONV.

DATA : BEGIN OF IT_ADD_LAST OCCURS 0,
     CHARG LIKE EKET-CHARG,
     MATNR LIKE EKPO-MATNR,
     EBELP LIKE EKPO-EBELP,
     EBELN LIKE EKPO-EBELN,
     MEINS LIKE EKPO-MEINS,
     KNUMV LIKE EKKO-KNUMV,
     LIFNR LIKE EKKO-LIFNR,
    END OF IT_ADD_LAST.

DATA: BEGIN OF IT_DELV OCCURS 0.
        INCLUDE STRUCTURE EKET.
DATA: END OF IT_DELV.

DATA : IT_LAST_PO LIKE IT_PO OCCURS 0 WITH HEADER LINE,
       IT_LAST_PO1 LIKE IT_PO OCCURS 0 WITH HEADER LINE,
       I_LINES  LIKE TLINE  OCCURS 0 WITH HEADER LINE,
       WA_LINES LIKE TLINE,
*- add WITH HEADER LINE
       IT_HTEXT TYPE TABLE OF ZMMSTRTDLINE WITH HEADER LINE,      "CHANGED BY FATHIR 06.11.2018
       ITHREV TYPE TABLE OF TYREV WITH HEADER LINE,
       ITIREV TYPE TABLE OF TYREV WITH HEADER LINE,
       IT_KONV_LAST LIKE IT_KONV OCCURS 0 WITH HEADER LINE,
       I_ZPO_LOCAL LIKE  ZPO_LOCAL OCCURS 0 WITH HEADER LINE.

DATA : V_TDNAME LIKE THEAD-TDNAME,
       WA_HTEXT TYPE ZMMSTRTDLINE,
       WAREV    TYPE TYREV,
       REV      TYPE I,
       V_REV(30),
       I_SSFCOMPOP TYPE SSFCOMPOP,
       I_SSFCTRLOP TYPE SSFCTRLOP,
       I_RECIPIENT TYPE SWOTOBJID,
       I_SENDER    TYPE SWOTOBJID,
       I_ADDR_KEY  LIKE ADDR_KEY,
       V_FORMNAME  TYPE TDSFNAME  VALUE 'ZMMF_PO_LOCAL_PDF',
       V_FUNCNAME  TYPE RS38L_FNAM,
       RETCODE    LIKE SY-SUBRC,
       REPEAT(1)  TYPE C,
       XSCREEN(1) TYPE C,
       P_VENDOR   TYPE CHAR35,    "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
       P_VENDOR2  TYPE CHAR35,    "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
       P_ADDRESS  TYPE CHAR50,
       P_ORT01    TYPE LFA1-ORT01,
       P_PSTLZ    TYPE LFA1-PSTLZ,
       P_CITY     TYPE CHAR50,
       P_TELP     TYPE CHAR15,
       P_FAX      TYPE CHAR15,
       P_WERKS         TYPE  CHAR04,
       P_NAME_WERKS    TYPE  CHAR20,
       P_ADDRESS_PLANT TYPE  CHAR30,
       P_CITY_PLANT    TYPE  CHAR15,
       P_ADRNR         TYPE T001W-ADRNR,
       P_CITY1         TYPE ADRC-CITY1,
       P_POST_CODE1    TYPE ADRC-POST_CODE1,
       P_LGORT      TYPE CHAR05,
       P_LGORT_TEXT TYPE CHAR35,
       P_EBELN    TYPE CHAR10,
       P_DATE_PO  TYPE CHAR10,
       P_DATE_PRT TYPE CHAR10,
       P_DATE_PAY TYPE CHAR25,
       P_SUBTOTAL TYPE CHAR15,
       P_DISCOUNT TYPE CHAR15,
       P_TAX      TYPE CHAR15,
       P_FREIGHT  TYPE CHAR15,
       P_TOTAL_ORDER TYPE CHAR15,
       P_LOOP(2)    TYPE N VALUE '12',
       C_FLAG(1)    VALUE 'X',
       V_DATUM_END LIKE SY-DATUM,
       P_TERM      TYPE CHAR80,
       V_BSART     LIKE EKKO-BSART,
       V_POTYPE(35),
       VBSART TYPE EKKO-BSART,
       P_COMPCODE TYPE CHAR4.

DATA   :   P_EKNAM LIKE T024-EKNAM.   "contact person
DATA: V_PPN_PRC LIKE KONP-KBETR.

RANGES : R_KSCHL FOR KONV-KSCHL,
         R_DATE  FOR SY-DATUM.

DATA: IS_SAME_OTYPE(1).      "tidak boleh reprint dengan output beda

"ADDED BY FATHIR 01.11.2018
*- Add variable for converting ITF to STREAM_TEXT purpose
DATA :WA_UNCONVERTEDTEXT(320).
DATA :V_TEXTCONTAINER(320).

DATA: IT_CONVLINES TYPE TLINE OCCURS 0 WITH HEADER LINE.
DATA: IT_TEXTTEMP(132) OCCURS 0.
DATA: WA_TEXTTEMP(320).
*-----------------------------------------------
*&---------------------------------------------------------------------*
*&  Include           ZMMF_PO_LOCAL_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  entry_neu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*----------------------------------------------------------------------*
FORM ENTRY_NEU USING ENT_RETCO ENT_SCREEN.
  PERFORM CEK_OUTPUT_TYPE.
  IF IS_SAME_OTYPE NE 'X'.
    CLEAR RETCODE.
    XSCREEN = ENT_SCREEN.
    PERFORM F_PROCESSING.
    IF RETCODE NE 0.
      ENT_RETCO = 1.
    ELSE.
      ENT_RETCO = 0.
    ENDIF.
  ENDIF.  "cek output type
ENDFORM.                    "entry_neu

*&---------------------------------------------------------------------*
*&      Form  f_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PROCESSING .

  PERFORM F_SELECT_DATA.

  READ TABLE IT_PO INDEX 1.

  PERFORM F_FIND_DATA_VENDOR.

  PERFORM F_FIND_DATA_PLANT.

  PERFORM F_FIND_DATA_SLOC.

  PERFORM F_FIND_DATA_PO_NO.

  PERFORM F_ADDITIONAL_DATA.

  PERFORM F_FIND_ITEM_DATA.

  PERFORM F_GET_INFORECORD.   "case of subcont

  PERFORM F_PO_RETURN.        "case of po return

  PERFORM ADD_DESCRIPTION.    "add by Yulius 09-11-15

*  PERFORM F_CALL_SMARTFORMS.
  PERFORM TO_PDF.

ENDFORM.                    " f_processing
*&---------------------------------------------------------------------*
*&      Form  f_find_data_vendor
*&---------------------------------------------------------------------*
*       text

*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_VENDOR.
  DATA : VKTOKK LIKE LFA1-KTOKK,
         VHNUM LIKE ADRC-HOUSE_NUM1.

  SELECT SINGLE LFA1~NAME1
    LFA1~NAME2                      "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
    LFA1~STRAS
    LFA1~ORT01
    LFA1~PSTLZ
    LFA1~TELF1
    LFA1~TELFX
    LFA1~KTOKK "EDIT BY JEFF
    INTO (P_VENDOR, P_VENDOR2,        "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
          P_ADDRESS,P_ORT01,P_PSTLZ,
          P_TELP,P_FAX , VKTOKK)
    FROM LFA1
    WHERE LIFNR = IT_PO-LIFNR.

  CONCATENATE P_ORT01 P_PSTLZ INTO P_CITY SEPARATED BY SPACE.
*  EDIT BY JEFF 04-01-2013******************
  IF VKTOKK = 'ZOTI'.
    SELECT SINGLE ADRC~NAME1 ADRC~NAME2 STREET "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
                  HOUSE_NUM1 CITY1 POST_CODE1 TEL_NUMBER FAX_NUMBER
      INTO (P_VENDOR, P_VENDOR2, P_ADDRESS, VHNUM,  "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
            P_ORT01, P_PSTLZ, P_TELP, P_FAX )
    FROM ADRC
      JOIN EKKO ON EKKO~ADRNR = ADRC~ADDRNUMBER
      JOIN LFA1 ON LFA1~LIFNR = EKKO~LIFNR
    WHERE EBELN = IT_PO-EBELN AND
          LFA1~LIFNR = IT_PO-LIFNR AND
          KTOKK = 'ZOTI'.

    IF P_VENDOR EQ '*'.
      CLEAR P_VENDOR.
    ENDIF.
    IF P_VENDOR2 EQ '*'.  "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
      CLEAR P_VENDOR2.
    ENDIF.
    IF P_ADDRESS EQ '*'.
      CLEAR P_ADDRESS.
    ENDIF.
    IF VHNUM EQ '*'.
      CLEAR VHNUM.
    ENDIF.
    IF P_ORT01 EQ '*'.
      CLEAR P_ORT01.
    ENDIF.
    IF P_PSTLZ EQ '*'.
      CLEAR P_PSTLZ.
    ENDIF.
    IF P_TELP EQ '*'.
      CLEAR P_TELP.
    ENDIF.
    IF P_FAX EQ '*'.
      CLEAR P_FAX.
    ENDIF.

    CONCATENATE P_ADDRESS VHNUM INTO P_ADDRESS SEPARATED BY SPACE.
    CONCATENATE P_ORT01 P_PSTLZ INTO P_CITY SEPARATED BY SPACE.
  ENDIF.
*  END EDIT BY JEFF 04-01-2013**************

ENDFORM.                    " f_find_data_vendor
*&---------------------------------------------------------------------*
*&      Form  f_find_data_plant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_PLANT .

  SELECT SINGLE T001W~NAME1
    T001W~ADRNR
    FROM T001W
    INTO (P_NAME_WERKS,P_ADRNR)
    WHERE WERKS = IT_PO-WERKS.
  WRITE IT_PO-WERKS TO P_WERKS.

  SELECT SINGLE ADRC~STREET
    ADRC~CITY1
    ADRC~POST_CODE1
    INTO (P_ADDRESS_PLANT, P_CITY1, P_POST_CODE1)
     FROM ADRC WHERE ADDRNUMBER = P_ADRNR.

  CONCATENATE P_CITY1 P_POST_CODE1 INTO P_CITY_PLANT SEPARATED BY SPACE.


ENDFORM.                    " f_find_data_plant
*&---------------------------------------------------------------------*
*&      Form  f_find_Data_sloc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_SLOC .

  CLEAR T001L.
  SELECT SINGLE T001L~LGOBE
    INTO P_LGORT_TEXT
    FROM T001L
    WHERE WERKS = IT_PO-WERKS AND
    LGORT = IT_PO-LGORT.

  WRITE IT_PO-LGORT TO P_LGORT.

ENDFORM.                    " f_find_Data_sloc
*&--------------------------------------------------------------------*
*&      Form  f_find_data_po_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_PO_NO .
  CLEAR: P_COMPCODE .
  SELECT SINGLE BUKRS FROM EKKO INTO (P_COMPCODE ) WHERE EBELN EQ IT_PO-EBELN. "add for new company

  WRITE IT_PO-EBELN TO P_EBELN.

  CONCATENATE IT_PO-AEDAT+6(2) '-' IT_PO-AEDAT+4(2) '-' IT_PO-AEDAT+0(4)
  INTO P_DATE_PO.

  CONCATENATE SY-DATUM+6(2) '-' SY-DATUM+4(2) '-' SY-DATUM+0(4)
  INTO P_DATE_PRT.

  P_DATE_PAY = IT_PO-TEXT1.

ENDFORM.                    " f_find_data_po_no

*&---------------------------------------------------------------------*
*&      Form  f_find_item_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_ITEM_DATA.

  DATA : LC_KBETR LIKE KONV-KWERT,
         LC_KBETR2 LIKE KONV-KWERT,   "ADD BY JALU 06.02.2013 - TAMBAH KONDISI SELAIN %
         LC_KWERT LIKE KONV-KWERT.


  DATA : LC_SUBTOTAL LIKE KONV-KWERT,
         LC_SUBDIC   LIKE KONV-KWERT.

  DATA : LC_BASE_AMOUNT LIKE KONV-KWERT.
  DATA : LC_TAX_AMOUNT  LIKE KONV-KWERT,
         LC_TOTAL_ORDER LIKE KONV-KWERT.

  REFRESH : I_ZPO_LOCAL.
  CLEAR : I_ZPO_LOCAL.

  PERFORM F_ADD_KSCHL.


  CLEAR :  LC_SUBTOTAL,
           LC_SUBDIC.

  SORT IT_PO BY EBELN EBELP.
  LOOP AT IT_PO.
    PERFORM F_GET_ITEM_TEXT USING IT_PO-EBELN IT_PO-EBELP
                            CHANGING I_ZPO_LOCAL-ZTEXT.

    WRITE IT_PO-EBELP  TO I_ZPO_LOCAL-ZNO.
    WRITE IT_PO-MENGE  TO I_ZPO_LOCAL-ZMENGE UNIT IT_PO-MEINS LEFT-JUSTIFIED.
    WRITE IT_PO-MEINS  TO I_ZPO_LOCAL-ZMEINS LEFT-JUSTIFIED.
    WRITE IT_PO-MATNR  TO I_ZPO_LOCAL-ZMATNR LEFT-JUSTIFIED.
    WRITE IT_PO-PEINH  TO I_ZPO_LOCAL-ZPEINH LEFT-JUSTIFIED.
    WRITE IT_PO-BPRME  TO I_ZPO_LOCAL-ZBPRME LEFT-JUSTIFIED.


    CLEAR MAKT.
    SELECT SINGLE MAKTX INTO MAKT-MAKTX FROM MAKT
    WHERE MATNR = IT_PO-MATNR.

    IF MAKT-MAKTX = SPACE.
      WRITE IT_PO-TXZ01 TO I_ZPO_LOCAL-ZDESCRIPTION LEFT-JUSTIFIED.
    ELSE.
      WRITE MAKT-MAKTX  TO I_ZPO_LOCAL-ZDESCRIPTION LEFT-JUSTIFIED.
    ENDIF.
    WRITE IT_PO-BANFN TO I_ZPO_LOCAL-ZPRNO LEFT-JUSTIFIED.
    WRITE IT_PO-BEDNR TO I_ZPO_LOCAL-ZFANO LEFT-JUSTIFIED.

    READ TABLE IT_EKET WITH KEY EBELN = IT_PO-EBELN
                                EBELP = IT_PO-EBELP.
    IF SY-SUBRC EQ 0.
      CONCATENATE IT_EKET-EINDT+6(2) '-' IT_EKET-EINDT+4(2) '-' IT_EKET-EINDT+2(2) INTO
      I_ZPO_LOCAL-ZEINDT.
    ENDIF.

* unit Price
    CLEAR LC_KBETR.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          ( KSCHL = 'PB00' OR KSCHL = 'PBXX' ).
      LC_KBETR = LC_KBETR + IT_KONV-KBETR.
    ENDLOOP.

    WRITE LC_KBETR TO I_ZPO_LOCAL-ZUNITPRICE CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

* unitdisc
    CLEAR : LC_KBETR, LC_KBETR2.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          KSCHL IN R_KSCHL AND KSCHL NE 'HB01'.

*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
      IF IT_KONV-WAERS NE ''.
        LC_KBETR2 = LC_KBETR2 + IT_KONV-KBETR.
        IT_KONV-DISC2 = LC_KBETR2.
      ELSE.
        LC_KBETR = LC_KBETR + IT_KONV-KBETR.
        IT_KONV-DISC1 = LC_KBETR.
      ENDIF.
      MODIFY IT_KONV.
*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
    ENDLOOP.

*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
    LOOP AT IT_KONV WHERE DISC1 NE '0.00' AND KNUMV = IT_PO-KNUMV AND KPOSN = IT_PO-EBELP.
      IT_KONV-DISC1 = IT_KONV-DISC1 / 10.
      WRITE IT_KONV-DISC1 TO I_ZPO_LOCAL-ZUNITDISC EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
      I_ZPO_LOCAL-ZWAERS = '%'.
    ENDLOOP.

    LOOP AT IT_KONV WHERE DISC2 NE '0.00' AND KNUMV = IT_PO-KNUMV AND KPOSN = IT_PO-EBELP.
      DATA  : V_NEWAMOUNT LIKE WMTO_S-AMOUNT.
      CLEAR : V_NEWAMOUNT.
      V_NEWAMOUNT = IT_KONV-DISC2.
      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
          CURRENCY        = IT_PO-WAERS
          AMOUNT_INTERNAL = V_NEWAMOUNT
        IMPORTING
          AMOUNT_DISPLAY  = V_NEWAMOUNT.
      IT_KONV-DISC2 = V_NEWAMOUNT.
      WRITE IT_KONV-DISC2 TO I_ZPO_LOCAL-ZUNITDISC2 EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
    ENDLOOP.
*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
*    IF IT_KONV-WAERS = SPACE AND LC_KBETR <> SPACE.
*      LC_KBETR = LC_KBETR / 10.
*      WRITE LC_KBETR TO I_ZPO_LOCAL-ZUNITDISC EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
*      I_ZPO_LOCAL-ZWAERS = '%'.
*
*    ELSEIF LC_KBETR = 0.
*      I_ZPO_LOCAL-ZUNITDISC = ''.
*    ELSE.
*    ENDIF.

*total price
    CLEAR LC_KWERT.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          ( KSCHL = 'PB00' OR KSCHL = 'PBXX' ).

      LC_KWERT = LC_KWERT + IT_KONV-KWERT.
    ENDLOOP.
    WRITE LC_KWERT TO I_ZPO_LOCAL-ZTOTALPRICE CURRENCY IT_PO-WAERS.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

    LC_SUBTOTAL = LC_SUBTOTAL + LC_KWERT.

*total disc
    CLEAR LC_KWERT.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          KSCHL IN R_KSCHL.

      LC_KWERT = LC_KWERT + IT_KONV-KWERT.
    ENDLOOP.
    WRITE LC_KWERT TO I_ZPO_LOCAL-ZTOTALDISC CURRENCY IT_PO-WAERS NO-GAP.
    CONDENSE I_ZPO_LOCAL-ZTOTALDISC.
    IF LC_KWERT <> 0.
      REPLACE ALL OCCURRENCES OF '-' IN I_ZPO_LOCAL-ZTOTALDISC WITH ' '.
      CONCATENATE '-' I_ZPO_LOCAL-ZTOTALDISC INTO I_ZPO_LOCAL-ZTOTALDISC.
    ENDIF.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

    LC_SUBDIC = LC_SUBDIC + LC_KWERT.

* find last po.
    IF IT_PO-MATNR <> ''.
      IF IT_PO-BSART EQ 'PO05'.
        READ TABLE IT_ADD_LAST WITH KEY MATNR = IT_PO-MATNR CHARG = IT_PO-CHARG.
      ELSE.
        READ TABLE IT_ADD_LAST WITH KEY MATNR = IT_PO-MATNR.
      ENDIF.

      READ TABLE IT_ADD_LAST WITH KEY MATNR = IT_PO-MATNR.
      IF SY-SUBRC EQ 0.
        CLEAR LFA1.
        SELECT SINGLE NAME1 INTO LFA1-NAME1 FROM LFA1
        WHERE LIFNR = IT_ADD_LAST-LIFNR.
        IF SY-SUBRC EQ 0.
          WRITE LFA1-NAME1 TO I_ZPO_LOCAL-ZLASTVENDOR.
        ENDIF.
      ENDIF.

*--- find last price by material
      CLEAR: IT_KONV_LAST.

      "ADD BY YULIUS #FIND LAST PRICE BASED ON MATERIAL NUMBER AND BATCH IF THEY'RE RPV, RPC OR RPM
      DATA : V_MTART TYPE MARA-MTART,
             V_CHARG TYPE EKET-CHARG.
      CLEAR : V_MTART,V_CHARG.
      IF IT_PO-MATNR = 'RPV' OR IT_PO-MATNR = 'RPC' OR IT_PO-MATNR = 'RPM' OR IT_PO-MATNR = 'CPV' OR IT_PO-MATNR = 'CPC' OR IT_PO-MATNR = 'CPM'. "Add by Fany Parama (05.10.2024)
        SELECT SINGLE MTART INTO V_MTART FROM MARA WHERE MATNR = IT_PO-MATNR AND MTART = 'ZRAW'.
        IF SY-SUBRC = 0.
          SELECT SINGLE CHARG INTO V_CHARG FROM EKET WHERE EBELN = P_EBELN AND EBELP = IT_PO-EBELP.
        ENDIF.
      ENDIF.
      IF IT_PO-BSART EQ 'PO05'.
        IF V_CHARG IS NOT INITIAL.
          SELECT A~KNUMV B~EBELP INTO (IT_KONV_LAST-KNUMV, IT_KONV_LAST-KPOSN)
          FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
                         JOIN EKET AS C ON C~EBELN = B~EBELN AND C~EBELP = B~EBELP AND C~CHARG = V_CHARG
          WHERE B~MATNR = IT_PO-MATNR
           AND C~CHARG = IT_PO-CHARG
           AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
           AND A~FRGZU = 'X'
          ORDER BY A~KNUMV ASCENDING.
          ENDSELECT.
          " END ADD BY YULIUS
        ELSE.
          SELECT A~KNUMV B~EBELP A~BEDAT INTO (IT_KONV_LAST-KNUMV, IT_KONV_LAST-KPOSN, IT_KONV_LAST-BEDAT)
          FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
          WHERE B~MATNR = IT_PO-MATNR
           AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
           AND A~FRGZU = 'X'
           AND A~BSART = IT_PO-BSART    "Add By Jarwo 02.03.2018
*          ORDER BY A~KNUMV ASCENDING.
          ORDER BY A~KNUMV B~EBELP A~BEDAT ASCENDING. "Add By Jarwo 02.03.2018
          ENDSELECT.
        ENDIF.
       ELSE.
         SELECT A~KNUMV B~EBELP A~BEDAT INTO (IT_KONV_LAST-KNUMV, IT_KONV_LAST-KPOSN, IT_KONV_LAST-BEDAT)
          FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
          WHERE B~MATNR = IT_PO-MATNR
           AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
           AND A~FRGZU = 'X'
           AND A~BSART = IT_PO-BSART    "Add By Jarwo 02.03.2018
*          ORDER BY A~KNUMV ASCENDING.
          ORDER BY A~KNUMV B~EBELP A~BEDAT ASCENDING. "Add By Jarwo 02.03.2018
          ENDSELECT.
       ENDIF.
      IF SY-SUBRC = 0.
        CLEAR LC_KBETR.
        SELECT SINGLE KBETR WAERS INTO (LC_KBETR, IT_KONV_LAST-WAERS) FROM KONV
        WHERE KNUMV = IT_KONV_LAST-KNUMV AND KPOSN = IT_KONV_LAST-KPOSN AND
                                         ( KSCHL = 'PB00' OR KSCHL = 'PBXX').

        "Add by Yulius - Get Last Price include discount
*        DATA : ZDISCOUNT TYPE KONV-KBETR.
*        CLEAR : ZDISCOUNT.
*        SELECT SINGLE KBETR INTO (ZDISCOUNT) FROM KONV
*         WHERE KNUMV = IT_KONV_LAST-KNUMV AND KPOSN = IT_KONV_LAST-KPOSN AND
*                                          ( KSCHL = 'RA01').
*        IF ZDISCOUNT < 0.
*          ZDISCOUNT = ZDISCOUNT / 10 * -1.
*        ELSE.
*          ZDISCOUNT  = ZDISCOUNT / 10.
*        ENDIF.
*        LC_KBETR = LC_KBETR - ( LC_KBETR * ZDISCOUNT / 100 ).
        "End add by Yulius - Get Last Price include discount

*       "Add by Yulius - Get Last Price from netprice
        IF V_CHARG IS NOT INITIAL.
          SELECT  B~NETPR INTO (LC_KBETR)
          FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
                         JOIN EKET AS C ON C~EBELN = B~EBELN AND C~EBELP = B~EBELP AND C~CHARG = V_CHARG
          WHERE B~MATNR = IT_PO-MATNR
           AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
           AND A~FRGZU = 'X'
          ORDER BY A~KNUMV ASCENDING.
          ENDSELECT.
        ELSE.
          SELECT B~NETPR INTO (LC_KBETR)
           FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
           WHERE B~MATNR = IT_PO-MATNR
            AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
            AND A~FRGZU = 'X'
            ORDER BY A~EBELN ASCENDING.
          ENDSELECT.
        ENDIF.
*       "End by Yulius - Get Last Price from netprice

* get kurs
        DATA: V_KURS LIKE RKB1K-EXCHR.
        CLEAR: V_KURS, V_NEWAMOUNT.

        IF IT_PO-WAERS NE IT_KONV_LAST-WAERS.
* convert to IDR
          IF IT_KONV_LAST-WAERS = 'IDR'.
            LC_KBETR = LC_KBETR.
          ELSE.
            CALL FUNCTION 'RKC_SINGLE_EXCHANGE_RATE_GET'
              EXPORTING
                DATUM         = SY-DATUM
                KURST         = 'M'
                NCURR         = 'IDR'
                VCURR         = IT_KONV_LAST-WAERS
              IMPORTING
                EXCHR         = V_KURS
              EXCEPTIONS
                NO_RATE_FOUND = 1
                OTHERS        = 2.

            LC_KBETR = LC_KBETR * V_KURS.
          ENDIF.

          V_NEWAMOUNT = LC_KBETR.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = IT_KONV_LAST-WAERS
              AMOUNT_INTERNAL = V_NEWAMOUNT
            IMPORTING
              AMOUNT_DISPLAY  = V_NEWAMOUNT.
          LC_KBETR = V_NEWAMOUNT.

* convert from IDR
          IF IT_PO-WAERS EQ 'IDR'.
            LC_KBETR = LC_KBETR.
          ELSE.
            CALL FUNCTION 'RKC_SINGLE_EXCHANGE_RATE_GET'
              EXPORTING
                DATUM         = SY-DATUM
                KURST         = 'M'
                NCURR         = 'IDR'
                VCURR         = IT_PO-WAERS
              IMPORTING
                EXCHR         = V_KURS
              EXCEPTIONS
                NO_RATE_FOUND = 1
                OTHERS        = 2.

            LC_KBETR = LC_KBETR * 1 / V_KURS.
          ENDIF.
        ELSE.
          V_NEWAMOUNT = LC_KBETR.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = IT_KONV_LAST-WAERS
              AMOUNT_INTERNAL = V_NEWAMOUNT
            IMPORTING
              AMOUNT_DISPLAY  = V_NEWAMOUNT.
          LC_KBETR = V_NEWAMOUNT.
        ENDIF.    " no same currency
*--- end of get kurs

        IF SY-SUBRC = 0.
         DATA : LV_TEMPKBETR LIKE KONV-KWERT.
          IF IT_PO-BSART EQ 'PO05'.
*           "new last price by fany (convert last price to current PO order price unit)
            DATA: LV_LASTPOU LIKE EKPO-BPRME.
            CLEAR: LV_LASTPOU.
            SELECT SINGLE BPRME FROM EKPO INTO LV_LASTPOU
              WHERE EKPO~EBELN = IT_ADD_LAST-EBELN AND EKPO~EBELP = IT_ADD_LAST-EBELP .
            CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
             EXPORTING
               INPUT =  LC_KBETR
               UNIT_IN = IT_PO-BPRME
               UNIT_OUT = LV_LASTPOU
             IMPORTING
               OUTPUT = LC_KBETR.

            IF IT_PO-WAERS EQ 'IDR'.
              LV_TEMPKBETR = LC_KBETR.
              WRITE LV_TEMPKBETR TO I_ZPO_LOCAL-ZLASTPRICE.
            ELSE.
              WRITE LC_KBETR TO I_ZPO_LOCAL-ZLASTPRICE.
            ENDIF.
          ELSE.
            IF IT_PO-WAERS EQ 'IDR'.
              LV_TEMPKBETR = LC_KBETR.
              WRITE LV_TEMPKBETR TO I_ZPO_LOCAL-ZLASTPRICE.
            ELSE.
              WRITE LC_KBETR TO I_ZPO_LOCAL-ZLASTPRICE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: IT_KONV_LAST.
*---
    ENDIF.

    APPEND I_ZPO_LOCAL.
    CLEAR  I_ZPO_LOCAL.

  ENDLOOP.

  WRITE LC_SUBTOTAL TO P_SUBTOTAL CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.
  WRITE LC_SUBDIC   TO P_DISCOUNT CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.

  IF LC_KBETR <> 0.
    REPLACE ALL OCCURRENCES OF '-' IN P_DISCOUNT WITH ' '.
    CONCATENATE '-' P_DISCOUNT  INTO  P_DISCOUNT.
  ENDIF.

* tax
  CLEAR LC_BASE_AMOUNT.
  LC_BASE_AMOUNT  = LC_SUBTOTAL + LC_SUBDIC.

  CLEAR LC_TAX_AMOUNT.
*  LOOP AT IT_PO WHERE MWSKZ NE SPACE.
*    IF IT_PO-MWSKZ = 'V0'.
*      LC_TAX_AMOUNT = 0.
*    ELSEIF IT_PO-MWSKZ = 'V1'.
*      LC_TAX_AMOUNT = LC_BASE_AMOUNT * ( 10 / 100 ).
*    ENDIF.
*    EXIT.
*  ENDLOOP.
*- get KONP-KBETR
  LOOP AT IT_PO WHERE MWSKZ NE SPACE.
    SELECT SINGLE KBETR INTO V_PPN_PRC
      FROM A003 JOIN KONP ON A003~KNUMH = KONP~KNUMH
      WHERE A003~KAPPL = 'TX' AND A003~ALAND = 'ID' AND A003~KSCHL = 'MWVS' AND A003~MWSKZ = IT_PO-MWSKZ.
    CLEAR P_TAX.
    IF V_PPN_PRC > 0.
      V_PPN_PRC = V_PPN_PRC / 1000.
      LC_TAX_AMOUNT = LC_BASE_AMOUNT * V_PPN_PRC.
      WRITE LC_TAX_AMOUNT TO P_TAX CURRENCY IT_PO-WAERS.
    ENDIF.
  ENDLOOP.
*freight
  CLEAR LC_KWERT.
  LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                        KPOSN = IT_PO-EBELP    AND
                        KSCHL = 'ZS01'.

    LC_KWERT = LC_KWERT + IT_KONV-KBETR.
  ENDLOOP.
  WRITE LC_KWERT TO P_FREIGHT CURRENCY IT_PO-WAERS.


  LC_TOTAL_ORDER = LC_SUBTOTAL + LC_SUBDIC + LC_TAX_AMOUNT + LC_KWERT .

  WRITE LC_TOTAL_ORDER TO P_TOTAL_ORDER CURRENCY IT_PO-WAERS.


ENDFORM.                    " f_find_item_data
*&---------------------------------------------------------------------*
*&      Form  f_add_kschl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_KSCHL .

  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'HB01'.
  R_KSCHL-HIGH   =  'HB01'.
  APPEND R_KSCHL.

  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RA00'.
  R_KSCHL-HIGH   =  'RA00'.
  APPEND R_KSCHL.


  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RA01'.
  R_KSCHL-HIGH   =  'RA01'.
  APPEND R_KSCHL.


  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RB00'.
  R_KSCHL-HIGH   =  'RB00'.
  APPEND R_KSCHL.



ENDFORM.                    " f_add_kschl
*&---------------------------------------------------------------------*
*&      Form  f_get_last_month_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_LAST_MONTH_DATE .

  REFRESH R_DATE.
  V_DATUM_END = V_DATUM_END - 1.

  R_DATE-SIGN   =  'I'.
  R_DATE-OPTION =  'BT'.
  R_DATE-HIGH   =  IT_PO-AEDAT. "sy-datum.
  R_DATE-LOW    =  V_DATUM_END.
  APPEND R_DATE.

ENDFORM.                    " f_get_last_month_date
*&---------------------------------------------------------------------*
*&      Form  f_additional_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADDITIONAL_DATA .
* addtional column.
  LOOP AT IT_PO.
     IF IT_PO-BSART EQ 'PO05'.
      SORT IT_LAST_PO DESCENDING BY EBELN.
      READ TABLE IT_LAST_PO WITH KEY MATNR = IT_PO-MATNR CHARG = IT_PO-CHARG.
      IF SY-SUBRC EQ 0.
         MOVE: IT_LAST_PO-MATNR TO IT_ADD_LAST-MATNR,
               IT_LAST_PO-CHARG TO IT_ADD_LAST-CHARG,
               IT_LAST_PO-EBELP TO IT_ADD_LAST-EBELP,
               IT_LAST_PO-EBELN TO IT_ADD_LAST-EBELN,
               IT_LAST_PO-MEINS TO IT_ADD_LAST-MEINS,
               IT_LAST_PO-KNUMV TO IT_ADD_LAST-KNUMV,
               IT_LAST_PO-LIFNR TO IT_ADD_LAST-LIFNR.
         APPEND IT_ADD_LAST.
      ENDIF.
    ELSE.
      READ TABLE IT_LAST_PO WITH KEY MATNR = IT_PO-MATNR.
      IF SY-SUBRC EQ 0.
        MOVE: IT_LAST_PO-MATNR TO IT_ADD_LAST-MATNR,
              IT_LAST_PO-EBELP TO IT_ADD_LAST-EBELP,
              IT_LAST_PO-EBELN TO IT_ADD_LAST-EBELN,
              IT_LAST_PO-MEINS TO IT_ADD_LAST-MEINS,
              IT_LAST_PO-KNUMV TO IT_ADD_LAST-KNUMV,
              IT_LAST_PO-LIFNR TO IT_ADD_LAST-LIFNR.
        APPEND IT_ADD_LAST.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF IT_ADD_LAST[] IS NOT INITIAL.
    SELECT KNUMV  KPOSN  KSCHL
           KBETR  KWERT  WAERS
    INTO TABLE IT_KONV_LAST
    FROM KONV FOR ALL ENTRIES IN IT_ADD_LAST
    WHERE KNUMV  = IT_ADD_LAST-KNUMV.
  ENDIF.


ENDFORM.                    " f_additional_data
*&---------------------------------------------------------------------*
*&      Form  f_select_Data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_DATA .
  CLEAR : P_VENDOR, P_VENDOR2, P_ADDRESS, P_CITY, "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
          P_TELP, P_FAX, P_WERKS, P_NAME_WERKS, P_ADDRESS_PLANT,
          P_SUBTOTAL, P_FREIGHT, P_CITY_PLANT, P_LGORT, P_LGORT_TEXT,
          P_EBELN, P_DATE_PO, P_DATE_PRT, P_DISCOUNT, P_TAX, P_TOTAL_ORDER.


  REFRESH : IT_PO, IT_EKET, IT_KONV.
  SELECT
      A~EBELN A~EKORG A~WAERS A~AEDAT A~LIFNR A~KNUMV A~ZTERM A~BSART A~VERKF A~EKGRP
      B~WERKS B~LGORT B~EBELP B~MENGE B~MEINS B~MATNR
      B~TXZ01 B~BEDNR B~BANFN B~MEINS B~MWSKZ
      C~TEXT1 B~BPRME B~PEINH D~CHARG
      APPENDING CORRESPONDING FIELDS OF TABLE IT_PO
      FROM EKKO AS A INNER JOIN EKPO AS B
             ON A~EBELN = B~EBELN
              JOIN T052U AS C ON A~ZTERM = C~ZTERM
               INNER JOIN EKET AS D
                ON B~EBELN = D~EBELN
                AND B~EBELP = D~EBELP
             WHERE A~EBELN = NAST-OBJKY+0(10) AND B~LOEKZ = ''.
  IF NOT IT_PO[] IS INITIAL.
    READ TABLE IT_PO INDEX 1.

    IF IT_PO-EKORG NE 'TPOL'.
      MESSAGE E398(00) WITH 'Only for TRIAS PO LOCAL' '' '' ''.
      EXIT.
    ENDIF.

    SELECT EBELN EBELP EINDT INTO TABLE IT_EKET
    FROM EKET WHERE EBELN = IT_PO-EBELN.

    "add by whika issue Update Print out Purchase Order case of Multiple discount
    "18 oct 2016
    LOOP AT IT_PO.
      CLEAR : IT_KONV.
      SELECT KNUMV  KPOSN  KSCHL
           KBETR  KWERT  WAERS INTO TABLE IT_KONV FROM KONV WHERE KNUMV  = IT_PO-KNUMV.
    ENDLOOP.

    SELECT NETPR NETWR INTO (IT_KONV-NETPR, IT_KONV-NETWR)
    FROM EKPO FOR ALL ENTRIES IN IT_PO WHERE EBELN = IT_PO-EBELN AND  LOEKZ = ''.
    ENDSELECT.
  ENDIF.


* last po base on material number
  DATA: TEMP LIKE EKKO-EBELN.
  CLEAR IT_LAST_PO1.
  REFRESH IT_LAST_PO1.

  TEMP = IT_PO-EBELN.
  REFRESH IT_LAST_PO.
  IF IT_PO-BSART = 'PO05'.
     SELECT
       A~EBELN A~AEDAT A~LIFNR A~KNUMV
       B~WERKS B~LGORT
       B~MENGE B~MEINS B~MATNR
       B~TXZ01 B~BEDNR B~BANFN
       B~MEINS B~MWSKZ B~EBELP C~CHARG
     APPENDING CORRESPONDING FIELDS OF TABLE IT_LAST_PO
       FROM EKKO AS A INNER JOIN EKPO AS B
       ON B~EBELN = A~EBELN
       INNER JOIN EKET AS C
       ON B~EBELN = C~EBELN
       AND B~EBELP = C~EBELP
       WHERE  B~MATNR  = IT_PO-MATNR AND
        C~CHARG = IT_PO-CHARG  AND
        B~EBELN  < TEMP AND B~LOEKZ = ''
       ORDER BY A~EBELN DESCENDING.
  ELSE.
    SELECT
    A~EBELN A~AEDAT A~LIFNR A~KNUMV
    B~WERKS B~LGORT
    B~MENGE B~MEINS B~MATNR
    B~TXZ01 B~BEDNR B~BANFN
    B~MEINS B~MWSKZ B~EBELP
    APPENDING CORRESPONDING FIELDS OF TABLE IT_LAST_PO
    FROM EKKO AS A INNER JOIN EKPO AS B
           ON B~EBELN = A~EBELN
    WHERE B~MATNR  = IT_PO-MATNR AND
          B~EBELN  < TEMP AND B~LOEKZ = ''
          AND B~MATNR NE ''
    ORDER BY A~EBELN DESCENDING.
  ENDIF.
  PERFORM F_GET_REV_DOC.
ENDFORM.                    " f_select_Data


*&---------------------------------------------------------------------*
*&      Form  f_smartforms_configure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SMARTFORMS_CONFIGURE .
  DATA: XDEVICE(10) TYPE C,
          XDIALOG.                 "Hilfsfeld Formular

  CLEAR: I_SSFCOMPOP.
  CLEAR: I_SSFCTRLOP.

  MOVE-CORRESPONDING NAST TO I_SSFCOMPOP.
  I_SSFCOMPOP-TDTITLE   = NAST-TDCOVTITLE.
  I_SSFCOMPOP-TDFAXUSER = NAST-USNAM.

*- Ausgabemedium festlegen --------------------------------------------*
  CASE NAST-NACHA.
    WHEN '2'.
      XDEVICE = 'TELEFAX'.
      IF NAST-TELFX EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELFX.
        IF NOT NAST-TLAND IS INITIAL.
          I_SSFCOMPOP-TDTELELAND = NAST-TLAND.
        ENDIF.
      ENDIF.
    WHEN '3'.
      XDEVICE = 'TELETEX'.
      IF NAST-TELTX EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELTX.
      ENDIF.
    WHEN '4'.
      XDEVICE = 'TELEX'.
      IF NAST-TELX1 EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELX1.
      ENDIF.
    WHEN '5'.
* N/a
    WHEN OTHERS.
      XDEVICE = 'PRINTER'.
      IF NAST-LDEST EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDDEST   = NAST-LDEST.
      ENDIF.
  ENDCASE.

* Bei Probedruck, wenn das Medium keine Drucker ist.        " 361152
  IF NAST-SNDEX EQ C_FLAG AND
     NAST-NACHA NE '1'.                                     " 361152
    XDEVICE = 'PRINTER'.                                    " 361152
    IF NAST-LDEST EQ SPACE.                                 " 361152
      XDIALOG = C_FLAG.                                     " 361152
    ELSE.                                                   " 361152
      I_SSFCOMPOP-TDDEST   = NAST-LDEST.                    " 361152
    ENDIF.                                                  " 361152
  ENDIF.                                                    " 361152
  I_SSFCOMPOP-TDCOVER    = NAST-TDOCOVER.
  I_SSFCOMPOP-TDCOPIES   = NAST-ANZAL.
  I_SSFCOMPOP-TDDATASET  = NAST-DSNAM.
  I_SSFCOMPOP-TDSUFFIX1  = NAST-DSUF1.
  I_SSFCOMPOP-TDSUFFIX2  = NAST-DSUF2.
  I_SSFCOMPOP-TDSENDDATE = NAST-VSDAT.
  I_SSFCOMPOP-TDSENDTIME = NAST-VSURA.

  IF SY-XCODE = '9AUS' OR SY-XCODE = '9ANZ'.
*   Set Display SmartForm directly
*   ------------------------------
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = ' '.
    I_SSFCOMPOP-TDNOPRINT = SPACE.
    I_SSFCOMPOP-TDIMMED   = NAST-DIMME.
    I_SSFCOMPOP-TDDELETE  = NAST-DELET.
    I_SSFCOMPOP-TDNEWID   = C_FLAG.                         " 99282
  ELSEIF SY-XCODE = '9ANZ'.
    I_SSFCOMPOP-TDNOPRINT = C_FLAG.
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = C_FLAG.
    I_SSFCOMPOP-TDIMMED   = SPACE.
    I_SSFCOMPOP-TDNEWID   = SPACE.                          " 99282
  ELSEIF SY-XCODE EQ 'DRPR' OR                              " 361152
           NAST-SNDEX EQ C_FLAG.                            " 361152

    I_SSFCOMPOP-TDNOPRINT  = SPACE.                         " 361152
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCOMPOP-TDNOPREV  = C_FLAG.
    I_SSFCOMPOP-TDCOPIES   = 1.
    I_SSFCOMPOP-TDIMMED    = 'X'.
    I_SSFCOMPOP-TDDELETE   = NAST-DELET.
    I_SSFCOMPOP-TDNEWID    = C_FLAG.                        " 99282

  ELSE.
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = C_FLAG.
    I_SSFCOMPOP-TDNOPRINT = 'X'.
    I_SSFCOMPOP-TDIMMED   = ' '.
    I_SSFCOMPOP-TDDELETE  = NAST-DELET.
    I_SSFCOMPOP-TDNEWID   = C_FLAG.                         " 99282
  ENDIF.

ENDFORM.                    " f_smartforms_configure

*&---------------------------------------------------------------------*
*&      Form  f_get_term_payment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_TERM_PAYMENT .

  CLEAR : V_TDNAME.
  V_TDNAME = IT_PO-EBELN.
  REFRESH I_LINES.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F07'
      LANGUAGE  = 'E'
      NAME      = V_TDNAME
      OBJECT    = 'EKKO'
    IMPORTING
      HEADER    = THEAD
    TABLES
      LINES     = I_LINES
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      NOT_FOUND = 4
      OBJECT    = 5.

  DELETE I_LINES
     WHERE  TDLINE EQ SPACE.

  CLEAR P_TERM.
  LOOP AT I_LINES.
    IF SY-TABIX = 1.
      CONCATENATE 'TOP: ' I_LINES-TDLINE INTO  P_TERM  SEPARATED BY SPACE.
    ELSE.
      CONCATENATE P_TERM I_LINES-TDLINE ' ' INTO  P_TERM  SEPARATED BY SPACE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " f_get_term_payment

*&---------------------------------------------------------------------*
*&      Form  f_get_item_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_ITEM_TEXT USING EBELN EBELP
                     CHANGING TEXT.

  CLEAR : V_TDNAME.
  CONCATENATE EBELN EBELP INTO V_TDNAME.
  CLEAR I_LINES.
  REFRESH I_LINES.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'
      LANGUAGE  = 'E'
      NAME      = V_TDNAME
      OBJECT    = 'EKPO'
    IMPORTING
      HEADER    = THEAD
    TABLES
      LINES     = I_LINES
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      NOT_FOUND = 4
      OBJECT    = 5.


  DELETE I_LINES
     WHERE  TDLINE EQ SPACE.

  CLEAR TEXT.
  LOOP AT I_LINES.
    CONCATENATE TEXT I_LINES-TDLINE INTO TEXT SEPARATED BY SPACE.
  ENDLOOP.

  REPLACE ALL OCCURRENCES OF '<(>' IN TEXT WITH SPACE.
  REPLACE ALL OCCURRENCES OF '<)>' IN TEXT WITH SPACE.

ENDFORM.                    " f_get_term_payment



*--- get consignmrnt price
FORM F_GET_INFORECORD.
  CLEAR:  V_POTYPE.

  DATA: BEGIN OF IT_EKPO OCCURS 0,
        EBELN LIKE EKPO-EBELN,
        EBELP LIKE EKPO-EBELP,
        INFNR LIKE EKPO-INFNR,
        NETPR LIKE EINE-NETPR,
        WAERS LIKE EINE-WAERS,
        MWSKZ LIKE EINE-MWSKZ,   "Tax code
        END OF IT_EKPO.
  DATA: T_SUBTOTAL LIKE EINE-NETPR,
        T_DISCOUNT  LIKE EINE-NETPR,
        T_TAX  LIKE EINE-NETPR,
        T_FREIGHT  LIKE EINE-NETPR,
        T_TOTAL_ORDER  LIKE EINE-NETPR.

  SELECT A~EBELN A~EBELP A~INFNR B~NETPR B~WAERS B~MWSKZ INTO TABLE IT_EKPO
  FROM ( EKPO AS A JOIN EINE AS B ON A~INFNR = B~INFNR AND B~WERKS = P_WERKS ) JOIN EKKO AS C ON A~EBELN = C~EBELN
  WHERE A~EBELN = P_EBELN AND C~BSART = 'PO12'.

  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  V_POTYPE = 'Consignment'.
  CLEAR: P_SUBTOTAL, P_DISCOUNT, P_TAX, P_FREIGHT, P_TOTAL_ORDER.
  LOOP AT I_ZPO_LOCAL.
    READ TABLE IT_EKPO WITH KEY EBELP = I_ZPO_LOCAL-ZNO.
    IF SY-SUBRC = 0.
      WRITE IT_EKPO-NETPR TO I_ZPO_LOCAL-ZUNITPRICE CURRENCY IT_EKPO-WAERS.
      IT_EKPO-NETPR = IT_EKPO-NETPR * I_ZPO_LOCAL-ZMENGE.
      WRITE IT_EKPO-NETPR TO  I_ZPO_LOCAL-ZTOTALPRICE CURRENCY IT_EKPO-WAERS.
      MODIFY I_ZPO_LOCAL.

      T_SUBTOTAL = T_SUBTOTAL + IT_EKPO-NETPR.
    ENDIF.
  ENDLOOP.

*  IF IT_EKPO-MWSKZ = 'V0'.
*    T_TAX = 0.
*  ELSEIF IT_EKPO-MWSKZ = 'V1'.
*    T_TAX = T_SUBTOTAL * ( 10 / 100 ).
*  ENDIF.
  CLEAR T_TAX.
  IF V_PPN_PRC > 0.
    T_TAX = T_SUBTOTAL * V_PPN_PRC.
  ENDIF.

  WRITE T_SUBTOTAL TO  P_SUBTOTAL CURRENCY IT_EKPO-WAERS.
  T_TOTAL_ORDER = T_SUBTOTAL - T_DISCOUNT + T_TAX + T_FREIGHT.
  WRITE T_TOTAL_ORDER TO  P_TOTAL_ORDER CURRENCY IT_EKPO-WAERS.

ENDFORM.                    "f_get_inforecord



*--- case of PO return
FORM F_PO_RETURN.
  DATA: BEGIN OF IT_RETURN OCCURS 0,
        EBELN LIKE EKPO-EBELN,
        RETPO LIKE EKPO-RETPO,
        END OF IT_RETURN.

  SELECT EBELN RETPO INTO TABLE IT_RETURN
    FROM EKPO WHERE EBELN = P_EBELN AND LOEKZ = ''.

  IF SY-SUBRC = 0.
    READ TABLE IT_RETURN WITH KEY RETPO = 'X'.

    IF SY-SUBRC = 0.
      READ TABLE IT_RETURN WITH KEY RETPO = ''.

      IF SY-SUBRC = 0.
        CLEAR VBSART.
        SELECT SINGLE EKKO~BSART
          FROM EKKO
          INTO VBSART
          WHERE EKKO~EBELN = P_EBELN.

        IF VBSART = 'PO19'.
          V_POTYPE = 'R E T U R N'.
        ENDIF.
      ELSE.

        CLEAR VBSART.
        SELECT SINGLE EKKO~BSART
          FROM EKKO
          INTO VBSART
          WHERE EKKO~EBELN = P_EBELN.

        IF VBSART = 'PO19'.
          V_POTYPE = 'R E T U R N'.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_po_return


*--- get Delivery schedule line data.
FORM F_GET_SCHE_LINES.
  DATA: V_COUNT LIKE SY-TABIX.

  SELECT EBELN EBELP EINDT MENGE
  INTO CORRESPONDING FIELDS OF TABLE IT_DELV
  FROM EKET WHERE EBELN = P_EBELN.

  LOOP AT I_ZPO_LOCAL.
    CLEAR V_COUNT.
    LOOP AT IT_DELV WHERE EBELN = P_EBELN AND EBELP = I_ZPO_LOCAL-ZNO.
      V_COUNT = V_COUNT + 1.
    ENDLOOP.
    IF V_COUNT < 2.
      DELETE IT_DELV WHERE EBELN = P_EBELN AND EBELP = I_ZPO_LOCAL-ZNO.
    ELSE.
      I_ZPO_LOCAL-ZEINDT = ''.
      MODIFY I_ZPO_LOCAL.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_get_sche_lines


*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_HEADER_TEXT .
  CLEAR : V_TDNAME.
  V_TDNAME = IT_PO-EBELN.
  REFRESH I_LINES.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'
      LANGUAGE  = 'E'
      NAME      = V_TDNAME
      OBJECT    = 'EKKO'
    IMPORTING
      HEADER    = THEAD
    TABLES
      LINES     = I_LINES
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      NOT_FOUND = 4
      OBJECT    = 5.


  DELETE I_LINES
     WHERE  TDLINE EQ SPACE.

  REFRESH IT_HTEXT.
  LOOP AT I_LINES.
    WA_HTEXT-TDLINE = I_LINES-TDLINE.
    APPEND WA_HTEXT TO IT_HTEXT.
  ENDLOOP.
ENDFORM.                    " F_GET_HEADER_TEXT


*&---------------------------------------------------------------------*
*&      Form  F_GET_REV_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_REV_DOC .
  DATA : IS_CHANGE(1) TYPE C.
  REFRESH : ITHREV, ITIREV.
  CLEAR : WAREV.

  SELECT CDHDR~OBJECTID AS NOPO
    CDHDR~CHANGENR AS NODOC CDHDR~UDATE AS UDATE
    INTO CORRESPONDING FIELDS OF TABLE ITHREV
    FROM CDHDR
    WHERE CDHDR~OBJECTCLAS = 'EINKBELEG'
    AND CDHDR~OBJECTID = NAST-OBJKY+0(10).

  LOOP AT ITHREV.
    REFRESH ITIREV.

    SELECT CDPOS~OBJECTID AS NOPO
      CDPOS~CHANGENR AS NODOC
      CDPOS~FNAME AS FNAME
      INTO CORRESPONDING FIELDS OF TABLE ITIREV
      FROM CDPOS
      WHERE CDPOS~OBJECTCLAS = 'EINKBELEG'
      AND CDPOS~OBJECTID = ITHREV-NOPO
      AND CDPOS~CHANGENR = ITHREV-NODOC.

    "CEK PERUBAHAN DATA
    "HARGA DAN QTY, TERMS OF PAYMENT, DESKRIPSI.
    CLEAR IS_CHANGE.
    LOOP AT ITIREV WHERE FNAME = 'F07 E'
      OR FNAME = 'MENGE'
      OR FNAME = 'F01 E'
      OR FNAME = 'NETPR'
      OR FNAME = 'ZTERM'.

      IS_CHANGE = 'X'.

    ENDLOOP.

    IF IS_CHANGE = 'X'.
      ITHREV-FLAG = 'X'.
    ENDIF.
    MODIFY ITHREV.

  ENDLOOP.

  DELETE ITHREV WHERE FLAG NE 'X'.
  DESCRIBE TABLE ITHREV LINES REV.

  IF REV <> 0.
    V_REV = REV.
    CONDENSE V_REV NO-GAPS.
    CONCATENATE '(REVISION:' V_REV ',' INTO V_REV SEPARATED BY SPACE.
  ENDIF.

  SORT ITHREV BY UDATE DESCENDING.
  LOOP AT ITHREV.
    CONCATENATE V_REV ITHREV-UDATE+6(2) '-'  ITHREV-UDATE+4(2) '-' ITHREV-UDATE+0(4) ')'  INTO V_REV.
    EXIT.
  ENDLOOP.


ENDFORM.                    " F_GET_REV_DOC


*&---------------------------------------------------------------------*
*&      Form  to_pdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TO_PDF.
  DATA :IT_DOCS     TYPE STANDARD TABLE OF DOCS,
        IT_LINES    TYPE STANDARD TABLE OF TLINE,
        V_E_DEVTYPE              TYPE RSPOPTYPE,
        V_BIN_FILESIZE           TYPE I,
        V_NAME                   TYPE STRING,
        ST_JOB_OUTPUT_INFO       TYPE SSFCRESCL,
        ST_DOCUMENT_OUTPUT_INFO  TYPE SSFCRESPD,
        ST_JOB_OUTPUT_OPTIONS    TYPE SSFCRESOP.

  DATA: FPATH TYPE IBIPPARMS-PATH.
  DATA: V_BG(1).

  " Start Add by Fiqih 31.01.2026
  DATA: LS_ZMAP          TYPE ZMAP_TYPE,
        LV_SIGNER        TYPE CHAR20,
        LV_STAMP         TYPE CHAR20,
        LV_DATE          TYPE DATS,
        LV_CRTD_DATE     TYPE DATS,
        LV_CHG_DATE      TYPE DATS.

  LV_CRTD_DATE = IT_PO-AEDAT. "Ambil tanggal pembuatan PO dari EKKO-AEDAT

  CLEAR LV_CHG_DATE.
  SELECT UDATE
    FROM CDHDR
    INTO LV_CHG_DATE
    UP TO 1 ROWS
    WHERE OBJECTCLAS = 'EINKBELEG' " OBJECT CLASS UNTUK PURCHASING DOCUMENT (PO)
      AND OBJECTID = IT_PO-EBELN  " Nomor PO
    ORDER BY UDATE DESCENDING UTIME DESCENDING.
  ENDSELECT.

  IF SY-SUBRC = 0 AND LV_CHG_DATE > LV_CRTD_DATE.
    LV_CRTD_DATE = LV_CHG_DATE.
  ENDIF.

  CLEAR LS_ZMAP.
  SELECT SINGLE *
    FROM ZMAP_TYPE
    INTO LS_ZMAP
    WHERE PROG = SY-REPID
      AND TYPE = 'SIGN PO'
      AND OPT = 'CUT OVER'
      AND DELETION = ''.

  IF SY-SUBRC = 0.
    LV_DATE = LS_ZMAP-VALUE.
    IF LV_CRTD_DATE < LV_DATE.
      LV_SIGNER = LS_ZMAP-TEXT1.
      LV_STAMP  = LS_ZMAP-TEXT2.
    ELSE.
      LV_SIGNER = LS_ZMAP-TEXT3.
      LV_STAMP  = LS_ZMAP-TEXT4.
    ENDIF.
  ENDIF.
  " End Add by Fiqih 31.01.2026

  IF NOT *TNAPR-SFORM IS INITIAL.
    V_FORMNAME = *TNAPR-SFORM.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-XCODE EQ '9AUS'.
    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        I_LANGUAGE    = 'E'
        I_APPLICATION = 'SAPDEFAULT'
      IMPORTING
        E_DEVTYPE     = V_E_DEVTYPE.

    I_SSFCOMPOP-TDPRINTER = V_E_DEVTYPE.
    I_SSFCOMPOP-TDIMMED   =  'X'.
    I_SSFCOMPOP-TDNOPRINT = 'X'.
    I_SSFCTRLOP-NO_DIALOG = 'X'.
    I_SSFCTRLOP-GETOTF = 'X'.

    V_BG = ''.
    I_SSFCTRLOP-PREVIEW = ''.

  ELSE.
    I_SSFCOMPOP-TDNOPRINT = 'X'.

    V_BG = 'X'.
    I_SSFCTRLOP-PREVIEW = 'X'.
  ENDIF.

  PERFORM F_GET_TERM_PAYMENT.

  PERFORM F_GET_HEADER_TEXT.

  READ TABLE  IT_PO INDEX 1.
  SELECT SINGLE EKNAM INTO P_EKNAM FROM T024 WHERE EKGRP = IT_PO-EKGRP.

*- Perform convert ITF to STREAM_TEXT process to remove special character
  PERFORM F_DO_CONVERT.     "ADDED BY FATHIR 02.11.2018

  IF IT_PO-BSART = 'PO06'.
    PERFORM F_GET_SCHE_LINES.

    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS   = I_SSFCTRLOP
        OUTPUT_OPTIONS       = I_SSFCOMPOP
        S_VENDOR             = P_VENDOR
        S_VENDOR2            = P_VENDOR2 "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
        S_ADDRESS            = P_ADDRESS
        S_CITY               = P_CITY
        S_TELP               = P_TELP
        S_FAX                = P_FAX
        S_WERKS              = P_WERKS
        S_NAME_WERKS         = P_NAME_WERKS
        S_ADDRESS_PLANT      = P_ADDRESS_PLANT
        S_CITY_PLANT         = P_CITY_PLANT
        S_LGORT              = P_LGORT
        S_LGORT_TEXT         = P_LGORT_TEXT
        S_EBELN              = P_EBELN
        S_DATE_PO            = P_DATE_PO
        S_DATE_PRT           = P_DATE_PRT
        S_PAY1               = P_TERM
        S_SUBTOTAL           = P_SUBTOTAL
        S_DISCOUNT           = P_DISCOUNT
        S_TAX                = P_TAX
        S_FREIGHT            = P_FREIGHT
        S_TOTAL_ORDER        = P_TOTAL_ORDER
        S_FLAG_PREV          = I_SSFCTRLOP-PREVIEW
        P_WAERS              = IT_PO-WAERS
        PO_TYPE              = V_POTYPE
        V_REV                = V_REV
        V_BG                 = V_BG
        S_VERKF              = IT_PO-VERKF
        S_EKNAM              = P_EKNAM
        S_COMPCODE           = P_COMPCODE
        S_SIGNER             = LV_SIGNER    " Add by Fiqih 31.01.2026
        S_STAMP              = LV_STAMP     " Add by Fiqih 31.01.2026
      IMPORTING
        DOCUMENT_OUTPUT_INFO = ST_DOCUMENT_OUTPUT_INFO
        JOB_OUTPUT_INFO      = ST_JOB_OUTPUT_INFO
        JOB_OUTPUT_OPTIONS   = ST_JOB_OUTPUT_OPTIONS
      TABLES
        I_ZPO_LOCAL          = I_ZPO_LOCAL
        IT_EKET              = IT_DELV.
  ELSE.
    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS   = I_SSFCTRLOP
        OUTPUT_OPTIONS       = I_SSFCOMPOP
        S_VENDOR             = P_VENDOR
        S_VENDOR2            = P_VENDOR2  "Modified by AKBAR 10.02.2020 (Add NAME2 Vendor with more 35 char)
        S_ADDRESS            = P_ADDRESS
        S_CITY               = P_CITY
        S_TELP               = P_TELP
        S_FAX                = P_FAX
        S_WERKS              = P_WERKS
        S_NAME_WERKS         = P_NAME_WERKS
        S_ADDRESS_PLANT      = P_ADDRESS_PLANT
        S_CITY_PLANT         = P_CITY_PLANT
        S_LGORT              = P_LGORT
        S_LGORT_TEXT         = P_LGORT_TEXT
        S_EBELN              = P_EBELN
        S_DATE_PO            = P_DATE_PO
        S_DATE_PRT           = P_DATE_PRT
        S_PAY1               = P_TERM
        S_SUBTOTAL           = P_SUBTOTAL
        S_DISCOUNT           = P_DISCOUNT
        S_TAX                = P_TAX
        S_FREIGHT            = P_FREIGHT
        S_TOTAL_ORDER        = P_TOTAL_ORDER
        S_FLAG_PREV          = I_SSFCTRLOP-PREVIEW
        P_WAERS              = IT_PO-WAERS
        PO_TYPE              = V_POTYPE
        V_REV                = V_REV
        V_BG                 = V_BG
        S_VERKF              = IT_PO-VERKF
        S_EKNAM              = P_EKNAM
        S_COMPCODE           = P_COMPCODE
        S_SIGNER             = LV_SIGNER    " Add by Fiqih 31.01.2026
        S_STAMP              = LV_STAMP     " Add by Fiqih 31.01.2026
      IMPORTING
        DOCUMENT_OUTPUT_INFO = ST_DOCUMENT_OUTPUT_INFO
        JOB_OUTPUT_INFO      = ST_JOB_OUTPUT_INFO
        JOB_OUTPUT_OPTIONS   = ST_JOB_OUTPUT_OPTIONS
      TABLES
        I_ZPO_LOCAL          = I_ZPO_LOCAL.
  ENDIF.

  IF SY-XCODE EQ '9AUS'.
    CALL FUNCTION 'CONVERT_OTF_2_PDF'
      IMPORTING
        BIN_FILESIZE           = V_BIN_FILESIZE
      TABLES
        OTF                    = ST_JOB_OUTPUT_INFO-OTFDATA
        DOCTAB_ARCHIVE         = IT_DOCS
        LINES                  = IT_LINES
      EXCEPTIONS
        ERR_CONV_NOT_POSSIBLE  = 1
        ERR_OTF_MC_NOENDMARKER = 2
        OTHERS                 = 3.

*---
    CALL FUNCTION 'F4_FILENAME'
      EXPORTING
        PROGRAM_NAME  = SY-CPROG
        DYNPRO_NUMBER = SY-DYNNR
        FIELD_NAME    = ' '
      IMPORTING
        FILE_NAME     = FPATH.

    CONCATENATE FPATH '.PDF' INTO FPATH.
    DATA: V_PATH TYPE STRING.
    V_PATH = FPATH.
*---
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        BIN_FILESIZE            = V_BIN_FILESIZE
        FILENAME                = V_PATH
        FILETYPE                = 'BIN'
      TABLES
        DATA_TAB                = IT_LINES
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.
  ENDIF.   " print to PDF

ENDFORM.                    "to_pdf



*&---------------------------------------------------------------------*
*&      Form  cek_output_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_OUTPUT_TYPE.
  DATA: WA_NAST LIKE NAST OCCURS 0  WITH HEADER LINE.
  DATA: V_MSG(100).
  CLEAR IS_SAME_OTYPE.
  SELECT SINGLE * INTO WA_NAST FROM NAST WHERE KAPPL = 'EF' AND VSTAT = '1' AND OBJKY = NAST-OBJKY. "AND KSCHL NE NAST-KSCHL.
  IF SY-SUBRC = 0 AND WA_NAST-KSCHL NE NAST-KSCHL.
    IS_SAME_OTYPE = 'X'.
    CONCATENATE 'Sudah pernah dicetak dengan output type' WA_NAST-KSCHL 'PO no:' NAST-OBJKY INTO V_MSG SEPARATED BY SPACE.
    MESSAGE V_MSG TYPE 'I'.
  ELSE.
    IS_SAME_OTYPE = ''.
  ENDIF.
ENDFORM.                    "cek_output_type
*&---------------------------------------------------------------------*
*&      Form  ADD_DESCRIPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_DESCRIPTION .
  DATA : V_MTART LIKE MARA-MTART,
         V_CHARG LIKE EKET-CHARG,
         IT_INLINES TYPE TLINE OCCURS 0 WITH HEADER LINE,
         IT_LINES LIKE TLINE OCCURS 0,
         FINLINE_COUNT  LIKE SY-STEPL.

  DATA:   BEGIN OF HTEXT,                   "Struktur für Textparameter
            TDOBJECT LIKE THEAD-TDOBJECT,
            TDID     LIKE THEAD-TDID,
            TDNAME   LIKE THEAD-TDNAME,
            TDSPRAS  LIKE THEAD-TDSPRAS,
          END OF  HTEXT.

  HTEXT-TDID   = 'VERM'.
  FINLINE_COUNT = 1.
  HTEXT-TDOBJECT = 'CHARGE'.

  LOOP AT I_ZPO_LOCAL.
    SELECT SINGLE MTART INTO V_MTART FROM MARA WHERE MATNR = I_ZPO_LOCAL-ZMATNR AND MTART = 'ZRAW'.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    SELECT SINGLE CHARG INTO V_CHARG FROM EKET WHERE EBELN = P_EBELN AND EBELP = I_ZPO_LOCAL-ZNO.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    HTEXT-TDNAME = I_ZPO_LOCAL-ZMATNR.
    HTEXT-TDNAME+22(10) = V_CHARG.
    CLEAR IT_INLINES. CLEAR IT_LINES.
    REFRESH IT_INLINES. REFRESH IT_LINES.
    CALL FUNCTION 'READ_TEXT_INLINE'
      EXPORTING
        ID              = HTEXT-TDID
        INLINE_COUNT    = FINLINE_COUNT
        LANGUAGE        = SY-LANGU
        NAME            = HTEXT-TDNAME
        OBJECT          = HTEXT-TDOBJECT
      TABLES
        INLINES         = IT_INLINES
        LINES           = IT_LINES
      EXCEPTIONS
        ID              = 1
        LANGUAGE        = 2
        NAME            = 3
        NOT_FOUND       = 4
        OBJECT          = 5
        REFERENCE_CHECK = 6
        OTHERS          = 7.
    READ TABLE IT_INLINES INDEX 1.
    CONCATENATE I_ZPO_LOCAL-ZDESCRIPTION IT_INLINES-TDLINE INTO I_ZPO_LOCAL-ZDESCRIPTION SEPARATED BY SPACE.
    MODIFY I_ZPO_LOCAL TRANSPORTING ZDESCRIPTION.
*    I_ZPO_LOCAL-ZLASTVENDOR = IT_INLINES-TDLINE.
*    MODIFY I_ZPO_LOCAL TRANSPORTING ZLASTVENDOR.

  ENDLOOP.


ENDFORM.                    " ADD_DESCRIPTION

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_TO_STREAM_TEXT
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR 05.11.2018
*----------------------------------------------------------------------*
*      -->P_TEXTIN   text
*      -->P_TEXTOUT  text
*----------------------------------------------------------------------*
FORM F_CONVERT_TO_STREAM_TEXT
  USING P_TEXTIN TYPE C
  CHANGING P_TEXTOUT TYPE C.

  CLEAR: P_TEXTOUT.

  IT_CONVLINES-TDFORMAT = '*'.
  IT_CONVLINES-TDLINE = P_TEXTIN.
  APPEND IT_CONVLINES.

  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    EXPORTING
      LANGUAGE    = SY-LANGU
    TABLES
      ITF_TEXT    = IT_CONVLINES
      TEXT_STREAM = IT_TEXTTEMP.

  LOOP AT IT_TEXTTEMP INTO WA_TEXTTEMP.
    CONCATENATE P_TEXTOUT WA_TEXTTEMP INTO P_TEXTOUT SEPARATED BY SPACE.
  ENDLOOP.

ENDFORM.                    "F_CONVERT_TO_STREAM_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_DO_CONVERT
*&---------------------------------------------------------------------*
*       ADDED BY FATHIR 05.11.2018
*       Execute the process of converting ITF to STREAM_TEXT
*----------------------------------------------------------------------*
FORM F_DO_CONVERT.
  LOOP AT I_ZPO_LOCAL.

*- Convert every ITEM TEXT
    CLEAR: V_TEXTCONTAINER, IT_CONVLINES, IT_TEXTTEMP.
    REFRESH: IT_CONVLINES, IT_TEXTTEMP.
    PERFORM F_CONVERT_TO_STREAM_TEXT
    USING
       I_ZPO_LOCAL-ZTEXT
    CHANGING
       V_TEXTCONTAINER.

    I_ZPO_LOCAL-ZTEXT = V_TEXTCONTAINER.
    MODIFY I_ZPO_LOCAL TRANSPORTING ZTEXT WHERE ZNO = I_ZPO_LOCAL-ZNO AND ZMATNR = I_ZPO_LOCAL-ZMATNR.

*- Convert every ITEM DESCRIPTION
    CLEAR: V_TEXTCONTAINER, IT_CONVLINES, IT_TEXTTEMP.
    REFRESH: IT_CONVLINES, IT_TEXTTEMP.
    PERFORM F_CONVERT_TO_STREAM_TEXT
      USING
         I_ZPO_LOCAL-ZDESCRIPTION
      CHANGING
         V_TEXTCONTAINER.

    I_ZPO_LOCAL-ZDESCRIPTION = V_TEXTCONTAINER.
    MODIFY I_ZPO_LOCAL TRANSPORTING ZDESCRIPTION WHERE ZNO = I_ZPO_LOCAL-ZNO AND ZMATNR = I_ZPO_LOCAL-ZMATNR.

  ENDLOOP.

*- Convert HEADER TEXT
  CLEAR: WA_UNCONVERTEDTEXT.
  LOOP AT IT_HTEXT INTO WA_UNCONVERTEDTEXT.
    CLEAR:V_TEXTCONTAINER, IT_CONVLINES, IT_TEXTTEMP.
    REFRESH: IT_CONVLINES, IT_TEXTTEMP.
    PERFORM F_CONVERT_TO_STREAM_TEXT
      USING
         WA_UNCONVERTEDTEXT
      CHANGING
         V_TEXTCONTAINER.

    IT_HTEXT-TDLINE = V_TEXTCONTAINER.
    MODIFY IT_HTEXT TRANSPORTING TDLINE.
  ENDLOOP.

*- Convert PAYMENT TERM
  CLEAR: V_TEXTCONTAINER, IT_CONVLINES, IT_TEXTTEMP.
  REFRESH: IT_CONVLINES, IT_TEXTTEMP.
  PERFORM F_CONVERT_TO_STREAM_TEXT
    USING
       P_TERM
    CHANGING
       V_TEXTCONTAINER.
  P_TERM = V_TEXTCONTAINER.
ENDFORM.                    "F_DO_CONVERT
