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

  IF P_ACTUAL = 'X'.
    PERFORM GET_ACTUAL_WEIGHT.   "get actual weight
  ENDIF.
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
  IF IT_HU[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " DISPLAY_DATA


*&---------------------------------------------------------------------*
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
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
      'ZZNOMORROLL'   ''  ''  ''  15   'Roll Number'   ''   ''  ''  '',
      'ZZTYPE'   ''  ''  ''  5   'Tipe'  ''   ''  ''  '',
      'ZZTHICKNESS'   ''  ''  ''  10   'Thickness (micron)'   ''  ''  ''  '',
      'ZZWIDTH'   ''  ''  ''  10   'Width (mm)'   ''  ''  ''  '',
      'ZZLENGTH'   ''  ''  ''  12   'Length (M)' ''   ''  ''  '',
      'ZZCRITERIA'   ''  ''  ''  8   'Criteria Grade'    ''   ''  ''  '',
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
      'ACORE'  ''  ''  ''  12   'Act core weight'  ''   ''  ''  ''.

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

  DATA : BEGIN OF IT_CHARG OCCURS 0,
          CHARG LIKE MSEG-CHARG,
         END OF IT_CHARG.

  DATA : R_CHARG LIKE S_CHARG OCCURS 0 WITH HEADER LINE.

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
    "REFRESH IT_VEKP_TEMP
    CLEAR: IT_VEKP_TEMP.
    REFRESH: IT_VEKP_TEMP.

    " Special Stock E (MSKA)
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    APPENDING CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE
      VEPO~CHARG IN ( SELECT CHARG
     FROM MSKA JOIN VBAK
       ON MSKA~VBELN EQ VBAK~VBELN
       WHERE
     MSKA~VBELN IN S_VBELN AND
     WERKS IN S_WERKS AND
     LGORT IN S_LGORT AND
     MATNR IN S_MATNR AND
     CHARG IN S_CHARG AND
     AUART IN S_AUART AND
     KALAB > 0 ) .

    " No Special Stock (MCHB)
*    SELECT
*    VEKP~EXIDV
*    VEKP~MAGRV
*    VEPO~VENUM
*    VEPO~UNVEL
*    APPENDING CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
*    FROM VEKP
*    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
*    WHERE
*      VEPO~CHARG IN ( SELECT CHARG
*    FROM MCHB
*    WHERE
*    WERKS IN S_WERKS AND
*    LGORT IN S_LGORT AND
*    MATNR IN S_MATNR AND
*    CHARG IN S_CHARG AND
*    CLABS > 0 ) .

   " Special Stock O (MSLB)
*    SELECT
*    VEKP~EXIDV
*    VEKP~MAGRV
*    VEPO~VENUM
*    VEPO~UNVEL
*    APPENDING CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
*    FROM VEKP
*    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
*    WHERE
*      VEPO~CHARG IN ( SELECT CHARG
*    FROM MSLB
*    WHERE
*    WERKS IN S_WERKS AND
*    MATNR IN S_MATNR AND
*    CHARG IN S_CHARG AND
*    LBLAB > 0
*    AND SOBKZ EQ 'O' ) .

   " Special Stock W (MSKU)
    SELECT
    VEKP~EXIDV
    VEKP~MAGRV
    VEPO~VENUM
    VEPO~UNVEL
    APPENDING CORRESPONDING FIELDS OF TABLE IT_VEKP_TEMP
    FROM VEKP
    INNER JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
    WHERE
      VEPO~CHARG IN ( SELECT CHARG
    FROM MSKU
    WHERE
    WERKS IN S_WERKS AND
    MATNR IN S_MATNR AND
    CHARG IN S_CHARG AND
    KULAB > 0
    AND SOBKZ EQ 'W' ) .
  ENDIF.


  LOOP AT IT_VEKP_TEMP ASSIGNING <FS_VEKP_TEMP>  WHERE UNVEL EQ ''.
    IF <FS_VEKP_TEMP>-MAGRV NE 'TRS' AND <FS_VEKP_TEMP>-MAGRV NE 'LCL'.
      <FS_VEKP_TEMP>-UNVEL = <FS_VEKP_TEMP>-VENUM.
    ENDIF.
  ENDLOOP.

  DELETE IT_VEKP_TEMP WHERE UNVEL = ''.

  IF IT_VEKP_TEMP[] IS NOT INITIAL.
    "CLEAR IT_VEKP
    CLEAR: IT_VEKP.
    REFRESH: IT_VEKP.

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
    DATA: OREF   TYPE REF TO CX_ROOT.
    TRY.
      "CLEAR IT_HU
      CLEAR: IT_HU.
      REFRESH: IT_HU.

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
      WHERE
        VEPO~VENUM = IT_VEKP-UNVEL
*        AND VEPO~WERKS IN S_WERKS
*        AND VEPO~LGORT IN S_LGORT
*        AND VEPO~MATNR IN S_MATNR
*        AND
*        VEPO~CHARG IN S_CHARG.
*        %_HINTS ORACLE 'INDEX("VEPO" "VEPO~Z02")'.
*      CATCH cx_root INTO oref.
        .
    ENDTRY.

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