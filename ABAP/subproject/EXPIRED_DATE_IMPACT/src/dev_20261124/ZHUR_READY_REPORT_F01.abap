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
  DATA : LV_NUM_OF_ITEMS TYPE I,
         LV_PERCENTAGE  TYPE I,
         LV_PROGRESS_TEXT TYPE STRING.


  CLEAR   : IT_VEKP_TEMP, IT_VEKP.
  REFRESH : IT_VEKP_TEMP, IT_VEKP.

  PERFORM GET_HU.

  SORT IT_HU ASCENDING BY EXIDV.

  DATA: LD_COLOR(10) TYPE C.
  CLEAR : V_EXIDV, V_ZZEXIDV.
  FLAG = 'X'.

  DESCRIBE TABLE IT_HU LINES LV_NUM_OF_ITEMS.
  LOOP AT IT_HU ASSIGNING <FS_HU>.

    "- HU Pallet
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
        DELETE IT_HU.
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
        DELETE IT_HU.
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
        DELETE IT_HU.
        CONTINUE.
      ENDIF.

    ENDIF.

    IF <FS_HU>-ZZEXIDV NE '' AND <FS_HU>-EXIDV EQ ''.
      DELETE IT_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-EXIDV NE ''.
      "- Warehouse Number
      SELECT SINGLE LEIN~LGNUM
        INTO <FS_HU>-LGNUM
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-EXIDV.

      "- Storage Bin
      SELECT SINGLE LEIN~LGPLA
        INTO <FS_HU>-LGPLA
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-EXIDV.

      "- HU Date
      SELECT SINGLE VEKP~ERDAT
        INTO <FS_HU>-ERDAT
        FROM VEKP
        WHERE VEKP~EXIDV = <FS_HU>-EXIDV.

      "- QA Status
      CLEAR : V_VENUM.
      SELECT SINGLE VEKP~VENUM
        INTO V_VENUM
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
      "- Warehouse Number
      SELECT SINGLE LEIN~LGNUM
        INTO <FS_HU>-LGNUM
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-ZEXIDV.

      "- Storage Bin
      SELECT SINGLE LEIN~LGPLA
        INTO <FS_HU>-LGPLA
        FROM LEIN
        WHERE LEIN~LENUM = <FS_HU>-ZEXIDV.

    ENDIF.

    IF S_LGNUM[] IS NOT INITIAL.
      IF <FS_HU>-LGNUM NOT IN S_LGNUM.
        DELETE IT_HU.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF S_LGPLA[] IS NOT INITIAL.
      IF <FS_HU>-LGPLA NOT IN S_LGPLA.
        DELETE IT_HU.
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



    "- Qty Roll
    <FS_HU>-ZQTYROL = '1'.

    IF <FS_HU>-SOBKZ EQ 'E'.
      "- SO Number
      <FS_HU>-VBELN = <FS_HU>-SONUM(10).

      "- SO Item
      <FS_HU>-POSNR = <FS_HU>-SONUM+10(6).

      "- SO Type
      SELECT SINGLE VBAK~AUART
        INTO <FS_HU>-AUART
        FROM VBAK
        WHERE VBAK~VBELN = <FS_HU>-VBELN.

      "- Item Category
      SELECT SINGLE VBAP~PSTYV
      INTO <FS_HU>-PSTYV
      FROM VBAP
      WHERE VBAP~VBELN = <FS_HU>-VBELN
        AND VBAP~POSNR = <FS_HU>-POSNR.

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
        DELETE IT_HU.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF <FS_HU>-VBELN NOT IN S_VBELN.
      DELETE IT_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-POSNR NOT IN S_POSNR.
      DELETE IT_HU.
      CONTINUE.
    ENDIF.

    IF <FS_HU>-AUART NOT IN S_AUART.
      DELETE IT_HU.
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
      DELETE IT_HU.
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
        DELETE IT_HU.
        CONTINUE.
      ENDIF.
    ENDIF.


    CLEAR : IT_XVBPA.
    REFRESH : IT_XVBPA.
    CALL FUNCTION 'SD_PARTNER_READ'
      EXPORTING
        F_VBELN          = <FS_HU>-VBELN
        OBJECT           = 'VBPA'
*       NO_MASTER_ADRESS = ' '
*       IV_NO_INIT       = ' '
*       IV_PARVW         =
*       IV_POSNR         =
      TABLES
        I_XVBADR         = IT_XVBADR
        I_XVBPA          = IT_XVBPA.

    "- Customer Name
    READ TABLE IT_XVBPA WITH KEY PARVW = 'AG'.
    IF SY-SUBRC = 0.
      <FS_HU>-NAME1 = IT_XVBPA-NAME1.
    ENDIF.

    "- Customer Code
    READ TABLE IT_XVBPA WITH KEY PARVW = 'AG'.
    IF SY-SUBRC = 0.
      <FS_HU>-KUNNR = IT_XVBPA-KUNNR.
    ENDIF.



    "- Baseline Date
    REFRESH : IT_BSID.
    CLEAR : WA_BSID.
    SELECT BSID~ZFBDT BSID~ZBD1T BSID~KUNNR BSID~WRBTR BSID~SHKZG
      INTO CORRESPONDING FIELDS OF TABLE IT_BSID
      FROM BSID
      INNER JOIN KNA1 ON BSID~KUNNR = KNA1~KUNNR
        WHERE KNA1~KTOKD IN ('ZLAF', 'ZLOE', 'ZLTP')
          AND BSID~KUNNR = <FS_HU>-KUNNR
          AND BSID~ZBD1T >= 0.

    SORT IT_BSID ASCENDING BY KUNNR ZBD1T.
    LOOP AT IT_BSID.
      IF IT_BSID-SHKZG EQ 'H'.
        IT_BSID-WRBTR = IT_BSID-WRBTR * -1.
      ENDIF.

      IT_BSID-DUEDT = IT_BSID-ZFBDT + IT_BSID-ZBD1T.

      MODIFY IT_BSID.
    ENDLOOP.

    DELETE IT_BSID WHERE WRBTR LE 0.
    SORT IT_BSID ASCENDING BY KUNNR DUEDT.
    READ TABLE IT_BSID INDEX 1 INTO WA_BSID.

    V_BLOCK = SY-DATUM - WA_BSID-DUEDT.

    IF V_BLOCK >= 30.
      <FS_HU>-ZZBLOCK = 'BLOCKED'.
    ELSE.
      <FS_HU>-ZZBLOCK = ''.
    ENDIF.

    IF <FS_HU>-VBELN EQ ''.
      <FS_HU>-ZZBLOCK = ''.
    ENDIF.



    "- Sales Employee
    READ TABLE IT_XVBPA WITH KEY PARVW = 'VE'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZNAME1 = IT_XVBPA-NAME1.
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
         CLIENT                        = SY-MANDT
          ID                            = 'Z101'
          LANGUAGE                      = SY-LANGU
          NAME                          = V_VBELV
          OBJECT                        = 'VBBK'
*             ARCHIVE_HANDLE                = 0
*             LOCAL_CAT                     = ' '
*           IMPORTING
*             HEADER                        =
*             OLD_LINE_COUNTER              =
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
         OTHERS                        = 8
                .
      IF SY-SUBRC <> 0.
*       Implement suitable error handling here
      ENDIF.

      READ TABLE IT_LINE INDEX 1.
      IF SY-SUBRC = 0.
        <FS_HU>-ZPINUM = IT_LINE-TDLINE.
      ENDIF.

    ENDIF.


    "- Production Date
    SELECT SINGLE MCH1~ERSDA
      INTO <FS_HU>-ERSDA
      FROM MCH1
      WHERE MCH1~MATNR = <FS_HU>-MATNR
        AND MCH1~CHARG = <FS_HU>-CHARG.

    "- Requested Delivery Date
    SELECT SINGLE VBAK~VDATU
      INTO <FS_HU>-VDATU
      FROM VBAK
      WHERE VBAK~VBELN = <FS_HU>-VBELN.


  IF <FS_HU>-CHARG NE ''.
    CLEAR   : IT_CHAR.
    REFRESH : IT_CHAR.
    CALL FUNCTION 'ZCHARACTERISTICS_ZSD012N'
      EXPORTING
        I_VAL_MATNR  = <FS_HU>-MATNR
        I_VAL_CHARGE = <FS_HU>-CHARG
      TABLES
        T_VAL_TAB    = IT_CHAR
      EXCEPTIONS
        NO_OBJECT    = 1
        NO_VALUES    = 2.

    IF SY-SUBRC EQ '0'.
      "- Roll Number
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZROLL =  <FS_CHAR>-ATWRT.
      ENDIF.

      "- Tipe
      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTYPE' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZTYPE =  <FS_CHAR>-ATWRT.
      ENDIF.

      "- Thickness
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZTHICKNESS' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        MOVE <FS_CHAR>-ATFLV TO ATFLV1.
        WRITE ATFLV1 TO <FS_HU>-ZZTHICK.
      ENDIF.

      "- Width
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZWIDTH' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        MOVE <FS_CHAR>-ATFLV TO ATFLV2.
        WRITE ATFLV2 TO <FS_HU>-ZZWIDTH.
      ENDIF.

      "- Length
      IF <FS_HU>-MATNR(2) EQ 'SH'.
        READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZLENGTHSHT' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          WRITE ATFLV2 TO <FS_HU>-ZZLENGTH.
        ENDIF.

      ELSE.
        READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZLENGTH' ASSIGNING <FS_CHAR>.
        IF SY-SUBRC = 0.
          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
          WRITE ATFLV2 TO <FS_HU>-ZZLENGTH.
        ENDIF.
      ENDIF.

      "- Criteria Grade
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZCRITERIA' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZGRADE =  <FS_CHAR>-ATWTB.
      ENDIF.

      "- Treatment
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZTREATMENT' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZTREAT =  <FS_CHAR>-ATWTB.
      ENDIF.

      "- Alias
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZALIAS' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZALIAS =  <FS_CHAR>-ATWTB.
      ENDIF.

      "- Core
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZCORE' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZCORE =  <FS_CHAR>-ATWTB.
      ENDIF.

      "- Sistem Packing
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZPACKING' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZPACK =  <FS_CHAR>-ATWTB.
      ENDIF.

      "- Code
      READ TABLE IT_CHAR   WITH KEY ATNAM = 'ZZCODE' ASSIGNING <FS_CHAR>.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZCODE =  <FS_CHAR>-ATWRT.
      ENDIF.

    ENDIF.
  ENDIF.


    "- ZZCODE
    CLEAR : IT_TEMP, IT_ENTRIES, V_VTLINENO.
    REFRESH : IT_TEMP, IT_ENTRIES.
    CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
      EXPORTING
        VAR_TABLE       = 'ZZCODE'
*       CHANGE_NO       =
*       DATE            =
      TABLES
        VAR_TAB_ENTRIES = IT_ENTRIES
      EXCEPTIONS
        ERROR           = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    DELETE IT_ENTRIES WHERE VTCHARACT = 'ZZTHICKNESS'
                         OR VTCHARACT = 'ZZDENSITY'.
    IT_TEMP[] = IT_ENTRIES[].

    DELETE IT_ENTRIES WHERE VTVALUE NE <FS_HU>-ZZCODE.

    LOOP AT IT_ENTRIES.
      LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO = IT_ENTRIES-VTLINENO
**                                       AND VTVALUE  = <FS_HU>-ZZTYPE.
                                       AND VTCHARACT = 'ZZEXPIREDLIVE'.
**          V_VTLINENO = WA_TEMP-VTLINENO.
        V_VTVALUE = WA_TEMP-VTVALUE.
      ENDLOOP.
    ENDLOOP.

    "- Expired Live
    <FS_HU>-ZZEXPR = <FS_HU>-ERSDA + V_VTVALUE.

    "- Colour
    V_EXIDV2 = <FS_HU>-EXIDV.
    IF V_EXIDV NE V_EXIDV2.
      V_EXIDV = <FS_HU>-EXIDV.

      LD_COLOR = LD_COLOR + 1.

      IF LD_COLOR MOD 2 = 1.
        <FS_HU>-LINE_COLOR = ''.
      ELSEIF LD_COLOR MOD 2 = 0.
        <FS_HU>-LINE_COLOR = 'C210'.
      ENDIF.
    ELSE.
      V_EXIDV = <FS_HU>-EXIDV.

      LD_COLOR = LD_COLOR.

      IF LD_COLOR MOD 2 = 1.
        <FS_HU>-LINE_COLOR = ''.
      ELSEIF LD_COLOR MOD 2 = 0.
        <FS_HU>-LINE_COLOR = 'C210'.
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
      'ZZROLL'   ''  ''  ''  15   'Roll Number'   ''   ''  ''  '',
      'ZZTYPE'   ''  ''  ''  5   'Tipe'  ''   ''  ''  '',
      'ZZTHICK'   ''  ''  ''  10   'Thickness (micron)'   ''  ''  ''  '',
      'ZZWIDTH'   ''  ''  ''  10   'Width (mm)'   ''  ''  ''  '',
      'ZZLENGTH'   ''  ''  ''  12   'Length (M)' ''   ''  ''  '',
      'ZZGRADE'   ''  ''  ''  8   'Criteria Grade'    ''   ''  ''  '',
      'VEMNG'   ''  ''  ''  12   'Weight (KG)'  ''   ''  ''  '',
      'ZQTYROL'   ''  ''  ''  8   'Qty Roll'  ''   ''  ''  '',
      'ZZTREAT'   ''  ''  ''  15   'Treatment'  ''   ''  ''  '',
      'ZZCORE'   ''  ''  ''  6   'Core'   ''   ''  ''  '',
      'ZZPACK'   ''  ''  ''  18   'Sistem Packing'   ''   ''  ''  '',
      'BESTQ'   ''  ''  ''  16   'Stock Category'   ''   ''  ''  '',
      'SOBKZ'   ''  ''  ''  16   'Special Stock'   ''   ''  ''  '',
      'TXT04'   ''  ''  '' 10   'QA Status '       ''   ''  ''  '',
      'WDATU'   ''  ''  ''  10   'GR HU Date'  ''   ''  ''  '',
      'ZZEXPR'   ''  ''  ''  10   'Expired Date'  ''   ''  ''  '',
      'ERSDA'   ''  ''  ''  10   'Production Date'   ''  ''  ''  '',
      'BSTKD'   ''  ''  ''  6   'PO Number'   ''  ''  ''  '',
      'ZPINUM'   ''  ''  ''  6   'PI Number'   ''  ''  ''  '',
      'BEZEI'   ''  ''  ''  12   'SO Type Description' ''   ''  ''  '',
      'NAME1'   ''  ''  ''  25   'Customer Name'  ''   ''  ''  '',
      'VBELN'   ''  ''  ''  12   'SO Number'  ''   ''  ''  '',
      'POSNR'   ''  ''  ''  7   'SO Item'  ''   ''  ''  '',
      'VDATU'   ''  ''  ''  10   'Requested Delivery Date'  ''   ''  ''  '',
      'ZZBLOCK'   ''  ''  ''  6   'Credit Blocked' ''   ''  ''  '',
      'ZNAME1'   ''  ''  ''  20   'Sales Employee'    ''   ''  ''  '',
      'ERDAT'   ''  ''  ''  12   'HU Created Date'  ''   ''  ''  '',
      'ERUHR'   ''  ''  ''  12   'HU Created On'  ''   ''  ''  '',
      'ZZALIAS'  ''  ''  ''  12   'Alias'  ''   ''  ''  ''.


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
  EXEC SQL.
    CONNECT TO 'TRIASDB' AS 'DBTRIAL'
  ENDEXEC.

  EXEC SQL.
    SET CONNECTION 'DBTRIAL'
  ENDEXEC.

  EXEC SQL.
    DELETE  FROM ZSD012N
  ENDEXEC.

  LOOP AT IT_HU.
    EXEC SQL.
      INSERT INTO ZSD012N(ZCOLUMN0,ZCOLUMN1,ZCOLUMN2,ZCOLUMN3,ZCOLUMN4,ZCOLUMN5,ZCOLUMN6,ZCOLUMN7,ZCOLUMN8,ZCOLUMN9,ZCOLUMN10,ZCOLUMN11,ZCOLUMN12
                          ,ZCOLUMN13,ZCOLUMN14,ZCOLUMN15,ZCOLUMN16,ZCOLUMN17,ZCOLUMN18,ZCOLUMN19,ZCOLUMN20,ZCOLUMN21,ZCOLUMN22,ZCOLUMN23,ZCOLUMN24
                          ,ZCOLUMN25,ZCOLUMN26,ZCOLUMN27,ZCOLUMN28,ZCOLUMN29,ZCOLUMN30,ZCOLUMN31,ZCOLUMN32,ZCOLUMN33,ZCOLUMN34,ZCOLUMN35,ZCOLUMN36
                          ,ZCOLUMN37)
      VALUES(:IT_HU-WERKS,:IT_HU-LGORT,:IT_HU-LGNUM,:IT_HU-LGPLA,:IT_HU-ZZEXIDV,:IT_HU-EXIDV,:IT_HU-ZEXIDV,:IT_HU-MATNR,:IT_HU-CHARG,:IT_HU-ZZROLL,
             :IT_HU-ZZTYPE,:IT_HU-ZZTHICK,:IT_HU-ZZWIDTH,:IT_HU-ZZLENGTH,:IT_HU-ZZGRADE,:IT_HU-VEMNG,:IT_HU-ZQTYROL,:IT_HU-ZZTREAT,:IT_HU-ZZCORE,:IT_HU-ZZPACK,
             :IT_HU-BESTQ,:IT_HU-SOBKZ,:IT_HU-TXT04,:IT_HU-ERDAT,:IT_HU-WDATU,:IT_HU-ZZEXPR,:IT_HU-ERSDA,:IT_HU-BSTKD,:IT_HU-ZPINUM,:IT_HU-BEZEI,
             :IT_HU-NAME1,:IT_HU-VBELN,:IT_HU-POSNR,:IT_HU-VDATU,:IT_HU-ZZBLOCK,:IT_HU-ZNAME1,:IT_HU-ERDAT,:IT_HU-ERUHR)
    ENDEXEC.
  ENDLOOP.

  MESSAGE 'Penyimpanan Data ke SQL sukses!!!' TYPE 'I'.
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
      WHERE VEKP~EXIDV IN S_EXIDV
        AND VEPO~WERKS IN S_WERKS
        AND VEPO~LGORT IN S_LGORT
        AND VEPO~MATNR IN S_MATNR
        AND VEPO~CHARG IN S_CHARG.
    ENDIF.

      LOOP AT IT_VEKP_TEMP WHERE UNVEL EQ ''.
        IF IT_VEKP_TEMP-MAGRV NE 'TRS' AND IT_VEKP_TEMP-MAGRV NE 'LCL'.
          IT_VEKP_TEMP-UNVEL = IT_VEKP_TEMP-VENUM.
        ENDIF.

        IF IT_VEKP_TEMP-UNVEL EQ ''.
          DELETE IT_VEKP_TEMP.
          CONTINUE.
        ENDIF.
        MODIFY IT_VEKP_TEMP.
      ENDLOOP.

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

      LOOP AT IT_VEKP WHERE UNVEL EQ ''.
        IT_VEKP-UNVEL = IT_VEKP-VENUM.
        MODIFY IT_VEKP.
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

      ENDIF.
ENDFORM.                    " GET_HU