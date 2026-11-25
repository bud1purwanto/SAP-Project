ENHANCEMENT 1  .

**********************************************************
* Created by: J. Budi
* Created on: 27.04.2023
* Usage: Automatic add Line & Date to VBAP
***********************************************************

    DATA: V_BUKRS LIKE T001K-BUKRS,
          V_MATKL LIKE MARA-MATKL.

    IF ( SY-TCODE = 'VA01' OR SY-TCODE = 'VA02').

    IF VBAK-AUART NE 'ZDOR' AND VBAK-AUART NE 'ZEOR' AND VBAK-AUART NE 'ZDKB' AND VBAK-AUART NE 'ZEKB' AND VBAK-AUART NE 'ZDSO' AND
       VBAK-AUART NE 'ZESO' AND VBAK-AUART NE 'ZINV' AND VBAK-AUART NE 'ZDSD' AND VBAK-AUART NE 'ZESD' AND VBAK-AUART NE 'ZDSS'.
       EXIT.
    ENDIF.

    "Check Firts Grade and Second Grade (Only first frade to check mapping)
    SELECT SINGLE MATKL INTO V_MATKL FROM MARA WHERE MATNR EQ VBAP-MATNR AND MATKL LIKE '3%'.
    IF SY-SUBRC EQ 0 AND VBAP-MATNR+0(2) EQ 'SR'.
      IF VBAP-ZDATE IS INITIAL.
        VBAP-ZDATE+0(4) = RV45A-ETDAT+6(4).
        VBAP-ZDATE+4(2) = RV45A-ETDAT+3(2).
        VBAP-ZDATE+6(2) = RV45A-ETDAT+0(2).
      ENDIF.
      "With Reference Quotation
      IF VBAP-ZDATE IS INITIAL AND VBAP-VGBEL IS NOT INITIAL AND VBAP-VGPOS IS NOT INITIAL.
        SELECT SINGLE EDATU INTO VBAP-ZDATE FROM VBEP WHERE VBELN EQ VBAP-VGBEL AND POSNR EQ VBAP-VGPOS AND ETENR EQ 0001.
      ENDIF.

      IF VBAP-ZLINE IS INITIAL.
        SELECT SINGLE BUKRS INTO V_BUKRS FROM T001K WHERE BWKEY EQ VBAP-WERKS.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE ZLINE INTO VBAP-ZLINE FROM ZMAP_PRODLINE WHERE BUKRS EQ V_BUKRS AND MATNR EQ VBAP-MATNR.
          IF VBAP-ZLINE IS INITIAL.
            MESSAGE 'Mapping production line di product group tidak ada' TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ENDIF.

*****************************************************
* Created by: PST_MONICA
* Created on: 20.09.2012
* Usage: Validasi UoM untuk Trading hanya bisa KG
*****************************************************

IF XVBAK-AUART EQ 'ZDTR' OR XVBAK-AUART EQ 'ZETR'.
  LOOP AT XVBAP.
    IF XVBAP-VRKME EQ 'M2' OR
      XVBAP-VRKME EQ 'ROL' OR
      XVBAP-VRKME EQ 'LB' OR
      XVBAP-VRKME EQ 'PAK' OR
      XVBAP-VRKME EQ 'PC'.
      MESSAGE 'UoM yang dapat digunakan untuk SO Third Party hanya KG.' TYPE 'E'.
    ENDIF.
  ENDLOOP.
ENDIF.



******************************************************
** Created by: PST_MONICA
** Created on: 31.08.2012
** Usage: Validasi Sales Unit
******************************************************
DATA:
      ZMEINS LIKE MARA-MEINS,
      ZVRKME LIKE VBAP-VRKME.


DATA: CUR_POS(20), D_SPRMSGW(100).

GET CURSOR FIELD CUR_POS.

IF ( SY-TCODE = 'VA01' OR SY-TCODE = 'VA02' OR SY-TCODE = 'ZVA02S' ) AND SY-DYNNR = '7905' AND CUR_POS = 'VBAP-VRKME'.

  IF XVBAP-VRKME IS NOT INITIAL.

    ZVRKME = VBAP-VRKME.

    SELECT MEINS INTO ZMEINS FROM MARA
        WHERE MATNR = XVBAP-MATNR.
        ENDSELECT.

    IF ZMEINS NE ZVRKME.
    CONCATENATE 'Sales Unit (SU) untuk Item ' XVBAP-POSNR ': ' XVBAP-VRKME ' berbeda dengan base uom!' INTO D_SPRMSGW SEPARATED BY SPACE.
    MESSAGE  D_SPRMSGW TYPE 'W'.
*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*         EXPORTING
*            TITEL     = 'Input Check'
*            TEXTLINE1 = d_sprmsgw
*            TEXTLINE2 = 'Have you entered the correct Sales Unit (SU) ?'.
   ENDIF.
  ENDIF.
ENDIF.


*****************************************************
* Created by: PST_ABAP
* Created on: 31.08.2012
* Usage: Validasi PO Line Item yang sama dalam 1 SO
*****************************************************


DATA : LN      TYPE N,
       COUNT   TYPE N,
       COUNT2  TYPE N,
       V_MESSAGE TYPE STRING,
       V_ITEM  TYPE VBAP-POSNR,
       V_ITEM4  TYPE VBAP-POSNR,
       V_TEMP  TYPE STRING,
       V_TEMP4  TYPE STRING,
       V_TEXT  TYPE STRING,
       V_TEXT4  TYPE STRING,
       V_POSEX TYPE VBAP-POSEX,
       WA_VBAP LIKE LINE OF XVBAP,
       V_POSNR TYPE VBAP-POSNR.

DESCRIBE TABLE XVBAP LINES LN.

READ TABLE XVBAP INDEX LN INTO WA_VBAP.
IF SY-SUBRC = 0.
  V_POSEX = WA_VBAP-POSEX.
ENDIF.

CLEAR : COUNT, COUNT2.

IF VBAK-AUART NE 'ZDCD' AND
  VBAK-AUART NE 'ZDCM' AND
  VBAK-AUART NE 'ZDKE' AND
  VBAK-AUART NE 'ZDKP' AND
  VBAK-AUART NE 'ZDKR' AND
  VBAK-AUART NE 'ZDQT' AND
  VBAK-AUART NE 'ZDRC' AND
  VBAK-AUART NE 'ZDRE' AND
  VBAK-AUART NE 'ZDSD' AND
  VBAK-AUART NE 'ZECD' AND
  VBAK-AUART NE 'ZECM' AND
  VBAK-AUART NE 'ZEKE' AND
  VBAK-AUART NE 'ZEKP' AND
  VBAK-AUART NE 'ZEKR' AND
  VBAK-AUART NE 'ZEQT' AND
  VBAK-AUART NE 'ZERC' AND
  VBAK-AUART NE 'ZERE' AND
  VBAK-AUART NE 'ZESD'
  .
LOOP AT XVBAP WHERE POSEX = V_POSEX
   "AND POSEX NE ''
  AND UPDKZ NE 'D'.

  IF XVBAP-POSEX EQ ''.
    COUNT2 = COUNT2 + 1.
    V_POSNR = XVBAP-POSNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT         = V_POSNR
     IMPORTING
      OUTPUT        = V_POSNR
            .

  CONCATENATE V_POSNR ',' INTO V_TEMP4.
  CONCATENATE V_TEXT4 V_TEMP4 INTO V_TEXT4 SEPARATED BY SPACE.

  ENDIF.

  CLEAR : V_ITEM, V_TEMP.

  IF XVBAP-POSEX NE ''.
    COUNT = COUNT + 1.
    V_ITEM = XVBAP-POSNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT         = V_ITEM
   IMPORTING
      OUTPUT        = V_ITEM
            .

  CONCATENATE V_ITEM ',' INTO V_TEMP.
  CONCATENATE V_TEXT V_TEMP INTO V_TEXT SEPARATED BY SPACE.
  ENDIF.

ENDLOOP.

IF COUNT > 1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT         = V_POSEX
   IMPORTING
      OUTPUT        = V_POSEX
            .

  CONCATENATE 'Ditemukan' COUNT 'lines untuk PO Item' V_POSEX ':' V_TEXT INTO V_MESSAGE SEPARATED BY SPACE.
  MESSAGE V_MESSAGE TYPE 'W'.
ENDIF.

* Remove karena di incompletion log sudah ada
**IF COUNT2 >= 1.
**  CONCATENATE 'Field PO Item untuk line item:' V_TEXT4 'belum diisi' INTO V_TEXT4 SEPARATED BY SPACE.
**  MESSAGE V_TEXT4 TYPE 'W'.
**ENDIF.

ENDIF.

*****************************************************
* Created by: PST_MONICA
* Created on: 31.08.2012
* Usage: Req. Type untuk Trading = kosong bukan KEL
*****************************************************

IF XVBAK-AUART EQ 'ZDTR' OR XVBAK-AUART EQ 'ZETR'.
  LOOP AT XVBAP.
    IF XVBAP-BEDAE NE ''.
      MESSAGE 'Khusus untuk SO Third Party, kosongkan field RqTy (Requirement Type) di tab Procurement Tab.' TYPE 'I'.
    ENDIF.
  ENDLOOP.
ENDIF.




ENDENHANCEMENT.
