*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHUI_DELIVERY_HU_PC_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM GET_DATA.
  DATA : P_VBELN LIKE LIKP-VBELN.

  SELECT
    VEKP~EXIDV
    VEPO~VENUM
    VEPO~UNVEL
    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV.

  LOOP AT IT_VEKP WHERE UNVEL EQ ''.
    IT_VEKP-UNVEL = IT_VEKP-VENUM.
    MODIFY IT_VEKP.
  ENDLOOP.

  IF IT_VEKP[] IS NOT INITIAL.
    SELECT
    VEKP~EXIDV
    VEKP~VENUM
    VEKP~MAGRV
    VEPO~UNVEL
    VEPO~SONUM
    VEPO~CHARG
    VEPO~VEMNG
    VEPO~VEMEH
    VEPO~MATNR
    VEPO~BESTQ

    INTO CORRESPONDING FIELDS OF TABLE IT_VBAP
    FROM VEKP
    INNER JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    FOR ALL ENTRIES IN IT_VEKP
    WHERE VEPO~VENUM = IT_VEKP-UNVEL.
  ENDIF.


  LOOP AT IT_VBAP.
    CLEAR : V_CUOBJ, V_UEVEL, IT_TEMP.
    REFRESH IT_TEMP.

    IF IT_VBAP-MAGRV = 'BOX'.
      SELECT SINGLE VEKP~UEVEL
        INTO V_UEVEL
        FROM VEKP
        WHERE VEKP~VENUM = IT_VBAP-VENUM.

      IF V_UEVEL NE ''.
        SELECT SINGLE VEKP~EXIDV
          INTO IT_VBAP-ZEXIDV
          FROM VEKP
          WHERE VEKP~VENUM = V_UEVEL.
      ENDIF.
    ENDIF.

    IF IT_VBAP-ZEXIDV EQ ''.
      IT_VBAP-ZEXIDV = IT_VBAP-EXIDV.
    ENDIF.

    "- ODO
    SELECT SINGLE VEKP~VPOBJKEY
      INTO IT_VBAP-ZVBELN
      FROM VEKP
      WHERE VEKP~EXIDV = IT_VBAP-EXIDV.

    "- Check ODO
    CLEAR : P_VBELN.
    IF IT_VBAP-ZVBELN NE ''.
      SELECT SINGLE LIKP~VBELN
        INTO P_VBELN
        FROM LIKP
        WHERE LIKP~VBELN = IT_VBAP-ZVBELN
          AND LIKP~LFART IN ('ZDLF', 'ZELF').

      IF SY-SUBRC <> 0.
        IT_VBAP-ZVBELN = ''.
      ENDIF.
    ENDIF.


    "- SO Number
    IT_VBAP-VBELN = IT_VBAP-SONUM(10).

    "- SO Item
    IT_VBAP-POSNR = IT_VBAP-SONUM+10(6).

    "- Remarks
    PERFORM READ_REMARKS.

    "- UoM SO
    SELECT SINGLE VBAP~VRKME
      INTO IT_VBAP-VRKME
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN
        AND VBAP~POSNR = IT_VBAP-POSNR.

    "- Shipping Point
    SELECT SINGLE VBAP~VSTEL
      INTO IT_VBAP-VSTEL
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN
        AND VBAP~POSNR = IT_VBAP-POSNR.

    "- Sold-to-Party
    SELECT SINGLE VBPA~KUNNR
      INTO IT_VBAP-KUNNR
      FROM VBPA
      WHERE VBPA~VBELN = IT_VBAP-VBELN
        AND VBPA~PARVW = 'AG'.

    "- Sold-to-Party Name
    SELECT SINGLE KNA1~NAME1
      INTO IT_VBAP-NAME1
      FROM KNA1
      WHERE KNA1~KUNNR = IT_VBAP-KUNNR.

    "- Ship-to-Party
    SELECT SINGLE VBPA~KUNNR
      INTO IT_VBAP-ZKUNNR
      FROM VBPA
      WHERE VBPA~VBELN = IT_VBAP-VBELN
        AND VBPA~POSNR = IT_VBAP-POSNR
        AND VBPA~PARVW = 'WE'.

    IF IT_VBAP-ZKUNNR EQ ''.
      SELECT SINGLE VBPA~KUNNR
      INTO IT_VBAP-ZKUNNR
      FROM VBPA
      WHERE VBPA~VBELN = IT_VBAP-VBELN
        AND VBPA~PARVW = 'WE'.
    ENDIF.

    "- Ship-to-Party Name
    SELECT SINGLE KNA1~NAME1
      INTO IT_VBAP-ZNAME1
      FROM KNA1
      WHERE KNA1~KUNNR = IT_VBAP-KUNNR.

    "- PO Number
    SELECT SINGLE VBAK~BSTNK
      INTO IT_VBAP-BSTNK
      FROM VBAK
      WHERE VBAK~VBELN = IT_VBAP-VBELN.

    "- Packing Status
    CLEAR : ZHU_STAT, ZHU_OK, V_SEQ.
    SELECT MAX( ZQM001~SEQ )
      INTO V_SEQ
      FROM ZQM001
      WHERE ZQM001~EXIDV = IT_VBAP-ZEXIDV.

    SELECT SINGLE ZQM001~PSTAT
      INTO ZHU_STAT
      FROM ZQM001
      WHERE ZQM001~SEQ = V_SEQ
        AND ZQM001~EXIDV = IT_VBAP-ZEXIDV.

    IF ZHU_STAT EQ 'P'.
      ZHU_STAT = 'Pass'.
    ELSEIF ZHU_STAT EQ 'H'.
      ZHU_STAT = 'Hold'.
    ELSEIF ZHU_STAT EQ ''.
      ZHU_STAT = 'Initial'.
    ENDIF.

    "- QA IN, QA OK
    CLEAR : V_STAT, V_OBJNR, V_VENUM.
    SELECT SINGLE VEKP~VENUM
      INTO V_VENUM
      FROM VEKP
      WHERE VEKP~EXIDV = IT_VBAP-ZEXIDV.

    CONCATENATE 'HU' V_VENUM INTO V_OBJNR.
    SELECT SINGLE HUSSTAT~STAT
      INTO V_STAT
      FROM HUSSTAT
      WHERE HUSSTAT~OBJNR = V_OBJNR
        AND HUSSTAT~INACT NE 'X'
        AND HUSSTAT~STAT EQ 'E0002'.

    IF SY-SUBRC <> 0.
      ZHU_OK = 'QA IN'.
    ELSE.
      ZHU_OK = 'QA OK'.
    ENDIF.

    CONCATENATE ZHU_STAT ZHU_OK INTO IT_VBAP-ZSTAT SEPARATED BY ','.

    "- Update group for statistik
    SELECT SINGLE VBAP~STAFO
      INTO IT_VBAP-STAFO
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN
        AND VBAP~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-STAFO EQ ''.
      SELECT SINGLE VBAP~STAFO
      INTO IT_VBAP-STAFO
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Currency sales doc
    SELECT SINGLE VBAP~WAERK
      INTO IT_VBAP-WAERK
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN
        AND VBAP~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-WAERK EQ ''.
      SELECT SINGLE VBAP~WAERK
      INTO IT_VBAP-WAERK
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Inco 1
    SELECT SINGLE VBKD~INCO1
      INTO IT_VBAP-INCO1
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN
        AND VBKD~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-INCO1 EQ ''.
      SELECT SINGLE VBKD~INCO1
      INTO IT_VBAP-INCO1
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Inco 2
    SELECT SINGLE VBKD~INCO2
      INTO IT_VBAP-INCO2
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN
        AND VBKD~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-INCO2 EQ ''.
      SELECT SINGLE VBKD~INCO2
      INTO IT_VBAP-INCO2
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Indicator order combination
    SELECT SINGLE VBKD~KZAZU
      INTO IT_VBAP-KZAZU
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN
        AND VBKD~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-KZAZU EQ ''.
      SELECT SINGLE VBKD~KZAZU
      INTO IT_VBAP-KZAZU
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Customer Group
    SELECT SINGLE VBKD~KDGRP
      INTO IT_VBAP-KDGRP
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN
        AND VBKD~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-KDGRP EQ ''.
      SELECT SINGLE VBKD~KDGRP
      INTO IT_VBAP-KDGRP
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Invoice date
    SELECT SINGLE VBKD~PERFK
      INTO IT_VBAP-PERFK
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN
        AND VBKD~POSNR = IT_VBAP-POSNR.

    IF IT_VBAP-PERFK EQ ''.
      SELECT SINGLE VBKD~PERFK
      INTO IT_VBAP-PERFK
      FROM VBKD
      WHERE VBKD~VBELN = IT_VBAP-VBELN.
    ENDIF.

    "- Configuration
    SELECT SINGLE VBAP~CUOBJ
      INTO V_CUOBJ
      FROM VBAP
      WHERE VBAP~VBELN = IT_VBAP-VBELN
        AND VBAP~POSNR = IT_VBAP-POSNR.

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

    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    "- Type
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC = 0.
      IT_VBAP-ZZTYPE = IT_TEMP-ATWRT.
    ENDIF.

    "- Width
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC = 0.
      IT_VBAP-ZZWIDTH = IT_TEMP-ATWRT.
    ENDIF.

    "- Length
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC = 0.
      IT_VBAP-ZZLENGTH = IT_TEMP-ATWRT.
    ENDIF.

    "- Conversion Roll/Kg
    CLEAR : ZZCONVERSIONROLLKG, V_CONV, C_CONV, C_CONV1.
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
    IF SY-SUBRC = 0.
      ZZCONVERSIONROLLKG = IT_TEMP-ATWRT.
    ENDIF.

    "- Conversion Pack/Kg
    CLEAR : ZZCONVERSIONPACKKG, V_PACK, C_PACK, C_PACK1.
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
    IF SY-SUBRC = 0.
      ZZCONVERSIONPACKKG = IT_TEMP-ATWRT.
    ENDIF.

    "- Conversion Kg/M2
    CLEAR : ZZCONVERSIONKGM2, V_M2, C_M2, C_M21.
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZCONVERSIONKGM2'.
    IF SY-SUBRC = 0.
      ZZCONVERSIONKGM2 = IT_TEMP-ATWRT.
    ENDIF.

    "- Number of Roll
    CLEAR : ZZNUMBEROFROLL, V_ROLL, C_ROLL, C_ROLL1.
    READ TABLE IT_TEMP WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
    IF SY-SUBRC = 0.
      ZZNUMBEROFROLL = IT_TEMP-ATWRT.
    ENDIF.


    IF IT_VBAP-VRKME EQ 'ROL'.
      SPLIT ZZCONVERSIONROLLKG AT SPACE INTO C_CONV C_CONV1.
      REPLACE ',' IN C_CONV WITH ''.
      V_CONV = C_CONV.
      IF V_CONV <> 0.
        IT_VBAP-ZVEMNG = IT_VBAP-VEMNG / V_CONV.

        "- Batch Qty
        IT_VBAP-VEMNG1 = IT_VBAP-VEMNG / V_CONV.

        "- Picking Qty
        IT_VBAP-VEMNG2 = IT_VBAP-VEMNG / V_CONV.
      ENDIF.

    ELSEIF IT_VBAP-VRKME EQ 'PAK'.
      SPLIT ZZCONVERSIONPACKKG AT SPACE INTO C_PACK C_PACK1.
      REPLACE ',' IN C_PACK WITH ''.
      V_PACK = C_PACK.

      IF V_PACK <> 0.
        IT_VBAP-ZVEMNG = IT_VBAP-VEMNG / V_PACK.

        "- Batch Qty
        IT_VBAP-VEMNG1 = IT_VBAP-VEMNG / V_PACK.

        "- Picking Qty
        IT_VBAP-VEMNG2 = IT_VBAP-VEMNG / V_PACK.
      ENDIF.


    ELSEIF IT_VBAP-VRKME EQ 'M2'.
      SPLIT ZZCONVERSIONKGM2 AT SPACE INTO C_M2 C_M21.
      PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.
      REPLACE RIBUAN WITH '' INTO C_M2.
      CONDENSE C_M2 NO-GAPS.
      V_M2 = C_M2.

      SPLIT ZZNUMBEROFROLL AT SPACE INTO C_ROLL C_ROLL1.
      V_ROLL = C_ROLL.

      IF V_ROLL <> 0.
        IT_VBAP-ZVEMNG = ( IT_VBAP-VEMNG / V_M2 ) / V_ROLL.

        "- Batch Qty
        IT_VBAP-VEMNG1 = ( IT_VBAP-VEMNG / V_M2 ) / V_ROLL.

        "- Picking Qty
        IT_VBAP-VEMNG2 = ( IT_VBAP-VEMNG / V_M2 ) / V_ROLL.
      ENDIF.

    ELSEIF IT_VBAP-VRKME EQ 'LB'.
      DATA : V_PEMBILANG TYPE P LENGTH 10 DECIMALS 3 VALUE '71.701',
             V_PENYEBUT  TYPE P LENGTH 10 DECIMALS 3 VALUE '32.523'.
      CLEAR : ZVEMNG.

      V_MULTI = V_PEMBILANG / V_PENYEBUT.

      IT_VBAP-ZVEMNG = IT_VBAP-VEMNG * V_MULTI.

      "- Batch Qty
      IT_VBAP-VEMNG1 = IT_VBAP-VEMNG * V_MULTI.

      "- Picking Qty
      IT_VBAP-VEMNG2 = IT_VBAP-VEMNG * V_MULTI.

    ELSE.
      IT_VBAP-ZVEMNG = IT_VBAP-VEMNG.

      "- Batch Qty
      IT_VBAP-VEMNG1 = IT_VBAP-VEMNG.

      "- Picking Qty
      IT_VBAP-VEMNG2 = IT_VBAP-VEMNG.
    ENDIF.

    MODIFY IT_VBAP.
  ENDLOOP.

  READ TABLE IT_VBAP INDEX 1 INTO WA_VBAP.
  IF SY-SUBRC = 0.
    CLEAR : P_VRKME.
    P_VRKME = WA_VBAP-VRKME.
  ENDIF.

  SORT IT_VBAP ASCENDING BY ZEXIDV SONUM.
  IT_CHANGE[] = IT_VBAP[].
  DELETE ADJACENT DUPLICATES FROM IT_VBAP COMPARING ZEXIDV SONUM.


  LOOP AT IT_VBAP.
    CLEAR : V_QTY, V_QTY2.
    LOOP AT IT_CHANGE WHERE SONUM  = IT_VBAP-SONUM
                        AND ZEXIDV = IT_VBAP-ZEXIDV.
      V_QTY  = V_QTY + IT_CHANGE-ZVEMNG.
      V_QTY2 = V_QTY2 + IT_CHANGE-VEMNG.
    ENDLOOP.
    IT_VBAP-ZVEMNG   = V_QTY.
    IT_VBAP-VEMNG    = V_QTY2.


    LOOP AT ITDATA WHERE HUNO = IT_VBAP-ZEXIDV.
      IT_VBAP-SLOCA  = ITDATA-SLOCA.
      IF ITDATA-SLOCT NE ''.
        IT_VBAP-LGORT  = ITDATA-SLOCT.
      ELSEIF ITDATA-SLOCT EQ ''.
        IF R1 = 'X'.
          IF IT_VBAP-SLOCA = '1813'.
            IT_VBAP-LGORT = '1813'.
          ENDIF.
        ELSEIF R2 = 'X'.
          IF IT_VBAP-SLOCA = '2813'.
            IT_VBAP-LGORT = '2813'.
          ENDIF.
        ELSEIF R3 = 'X'.
          IF IT_VBAP-SLOCA = '3813'.
            IT_VBAP-LGORT = '3813'.
          ENDIF.
        ENDIF.
      ENDIF.

      IT_VBAP-PLANTA = ITDATA-PLANTA.
      IT_VBAP-PLANTT = ITDATA-PLANTA.
      IT_VBAP-KET    = ITDATA-KET.
      IT_VBAP-MATDOC = ITDATA-MATDOC.
      IF IT_VBAP-LGORT EQ '1813'.
        IT_VBAP-ZVSTEL = '1000'.
      ELSEIF IT_VBAP-LGORT EQ '2813'.
        IT_VBAP-ZVSTEL = '2000'.
      ELSEIF IT_VBAP-LGORT EQ '3813'.
        IT_VBAP-ZVSTEL = '3000'.
      ENDIF.

    ENDLOOP.


    IF IT_VBAP-MATDOC EQ '-' AND IT_VBAP-LGORT EQ ''.
      IF IT_VBAP-SLOCA NE IT_VBAP-LGORT.
        IT_VBAP-ICON   = '@0A@'.
      ELSEIF IT_VBAP-SLOCA EQ IT_VBAP-LGORT.
        IT_VBAP-ICON   = '@09@'.
      ENDIF.
    ELSEIF IT_VBAP-MATDOC EQ '-' AND IT_VBAP-LGORT NE ''.
      IT_VBAP-ICON   = '@09@'.
    ELSEIF IT_VBAP-MATDOC NE '-'.
      IT_VBAP-ICON   = '@08@'.
    ENDIF.

    MODIFY IT_VBAP.
  ENDLOOP.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF IT_VBAP[] IS INITIAL.
    MESSAGE 'No data selected.' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " DISPLAY_DATA


*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECTION_SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SHIP'.
      IF S_EXIDV[] IS INITIAL.
        MESSAGE E001(00) WITH 'Please fill the HU Number.'.
        EXIT.
      ENDIF.

      IF S_EXIDV-LOW EQ ''.
        MESSAGE E001(00) WITH 'Please fill from first.'.
        EXIT.
      ENDIF.

      PERFORM VALIDASI_PLANT.
      PERFORM SET_DATA.

      "ADD BY RYAN, Project SubCont CKI 18.02.2025
      IF SY-TCODE = 'ZSD013SL'.
        DATA : V_IS_AGINGVALID(1) TYPE C.
        PERFORM VALIDASI_AGING_TIME CHANGING V_IS_AGINGVALID.
        IF V_IS_AGINGVALID NE 'X'.
          EXIT.
        ENDIF.
      ENDIF.
      "end ADD BY RYAN, Project SubCont CKI 18.02.2025

      PERFORM F_TRANSFER_FOR_GI_SALES.
  ENDCASE.

ENDFORM.                    " F_SELECTION_SCREEN


*&---------------------------------------------------------------------*
*&      Form  SET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATA .
  DATA : V_WERKS LIKE VEPO-WERKS,
         V_LGORT LIKE VEPO-LGORT,
         V_VENUM LIKE VEPO-VENUM,
         V_UNVEL LIKE VEPO-UNVEL,
         V_VRKME LIKE VBAP-VRKME,
         V_SONUM LIKE VEPO-SONUM,
         V_VBELN LIKE VBAP-VBELN,
         V_POSNR LIKE VBAP-POSNR,
         V_PSTAT LIKE ZQM001-PSTAT,
         V_SEQ   LIKE ZQM001-SEQ.

  DATA : P_KUNNR LIKE VBPA-KUNNR,
         P_KUNAG LIKE VBAK-KUNNR,
         P_VKORG LIKE VBAK-VKORG,
         P_AUTLF LIKE VBAK-AUTLF,
         P_VSBED LIKE VBAK-VSBED,
         P_AUART LIKE VBAK-AUART,
         P_LIFSK LIKE VBAK-LIFSK,
         P_STAFO LIKE VBAK-STAFO,
         P_STWAE LIKE VBAK-STWAE,
         P_KKBER LIKE VBAK-KKBER,
         P_KNKLI LIKE VBAK-KNKLI,
         P_GRUPP LIKE VBAK-GRUPP,
         P_SBGRP LIKE VBAK-SBGRP,
         P_CTLPC LIKE VBAK-CTLPC,
         P_CMWAE LIKE VBAK-CMWAE,
         P_WAERK LIKE VBAK-WAERK,
         P_INCO1 LIKE VBKD-INCO1,
         P_INCO2 LIKE VBKD-INCO2,
         P_KZAZU LIKE VBKD-KZAZU,
         P_KDGRP LIKE VBKD-KDGRP,
         P_PERFK LIKE VBKD-PERFK .

  CLEAR : V_WERKS, V_LGORT, V_VENUM, V_UNVEL, V_VRKME, V_SONUM, V_VBELN, V_POSNR.

  "- Internal HU
  SELECT SINGLE VEKP~VENUM
    INTO V_VENUM
    FROM VEKP
    WHERE VEKP~EXIDV = S_EXIDV-LOW.

  "- Lower Level
  SELECT SINGLE VEPO~UNVEL
    INTO V_UNVEL
    FROM VEPO
    WHERE VEPO~VENUM = V_VENUM.

  "- Plant and Sloc
  IF V_UNVEL EQ ''.
    SELECT SINGLE VEPO~WERKS
      INTO V_WERKS
      FROM VEPO
      WHERE VEPO~VENUM = V_VENUM.

    SELECT SINGLE VEPO~LGORT
      INTO V_LGORT
      FROM VEPO
      WHERE VEPO~VENUM = V_VENUM.

    SELECT SINGLE VEPO~SONUM
      INTO V_SONUM
      FROM VEPO
      WHERE VEPO~VENUM = V_VENUM.

  ELSEIF V_UNVEL NE ''.
    SELECT SINGLE VEPO~WERKS
      INTO V_WERKS
      FROM VEPO
      WHERE VEPO~VENUM = V_UNVEL.

    SELECT SINGLE VEPO~LGORT
      INTO V_LGORT
      FROM VEPO
      WHERE VEPO~VENUM = V_UNVEL.

    SELECT SINGLE VEPO~SONUM
      INTO V_SONUM
      FROM VEPO
      WHERE VEPO~VENUM = V_UNVEL.
  ENDIF.



  V_VBELN = V_SONUM(10).
  V_POSNR = V_SONUM+10(6).

* Sold to Party
  SELECT SINGLE VBAK~KUNNR
    INTO P_KUNAG
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Ship to Party
  SELECT SINGLE VBPA~KUNNR
    INTO P_KUNNR
    FROM VBPA
    WHERE VBPA~VBELN = V_VBELN AND
      VBPA~PARVW EQ 'WE'.

* Sales Organization
  SELECT SINGLE VBAK~VKORG
    INTO P_VKORG
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Full delivery indicator
  SELECT SINGLE VBAK~AUTLF
    INTO P_AUTLF
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Shipping Condition
  SELECT SINGLE VBAK~VSBED
    INTO P_VSBED
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Order Type
  SELECT SINGLE VBAK~AUART
    INTO P_AUART
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Delivery block
  SELECT SINGLE VBAK~LIFSK
    INTO P_LIFSK
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Update group for statistik
  SELECT SINGLE VBAK~STAFO
    INTO P_STAFO
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Statistic Currency
  SELECT SINGLE VBAK~STWAE
    INTO P_STWAE
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Credit control area
  SELECT SINGLE VBAK~KKBER
    INTO P_KKBER
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Acc. number of the cust. w/ cr.limit default
  SELECT SINGLE VBAK~KNKLI
    INTO P_KNKLI
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Cust Cr. Group
  SELECT SINGLE VBAK~GRUPP
    INTO P_GRUPP
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Processor group for cr. limit
  SELECT SINGLE VBAK~SBGRP
    INTO P_SBGRP
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Cr. Management, Risk Category
  SELECT SINGLE VBAK~CTLPC
    INTO P_CTLPC
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Currency key of cr. ctrl area
  SELECT SINGLE VBAK~CMWAE
    INTO P_CMWAE
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Currency sales doc
  SELECT SINGLE VBAK~WAERK
    INTO P_WAERK
    FROM VBAK
    WHERE VBAK~VBELN = V_VBELN.

* Inco 1
  SELECT SINGLE VBKD~INCO1
    INTO P_INCO1
    FROM VBKD
    WHERE VBKD~VBELN = V_VBELN.

* Inco 2
  SELECT SINGLE VBKD~INCO2
    INTO P_INCO2
    FROM VBKD
    WHERE VBKD~VBELN = V_VBELN.

* Indicator order combination
  SELECT SINGLE VBKD~KZAZU
    INTO P_KZAZU
    FROM VBKD
    WHERE VBKD~VBELN = V_VBELN.

* Customer Group
  SELECT SINGLE VBKD~KDGRP
    INTO P_KDGRP
    FROM VBKD
    WHERE VBKD~VBELN = V_VBELN.

* Invoice date
  SELECT SINGLE VBKD~PERFK
    INTO P_PERFK
    FROM VBKD
    WHERE VBKD~VBELN = V_VBELN.


  SELECT
    VEKP~EXIDV
    VEKP~VENUM
    VEPO~UNVEL

    INTO CORRESPONDING FIELDS OF TABLE IT_HU
    FROM VEKP
    INNER JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV.

  LOOP AT IT_HU.
    IF IT_HU-UNVEL EQ ''.
      SELECT SINGLE VEPO~LGORT
        INTO IT_HU-LGORT
        FROM VEPO
        WHERE VEPO~VENUM = IT_HU-VENUM.

      SELECT SINGLE VEPO~SONUM
        INTO IT_HU-SONUM
        FROM VEPO
        WHERE VEPO~VENUM = IT_HU-VENUM.

      CLEAR : V_VBELN.
      V_VBELN = IT_HU-SONUM(10).

* Sold to Party
      SELECT SINGLE VBAK~KUNNR
          INTO IT_HU-KUNAG
          FROM VBAK
          WHERE VBAK~VBELN = V_VBELN.

* Ship to Party
      SELECT SINGLE VBPA~KUNNR
        INTO IT_HU-KUNNR
        FROM VBPA
        WHERE VBPA~VBELN = V_VBELN AND
          VBPA~PARVW EQ 'WE'.

* Sales Organization
      SELECT SINGLE VBAK~VKORG
        INTO IT_HU-VKORG
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Full delivery indicator
      SELECT SINGLE VBAK~AUTLF
        INTO IT_HU-AUTLF
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Shipping Condition
      SELECT SINGLE VBAK~VSBED
        INTO IT_HU-VSBED
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Order Type
      SELECT SINGLE VBAK~AUART
        INTO IT_HU-AUART
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Delivery block
      SELECT SINGLE VBAK~LIFSK
        INTO IT_HU-LIFSK
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Update group for statistik
      SELECT SINGLE VBAK~STAFO
        INTO IT_HU-STAFO
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Statistic Currency
      SELECT SINGLE VBAK~STWAE
        INTO IT_HU-STWAE
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Credit control area
      SELECT SINGLE VBAK~KKBER
        INTO IT_HU-KKBER
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Acc. number of the cust. w/ cr.limit default
      SELECT SINGLE VBAK~KNKLI
        INTO IT_HU-KNKLI
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Cust Cr. Group
      SELECT SINGLE VBAK~GRUPP
        INTO IT_HU-GRUPP
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Processor group for cr. limit
      SELECT SINGLE VBAK~SBGRP
        INTO IT_HU-SBGRP
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Cr. Management, Risk Category
      SELECT SINGLE VBAK~CTLPC
        INTO IT_HU-CTLPC
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Currency key of cr. ctrl area
      SELECT SINGLE VBAK~CMWAE
        INTO IT_HU-CMWAE
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Currency sales doc
      SELECT SINGLE VBAK~WAERK
        INTO IT_HU-WAERK
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Inco 1
      SELECT SINGLE VBKD~INCO1
        INTO IT_HU-INCO1
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Inco 2
      SELECT SINGLE VBKD~INCO2
        INTO IT_HU-INCO2
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Indicator order combination
      SELECT SINGLE VBKD~KZAZU
        INTO IT_HU-KZAZU
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Customer Group
      SELECT SINGLE VBKD~KDGRP
        INTO IT_HU-KDGRP
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Invoice date
      SELECT SINGLE VBKD~PERFK
        INTO IT_HU-PERFK
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

    ELSEIF IT_HU-UNVEL NE ''.
      SELECT SINGLE VEPO~LGORT
        INTO IT_HU-LGORT
        FROM VEPO
        WHERE VEPO~VENUM = IT_HU-UNVEL.

      SELECT SINGLE VEPO~SONUM
        INTO IT_HU-SONUM
        FROM VEPO
        WHERE VEPO~VENUM = IT_HU-UNVEL.

      CLEAR : V_VBELN.
      V_VBELN = IT_HU-SONUM(10).


* Sold to Party
      SELECT SINGLE VBAK~KUNNR
        INTO IT_HU-KUNAG
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Ship to Party
      SELECT SINGLE VBPA~KUNNR
        INTO IT_HU-KUNNR
        FROM VBPA
        WHERE VBPA~VBELN = V_VBELN AND
          VBPA~PARVW EQ 'WE'.

* Sales Organization
      SELECT SINGLE VBAK~VKORG
        INTO IT_HU-VKORG
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Full delivery indicator
      SELECT SINGLE VBAK~AUTLF
        INTO IT_HU-AUTLF
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Shipping Condition
      SELECT SINGLE VBAK~VSBED
        INTO IT_HU-VSBED
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Order Type
      SELECT SINGLE VBAK~AUART
        INTO IT_HU-AUART
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Delivery block
      SELECT SINGLE VBAK~LIFSK
        INTO IT_HU-LIFSK
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Update group for statistik
      SELECT SINGLE VBAK~STAFO
        INTO IT_HU-STAFO
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Statistic Currency
      SELECT SINGLE VBAK~STWAE
        INTO IT_HU-STWAE
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Credit control area
      SELECT SINGLE VBAK~KKBER
        INTO IT_HU-KKBER
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Acc. number of the cust. w/ cr.limit default
      SELECT SINGLE VBAK~KNKLI
        INTO IT_HU-KNKLI
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Cust Cr. Group
      SELECT SINGLE VBAK~GRUPP
        INTO IT_HU-GRUPP
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Processor group for cr. limit
      SELECT SINGLE VBAK~SBGRP
        INTO IT_HU-SBGRP
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Cr. Management, Risk Category
      SELECT SINGLE VBAK~CTLPC
        INTO IT_HU-CTLPC
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Currency key of cr. ctrl area
      SELECT SINGLE VBAK~CMWAE
        INTO IT_HU-CMWAE
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Currency sales doc
      SELECT SINGLE VBAK~WAERK
        INTO IT_HU-WAERK
        FROM VBAK
        WHERE VBAK~VBELN = V_VBELN.

* Inco 1
      SELECT SINGLE VBKD~INCO1
        INTO IT_HU-INCO1
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Inco 2
      SELECT SINGLE VBKD~INCO2
        INTO IT_HU-INCO2
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Indicator order combination
      SELECT SINGLE VBKD~KZAZU
        INTO IT_HU-KZAZU
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Customer Group
      SELECT SINGLE VBKD~KDGRP
        INTO IT_HU-KDGRP
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

* Invoice date
      SELECT SINGLE VBKD~PERFK
        INTO IT_HU-PERFK
        FROM VBKD
        WHERE VBKD~VBELN = V_VBELN.

    ENDIF.


    IF IT_HU-KUNAG NE P_KUNAG.
      MESSAGE 'Sold-to-Party in HUs are different' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-KUNNR NE P_KUNNR.
      MESSAGE 'Ship-to-Party in HUs are different' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-VKORG NE P_VKORG.
      MESSAGE 'Sales Organization in HUs are different' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-AUTLF NE P_AUTLF.
      MESSAGE 'Full delivery indicator in HUs are different ( VBAK-AUTLF <> ) ' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-VSBED NE P_VSBED.
      MESSAGE 'Shipping condition in HUs are different ( VBAK-VSBED <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-AUART NE P_AUART.
      MESSAGE 'SO Type in HUs are different ( VBAK-AUART <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-LIFSK NE P_LIFSK.
      MESSAGE 'Delivery block in HUs are different ( VBAK-LIFSK <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-STAFO NE P_STAFO.
      MESSAGE 'Update grp. for statistic in HUs are different ( VBAK-STAFO <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-STWAE NE P_STWAE.
      MESSAGE 'Statistic currency in HUs are different ( VBAK-STWAE <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-KKBER NE P_KKBER.
      MESSAGE 'Cr. control area in HUs are different ( VBAK-KKBER <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-KNKLI NE P_KNKLI.
      MESSAGE 'Acc.number or cust w/ cr.limit default in HUs are different ( VBAK-VSBED <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-GRUPP NE P_GRUPP.
      MESSAGE 'Cust. Cr. Group in HUs are different ( VBAK-GRUPP <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-SBGRP NE P_SBGRP.
      MESSAGE 'Processor grp. for cr. limit in HUs are different ( VBAK-SBGRP <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-CTLPC NE P_CTLPC.
      MESSAGE 'Cr. Management, Risk Category in HUs are different ( VBAK-CTLPC <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-CMWAE NE P_CMWAE.
      MESSAGE 'Currency key of cr. ctrl area in HUs are different ( VBAK-CMWAE <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-WAERK NE P_WAERK.
      MESSAGE 'Sales doc. currency in HUs are different ( VBAK-SBGRP <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-INCO1 NE P_INCO1.
      MESSAGE 'Incoterm1 in HUs are different ( VBKD-INCO1 <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-INCO2 NE P_INCO2.
      MESSAGE 'Incoterm2 in HUs are different ( VBKD-INCO2 <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-KZAZU NE P_KZAZU.
      MESSAGE 'Indicator order combination in HUs are different ( VBKD-KZAZU <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-KDGRP NE P_KDGRP.
      MESSAGE 'Cust. group in HUs are different ( VBKD-KDGRP <> )' TYPE 'E'.
      EXIT.
    ENDIF.

    IF IT_HU-PERFK NE P_PERFK.
      MESSAGE 'Invoice date in HUs are different ( VBKD-PERFK <> )' TYPE 'E'.
      EXIT.
    ENDIF.


  ENDLOOP.

  V_VBELN = V_SONUM(10).
  V_POSNR = V_SONUM+10(6).


ENDFORM.                    " SET_DATA

*&---------------------------------------------------------------------*
*&      Form  CREATE_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_DELIVERY .
  CLEAR : V_EDATU.
  V_EDATU = LIKP-WADAT.

  LOOP AT ITAB.
    CLEAR WA_ITAB.
    READ TABLE ITAB INTO WA_ITAB.

    WA_UPLOAD-REF_DOC    = WA_ITAB-VBELN.
    WA_UPLOAD-REF_ITEM   = WA_ITAB-POSNR.
    WA_UPLOAD-DLV_QTY    = WA_ITAB-ZVEMNG.
    WA_UPLOAD-SALES_UNIT = WA_ITAB-VRKME.

    APPEND WA_UPLOAD TO IT_UPLOAD.
  ENDLOOP.

  IT_UP[] = IT_UPLOAD[].

  SORT IT_UPLOAD ASCENDING BY REF_DOC REF_ITEM.
  DELETE ADJACENT DUPLICATES FROM IT_UPLOAD COMPARING REF_DOC REF_ITEM.

  LOOP AT IT_UPLOAD.

    CLEAR: V_SUM.
    LOOP AT IT_UP WHERE REF_DOC  = IT_UPLOAD-REF_DOC
                    AND REF_ITEM = IT_UPLOAD-REF_ITEM.

      V_SUM = V_SUM + IT_UP-DLV_QTY.
    ENDLOOP.
    IT_UPLOAD-DLV_QTY = V_SUM.
    MODIFY IT_UPLOAD.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_SLS'
   EXPORTING
      SHIP_POINT              = P_VSTEL
      DUE_DATE                = V_EDATU
*     DEBUG_FLG               =
*     NO_DEQUEUE              = ' '
*   IMPORTING
*     DELIVERY                =
*     NUM_DELIVERIES          =
    TABLES
      SALES_ORDER_ITEMS       = IT_UPLOAD
*     SERIAL_NUMBERS          =
*     EXTENSION_IN            =
*     DELIVERIES              =
*     CREATED_ITEMS           =
*     EXTENSION_OUT           =
      RETURN                  = IT_RET.

  DATA: LS_SUBRC TYPE SY-SUBRC.
  LS_SUBRC = 0.


  LOOP AT IT_RET.
    IF IT_RET-TYPE EQ 'E'.
      WRITE:/ IT_RET-MESSAGE.
    ENDIF.

    IF IT_RET-TYPE EQ 'E' AND LS_SUBRC EQ 0.
      LS_SUBRC = 1.
    ENDIF.

    IF IT_RET-TYPE = 'S' AND IT_RET-ID = 'VL'.
      V_DELIVERY = IT_RET-MESSAGE(10).
    ENDIF.
  ENDLOOP.

  LOOP AT IT_RET.
    IT_ERROR-TYPE    = IT_RET-TYPE.
    IT_ERROR-ID      = IT_RET-ID.
    IT_ERROR-NUMBER  = IT_RET-NUMBER.
    IT_ERROR-MESSAGE = IT_RET-MESSAGE.
    COLLECT IT_ERROR.
  ENDLOOP.

  IF LS_SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
     EXPORTING
       WAIT          = 'X'
*         IMPORTING
*           RETURN       =
              .
    PERFORM CHANGE_BATCH.

  ELSE.
    LOOP AT IT_ERROR.
      IF IT_ERROR-TYPE EQ 'E'.
        IT_ERROR-ICON = '@0A@'.
      ELSEIF IT_ERROR-TYPE EQ 'S'.
        IT_ERROR-ICON = '@08@'.
      ELSEIF IT_ERROR-TYPE EQ 'W'.
        IT_ERROR-ICON = '@09@'.
      ELSEIF IT_ERROR-TYPE EQ 'I'.
        IT_ERROR-ICON = '@08@'.
      ENDIF.
      MODIFY IT_ERROR.
    ENDLOOP.
    PERFORM WRITE_ERROR.
  ENDIF.


ENDFORM.                    " CREATE_DELIVERY


*&---------------------------------------------------------------------*
*&      Form  POP_UP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POP_UP .

  SET PF-STATUS 'STDPOPUP'.
  CALL SCREEN 2000 STARTING AT 5    5
                   ENDING   AT 80  15.

ENDFORM.                    " POP_UP


*&---------------------------------------------------------------------*
*&      Form  CHANGE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_BATCH .
  DATA  : VAL   TYPE I,
          ZVAL  TYPE I.
  DATA  : IT_BACTH1 TYPE IT_BATCH OCCURS 0 WITH HEADER LINE.
  CLEAR   : IT_BATCH.
  REFRESH : IT_BATCH.

  LOOP AT ITAB.
    LOOP AT IT_CHANGE WHERE VBELN = ITAB-VBELN
                        AND POSNR = ITAB-POSNR
                        AND ZEXIDV = ITAB-ZEXIDV.

      IT_BATCH-VBELN  = IT_CHANGE-VBELN.
      IT_BATCH-POSNR  = IT_CHANGE-POSNR.
      IT_BATCH-CHARG  = IT_CHANGE-CHARG.
      IT_BATCH-VEMNG  = IT_CHANGE-VEMNG1.
      IT_BATCH-VEMEH  = IT_CHANGE-VEMEH.
      COLLECT IT_BATCH.
    ENDLOOP.
    P_LGORT = ITAB-LGORT.
  ENDLOOP.


  LOOP AT IT_BATCH.
    WRITE IT_BATCH-VEMNG TO IT_BATCH-CVEMNG.
    CONDENSE IT_BATCH-CVEMNG NO-GAPS.
    MODIFY IT_BATCH.
  ENDLOOP.

  DATA : N TYPE N LENGTH 1,
         M TYPE N LENGTH 1,
         K TYPE N LENGTH 1,
         L TYPE N LENGTH 1,
         ZLN TYPE I,
         LN TYPE I,
         TEMP TYPE I,
         V_FIELD(040).

  "- CTU_PARAMS
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

  CLEAR   IT_BDCDATA.
  REFRESH IT_BDCDATA.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                 V_DELIVERY.         "- DELIVERY NUMBER
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=T\04'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIPS-MATNR(03)'.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-ROUTE'.
  PERFORM BDC_FIELD       USING 'LIKP-ROUTE'
                                 V_ROUTE.           "- ROUTE
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=T\02'.


  "- Insert Batch and Quantity
  CLEAR : N, ZVAL, LN, TEMP.
  IT_BATCH2[] = IT_BATCH[].

  DESCRIBE TABLE IT_UPLOAD LINES LN.
  LOOP AT IT_UPLOAD.
    ZVAL =  ZVAL + 1.
    N = N + 1.

    IF N > 8.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=NPAG_T'.
      TEMP = ( LN - 8 ).
      LN = TEMP.
      IF TEMP >= 8.
        N = 1.
        ZVAL = 1.
      ELSE.
        N = ( 8 - TEMP ) + 1.
        ZVAL = N.
      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'LIPS-LGORT(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD       USING V_FIELD
                                      P_LGORT.           "- STORAGE LOCATION
      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=CHSP_T'.

      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'RV50A-LIPS_SELKZ(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD       USING V_FIELD
                                      'X'.
      ENDIF.

    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'LIPS-LGORT(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD       USING V_FIELD
                                      P_LGORT.           "- STORAGE LOCATION
      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=CHSP_T'.

      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'RV50A-LIPS_SELKZ(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD       USING V_FIELD
                                      'X'.
      ENDIF.
    ENDIF.

    CLEAR : M, VAL.
    LOOP AT IT_BATCH WHERE VBELN = IT_UPLOAD-REF_DOC
                       AND POSNR = IT_UPLOAD-REF_ITEM.
      VAL = VAL + 1.
      M = M + 1.

      IF M > 8.
        M = 2.
        VAL = 2.
        PERFORM BDC_DYNPRO      USING 'SAPMV50A' '3000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=POAN_T'.

      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '3000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'LIPS-CHARG(01)'.
      IF M > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'LIPS-CHARG(0' M ')' INTO V_FIELD.
        PERFORM BDC_FIELD     USING V_FIELD
                              IT_BATCH-CHARG.
      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '3000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'LIPS-LFIMG(01)'.
      IF M > 0.

        CLEAR : V_FIELD.
        CONCATENATE 'LIPS-LFIMG(0' M ')' INTO V_FIELD.
        PERFORM BDC_FIELD     USING V_FIELD
                              IT_BATCH-CVEMNG.

      ENDIF.
    ENDLOOP.

    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '3000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BACK_T'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIPS-CHARG(01)'.

  ENDLOOP.

  "- Insert Picking Quantity
  CLEAR : N, ZVAL, LN, TEMP, ZLN.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=FPAG_T'.

  DESCRIBE TABLE IT_UPLOAD LINES ZLN.
  LOOP AT IT_UPLOAD.
    ZVAL = ZVAL + 1.
    N = N + 1.

    IF N > 8.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=NPAG_T'.
      TEMP = ( ZLN - 8 ).
      ZLN = TEMP.
      IF TEMP >= 8.
        N = 1.
        ZVAL = 1.
      ELSE.
        N = ( 8 - TEMP ) + 1.
        ZVAL = N.
      ENDIF.

      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE '=CHPL_T0' N '' INTO V_FIELD.
        PERFORM BDC_FIELD     USING 'BDC_OKCODE'
                                     V_FIELD.
      ENDIF.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RV50A-CHMULT(01)'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'RV50A-LIPS_SELKZ(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD       USING V_FIELD
                                      'X'.
      ENDIF.
    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE '=CHPL_T0' N '' INTO V_FIELD.
        PERFORM BDC_FIELD     USING 'BDC_OKCODE'
                                     V_FIELD.
      ENDIF.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RV50A-CHMULT(01)'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'RV50A-LIPS_SELKZ(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD     USING V_FIELD
                                    'X'.
      ENDIF.
    ENDIF.


    M   = 1.
    VAL = 1.
    CLEAR : L, LN, TEMP, IT_BATCH, IT_BATCH3.
    REFRESH : IT_BATCH, IT_BATCH3.
    IT_BATCH3[] = IT_BATCH2[].
    IT_BATCH[]  = IT_BATCH2[].

    DELETE IT_BATCH3 WHERE VBELN EQ IT_UPLOAD-REF_DOC
                       AND POSNR EQ IT_UPLOAD-REF_ITEM.

    LOOP AT IT_BATCH3.
      LOOP AT IT_BATCH WHERE VBELN EQ IT_BATCH3-VBELN
                         AND POSNR EQ IT_BATCH3-POSNR.
        IF SY-SUBRC = 0.
          DELETE IT_BATCH.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DESCRIBE TABLE IT_BATCH LINES LN.
    LOOP AT IT_BATCH WHERE VBELN = IT_UPLOAD-REF_DOC
                       AND POSNR = IT_UPLOAD-REF_ITEM.

      VAL = VAL + 1.
      M = M + 1.
      IF M > 8.
        PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=NPAG_T'.


        TEMP = ( LN - 8 ).
        LN = TEMP.
        IF TEMP >= 8.
          M = 1.
          VAL = 1.
        ELSE.
          M = ( 8 - TEMP ).
          VAL = M.
        ENDIF.
        PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '/00'.
        CLEAR : V_FIELD.
        CONCATENATE 'LIPSD-PIKMG(0' M ')' INTO V_FIELD.
        PERFORM BDC_FIELD      USING V_FIELD
                                  IT_BATCH-CVEMNG.
      ELSE.

        PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '/00'.
        CLEAR : V_FIELD.
        CONCATENATE 'LIPSD-PIKMG(0' M ')' INTO V_FIELD.
        PERFORM BDC_FIELD      USING V_FIELD
                               IT_BATCH-CVEMNG.


      ENDIF.

    ENDLOOP.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=CHPL_T01'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV50A-CHMULT(02)'.
  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VERP_T'.

  "- Insert HU Number
  CLEAR : N, VAL.
  DELETE ADJACENT DUPLICATES FROM ITAB COMPARING EXIDV.
  LOOP AT ITAB.
    N = N + 1.
    VAL = VAL + 1.

*-- BAGUS

    IF VAL > 1.
      PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=PPLUSP'.
      PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'V51VE-EXIDV(05)'.
      PERFORM BDC_FIELD       USING 'V51VE-EXIDV(05)'
                                    ITAB-EXIDV.
    ELSE.
      PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ENTR'.
      IF N > 0.
        CLEAR : V_FIELD.
        CONCATENATE 'V51VE-EXIDV(0' N ')' INTO V_FIELD.
        PERFORM BDC_FIELD     USING V_FIELD
                                    ITAB-EXIDV.
      ENDIF.

    ENDIF.

  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BACK'.


  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH_T'.

  CALL TRANSACTION 'VL02N' USING IT_BDCDATA
                                 OPTIONS FROM OPT
                                 MESSAGES INTO IT_BDCMSGCOLL.

  COMMIT WORK AND WAIT.

  DATA : V_DEL TYPE STRING,
         V_KOSTK LIKE VBUK-KOSTK,
         V_ODO   LIKE LIKP-VBELN,
         V_BRGEW LIKE VEKP-BRGEW,
         V_NTGEW LIKE LIKP-NTGEW.


  LOOP AT IT_BDCMSGCOLL.
    IF IT_BDCMSGCOLL-MSGTYP EQ 'S' AND IT_BDCMSGCOLL-MSGNR = '311'.
      CONCATENATE IT_BDCMSGCOLL-MSGV1 'created successfully.' INTO V_DEL SEPARATED BY SPACE.
      IT_ERROR-TYPE    = IT_BDCMSGCOLL-MSGTYP.
      IT_ERROR-MESSAGE = V_DEL.
      COLLECT IT_ERROR.
    ENDIF.
  ENDLOOP.

  "- Check Picking Status
  CLEAR : V_KOSTK, V_ODO, V_BRGEW, V_NTGEW, WA_ERROR.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = V_DELIVERY
    IMPORTING
      OUTPUT = V_ODO.

  SELECT SINGLE VBUK~KOSTK
    INTO V_KOSTK
    FROM VBUK
    WHERE VBUK~VBELN =  V_ODO.

  IF V_KOSTK EQ 'C'.
    WA_ERROR-TYPE    = 'S'.
    WA_ERROR-MESSAGE = 'Picking Completely processed.'.
    APPEND WA_ERROR TO IT_ERROR.
  ELSEIF V_KOSTK EQ ''.
    WA_ERROR-TYPE    = 'E'.
    WA_ERROR-MESSAGE = 'Picking Not Relevant.'.
    APPEND WA_ERROR TO IT_ERROR.
  ELSEIF V_KOSTK EQ 'A'.
    WA_ERROR-TYPE    = 'E'.
    WA_ERROR-MESSAGE = 'Picking Not yet processed.'.
    APPEND WA_ERROR TO IT_ERROR.
  ELSEIF V_KOSTK EQ 'B'.
    WA_ERROR-TYPE    = 'E'.
    WA_ERROR-MESSAGE = 'Picking Partially processed.'.
    APPEND WA_ERROR TO IT_ERROR.
  ENDIF.

  "- Check Packing Status
  SELECT SINGLE LIKP~NTGEW
    INTO V_NTGEW
    FROM LIKP
    WHERE LIKP~VBELN = V_ODO.

  SELECT SUM( VEKP~BRGEW )
    INTO V_BRGEW
    FROM VEKP
    WHERE VEKP~VPOBJKEY = V_ODO
      AND VEKP~MAGRV EQ 'PLT'.

  CLEAR : WA_ERROR.
  IF V_NTGEW <> V_BRGEW.
    WA_ERROR-TYPE    = 'W'.
    WA_ERROR-MESSAGE = 'HU not Completely Packed.'.
    APPEND WA_ERROR TO IT_ERROR.
  ELSE.
    WA_ERROR-TYPE    = 'S'.
    WA_ERROR-MESSAGE = 'HU Completely Packed.'.
    APPEND WA_ERROR TO IT_ERROR.
  ENDIF.

  LOOP AT IT_ERROR.
    IF IT_ERROR-TYPE EQ 'S' AND IT_ERROR-ID EQ 'VL' AND IT_ERROR-NUMBER EQ '311'.
      IT_ERROR-VBELN = V_DELIVERY.
    ENDIF.

    IF IT_ERROR-TYPE EQ 'E'.
      IT_ERROR-ICON = '@0A@'.
    ELSEIF IT_ERROR-TYPE EQ 'S'.
      IT_ERROR-ICON = '@08@'.
    ELSEIF IT_ERROR-TYPE EQ 'W'.
      IT_ERROR-ICON = '@09@'.
    ELSEIF IT_ERROR-TYPE EQ 'I'.
      IT_ERROR-ICON = '@08@'.
    ENDIF.
    MODIFY IT_ERROR.
  ENDLOOP.

  PERFORM WRITE_ERROR.

ENDFORM.                    " CHANGE_BATCH

*&--------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&--------------------------------------------------------------------*
*           text
*---------------------------------------------------------------------*
*          -->PROG       text
*          -->SCR        text
*---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*&--------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*          -->FNAM       text
*          -->FVAL       text
* ---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  VALIDASI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDASI .
  CLEAR : ITAB, ITAB2, IT_ERROR, IT_RET, IT_UPLOAD, IT_EDATU, V_DELIVERY, V_EDATU, V_KUNNR, WA_ITAB.
  REFRESH : ITAB, ITAB2, IT_ERROR, IT_RET, IT_UPLOAD, IT_EDATU.
  ITAB[] = IT_VBAP[].

  DELETE ITAB WHERE BOX NE 'X'.
  ITAB2[] = ITAB[].

  IF ITAB[] IS INITIAL .
    MESSAGE 'No Data Selected, select at least one line.' TYPE 'I'.
    EXIT.
  ENDIF.

  "- Selection Date
  SELECT VBEP~EDATU
    INTO CORRESPONDING FIELDS OF TABLE IT_EDATU
    FROM VBEP
    FOR ALL ENTRIES IN ITAB
    WHERE VBEP~VBELN = ITAB-VBELN.

  SORT IT_EDATU DESCENDING BY EDATU.
  READ TABLE IT_EDATU INDEX 1 INTO ZEDATU.
  READ TABLE IT_EDATU INDEX 1 INTO V_EDATU.


  READ TABLE ITAB INDEX 1 INTO WA_ITAB.
  IF SY-SUBRC = 0.
    V_KUNNR = WA_ITAB-ZKUNNR.
  ENDIF.

  LOOP AT ITAB.
    IF ITAB-LGORT EQ ''.
      MESSAGE 'HU(s) are not transfered yet. Delivery can not be created.' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZSTAT CS 'Hold' OR ITAB-ZSTAT CS 'Initial'.
      MESSAGE 'Input HU might contains status hold or init. Can not be processed.' TYPE 'E'.
      EXIT.
    ENDIF.

    "- Transfer HU
    CLEAR : V_LGORT, V_BMENG.
    SELECT SINGLE VEPO~UNVEL
      INTO V_UNVEL
      FROM VEPO
      INNER JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
      WHERE VEKP~EXIDV = ITAB-ZEXIDV.

    IF V_UNVEL EQ ''.
      SELECT SINGLE VEPO~LGORT
        INTO V_LGORT
        FROM VEPO
        INNER JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
        WHERE VEKP~EXIDV = ITAB-ZEXIDV.
    ELSE.
      SELECT SINGLE VEPO~LGORT
      INTO V_LGORT
      FROM VEPO
      WHERE VEPO~VENUM = V_UNVEL.
    ENDIF.



    IF V_LGORT NE '2813' AND V_LGORT NE '1813' AND V_LGORT NE '3813'.
      MESSAGE 'HU(s) might contains wrong Sloc.' TYPE 'E'.
      EXIT.
    ENDIF.

    "- Schedule Line
    SELECT SUM( VBEP~BMENG )
      INTO V_BMENG
      FROM VBEP
      WHERE VBEP~VBELN = ITAB-VBELN
        AND VBEP~POSNR = ITAB-POSNR.

    IF V_BMENG EQ 0.
      MESSAGE 'Cek Schedule Lines in SO' TYPE 'E'.
      EXIT.
    ENDIF.


    CLEAR : V_VBELN.
    SELECT SINGLE VEKP~VPOBJKEY
      INTO V_VBELN
      FROM VEKP
      WHERE VEKP~EXIDV = ITAB-ZEXIDV.

    SELECT SINGLE LIKP~VBELN
      INTO V_VBELN
      FROM LIKP
      WHERE LIKP~VBELN = V_VBELN
        AND LIKP~LFART IN ('ZDLF', 'ZELF' ).

    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CONCATENATE 'HU has been created in ODO :' V_VBELN INTO V_TEXT SEPARATED BY SPACE.
      MESSAGE V_TEXT TYPE 'E'.
      EXIT.
    ENDIF.

    "- HU Status
    CLEAR : V_STAT, V_OBJNR, V_VENUM.
    SELECT SINGLE VEKP~VENUM
      INTO V_VENUM
      FROM VEKP
      WHERE VEKP~EXIDV = ITAB-ZEXIDV.


    CONCATENATE 'HU' V_VENUM INTO V_OBJNR.
    SELECT SINGLE HUSSTAT~STAT
      INTO V_STAT
      FROM HUSSTAT
      WHERE HUSSTAT~OBJNR = V_OBJNR
        AND HUSSTAT~INACT NE 'X'
        AND HUSSTAT~STAT EQ 'E0002'.

    IF SY-SUBRC <> 0.
      MESSAGE 'Cek HU status. HU QA IN not permitted to delivery.' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-VSTEL NE ITAB-ZVSTEL.
      MESSAGE 'Shipping Point in HU and SO is different, change shipping point in SO first!' TYPE 'E'.
      EXIT.
    ENDIF.

    "- Cek PO
    LOOP AT ITAB2.
      IF ITAB-BSTNK NE ITAB2-BSTNK.
        MESSAGE 'PO number different. Can not combine into one delivery.' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.


    LOOP AT ITAB2 WHERE VBELN = ITAB-VBELN.
      IF ITAB-LGORT NE ITAB2-LGORT.
        MESSAGE 'HU contains different Sloc' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-ZKUNNR NE ITAB2-ZKUNNR.
        MESSAGE 'Can not create ODO, different Ship-to-Party per SO item. Choose line with same Ship-to-Party.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-STAFO NE ITAB2-STAFO.
        MESSAGE 'Can not create ODO, different Group for Statistic per SO item. Choose line with same Group for Statistic.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-WAERK NE ITAB2-WAERK.
        MESSAGE 'Can not create ODO, different Currency per SO item. Choose line with same Currency.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-INCO1 NE ITAB2-INCO1.
        MESSAGE 'Can not create ODO, different Inco 1 per SO item. Choose line with same Inco 1.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-INCO2 NE ITAB2-INCO2.
        MESSAGE 'Can not create ODO, different Inco 2 per SO item. Choose line with same Inco 2.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-KZAZU NE ITAB2-KZAZU.
        MESSAGE 'Can not create ODO, different Order Combination per SO item. Choose line with same Order Combination.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-KDGRP NE ITAB2-KDGRP.
        MESSAGE 'Can not create ODO, different Customer Group per SO item. Choose line with same Customer Group.' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-PERFK NE ITAB2-PERFK.
        MESSAGE 'Can not create ODO, different Invoice Date per SO item. Choose line with same Invoice Date.' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF ITAB-LGORT NE '1813' AND ITAB-LGORT NE '2813' AND ITAB-LGORT NE '3813'.
      MESSAGE 'Delivery Sloc must be from 1813 or 2813 or 3813' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-BESTQ NE ''.
      MESSAGE 'HU can be in Quality Control, Return Stock, or Block Stock. Delivery can not be processed.' TYPE 'E'.
      EXIT.
    ENDIF.

    LOOP AT IT_VBAP WHERE EXIDV = ITAB-EXIDV
                      AND BOX NE 'X'.
      IF SY-SUBRC = 0.
        MESSAGE 'HU Number contains incomplete SONUM' TYPE 'E'.
      ENDIF.
    ENDLOOP.

    CLEAR : V_VBELN, V_POSNR.
    V_VBELN = ITAB-VBELN.
    V_POSNR = ITAB-POSNR.
  ENDLOOP.

  PERFORM POP_UP.

ENDFORM.                    " VALIDASI


*&---------------------------------------------------------------------*
*&      Form  GET_DEC_NOTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_RIBUAN  text
*      <--P_PULUHAN  text
*----------------------------------------------------------------------*
FORM GET_DEC_NOTATION  CHANGING RIBUAN PULUHAN.
  DATA: USR01_EXP LIKE USR01.

  CALL FUNCTION 'CETA_USR01_READ'
    EXPORTING
      BNAME     = SY-UNAME
    IMPORTING
      USR01_EXP = USR01_EXP
    EXCEPTIONS
      NO_ENTRY  = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

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

ENDFORM.                    " GET_DEC_NOTATION


*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_FOR_GI_SALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_TRANSFER_FOR_GI_SALES .
  CLEAR : ITDATA ,WADATA.
  REFRESH : ITDATA.

  "CHECK PLANT
  SELECT DISTINCT VEKP~EXIDV AS HUNO
    VEPO~WERKS AS PLANTA
    INTO CORRESPONDING FIELDS OF TABLE ITDATA
    FROM VEKP
    JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV
      AND VEKP~UEVEL = ''.

  LOOP AT ITDATA.

    PERFORM F_GET_SLOC USING ITDATA-HUNO ITDATA-PLANTA. " add new company

    "CHECK PLANT
    IF ( R1 = 'X' ).
      IF ITDATA-PLANTA <> '1000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Waru'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.
    ELSEIF ( R2 = 'X' ).
      IF ITDATA-PLANTA <> '2000'.
        IF ITDATA-PLANTA NE ''.
          ITDATA-KET = 'Plant Asal tidak berada di Area Krian'.
          ITDATA-MATDOC = '-'.

          SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        ENDIF.
      ENDIF.

    ENDIF.

    IF ITDATA-KET = ''.
      "GET SLOC ASAL
      CLEAR : UNVEL.
      SELECT SINGLE VEPO~UNVEL
          INTO UNVEL
          FROM VEPO JOIN VEKP
          ON VEPO~VENUM = VEKP~VENUM
          WHERE VEKP~EXIDV = ITDATA-HUNO.

      IF UNVEL = ''.
        SELECT SINGLE VEPO~LGORT
           INTO ITDATA-SLOCA
           FROM VEPO
           JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
           WHERE VEKP~EXIDV = ITDATA-HUNO.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( R1 = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( R2 = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( R3 = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.

            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.

      ELSE. "Jika masih ada high level HU
        SELECT SINGLE VEPO~LGORT VEPO~WERKS
            INTO (ITDATA-SLOCA,ITDATA-PLANTA)
            FROM VEPO
            WHERE VEPO~VENUM = UNVEL.

        IF ITDATA-SLOCA = ''.
          ITDATA-KET = 'Error, Sloc Asal Kosong'.
          ITDATA-MATDOC = '-'.
          ITDATA-SLOCA = '-'.
        ELSE.

          "CHECK SLOC FROM ZHU_MAPP
          CLEAR INDICATOR.
          IF ITDATA-SLOCA NOT IN RSLOCA.
            INDICATOR = ITDATA-SLOCA+0(1).
            IF ( R1 = 'X' ).
              IF INDICATOR = '1'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Waru'.
              ENDIF.
            ELSEIF ( R2 = 'X' ).
              IF INDICATOR = '2'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Krian'.
              ENDIF.
            ELSEIF ( R3 = 'X' ).
              IF INDICATOR = '3'.
                ITDATA-KET = 'Error, Sloc Asal salah'.
              ELSE.
                ITDATA-KET = 'Error, Sloc Asal tidak berada di Area Jakarta'.
              ENDIF.
            ENDIF.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ITDATA-KET = ''.
        "GET SLOC DAN PLANT TUJUAN
        SELECT SINGLE ZHU_MAPP~WERK2 ZHU_MAPP~LGOR2
              INTO (ITDATA-PLANTT, ITDATA-SLOCT)
              FROM ZHU_MAPP
              WHERE ZHU_MAPP~TYPES = TYPE
              AND ZHU_MAPP~WERK1 = ITDATA-PLANTA
              AND ZHU_MAPP~LGOR1 = ITDATA-SLOCA.

        "CHECK SLOC TUJUAN
        IF ITDATA-SLOCT = ''.
          ITDATA-KET = 'Error, SLoc Tujuan Kosong'.
          ITDATA-MATDOC = '-'.
        ELSE.
          IF  ITDATA-SLOCT NOT IN RSLOCT.
            ITDATA-KET = 'Error, SLoc Tujuan Salah'.
            ITDATA-MATDOC = '-'.
          ENDIF.
        ENDIF.


        IF ITDATA-SLOCA = ITDATA-SLOCT.
          ITDATA-KET = 'Error, SLoc Asal sama dengan SLoc tujuan'.
          ITDATA-MATDOC = '-'.
        ENDIF.

        IF  ITDATA-KET = ''..

          "GET INTERNAL HU
          CLEAR VENUM.
          SELECT SINGLE VEKP~VENUM
             INTO VENUM
             FROM VEKP
             WHERE VEKP~EXIDV = ITDATA-HUNO.

          "GET STATUS HU
          CLEAR : STATUS.
          CONCATENATE 'HU' VENUM INTO OBJNR.
          SELECT SINGLE TJ30T~TXT04
             INTO STATUS
             FROM TJ30T
             JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
             JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
             WHERE HUSSTAT~OBJNR = OBJNR
             AND HUSSTAT~STAT = TJ30T~ESTAT
             AND HUSSTAT~INACT = ''
             AND TJ30T~SPRAS = 'EN'.

          IF STATUS = ''.
            ITDATA-KET = 'Error, Status HU kosong'.
            ITDATA-MATDOC = '-'.
          ELSEIF STATUS <> 'QAOK'.
            ITDATA-KET = 'Error, Status HU tidak QAOK'.
            ITDATA-MATDOC = '-'.
          ENDIF.

          IF ITDATA-KET = ''.

            "GET MAX DATE AND TIME STATUS HU
            CLEAR : VAEDAT , VAETIME.
            SELECT MAX( ZQM001~AEDAT )
              INTO VAEDAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO.

            SELECT MAX( ZQM001~AETIME )
              INTO VAETIME
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT.

            "GET STATUS PASS/HOLD.
            CLEAR PSTAT.
            SELECT SINGLE ZQM001~PSTAT
              INTO PSTAT
              FROM ZQM001
              WHERE ZQM001~EXIDV = ITDATA-HUNO
              AND ZQM001~AEDAT = VAEDAT
              AND ZQM001~AETIME = VAETIME.

            IF PSTAT NE 'P'.
              ITDATA-KET = 'Status HU is not Pass'.
              ITDATA-MATDOC = '-'.
            ENDIF.

            "MOVE HU
            IF ITDATA-KET = ''.

              "convert HU
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT  = ITDATA-HUNO
                IMPORTING
                  OUTPUT = ITDATA-HUNO.

*              CLEAR : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.
              REFRESH : IT_MOVE_TO, IT_EXTERNAL_ID, ES_MESSAGE, ET_MESSAGES.

              IT_MOVE_TO-LGORT = ITDATA-SLOCT.
              IT_MOVE_TO-WERKS = ITDATA-PLANTT.
              APPEND IT_MOVE_TO.
              MOVE ITDATA-HUNO TO IT_EXTERNAL_ID-EXIDV.
              APPEND  IT_EXTERNAL_ID.

              IF R1 = 'X'.
                IF_EVENT = '0007'.
              ELSE.
                IF_EVENT = '0006'.
              ENDIF.

              CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
                EXPORTING
                  IF_EVENT       = IF_EVENT
                  IF_TCODE       = 'VLMOVE'
                  IT_MOVE_TO     = IT_MOVE_TO[]
                  IT_EXTERNAL_ID = IT_EXTERNAL_ID[]
                IMPORTING
                  ES_MESSAGE     = ES_MESSAGE
                  ET_MESSAGES    = ET_MESSAGES[].

              IF SY-SUBRC = 0.

                READ TABLE ES_MESSAGE WITH KEY MSGTY = 'E'.
*
                IF SY-SUBRC = 0.
                  ITDATA-KET = 'Error, Transfer HU Gagal'.
                  ITDATA-MATDOC = '-'.
                ELSE.

                  LOOP AT ET_MESSAGES.
                    "JIKA ERROR
                    IF ET_MESSAGES-MSGTY = 'E'.
                      ITDATA-MATDOC = ''.
                    ELSE.
                      ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                    ENDIF.
                  ENDLOOP.

                  IF ITDATA-MATDOC = ''.
                    ITDATA-KET = 'Error, Transfer HU Gagal'.
                    ITDATA-MATDOC = '-'.
                  ELSE.
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        WAIT = 'X'.

                    "UPDATE DATA IN ZPACKPCL.
                    CLEAR : WA_PSOURCE, T_PSOURCE,VENUM.
                    REFRESH : T_PSOURCE.
                    SELECT SINGLE VENUM INTO VENUM FROM VEKP WHERE VEKP~EXIDV = ITDATA-HUNO.

                    SELECT SINGLE * INTO WA_PSOURCE FROM ZPACK_PCL WHERE VENUM = VENUM.
                    WA_PSOURCE-FM = 'X'.
                    UPDATE ZPACK_PCL FROM WA_PSOURCE.
                    COMMIT WORK AND WAIT.

                    "GET ALL DATA FROM ZPACKPCL (BOX)
                    SELECT * INTO CORRESPONDING FIELDS OF TABLE T_PSOURCE
                      FROM ZPACK_PCL
                      WHERE HUSEQ_P = WA_PSOURCE-HUSEQ
                      AND VENUM NE ''
                      AND PINNR = WA_PSOURCE-PINNR .

                    IF SY-SUBRC = 0.
                      CLEAR WA_PSOURCE.
                      LOOP AT T_PSOURCE INTO WA_PSOURCE.
                        WA_PSOURCE-FM = 'X'.
                        UPDATE ZPACK_PCL FROM WA_PSOURCE.
                        COMMIT WORK AND WAIT.
                      ENDLOOP.
                    ENDIF.


                    ITDATA-MATDOC = ET_MESSAGES-MSGV1.
                    ITDATA-KET = 'Transfer HU Sukses'.
                  ENDIF.
                ENDIF.
              ELSE.
                ITDATA-MATDOC = '-'.
                ITDATA-KET = 'Error, Transfer HU Gagal'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY ITDATA.
  ENDLOOP.

  "CHECK LOCKING.
  CLEAR WADATA.
  READ TABLE ITDATA INTO WADATA WITH KEY MATDOC = '-'.

  IF SY-SUBRC = 0.
    LOOP AT ITDATA.
      REFRESH : IT_BDCDATA, IT_BDCMSGCOLL.
      "CANCEL TRANSFER HU
      IF ITDATA-MATDOC NE '-'.
        PERFORM BDC_DYNPRO      USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=ONLI'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'SP_MBLNR'.
        PERFORM BDC_FIELD       USING 'SP_PSTDA'
                                      DATE.
        PERFORM BDC_FIELD       USING 'SP_MBLNR'
                                      ITDATA-MATDOC.
        PERFORM BDC_FIELD       USING 'SP_MJAHR'
                                      YYYY.

        CALL TRANSACTION 'HUCANC' USING IT_BDCDATA
                MODE 'E'
                UPDATE 'S'
                MESSAGES INTO IT_BDCMSGCOLL.

        ITDATA-KET = 'HU OK, Not transferred'.
        ITDATA-MATDOC = '-'.
      ELSE.
        IF ITDATA-KET = 'Error, Transfer HU Gagal'..
          ITDATA-KET = 'HU Locked, Not Transferred'.
          ITDATA-MATDOC = '-'.
        ENDIF.
      ENDIF.
      MODIFY ITDATA.
    ENDLOOP.

    CLEAR VLINE.
    DESCRIBE TABLE ITDATA LINES VLINE.
    IF VLINE = 1.
      MESSAGE 'HU Not Transferred.' TYPE 'I'.
    ELSE.
      MESSAGE 'All HU are Not Transferred.' TYPE 'I'.
    ENDIF.
  ENDIF.

  PERFORM GET_DATA.
  PERFORM DISPLAY_DATA.

ENDFORM.                    " F_TRANSFER_FOR_GI_SALES


*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM F_GET_SLOC.
FORM F_GET_SLOC USING HUNO PLANTA .
  TYPE = '9'.

  "GET DATA SLOC
  CLEAR : ITSLOC, RSLOCA, RSLOCT, WSLOC.
  REFRESH : ITSLOC, RSLOCA, RSLOCT.

  IF R1 = 'X'. "WARU AREA
    " GET DATA SLOC ASAL FOR WARU AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '1%'
      AND ZHU_MAPP~WERK1 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR WARU AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    IF R1 = 'X'.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '1%'
      AND ZHU_MAPP~WERK2 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.
    ELSE.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '1%'
      AND ZHU_MAPP~WERK2 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.
    ENDIF.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.

  ELSEIF R2 = 'X'.  "KRIAN AREA
    " GET DATA SLOC ASAL FOR KRIAN AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '2%'
      AND ZHU_MAPP~WERK1 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR KRIAN AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.

    IF R2 = 'X'.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '2%'
      AND ZHU_MAPP~WERK2 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.
    ELSE.
      SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '2%'
      AND ZHU_MAPP~WERK2 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.
    ENDIF.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.

  ELSEIF R3 = 'X'. "JAKARTA AREA

    " GET DATA SLOC ASAL FOR JAKARTA AREA
    SELECT DISTINCT ZHU_MAPP~LGOR1 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR1 LIKE '3%'
      AND ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCA.
    ENDLOOP.

    " GET DATA SLOC TUJUAN FOR JAKARTA AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~TYPES = TYPE.

    LOOP AT ITSLOC.
      WSLOC-SIGN   = 'I'.
      WSLOC-OPTION = 'EQ'.
      WSLOC-LOW    = ITSLOC-SLOC.
      APPEND WSLOC TO RSLOCT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_GET_SLOC


*&---------------------------------------------------------------------*
*&      Form  READ_REMARKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_REMARKS .
  CLEAR : P_NAME.
  REFRESH : IT_LINE.

  P_NAME = IT_VBAP-VBELN.

  CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                        = SY-MANDT
        ID                            = 'Z010'
        LANGUAGE                      = SY-LANGU
        NAME                          = P_NAME
        OBJECT                        = 'VBBK'
*       ARCHIVE_HANDLE                = 0
*       LOCAL_CAT                     = ' '
*     IMPORTING
*       HEADER                        =
*       OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8.

  READ TABLE IT_LINE INTO WA_LINE.
  IF SY-SUBRC = 0.
    IT_VBAP-ZREMARKS = WA_LINE-TDLINE.
  ENDIF.

ENDFORM.                    " READ_REMARKS

*&---------------------------------------------------------------------*
*&      Form  VALIDASI_PLANT
*&---------------------------------------------------------------------*
*       add new company
*----------------------------------------------------------------------*
FORM VALIDASI_PLANT.

  DATA : BEGIN OF LMSG OCCURS 0,
          MSGID  LIKE SY-MSGID,
          MSGTY  LIKE SY-MSGTY,
          MSGNO  LIKE SY-MSGNO,
          MSGV1  LIKE SY-MSGV1,
          MSGV2  LIKE SY-MSGV2,
          MSGV3  LIKE SY-MSGV3,
          MSGV4  LIKE SY-MSGV4,
          LINENO TYPE MESG-ZEILE,
        END OF LMSG.

  DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
        IT_EXIDV TYPE HUM_EXIDV_T,
        WA_VEPO LIKE VEPOVB OCCURS 0 WITH HEADER LINE,
        V_TMP3 LIKE VEKP-EXIDV,
        V_TMP4 LIKE VEKP-EXIDV,
        V_TMP1 TYPE P,
        V_TMP2 TYPE P,
        LMSG2 LIKE LMSG OCCURS 0,
        VNO TYPE I VALUE 1.
  RANGES: PLANT FOR MARC-WERKS,
          V_HU FOR VEKP-EXIDV.

  PLANT-SIGN = 'I'.
  PLANT-OPTION = 'EQ'.
  PLANT-LOW = '1000'.
  APPEND PLANT.

  PLANT-SIGN = 'I'.
  PLANT-OPTION = 'EQ'.
  PLANT-LOW = '2000'.
  APPEND PLANT.

  V_HU[] = S_EXIDV[].
*  V_BUDAT_TEMP[] = V_BUDAT[].
  V_HU-SIGN = 'I'.
  V_HU-OPTION = 'EQ'.
  CLEAR: V_HU-HIGH.
  LOOP AT S_EXIDV WHERE OPTION = 'BT'.
    V_TMP3 = S_EXIDV-LOW.
    V_TMP4 = S_EXIDV-HIGH.
    SHIFT V_TMP3 LEFT DELETING LEADING '0'.
    SHIFT V_TMP4 LEFT DELETING LEADING '0'.
    V_TMP1 = V_TMP3.
    V_TMP2 = V_TMP4.

    WHILE V_TMP1 <= V_TMP2.
      V_HU-LOW = V_TMP1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_HU-LOW
        IMPORTING
          OUTPUT = V_HU-LOW.

      APPEND V_HU.
      V_TMP1 = V_TMP1 + 1.
    ENDWHILE.
  ENDLOOP.

  DELETE V_HU WHERE OPTION = 'BT'.

  LOOP AT V_HU.
    APPEND V_HU-LOW TO IT_EXIDV.
    CALL FUNCTION 'HU_GET_HUS_DB'
      EXPORTING
        IT_HU_NUMBERS = IT_EXIDV
      IMPORTING
        ET_HU_ITEMS   = IT_VEPO.

    LOOP AT IT_VEPO INTO WA_VEPO WHERE CHARG IS NOT INITIAL.
    ENDLOOP.

    IF WA_VEPO-WERKS NOT IN PLANT.
      SHIFT V_HU-LOW LEFT DELETING LEADING '0'.
      CONCATENATE V_HU-LOW 'Bukan Plant Trias' INTO LMSG-MSGV1 SEPARATED BY SPACE.
      LMSG-MSGID = '00'.
      LMSG-MSGTY = 'E'.
      LMSG-MSGNO = '1'.
      LMSG-LINENO = VNO.
      APPEND LMSG.
    ENDIF.
    CLEAR: IT_EXIDV.
    REFRESH: IT_EXIDV.
  ENDLOOP.

  IF LMSG[] IS NOT INITIAL.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = LMSG.
    STOP.
  ENDIF.

  CLEAR: IT_VEPO,IT_EXIDV,LMSG.
  REFRESH: IT_VEPO,IT_EXIDV,LMSG.
ENDFORM.                    "VALIDASI_PLANT
*&---------------------------------------------------------------------*
*&      Form  VALIDASI_AGING_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
* ADD BY RYAN, Project Laminator #2 #3 24.01.2025
*----------------------------------------------------------------------*
FORM VALIDASI_AGING_TIME CHANGING P_IS_AGINGVALID.
  DATA: BEGIN OF IT_TEMP_NOROLL OCCURS 0,
         STRING LIKE AUSP-ATWRT,
        END OF IT_TEMP_NOROLL.

  DATA: BEGIN OF IT_NOROLL OCCURS 0,
          MATNR   LIKE MCH1-MATNR,
          CHARG   LIKE MCH1-CHARG,
          NOROLL  LIKE AUSP-ATWRT,
          ERSDA   LIKE MCH1-ERSDA,
          ERNAM   LIKE MCH1-ERNAM,
          OBJEK   LIKE AUSP-OBJEK,
          ATINN   LIKE AUSP-ATINN,
          ATWRT   LIKE AUSP-ATWRT,
        END OF IT_NOROLL.

  DATA: BEGIN OF IT_FINAL_MKPF OCCURS 0,
          MBLNR   LIKE MKPF-MBLNR,
          MJAHR   LIKE MKPF-MJAHR,
          BUDAT   LIKE MKPF-BUDAT,
          CPUTM   LIKE MKPF-CPUTM,
          BKTXT   LIKE MKPF-BKTXT,
        END OF IT_FINAL_MKPF.

  DATA : BEGIN OF LMSG_AGING OCCURS 0,
          MSGID  LIKE SY-MSGID,
          MSGTY  LIKE SY-MSGTY,
          MSGNO  LIKE SY-MSGNO,
          MSGV1  LIKE SY-MSGV1,
          MSGV2  LIKE SY-MSGV2,
          MSGV3  LIKE SY-MSGV3,
          MSGV4  LIKE SY-MSGV4,
          LINENO TYPE MESG-ZEILE,
        END OF LMSG_AGING.

  DATA: BEGIN OF IT_AUSP OCCURS 0,
          MATNR   LIKE MCH1-MATNR,
          CHARG   LIKE MCH1-CHARG,
          ERSDA   LIKE MCH1-ERSDA,
          ERNAM   LIKE MCH1-ERNAM,
          OBJEK   LIKE AUSP-OBJEK,
          ATINN   LIKE AUSP-ATINN,
          KLART   LIKE AUSP-KLART,
          ATWRT   LIKE AUSP-ATWRT,
          ATFLV   LIKE AUSP-ATFLV,
        END OF IT_AUSP.

  DATA: BEGIN OF IT_MKPF OCCURS 0,
          MBLNR   LIKE MKPF-MBLNR,
          MJAHR   LIKE MKPF-MJAHR,
          BKTXT   LIKE MKPF-BKTXT,
          BUDAT   LIKE MKPF-BUDAT,
          CPUTM   LIKE MKPF-CPUTM,
          MATNR   LIKE MCH1-MATNR,
          CHARG   LIKE MCH1-CHARG,
          NOROLL  LIKE AUSP-ATWRT,
          BWART   LIKE AUFM-BWART,
        END OF IT_MKPF.

  DATA : IT_EXIDV_AGING TYPE HUM_EXIDV_T,
         IT_VEPO_AGING LIKE VEPOVB OCCURS 0,
         IT_MCH1 LIKE MCH1 OCCURS 0 WITH HEADER LINE,
*         IT_AUSP LIKE AUSP OCCURS 0 WITH HEADER LINE,
*         IT_MKPF LIKE MKPF OCCURS 0 WITH HEADER LINE,
         IT_AUFM LIKE AUFM OCCURS 0 WITH HEADER LINE,
         V_TEMP_NOROLL LIKE AUSP-ATWRT,
         V_TIME_MKPF  TYPE TIMESTAMPL,
         V_TIME_NOW  TYPE TIMESTAMPL,
         V_IS_VALID(1) TYPE C
        .

  LOOP AT S_EXIDV.
    APPEND S_EXIDV-LOW TO IT_EXIDV_AGING.
    CALL FUNCTION 'HU_GET_HUS_DB'
      EXPORTING
        IT_HU_NUMBERS = IT_EXIDV_AGING
      IMPORTING
        ET_HU_ITEMS   = IT_VEPO_AGING.

    CLEAR: IT_EXIDV_AGING.
    REFRESH: IT_EXIDV_AGING.
  ENDLOOP.

  SELECT *
    FROM MCH1
    INTO CORRESPONDING FIELDS OF TABLE IT_MCH1
    FOR ALL ENTRIES IN IT_VEPO_AGING
    WHERE MCH1~CHARG EQ IT_VEPO_AGING-CHARG
    .

  IF SY-SUBRC EQ 0.
    REFRESH IT_AUSP.
    LOOP AT IT_MCH1.
      SELECT
          AUSP~OBJEK
          AUSP~ATINN
          AUSP~KLART
          AUSP~ATWRT
          AUSP~ATFLV
        FROM AUSP JOIN CABN
              ON AUSP~ATINN = CABN~ATINN
        APPENDING CORRESPONDING FIELDS OF TABLE IT_AUSP
        WHERE AUSP~OBJEK EQ IT_MCH1-CUOBJ_BM
          AND CABN~ATNAM = 'ZZNOMORROLL'
      .
      IT_AUSP-MATNR = IT_MCH1-MATNR.
      IT_AUSP-CHARG = IT_MCH1-CHARG.
      IT_AUSP-ERSDA = IT_MCH1-ERSDA.
      IT_AUSP-ERNAM = IT_MCH1-ERNAM.
      MODIFY IT_AUSP TRANSPORTING MATNR CHARG ERSDA ERNAM WHERE OBJEK EQ IT_MCH1-CUOBJ_BM.
    ENDLOOP.

    REFRESH IT_NOROLL.
    LOOP AT IT_AUSP.
      REFRESH IT_TEMP_NOROLL.
      CLEAR V_TEMP_NOROLL.

      SPLIT IT_AUSP-ATWRT AT ' ' INTO TABLE IT_TEMP_NOROLL.
      LOOP AT IT_TEMP_NOROLL.
        IF SY-TABIX < 5.
          CONCATENATE V_TEMP_NOROLL IT_TEMP_NOROLL INTO V_TEMP_NOROLL SEPARATED BY SPACE.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.

      CONDENSE V_TEMP_NOROLL.

      IT_NOROLL-MATNR = IT_AUSP-MATNR.
      IT_NOROLL-CHARG = IT_AUSP-CHARG.
      IT_NOROLL-ERSDA = IT_AUSP-ERSDA.
      IT_NOROLL-ERNAM = IT_AUSP-ERNAM.
      IT_NOROLL-OBJEK = IT_AUSP-OBJEK.
      IT_NOROLL-ATINN = IT_AUSP-ATINN.
      IT_NOROLL-ATWRT = IT_AUSP-ATWRT.
      IT_NOROLL-NOROLL = V_TEMP_NOROLL.
      APPEND IT_NOROLL.

      CLEAR V_TEMP_NOROLL.
    ENDLOOP.

    SORT IT_NOROLL BY NOROLL.
    DELETE ADJACENT DUPLICATES FROM IT_NOROLL COMPARING NOROLL.

    "insert MKPF
    REFRESH IT_MKPF.
    LOOP AT IT_NOROLL.
      SELECT
        MKPF~MBLNR
        MKPF~MJAHR
        MKPF~BKTXT
        MKPF~BUDAT
        MKPF~CPUTM
        AUFM~BWART
      FROM MKPF JOIN AUFM
        ON MKPF~MBLNR EQ AUFM~MBLNR
        AND MKPF~MJAHR EQ AUFM~MJAHR
      APPENDING CORRESPONDING FIELDS OF TABLE IT_MKPF
      WHERE MKPF~BKTXT EQ IT_NOROLL-NOROLL
        AND AUFM~BWART = '101'
      .

      IT_MKPF-MATNR = IT_NOROLL-MATNR.
      IT_MKPF-CHARG = IT_NOROLL-CHARG.
      IT_MKPF-NOROLL = IT_NOROLL-NOROLL.
      MODIFY IT_MKPF TRANSPORTING MATNR CHARG NOROLL WHERE BKTXT EQ IT_NOROLL-NOROLL.
    ENDLOOP.

    "insert AUFM
*    REFRESH IT_AUFM.
*    LOOP AT IT_MKPF.
*      SELECT *
*      FROM AUFM
*      APPENDING CORRESPONDING FIELDS OF TABLE IT_AUFM
*      WHERE AUFM~MBLNR EQ IT_MKPF-MBLNR
*        AND AUFM~MJAHR EQ IT_MKPF-MJAHR
*        AND AUFM~BWART = '101'
*      .
*    ENDLOOP.

    REFRESH : IT_FINAL_MKPF, LMSG_AGING.
*    LOOP AT IT_AUFM.
*      LOOP AT IT_MKPF WHERE MBLNR = IT_AUFM-MBLNR
*                        AND MJAHR = IT_AUFM-MJAHR.
      LOOP AT IT_MKPF.
        CLEAR V_IS_VALID.
        IT_FINAL_MKPF-MBLNR = IT_MKPF-MBLNR.
        IT_FINAL_MKPF-MJAHR = IT_MKPF-MJAHR.
        IT_FINAL_MKPF-BUDAT = IT_MKPF-BUDAT.
        IT_FINAL_MKPF-CPUTM = IT_MKPF-CPUTM.
        IT_FINAL_MKPF-BKTXT = IT_MKPF-BKTXT.
        APPEND IT_FINAL_MKPF.

        "Hitung apakah tanggal dan jam di mkpf > dari 24 jam dari tanggal hari ini dan jam saat ini
        "jika < 24 jam, maka error, batch xxx belum melewati masa aging 24 jam
        "jika > 24, lolos
        PERFORM CEK_AGING_24JAM USING IT_FINAL_MKPF-BUDAT
                                      IT_FINAL_MKPF-CPUTM
                                CHANGING V_IS_VALID
        .

        IF V_IS_VALID NE 'X'.
          CONCATENATE 'Batch' IT_MKPF-CHARG 'belum melewati masa aging 24 jam' INTO LMSG_AGING-MSGV1 SEPARATED BY SPACE.
          LMSG_AGING-MSGID = '00'.
          LMSG_AGING-MSGTY = 'E'.
          LMSG_AGING-MSGNO = '1'.
          LMSG_AGING-LINENO = 1.
          APPEND LMSG_AGING.
        ENDIF.
        CLEAR V_IS_VALID.

      ENDLOOP.
*    ENDLOOP.

    IF LMSG_AGING[] IS NOT INITIAL.
      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          I_MESSAGE_TAB = LMSG_AGING.
      EXIT.
*      STOP.
    ELSE.
      P_IS_AGINGVALID = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDASI_AGING_TIME
*&---------------------------------------------------------------------*
*&      Form  CEK_AGING_24JAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_FINAL_MKPF_BUDAT  text
*      -->P_IT_FINAL_MKPF_CPUTM  text
*      ADD BY RYAN, Project Laminator #2 #3 24.01.2025
*----------------------------------------------------------------------*
FORM CEK_AGING_24JAM  USING    P_MKPF_BUDAT
                               P_MKPF_CPUTM
                      CHANGING P_IS_VALID
                               .
  DATA : V_NOW_DATE   TYPE SY-DATUM,    "Tanggal Hari ini
         V_NOW_TIME   TYPE SY-UZEIT,    "Waktu saat ini
         V_TS_BUDAT   TYPE P LENGTH 14, "Timestamp dokumen
         V_TS_NOW     TYPE P LENGTH 14, "Timestamp saat ini
         V_DIFF_SEC   TYPE I,           "Diff Second
         V_DIFF_HOUR  TYPE P DECIMALS 2 "Diff Hour
         .

  "================ CARA 1 ===============================
*  V_NOW_DATE = SY-DATUM.
*  V_NOW_TIME = SY-UZEIT.
*
*  "CONVERT DATE AND TIME TO TIMESTAMP
*  V_TS_BUDAT = P_MKPF_BUDAT * 1000000 + P_MKPF_CPUTM.
*  V_TS_NOW   = V_NOW_DATE * 1000000 + V_NOW_TIME.
*
*  "SELISIH TIMESTAMP (SECOND)
*  V_DIFF_SEC = ( V_TS_NOW - V_TS_BUDAT ) / 100.
*
*  "KONVERSI SECOND KE HOUR
*  V_DIFF_HOUR = V_DIFF_SEC / 3600.
*
*  IF V_DIFF_HOUR > 24.
*    P_IS_VALID = 'X'.
*  ENDIF.

  "================ CARA 2 ===============================
  CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
    EXPORTING
      DATE_1  = P_MKPF_BUDAT
      TIME_1  = P_MKPF_CPUTM
      DATE_2  = SY-DATUM
      TIME_2  = SY-UZEIT
    IMPORTING
      SECONDS = V_DIFF_SEC.

  "KONVERSI SECOND KE HOUR
  V_DIFF_HOUR = V_DIFF_SEC / 3600.

  IF V_DIFF_HOUR >= 24.
    P_IS_VALID = 'X'.
  ENDIF.
ENDFORM.                    " CEK_AGING_24JAM