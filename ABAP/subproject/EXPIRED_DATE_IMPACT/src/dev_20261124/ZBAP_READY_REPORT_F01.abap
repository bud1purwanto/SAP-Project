*&---------------------------------------------------------------------*
*&  Include           ZHUR_READY_REPORT_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA : T_PERCENT(50).
  DATA: LD_COLOR(10) TYPE C.
  DATA : KNKLI TYPE KNKK-KNKLI.

  CLEAR : IT_HU,IT_VEKP,IT_VEKP_TEMP,IT_LINE,IT_XVBPA,IT_XVBADR,IT_ENTRIES,IT_TEMP,
          WA_TEMP,IT_CHARG,IT_MSEG,IT_MKPF,IT_AUART,IT_VBELN,IT_LGNUM,IT_BSID,IT_CHAR.
  REFRESH: IT_HU,IT_VEKP,IT_VEKP_TEMP,IT_LINE,IT_XVBPA,IT_XVBADR,IT_ENTRIES,IT_TEMP,
           WA_TEMP,IT_CHARG,IT_MSEG,IT_MKPF,IT_AUART,IT_VBELN,IT_LGNUM,IT_BSID,IT_CHAR.


  PERFORM GET_HU.

  SORT IT_HU ASCENDING BY EXIDV.


  CLEAR : V_EXIDV, V_ZZEXIDV.
  FLAG = 'X'.

  DESCRIBE TABLE IT_HU LINES LINE.
  NUMBER1 = ( LINE / 10 ) .
  CLEAR : NUMBER2.
  LOOP AT IT_HU ASSIGNING <FS_HU>.
    CLEAR : V_TEXT1.
    "- HU Pallet
    NUMBER2 = NUMBER2 + 1.
    IF NUMBER2 = NUMBER1.
      V_PERCENT  = ( SY-TABIX / LINE ) * 100.
      MOVE V_PERCENT TO T_PERCENT.
      CONCATENATE T_PERCENT '%' 'of 100 %' INTO V_TEXT1 SEPARATED BY SPACE.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          PERCENTAGE = V_PERCENT
          TEXT       = V_TEXT1.
      NUMBER2 = 0.
    ENDIF.

    IF <FS_HU>-MAGRV EQ 'BOX'.
      <FS_HU>-ZEXIDV = <FS_HU>-EXIDV.
      CLEAR : <FS_HU>-EXIDV.
      SELECT SINGLE VEKP~EXIDV
        INTO <FS_HU>-EXIDV
        FROM VEKP
        WHERE VEKP~VENUM = <FS_HU>-UEVEL.

      CLEAR : V_STATUS.
      SELECT SINGLE VEKP~STATUS
        INTO V_STATUS
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-ZEXIDV.

      IF V_STATUS EQ '0050' OR V_STATUS EQ '0001' OR V_STATUS EQ '0060'.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.

      "- Container
      CLEAR : V_VENUM, V_UNVEL.
      SELECT SINGLE VEKP~VENUM
        INTO V_VENUM
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-EXIDV.

      SELECT SINGLE VEPO~VENUM
        INTO V_UNVEL
        FROM VEPO
        WHERE VEPO~UNVEL = V_VENUM.

      IF V_UNVEL NE ''.
        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-ZZEXIDV
          FROM VEKP
          WHERE VEKP~VENUM = V_UNVEL
            AND VEKP~MAGRV IN ('TRS', 'LCL').
      ENDIF.


    ELSEIF <FS_HU>-MAGRV EQ 'PLT'.
      CLEAR : V_VENUM.
      SELECT SINGLE VEPO~VENUM
        INTO V_VENUM
        FROM VEPO
        WHERE VEPO~UNVEL = <FS_HU>-VENUM.

      "- HU Container
      IF V_VENUM NE ''.
        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-ZZEXIDV
          FROM VEKP
          WHERE VEKP~VENUM = V_VENUM
            AND VEKP~MAGRV IN ('TRS', 'LCL').
      ENDIF.

      CLEAR : V_STATUS.
      SELECT SINGLE VEKP~STATUS
        INTO V_STATUS
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-EXIDV.

      IF V_STATUS EQ '0050' OR V_STATUS EQ '0001' OR V_STATUS EQ '0060'.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.

    ELSEIF <FS_HU>-MAGRV EQ 'TRS' OR <FS_HU>-MAGRV EQ 'LCL'.
      <FS_HU>-ZZEXIDV = <FS_HU>-EXIDV.
      CLEAR : <FS_HU>-EXIDV.

      CLEAR : V_STATUS.
      SELECT SINGLE VEKP~STATUS
        INTO V_STATUS
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-ZZEXIDV.

      IF V_STATUS EQ '0050' OR V_STATUS EQ '0060'.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.

    ENDIF.

    IF <FS_HU>-ZZEXIDV NE '' AND <FS_HU>-EXIDV EQ ''.
      DELETE IT_HU . "FROM WA_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-EXIDV NE ''.
      "- Warehouse Number "- Storage Bin
      SELECT SINGLE LEIN~LGNUM LEIN~LGPLA
        INTO (<FS_HU>-LGNUM,<FS_HU>-LGPLA)
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-EXIDV.


      "- HU Date  , "- QA Status
      CLEAR : V_VENUM.
      SELECT SINGLE VEKP~ERDAT VEKP~VENUM
        INTO (<FS_HU>-ERDAT,V_VENUM)
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-EXIDV.


      CLEAR : V_OBJNR.
      CONCATENATE 'HU' V_VENUM INTO V_OBJNR.
      SELECT SINGLE TJ30T~TXT04
        INTO <FS_HU>-TXT04
        FROM TJ30T
        INNER JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
        INNER JOIN HUSSTAT ON HUSTOBJ~OBJNR = HUSSTAT~OBJNR
        WHERE HUSSTAT~INACT EQ ''
          AND HUSSTAT~STAT = TJ30T~ESTAT
          AND HUSSTAT~OBJNR = V_OBJNR.

    ELSE.
      "- Warehouse Number "- Storage Bin
      SELECT SINGLE LEIN~LGNUM LEIN~LGPLA
        INTO (<FS_HU>-LGNUM,<FS_HU>-LGPLA)
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-ZEXIDV.

    ENDIF.

    IF S_LGNUM[] IS NOT INITIAL.
      IF <FS_HU>-LGNUM NOT IN S_LGNUM.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF S_LGPLA[] IS NOT INITIAL.
      IF <FS_HU>-LGPLA NOT IN S_LGPLA.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.
    ENDIF.


    "- GR HU Date
    CLEAR : IT_MSEG, IT_MKPF.
    REFRESH : IT_MSEG, IT_MKPF.

    SELECT MAX( MSEG~BUDAT_MKPF )
    INTO <FS_HU>-WDATU
    FROM MSEG
    WHERE MSEG~CHARG = <FS_HU>-CHARG
      AND MSEG~BWART = '311'
      AND MSEG~SHKZG = 'S'
      AND ( MSEG~LGORT LIKE '18%' OR MSEG~LGORT LIKE '28%' OR MSEG~LGORT LIKE '38%' )
      AND MSEG~UMLGO NOT LIKE '18%'
      AND MSEG~UMLGO NOT LIKE '28%'
      AND MSEG~UMLGO NOT LIKE '38%'.
*     %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z12")'.


    "- Qty Roll
    <FS_HU>-ZQTYROL = '1'.

    IF <FS_HU>-SOBKZ EQ 'E'.
      "- SO Number
      <FS_HU>-VBELN = <FS_HU>-SONUM(10).

      "- SO Item
      <FS_HU>-POSNR = <FS_HU>-SONUM+10(6).

      "- SO Type   "- Item Category
      SELECT SINGLE VBAK~AUART VBAP~PSTYV
        INTO (<FS_HU>-AUART,<FS_HU>-PSTYV)
        FROM VBAK
        JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
        WHERE VBAK~VBELN = <FS_HU>-VBELN
        AND   VBAP~POSNR = <FS_HU>-POSNR.


    ELSEIF <FS_HU>-SOBKZ EQ 'W'.
      "- Item Category
      SELECT SINGLE LIPS~PSTYV
      INTO <FS_HU>-PSTYV
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-ZVBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    ELSEIF <FS_HU>-SOBKZ EQ 'O'.
      SELECT SINGLE MSLB~LBLAB
        INTO V_LBLAB
        FROM MSLB
        WHERE MSLB~MATNR = <FS_HU>-MATNR
          AND MSLB~CHARG = <FS_HU>-CHARG.

      IF V_LBLAB = 0.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF <FS_HU>-VBELN NOT IN S_VBELN.
      DELETE IT_HU . "FROM WA_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-POSNR NOT IN S_POSNR.
      DELETE IT_HU . "FROM WA_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-AUART NOT IN S_AUART.
      DELETE IT_HU . "FROM WA_HU.
      CONTINUE.
    ENDIF.

    "- SO Type Description
    SELECT SINGLE TVAKT~BEZEI
      INTO <FS_HU>-BEZEI
      FROM TVAKT
      WHERE TVAKT~AUART = <FS_HU>-AUART
        AND TVAKT~SPRAS EQ 'E'.


    IF <FS_HU>-SOBKZ EQ 'W' AND ( <FS_HU>-PSTYV EQ 'ZKEC' OR
                                  <FS_HU>-PSTYV EQ 'ZKEN' OR
                                  <FS_HU>-PSTYV EQ 'ZKRC' OR
                                  <FS_HU>-PSTYV EQ 'ZKRN' OR
                                  <FS_HU>-PSTYV EQ 'ZKAC' OR
                                  <FS_HU>-PSTYV EQ 'ZKAN' ).
      DELETE IT_HU . "FROM WA_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-SOBKZ EQ 'W'.
      CLEAR : V_KULAB.
      SELECT SINGLE MSKU~KULAB
        INTO V_KULAB
        FROM MSKU
        WHERE MSKU~CHARG = <FS_HU>-CHARG
          AND MSKU~WERKS = <FS_HU>-WERKS
          AND MSKU~MATNR = <FS_HU>-MATNR.

      IF V_KULAB EQ 0.
        DELETE IT_HU . "FROM WA_HU.
        CONTINUE.
      ENDIF.
    ENDIF.


    CLEAR : IT_XVBPA.
    REFRESH : IT_XVBPA.
    CALL FUNCTION 'SD_PARTNER_READ'
      EXPORTING
        F_VBELN  = <FS_HU>-VBELN
        OBJECT   = 'VBPA'
      TABLES
        I_XVBADR = IT_XVBADR
        I_XVBPA  = IT_XVBPA.

    "- Customer Name
    READ TABLE IT_XVBPA  WITH KEY PARVW = 'AG' ASSIGNING <FS_XVBPA>.
    IF SY-SUBRC = 0.
      <FS_HU>-NAME1 = <FS_XVBPA>-NAME1.
    ENDIF.

    "- Customer Code
    READ TABLE IT_XVBPA  WITH KEY PARVW = 'AG' ASSIGNING <FS_XVBPA>.
    IF SY-SUBRC = 0.
      <FS_HU>-KUNNR = <FS_XVBPA>-KUNNR.
    ENDIF.

    "-Customer Group
    CLEAR : KNKLI.
    SELECT SINGLE KNKLI INTO KNKLI
      FROM KNKK
      WHERE KUNNR = <FS_HU>-KUNNR.

    "- Baseline Date
    REFRESH : IT_BSID.
    CLEAR : IT_BSID.
    SELECT BSID~ZFBDT BSID~ZBD1T BSID~KUNNR BSID~WRBTR BSID~SHKZG
      INTO CORRESPONDING FIELDS OF TABLE IT_BSID
      FROM BSID
      INNER JOIN KNA1 ON BSID~KUNNR = KNA1~KUNNR
      JOIN KNKK ON KNA1~KUNNR = KNKK~KUNNR
        WHERE KNA1~KTOKD IN ('ZLAF', 'ZLOE', 'ZLTP')
*          AND BSID~KUNNR = <FS_HU>-KUNNR
          AND KNKK~KNKLI = KNKLI
          AND BSID~ZBD1T >= 0.

    SORT IT_BSID ASCENDING BY ZBD1T.
    LOOP AT IT_BSID ASSIGNING <FS_BSID>.
      IF <FS_BSID>-SHKZG EQ 'H'.
        <FS_BSID>-WRBTR = <FS_BSID>-WRBTR * -1.
      ENDIF.

      <FS_BSID>-DUEDT = <FS_BSID>-ZFBDT + <FS_BSID>-ZBD1T.
    ENDLOOP.

    DELETE IT_BSID  WHERE WRBTR LE 0.
    SORT IT_BSID ASCENDING BY DUEDT.
    READ TABLE IT_BSID  INDEX 1 ASSIGNING <FS_BSID> .
    IF SY-SUBRC = 0.
      V_BLOCK = SY-DATUM - <FS_BSID>-DUEDT.
    ELSE.
      V_BLOCK = 0.
    ENDIF.

    IF V_BLOCK >= 30.
      <FS_HU>-ZZBLOCK = 'BLOCKED'.
    ELSE.
      <FS_HU>-ZZBLOCK = ''.
    ENDIF.

    IF <FS_HU>-VBELN EQ ''.
      <FS_HU>-ZZBLOCK = ''.
    ENDIF.


    "- Sales Employee
    READ TABLE IT_XVBPA  WITH KEY PARVW = 'VE' ASSIGNING <FS_XVBPA>.
    IF SY-SUBRC = 0.
      <FS_HU>-ZNAME1 = <FS_XVBPA>-NAME1.
    ENDIF.

    "- PO Number
    SELECT SINGLE VBKD~BSTKD
      INTO <FS_HU>-BSTKD
      FROM VBKD
      WHERE VBKD~VBELN = <FS_HU>-VBELN.

    "- PI Number
    IF <FS_HU>-VBELN NE ''.

      CLEAR : IT_LINE, V_VBELV.
      REFRESH : IT_LINE.
      V_VBELV = <FS_HU>-VBELN.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          CLIENT                  = SY-MANDT
          ID                      = 'Z101'
          LANGUAGE                = SY-LANGU
          NAME                    = V_VBELV
          OBJECT                  = 'VBBK'
        TABLES
          LINES                   = IT_LINE
        EXCEPTIONS
          ID                      = 1
          LANGUAGE                = 2
          NAME                    = 3
          NOT_FOUND               = 4
          OBJECT                  = 5
          REFERENCE_CHECK         = 6
          WRONG_ACCESS_TO_ARCHIVE = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
*       Implement suitable error handling here
      ENDIF.

      READ TABLE IT_LINE INDEX 1 ASSIGNING <FS_LINE> .
      IF SY-SUBRC = 0.
        <FS_HU>-ZPINUM = <FS_LINE>-TDLINE.
      ENDIF.

    ENDIF.

    "- Production Date
*- update by ALF
*    SELECT SINGLE MCH1~ERSDA
*      INTO <FS_HU>-ERSDA
*      FROM MCH1
*      WHERE MCH1~MATNR = <FS_HU>-MATNR
*        AND MCH1~CHARG = <FS_HU>-CHARG.
**    %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z04")'.

    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = <FS_HU>-MATNR
        CHARG = <FS_HU>-CHARG
      IMPORTING
        PDATE = <FS_HU>-ERSDA.
*- end of ALF

    "- Requested Delivery Date
*    SELECT SINGLE VBAK~VDATU
*      INTO <FS_HU>-VDATU
*      FROM VBAK
*      WHERE VBAK~VBELN = <FS_HU>-VBELN.
    SELECT SINGLE VBEP~EDATU
      INTO <FS_HU>-VDATU
      FROM VBEP
      WHERE VBEP~VBELN = <FS_HU>-VBELN
      AND   VBEP~POSNR = <FS_HU>-POSNR.
    IF SY-SUBRC = 0.
      IF <FS_HU>-VDATU = SY-DATUM .
        <FS_HU>-DELUS = 'Hari Ini'.
      ELSEIF <FS_HU>-VDATU > SY-DATUM.
        CLEAR : V_TEXT1.
        IF <FS_HU>-VDATU+4(2) = SY-DATUM+4(2).
          CONCATENATE 'Sesudah Tanggal' SY-DATUM+6(2) INTO V_TEXT1 SEPARATED BY SPACE.
        ELSE.
          CONCATENATE 'Sesudah Bulan' SY-DATUM+4(2) INTO V_TEXT1 SEPARATED BY SPACE.
        ENDIF.
        <FS_HU>-DELUS = V_TEXT1.

      ELSEIF <FS_HU>-VDATU < SY-DATUM.
        CLEAR : V_TEXT1.
        IF <FS_HU>-VDATU+4(2) = SY-DATUM+4(2).
          CONCATENATE 'Sebelum Tanggal' SY-DATUM+6(2) INTO V_TEXT1 SEPARATED BY SPACE.
        ELSE.
          CONCATENATE 'Sebelum Bulan' SY-DATUM+4(2) INTO V_TEXT1 SEPARATED BY SPACE.
        ENDIF.
        <FS_HU>-DELUS = V_TEXT1.

      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <FS_HU>-EXIDV
      IMPORTING
        OUTPUT = <FS_HU>-EXIDV.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <FS_HU>-ZEXIDV
      IMPORTING
        OUTPUT = <FS_HU>-ZEXIDV.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <FS_HU>-ZZEXIDV
      IMPORTING
        OUTPUT = <FS_HU>-ZZEXIDV.

    "- Characteristic
*    CLEAR : IT_CHAR.
*    REFRESH : IT_CHAR.
*    CHECK <FS_HU>-CHARG NE ''.
*    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
*      EXPORTING
*        I_VAL_MATNR    = <FS_HU>-MATNR
*        I_VAL_WERKS    = <FS_HU>-WERKS
*        I_VAL_CHARGE   = <FS_HU>-CHARG
*      TABLES
*        T_VAL_TAB      = IT_CHAR
*      EXCEPTIONS
*        NO_CLASS       = 1
*        INTERNAL_ERROR = 2
*        NO_VALUES      = 3
*        NO_CHARS       = 4
*        OTHERS         = 5.
*    CHECK SY-SUBRC EQ '0'.
*
*    "- Roll Number
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZROLL =  <FS_CHAR>-ATWRT.
*    ENDIF.
*
*    "- Tipe
*    READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZTYPE =  <FS_CHAR>-ATWRT.
*    ENDIF.
*
*    "- Thickness
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTHICKNESS' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZTHICK =  <FS_CHAR>-ATWRT.
*    ENDIF.
*
*    "- Width
*    READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH' ASSIGNING <FS_CHAR> .
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZWIDTH =  <FS_CHAR>-ATWRT.
*    ENDIF.
*
*    "- Length
*    IF <FS_HU>-MATNR(2) EQ 'SH'.
*      READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZLENGTHSHT' ASSIGNING <FS_CHAR>.
*      IF SY-SUBRC = 0.
*        <FS_HU>-ZZLENGTH =  <FS_CHAR>-ATWRT.
*      ENDIF.
*    ELSE.
*      READ TABLE  IT_CHAR WITH  KEY ATNAM = 'ZZLENGTH' ASSIGNING <FS_CHAR>.
*      IF SY-SUBRC = 0.
*        <FS_HU>-ZZLENGTH =  <FS_CHAR>-ATWRT.
*      ENDIF.
*    ENDIF.
*
*    "- Criteria Grade
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCRITERIA' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZGRADE =  <FS_CHAR>-ATWTB.
*    ENDIF.
*
*    "- Treatment
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTREATMENT' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZTREAT =  <FS_CHAR>-ATWTB.
*    ENDIF.
*
*    "- Alias
*    READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZALIAS'  ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZALIAS =  <FS_CHAR>-ATWTB.
*    ENDIF.
*
*    "- Core.
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCORE' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZCORE =  <FS_CHAR>-ATWTB.
*    ENDIF.
*
*    "- Sistem Packing
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZPACKING' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZPACK =  <FS_CHAR>-ATWTB.
*    ENDIF.
*
*    "- Code
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCODE' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZCODE =  <FS_CHAR>-ATWRT.
*    ENDIF.
*
*    "- Expired Live
*    READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZEXPIREDLIVE' ASSIGNING <FS_CHAR>.
*    IF SY-SUBRC = 0.
*      <FS_HU>-ZZEXPR = <FS_HU>-ERSDA + <FS_CHAR>-ATWRT.
*    ELSE.
*      <FS_HU>-ZZEXPR = <FS_HU>-ERSDA.
*    ENDIF.


    IF <FS_HU>-CHARG NE  ''.
      CALL FUNCTION 'ZCHARACTERISTICS'
        EXPORTING
          I_VAL_MATNR  = <FS_HU>-MATNR
          I_VAL_CHARGE = <FS_HU>-CHARG
        TABLES
          T_VAL_TAB    = IT_CHAR
        EXCEPTIONS
          NO_OBJECT    = 1
          T_L_E1       = 2
          T_L_E2       = 3.
      IF SY-SUBRC EQ 0.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZTYPE =  <FS_CHAR>-ATWRT.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTHICKNESS'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV1.
          <FS_HU>-ZZTHICKNESS =  ATFLV1.
        ENDIF.


        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZWIDTH'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_HU>-ZZWIDTH =  ATFLV2.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZLENGTHSHT'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          <FS_HU>-ZZLENGTH =  ATFLV2.
        ELSE.
          READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZLENGTH'  ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            <FS_HU>-ZZLENGTH =  ATFLV2.
          ENDIF.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZNOMORROLL'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZNOMORROLL =  <FS_CHAR>-ATWRT.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZALIAS'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZALIAS =  <FS_CHAR>-ATWRT.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZEXPIREDLIVE'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          IF <FS_HU>-ERSDA NE '00000000'.
            <FS_HU>-ZZEXPIREDLIVE =  <FS_HU>-ERSDA + <FS_CHAR>-ATFLV.
          ENDIF.
        ENDIF.


        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZCORE'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZCORE =  <FS_CHAR>-ATWTB.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZCRITERIA'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZCRITERIA =  <FS_CHAR>-ATWTB.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZPACKING'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZPACKING =  <FS_CHAR>-ATWTB.
        ENDIF.

        READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTREATMENT'  ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          <FS_HU>-ZZTREATMENT =  <FS_CHAR>-ATWTB.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDLOOP.

  " Added by William at 01.09.2026 (Populate Grade and Grade Description with bulk classification reads - generate by AI)
  PERFORM GET_ZZGRADE.

  IF P_ACTUAL = 'X'.
    PERFORM GET_ACTUAL_WEIGHT.   "get actual weight
  ENDIF.

  "add by ryan, 02-05-2025, Project Subcont CKI"
  PERFORM GET_AGING_TIME.

  " Modified by William at 21.09.2026 (Load optional HU and Batch QA Reason in bulk only when selected - generate by AI)
  IF P_HHU = 'X' OR P_HHUF = 'X'.
    PERFORM GET_HU_QA_REASON.
  ENDIF.
  IF P_HBATCH = 'X' OR P_HBAF = 'X'.
    PERFORM GET_BATCH_QA_REASON.
  ENDIF.

  " Modified by William at 21.09.2026 (Filter QA Reason rows with OR semantics - generate by AI)
  IF P_HHUF = 'X' OR P_HBAF = 'X'.
    LOOP AT IT_HU ASSIGNING <FS_HU>.
      IF ( P_HHUF = 'X' AND <FS_HU>-HUHOLD IS NOT INITIAL ) OR
         ( P_HBAF = 'X' AND <FS_HU>-BATCHHOLD IS NOT INITIAL ).
        CONTINUE.
      ENDIF.
      DELETE IT_HU.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_ZZGRADE
*&---------------------------------------------------------------------*
* Reads ZZGRADE classification values for unique batches in bulk and maps
* the code plus its CAWNT description back to the ALV output.
*----------------------------------------------------------------------*
" Modified by William at 01.09.2026 (Optimize Batch QA Reason with bulk reads and cache - generate by AI)
FORM GET_ZZGRADE.
  TYPES: BEGIN OF TY_BATCH_KEY,
           MATNR LIKE MCH1-MATNR,
           CHARG LIKE MCH1-CHARG,
         END OF TY_BATCH_KEY,
         BEGIN OF TY_MCH1,
           MATNR    LIKE MCH1-MATNR,
           CHARG    LIKE MCH1-CHARG,
           OBJEK    LIKE AUSP-OBJEK,
         END OF TY_MCH1,
         BEGIN OF TY_AUSP,
           OBJEK LIKE AUSP-OBJEK,
           ATINN LIKE AUSP-ATINN,
           ATZHL LIKE AUSP-ATZHL,
           ATWRT LIKE AUSP-ATWRT,
         END OF TY_AUSP,
         BEGIN OF TY_CAWN,
           ATINN LIKE CAWN-ATINN,
           ATZHL LIKE CAWN-ATZHL,
           ATWRT LIKE CAWN-ATWRT,
         END OF TY_CAWN,
         BEGIN OF TY_CAWNT,
           ATINN LIKE CAWNT-ATINN,
           ATZHL LIKE CAWNT-ATZHL,
           ATWTB LIKE CAWNT-ATWTB,
         END OF TY_CAWNT.
  DATA: LT_BATCH_KEY TYPE SORTED TABLE OF TY_BATCH_KEY
          WITH UNIQUE KEY MATNR CHARG,
        LT_MCH1 TYPE STANDARD TABLE OF TY_MCH1,
        LT_AUSP TYPE STANDARD TABLE OF TY_AUSP,
        LT_CAWN TYPE STANDARD TABLE OF TY_CAWN,
        LT_CAWNT TYPE STANDARD TABLE OF TY_CAWNT,
        LS_BATCH_KEY TYPE TY_BATCH_KEY,
        LS_MCH1 TYPE TY_MCH1,
        LS_AUSP TYPE TY_AUSP,
        LS_CAWN TYPE TY_CAWN,
        LS_CAWNT TYPE TY_CAWNT,
        LV_ATINN LIKE CABN-ATINN.

  IF IT_HU[] IS INITIAL.
    EXIT.
  ENDIF.

  " Build a unique batch driver before accessing classification tables.
  LOOP AT IT_HU WHERE MATNR IS NOT INITIAL AND CHARG IS NOT INITIAL.
    CLEAR LS_BATCH_KEY.
    LS_BATCH_KEY-MATNR = IT_HU-MATNR.
    LS_BATCH_KEY-CHARG = IT_HU-CHARG.
    INSERT LS_BATCH_KEY INTO TABLE LT_BATCH_KEY.
  ENDLOOP.
  IF LT_BATCH_KEY IS INITIAL.
    EXIT.
  ENDIF.

  " Resolve ZZGRADE once; do not call ZCHARACTERISTICS inside the HU loop.
  SELECT SINGLE ATINN INTO LV_ATINN
    FROM CABN
    WHERE ATNAM = 'ZZGRADE'.
  IF SY-SUBRC <> 0 OR LV_ATINN IS INITIAL.
    EXIT.
  ENDIF.

  SELECT MATNR CHARG CUOBJ_BM AS OBJEK
    INTO CORRESPONDING FIELDS OF TABLE LT_MCH1
    FROM MCH1
    FOR ALL ENTRIES IN LT_BATCH_KEY
    WHERE MATNR = LT_BATCH_KEY-MATNR
      AND CHARG = LT_BATCH_KEY-CHARG.
  IF LT_MCH1 IS INITIAL.
    EXIT.
  ENDIF.

  " Read only ZZGRADE assignments for all identified batch objects.
  SELECT OBJEK ATINN ATZHL ATWRT
    INTO CORRESPONDING FIELDS OF TABLE LT_AUSP
    FROM AUSP
    FOR ALL ENTRIES IN LT_MCH1
    WHERE OBJEK = LT_MCH1-OBJEK
      AND ATINN = LV_ATINN
      AND KLART = '023'.
  SORT LT_MCH1 BY MATNR CHARG.
  SORT LT_AUSP BY OBJEK ATINN ATZHL.

  IF LT_AUSP IS NOT INITIAL.
    " Resolve the assigned Grade code through CAWN, then read its language text from CAWNT.
    SELECT ATINN ATZHL ATWRT
      INTO CORRESPONDING FIELDS OF TABLE LT_CAWN
      FROM CAWN
      WHERE ATINN = LV_ATINN.
    SELECT ATINN ATZHL ATWTB
      INTO CORRESPONDING FIELDS OF TABLE LT_CAWNT
      FROM CAWNT
      WHERE ATINN = LV_ATINN
        AND SPRAS = 'E'.
    SORT LT_CAWN BY ATINN ATWRT.
    SORT LT_CAWNT BY ATINN ATZHL.
  ENDIF.

  " Map the prepared values in memory; no database access occurs here.
  " Modified by William at 02.09.2026 (Fix Grade Description mapping via CAWN value code - generate by AI)
  LOOP AT IT_HU ASSIGNING <FS_HU> WHERE MATNR IS NOT INITIAL AND CHARG IS NOT INITIAL.
    CLEAR: LS_BATCH_KEY, LS_MCH1, LS_AUSP, LS_CAWNT.
    LS_BATCH_KEY-MATNR = <FS_HU>-MATNR.
    LS_BATCH_KEY-CHARG = <FS_HU>-CHARG.
    READ TABLE LT_MCH1 INTO LS_MCH1
      WITH KEY MATNR = LS_BATCH_KEY-MATNR CHARG = LS_BATCH_KEY-CHARG
      BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    READ TABLE LT_AUSP INTO LS_AUSP
      WITH KEY OBJEK = LS_MCH1-OBJEK ATINN = LV_ATINN
      BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    <FS_HU>-ZZGRADE = LS_AUSP-ATWRT.
    READ TABLE LT_CAWN INTO LS_CAWN
      WITH KEY ATINN = LS_AUSP-ATINN ATWRT = LS_AUSP-ATWRT
      BINARY SEARCH.
    IF SY-SUBRC = 0.
      READ TABLE LT_CAWNT INTO LS_CAWNT
        WITH KEY ATINN = LS_CAWN-ATINN ATZHL = LS_CAWN-ATZHL
        BINARY SEARCH.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZGRADE_DESC = LS_CAWNT-ATWTB.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_ZZGRADE

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
* add by ryan, 02-05-2025, Project Subcont CKI"
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Original GET_AGING_TIME source retained for comparison
* Modified by William at 01.09.2026 (Comment initial aging logic - generate by AI)
*----------------------------------------------------------------------*
* FORM GET_AGING_TIME.
*   DATA: BEGIN OF IT_AUSP OCCURS 0,
*           MATNR   LIKE MCH1-MATNR,
*           CHARG   LIKE MCH1-CHARG,
*           ERSDA   LIKE MCH1-ERSDA,
*           ERNAM   LIKE MCH1-ERNAM,
*           OBJEK   LIKE AUSP-OBJEK,
*           ATINN   LIKE AUSP-ATINN,
*           KLART   LIKE AUSP-KLART,
*           ATWRT   LIKE AUSP-ATWRT,
*           ATFLV   LIKE AUSP-ATFLV,
*         END OF IT_AUSP.
*
*   DATA: BEGIN OF IT_TEMP_NOROLL OCCURS 0,
*          STRING LIKE AUSP-ATWRT,
*         END OF IT_TEMP_NOROLL.
*
*   DATA: BEGIN OF IT_NOROLL OCCURS 0,
*           MATNR   LIKE MCH1-MATNR,
*           CHARG   LIKE MCH1-CHARG,
*           NOROLL  LIKE AUSP-ATWRT,
*           ERSDA   LIKE MCH1-ERSDA,
*           ERNAM   LIKE MCH1-ERNAM,
*           OBJEK   LIKE AUSP-OBJEK,
*           ATINN   LIKE AUSP-ATINN,
*           ATWRT   LIKE AUSP-ATWRT,
*         END OF IT_NOROLL.
*
*   DATA: BEGIN OF IT_MKPF OCCURS 0,
*           MBLNR   LIKE MKPF-MBLNR,
*           MJAHR   LIKE MKPF-MJAHR,
*           BKTXT   LIKE MKPF-BKTXT,
*           BUDAT   LIKE MKPF-BUDAT,
*           CPUTM   LIKE MKPF-CPUTM,
*           MATNR   LIKE MCH1-MATNR,
*           CHARG   LIKE MCH1-CHARG,
*           NOROLL  LIKE AUSP-ATWRT,
*           BWART   LIKE AUFM-BWART,
*           AGINGTM TYPE P DECIMALS 2,
*         END OF IT_MKPF.
*
*   DATA : IT_MCH1 LIKE MCH1 OCCURS 0 WITH HEADER LINE,
*          V_TEMP_NOROLL LIKE AUSP-ATWRT,
*          V_IS_VALID(1) TYPE C
*          .
*
*   SELECT *
*     FROM MCH1
*     INTO CORRESPONDING FIELDS OF TABLE IT_MCH1
*     FOR ALL ENTRIES IN IT_HU
*     WHERE MCH1~CHARG EQ IT_HU-CHARG
*     .
*
*   IF SY-SUBRC EQ 0.
*     REFRESH IT_AUSP.
*     LOOP AT IT_MCH1.
*       SELECT
*           AUSP~OBJEK
*           AUSP~ATINN
*           AUSP~KLART
*           AUSP~ATWRT
*           AUSP~ATFLV
*         FROM AUSP JOIN CABN
*               ON AUSP~ATINN = CABN~ATINN
*         APPENDING CORRESPONDING FIELDS OF TABLE IT_AUSP
*         WHERE AUSP~OBJEK EQ IT_MCH1-CUOBJ_BM
*           AND CABN~ATNAM = 'ZZNOMORROLL'
*       .
*       IT_AUSP-MATNR = IT_MCH1-MATNR.
*       IT_AUSP-CHARG = IT_MCH1-CHARG.
*       IT_AUSP-ERSDA = IT_MCH1-ERSDA.
*       IT_AUSP-ERNAM = IT_MCH1-ERNAM.
*       MODIFY IT_AUSP TRANSPORTING MATNR CHARG ERSDA ERNAM WHERE OBJEK EQ IT_MCH1-CUOBJ_BM.
*     ENDLOOP.
*
*     REFRESH IT_NOROLL.
*     LOOP AT IT_AUSP.
*       REFRESH IT_TEMP_NOROLL.
*       CLEAR V_TEMP_NOROLL.
*
*       SPLIT IT_AUSP-ATWRT AT ' ' INTO TABLE IT_TEMP_NOROLL.
*       LOOP AT IT_TEMP_NOROLL.
*         IF SY-TABIX < 5.
*           CONCATENATE V_TEMP_NOROLL IT_TEMP_NOROLL INTO V_TEMP_NOROLL SEPARATED BY SPACE.
*         ELSE.
*           EXIT.
*         ENDIF.
*       ENDLOOP.
*
*       CONDENSE V_TEMP_NOROLL.
*
*       IT_NOROLL-MATNR = IT_AUSP-MATNR.
*       IT_NOROLL-CHARG = IT_AUSP-CHARG.
*       IT_NOROLL-ERSDA = IT_AUSP-ERSDA.
*       IT_NOROLL-ERNAM = IT_AUSP-ERNAM.
*       IT_NOROLL-OBJEK = IT_AUSP-OBJEK.
*       IT_NOROLL-ATINN = IT_AUSP-ATINN.
*       IT_NOROLL-ATWRT = IT_AUSP-ATWRT.
*       IT_NOROLL-NOROLL = V_TEMP_NOROLL.
*       APPEND IT_NOROLL.
*
*       CLEAR V_TEMP_NOROLL.
*     ENDLOOP.
*
*     SORT IT_NOROLL BY NOROLL.
*     DELETE ADJACENT DUPLICATES FROM IT_NOROLL COMPARING NOROLL.
*
*     "insert MKPF
*     REFRESH IT_MKPF.
*     LOOP AT IT_NOROLL.
*       SELECT
*         MKPF~MBLNR
*         MKPF~MJAHR
*         MKPF~BKTXT
*         MKPF~BUDAT
*         MKPF~CPUTM
*         AUFM~BWART
*       FROM MKPF JOIN AUFM
*         ON MKPF~MBLNR EQ AUFM~MBLNR
*         AND MKPF~MJAHR EQ AUFM~MJAHR
*       APPENDING CORRESPONDING FIELDS OF TABLE IT_MKPF
*       WHERE MKPF~BKTXT EQ IT_NOROLL-NOROLL
*         AND AUFM~BWART = '101'
*       .
*
*       IT_MKPF-MATNR = IT_NOROLL-MATNR.
*       IT_MKPF-CHARG = IT_NOROLL-CHARG.
*       IT_MKPF-NOROLL = IT_NOROLL-NOROLL.
*       MODIFY IT_MKPF TRANSPORTING MATNR CHARG NOROLL WHERE BKTXT EQ IT_NOROLL-NOROLL.
*     ENDLOOP.
*
*     LOOP AT IT_MKPF.
*       CLEAR V_IS_VALID.
*
*       "Hitung apakah tanggal dan jam di mkpf > dari 24 jam dari tanggal hari ini dan jam saat ini
*       "jika < 24 jam, maka error, batch xxx belum melewati masa aging 24 jam
*       "jika > 24, lolos
*       PERFORM CEK_AGING_24JAM USING IT_MKPF-BUDAT
*                                     IT_MKPF-CPUTM
*                               CHANGING IT_MKPF-AGINGTM
*       .
*
*       MODIFY IT_MKPF TRANSPORTING AGINGTM WHERE CHARG = IT_MKPF-CHARG.
*     ENDLOOP.
*
*     "Update main table
*     LOOP AT IT_HU.
*       LOOP AT IT_MKPF WHERE CHARG = IT_HU-CHARG.
*         IT_HU-AGINGTM = IT_MKPF-AGINGTM.
*       ENDLOOP.
*       MODIFY IT_HU TRANSPORTING AGINGTM WHERE CHARG = IT_HU-CHARG.
*     ENDLOOP.
*   ENDIF.
* ENDFORM.                    " GET_AGING_TIME

*&---------------------------------------------------------------------*
*&      Form  GET_AGING_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
* add by ryan, 02-05-2025, Project Subcont CKI"
* Modified by William at 01.09.2026 (Comment initial aging logic - generate by AI)
*----------------------------------------------------------------------*
FORM GET_AGING_TIME.
  " Modified by William at 01.09.2026 (Optimize GET_AGING_TIME with bulk reads - generate by AI)
  " Previous logic retained for comparison:
  " - MCH1 was read without an empty IT_HU guard.
  " - AUSP/CABN and MKPF/AUFM were selected inside loops.
  " - IT_HU was updated through a nested loop by CHARG.
  TYPES: BEGIN OF TY_BATCH_KEY,
           CHARG LIKE MCH1-CHARG,
         END OF TY_BATCH_KEY,
         BEGIN OF TY_OBJ_KEY,
           OBJEK LIKE AUSP-OBJEK,
         END OF TY_OBJ_KEY,
         BEGIN OF TY_AUSP,
           OBJEK LIKE AUSP-OBJEK,
           ATWRT LIKE AUSP-ATWRT,
           MATNR LIKE MCH1-MATNR,
           CHARG LIKE MCH1-CHARG,
         END OF TY_AUSP,
         BEGIN OF TY_NOROLL,
           NOROLL LIKE MKPF-BKTXT,
           CHARG  LIKE MCH1-CHARG,
         END OF TY_NOROLL,
         BEGIN OF TY_MKPF,
           BKTXT   LIKE MKPF-BKTXT,
           BUDAT   LIKE MKPF-BUDAT,
           CPUTM   LIKE MKPF-CPUTM,
           CHARG   LIKE MCH1-CHARG,
           AGINGTM TYPE P DECIMALS 2,
         END OF TY_MKPF,
         BEGIN OF TY_AGING_CACHE,
           CHARG   LIKE MCH1-CHARG,
           AGINGTM TYPE P DECIMALS 2,
         END OF TY_AGING_CACHE.
  DATA: LT_BATCH_KEY TYPE SORTED TABLE OF TY_BATCH_KEY
          WITH UNIQUE KEY CHARG,
        LT_OBJ_KEY TYPE SORTED TABLE OF TY_OBJ_KEY
          WITH UNIQUE KEY OBJEK,
        LT_MCH1 TYPE STANDARD TABLE OF MCH1,
        LT_AUSP TYPE STANDARD TABLE OF TY_AUSP,
        LT_NOROLL TYPE STANDARD TABLE OF TY_NOROLL,
        LT_MKPF TYPE STANDARD TABLE OF TY_MKPF,
        LT_AGING_CACHE TYPE SORTED TABLE OF TY_AGING_CACHE
          WITH UNIQUE KEY CHARG,
        LS_BATCH_KEY TYPE TY_BATCH_KEY,
        LS_OBJ_KEY TYPE TY_OBJ_KEY,
        LS_MCH1 LIKE MCH1,
        LS_AUSP TYPE TY_AUSP,
        LS_NOROLL TYPE TY_NOROLL,
        LS_MKPF TYPE TY_MKPF,
        LS_AGING_CACHE TYPE TY_AGING_CACHE,
        LT_WORD TYPE STANDARD TABLE OF AUSP-ATWRT,
        LV_NOROLL LIKE AUSP-ATWRT.

  IF IT_HU[] IS INITIAL.
    EXIT.
  ENDIF.

  " Build a unique batch driver so empty or duplicate report rows do not expand reads.
  LOOP AT IT_HU WHERE CHARG IS NOT INITIAL.
    LS_BATCH_KEY-CHARG = IT_HU-CHARG.
    INSERT LS_BATCH_KEY INTO TABLE LT_BATCH_KEY.
  ENDLOOP.

  IF LT_BATCH_KEY IS INITIAL.
    EXIT.
  ENDIF.

  SELECT MATNR CHARG ERSDA ERNAM CUOBJ_BM
    INTO CORRESPONDING FIELDS OF TABLE LT_MCH1
    FROM MCH1
    FOR ALL ENTRIES IN LT_BATCH_KEY
    WHERE CHARG = LT_BATCH_KEY-CHARG.
  IF LT_MCH1 IS INITIAL.
    EXIT.
  ENDIF.

  " Read ZZ Nomer Roll characteristics in one database operation.
  LOOP AT LT_MCH1 INTO LS_MCH1.
    LS_OBJ_KEY-OBJEK = LS_MCH1-CUOBJ_BM.
    IF LS_OBJ_KEY-OBJEK IS NOT INITIAL.
      INSERT LS_OBJ_KEY INTO TABLE LT_OBJ_KEY.
    ENDIF.
  ENDLOOP.

  IF LT_OBJ_KEY IS INITIAL.
    EXIT.
  ENDIF.

  SELECT AUSP~OBJEK AUSP~ATWRT
    INTO CORRESPONDING FIELDS OF TABLE LT_AUSP
    FROM AUSP INNER JOIN CABN ON AUSP~ATINN = CABN~ATINN
    FOR ALL ENTRIES IN LT_OBJ_KEY
    WHERE AUSP~OBJEK = LT_OBJ_KEY-OBJEK
      AND CABN~ATNAM = 'ZZNOMORROLL'.

  SORT LT_MCH1 BY CUOBJ_BM.

  LOOP AT LT_AUSP INTO LS_AUSP.
    READ TABLE LT_MCH1 INTO LS_MCH1
      WITH KEY CUOBJ_BM = LS_AUSP-OBJEK BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    REFRESH LT_WORD.
    SPLIT LS_AUSP-ATWRT AT ' ' INTO TABLE LT_WORD.
    CLEAR LV_NOROLL.
    LOOP AT LT_WORD INTO LV_NOROLL FROM 1 TO 4.
      CONCATENATE LS_NOROLL-NOROLL LV_NOROLL
        INTO LS_NOROLL-NOROLL SEPARATED BY SPACE.
    ENDLOOP.
    CONDENSE LS_NOROLL-NOROLL.
    IF LS_NOROLL-NOROLL IS NOT INITIAL.
      LS_NOROLL-CHARG = LS_MCH1-CHARG.
      APPEND LS_NOROLL TO LT_NOROLL.
    ENDIF.
    CLEAR LS_NOROLL.
  ENDLOOP.

  SORT LT_NOROLL BY NOROLL.
  DELETE ADJACENT DUPLICATES FROM LT_NOROLL COMPARING NOROLL.

  IF LT_NOROLL IS INITIAL.
    EXIT.
  ENDIF.

  " Read all GR documents for the prepared roll numbers at once.
  SELECT MKPF~BKTXT MKPF~BUDAT MKPF~CPUTM
    INTO CORRESPONDING FIELDS OF TABLE LT_MKPF
    FROM MKPF INNER JOIN AUFM
      ON MKPF~MBLNR = AUFM~MBLNR AND MKPF~MJAHR = AUFM~MJAHR
    FOR ALL ENTRIES IN LT_NOROLL
    WHERE MKPF~BKTXT = LT_NOROLL-NOROLL
      AND AUFM~BWART = '101'.

  SORT LT_NOROLL BY NOROLL.

  LOOP AT LT_MKPF INTO LS_MKPF.
    READ TABLE LT_NOROLL INTO LS_NOROLL
      WITH KEY NOROLL = LS_MKPF-BKTXT BINARY SEARCH.
    IF SY-SUBRC = 0.
      LS_MKPF-CHARG = LS_NOROLL-CHARG.
      PERFORM CEK_AGING_24JAM USING LS_MKPF-BUDAT LS_MKPF-CPUTM
                        CHANGING LS_MKPF-AGINGTM.
      CLEAR LS_AGING_CACHE.
      LS_AGING_CACHE-CHARG = LS_MKPF-CHARG.
      LS_AGING_CACHE-AGINGTM = LS_MKPF-AGINGTM.
      MODIFY TABLE LT_AGING_CACHE FROM LS_AGING_CACHE.
      IF SY-SUBRC <> 0.
        INSERT LS_AGING_CACHE INTO TABLE LT_AGING_CACHE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  " Map the final aging value back without nested IT_HU and IT_MKPF loops.
  LOOP AT IT_HU.
    CLEAR: IT_HU-AGINGTM, LS_AGING_CACHE.
    READ TABLE LT_AGING_CACHE INTO LS_AGING_CACHE
      WITH TABLE KEY CHARG = IT_HU-CHARG.
    IF SY-SUBRC = 0.
      IT_HU-AGINGTM = LS_AGING_CACHE-AGINGTM.
    ENDIF.
    MODIFY IT_HU TRANSPORTING AGINGTM.
  ENDLOOP.
ENDFORM.                    " GET_AGING_TIME

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
                      CHANGING P_DIFF_HOUR
                               .
  DATA : V_NOW_DATE   TYPE SY-DATUM,    "Tanggal Hari ini
         V_NOW_TIME   TYPE SY-UZEIT,    "Waktu saat ini
         V_TS_BUDAT   TYPE P LENGTH 14, "Timestamp dokumen
         V_TS_NOW     TYPE P LENGTH 14, "Timestamp saat ini
         V_DIFF_SEC   TYPE I,           "Diff Second
         V_DIFF_HOUR  TYPE P DECIMALS 2 "Diff Hour
         .

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
  P_DIFF_HOUR = V_DIFF_HOUR.
*  IF V_DIFF_HOUR >= 24.
*    P_IS_VALID = 'X'.
*  ENDIF.
ENDFORM.                    " CEK_AGING_24JAM
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  IF IT_HU[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " DISPLAY_DATA

*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
       'WERKS'   ''  ''  ''  5   'Plant'    ''   ''  ''  '',
       'LGORT'   ''  ''  ''  5   'Sloc'  ''   ''  ''  '',
       'LGNUM'   ''  ''  ''  8   'Warehouse Number'  ''   ''  ''  '',
       'LGPLA'   ''  ''  ''  12   'Storage Bin'  ''   ''  ''  '',
       'ZZEXIDV'   ''  ''  ''  11   'HU Container'  ''   ''  ''  '',
       'EXIDV'   ''  ''  ''  11   'HU Pallet'  ''   ''  ''  '',
       'ZEXIDV'   ''  ''  '' 11   'HU Box'  ''   ''  ''  '' ,
       'MATNR'   ''  ''  ''  11    'Material Number'    ''   ''  ''  ''.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_HU' :
      'CHARG'   ''  ''  ''  12   'Batch'  ''   ''  ''  ''.
  " Modified by William at 21.09.2026 (Display QA Reason columns only when selected - generate by AI)
  IF P_HHU = 'X' OR P_HHUF = 'X'.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU'
      'HUHOLD' '' '' '' 50 'HU QA Reason' '' '' '' ''.
  ENDIF.
  IF P_HBATCH = 'X' OR P_HBAF = 'X'.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU'
      'BATCHHOLD' '' '' '' 50 'Batch QA Reason' '' '' '' ''.
  ENDIF.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
      'ZZNOMORROLL'   ''  ''  ''  15   'Roll Number'   ''   ''  ''  '',
      'ZZTYPE'   ''  ''  ''  5   'Tipe'  ''   ''  ''  '',
      'ZZTHICKNESS'   ''  ''  ''  10   'Thickness (micron)'   ''  ''  ''  '',
      'ZZWIDTH'   ''  ''  ''  10   'Width (mm)'   ''  ''  ''  '',
      'ZZLENGTH'   ''  ''  ''  12   'Length (M)' ''   ''  ''  '',
      " Added by William at 01.09.2026 (Display Grade and Grade Description columns - generate by AI)"
      'ZZGRADE'   ''  ''  ''  10   'Grade' ''   ''  ''  '',
      'ZZCRITERIA'   ''  ''  ''  8   'Criteria Grade'    ''   ''  ''  '',
      'ZZGRADE_DESC'   ''  ''  ''  30   'Grade Description' ''   ''  ''  '',
      'VEMNG'   ''  ''  ''  12   'Weight (KG)'  ''   ''  ''  '',
      'ZQTYROL'   ''  ''  ''  8   'Qty Roll'  ''   ''  ''  '',
      'ZZTREATMENT'   ''  ''  ''  15   'Treatment'  ''   ''  ''  '',
      'ZZCORE'   ''  ''  ''  6   'Core'   ''   ''  ''  '',
      'ZZPACKING'   ''  ''  ''  18   'Sistem Packing'   ''   ''  ''  '',
      'BESTQ'   ''  ''  ''  16   'Stock Category'   ''   ''  ''  '',
      'SOBKZ'   ''  ''  ''  16   'Special Stock'   ''   ''  ''  '',
      'TXT04'   ''  ''  '' 10   'QA Status '       ''   ''  ''  '',
      'WDATU'   ''  ''  ''  10   'GR HU Date'  ''   ''  ''  '',
      'ZZEXPIREDLIVE'   ''  ''  ''  10   'Expired Date'  ''   ''  ''  '',
      'ERSDA'   ''  ''  ''  10   'Production Date'   ''  ''  ''  '',
      'BSTKD'   ''  ''  ''  6   'PO Number'   ''  ''  ''  '',
      'ZPINUM'   ''  ''  ''  6   'PI Number'   ''  ''  ''  '',
      'BEZEI'   ''  ''  ''  12   'SO Type Description' ''   ''  ''  '',
      'NAME1'   ''  ''  ''  25   'Customer Name'  ''   ''  ''  '',
      'VBELN'   ''  ''  ''  12   'SO Number'  ''   ''  ''  '',
      'POSNR'   ''  ''  ''  7   'SO Item'  ''   ''  ''  '',
      'VDATU'   ''  ''  ''  10   'Requested Delivery Date'  ''   ''  ''  '',
      'DELUS'   ''  ''  ''  50   'Requested Delivery Status'  ''   ''  ''  '',
      'ZZBLOCK'   ''  ''  ''  10   'Credit Blocked' ''   ''  ''  '',
      'ZNAME1'   ''  ''  ''  20   'Sales Employee'    ''   ''  ''  '',
      'ERDAT'   ''  ''  ''  12   'HU Created Date'  ''   ''  ''  '',
      'ERUHR'   ''  ''  ''  12   'HU Created On'  ''   ''  ''  '',
      'ZZALIAS'  ''  ''  ''  12   'Alias'  ''   ''  ''  '',

      'AWEIGHT'  ''  ''  ''  15   'Actual Weight'  ''   ''  ''  '',
      'ALENGTH'  ''  ''  ''  15   'Actual Length'  ''   ''  ''  '',
      'ACORE'  ''  ''  ''  12   'Act core weight'  ''   ''  ''  '',
      "add by ryan, 02-05-2025, Project Subcont CKI"
      'AGINGTM'  ''  ''  ''  12   'Aging Time (H)'  ''   ''  ''  ''
      .

  IF P_ACTUAL = ''.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'AWEIGHT'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'ALENGTH'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'ACORE'.
  ENDIF.

ENDFORM.                    " F_FIELD_CATALOG


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_HU_QA_REASON
*&---------------------------------------------------------------------*
* Reads the latest HU QA reason for all unique handling units in one
* database operation and maps the result back to the report output.
*----------------------------------------------------------------------*
FORM GET_HU_QA_REASON.
  TYPES: BEGIN OF TY_HU_KEY,
           EXIDV LIKE ZQM001-EXIDV,
         END OF TY_HU_KEY,
         BEGIN OF TY_HU_REASON,
           EXIDV LIKE ZQM001-EXIDV,
           SEQ   LIKE ZQM001-SEQ,
           NOTE  LIKE ZQM001-NOTE,
         END OF TY_HU_REASON.
  DATA: LT_HU_KEY TYPE SORTED TABLE OF TY_HU_KEY
          WITH UNIQUE KEY EXIDV,
        LT_HU_REASON TYPE STANDARD TABLE OF TY_HU_REASON,
        LS_HU_KEY TYPE TY_HU_KEY,
        LS_HU_REASON TYPE TY_HU_REASON,
        LS_CACHE TYPE TY_HU_REASON_CACHE.

  REFRESH: GT_HU_REASON_CACHE, LT_HU_REASON.

  " Collect only unique, usable HUs before accessing ZQM001.
  LOOP AT IT_HU WHERE EXIDV IS NOT INITIAL.
    CLEAR LS_HU_KEY.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IT_HU-EXIDV
      IMPORTING
        OUTPUT = LS_HU_KEY-EXIDV.
    IF LS_HU_KEY-EXIDV IS NOT INITIAL.
      INSERT LS_HU_KEY INTO TABLE LT_HU_KEY.
    ENDIF.
  ENDLOOP.

  " Modified by William at 01.09.2026 (Optimize HU and Batch QA Reason with bulk reads - generate by AI)
  IF LT_HU_KEY IS NOT INITIAL.
    SELECT EXIDV SEQ NOTE
      INTO TABLE LT_HU_REASON
      FROM ZQM001
      FOR ALL ENTRIES IN LT_HU_KEY
      WHERE EXIDV = LT_HU_KEY-EXIDV.

    SORT LT_HU_REASON BY EXIDV ASCENDING SEQ DESCENDING.
    LOOP AT LT_HU_REASON INTO LS_HU_REASON.
      CLEAR LS_CACHE.
      LS_CACHE-EXIDV = LS_HU_REASON-EXIDV.
      LS_CACHE-REASON = LS_HU_REASON-NOTE.
      " Keep the first row only: sorting has placed the highest SEQ first.
      READ TABLE GT_HU_REASON_CACHE TRANSPORTING NO FIELDS
        WITH TABLE KEY EXIDV = LS_HU_REASON-EXIDV.
      IF SY-SUBRC <> 0.
        INSERT LS_CACHE INTO TABLE GT_HU_REASON_CACHE.
      ENDIF.
    ENDLOOP.
  ENDIF.

  " Map the prepared lookup without further database access.
  LOOP AT IT_HU WHERE EXIDV IS NOT INITIAL.
    CLEAR: LS_HU_KEY, LS_CACHE, IT_HU-HUHOLD.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IT_HU-EXIDV
      IMPORTING
        OUTPUT = LS_HU_KEY-EXIDV.
    READ TABLE GT_HU_REASON_CACHE INTO LS_CACHE
      WITH TABLE KEY EXIDV = LS_HU_KEY-EXIDV.
    IF SY-SUBRC = 0.
      IT_HU-HUHOLD = LS_CACHE-REASON.
    ENDIF.
    MODIFY IT_HU TRANSPORTING HUHOLD.
  ENDLOOP.
ENDFORM.                    " GET_HU_QA_REASON

*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_QA_REASON
*&---------------------------------------------------------------------*
* Reads the latest Z04 inspection lot per batch, excludes a canceled
* latest lot, and falls back to the latest nonblank QA log reason.
*----------------------------------------------------------------------*
FORM GET_BATCH_QA_REASON.
  TYPES: BEGIN OF TY_BATCH_KEY,
           CHARG LIKE QALS-CHARG,
           MATNR LIKE QALS-MATNR,
           WERKS LIKE QALS-WERK,
         END OF TY_BATCH_KEY,
         BEGIN OF TY_LOT,
           CHARG     LIKE QALS-CHARG,
           MATNR     LIKE QALS-MATNR,
           WERKS     LIKE QALS-WERK,
           PRUEFLOS  LIKE QALS-PRUEFLOS,
           OBJNR     LIKE QALS-OBJNR,
           TDNAME    LIKE THEAD-TDNAME,
         END OF TY_LOT,
         BEGIN OF TY_STATUS,
           OBJNR LIKE JEST-OBJNR,
         END OF TY_STATUS,
         BEGIN OF TY_TEXT_HEADER,
           TDNAME LIKE STXH-TDNAME,
         END OF TY_TEXT_HEADER,
         BEGIN OF TY_ZLOG_REASON,
           CHARG LIKE ZLOG_QA_REASON-CHARG,
           ID    LIKE ZLOG_QA_REASON-ID,
           TEXT  LIKE ZLOG_QA_REASON-TEXT,
         END OF TY_ZLOG_REASON,
         BEGIN OF TY_LOG_CACHE,
           CHARG  LIKE ZLOG_QA_REASON-CHARG,
           REASON TYPE STRING,
         END OF TY_LOG_CACHE.
  DATA: LT_BATCH_KEY TYPE SORTED TABLE OF TY_BATCH_KEY
          WITH UNIQUE KEY CHARG MATNR WERKS,
        LT_FALLBACK_KEY TYPE SORTED TABLE OF TY_BATCH_KEY
          WITH UNIQUE KEY CHARG MATNR WERKS,
        LT_LOT TYPE STANDARD TABLE OF TY_LOT,
        LT_LATEST_LOT TYPE SORTED TABLE OF TY_LOT
          WITH UNIQUE KEY CHARG MATNR WERKS,
        LT_STATUS TYPE SORTED TABLE OF TY_STATUS
          WITH UNIQUE KEY OBJNR,
        LT_TEXT_HEADER TYPE SORTED TABLE OF TY_TEXT_HEADER
          WITH UNIQUE KEY TDNAME,
        LT_ZLOG_REASON TYPE STANDARD TABLE OF TY_ZLOG_REASON,
        LT_LOG_CACHE TYPE SORTED TABLE OF TY_LOG_CACHE
          WITH UNIQUE KEY CHARG,
        LT_TLINE TYPE STANDARD TABLE OF TLINE,
        LS_BATCH_KEY TYPE TY_BATCH_KEY,
        LS_LOT TYPE TY_LOT,
        LS_STATUS TYPE TY_STATUS,
        LS_TEXT_HEADER TYPE TY_TEXT_HEADER,
        LS_ZLOG_REASON TYPE TY_ZLOG_REASON,
        LS_LOG_CACHE TYPE TY_LOG_CACHE,
        LS_TLINE TYPE TLINE,
        LS_CACHE TYPE TY_BATCH_REASON_CACHE,
        LV_TEXTLINE LIKE TLINE-TDLINE,
        LV_TEXT_CHECK TYPE STRING.

  REFRESH: GT_BATCH_REASON_CACHE, LT_LOT, LT_ZLOG_REASON.

  " Use batch, material, and plant to avoid mixing identical batch IDs.
  LOOP AT IT_HU WHERE CHARG IS NOT INITIAL.
    CLEAR LS_BATCH_KEY.
    LS_BATCH_KEY-CHARG = IT_HU-CHARG.
    LS_BATCH_KEY-MATNR = IT_HU-MATNR.
    LS_BATCH_KEY-WERKS = IT_HU-WERKS.
    INSERT LS_BATCH_KEY INTO TABLE LT_BATCH_KEY.
  ENDLOOP.

  " Modified by William at 01.09.2026 (Optimize HU and Batch QA Reason with bulk reads - generate by AI)
  IF LT_BATCH_KEY IS NOT INITIAL.
    SELECT CHARG MATNR WERK AS WERKS PRUEFLOS OBJNR
      INTO CORRESPONDING FIELDS OF TABLE LT_LOT
      FROM QALS
      FOR ALL ENTRIES IN LT_BATCH_KEY
      WHERE CHARG = LT_BATCH_KEY-CHARG
        AND MATNR = LT_BATCH_KEY-MATNR
        AND WERK = LT_BATCH_KEY-WERKS
        AND ART = 'Z04'.

    SORT LT_LOT BY CHARG ASCENDING MATNR ASCENDING WERKS ASCENDING
                   PRUEFLOS DESCENDING.
    LOOP AT LT_LOT INTO LS_LOT.
      INSERT LS_LOT INTO TABLE LT_LATEST_LOT.
    ENDLOOP.

    IF LT_LATEST_LOT IS NOT INITIAL.
      SELECT OBJNR
        INTO TABLE LT_STATUS
        FROM JEST
        FOR ALL ENTRIES IN LT_LATEST_LOT
        WHERE OBJNR = LT_LATEST_LOT-OBJNR
          AND STAT = 'I0224'
          AND INACT = ''.

      " Prepare long-text names only for latest lots that are not canceled.
      LOOP AT LT_LATEST_LOT INTO LS_LOT.
        READ TABLE LT_STATUS INTO LS_STATUS
          WITH TABLE KEY OBJNR = LS_LOT-OBJNR.
        IF SY-SUBRC = 0.
          CONTINUE.
        ENDIF.
        CONCATENATE SY-MANDT LS_LOT-PRUEFLOS 'L' INTO LS_LOT-TDNAME.
        CONDENSE LS_LOT-TDNAME NO-GAPS.
        MODIFY TABLE LT_LATEST_LOT FROM LS_LOT.
      ENDLOOP.

      SELECT TDNAME
        INTO TABLE LT_TEXT_HEADER
        FROM STXH
        FOR ALL ENTRIES IN LT_LATEST_LOT
        WHERE TDOBJECT = 'QPRUEFLOS'
          AND TDNAME = LT_LATEST_LOT-TDNAME
          AND TDID = 'QAVE'
          AND TDSPRAS = 'E'.
    ENDIF.

    " READ_TEXT remains one call per existing unique long text.
    LOOP AT LT_LATEST_LOT INTO LS_LOT WHERE TDNAME IS NOT INITIAL.
      CLEAR: LS_CACHE, LV_TEXTLINE, LV_TEXT_CHECK.
      REFRESH LT_TLINE.
      READ TABLE LT_TEXT_HEADER INTO LS_TEXT_HEADER
        WITH TABLE KEY TDNAME = LS_LOT-TDNAME.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            CLIENT   = SY-MANDT
            ID       = 'QAVE'
            LANGUAGE = 'E'
            NAME     = LS_LOT-TDNAME
            OBJECT   = 'QPRUEFLOS'
          TABLES
            LINES    = LT_TLINE
          EXCEPTIONS
            OTHERS   = 1.
        IF SY-SUBRC = 0.
          LOOP AT LT_TLINE INTO LS_TLINE WHERE TDLINE IS NOT INITIAL.
            IF LS_TLINE-TDFORMAT = '>1'.
              CONTINUE.
            ENDIF.
            LV_TEXTLINE = LS_TLINE-TDLINE.
            IF LV_TEXTLINE = 'Enter comments:'.
              CONTINUE.
            ENDIF.
            IF LV_TEXTLINE CP 'Enter comments:*'.
              SHIFT LV_TEXTLINE BY 15 PLACES LEFT.
              CONDENSE LV_TEXTLINE.
            ENDIF.
            LV_TEXT_CHECK = LV_TEXTLINE.
            CONDENSE LV_TEXT_CHECK NO-GAPS.
            IF LV_TEXT_CHECK IS NOT INITIAL.
              LS_CACHE-REASON = LV_TEXTLINE.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
      LS_CACHE-CHARG = LS_LOT-CHARG.
      LS_CACHE-MATNR = LS_LOT-MATNR.
      LS_CACHE-WERKS = LS_LOT-WERKS.
      INSERT LS_CACHE INTO TABLE GT_BATCH_REASON_CACHE.
    ENDLOOP.

    " Restrict fallback reads to batches without a usable inspection text.
    LOOP AT LT_BATCH_KEY INTO LS_BATCH_KEY.
      CLEAR: LS_CACHE, LV_TEXT_CHECK.
      READ TABLE GT_BATCH_REASON_CACHE INTO LS_CACHE
        WITH TABLE KEY CHARG = LS_BATCH_KEY-CHARG
                       MATNR = LS_BATCH_KEY-MATNR
                       WERKS = LS_BATCH_KEY-WERKS.
      LV_TEXT_CHECK = LS_CACHE-REASON.
      CONDENSE LV_TEXT_CHECK NO-GAPS.
      IF LV_TEXT_CHECK IS INITIAL.
        INSERT LS_BATCH_KEY INTO TABLE LT_FALLBACK_KEY.
      ENDIF.
    ENDLOOP.

    IF LT_FALLBACK_KEY IS NOT INITIAL.
      SELECT CHARG ID TEXT
        INTO TABLE LT_ZLOG_REASON
        FROM ZLOG_QA_REASON
        FOR ALL ENTRIES IN LT_FALLBACK_KEY
        WHERE CHARG = LT_FALLBACK_KEY-CHARG.
    ENDIF.
    SORT LT_ZLOG_REASON BY CHARG ASCENDING ID DESCENDING.
    LOOP AT LT_ZLOG_REASON INTO LS_ZLOG_REASON.
      LV_TEXT_CHECK = LS_ZLOG_REASON-TEXT.
      CONDENSE LV_TEXT_CHECK NO-GAPS.
      IF LV_TEXT_CHECK IS INITIAL.
        CONTINUE.
      ENDIF.
      CLEAR LS_LOG_CACHE.
      LS_LOG_CACHE-CHARG = LS_ZLOG_REASON-CHARG.
      LS_LOG_CACHE-REASON = LS_ZLOG_REASON-TEXT.
      INSERT LS_LOG_CACHE INTO TABLE LT_LOG_CACHE.
    ENDLOOP.
  ENDIF.

  " Apply long text first; use the QA log only when it is blank or absent.
  LOOP AT LT_BATCH_KEY INTO LS_BATCH_KEY.
    CLEAR LS_CACHE.
    READ TABLE GT_BATCH_REASON_CACHE INTO LS_CACHE
      WITH TABLE KEY CHARG = LS_BATCH_KEY-CHARG
                     MATNR = LS_BATCH_KEY-MATNR
                     WERKS = LS_BATCH_KEY-WERKS.
    IF SY-SUBRC <> 0.
      LS_CACHE-CHARG = LS_BATCH_KEY-CHARG.
      LS_CACHE-MATNR = LS_BATCH_KEY-MATNR.
      LS_CACHE-WERKS = LS_BATCH_KEY-WERKS.
    ENDIF.
    LV_TEXT_CHECK = LS_CACHE-REASON.
    CONDENSE LV_TEXT_CHECK NO-GAPS.
    IF LV_TEXT_CHECK IS INITIAL.
      READ TABLE LT_LOG_CACHE INTO LS_LOG_CACHE
        WITH TABLE KEY CHARG = LS_BATCH_KEY-CHARG.
      IF SY-SUBRC = 0.
        LS_CACHE-REASON = LS_LOG_CACHE-REASON.
      ENDIF.
    ENDIF.
    MODIFY TABLE GT_BATCH_REASON_CACHE FROM LS_CACHE.
    IF SY-SUBRC <> 0.
      INSERT LS_CACHE INTO TABLE GT_BATCH_REASON_CACHE.
    ENDIF.
  ENDLOOP.

  LOOP AT IT_HU WHERE CHARG IS NOT INITIAL.
    CLEAR: LS_CACHE, IT_HU-BATCHHOLD.
    READ TABLE GT_BATCH_REASON_CACHE INTO LS_CACHE
      WITH TABLE KEY CHARG = IT_HU-CHARG
                     MATNR = IT_HU-MATNR
                     WERKS = IT_HU-WERKS.
    IF SY-SUBRC = 0.
      IT_HU-BATCHHOLD = LS_CACHE-REASON.
    ENDIF.
    MODIFY IT_HU TRANSPORTING BATCHHOLD.
  ENDLOOP.
ENDFORM.                    " GET_BATCH_QA_REASON

FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.
ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_HU
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_HU'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  SY-LSIND = 0.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  GET_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0017   text
*----------------------------------------------------------------------*
FORM GET_F4  USING    VALUE(P_0017).

  DATA : V_CHARG TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_CHARG.
  REFRESH : IT_CHARG.
  "-GET DATA CHARG
  SELECT
    MCHA~CHARG
    MCHA~MATNR
    MCHA~WERKS
    INTO CORRESPONDING FIELDS OF TABLE IT_CHARG
    FROM MCHA
    INNER JOIN MARA ON MCHA~MATNR = MARA~MATNR
    INNER JOIN VEPO ON MCHA~CHARG = VEPO~CHARG
    INNER JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
      WHERE VEKP~STATUS NE '0050'
        AND VEKP~STATUS NE '0060'
        AND VEKP~STATUS NE '0001'
        AND MARA~MTART EQ 'ZFGS'.

  SORT IT_CHARG ASCENDING BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.

  CASE P_0017.
    WHEN 'LOW'.
      V_CHARG = 'S_CHARG-LOW'.
    WHEN 'HIGH'.
      V_CHARG = 'S_CHARG-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'CHARG'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_CHARG
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_CHARG.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.



ENDFORM.                    " GET_F4

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON2 USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = ''.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

*&---------------------------------------------------------------------*
*&      Form  EXP_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXP_SQL.
  DATA : COUNT TYPE P.

  TRY .
      EXEC SQL.
        DELETE  FROM XZSD012N
      ENDEXEC.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.
    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution delete' TYPE 'I'.
      RETURN.
  ENDTRY.

  TRY.
*      COUNT = 0.
      LOOP AT IT_HU ASSIGNING <FS_HU>.
*        COUNT = COUNT + 1.
        EXEC SQL.
          INSERT INTO XZSD012N(ZCOLUMN0,ZCOLUMN1,ZCOLUMN2,ZCOLUMN3,ZCOLUMN4,ZCOLUMN5,ZCOLUMN6,ZCOLUMN7,ZCOLUMN8,ZCOLUMN9,ZCOLUMN10,ZCOLUMN11,ZCOLUMN12
                              ,ZCOLUMN13,ZCOLUMN14,ZCOLUMN15,ZCOLUMN16,ZCOLUMN17,ZCOLUMN18,ZCOLUMN19,ZCOLUMN20,ZCOLUMN21,ZCOLUMN22,ZCOLUMN23,ZCOLUMN24
                              ,ZCOLUMN25,ZCOLUMN26,ZCOLUMN27,ZCOLUMN28,ZCOLUMN29,ZCOLUMN30,ZCOLUMN31,ZCOLUMN32,ZCOLUMN33,ZCOLUMN34,ZCOLUMN35,ZCOLUMN36
                              ,ZCOLUMN37,ZCOLUMN38)
          VALUES(:<FS_HU>-WERKS,:<FS_HU>-LGORT,:<FS_HU>-LGNUM,:<FS_HU>-LGPLA,:<FS_HU>-ZZEXIDV,:<FS_HU>-EXIDV,:<FS_HU>-ZEXIDV,:<FS_HU>-MATNR,:<FS_HU>-CHARG,:<FS_HU>-ZZNOMORROLL,
                 :<FS_HU>-ZZTYPE,:<FS_HU>-ZZTHICKNESS,:<FS_HU>-ZZWIDTH,:<FS_HU>-ZZLENGTH,:<FS_HU>-ZZCRITERIA,:<FS_HU>-VEMNG,:<FS_HU>-ZQTYROL,:<FS_HU>-ZZTREATMENT,:<FS_HU>-ZZCORE,:<FS_HU>-ZZPACKING,
                 :<FS_HU>-BESTQ,:<FS_HU>-SOBKZ,:<FS_HU>-TXT04,:<FS_HU>-ERDAT,:<FS_HU>-WDATU,:<FS_HU>-ZZEXPIREDLIVE,:<FS_HU>-ERSDA,:<FS_HU>-BSTKD,:<FS_HU>-ZPINUM,:<FS_HU>-BEZEI,
                 :<FS_HU>-NAME1,:<FS_HU>-VBELN,:<FS_HU>-POSNR,:<FS_HU>-VDATU,:<FS_HU>-ZZBLOCK,:<FS_HU>-ZNAME1,:<FS_HU>-ERDAT,:<FS_HU>-ERUHR,:<FS_HU>-DELUS)
        ENDEXEC.

*        IF COUNT = '100'.
*          EXEC SQL.
*            COMMIT WORK
*          ENDEXEC.
*
*          COUNT = 0.
*        ENDIF.
      ENDLOOP.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution insert' TYPE 'I'.
      RETURN.
  ENDTRY.

  IF SY-SUBRC  = 0.
    MESSAGE 'Penyimpanan Data ke SQL sukses!!!' TYPE 'I'.
  ENDIF.

ENDFORM.                    "EXP_SQL


*&---------------------------------------------------------------------*
*&      Form  GET_AUART_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0072   text
*----------------------------------------------------------------------*
FORM GET_AUART_F4  USING    VALUE(P_0072).
  DATA : V_AUART TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_AUART.
  REFRESH : IT_AUART.

  "-GET DATA AUART
  SELECT
    VBAK~AUART
    TVAKT~BEZEI

    INTO CORRESPONDING FIELDS OF TABLE IT_AUART
    FROM VBAK
    INNER JOIN TVAKT ON VBAK~AUART = TVAKT~AUART
    WHERE VBAK~AUART LIKE 'Z%'
      AND TVAKT~SPRAS EQ 'E'.

  SORT IT_AUART ASCENDING BY AUART.
  DELETE ADJACENT DUPLICATES FROM IT_AUART COMPARING AUART.


  CASE P_0072.
    WHEN 'LOW'.
      V_AUART = 'S_AUART-LOW'.
    WHEN 'HIGH'.
      V_AUART = 'S_AUART-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'AUART'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_AUART
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_AUART.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.



ENDFORM.                    " GET_AUART_F4


*&---------------------------------------------------------------------*
*&      Form  GET_VBELN_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0092   text
*----------------------------------------------------------------------*
FORM GET_VBELN_F4  USING    VALUE(P_0092).
  DATA : V_VBELN TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_VBELN.
  REFRESH : IT_VBELN.

  "-GET DATA VBELN
  SELECT
    VBAK~VBELN

    INTO CORRESPONDING FIELDS OF TABLE IT_VBELN
    FROM VBAK
    WHERE VBAK~VBTYP EQ 'C'.

  SORT IT_VBELN ASCENDING BY VBELN.
  DELETE ADJACENT DUPLICATES FROM IT_VBELN COMPARING VBELN.


  CASE P_0092.
    WHEN 'LOW'.
      V_VBELN = 'S_VBELN-LOW'.
    WHEN 'HIGH'.
      V_VBELN = 'S_VBELN-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'VBELN'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_VBELN
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_VBELN.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.

ENDFORM.                    " GET_VBELN_F4


*&---------------------------------------------------------------------*
*&      Form  GET_LGNUM_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0112   text
*----------------------------------------------------------------------*
FORM GET_LGNUM_F4  USING    VALUE(P_0112).
  DATA : V_LGNUM TYPE HELP_INFO-DYNPROFLD.
  CLEAR : IT_LGNUM.
  REFRESH : IT_LGNUM.

  "-GET DATA VBELN
  SELECT
    T300~LGNUM
    T300T~LNUMT

    INTO CORRESPONDING FIELDS OF TABLE IT_LGNUM
    FROM T300
    INNER JOIN T300T ON T300~LGNUM = T300T~LGNUM
    WHERE T300~LGNUM IN ('J01' , 'K01' , 'W01')
      AND T300T~SPRAS EQ 'E'.

  SORT IT_LGNUM ASCENDING BY LGNUM.
  DELETE ADJACENT DUPLICATES FROM IT_LGNUM COMPARING LGNUM.

  CASE P_0112.
    WHEN 'LOW'.
      V_LGNUM = 'S_LGNUM-LOW'.
    WHEN 'HIGH'.
      V_LGNUM = 'S_LGNUM-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'LGNUM'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_LGNUM
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_LGNUM.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.


ENDFORM.                    " GET_LGNUM_F4
*&---------------------------------------------------------------------*
*&      Form  CHECK_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_WERKS .
  CLEAR : VON, TVALUES. REFRESH  : TVALUES.
  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      USER_NAME           = SY-UNAME
      SEL_OBJECT          = 'Z_WERKS'
    TABLES
      VALUES              = TVALUES
    EXCEPTIONS
      USER_NAME_NOT_EXIST = 1
      NOT_AUTHORIZED      = 2
      INTERNAL_ERROR      = 3.

  READ TABLE TVALUES INDEX 1.
  VON = TVALUES-VON.

  CHECK VON NE '*'.


  READ TABLE S_WERKS WITH KEY LOW = '*'.
  IF SY-SUBRC = 0.
    CLEAR : S_WERKS. REFRESH : S_WERKS.
    MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
    S_WERKS-SIGN   = 'I'.
    S_WERKS-OPTION = 'EQ'.
    S_WERKS-LOW    = VON.
    APPEND S_WERKS.
    RETURN.
  ELSE.

    READ TABLE S_WERKS WITH KEY HIGH = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_WERKS. REFRESH : S_WERKS.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      S_WERKS-SIGN   = 'I'.
      S_WERKS-OPTION = 'EQ'.
      S_WERKS-LOW    = VON.
      APPEND S_WERKS.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT S_WERKS.
    IF S_WERKS-LOW NE ''.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-LOW.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        CLEAR : S_WERKS. REFRESH : S_WERKS.
        RETURN.
      ENDIF.
    ENDIF.
    IF S_WERKS-HIGH NE ''.
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD S_WERKS-HIGH.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'E'.
        CLEAR : S_WERKS. REFRESH : S_WERKS.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " CHECK_WERKS
*&---------------------------------------------------------------------*
*&      Form  CHECK_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LGORT .
  CLEAR : VON, TVALUES. REFRESH  : TVALUES.
  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      USER_NAME           = SY-UNAME
      SEL_OBJECT          = 'Z_LGORT'
    TABLES
      VALUES              = TVALUES
    EXCEPTIONS
      USER_NAME_NOT_EXIST = 1
      NOT_AUTHORIZED      = 2
      INTERNAL_ERROR      = 3.

  READ TABLE TVALUES WITH KEY VON = '*'.
  IF SY-SUBRC = 0.
    RETURN.
  ENDIF.


  READ TABLE S_LGORT WITH KEY LOW = '*'.
  IF SY-SUBRC = 0.
    CLEAR : S_LGORT. REFRESH : S_LGORT.
    MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
    LOOP AT TVALUES.
      S_LGORT-SIGN   = 'I'.
      S_LGORT-OPTION = 'EQ'.
      S_LGORT-LOW    = TVALUES-VON.
      APPEND S_LGORT.
    ENDLOOP.
    RETURN.
  ELSE.

    READ TABLE S_LGORT WITH KEY HIGH = '*'.
    IF SY-SUBRC = 0.
      CLEAR : S_LGORT. REFRESH : S_LGORT.
      MESSAGE ID 'IH' TYPE 'I' NUMBER '046'.
      LOOP AT TVALUES.
        S_LGORT-SIGN   = 'I'.
        S_LGORT-OPTION = 'EQ'.
        S_LGORT-LOW    = TVALUES-VON.
        APPEND S_LGORT.
      ENDLOOP.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT S_LGORT.
    IF S_LGORT-LOW NE ''.
      AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-LOW.
      IF SY-SUBRC NE 0.
        MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
        CLEAR : S_LGORT-LOW.
        MODIFY S_LGORT.
      ENDIF.
    ENDIF.
    IF S_LGORT-HIGH NE ''.
      AUTHORITY-CHECK OBJECT 'Z_LGORT' ID 'ZLGORT' FIELD S_LGORT-HIGH.
      IF SY-SUBRC NE 0.
        MESSAGE E000(0K) WITH 'No Authorization to process data' S_LGORT-LOW.
        CLEAR : S_LGORT-HIGH.
        MODIFY S_LGORT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_LGORT


*&---------------------------------------------------------------------*
*&      Form  GET_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_HU.

  "- HU
  IF S_EXIDV[] IS NOT INITIAL.
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE VEKP~EXIDV IN S_EXIDV.

  ELSE.
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
*    WHERE VEKP~EXIDV IN S_EXIDV
*      AND VEPO~WERKS IN S_WERKS
      WHERE VEPO~WERKS IN S_WERKS
      AND VEPO~LGORT IN S_LGORT
      AND VEPO~MATNR IN S_MATNR
      AND VEPO~CHARG IN S_CHARG.
  ENDIF.


  LOOP AT IT_VEKP_TEMP ASSIGNING <FS_VEKP_TEMP>  WHERE UNVEL EQ ''.
    IF <FS_VEKP_TEMP>-MAGRV NE 'TRS' AND <FS_VEKP_TEMP>-MAGRV NE 'LCL'.
      <FS_VEKP_TEMP>-UNVEL = <FS_VEKP_TEMP>-VENUM.
    ENDIF.
  ENDLOOP.

  DELETE IT_VEKP_TEMP WHERE UNVEL = ''.

  IF IT_VEKP_TEMP[] IS NOT INITIAL.
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    INTO CORRESPONDING FIELDS OF TABLE IT_VEKP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    FOR ALL ENTRIES IN IT_VEKP_TEMP
    WHERE VEPO~VENUM = IT_VEKP_TEMP-UNVEL.
  ENDIF.

  LOOP AT IT_VEKP ASSIGNING <FS_VEKP> WHERE UNVEL EQ ''.
    <FS_VEKP>-UNVEL = <FS_VEKP>-VENUM.
  ENDLOOP.

  IF IT_VEKP[] IS NOT INITIAL.
    SELECT
      VEKP~EXIDV
      VEKP~VENUM
      VEKP~MAGRV
      VEKP~ERUHR
      VEKP~UEVEL
      VEPO~UNVEL
      VEPO~WERKS
      VEPO~LGORT
      VEPO~MATNR
      VEPO~CHARG
      VEPO~SONUM
      VEPO~VEMNG
      VEPO~WDATU
      VEPO~BESTQ
      VEPO~SOBKZ
      VEPO~VBELN AS ZVBELN
      VEPO~POSNR AS ZPOSNR
      INTO CORRESPONDING FIELDS OF TABLE IT_HU
      FROM VEKP
      INNER JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
      FOR ALL ENTRIES IN IT_VEKP
      WHERE VEPO~VENUM = IT_VEKP-UNVEL
        AND VEPO~WERKS IN S_WERKS
        AND VEPO~LGORT IN S_LGORT
        AND VEPO~MATNR IN S_MATNR
        AND VEPO~CHARG IN S_CHARG.
*        %_HINTS ORACLE 'INDEX("VEPO" "VEPO~Z02")'.

  ENDIF.
ENDFORM.                    " GET_HU
*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONNECT_SQL .
  SELECT SINGLE DBMS
         FROM DBCON
         INTO DBTYPE
         WHERE CON_NAME = SAP_CON.

  IF DBTYPE = 'MSS'.
    TRY .
      EXEC SQL.
        SET CONNECTION :SAP_CON
      ENDEXEC.

      EXEC SQL.
        CONNECT TO :SAP_CON
      ENDEXEC.

      IF SY-SUBRC <> 0.
        MESSAGE 'Not Connected..!!' TYPE 'I'.
      ELSE.
        MESSAGE 'Database SQL Connected' TYPE 'I'.
      ENDIF.
    ENDTRY.
  ENDIF.
ENDFORM.                    " CONNECT_SQL



*&---------------------------------------------------------------------*
*&      Form  GET_ACTUAL_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ACTUAL_WEIGHT.
  DATA: V_ATINN LIKE CABN-ATINN,
        STOUCH3 LIKE AUSP-ATWRT,
        V_CHAR1(20), V_CHAR2(20), V_CHAR3(20), V_NUM1 TYPE P.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZSPECIALTOUCH-3'.
  LOOP AT IT_HU.
    SELECT SINGLE A~ATWRT INTO STOUCH3
      FROM AUSP AS A JOIN MCH1 AS B ON A~OBJEK = B~CUOBJ_BM
       WHERE B~CHARG = IT_HU-CHARG AND A~ATINN = '0000000850'.
    IF SY-SUBRC = 0.
      SPLIT STOUCH3 AT '-' INTO V_CHAR1 V_CHAR2 V_CHAR3.
      IF V_CHAR1 CO '0123456789. '.
        IT_HU-ALENGTH = V_CHAR1.
      ELSE.
        IT_HU-ALENGTH = 0.
      ENDIF.

      IF V_CHAR2 CO '0123456789. '.
        IT_HU-AWEIGHT = V_CHAR2.
      ELSE.
        IT_HU-AWEIGHT = 0.
      ENDIF.

      IF V_CHAR3 CO '0123456789. '.
        IT_HU-ACORE = V_CHAR3.
      ELSE.
        IT_HU-ACORE = 0.
      ENDIF.

      MODIFY IT_HU.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_actual_weight