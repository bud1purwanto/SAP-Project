*----------------------------------------------------------------------*
* Include           ZPPI_SR_PROCESS_F01
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Include funcion definition
*
* Application Area - PP
* ABAPer           - William
* Date             - August 06, 2012
*----------------------------------------------------------------------*
* Amendment History                                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SELECTION_TEXT
*&---------------------------------------------------------------------*
*       Form define selection text and title
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECTION_TEXT .

  JDL  = 'Slitting Process Selection :'.                    "#EC NOTEXT
  TXT1 = 'Order Type'.                                      "#EC NOTEXT
  TXT2 = 'Plant'.                                           "#EC NOTEXT
  TXT3 = 'Storage Location'.                                "#EC NOTEXT
  TXT4 = 'Order Number'.                                    "#EC NOTEXT
  TXT5 = 'Material Number'.                                 "#EC NOTEXT
  TXT6 = 'Production Date'.                                 "#EC NOTEXT
  TXT7 = 'Order Status'.                                    "#EC NOTEXT
  TXT8 = 'Resource'.                                        "#EC NOTEXT

ENDFORM.                    " SELECTION_TEXT

*&---------------------------------------------------------------------*
*&      Form  blist_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BLIST_HEADER .
*  WRITE : 'PT. TRIAS SENTOSA Tbk.'.                         "#EC NOTEXT    "disable new company
  WRITE : / 'PROCESS ORDER LIST'.
  WRITE : / '------------------'.   "ditambahkan karena header trias dihapus, ada hardcode index
  SKIP.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.

  WRITE:/1(357)  SY-ULINE.
  WRITE:/1    SY-VLINE,
         2    SPACE,
         3    SPACE,
         (12) 'Order Number' , SY-VLINE,                    "#EC NOTEXT
         (10) 'Material', SY-VLINE,                         "#EC NOTEXT
         (11) 'Status', SY-VLINE,                           "#EC NOTEXT
         (10) 'Prod.Date', SY-VLINE,                        "#EC NOTEXT
         (8)  'Resource', SY-VLINE,                         "#EC NOTEXT
         (4)  'Type', SY-VLINE, "#EC NOTEXT "11 January 2013 penambahan ABLAD di depan
              '  1  ', SY-VLINE NO-GAP,
              '  2  ', SY-VLINE NO-GAP,
              '  3  ', SY-VLINE NO-GAP,
              '  4  ', SY-VLINE NO-GAP,
              '  5  ', SY-VLINE NO-GAP,
              '  6  ', SY-VLINE NO-GAP,
              '  7  ', SY-VLINE NO-GAP,
              '  8  ', SY-VLINE NO-GAP,
              '  9  ', SY-VLINE NO-GAP,
              ' 10  ', SY-VLINE NO-GAP,
              ' 11  ', SY-VLINE NO-GAP,
              ' 12  ', SY-VLINE NO-GAP,
              ' 13  ', SY-VLINE NO-GAP,
              ' 14  ', SY-VLINE NO-GAP,
              ' 15  ', SY-VLINE NO-GAP,
              ' 16  ', SY-VLINE NO-GAP,
              ' 17  ', SY-VLINE NO-GAP,
              ' 18  ', SY-VLINE NO-GAP,
              ' 19  ', SY-VLINE NO-GAP,
              ' 20  ', SY-VLINE NO-GAP,
              ' 21  ', SY-VLINE NO-GAP,
              ' 22  ', SY-VLINE NO-GAP,
              ' 23  ', SY-VLINE NO-GAP,
              ' 24  ', SY-VLINE NO-GAP,
              ' 25  ', SY-VLINE NO-GAP,
              ' 26  ', SY-VLINE NO-GAP,
              ' 27  ', SY-VLINE NO-GAP,
              ' 28  ', SY-VLINE NO-GAP,
              ' 29  ', SY-VLINE NO-GAP,
              ' 30  ', SY-VLINE NO-GAP,
              ' 31  ', SY-VLINE NO-GAP,
              ' 32  ', SY-VLINE NO-GAP,
              ' 33  ', SY-VLINE NO-GAP,
              ' 34  ', SY-VLINE NO-GAP,
              ' 35  ', SY-VLINE NO-GAP,
              ' 36  ', SY-VLINE NO-GAP,
              ' 37  ', SY-VLINE NO-GAP,
              ' 38  ', SY-VLINE NO-GAP,
              ' 39  ', SY-VLINE NO-GAP,
              ' 40  ', SY-VLINE NO-GAP.
  WRITE:/1(357)  SY-ULINE.

ENDFORM.                    " blist_header

*&---------------------------------------------------------------------*
*&      Form  f4_help
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0191   text
*----------------------------------------------------------------------*
FORM F4_HELP  USING    VALUE(PARAM).
  DATA : RETFLD     LIKE DFIES-FIELDNAME,
         RETURN_TAB LIKE DDSHRETVAL OCCURS 2 WITH HEADER LINE.

  DATA : BEGIN OF ITAB OCCURS 2,
            TXT04 LIKE TJ02T-TXT04,
            TXT30 LIKE TJ02T-TXT30,
         END OF ITAB.

  SELECT * FROM TJ02T INTO CORRESPONDING FIELDS OF TABLE ITAB
                WHERE SPRAS = SY-LANGU.
  RETFLD = 'TXT04'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      WINDOW_TITLE = 'Original Order Status'                "#EC NOTEXT
      RETFIELD     = RETFLD
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = ITAB " entries to be selected
      RETURN_TAB   = RETURN_TAB.
  CHECK NOT RETURN_TAB[] IS INITIAL.
  READ TABLE RETURN_TAB INDEX 1.
  CASE PARAM.
    WHEN 'low'.
      SO_ISTAT-LOW  = RETURN_TAB-FIELDVAL.
    WHEN 'high'.
      SO_ISTAT-HIGH = RETURN_TAB-FIELDVAL.
  ENDCASE.

ENDFORM.                                                  " F4_help

*&---------------------------------------------------------------------*
*&      Form  read_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ORDER .
  DATA: STATUS  TYPE  CHAR11,
        COUNT LIKE SY-TABIX,
        MBST  LIKE SY-TABIX.

* Characteristics Display Variable
  DATA: ZTYPE TYPE  AUSP-ATWRT,
        ZSIZE TYPE  AUSP-ATWRT,
        TREAT TYPE  AUSP-ATWRT.

  DATA: BEGIN OF IT_AUFNR OCCURS 40,
          AUFNR  LIKE  AFPO-AUFNR,
          ZMILL  LIKE  AFPO-MILL_OC_AUFNR_U,
        END OF IT_AUFNR.

  CLEAR V_AUFK.
  REFRESH V_AUFK.

  SELECT AUFNR AUART INTO TABLE V_AUFK FROM AUFK WHERE AUFNR IN SO_AUFNR AND
                                                       WERKS IN SO_WERKS AND
                                                       AUART IN SO_AUART.
*                                  %_HINTS ORACLE 'INDEX("AUFK" "AUFK~Z02")'.

*add by ALF at 12-09-2007
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.
*end of ALF

  SORT V_AUFK BY AUFNR.

  CLEAR V_AFKO.
  REFRESH V_AFKO.

  SELECT AUFNR PLNBEZ GAMNG GMEIN AUFPL GLTRP INTO TABLE V_AFKO FROM AFKO
  FOR ALL ENTRIES IN V_AUFK WHERE AUFNR = V_AUFK-AUFNR AND GLTRP IN SO_GLTRP AND PLNBEZ IN SO_MATNR ##TOO_MANY_ITAB_FIELDS.
*    %_HINTS ORACLE 'INDEX("AFKO" "AFKO~Z01")'.

  SORT V_AFKO BY AUFNR.

  CLEAR V_AFPO.
  REFRESH V_AFPO.

  "Tambahin ABLAD 11 January 2013
  SELECT AUFNR PWERK MATNR KDAUF KDPOS MILL_OC_AUFNR_U ABLAD INTO TABLE V_AFPO FROM AFPO FOR ALL ENTRIES IN V_AFKO
  WHERE AUFNR = V_AFKO-AUFNR.

  SORT V_AFPO BY AUFNR ZMILL MATNR.

  CLEAR V_VBAK.
  REFRESH V_VBAK.

  SELECT VBELN KNA1~NAME1 INTO TABLE V_VBAK FROM VBAK
  INNER JOIN KNA1 ON KNA1~KUNNR = VBAK~KUNNR
  FOR ALL ENTRIES IN V_AFPO WHERE VBAK~VBELN = V_AFPO-KDAUF.

  SORT V_VBAK BY VBELN.

  CLEAR V_CRHD.
  REFRESH V_CRHD.

  SELECT AFVC~AUFPL CRHD~ARBPL INTO TABLE V_CRHD FROM AFVC
  INNER JOIN CRHD ON CRHD~OBJID = AFVC~ARBID
  FOR ALL ENTRIES IN V_AFKO WHERE AFVC~AUFPL  = V_AFKO-AUFPL AND ( AFVC~STEUS = 'ZP01' OR AFVC~STEUS = 'ZP02' ).

  SORT V_CRHD BY AUFPL.

  CLEAR V_BASIC.
  REFRESH V_BASIC.

  LOOP AT V_AFKO INTO WA_AFKO.
****Add By Will For Patch Combine Order yg ga punya Original Order
    CLEAR: V_MILL.
    SELECT SINGLE MILL_OC_AUFNR_U
      INTO V_MILL
      FROM AFPO
     WHERE AUFNR = WA_AFKO-AUFNR AND MILL_OC_AUFNR_U = ''.
*      %_HINTS ORACLE 'INDEX("AFPO" "AFPO~Z05")'.
    IF SY-SUBRC = 0.
      DELETE V_AFPO WHERE AUFNR = WA_AFKO-AUFNR.
      WA_AFKO-FLAG = 'X'.
      MODIFY V_AFKO FROM WA_AFKO TRANSPORTING FLAG.
      CONTINUE.
    ENDIF.
****End Add By Will For Patch Combine Order yg ga punya Original Order
    WA_BASIC-AUFNR  = WA_AFKO-AUFNR.
    WA_BASIC-GAMNG  = WA_AFKO-GAMNG.
    WA_BASIC-GMEIN  = WA_AFKO-GMEIN.
    WA_BASIC-MATNR  = WA_AFKO-MATNR.
    WA_BASIC-GLTRP  = WA_AFKO-GLTRP.

    READ TABLE V_AUFK INTO WA_AUFK WITH KEY AUFNR = WA_AFKO-AUFNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      WA_BASIC-AUART  = WA_AUFK-AUART.
    ENDIF.

    READ TABLE V_AFPO INTO WA_AFPO WITH KEY AUFNR = WA_AFKO-AUFNR
                                            MATNR = WA_AFKO-MATNR. "BINARY SEARCH.
    IF SY-SUBRC = 0.
      WA_BASIC-KDAUF  = WA_AFPO-KDAUF.
      WA_BASIC-KDPOS  = WA_AFPO-KDPOS.
******11 January 2013
      CLEAR: WA_AFPO.
      READ TABLE V_AFPO INTO WA_AFPO WITH KEY AUFNR = WA_AFKO-AUFNR
                                              MATNR = WA_AFKO-MATNR
                                              ABLAD = 'MS'.
      IF SY-SUBRC = 0.
        WA_BASIC-ABLAD  = WA_AFPO-ABLAD.
      ELSE.
        READ TABLE V_AFPO INTO WA_AFPO WITH KEY AUFNR = WA_AFKO-AUFNR
                                                MATNR = WA_AFKO-MATNR
                                                ABLAD = 'SS'.
        IF SY-SUBRC = 0.
          WA_BASIC-ABLAD  = WA_AFPO-ABLAD.
        ENDIF.
      ENDIF.
******11 January 2013

      READ TABLE V_VBAK INTO WA_VBAK WITH KEY VBELN = WA_AFPO-KDAUF BINARY SEARCH.
      IF SY-SUBRC = 0.
        WA_BASIC-NAME1  = WA_VBAK-NAME1.
      ENDIF.
    ENDIF.

    READ TABLE V_CRHD INTO WA_CRHD WITH KEY AUFPL = WA_AFKO-AUFPL BINARY SEARCH.
    IF SY-SUBRC = 0.
      WA_BASIC-ARBPL  = WA_CRHD-ARBPL.
      WA_AFKO-ARBPL   = WA_CRHD-ARBPL.
      MODIFY V_AFKO FROM WA_AFKO TRANSPORTING ARBPL.
    ENDIF.

    PERFORM GET_ORDER_STATUS USING    WA_BASIC-AUFNR
                             CHANGING WA_BASIC-ZSTAT.

    READ TABLE V_AFPO INTO WA_AFPO WITH KEY AUFNR = WA_AFKO-AUFNR BINARY SEARCH.
    IF SY-SUBRC = 0.
      PERFORM GET_ORDER_STATUS USING    WA_AFPO-ZMILL
                               CHANGING STATUS.
      IF STATUS = 'DLV'.
        WA_BASIC-ZSTAT  = STATUS.
      ENDIF.
    ENDIF.

    WA_BASIC-PLNBE = WA_BASIC-MATNR.

    CLEAR: V_ABLAD.
    SELECT SINGLE ABLAD
      INTO V_ABLAD
      FROM AFPO
     WHERE AUFNR = WA_AFKO-AUFNR AND ABLAD IN ('SS','MS').

    CLEAR COUNT.

    LOOP AT V_AFPO INTO WA_AFPO WHERE AUFNR = WA_AFKO-AUFNR.
      AT NEW ZMILL.
*       New
        CLEAR  : V_MCH1, WA_MCH1, V_LICHA.", <fs_mch1>.
        REFRESH: V_MCH1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = WA_AFPO-ZMILL
          IMPORTING
            OUTPUT = V_LICHA.
        SELECT CHARG INTO TABLE V_MCH1
          FROM MCH1
         WHERE MATNR = WA_AFPO-MATNR AND LICHA = V_LICHA AND
               LVORM = '' ##TOO_MANY_ITAB_FIELDS.
*               %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z01")'.
        LOOP AT V_MCH1 ASSIGNING <FS_MCH1>.

          CLEAR: CHAR_OF_BATCH2, WA_CHAR_OF_BATCH, V_CUOBJ_BM.
          REFRESH: CHAR_OF_BATCH2.

          SELECT SINGLE CUOBJ_BM
            INTO V_CUOBJ_BM
            FROM MCH1
           WHERE MATNR = WA_AFPO-MATNR AND CHARG = <FS_MCH1>-CHARG.

          SELECT CABN~ATNAM AS ATNAM
                 AUSP~ATINN AS ATINN
                 AUSP~ATWRT AS ATWRT
                 AUSP~ATFLV AS ATFLV
            FROM CABN
            JOIN AUSP ON CABN~ATINN = AUSP~ATINN
            INTO CORRESPONDING FIELDS OF TABLE CHAR_OF_BATCH2
            WHERE AUSP~OBJEK  = V_CUOBJ_BM
            AND   CABN~ATNAM IN ('ZZPOSITIONMS','ZZPOSITIONSS').

**          PERFORM VB_INIT.
**
**          CALL FUNCTION 'VB_BATCH_GET_DETAIL'
**            EXPORTING
**              MATNR                    = WA_AFPO-MATNR
**              CHARG                    = <FS_MCH1>-CHARG
**              WERKS                    = WA_AFPO-PWERK
**              GET_CLASSIFICATION       = 'X'
***             EXISTENCE_CHECK          =
***             READ_FROM_BUFFER         =
***             NO_CLASS_INIT            = ' '
***             LOCK_BATCH               = ' '
***           IMPORTING
***             YMCHA                    =
***             CLASSNAME                =
**            TABLES
**              CHAR_OF_BATCH            = CHAR_OF_BATCH
**            EXCEPTIONS
**              NO_MATERIAL              = 1
**              NO_BATCH                 = 2
**              NO_PLANT                 = 3
**              MATERIAL_NOT_FOUND       = 4
**              PLANT_NOT_FOUND          = 5
**              NO_AUTHORITY             = 6
**              BATCH_NOT_EXIST          = 7
**              LOCK_ON_BATCH            = 8
**              OTHERS                   = 9
**                    .
**          IF SY-SUBRC <> 0.
***  Implement suitable error handling here
**          ENDIF.

*          IF WA_AFKO-ARBPL(1) = 'M'.
          UNASSIGN <FS_CHAR_OF_BATCH2>.
          IF V_ABLAD = 'MS'.
            READ TABLE CHAR_OF_BATCH2 ASSIGNING <FS_CHAR_OF_BATCH2> WITH KEY ATNAM = 'ZZPOSITIONMS'." BINARY SEARCH.
            IF SY-SUBRC EQ 0.
              <FS_MCH1>-POSISI = <FS_CHAR_OF_BATCH2>-ATWRT.
*******              CLEAR <fs_char_of_batch>.
*******              READ TABLE CHAR_OF_BATCH ASSIGNING <fs_char_of_batch> WITH KEY ATNAM = 'ZZWIDTH'." BINARY SEARCH.
*******              IF SY-SUBRC EQ 0.
*******                <fs_mch1>-width = <fs_char_of_batch>-ATWTB.
*******              ENDIF.
              SELECT SINGLE ZWIDTH
                INTO <FS_MCH1>-WIDTH
                FROM AUFK
               WHERE AUFNR = WA_AFPO-ZMILL.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  INPUT  = <FS_MCH1>-WIDTH
                IMPORTING
                  OUTPUT = <FS_MCH1>-WIDTH.
            ENDIF.
*          ELSEIF WA_AFKO-ARBPL(1) = 'S' OR WA_AFKO-ARBPL(1) = 'F'.
          ELSEIF V_ABLAD = 'SS'.
            READ TABLE CHAR_OF_BATCH2 ASSIGNING <FS_CHAR_OF_BATCH2> WITH KEY ATNAM = 'ZZPOSITIONSS'." BINARY SEARCH.
            IF SY-SUBRC EQ 0.
              <FS_MCH1>-POSISI = <FS_CHAR_OF_BATCH2>-ATWRT.
*******              CLEAR <fs_char_of_batch>.
*******              READ TABLE CHAR_OF_BATCH ASSIGNING <fs_char_of_batch> WITH KEY ATNAM = 'ZZWIDTH'." BINARY SEARCH.
*******              IF SY-SUBRC EQ 0.
*******                <fs_mch1>-width = <fs_char_of_batch>-ATWTB.
*******              ENDIF.
              SELECT SINGLE ZWIDTH
                INTO <FS_MCH1>-WIDTH
                FROM AUFK
               WHERE AUFNR = WA_AFPO-ZMILL.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  INPUT  = <FS_MCH1>-WIDTH
                IMPORTING
                  OUTPUT = <FS_MCH1>-WIDTH.
            ENDIF.
          ENDIF.

          CASE <FS_MCH1>-POSISI.
            WHEN 1.
              WA_BASIC-POS1  = <FS_MCH1>-WIDTH.
            WHEN 2.
              WA_BASIC-POS2  = <FS_MCH1>-WIDTH.
            WHEN 3.
              WA_BASIC-POS3  = <FS_MCH1>-WIDTH.
            WHEN 4.
              WA_BASIC-POS4  = <FS_MCH1>-WIDTH.
            WHEN 5.
              WA_BASIC-POS5  = <FS_MCH1>-WIDTH.
            WHEN 6.
              WA_BASIC-POS6  = <FS_MCH1>-WIDTH.
            WHEN 7.
              WA_BASIC-POS7  = <FS_MCH1>-WIDTH.
            WHEN 8.
              WA_BASIC-POS8  = <FS_MCH1>-WIDTH.
            WHEN 9.
              WA_BASIC-POS9  = <FS_MCH1>-WIDTH.
            WHEN 10.
              WA_BASIC-POS10 = <FS_MCH1>-WIDTH.
            WHEN 11.
              WA_BASIC-POS11 = <FS_MCH1>-WIDTH.
            WHEN 12.
              WA_BASIC-POS12 = <FS_MCH1>-WIDTH.
            WHEN 13.
              WA_BASIC-POS13 = <FS_MCH1>-WIDTH.
            WHEN 14.
              WA_BASIC-POS14 = <FS_MCH1>-WIDTH.
            WHEN 15.
              WA_BASIC-POS15 = <FS_MCH1>-WIDTH.
            WHEN 16.
              WA_BASIC-POS16 = <FS_MCH1>-WIDTH.
            WHEN 17.
              WA_BASIC-POS17 = <FS_MCH1>-WIDTH.
            WHEN 18.
              WA_BASIC-POS18 = <FS_MCH1>-WIDTH.
            WHEN 19.
              WA_BASIC-POS19 = <FS_MCH1>-WIDTH.
            WHEN 20.
              WA_BASIC-POS20 = <FS_MCH1>-WIDTH.
            WHEN 21.
              WA_BASIC-POS21 = <FS_MCH1>-WIDTH.
            WHEN 22.
              WA_BASIC-POS22 = <FS_MCH1>-WIDTH.
            WHEN 23.
              WA_BASIC-POS23 = <FS_MCH1>-WIDTH.
            WHEN 24.
              WA_BASIC-POS24 = <FS_MCH1>-WIDTH.
            WHEN 25.
              WA_BASIC-POS25 = <FS_MCH1>-WIDTH.
            WHEN 26.
              WA_BASIC-POS26 = <FS_MCH1>-WIDTH.
            WHEN 27.
              WA_BASIC-POS27 = <FS_MCH1>-WIDTH.
            WHEN 28.
              WA_BASIC-POS28 = <FS_MCH1>-WIDTH.
            WHEN 29.
              WA_BASIC-POS29 = <FS_MCH1>-WIDTH.
            WHEN 30.
              WA_BASIC-POS30 = <FS_MCH1>-WIDTH.
            WHEN 31.
              WA_BASIC-POS31 = <FS_MCH1>-WIDTH.
            WHEN 32.
              WA_BASIC-POS32 = <FS_MCH1>-WIDTH.
            WHEN 33.
              WA_BASIC-POS33 = <FS_MCH1>-WIDTH.
            WHEN 34.
              WA_BASIC-POS34 = <FS_MCH1>-WIDTH.
            WHEN 35.
              WA_BASIC-POS35 = <FS_MCH1>-WIDTH.
            WHEN 36.
              WA_BASIC-POS36 = <FS_MCH1>-WIDTH.
            WHEN 37.
              WA_BASIC-POS37 = <FS_MCH1>-WIDTH.
            WHEN 38.
              WA_BASIC-POS38 = <FS_MCH1>-WIDTH.
            WHEN 39.
              WA_BASIC-POS39 = <FS_MCH1>-WIDTH.
            WHEN 40.
              WA_BASIC-POS40 = <FS_MCH1>-WIDTH.
          ENDCASE.

        ENDLOOP.

      ENDAT.
    ENDLOOP.

    APPEND WA_BASIC TO V_BASIC.
    CLEAR WA_BASIC.

  ENDLOOP.

**Add By Will For Patch Combine Order yg gada Original Order Nya
  DELETE V_AFKO WHERE FLAG = 'X'.
**End Add By Will For Patch Combine Order yg gada Original Order Nya

ENDFORM.                    " read_order

*&---------------------------------------------------------------------*
*&      Form  get_order_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BLIST_AUFNR  text
*      <--P_WA_BLIST_STAT  text
*----------------------------------------------------------------------*
FORM GET_ORDER_STATUS USING ORDNR
                      CHANGING STAT.

  DATA : OBJEK(22),
         ITAB  LIKE JSTAT OCCURS 2 WITH HEADER LINE.

  CONCATENATE 'OR' ORDNR INTO OBJEK.
  CALL FUNCTION 'STATUS_READ'
    EXPORTING
      OBJNR       = OBJEK
      ONLY_ACTIVE = 'X'
    TABLES
      STATUS      = ITAB.

*Delete status
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'TECO'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
      EXIT.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'CRTD'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'REL'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'PCNF'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'CNF'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'DLV'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'PDLV'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.

*- add by ALF
  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE TXT04 = 'CLSD'
                                           AND SPRAS = 'EN'.
*                %_HINTS ORACLE 'INDEX("TJ02T" "TJ02T~001")'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_order_status

*&---------------------------------------------------------------------*
*&      Form  display_original_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ORIGINAL_ORDER .

  SET PF-STATUS 'PFST_01'.

  CLEAR REC.
  LOOP AT V_BASIC INTO WA_BASIC WHERE ZSTAT IN SO_ISTAT
                                      AND ( ZSTAT = 'CRTD' OR ZSTAT = 'REL' OR
                                          ZSTAT = 'PCNF' OR ZSTAT = 'CNF' OR
                                          ZSTAT = 'DLV' OR ZSTAT = 'TECO' OR ZSTAT = 'CLSD')
                                      AND ARBPL IN SO_ARBPL.
    REC = REC + 1.
    EXIT.
  ENDLOOP.
  IF REC = 0.
*    MESSAGE I001(00) WITH 'No Data Selected.'. "#EC NOTEXT
    MESSAGE 'No Data Selected.' TYPE 'I'.                   "#EC NOTEXT
    RETCODE = 04.
    EXIT.
  ENDIF.

  CLEAR C.
  LOOP AT V_BASIC INTO WA_BASIC WHERE ZSTAT IN SO_ISTAT
                                      AND ( ZSTAT = 'CRTD' OR ZSTAT = 'REL' OR
                                          ZSTAT = 'PCNF' OR ZSTAT = 'CNF' OR
                                          ZSTAT = 'DLV' OR ZSTAT = 'TECO' OR ZSTAT = 'CLSD')
                                      AND ARBPL IN SO_ARBPL.

    PERFORM SET_COLOR.
    CASE WA_BASIC-ZSTAT.
      WHEN 'CRTD'.
        WA_BASIC-ZSTAT = 'Created'.                         "#EC NOTEXT
      WHEN 'REL'.
        WA_BASIC-ZSTAT = 'Active'.                          "#EC NOTEXT
      WHEN 'PCNF'.
        WA_BASIC-ZSTAT = 'In Progress'.                     "#EC NOTEXT
      WHEN 'CNF'.
        WA_BASIC-ZSTAT = 'Completed'.                       "#EC NOTEXT
      WHEN 'DLV'.
        WA_BASIC-ZSTAT = 'GoodReceipt'.                     "#EC NOTEXT
      WHEN 'TECO'.
        WA_BASIC-ZSTAT = 'TECO'.                            "#EC NOTEXT
      WHEN 'CLSD'.
        WA_BASIC-ZSTAT = 'Closed'.
    ENDCASE.

    WRITE:/1    SY-VLINE,
           2    MARK  AS CHECKBOX,
           3    SPACE,
           (12) WA_BASIC-AUFNR, SY-VLINE,
           (10) WA_BASIC-PLNBE, SY-VLINE,
           (11) WA_BASIC-ZSTAT, SY-VLINE,
           (10) WA_BASIC-GLTRP, SY-VLINE,
           (8)  WA_BASIC-ARBPL, SY-VLINE,
           (4)  WA_BASIC-ABLAD, SY-VLINE, "Unloading Point 11 January 2013
            (5) WA_BASIC-POS1, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS2, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS3, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS4, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS5, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS6, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS7, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS8, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS9, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS10, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS11, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS12, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS13, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS14, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS15, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS16, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS17, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS18, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS19, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS20, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS21, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS22, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS23, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS24, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS25, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS26, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS27, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS28, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS29, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS30, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS31, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS32, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS33, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS34, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS35, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS36, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS37, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS38, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS39, SY-VLINE NO-GAP,
            (5) WA_BASIC-POS40, SY-VLINE NO-GAP.

    COM_ORDER = WA_BASIC-AUFNR.
    HIDE COM_ORDER.

  ENDLOOP.

  WRITE:/1(357)   SY-ULINE.

  CLEAR: LBASIC.
  DESCRIBE TABLE V_BASIC LINES LBASIC.
  LBASIC = LBASIC + 8.

ENDFORM.                    " display_original_order

*&---------------------------------------------------------------------*
*&      Form  set_color
*&---------------------------------------------------------------------*
FORM SET_COLOR .

  IF C IS INITIAL.
    FORMAT COLOR COL_NORMAL INTENSIFIED.
    C = 'x'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    CLEAR C.
  ENDIF.

ENDFORM.                    " set_color

*&---------------------------------------------------------------------*
*&      Form  read_marker_blist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_MARKER_BLIST.
  DATA : COUNT TYPE I,
         OLD_ORDER LIKE COM_ORDER.

  CLEAR : RETCODE.
  COUNT = 0.
  DO.
    CLEAR MARK.
    READ LINE SY-INDEX FIELD VALUE MARK.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK = 'X'.
      COUNT = COUNT + 1.
    ENDIF.
    IF COUNT = 1 AND MARK = 'X'.
      OLD_ORDER = COM_ORDER.
    ELSEIF COUNT > 1.
      RETCODE = 01.
      EXIT.
    ENDIF.
  ENDDO.
  COM_ORDER   = OLD_ORDER.
  IF COUNT  = 0.
    IF SY-UCOMM = 'REFRESH'.
      RETCODE = 04.
    ELSE.
      RETCODE = 02.
    ENDIF.
  ENDIF.
ENDFORM.                    " read_marker_blist

*&---------------------------------------------------------------------*
*&      Form  read_marker_blist_TECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_MARKER_BLIST_TECO .
  DATA : COUNT TYPE I,
         OLD_ORDER LIKE V_ORDER.

  CLEAR IT_TECO.
  REFRESH IT_TECO.
  DO.
    CLEAR MARK.
    READ LINE SY-INDEX FIELD VALUE MARK.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK = 'X'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = COM_ORDER
        IMPORTING
          OUTPUT = COM_ORDER.

      IT_TECO-AUFNR = COM_ORDER.
      SELECT MILL_OC_AUFNR_U INTO IT_TECO-ZMILL FROM AFPO WHERE AUFNR = COM_ORDER.
        APPEND IT_TECO.
      ENDSELECT.
      IF SY-SUBRC <> 0.
        APPEND IT_TECO.
      ENDIF.
      CLEAR IT_TECO.
    ENDIF.
  ENDDO.
ENDFORM.                    " read_marker_blist_TECO

*&---------------------------------------------------------------------*
*&      Form  read_marker_blist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_MARKER_BLIST_REFRESH .
  DATA : COUNT TYPE I,
         OLD_ORDER LIKE V_ORDER.

  CLEAR IT_REF.
  REFRESH IT_REF.
  DO.
    CLEAR MARK.
    READ LINE SY-INDEX FIELD VALUE MARK.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF SY-LISEL+1(10) <> '----------' AND SY-INDEX > 6.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = COM_ORDER
        IMPORTING
          OUTPUT = COM_ORDER.

      IT_REF-AUFNR = COM_ORDER.
      APPEND IT_REF.
      CLEAR IT_REF.
    ENDIF.
  ENDDO.

  RETCODE = 00.
ENDFORM.                    " read_marker_blist_refresh

*&---------------------------------------------------------------------*
*&      Form  find_order_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER  text
*      <--P_AUART  text
*----------------------------------------------------------------------*
FORM FIND_ORDER_TYPE  USING    P_TAB STRUCTURE ZHEADER.

  DATA: BEGIN OF IT_AFPO OCCURS 40,
          AUFNR LIKE  AFPO-AUFNR,
          PWERK LIKE  AFPO-PWERK,
          MATNR LIKE  AFPO-MATNR,
          ZMILL LIKE  AFPO-MILL_OC_AUFNR_U,
        END OF IT_AFPO.

  DATA: COUNTER LIKE SY-TABIX,
        CHAR LIKE ZSCHAR_INT OCCURS 0 WITH HEADER LINE.

  CLEAR: RIBUAN, PULUHAN.
**  PERFORM GET_DEC_NOTATION USING SY-UNAME CHANGING RIBUAN PULUHAN.
  PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.

  CLEAR IT_AFPO.
  REFRESH IT_AFPO.

  CLEAR ZBOXER.
  REFRESH ZBOXER.

  SELECT AUFNR PWERK MATNR MILL_OC_AUFNR_U INTO TABLE IT_AFPO FROM AFPO WHERE AUFNR = ZHEADER-AUFNR.
  LOOP AT IT_AFPO.
    ZBOXER-AUFNR  = IT_AFPO-ZMILL.
    SELECT SINGLE MATNR CHARG
      INTO (ZBOXER-MATNR, ZBOXER-CHARG)
      FROM MCH1
     WHERE MATNR = IT_AFPO-MATNR AND
           LICHA = IT_AFPO-ZMILL.
*         %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z03")'.

    SELECT SINGLE KDAUF KDPOS ZVBELN1 ZPOSNR1 ZVBELN2 ZPOSNR2 ZVBELN3 ZPOSNR3 WERKS
      INTO (ZBOXER-VBELN1, ZBOXER-POSNR1, ZBOXER-VBELN2, ZBOXER-POSNR2,
            ZBOXER-VBELN3, ZBOXER-POSNR3, ZBOXER-VBELN4, ZBOXER-POSNR4,
            ZBOXER-WERKS)
      FROM AUFK
     WHERE AUFNR = IT_AFPO-ZMILL.

    SELECT SINGLE AUFPL INTO AFKO-AUFPL FROM AFKO WHERE AUFNR = IT_AFPO-ZMILL.
    IF SY-SUBRC = 0.
      SELECT SINGLE ARBID INTO *AFVC-ARBID FROM AFVC
                          WHERE AUFPL = AFKO-AUFPL.
      IF SY-SUBRC = 0.
        SELECT SINGLE ARBPL INTO *CRHD-ARBPL FROM CRHD
                           WHERE OBJID = *AFVC-ARBID.
        IF SY-SUBRC = 0.
          ZBOXER-ARBPL = *CRHD-ARBPL.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND ZBOXER.
    CLEAR ZBOXER.
  ENDLOOP.

  DELETE ZBOXER WHERE MATNR = ''.

  CLEAR: COUNTER, V_ORDER.

  REFRESH: V_ORDER.

  READ TABLE ZBOXER INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR CLASS.
    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = ZBOXER-MATNR
*       i_charg      = zheader-charg
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = CLASS.
  ELSE.
    MESSAGE 'Data Tidak Lengkap' TYPE 'I'.                  "#EC NOTEXT
    FLAG = 'X'.
    EXIT.
  ENDIF.

  LOOP AT ZBOXER.
    IF ( ZBOXER-VBELN1 NE SPACE OR ZBOXER-VBELN1 NE '0000000000' ) AND ZBOXER-POSNR1 NE '000000'.
      CLEAR WA_ORDER-V_ORDER1.
      WA_ORDER-V_ORDER1-VBELN  = ZBOXER-VBELN1.
      WA_ORDER-V_ORDER1-POSNR  = ZBOXER-POSNR1.
      PERFORM READ_CHAR_ORDER USING WA_ORDER-V_ORDER1.
    ELSE.
      CLEAR WA_ORDER-V_ORDER1.
    ENDIF.

    IF ( ZBOXER-VBELN2 NE SPACE OR ZBOXER-VBELN2 NE '0000000000' ) AND ZBOXER-POSNR2 NE '000000'.
      CLEAR WA_ORDER-V_ORDER2.
      WA_ORDER-V_ORDER2-VBELN  = ZBOXER-VBELN2.
      WA_ORDER-V_ORDER2-POSNR  = ZBOXER-POSNR2.
      PERFORM READ_CHAR_ORDER USING WA_ORDER-V_ORDER2.
    ELSE.
      CLEAR WA_ORDER-V_ORDER2.
    ENDIF.

    IF ( ZBOXER-VBELN3 NE SPACE OR ZBOXER-VBELN3 NE '0000000000' ) AND ZBOXER-POSNR3 NE '000000'.
      CLEAR WA_ORDER-V_ORDER3.
      WA_ORDER-V_ORDER3-VBELN  = ZBOXER-VBELN3.
      WA_ORDER-V_ORDER3-POSNR  = ZBOXER-POSNR3.
      PERFORM READ_CHAR_ORDER USING WA_ORDER-V_ORDER3.
    ELSE.
      CLEAR WA_ORDER-V_ORDER3.
    ENDIF.

    IF ( ZBOXER-VBELN4 NE SPACE OR ZBOXER-VBELN4 NE '0000000000' ) AND ZBOXER-POSNR4 NE '000000'.
      CLEAR V_ORDER-V_ORDER4.
      WA_ORDER-V_ORDER4-VBELN  = ZBOXER-VBELN4.
      WA_ORDER-V_ORDER4-POSNR  = ZBOXER-POSNR4.
      PERFORM READ_CHAR_ORDER USING WA_ORDER-V_ORDER4.
    ELSE.
      CLEAR WA_ORDER-V_ORDER4.
    ENDIF.

    APPEND WA_ORDER TO V_ORDER.
    CLEAR WA_ORDER.

    IF ZBOXER-MATNR NE SPACE AND ZBOXER-CHARG NE SPACE.
      CLEAR WA_CHAR.
      WA_CHAR-V_CHAR00-MATNR = ZBOXER-MATNR.
      WA_CHAR-V_CHAR00-CHARG = ZBOXER-CHARG.
      WA_CHAR-V_CHAR00-CLASS = CLASS.
      WA_CHAR-V_CHAR00-WERKS = ZBOXER-WERKS.
      PERFORM READ_CHAR USING WA_CHAR.

      APPEND WA_CHAR TO V_CHAR.
      CLEAR WA_CHAR.
    ENDIF.

  ENDLOOP.

  PERFORM F_READ_GRADE_CRITERIA.

ENDFORM.                    " find_order_type

*&---------------------------------------------------------------------*
*&      Form  read_char_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZORDER00  text
*----------------------------------------------------------------------*
FORM READ_CHAR_ORDER    CHANGING P_TAB STRUCTURE ZORDER00.

  DATA: CON_FIG LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
        API_VAL LIKE API_VALUE OCCURS 0 WITH HEADER LINE,
        COUNTER LIKE SY-TABIX,
        OFF     TYPE I,
        TEMP    LIKE AUSP-ATWRT,
        TEMP1   LIKE AUSP-ATWRT.

  DATA : BEGIN OF KY OCCURS 2,
           NAME LIKE BAPI_CHAR-NAME_CHAR,
         END OF KY.

  KY-NAME = 'ZZTYPE'.             APPEND KY.              " CHAR01
  KY-NAME = 'ZZTHICKNESS'.        APPEND KY.              " CHAR02
  KY-NAME = 'ZZWIDTH'.            APPEND KY.              " CHAR03
  KY-NAME = 'ZZLENGTH'.           APPEND KY.              " CHAR04
  KY-NAME = 'ZZINSIDE'.           APPEND KY.              " CHAR05
  KY-NAME = 'ZZOUTSIDE'.          APPEND KY.              " CHAR06
  KY-NAME = 'ZZGRADE'.            APPEND KY.              " CHAR07
  KY-NAME = 'ZZSEQUENCENBR'.      APPEND KY.              " CHAR08
  KY-NAME = 'ZZPRODLINE'.         APPEND KY.              " CHAR09
  KY-NAME = 'ZZMONTHYEAR'.        APPEND KY.              " CHAR10
  KY-NAME = 'ZZCRITERIA'.         APPEND KY.              " CHAR11
  KY-NAME = 'ZZCONVERSIONROLLKG'. APPEND KY.              " CHAR12
  KY-NAME = 'ZZALIAS'.            APPEND KY.              " CHAR13
  KY-NAME = 'ZZNUMBEROFROLL'.     APPEND KY.              " CHAR14
  KY-NAME = 'ZZNUMBEROFSHEET'.    APPEND KY.              " CHAR15
  KY-NAME = 'ZZNUMBEROFPACK'.     APPEND KY.              " CHAR16
**Additional
  KY-NAME = 'ZZCODE'.             APPEND KY.              " CHAR17
  KY-NAME = 'ZZTREATMENT'.        APPEND KY.              " CHAR18
  KY-NAME = 'ZZLABEL'.            APPEND KY.              " CHAR19
  KY-NAME = 'ZZPACKING'.          APPEND KY.              " CHAR20
  KY-NAME = 'ZZSPECIALTOUCH-1'.   APPEND KY.              " CHAR21
  KY-NAME = 'ZZSPECIALTOUCH-2'.   APPEND KY.              " CHAR22
  KY-NAME = 'ZZSPECIALTOUCH-3'.   APPEND KY.              " CHAR23
  KY-NAME = 'ZZPACKINGCODE'.      APPEND KY.              " CHAR24

*  CLEAR: VBAP." 7 January 2013
  SELECT SINGLE CUOBJ INTO VBAP-CUOBJ FROM VBAP WHERE VBELN = P_TAB-VBELN AND POSNR = P_TAB-POSNR.

  CALL FUNCTION '/SAPMP/CE3_GET_CONFIG_SINGLE'
    EXPORTING
      IM_INSTANCE         = VBAP-CUOBJ
* IMPORTING
*   EX_FIELD_ATTR       =
    TABLES
      CONFIGURATION       = CON_FIG
      API_VALUES          = API_VAL
* EXCEPTIONS
*   NOT_FOUND           = 1
*   OTHERS              = 2
            .

  SORT API_VAL BY ATNAM.
  CLEAR COUNTER.
  LOOP AT KY.
    ADD 1 TO COUNTER.
    READ TABLE API_VAL WITH KEY ATNAM = KY-NAME BINARY SEARCH.
    IF SY-SUBRC = 0.
      CASE COUNTER.
        WHEN  1.
          P_TAB-CHAR01  = API_VAL-ATWRT.
        WHEN  2.
          P_TAB-CHAR02  = API_VAL-ATWRT.
        WHEN  3.
          P_TAB-CHAR03  = API_VAL-ATWRT.
        WHEN  4.
          P_TAB-CHAR04  = API_VAL-ATWRT.
        WHEN  5.
          P_TAB-CHAR05  = API_VAL-ATWRT.
        WHEN  6.
          P_TAB-CHAR06  = API_VAL-ATWRT.
        WHEN  7.
          P_TAB-CHAR07  = API_VAL-ATWRT.
        WHEN  8.
          P_TAB-CHAR08  = API_VAL-ATWRT.
        WHEN  9.
          P_TAB-CHAR09  = API_VAL-ATWRT.
        WHEN  10.
          P_TAB-CHAR10  = API_VAL-ATWRT.
        WHEN  11.
          P_TAB-CHAR11  = API_VAL-ATWRT.
        WHEN  12.
          P_TAB-CHAR12  = API_VAL-ATWRT.
        WHEN  13.
          P_TAB-CHAR13  = API_VAL-ATWRT.
        WHEN  14.
          CLEAR OFF.
          CLEAR TEMP.
          SPLIT API_VAL-ATWRT AT ' ' INTO TEMP TEMP1.
          REPLACE ',' WITH ' ' INTO TEMP.
          CONDENSE TEMP NO-GAPS.
          P_TAB-CHAR14  = TEMP.
        WHEN  15.
          CLEAR OFF.
          CLEAR TEMP.
          SPLIT API_VAL-ATWRT AT ' ' INTO TEMP TEMP1.
          REPLACE ',' WITH ' ' INTO TEMP.
          CONDENSE TEMP NO-GAPS.
          P_TAB-CHAR15  = TEMP.
        WHEN  16.
          CLEAR OFF.
          CLEAR TEMP.
          SPLIT API_VAL-ATWRT AT ' ' INTO TEMP TEMP1.
          REPLACE ',' WITH ' ' INTO TEMP.
          CONDENSE TEMP NO-GAPS.
          P_TAB-CHAR16  = TEMP.
        WHEN  17.
          P_TAB-CHAR17  = API_VAL-ATWRT.
        WHEN  18.
          P_TAB-CHAR18  = API_VAL-ATWRT.
        WHEN  19.
          P_TAB-CHAR19  = API_VAL-ATWRT.
        WHEN  20.
          P_TAB-CHAR20  = API_VAL-ATWRT.
        WHEN  21.
          P_TAB-CHAR21  = API_VAL-ATWRT.
        WHEN  22.
          P_TAB-CHAR22  = API_VAL-ATWRT.
        WHEN  23.
          P_TAB-CHAR23  = API_VAL-ATWRT.
        WHEN  24.
          P_TAB-CHAR24  = API_VAL-ATWRT.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " read_char_order

*&---------------------------------------------------------------------*
*&      Form  read_char
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPACK00  text
*----------------------------------------------------------------------*
FORM READ_CHAR  CHANGING P_TAB STRUCTURE ZCHAR00.

  DATA : BEGIN OF KY OCCURS 2,
           NAME LIKE BAPI_CHAR-NAME_CHAR,
         END OF KY.
  DATA : TABIX   LIKE SY-TABIX.

  KY-NAME = 'ZZTYPE'.             APPEND KY.              " CHAR01
  KY-NAME = 'ZZTHICKNESS'.        APPEND KY.              " CHAR02
  KY-NAME = 'ZZWIDTH'.            APPEND KY.              " CHAR03
  KY-NAME = 'ZZLENGTH'.           APPEND KY.              " CHAR04
  KY-NAME = 'ZZINSIDE'.           APPEND KY.              " CHAR05
  KY-NAME = 'ZZOUTSIDE'.          APPEND KY.              " CHAR06
  KY-NAME = 'ZZGRADE'.            APPEND KY.              " CHAR07
  KY-NAME = 'ZZSEQUENCENBR'.      APPEND KY.              " CHAR08
  KY-NAME = 'ZZPRODLINE'.         APPEND KY.              " CHAR09
  KY-NAME = 'ZZMONTHYEAR'.        APPEND KY.              " CHAR10
  KY-NAME = 'ZZCRITERIA'.         APPEND KY.              " CHAR11
  KY-NAME = 'ZZCONVERSIONROLLKG'. APPEND KY.              " CHAR12
  KY-NAME = 'ZZALIAS'.            APPEND KY.              " CHAR13
  KY-NAME = 'ZZCODE'.             APPEND KY.              " CHAR14

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
  REFRESH: CHAR_OF_BATCH.

  PERFORM VB_INIT.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = P_TAB-MATNR
      CHARG                    = P_TAB-CHARG
      WERKS                    = P_TAB-WERKS
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
             .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

  LOOP AT KY.

    TABIX = SY-TABIX.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = KY-NAME BINARY SEARCH.

    IF SY-SUBRC = 0.

      CASE TABIX.
        WHEN 1.
          P_TAB-CHAR01 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 2.
          IF SY-UCOMM = ' '.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR02 DECIMALS 0.
          ELSEIF SY-UCOMM = 'SELEO7'.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR02 DECIMALS 0.
          ELSE.
            P_TAB-CHAR02 = <FS_CHAR_OF_BATCH>-ATWTB.
          ENDIF.
        WHEN 3.
          IF SY-UCOMM = ' '.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR03 DECIMALS 0.
          ELSEIF SY-UCOMM = 'SELEO7'.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR03 DECIMALS 0.
          ELSE.
            P_TAB-CHAR03 = <FS_CHAR_OF_BATCH>-ATWTB.
          ENDIF.
        WHEN 4.
          IF SY-UCOMM = ' '.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR04 DECIMALS 0.
          ELSEIF SY-UCOMM = 'SELEO7'.
            WRITE <FS_CHAR_OF_BATCH>-ATWTB TO P_TAB-CHAR04 DECIMALS 0.
          ELSE.
            P_TAB-CHAR04 = <FS_CHAR_OF_BATCH>-ATWTB.
          ENDIF.
        WHEN 5.
          P_TAB-CHAR05 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 6.
          P_TAB-CHAR06 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 7.
          P_TAB-CHAR07 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 8.
          P_TAB-CHAR08 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 9.
          P_TAB-CHAR09 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 10.
          P_TAB-CHAR10 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 11.
          P_TAB-CHAR11 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 12.
          P_TAB-CHAR12 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 13.
          P_TAB-CHAR13 = <FS_CHAR_OF_BATCH>-ATWTB.
        WHEN 14.
          P_TAB-CHAR14 = <FS_CHAR_OF_BATCH>-ATWTB.
      ENDCASE.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " read_char

*&---------------------------------------------------------------------*
*&      Form  read_grade_criteria
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_READ_GRADE_CRITERIA .

  SELECT C1~VALC C2~VALC
    INTO TABLE ITAB_GRADE_CRITERIA
    FROM CUVTAB_VALC AS C1
      INNER JOIN CUVTAB_VALC AS C2
      ON C1~VTINT = C2~VTINT
        AND C1~SLNID = C2~SLNID
      INNER JOIN CABN AS B1        " ZZGRADE
      ON C1~ATINN = B1~ATINN
      INNER JOIN CABN AS B2        " ZZCRITERIA
      ON C2~ATINN = B2~ATINN
    WHERE B1~ATNAM = 'ZZGRADE'                            " 1150
      AND B2~ATNAM = 'ZZCRITERIA'                         " 1151
  .

ENDFORM.                    " read_grade_criteria

*&---------------------------------------------------------------------*
*&      Form  teco_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TECO_ORDER .

  CLEAR: IT_TECO2.
  REFRESH: IT_TECO2.

  IT_TECO2[] = IT_TECO[].
  SORT IT_TECO2 BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM IT_TECO2 COMPARING AUFNR.

  LOOP AT IT_TECO2.

    CLEAR: E_SYSST, FLAG, VMESS.
    PERFORM GET_STATUS USING IT_TECO2-AUFNR CHANGING E_SYSST.

    IF E_SYSST CP '*TECO*'.
      CONCATENATE 'Order' IT_TECO2-AUFNR 'sudah di TECO' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      MESSAGE VMESS TYPE 'I'.
      IT_TECO2-FLAG = 'X'.
      MODIFY IT_TECO2.
    ELSEIF E_SYSST NP '*GMPS*'.

      DATA: JWB, TEXT_QUESTION TYPE STRING.

      CONCATENATE 'Order' IT_TECO2-AUFNR 'belum di start, apakah mau di TECO?' INTO TEXT_QUESTION SEPARATED BY SPACE. "#EC NOTEXT

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR                    = 'Konfirmasi TECO'   "#EC NOTEXT
*         DIAGNOSE_OBJECT             = ' '
          TEXT_QUESTION               = TEXT_QUESTION
          TEXT_BUTTON_1               = 'TECO'"(001)
*         ICON_BUTTON_1               = ' '
          TEXT_BUTTON_2               = 'Cancel'"(002)
*         ICON_BUTTON_2               = ' '
*         DEFAULT_BUTTON              = '1'
          DISPLAY_CANCEL_BUTTON       = ' '
*         USERDEFINED_F1_HELP         = ' '
          START_COLUMN                = 50"25
          START_ROW                   = 6
*         POPUP_TYPE                  =
*         IV_QUICKINFO_BUTTON_1       = ' '
*         IV_QUICKINFO_BUTTON_2       = ' '
        IMPORTING
          ANSWER                      = JWB
*       TABLES
*         PARAMETER                   =
        EXCEPTIONS
          TEXT_NOT_FOUND              = 1
          OTHERS                      = 2
                .
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.

      IF JWB = 2.
        IT_TECO2-FLAG = 'X'.
        MODIFY IT_TECO2.
      ENDIF.

    ENDIF.

  ENDLOOP.

  LOOP AT IT_TECO2 WHERE FLAG = 'X'.
    LOOP AT IT_TECO WHERE AUFNR = IT_TECO2-AUFNR.
      IT_TECO-FLAG = 'X'.
      MODIFY IT_TECO.
    ENDLOOP.
  ENDLOOP.

  CLEAR: IT_TECO.
  DELETE IT_TECO WHERE FLAG = 'X'.
  READ TABLE IT_TECO INDEX 1.
  IF SY-SUBRC NE 0.
    MESSAGE 'Tidak ada order yang di TECO' TYPE 'I'.        "#EC NOTEXT
    FLAG = 'X'.
    EXIT.
  ENDIF.

  IF FLAG = 'X'.
    EXIT.
  ENDIF.

  DATA: MESSAGE_TABLE LIKE COACTMSG OCCURS 0 WITH HEADER LINE,
        CAUFVTAB LIKE CAUFV OCCURS 0 WITH HEADER LINE.

  CLEAR CAUFVTAB.
  REFRESH CAUFVTAB.

  SELECT * INTO TABLE CAUFVTAB FROM CAUFV FOR ALL ENTRIES IN IT_TECO WHERE AUFNR = IT_TECO-AUFNR.
  CALL FUNCTION 'ORDER_CHANGE_FOR_ACTIVITY'
    EXPORTING
      TESTRUN              = ' '
      FLG_TERM             = ' '
      FLG_COST             = ' '
      FLG_TECL             = 'X'
      FLG_CAPA             = ' '
      FLG_LVS              = ' '
      FLG_CLOS             = ' '
      MAXNUMBER            = '999'
      INIT_TABLES          = 'X'
      EXPORT_MSG_TO_MEMORY = ' '
    TABLES
      TABLE_OF_MESSAGES    = MESSAGE_TABLE
      CAUFV_TAB            = CAUFVTAB
    EXCEPTIONS
      NOTHING_TO_DO        = 0
      WRONG_SELID          = 0
      OTHERS               = 0.

  READ TABLE MESSAGE_TABLE WITH KEY MSGNR = '889'  .
  IF SY-SUBRC = 0.
*******    MESSAGE I000(OK) WITH MESSAGE_TABLE-MSGV1.
    MESSAGE MESSAGE_TABLE-MSGV1 TYPE 'I'.
  ELSE.
*******    MESSAGE I001(00) WITH 'TECO Combined Failed'. "#EC NOTEXT
    MESSAGE 'TECO Combined Failed' TYPE 'I'.                "#EC NOTEXT
    EXIT.
  ENDIF.

  CLEAR CAUFVTAB.
  REFRESH CAUFVTAB.

  SELECT * INTO TABLE CAUFVTAB FROM CAUFV FOR ALL ENTRIES IN IT_TECO WHERE AUFNR = IT_TECO-ZMILL.

  CALL FUNCTION 'ORDER_CHANGE_FOR_ACTIVITY'
    EXPORTING
      TESTRUN              = ' '
      FLG_TERM             = ' '
      FLG_COST             = ' '
      FLG_TECL             = 'X'
      FLG_CAPA             = ' '
      FLG_LVS              = ' '
      FLG_CLOS             = ' '
      MAXNUMBER            = '999'
      INIT_TABLES          = 'X'
      EXPORT_MSG_TO_MEMORY = ' '
    TABLES
      TABLE_OF_MESSAGES    = MESSAGE_TABLE
      CAUFV_TAB            = CAUFVTAB
    EXCEPTIONS
      NOTHING_TO_DO        = 0
      WRONG_SELID          = 0
      OTHERS               = 0.

  READ TABLE MESSAGE_TABLE WITH KEY MSGNR = '889'  .
  IF SY-SUBRC = 0.
*******    MESSAGE I000(OK) WITH MESSAGE_TABLE-MSGV1.
    MESSAGE MESSAGE_TABLE-MSGV1 TYPE 'I'.
  ELSE.
*******    MESSAGE I001(00) WITH 'TECO Original Failed'. "#EC NOTEXT
    MESSAGE 'TECO Original Failed' TYPE 'I'.                "#EC NOTEXT
    EXIT.
  ENDIF.

ENDFORM.                    " teco_order

*&---------------------------------------------------------------------*
*&      Form  read_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_REFRESH .
  DATA: BEGIN OF IT_AUART OCCURS 10,
          AUFNR LIKE AUFK-AUFNR,
          AUART LIKE AUFK-AUART,
        END OF IT_AUART.

  DATA STATUS TYPE CHAR11.

* Characteristics Display Variable
  DATA: ZTYPE TYPE  AUSP-ATWRT,
        ZSIZE TYPE  AUSP-ATWRT,
        TREAT TYPE  AUSP-ATWRT.",
*        v_dcid TYPE zdigitctlr.

  DATA: BEGIN OF IT_AUFNR OCCURS 12,
          AUFNR  LIKE  AFPO-AUFNR,
          ZMILL  LIKE  AFPO-MILL_OC_AUFNR_U,
        END OF IT_AUFNR.

  SELECT AUFNR AUART INTO TABLE IT_AUART FROM AUFK FOR ALL ENTRIES IN IT_REF WHERE AUFNR = IT_REF-AUFNR.

  SORT V_BASIC BY AUFNR.
  SORT IT_AUART BY AUFNR.

  LOOP AT IT_REF.
    READ TABLE V_BASIC INTO WA_BASIC WITH KEY AUFNR = IT_REF-AUFNR. " BINARY SEARCH.
    IF SY-SUBRC = 0.
      READ TABLE IT_AUART WITH KEY AUFNR = WA_BASIC-AUFNR BINARY SEARCH.
      IF SY-SUBRC = 0.
        IF IT_AUART-AUART(1)  =  'Z'.
          PERFORM GET_ORDER_STATUS USING WA_BASIC-AUFNR
                                 CHANGING WA_BASIC-ZSTAT.
          IF WA_BASIC-ZSTAT = 'CNF'.
            SELECT SINGLE MILL_OC_AUFNR_U INTO AFPO-MILL_OC_AUFNR_U FROM AFPO WHERE AUFNR = WA_BASIC-AUFNR.
            IF SY-SUBRC = 0.
              PERFORM GET_ORDER_STATUS USING AFPO-MILL_OC_AUFNR_U
                                     CHANGING STATUS.
              IF STATUS = 'DLV'.
                WA_BASIC-ZSTAT = STATUS.
              ENDIF.
            ENDIF.
          ENDIF.

        ELSEIF IT_AUART-AUART(1)  =  'Y'.
          PERFORM GET_ORDER_STATUS USING WA_BASIC-AUFNR
                                   CHANGING WA_BASIC-ZSTAT.

        ENDIF.
      ENDIF.
      MODIFY V_BASIC FROM WA_BASIC TRANSPORTING ZSTAT WHERE AUFNR = WA_BASIC-AUFNR.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " read_refresh

*&---------------------------------------------------------------------*
*&      Form  boxer_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BOXER_HEADER .
  DATA: BEGIN OF IT_POS OCCURS 40,
          POS  TYPE N LENGTH 2,"LIKE  zdigitctl-positionss,
        END OF IT_POS.

  DATA: IDX  LIKE  SY-TABIX,
        WA_POS LIKE LINE OF ITAB_POS.
  FIELD-SYMBOLS: <FS_POS> LIKE LINE OF ITAB_POS.

*Tambahan Combine Order Type 28 January 2013
  CLEAR: V_AUART.
  SELECT SINGLE AUART
    INTO V_AUART
    FROM AUFK
   WHERE AUFNR = COM_ORDER.
*End Tambahan Combine Order Type 28 January 2013

*Get Resource Indicator
  CLEAR: V_ABLAD.
  SELECT SINGLE ABLAD
    INTO V_ABLAD
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND ABLAD IN ('SS','MS').

* Get position in batch
  CLEAR: ITAB_POS.
  REFRESH: ITAB_POS.
  LOOP AT ZBOXER.
    CHECK ZBOXER-AUFNR NE '' AND ZBOXER-AUFNR NE SPACE.
    CLEAR: WA_POS, V_LICHA, V_CHARG, V_AUFNR, MCH1.
    WA_POS-AUFNR = ZBOXER-AUFNR.
    WA_POS-MATNR = ZBOXER-MATNR.
    WA_POS-WERKS = ZBOXER-WERKS.
    SELECT LICHA CHARG "*
      INTO (MCH1-LICHA,MCH1-CHARG)
      FROM MCH1
     WHERE MATNR = ZBOXER-MATNR AND LICHA = ZBOXER-AUFNR.
*      %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z03")'.
      WA_POS-LICHA = MCH1-LICHA.
      WA_POS-CHARG = MCH1-CHARG.
      CLEAR: MCH1.
      APPEND WA_POS TO ITAB_POS.
    ENDSELECT.
  ENDLOOP.
  CLEAR: RIBUAN, PULUHAN.
**  PERFORM GET_DEC_NOTATION USING SY-UNAME CHANGING RIBUAN PULUHAN.
  PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.
  LOOP AT ITAB_POS ASSIGNING <FS_POS>.
    CLEAR: V_MATNR, V_CHARG, V_WERKS, V_POSMS, V_POSSS, V_GRADE, V_TYPE, V_THICKNESS, V_WIDTH, V_LENGTH,
           V_IN, V_OUT, V_TREATMENT, V_DERMS, V_DERSS, V_EXTRA, V_EXTRA2, V_CONV, V_EXTRALASL, V_CODE, V_CORE, V_CORETYPE.
    V_MATNR = <FS_POS>-MATNR.
    V_CHARG = <FS_POS>-CHARG.
    V_WERKS = <FS_POS>-WERKS.
    PERFORM GET_POSITION USING V_MATNR V_CHARG V_WERKS
                         CHANGING V_POSMS V_POSSS V_GRADE V_TYPE V_THICKNESS V_WIDTH V_LENGTH V_IN V_OUT
                                  V_TREATMENT V_DERMS V_DERSS V_EXTRA V_EXTRA2 V_CONV V_EXTRALASL V_CODE V_CORE V_CORETYPE.
    <FS_POS>-POSMS = V_POSMS.
    <FS_POS>-POSSS = V_POSSS.
    <FS_POS>-GRADE = V_GRADE.
    <FS_POS>-TYPE  = V_TYPE.
    <FS_POS>-CODE  = V_CODE.
    <FS_POS>-ZZCORETYPE  = V_CORETYPE. "Additional 17.10.2023 (Dila)
    <FS_POS>-THICK = V_THICKNESS.
    CLEAR: V_WIDTH, V_LENGTH.
    SELECT SINGLE ZWIDTH ZLENGTH
      INTO (V_WIDTH, V_LENGTH)
      FROM AUFK
     WHERE AUFNR = <FS_POS>-AUFNR.
    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_WIDTH
        IMPORTING
          OUTPUT = <FS_POS>-WIDTH.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_LENGTH
        IMPORTING
          OUTPUT = <FS_POS>-LENG.
    ENDIF.
    <FS_POS>-IN    = V_IN.
    <FS_POS>-OUT   = V_OUT.
    <FS_POS>-TREAT = V_TREATMENT.
    <FS_POS>-DERMS = V_DERMS.
    <FS_POS>-DERSS = V_DERSS.
    <FS_POS>-EXTRA = V_EXTRA.
    <FS_POS>-CONV  = V_CONV.
    <FS_POS>-ZZEXTRALENGTHASAL  = V_EXTRALASL.
    <FS_POS>-CORE  = V_CORE. " Additional ZZCORE 7 January 2013
  ENDLOOP.

* Draw for SO Default Layout in ITAB.
  CLEAR IDX.
  CLEAR IT_DEFAULT.
  REFRESH IT_DEFAULT.
  CLEAR IT_REWIND.
  REFRESH IT_REWIND.
  LOOP AT ZBOXER.
    ADD 1 TO IDX.

    IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
      IF IDX = 1.
        IT_DEFAULT-ZSTAT  =  'DEFAULT SO'.
      ELSE.
        READ TABLE IT_DEFAULT INTO V WITH KEY ZSTAT = 'DEFAULT SO'.
        IF SY-SUBRC <> 0.
          IT_DEFAULT-ZSTAT  =  'DEFAULT SO'.
        ENDIF.
      ENDIF.

      CONCATENATE ZBOXER-VBELN1 ZBOXER-POSNR1 INTO IT_DEFAULT-SONUM.
      SELECT SINGLE KUNNR INTO VBAK-KUNNR FROM VBAK WHERE VBELN = ZBOXER-VBELN1.
      IF SY-SUBRC = 0.
        SELECT SINGLE NAME1 INTO IT_DEFAULT-NAME1 FROM KNA1 WHERE KUNNR = VBAK-KUNNR.
      ENDIF.

      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN1 ZBOXER-POSNR1
                             CHANGING IT_DEFAULT-MENGE.

*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_DEFAULT-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_DEFAULT-ZPOST ITAB_POS-POSMS INTO IT_DEFAULT-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_DEFAULT-ZPOST ',' INTO IT_DEFAULT-ZPOST.
          ENDLOOP.
        ENDIF.
*      ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
      ELSEIF V_ABLAD = 'SS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_DEFAULT-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_DEFAULT-ZPOST ITAB_POS-POSSS INTO IT_DEFAULT-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_DEFAULT-ZPOST ',' INTO IT_DEFAULT-ZPOST.
          ENDLOOP.
        ENDIF.
      ENDIF.

      APPEND IT_DEFAULT.
      CLEAR IT_DEFAULT.
    ELSE.
      IF IDX = 1.
*        IT_REWIND-ZSTAT  =  'Rw/Rs (R0)'.
*        IT_REWIND-GRADE  =  'Grade R0 - Input'.
        IT_REWIND-ZSTAT  =  'Rw/Rs (RO)'.                   "#EC NOTEXT
        IT_REWIND-GRADE  =  'Grade RO - Input'.             "#EC NOTEXT
      ELSE.
        READ TABLE IT_REWIND INTO R WITH KEY ZSTAT = 'RWRS'.
        IF SY-SUBRC <> 0.
*          IT_REWIND-ZSTAT  =  'Rw/Rs (R0)'.
*          IT_REWIND-GRADE  =  'Grade R0 - Input'.
          IT_REWIND-ZSTAT  =  'Rw/Rs (RO)'.                 "#EC NOTEXT
          IT_REWIND-GRADE  =  'Grade RO - Input'.           "#EC NOTEXT
        ENDIF.
      ENDIF.
*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_REWIND-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_REWIND-ZPOST ITAB_POS-POSMS INTO IT_REWIND-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_REWIND-ZPOST ',' INTO IT_REWIND-ZPOST.
          ENDLOOP.
        ENDIF.
*      ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
      ELSEIF V_ABLAD = 'SS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_REWIND-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_REWIND-ZPOST ITAB_POS-POSSS INTO IT_REWIND-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_REWIND-ZPOST ',' INTO IT_REWIND-ZPOST.
          ENDLOOP.
        ENDIF.
      ENDIF.

      APPEND IT_REWIND.
      CLEAR IT_REWIND.
    ENDIF.

  ENDLOOP.

  SORT ZBOXER BY VBELN2 POSNR2.
* Draw for SO Option 1 Layout in ITAB.
*  clear idx.
  CLEAR IT_OPTION1.
  REFRESH IT_OPTION1.
  LOOP AT ZBOXER.
    ADD 1 TO IDX.

    IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
      IF IDX = 1.
        IT_OPTION1-ZSTAT  =  'Option #1'.                   "#EC NOTEXT
      ELSE.
        READ TABLE IT_OPTION1 INTO X WITH KEY ZSTAT = 'Option #1'. "#EC NOTEXT
        IF SY-SUBRC <> 0.
          IT_OPTION1-ZSTAT  =  'Option #1'.                 "#EC NOTEXT
        ENDIF.
      ENDIF.

      CONCATENATE ZBOXER-VBELN2 ZBOXER-POSNR2 INTO IT_OPTION1-SONUM.
      SELECT SINGLE KUNNR INTO VBAK-KUNNR FROM VBAK WHERE VBELN = ZBOXER-VBELN2.
      IF SY-SUBRC = 0.
        SELECT SINGLE NAME1 INTO IT_OPTION1-NAME1 FROM KNA1 WHERE KUNNR = VBAK-KUNNR.
      ENDIF.

      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN2 ZBOXER-POSNR2
                             CHANGING IT_OPTION1-MENGE.

*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_OPTION1-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_OPTION1-ZPOST ITAB_POS-POSMS INTO IT_OPTION1-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_OPTION1-ZPOST ',' INTO IT_OPTION1-ZPOST.
          ENDLOOP.
        ENDIF.
*      ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
      ELSEIF V_ABLAD = 'SS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_OPTION1-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_OPTION1-ZPOST ITAB_POS-POSSS INTO IT_OPTION1-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_OPTION1-ZPOST ',' INTO IT_OPTION1-ZPOST.
          ENDLOOP.
        ENDIF.
      ENDIF.

      APPEND IT_OPTION1.
      CLEAR IT_OPTION1.
    ENDIF.
  ENDLOOP.

  SORT ZBOXER BY VBELN3 POSNR3.
* Draw for SO Option 2 Layout in ITAB.
*  clear idx.
  CLEAR IT_OPTION2.
  REFRESH IT_OPTION2.
  LOOP AT ZBOXER.
    ADD 1 TO IDX.

    IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
      IF IDX = 1.
        IT_OPTION2-ZSTAT  =  'Option #2'.                   "#EC NOTEXT
      ELSE.
        READ TABLE IT_OPTION2 INTO Y WITH KEY ZSTAT = 'Option #2'. "#EC NOTEXT
        IF SY-SUBRC <> 0.
          IT_OPTION2-ZSTAT  =  'Option #2'.                 "#EC NOTEXT
        ENDIF.
      ENDIF.

      CONCATENATE ZBOXER-VBELN3 ZBOXER-POSNR3 INTO IT_OPTION2-SONUM.
      SELECT SINGLE KUNNR INTO VBAK-KUNNR FROM VBAK WHERE VBELN = ZBOXER-VBELN3.
      IF SY-SUBRC = 0.
        SELECT SINGLE NAME1 INTO IT_OPTION2-NAME1 FROM KNA1 WHERE KUNNR = VBAK-KUNNR.
      ENDIF.

      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN3 ZBOXER-POSNR3
                             CHANGING IT_OPTION2-MENGE.

*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_OPTION2-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_OPTION2-ZPOST ITAB_POS-POSMS INTO IT_OPTION2-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_OPTION2-ZPOST ',' INTO IT_OPTION2-ZPOST.
          ENDLOOP.
        ENDIF.
*      ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
      ELSEIF V_ABLAD = 'SS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_OPTION2-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_OPTION2-ZPOST ITAB_POS-POSSS INTO IT_OPTION2-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_OPTION2-ZPOST ',' INTO IT_OPTION2-ZPOST.
          ENDLOOP.
        ENDIF.
      ENDIF.

      APPEND IT_OPTION2.
      CLEAR IT_OPTION2.
    ENDIF.
  ENDLOOP.

  SORT ZBOXER BY VBELN4 POSNR4.
* Draw for SO Second Layout in ITAB.
*  clear idx.
  CLEAR IT_SECOND.
  REFRESH IT_SECOND.
  LOOP AT ZBOXER.
    ADD 1 TO IDX.

    IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
      IF IDX = 1.
        IT_SECOND-ZSTAT  =  'Second'.                       "#EC NOTEXT
      ELSE.
        READ TABLE IT_SECOND INTO Z WITH KEY ZSTAT = 'Second'. "#EC NOTEXT
        IF SY-SUBRC <> 0.
          IT_SECOND-ZSTAT  =  'Second'.                     "#EC NOTEXT
        ENDIF.
      ENDIF.

      CONCATENATE ZBOXER-VBELN4 ZBOXER-POSNR4 INTO IT_SECOND-SONUM.
      SELECT SINGLE KUNNR INTO VBAK-KUNNR FROM VBAK WHERE VBELN = ZBOXER-VBELN4.
      IF SY-SUBRC = 0.
        SELECT SINGLE NAME1 INTO IT_SECOND-NAME1 FROM KNA1 WHERE KUNNR = VBAK-KUNNR.
      ENDIF.

      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN4 ZBOXER-POSNR4
                             CHANGING IT_SECOND-MENGE.

*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_SECOND-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_SECOND-ZPOST ITAB_POS-POSMS INTO IT_SECOND-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_SECOND-ZPOST ',' INTO IT_SECOND-ZPOST.
          ENDLOOP.
        ENDIF.
*      ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
      ELSEIF V_ABLAD = 'SS'.
        READ TABLE ITAB_POS ASSIGNING <FS_POS> WITH KEY LICHA = ZBOXER-AUFNR.
        IF SY-SUBRC = 0.
          CLEAR IT_SECOND-ZPOST.
          LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.
            CONCATENATE IT_SECOND-ZPOST ITAB_POS-POSSS INTO IT_SECOND-ZPOST SEPARATED BY SPACE.
            CONCATENATE IT_SECOND-ZPOST ',' INTO IT_SECOND-ZPOST.
          ENDLOOP.
        ENDIF.
      ENDIF.

      APPEND IT_SECOND.
      CLEAR IT_SECOND.
    ENDIF.
  ENDLOOP.

  CLEAR: V_ABLAD2.
  V_ABLAD2 = V_ABLAD.

*  Draw to the screen
  WRITE:/1(15)  'Combine Order' COLOR COL_TOTAL INTENSIFIED ON, COM_ORDER COLOR COL_TOTAL INTENSIFIED ON, '-' COLOR COL_TOTAL INTENSIFIED ON, V_ABLAD2 COLOR COL_TOTAL INTENSIFIED ON. "#EC NOTEXT
*******  READ TABLE it_default INDEX 1.
*******  IF SY-SUBRC EQ 0.
*******    WRITE:/1(15)  'Combine Order' COLOR COL_TOTAL INTENSIFIED ON, com_order COLOR COL_TOTAL INTENSIFIED ON,
*******            (2)   '  ',
*******            (10)  'SO Number' COLOR COL_POSITIVE INTENSIFIED ON, it_default-sonum COLOR COL_POSITIVE INTENSIFIED ON.
*******  ELSE.
*******    READ TABLE it_rewind INDEX 1.
*******    IF SY-SUBRC EQ 0.
*******      WRITE:/1(15)  'Combine Order' COLOR COL_TOTAL INTENSIFIED ON, com_order COLOR COL_TOTAL INTENSIFIED ON,
*******              (2)   '  ',
*******              (10)  'Rw/Rs (R0)' COLOR COL_POSITIVE INTENSIFIED ON, it_rewind-grade COLOR COL_POSITIVE INTENSIFIED ON.
*******    ENDIF.
*******  ENDIF.

*******  SKIP.
* Additional
  WRITE:/1(153) SY-ULINE.
  WRITE:/1(1)  SY-VLINE, (28) 'Confirmation' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (14) 'Batch' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (20) 'Type Film' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (4)  'Sloc' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (40) 'Ket. Winder' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (12) 'Joint(M) Ke-' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE, (13) 'Scrap Inputan' CENTERED COLOR COL_HEADING INTENSIFIED ON, "#EC NOTEXT
          (1)  SY-VLINE.
  WRITE:/1(153) SY-ULINE.
  WRITE:/1(1)  SY-VLINE, (15) 'NIK' LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
          (1)  SY-VLINE, (10) IN_NIK INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (1)  '1' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
          (1)  SY-VLINE, (10) IN_CHARG1 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (20) V_TYPE1 LEFT-JUSTIFIED, " Narik Data (Type Film)
          (1)  SY-VLINE, (4)  IN_SLOC1 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (40) V_TEXT1 LEFT-JUSTIFIED, " Narik Data (Ket. Winder)
          (1)  SY-VLINE, (2)  ' ', (6) ' ' INPUT OFF CENTERED, (2) ' ',
          (1)  SY-VLINE, (5)  ' ', CHK1 AS CHECKBOX, (5) ' ',
          (1)  SY-VLINE.
*******  WRITE:/1(153) sy-uline.
  WRITE:/1(1)  SY-VLINE, (15) 'Resource' LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
          (1)  SY-VLINE, (10) IN_RES INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (1)  '2' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
          (1)  SY-VLINE, (10) IN_CHARG2 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (20) V_TYPE2 LEFT-JUSTIFIED, " Narik Data (Type Film)
          (1)  SY-VLINE, (4)  IN_SLOC2 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (40) V_TEXT2 LEFT-JUSTIFIED, " Narik Data (Ket. Winder)
          (1)  SY-VLINE, (2)  ' ', (6) IN_JOINT2 INPUT ON CENTERED, (2) ' ',
          (1)  SY-VLINE, (5)  ' ', CHK2 AS CHECKBOX, (5) ' ',
          (1)  SY-VLINE.
*******  WRITE:/1(153) sy-uline.
  WRITE:/1(1)  SY-VLINE, (15) 'Speed Machine' LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
          (1)  SY-VLINE, (10) IN_SPEED INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (1)  '3' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF,
          (1)  SY-VLINE, (10) IN_CHARG3 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (20) V_TYPE3 LEFT-JUSTIFIED, " Narik Data (Type Film)
          (1)  SY-VLINE, (4)  IN_SLOC3 INPUT ON LEFT-JUSTIFIED,
          (1)  SY-VLINE, (40) V_TEXT3 LEFT-JUSTIFIED, " Narik Data (Ket. Winder)
          (1)  SY-VLINE, (2)  ' ', (6) IN_JOINT3 INPUT ON CENTERED, (2) ' ',
          (1)  SY-VLINE, (5)  ' ', CHK3 AS CHECKBOX, (5) ' ',
          (1)  SY-VLINE.
  WRITE:/1(153) SY-ULINE.
*******  SKIP.
* End Additional

*******  WRITE:/1(10)  'Ket.' LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
*******          (16)  'SONUM' LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
*******          (35)  'Nama Customer' LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
*******          (10)  'Qty TBS' RIGHT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
*******          (77)  'Position' LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF.

*******  SKIP.
*******  CLEAR c.
*******  READ TABLE it_default INDEX 1.
*******  IF sy-subrc = 0.
*******    LOOP AT it_default.
*******      IF c NE space.
*******        WRITE:/1(10)  it_default-zstat LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF,
*******                (16)  it_default-sonum LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF,
*******                (35)  it_default-name1 LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF,
*******                (10)  it_default-menge RIGHT-JUSTIFIED COLOR COL_TOTAL INTENSIFIED OFF,
*******                (77)  it_default-zpost LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
*******        CLEAR c.
*******      ELSE.
*******        c = 'X'.
*******        WRITE:/1(10)  it_default-zstat LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED ON,
*******                (16)  it_default-sonum LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED ON,
*******                (35)  it_default-name1 LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED ON,
*******                (10)  it_default-menge RIGHT-JUSTIFIED COLOR COL_TOTAL INTENSIFIED ON,
*******                (77)  it_default-zpost LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED ON.
*******      ENDIF.
*******    ENDLOOP.
*******  ENDIF.
*******
*******  CLEAR c.
*******  READ TABLE it_rewind INDEX 1.
*******  IF sy-subrc = 0.
*******    SKIP.
*******    LOOP AT it_rewind.
*******      IF c NE space.
*******        WRITE:/1(10)  it_rewind-zstat LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
*******                (63)  it_rewind-grade LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF,
********                (62)  it_rewind-zpost LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF.
*******                (77)  it_rewind-zpost LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED OFF.
*******        c = ''.
*******      ELSE.
*******        WRITE:/1(10)  it_rewind-zstat LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED ON,
*******                (63)  it_rewind-grade LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED ON,
********                (62)  it_rewind-zpost LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED ON.
*******                (77)  it_rewind-zpost LEFT-JUSTIFIED COLOR COL_KEY INTENSIFIED ON.
*******      ENDIF.
*******    ENDLOOP.
*******  ENDIF.

*******  WRITE:/1(152)  sy-uline.
  WRITE:/1(10)    'Keterangan' CENTERED.                    "#EC NOTEXT
  WRITE:59(10)    'SO Default' CENTERED COLOR COL_HEADING INTENSIFIED OFF. "#EC NOTEXT  " 44
  WRITE:71(10)    'SO Option1' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF. "#EC NOTEXT " 56
  WRITE:83(10)    'SO Option2' CENTERED COLOR COL_TOTAL INTENSIFIED OFF. "#EC NOTEXT " 68
*******  WRITE:83(10)    'SO Option2' CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF. " 68
  WRITE:95(10)    'SO Second' CENTERED COLOR COL_NORMAL INTENSIFIED OFF. "#EC NOTEXT    " 80
******  SKIP.

ENDFORM.                    " boxer_header

*&---------------------------------------------------------------------*
*&      Form  display_boxer_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_BOXER_LAYOUT .

  DATA: SONUM  LIKE LQUA-SONUM.

  DATA: MATNR  LIKE AUSP-ATWRT,
        WIDTH  LIKE AUSP-ATWRT,
        LENGT  LIKE AUSP-ATWRT,
        ZSIZE  LIKE AUSP-ATWRT,
        TREAT  LIKE AUSP-ATWRT,
        CORE   LIKE AUSP-ATWRT, "Add ZZCORE di CTEXT 7 Januari 2013
        CTEXT  TYPE  CHAR30,
        GRADE  LIKE  AUSP-ATWRT,
        V_SONUM TYPE STRING.

  SET PF-STATUS 'SIGN'.

  CLEAR GRADE.
  SKIP.
  SORT ZBOXER BY AUFNR.
  SORT ITAB_POS BY AUFNR CHARG. " Additional 15 Okt 2012 " Komen 03.01.2013
****** Add By WIll kata yan karena ZPP001 posisi tidak urut 03.01.2013
*****  IF v_ablad = 'MS'.
*****    SORT ITAB_POS BY AUFNR CHARG POSMS.
*****  ELSEIF v_ablad = 'SS'.
*****    SORT ITAB_POS BY AUFNR CHARG POSSS.
*****  ENDIF.
****** Add By WIll kata yan karena ZPP001 posisi tidak urut03.01.2013
  LOOP AT ZBOXER.
    CLEAR: V_SONUM.
    IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
      CONCATENATE ZBOXER-VBELN1 ZBOXER-POSNR1 INTO V_SONUM.
      READ TABLE IT_DEFAULT WITH KEY SONUM = V_SONUM.
      IF SY-SUBRC = 0.
        WRITE:/1(2)  '  ',"itab_pos-posss INPUT ON,
               (12)  'Nama Cust. :' COLOR COL_HEADING INTENSIFIED OFF, "#EC NOTEXT "itab_pos-licha LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF,
               (40)  IT_DEFAULT-NAME1 COLOR COL_HEADING INTENSIFIED OFF."ctext LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
      ENDIF.
*      WRITE:44(10)   zboxer-vbeln1 CENTERED COLOR COL_HEADING INTENSIFIED OFF.
      WRITE:59(10)   ZBOXER-VBELN1 CENTERED COLOR COL_HEADING INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*      write:44(10)   'R0' centered color col_heading intensified off.
*      WRITE:44(10)   space CENTERED COLOR COL_HEADING INTENSIFIED OFF.
      WRITE:59(10)   SPACE CENTERED COLOR COL_HEADING INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
*      WRITE:56(10)   zboxer-vbeln2 CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE:71(10)   ZBOXER-VBELN2 CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN2 EQ '0000000000' OR ZBOXER-VBELN2 EQ SPACE ) AND ZBOXER-POSNR2 EQ '000000'.
*      write:56(10)   'R0' centered color col_positive intensified off.
*      WRITE:56(10)   space CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE:71(10)   SPACE CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
*      WRITE:68(10)   zboxer-vbeln3 CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE:83(10)   ZBOXER-VBELN3 CENTERED COLOR COL_TOTAL INTENSIFIED OFF.
*******      WRITE:83(10)   ZBOXER-VBELN3 CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN3 EQ '0000000000' OR ZBOXER-VBELN3 EQ SPACE ) AND ZBOXER-POSNR3 EQ '000000'.
*      WRITE:68(10)   space CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE:83(10)   SPACE CENTERED COLOR COL_TOTAL INTENSIFIED OFF.
*******      WRITE:83(10)   SPACE CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
*      write:68(10)   'R0' centered color col_negative intensified off.
    ENDIF.

    IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
*      WRITE:80(10)   zboxer-vbeln4 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
      WRITE:95(10)   ZBOXER-VBELN4 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
*            92(10)   'Base Film' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
            107(10)  'Base Film' CENTERED COLOR COL_GROUP INTENSIFIED ON, "#EC NOTEXT
*******            107(10)  'Base Film' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
*            104(10)  'Free Stock' CENTERED COLOR COL_KEY INTENSIFIED OFF,
            119(10)  'Free Stock' CENTERED COLOR COL_KEY INTENSIFIED OFF, "#EC NOTEXT
*            116(10)  'RW/RS' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
            131(10)  'RW/RS' CENTERED COLOR COL_POSITIVE INTENSIFIED ON, "#EC NOTEXT
*            128(10)  'Scrap' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
            143(10)  'Scrap' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON. "#EC NOTEXT
*******            143(10)  'Scrap' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN4 EQ '0000000000' OR ZBOXER-VBELN4 EQ SPACE ) AND ZBOXER-POSNR4 EQ '000000'.
*      WRITE:80(10)   'No Second' CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
      WRITE:95(10)   'No Second' CENTERED COLOR COL_NORMAL INTENSIFIED OFF, "#EC NOTEXT
*            92(10)   'Base Film' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
            107(10)  'Base Film' CENTERED COLOR COL_GROUP INTENSIFIED ON, "#EC NOTEXT
*******            107(10)  'Base Film' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
*            104(10)  'Free Stock' CENTERED COLOR COL_KEY INTENSIFIED OFF,
            119(10)  'Free Stock' CENTERED COLOR COL_KEY INTENSIFIED OFF, "#EC NOTEXT
*            116(10)  'RW/RS' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
            131(10)  'RW/RS' CENTERED COLOR COL_POSITIVE INTENSIFIED ON, "#EC NOTEXT
*            128(10)  'Scrap' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
            143(10)  'Scrap' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON. "#EC NOTEXT
*******            143(10)  'Scrap' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
*      WRITE:/44(10)   zboxer-posnr1 LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
      WRITE:/59(10)   ZBOXER-POSNR1 LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*      WRITE:/44(10)   ' ' CENTERED COLOR COL_HEADING INTENSIFIED OFF.
      WRITE:/59(10)   ' ' CENTERED COLOR COL_HEADING INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
*      WRITE:56(10)   zboxer-posnr2 LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE:71(10)   ZBOXER-POSNR2 LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN2 EQ '0000000000' OR ZBOXER-VBELN2 EQ SPACE ) AND ZBOXER-POSNR2 EQ '000000'.
*      WRITE:56(10)   ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE:71(10)   ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
*      WRITE:68(10)   zboxer-posnr3 LEFT-JUSTIFIED COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE:83(10)   ZBOXER-POSNR3 LEFT-JUSTIFIED COLOR COL_TOTAL INTENSIFIED OFF.
*******      WRITE:83(10)   ZBOXER-POSNR3 LEFT-JUSTIFIED COLOR COL_NEGATIVE INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN3 EQ '0000000000' OR ZBOXER-VBELN3 EQ SPACE ) AND ZBOXER-POSNR3 EQ '000000'.
*      WRITE:68(10)   ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE:83(10)   ' ' CENTERED COLOR COL_TOTAL INTENSIFIED OFF.
*******      WRITE:83(10)   ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
*      WRITE:80(10)   zboxer-posnr4 LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF,
      WRITE:95(10)   ZBOXER-POSNR4 LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF,
*            92(10)   ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
            107(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED ON,
*******            107(10)  ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
*            104(10)  ' ' CENTERED COLOR COL_KEY INTENSIFIED OFF,
            119(10)  ' ' CENTERED COLOR COL_KEY INTENSIFIED OFF,
*            116(10)  ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
            131(10)  ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
*            128(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
            143(10)  ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON.
*******            143(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
    ELSEIF ( ZBOXER-VBELN4 EQ '0000000000' OR ZBOXER-VBELN4 EQ SPACE ) AND ZBOXER-POSNR4 EQ '000000'.
*      WRITE:80(10)   ' ' CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
      WRITE:95(10)   ' ' CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
*            92(10)   ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
            107(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED ON,
*******            107(10)  ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON,
*            104(10)  ' ' CENTERED COLOR COL_KEY INTENSIFIED OFF,
            119(10)  ' ' CENTERED COLOR COL_KEY INTENSIFIED OFF,
*            116(10)  ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
            131(10)  ' ' CENTERED COLOR COL_POSITIVE INTENSIFIED ON,
*            128(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
            143(10)  ' ' CENTERED COLOR COL_NEGATIVE INTENSIFIED ON.
*******            143(10)  ' ' CENTERED COLOR COL_GROUP INTENSIFIED OFF.
    ENDIF.

    IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
      CLEAR SONUM.
      CONCATENATE ZBOXER-VBELN1 ZBOXER-POSNR1 INTO SONUM.
      READ TABLE IT_DEFAULT WITH KEY SONUM = SONUM.
      IF SY-SUBRC = 0.
*        WRITE:/44(10)   it_default-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        WRITE:/59(10)   IT_DEFAULT-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
*******        WRITE:/59(10)   IT_DEFAULT-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
      ENDIF.
    ENDIF.

    IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
      IF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN2 ZBOXER-POSNR2 INTO SONUM.
        READ TABLE IT_OPTION1 WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:/56(10)   it_option1-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:/71(10)   IT_OPTION1-MENGE LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF.
*******          WRITE:/71(10)   IT_OPTION1-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ELSE.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN2 ZBOXER-POSNR2 INTO SONUM.
        READ TABLE IT_OPTION1 WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:56(10)   it_option1-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:71(10)   IT_OPTION1-MENGE LEFT-JUSTIFIED COLOR COL_POSITIVE INTENSIFIED OFF.
*******          WRITE:71(10)   IT_OPTION1-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
      IF ( ZBOXER-VBELN2 EQ '0000000000' OR ZBOXER-VBELN2 EQ SPACE ) AND ZBOXER-POSNR2 EQ '000000'.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN3 ZBOXER-POSNR3 INTO SONUM.
        READ TABLE IT_OPTION2 WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:/68(10)   it_option2-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:/83(10)   IT_OPTION2-MENGE LEFT-JUSTIFIED COLOR COL_TOTAL INTENSIFIED OFF.
*******          WRITE:/83(10)   IT_OPTION2-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ELSE.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN3 ZBOXER-POSNR3 INTO SONUM.
        READ TABLE IT_OPTION2 WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:68(10)   it_option2-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:83(10)   IT_OPTION2-MENGE LEFT-JUSTIFIED COLOR COL_TOTAL INTENSIFIED OFF.
*******          WRITE:83(10)   IT_OPTION2-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
      IF ( ZBOXER-VBELN3 EQ '0000000000' OR ZBOXER-VBELN3 EQ SPACE ) AND ZBOXER-POSNR3 EQ '000000'.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN4 ZBOXER-POSNR4 INTO SONUM.
        READ TABLE IT_SECOND WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:/80(10)   it_second-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:/95(10)   IT_SECOND-MENGE LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
*******          WRITE:/95(10)   IT_SECOND-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ELSE.
        CLEAR SONUM.
        CONCATENATE ZBOXER-VBELN4 ZBOXER-POSNR4 INTO SONUM.
        READ TABLE IT_SECOND WITH KEY SONUM = SONUM.
        IF SY-SUBRC = 0.
*          WRITE:80(10)   it_second-menge LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
          WRITE:95(10)   IT_SECOND-MENGE LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
*******          WRITE:95(10)   IT_SECOND-MENGE LEFT-JUSTIFIED COLOR COL_HEADING INTENSIFIED OFF.
        ENDIF.
      ENDIF.
    ENDIF.

    SKIP.

    LOOP AT ITAB_POS.
      CHECK ITAB_POS-LICHA = ZBOXER-AUFNR.

      DATA OFF TYPE I.
      CLEAR: OFF, MATNR.
      FIND '.' IN ITAB_POS-THICK MATCH OFFSET OFF.
      IF SY-SUBRC EQ 0.
        MATNR = ITAB_POS-THICK(OFF).
      ELSE.
        MATNR = ITAB_POS-THICK.
      ENDIF.
      CONDENSE MATNR NO-GAPS.
      CONCATENATE ITAB_POS-TYPE '-' MATNR INTO MATNR.
      CONDENSE MATNR NO-GAPS.

      CLEAR: OFF, WIDTH, LENGT, ZSIZE.
      FIND '.' IN ITAB_POS-WIDTH MATCH OFFSET OFF.
      IF SY-SUBRC EQ 0.
        WIDTH = ITAB_POS-WIDTH(OFF).
      ELSE.
        WIDTH = ITAB_POS-WIDTH.
      ENDIF.
      CONDENSE WIDTH NO-GAPS.
      CLEAR OFF.
      FIND '.' IN ITAB_POS-LENG MATCH OFFSET OFF.
      IF SY-SUBRC EQ 0.
        LENGT = ITAB_POS-LENG(OFF).
      ELSE.
        LENGT = ITAB_POS-LENG.
      ENDIF.
      CONDENSE LENGT NO-GAPS.
      CONCATENATE WIDTH 'x' LENGT INTO ZSIZE.
      CONDENSE ZSIZE NO-GAPS.

      CLEAR: TREAT, CORE. " Additional 7 January 2013
      CONCATENATE ITAB_POS-IN ITAB_POS-OUT INTO TREAT.
      CORE = ITAB_POS-CORE. " Additional 7 January 2013
      CONDENSE CORE NO-GAPS. " Additional 7 January 2013
      CLEAR: CTEXT.
      CONDENSE ITAB_POS-TREAT NO-GAPS.
      CONCATENATE MATNR ZSIZE TREAT CORE INTO CTEXT SEPARATED BY SPACE. " Additional 7 January 2013

*      IF ZBOXER-ARBPL(1)  =  'M'.
      IF V_ABLAD = 'MS'.
        WRITE:/1(2)  ITAB_POS-POSMS INPUT ON,
               (12)  ITAB_POS-LICHA LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF,
*               (25)  ctext LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
               (40)  CTEXT LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
        IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
*          WRITE:44(5)   itab_pos-grade INPUT ON CENTERED,
*                52      mark AS CHECKBOX.
          WRITE:59(5)   ITAB_POS-GRADE INPUT ON CENTERED,
                67      MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*          write:44(5)   'R0' input on centered,
*          WRITE:44(5)   space INPUT ON CENTERED,
*                52      mark AS CHECKBOX.
          WRITE:59(5)   SPACE INPUT ON CENTERED,
                67      MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
*          WRITE:56(5) itab_pos-grade INPUT ON CENTERED,
*                64    mark AS CHECKBOX.
          WRITE:71(5) ITAB_POS-GRADE INPUT ON CENTERED,
                79    MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN2 EQ '0000000000' OR ZBOXER-VBELN2 EQ SPACE ) AND ZBOXER-POSNR2 EQ '000000'.
*          write:56(5) ctl-grade input on centered,
*          WRITE:56(5) space INPUT ON CENTERED,
*                64    mark AS CHECKBOX.
          WRITE:71(5) SPACE INPUT ON CENTERED,
                79    MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
*          WRITE:68(5) itab_pos-grade INPUT ON CENTERED,
*                76    mark AS CHECKBOX.
          WRITE:83(5) ITAB_POS-GRADE INPUT ON CENTERED,
                91    MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN3 EQ '0000000000' OR ZBOXER-VBELN3 EQ SPACE ) AND ZBOXER-POSNR3 EQ '000000'.
*          write:68(5) ctl-grade input on centered,
*          WRITE:68(5) space INPUT ON CENTERED,
*                76    mark AS CHECKBOX.
          WRITE:83(5) SPACE INPUT ON CENTERED,
                91    MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
*          WRITE:80(5) itab_pos-grade INPUT ON CENTERED,
*                88    mark AS CHECKBOX,
*                92(5) grade INPUT ON,
*                100   mark AS CHECKBOX,
*                104(5) grade INPUT ON,
*                112    mark AS CHECKBOX,
*                116(5) grade INPUT ON,
*                124   mark AS CHECKBOX,
*                128(5) grade INPUT ON,
*                136   mark AS CHECKBOX.
          WRITE:95(5) ITAB_POS-GRADE INPUT ON CENTERED,
              103   MARK AS CHECKBOX,
              107(5) GRADE INPUT ON,
              115   MARK AS CHECKBOX,
              119(5) GRADE INPUT ON,
              127    MARK AS CHECKBOX,
              131(5) GRADE INPUT ON,
              139   MARK AS CHECKBOX,
              143(5) GRADE INPUT ON,
              151   MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN4 EQ '0000000000' OR ZBOXER-VBELN4 EQ SPACE ) AND ZBOXER-POSNR4 EQ '000000'.
          IF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*            WRITE:80(5) space INPUT ON CENTERED,
*                  88    mark AS CHECKBOX,
*                  92(5) grade INPUT ON CENTERED,
*                  100   mark AS CHECKBOX,
*                  104(5) grade INPUT ON,"' R0' INPUT ON,
*                  112    mark AS CHECKBOX,
*                  116(5) ' R0' INPUT ON,grade INPUT ON,
*                  124   mark AS CHECKBOX,
*                  128(5) grade INPUT ON,
*                  136   mark AS CHECKBOX.
            WRITE:95(5) SPACE INPUT ON CENTERED,
                  103    MARK AS CHECKBOX,
                  107(5) GRADE INPUT ON CENTERED,
                  115   MARK AS CHECKBOX,
                  119(5) GRADE INPUT ON,"' R0' INPUT ON,
                  127    MARK AS CHECKBOX,
*                  131(5) ' R0' INPUT ON,"grade INPUT ON,
*******                  131(5) ' RO' INPUT ON,"grade INPUT ON,
                  131(5) '   ' INPUT ON,"grade INPUT ON,
                  139   MARK AS CHECKBOX,
                  143(5) GRADE INPUT ON,
                  151   MARK AS CHECKBOX.
          ELSE.
*            WRITE:80(5) space INPUT ON CENTERED,
*                  88    mark AS CHECKBOX,
*                  92(5) grade INPUT ON,
*                  100   mark AS CHECKBOX,
*                  104(5) grade INPUT ON,
*                  112    mark AS CHECKBOX,
*                  116(5) grade INPUT ON,
*                  124   mark AS CHECKBOX,
*                  128(5) grade INPUT ON,
*                  136   mark AS CHECKBOX.
            WRITE:95(5) SPACE INPUT ON CENTERED,
                  103    MARK AS CHECKBOX,
                  107(5) GRADE INPUT ON,
                  115   MARK AS CHECKBOX,
                  119(5) GRADE INPUT ON,
                  127    MARK AS CHECKBOX,
                  131(5) GRADE INPUT ON,
                  139   MARK AS CHECKBOX,
                  143(5) GRADE INPUT ON,
                  151   MARK AS CHECKBOX.
          ENDIF.
        ENDIF.
      ELSE.
        WRITE:/1(2)  ITAB_POS-POSSS INPUT ON,
               (12)  ITAB_POS-LICHA LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF,
*               (25)  ctext LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
               (40)  CTEXT LEFT-JUSTIFIED COLOR COL_NORMAL INTENSIFIED OFF.
        IF ( ZBOXER-VBELN1 NE '0000000000' OR ZBOXER-VBELN1 NE SPACE ) AND ZBOXER-POSNR1 NE '000000'.
*          WRITE:44(5)   itab_pos-grade INPUT ON CENTERED,
*                52      mark AS CHECKBOX.
          WRITE:59(5)   ITAB_POS-GRADE INPUT ON CENTERED,
                67      MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*          WRITE:44(5)   itab_pos-grade INPUT ON CENTERED,
*                52      mark AS CHECKBOX.
          WRITE:59(5)   ITAB_POS-GRADE INPUT ON CENTERED,
                67      MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN2 NE '0000000000' OR ZBOXER-VBELN2 NE SPACE ) AND ZBOXER-POSNR2 NE '000000'.
*          WRITE:56(5) itab_pos-grade INPUT ON CENTERED,
*                64    mark AS CHECKBOX.
          WRITE:71(5) ITAB_POS-GRADE INPUT ON CENTERED,
                79    MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN2 EQ '0000000000' OR ZBOXER-VBELN2 EQ SPACE ) AND ZBOXER-POSNR2 EQ '000000'.
*          WRITE:56(5) itab_pos-grade INPUT ON CENTERED,
*                64    mark AS CHECKBOX.
          WRITE:71(5) ITAB_POS-GRADE INPUT ON CENTERED,
                79    MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN3 NE '0000000000' OR ZBOXER-VBELN3 NE SPACE ) AND ZBOXER-POSNR3 NE '000000'.
*          WRITE:68(5) itab_pos-grade INPUT ON CENTERED,
*                76    mark AS CHECKBOX.
          WRITE:83(5) ITAB_POS-GRADE INPUT ON CENTERED,
                91    MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN3 EQ '0000000000' OR ZBOXER-VBELN3 EQ SPACE ) AND ZBOXER-POSNR3 EQ '000000'.
*          WRITE:68(5) itab_pos-grade INPUT ON CENTERED,
*                76    mark AS CHECKBOX.
          WRITE:83(5) ITAB_POS-GRADE INPUT ON CENTERED,
                91    MARK AS CHECKBOX.
        ENDIF.
        IF ( ZBOXER-VBELN4 NE '0000000000' OR ZBOXER-VBELN4 NE SPACE ) AND ZBOXER-POSNR4 NE '000000'.
*          WRITE:80(5) itab_pos-grade INPUT ON CENTERED,
*                88    mark AS CHECKBOX,
*                92(5) grade INPUT ON,
*                100   mark AS CHECKBOX,
*                104(5) grade INPUT ON,
*                112    mark AS CHECKBOX,
*                116(5) grade INPUT ON,
*                124   mark AS CHECKBOX,
*                128(5) grade INPUT ON,
*                136   mark AS CHECKBOX.
          WRITE:95(5) ITAB_POS-GRADE INPUT ON CENTERED,
                103   MARK AS CHECKBOX,
                107(5) GRADE INPUT ON,
                115   MARK AS CHECKBOX,
                119(5) GRADE INPUT ON,
                127    MARK AS CHECKBOX,
                131(5) GRADE INPUT ON,
                139   MARK AS CHECKBOX,
                143(5) GRADE INPUT ON,
                151   MARK AS CHECKBOX.
        ELSEIF ( ZBOXER-VBELN4 EQ '0000000000' OR ZBOXER-VBELN4 EQ SPACE ) AND ZBOXER-POSNR4 EQ '000000'.
          IF ( ZBOXER-VBELN1 EQ '0000000000' OR ZBOXER-VBELN1 EQ SPACE ) AND ZBOXER-POSNR1 EQ '000000'.
*            WRITE:80(5) space INPUT ON CENTERED,
*                  88    mark AS CHECKBOX,
*                  92(5) grade INPUT ON,
*                  100   mark AS CHECKBOX,
*                  104(5) grade INPUT ON,"' R0' INPUT ON,
*                  112    mark AS CHECKBOX,
*                  116(5) ' R0' INPUT ON,"grade INPUT ON,
*                  124   mark AS CHECKBOX,
*                  128(5) grade INPUT ON,
*                  136   mark AS CHECKBOX.
            WRITE:95(5) SPACE INPUT ON CENTERED,
                  103    MARK AS CHECKBOX,
                  107(5) GRADE INPUT ON CENTERED,
                  115   MARK AS CHECKBOX,
                  119(5) GRADE INPUT ON,"' R0' INPUT ON,
                  127    MARK AS CHECKBOX,
*                  131(5) ' R0' INPUT ON,"grade INPUT ON,
*******                  131(5) ' RO' INPUT ON,"grade INPUT ON,
                  131(5) '   ' INPUT ON,"grade INPUT ON,
                  139   MARK AS CHECKBOX,
                  143(5) GRADE INPUT ON,
                  151   MARK AS CHECKBOX.
          ELSE.
*            WRITE:80(5) space INPUT ON CENTERED,
*                  88    mark AS CHECKBOX,
*                  92(5) grade INPUT ON,
*                  100   mark AS CHECKBOX,
*                  104(5) grade INPUT ON,
*                  112    mark AS CHECKBOX,
*                  116(5) grade INPUT ON,
*                  124   mark AS CHECKBOX,
*                  128(5) grade INPUT ON,
*                  136   mark AS CHECKBOX.
            WRITE:95(5) SPACE INPUT ON CENTERED,
                  103    MARK AS CHECKBOX,
                  107(5) GRADE INPUT ON,
                  115   MARK AS CHECKBOX,
                  119(5) GRADE INPUT ON,
                  127    MARK AS CHECKBOX,
                  131(5) GRADE INPUT ON,
                  139   MARK AS CHECKBOX,
                  143(5) GRADE INPUT ON,
                  151   MARK AS CHECKBOX.
          ENDIF.
        ENDIF.
      ENDIF.
      SKIP.
    ENDLOOP.
    SKIP.
*******    SKIP.
  ENDLOOP.

ENDFORM.                    " display_boxer_layout
*&---------------------------------------------------------------------*
*&      Form  GET_POSITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_POSITION USING V_MATNR V_CHARG V_WERKS
                  CHANGING V_POSMS V_POSSS V_GRADE V_TYPE V_THICKNESS V_WIDTH V_LENGTH V_IN V_OUT
                           V_TREATMENT V_DERMS V_DERSS V_EXTRA V_EXTRA2 V_CONV V_EXTRALASL V_CODE V_CORE V_CORETYPE.

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH, V_POSMS, V_POSSS, V_GRADE, V_ATZHL, V_EXTRALASL, V_CODE, V_CORE, V_CORETYPE,
         V_TYPE, V_THICKNESS, V_WIDTH, V_LENGTH, V_IN, V_OUT, V_TREATMENT, V_DERMS, V_DERSS, V_EXTRA, V_EXTRA2, V_CONV.
  REFRESH: CHAR_OF_BATCH.

  PERFORM VB_INIT.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = V_MATNR "<fs_pos>-matnr
      CHARG                    = V_CHARG "<fs_pos>-charg
      WERKS                    = V_WERKS "<fs_pos>-werks
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
            .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPOSITIONMS'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_POSMS = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

*  CLEAR: <fs_char_of_batch>.
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPOSITIONSS'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_POSSS = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

*  Additional 18 October 2023
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCORETYPE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_CORETYPE = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

*  CLEAR: <fs_char_of_batch>.
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZGRADE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_GRADE = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZGRADE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_GRADE.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_GRADE.
    SELECT SINGLE ATWRT INTO V_GRADE
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.

*******  READ TABLE CHAR_OF_BATCH ASSIGNING <fs_char_of_batch> WITH KEY ATNAM = 'ZZTYPE'." BINARY SEARCH.
*******  IF SY-SUBRC EQ 0.
*******    V_TYPE = <fs_char_of_batch>-ATWTB.
*******  ENDIF.
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZTYPE'." BINARY SEARCH.
**  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCODE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_TYPE = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
*     INPUT  = 'ZZCODE'
      INPUT  = 'ZZTYPE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_TYPE.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_TYPE.
    SELECT SINGLE ATWRT INTO V_TYPE
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCODE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_CODE = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZCODE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_CODE.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_CODE.
    SELECT SINGLE ATWRT INTO V_CODE
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.

**Additional ZZCORE 7 January 2013
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCORE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_CORE = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZCORE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_CORE.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_CORE.
    SELECT SINGLE ATWRT INTO V_CORE
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.
**End Additional ZZCORE 7 January 2013

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZTHICKNESS'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_THICKNESS = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZINSIDE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_IN = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZINSIDE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_IN.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_IN.
    SELECT SINGLE ATWRT INTO V_IN
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZOUTSIDE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_OUT = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.
  CLEAR: V_ATINN, V_ATZHL.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZZOUTSIDE'
    IMPORTING
      OUTPUT = V_ATINN.
  SELECT SINGLE ATZHL INTO V_ATZHL
    FROM CAWNT
   WHERE ATINN = V_ATINN AND ATWTB = V_OUT.
*    %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
  IF SY-SUBRC EQ 0.
    CLEAR V_OUT.
    SELECT SINGLE ATWRT INTO V_OUT
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZTREATMENT'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_TREATMENT = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZDERIVATIVEMS'.
  IF SY-SUBRC EQ 0.
    V_DERMS = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZDERIVATIVESS'.
  IF SY-SUBRC EQ 0.
    V_DERSS = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

  IF CLASS NE 'ZZSRSHEET'.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZEXLENGTH'."'ZZEXTRALENGTH'.
    IF SY-SUBRC EQ 0.
      V_EXTRA = <FS_CHAR_OF_BATCH>-ATWTB.
******Tambahan 16 January 2013
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_EXTRA WITH SPACE.
      CONDENSE V_EXTRA NO-GAPS.
******End Tambahan 16 January 2013
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZEXTRALENGTHASAL'.
    IF SY-SUBRC EQ 0.
      V_EXTRALASL = <FS_CHAR_OF_BATCH>-ATWTB.
******Tambahan 16 January 2013
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_EXTRALASL WITH SPACE.
      CONDENSE V_EXTRALASL NO-GAPS.
******End Tambahan 16 January 2013
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_POSITION

*&---------------------------------------------------------------------*
*&      Form  get_to_be_slit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBELN  text
*      -->P_POSNR  text
*      <--P_MENGE  text
*----------------------------------------------------------------------*
FORM GET_TO_BE_SLIT  USING    P_VBELN
                              P_POSNR
                     CHANGING P_MENGE.

  DATA: BEGIN OF IT_AFPO OCCURS 0,
          PSMNG  LIKE  AFPO-PSMNG,
          WEMNG  LIKE  AFPO-WEMNG,
          AUFNR  LIKE  AFPO-AUFNR,
          KDAUF  LIKE  AFPO-KDAUF,
          KDPOS  LIKE  AFPO-KDPOS,
        END OF IT_AFPO.

  DATA : V_PSMNG TYPE AFPO-PSMNG,
         V_WEMNG TYPE AFPO-WEMNG,
         V_AUFNR TYPE AFPO-AUFNR,
         LC_WEMNG  TYPE  AFPO-WEMNG,
         COUNTER  LIKE  SY-TABIX.

  DATA: BEGIN OF IT_MSKA OCCURS 0,
          VBELN LIKE  MSKA-VBELN,
          POSNR LIKE  MSKA-POSNR,
          MATNR LIKE  MSKA-MATNR,
          CHARG LIKE  MSKA-CHARG,
          WERKS LIKE  MSKA-WERKS,
          LGORT LIKE  MSKA-LGORT,
          KALAB LIKE  MSKA-KALAB,
          KASPE LIKE  MSKA-KASPE,
        END OF IT_MSKA.

  DATA : LC_KALAB1  LIKE  MSKA-KALAB,
         LC_KALAB2  LIKE  MSKA-KALAB,
         LC_KASPE1  LIKE  MSKA-KASPE,
         LC_KASPE2  LIKE  MSKA-KASPE,
         LC_KALAB1802 LIKE MSKA-KALAB,
         LC_KASPE1802 LIKE MSKA-KASPE,
         LC_KALAB2802 LIKE MSKA-KALAB,
         LC_KASPE2802 LIKE MSKA-KASPE,
         LC_KALAB3802 LIKE MSKA-KALAB,
         LC_KASPE3802 LIKE MSKA-KASPE,
         LC_KALAB1801 LIKE MSKA-KALAB,
         LC_KASPE1801 LIKE MSKA-KASPE,
         LC_KALAB2801 LIKE MSKA-KALAB,
         LC_KASPE2801 LIKE MSKA-KASPE,
         LC_KALAB3801 LIKE MSKA-KALAB,
         LC_KASPE3801 LIKE MSKA-KASPE,
         LC_DELV601  LIKE  MSKA-KALAB,
         LC_DELV602  LIKE  MSKA-KALAB,
         LC_DELV631  LIKE  MSKA-KALAB,
         LC_DELV632  LIKE  MSKA-KALAB,
         LC_DELV633  LIKE  MSKA-KALAB,
         LC_DELV  LIKE  MSKA-KALAB,
         LC_KONV  LIKE  MSKA-KALAB,
         SONUM(16),
         NROLL  TYPE  P DECIMALS 3,
         NSHET  TYPE  P DECIMALS 3,
         NPACK  TYPE  P DECIMALS 3,
         ALIAS  LIKE  AUSP-ATWRT,
         KWMENG TYPE  P DECIMALS 3,
         NOMER  LIKE  AUSP-ATWRT.

*add by ALF.
  DATA: V_KALAB LIKE MSKA-KALAB.
  DATA: V_KASPE LIKE MSKA-KASPE.
*end of ALF
  DATA: V_MTR   LIKE VBAP-MATNR.

  CLEAR P_MENGE.
  PERFORM F_DEFINE_LGORT.

  SELECT SINGLE MATNR CUOBJ PSTYV WERKS KWMENG INTO (VBAP-MATNR, VBAP-CUOBJ, VBAP-PSTYV, VBAP-WERKS, VBAP-KWMENG)
  FROM VBAP WHERE VBELN = P_VBELN AND POSNR = P_POSNR.

  CLEAR: V_MTR.
  V_MTR = VBAP-MATNR.

  CLEAR ZORDER00.
  ZORDER00-VBELN  =  P_VBELN.
  ZORDER00-POSNR  =  P_POSNR.
  PERFORM READ_CHAR_ORDER USING ZORDER00.

  VBAP-MATNR = V_MTR.

*kwmeng  =  vbap-kwmeng.
  IF ZORDER00-CHAR14 NE SPACE.
    KWMENG  =  ZORDER00-CHAR14.
  ELSEIF ZORDER00-CHAR14 EQ SPACE AND ZORDER00-CHAR15 NE SPACE.
    KWMENG  =  ZORDER00-CHAR15.
  ELSEIF ZORDER00-CHAR14 EQ SPACE AND ZORDER00-CHAR16 NE SPACE.
    IF ZORDER00-CHAR16 NE SPACE AND ZORDER00-CHAR15 NE SPACE.
      KWMENG  =  ZORDER00-CHAR16 * ZORDER00-CHAR15.
    ENDIF.
  ENDIF.

  CLEAR IT_MSKA.
  REFRESH IT_MSKA.
  SELECT VBELN POSNR MATNR CHARG WERKS LGORT KALAB KASPE
    INTO TABLE IT_MSKA
    FROM MSKA
    WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
          LGORT NOT IN R_LGORT AND ( KALAB <> 0 OR KASPE <> 0 ).

  SORT IT_MSKA.

  CLEAR : LC_KALAB1,
          LC_KASPE1.

  CLEAR COUNTER.
  CLEAR AUSP.
  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND KALAB <> 0.
    ADD 1 TO COUNTER.
    LC_KALAB1 = LC_KALAB1 + IT_MSKA-KALAB.

    IF COUNTER = 1.
*   Get objek nr
      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                  WHERE MATNR = IT_MSKA-MATNR
                    AND CHARG = IT_MSKA-CHARG.

*   Read attin nr.
      CLEAR AUSP.
      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*   Read charateristic value
      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                  AND ATINN = CABN-ATINN
                                  AND KLART = '023'.
    ENDIF.
  ENDLOOP.

  IF AUSP-ATFLV NE SPACE.
    LC_KALAB1  =  ( LC_KALAB1 / AUSP-ATFLV ).
  ENDIF.

  CLEAR COUNTER.
  CLEAR AUSP.
  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND KASPE <> 0.
    ADD 1 TO COUNTER.
    LC_KASPE1 = LC_KASPE1 + IT_MSKA-KASPE.

    IF COUNTER = 1.
*   Get objek nr
      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                  WHERE MATNR = IT_MSKA-MATNR
                    AND CHARG = IT_MSKA-CHARG.

*   Read attin nr.
      CLEAR AUSP.
      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*   Read charateristic value
      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                  AND ATINN = CABN-ATINN
                                  AND KLART = '023'.
    ENDIF.
  ENDLOOP.

  IF AUSP-ATFLV NE SPACE.
    LC_KASPE1  =  ( LC_KASPE1 / AUSP-ATFLV ).
  ENDIF.

**  CLEAR IT_MSKA.
**  REFRESH IT_MSKA.
**  SELECT VBELN POSNR MATNR CHARG WERKS LGORT KALAB KASPE INTO TABLE IT_MSKA FROM MSKA WHERE VBELN = P_VBELN AND
**                                                                                            POSNR = P_POSNR AND
**                                                                                            MATNR = VBAP-MATNR AND
***                                                                                          ( werks = '1000' AND werks = '2000' AND werks = '3000' ) and
**                                                                                            ( LGORT = '1801' OR LGORT = '1802' OR LGORT = '1803' OR LGORT = '1804' OR LGORT = '1805' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '1806' OR LGORT = '1808' OR LGORT = '1809' OR LGORT = '1810' OR LGORT = '1811' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '1812' OR LGORT = '1813' OR LGORT = '1814' OR LGORT = '1STS' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2801' OR LGORT = '2802' OR LGORT = '2803' OR LGORT = '2804' OR LGORT = '2805' OR "LGORT = '2901' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2806' OR LGORT = '2807' OR LGORT = '2808' OR LGORT = '2809' OR LGORT = '2810' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2811' OR LGORT = '2812' OR LGORT = '2813' OR LGORT = '2814' OR LGORT = '2STS' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '3801' OR LGORT = '3802' OR LGORT = '3803' OR LGORT = '3804' OR LGORT = '3810' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '3813' OR LGORT = '3815' OR LGORT = '3STS' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '1301' OR LGORT = '1302' OR LGORT = '1303' OR LGORT = '1304' OR
**                                                                                              LGORT = '1306' OR LGORT = '1308' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2301' OR LGORT = '2302' OR LGORT = '2303' OR LGORT = '2304' OR LGORT = '2305' OR
**                                                                                              LGORT = '2306' OR LGORT = '2307' OR LGORT = '2308' OR LGORT = '2309' OR LGORT = '2310' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2311' OR LGORT = '2312' OR LGORT = '2313' OR LGORT = '2314' OR " Tambahan dari YAN YOHANA
**                                                                                              LGORT = '2315' OR LGORT = '2316' OR LGORT = '2317' OR LGORT = '2318' OR LGORT = '2319' OR LGORT = '2320' " Tambahan dari YAN YOHANA
***Add lgort = 2305 and lgort = 2306 for checking in Qty ToBe Slit
***Add lgort = 2307 and lgort = 2308 for checking in Qty ToBe Slit
**                                                                                             ) AND
***                                                                                          werks IN r_werks AND
***                                                                                          lgort IN r_lgort1302 AND
***                                                                                          lgort IN r_lgort2302 AND
***                                                                                          kalab <> 0.
**                                                                                            ( KALAB <> 0 OR KASPE <> 0 ).
**
**  SORT IT_MSKA.
**
***Slit and to be packed
***------------------------------
***Plnt : 1000
***Sloc : 1302 and 1304
**  CLEAR : LC_KALAB1,
**          LC_KASPE1.
**
**  PERFORM L_DEFINE_LGORT USING '1000'.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT IN LGORT AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1 = LC_KALAB1 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB1  =  ( LC_KALAB1 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT IN LGORT AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1 = LC_KASPE1 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE1  =  ( LC_KASPE1 / AUSP-ATFLV ).
**  ENDIF.
**
***Slit and to be packed
***------------------------------
***Plnt : 2000
***Sloc :
**  PERFORM L_DEFINE_LGORT USING '2000'.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT IN LGORT AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2 = LC_KALAB2 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2  =  ( LC_KALAB2 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT IN LGORT AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2 = LC_KASPE2 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE2  =  ( LC_KASPE2 / AUSP-ATFLV ).
**  ENDIF.
**
***Slit and to be Re-Packed
***------------------------------
***Plnt : 1000
***Sloc : 1802.
**  CLEAR :LC_KALAB1802,
**         LC_KASPE1802.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
***                        WERKS = '1000' AND LGORT = '1802' AND KALAB <> 0.
**                        WERKS = '1000' AND
**                        ( LGORT = '1802' OR LGORT = '1804' OR LGORT = '1806' OR LGORT = '1808' OR LGORT = '1810' OR
**                          LGORT = '1812' OR LGORT = '1814' OR LGORT = '1STS' ) AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1802 = LC_KALAB1802 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB1802  =  ( LC_KALAB1802 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
***                        WERKS = '1000' AND LGORT = '1802' AND KASPE <> 0.
**                        WERKS = '1000' AND
**                        ( LGORT = '1802' OR LGORT = '1804' OR LGORT = '1806' OR LGORT = '1808' OR LGORT = '1810' OR
**                          LGORT = '1812' OR LGORT = '1814' OR LGORT = '1STS' ) AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1802 = LC_KASPE1802 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE1802  =  ( LC_KASPE1802 / AUSP-ATFLV ).
**  ENDIF.
**
***Slit and to be Re-Packed
***------------------------------
***Plnt : 2000
***Sloc : 2802.
**  CLEAR :LC_KALAB2802,
**         LC_KASPE2802.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
***                        WERKS = '2000' AND LGORT = '2802' AND KALAB <> 0.
**                        WERKS = '2000' AND
**                        ( LGORT = '2802' OR LGORT = '2804' OR LGORT = '2806' OR LGORT = '2808' OR LGORT = '2810' OR
**                          LGORT = '2812' OR LGORT = '2814' OR
**                          LGORT = '2STS' OR LGORT = '3STS' OR LGORT = '3802' OR LGORT = '3804' OR LGORT = '2810') AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2802 = LC_KALAB2802 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2802  =  ( LC_KALAB2802 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
***                        WERKS = '2000' AND LGORT = '2802' AND KASPE <> 0.
**                        WERKS = '2000' AND
**                        ( LGORT = '2802' OR LGORT = '2804' OR LGORT = '2806' OR LGORT = '2808' OR LGORT = '2810' OR
**                          LGORT = '2812' OR LGORT = '2814' OR
**                          LGORT = '2STS' OR LGORT = '3STS' OR LGORT = '3802' OR LGORT = '3804' OR LGORT = '2810')  AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2802 = LC_KASPE2802 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE2802  =  ( LC_KASPE2802 / AUSP-ATFLV ).
**  ENDIF.
**
***Slit and to be Re-Packed
***------------------------------
***Plnt : 3000
***Sloc : 3802.
**  CLEAR :LC_KALAB3802,
**         LC_KASPE3802.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3802' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB3802 = LC_KALAB3802 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB3802  =  ( LC_KALAB3802 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3802' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE3802 = LC_KASPE3802 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE3802  =  ( LC_KASPE3802 / AUSP-ATFLV ).
**  ENDIF.
**
***Slit Rolls in FG Storage Location
***---------------------------------
***Plnt : 1000
***Sloc : 1801.
**  CLEAR :LC_KALAB1801,
**         LC_KASPE1801.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1801 = LC_KALAB1801 + IT_MSKA-KALAB.
**
**  ENDLOOP.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1801' AND KASPE <> 0.
**
**    ADD 1 TO COUNTER.
**    LC_KASPE1801 = LC_KASPE1801 + IT_MSKA-KASPE.
**
**  ENDLOOP.
**
***Sloc : 1803
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1803' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1801 = LC_KALAB1801 + IT_MSKA-KALAB.
**
**  ENDLOOP.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1803' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1801 = LC_KASPE1801 + IT_MSKA-KASPE.
**
**  ENDLOOP.
**
***Sloc : 1805
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1805' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1801 = LC_KALAB1801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
****     Get objek nr
***    SELECT SINGLE cuobj_bm FROM mch1 INTO mch1-cuobj_bm
***                WHERE matnr = it_mska-matnr
***                  AND charg = it_mska-charg.
***
****     Read attin nr.
***    CLEAR ausp.
***    SELECT SINGLE atinn INTO cabn-atinn FROM cabn WHERE atnam = 'ZZCONVERSIONROLLKG'.
****     Read charateristic value
***    SELECT SINGLE * FROM ausp WHERE objek = mch1-cuobj_bm
***                                AND atinn = cabn-atinn
***                                AND klart = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
***Sloc : 1809
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1809' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1801 = LC_KALAB1801 + IT_MSKA-KALAB.
**
**  ENDLOOP.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1809' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1801 = LC_KASPE1801 + IT_MSKA-KASPE.
**
**  ENDLOOP.
**
***Sloc : 1811
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1811' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB1801 = LC_KALAB1801 + IT_MSKA-KALAB.
**
**  ENDLOOP.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1811' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1801 = LC_KASPE1801 + IT_MSKA-KASPE.
**
**  ENDLOOP.
**
***Get objek nr
**  SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**              WHERE MATNR = IT_MSKA-MATNR
**                AND CHARG = IT_MSKA-CHARG.
**
***Read attin nr.
**  CLEAR AUSP.
**  SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***Read charateristic value
**  SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                              AND ATINN = CABN-ATINN
**                              AND KLART = '023'.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB1801  =  ( LC_KALAB1801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '1000' AND LGORT = '1805' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE1801 = LC_KASPE1801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
****     Get objek nr
***    SELECT SINGLE cuobj_bm FROM mch1 INTO mch1-cuobj_bm
***                WHERE matnr = it_mska-matnr
***                  AND charg = it_mska-charg.
***
****     Read attin nr.
***    CLEAR ausp.
***    SELECT SINGLE atinn INTO cabn-atinn FROM cabn WHERE atnam = 'ZZCONVERSIONROLLKG'.
****     Read charateristic value
***    SELECT SINGLE * FROM ausp WHERE objek = mch1-cuobj_bm
***                                AND atinn = cabn-atinn
***                                AND klart = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
***   Get objek nr
**  SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**              WHERE MATNR = IT_MSKA-MATNR
**                AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**  CLEAR AUSP.
**  SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**  SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                              AND ATINN = CABN-ATINN
**                              AND KLART = '023'.
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE1801  =  ( LC_KASPE1801 / AUSP-ATFLV ).
**  ENDIF.
**
**
**
********************************************************************
***Plant : 2000
***sum kalab and kaspe into 2801 : 2801, 2803, 2901, 2805
********************************************************************
***Slit Rolls in FG Storage Location
***---------------------------------
***Plnt : 2000
***Sloc : 2801.
**  CLEAR :LC_KALAB2801,
**         LC_KASPE2801.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2801' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
**
***********************************************
***Sloc : 2803
***********************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2803' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab2801 = lc_kalab2801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
***end of ALF
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab2801  =  ( lc_kalab2801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB2801  =  LC_KALAB2801 + V_KALAB.
***end of ALF
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR: AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2803' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe2801 = lc_kaspe2801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
***end of ALF
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
*********    LC_KASPE2801  =  LC_KASPE1801 + V_KASPE. " Komen 7 January 2013
**    LC_KASPE2801  =  LC_KASPE2801 + V_KASPE. " Benerin 7 January 2013
**  ENDIF.
**
***Sloc : 2901
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2901' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab2801 = lc_kalab2801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
***end of ALF
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab2801  =  ( lc_kalab2801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB2801  =  LC_KALAB2801 + V_KALAB.
***end of ALF
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2901' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***midify by ALF
***  lc_kaspe2801 = lc_kaspe2801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
***end of ALF
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    V_KASPE = V_KASPE / AUSP-ATFLV.
**    LC_KASPE2801  =  LC_KASPE2801 + V_KASPE.
**  ENDIF.
**
**
*******************************************
***Sloc : 2805
*******************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2805' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab2801 = lc_kalab2801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
***end of ALF
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab2801  =  ( lc_kalab2801 / ausp-atflv ).
**    V_KALAB       = V_KALAB / AUSP-ATFLV.
**    LC_KALAB2801  = LC_KALAB2801 + V_KALAB.
***end of ALF
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2805' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe2801 = lc_kaspe2801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
***end of ALF
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe2801 / ausp-atflv ).
**    V_KASPE = V_KASPE / AUSP-ATFLV.
**    LC_KASPE2801  =   LC_KASPE2801 + V_KASPE.
***end of ALF
**  ENDIF.
***IF ausp-atflv NE space.
***  lc_kalab2801  =  ( lc_kalab2801 / ausp-atflv ).
***ENDIF.
**
*******************************************
***Sloc : 2807 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2807' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2807' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 2809 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2809' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2809' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 2811 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2811' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2811' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 2813 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2813' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '2813' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 3801 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3801' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 3813 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3813' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3813' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*******************************************
***Sloc : 3815 " Add 7 January 2013
*******************************************
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3815' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB2801 = LC_KALAB2801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB2801  =  ( LC_KALAB2801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '2000' AND LGORT = '3815' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE2801 = LC_KASPE2801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe2801  =  ( lc_kaspe1801 / ausp-atflv ).
**    LC_KASPE2801  =  ( LC_KASPE2801 / AUSP-ATFLV ).
**  ENDIF.
**
*********************************************************************************************
***Plant : 3000
***sum kalab and kaspe into 3801 : 3801, 3803, 3805, 1801, 1803, 1805, 2801, 2803, 2805, 2901
**********************************************************************************************
***Slit Rolls in FG Storage Location
***---------------------------------
***Plnt : 3000
***Sloc : 3801.
**  CLEAR :LC_KALAB3801,
**         LC_KASPE3801.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
**    LC_KALAB3801 = LC_KALAB3801 + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KALAB3801  =  ( LC_KALAB3801 / AUSP-ATFLV ).
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3801' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
**    LC_KASPE3801 = LC_KASPE3801 + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
**    LC_KASPE3801  =  ( LC_KASPE3801 / AUSP-ATFLV ).
**  ENDIF.
**
**
********************************
***Sloc : 3803
********************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3803' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
***end of ALF
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB      = V_KALAB / AUSP-ATFLV.
**    LC_KALAB3801 = LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3803' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE = V_KASPE / AUSP-ATFLV.
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**
**  ENDIF.
**
**
***Sloc : 3805
**************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3805' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
*******
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB = V_KALAB / AUSP-ATFLV.
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '3805' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE = V_KASPE / AUSP-ATFLV.
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**
**  ENDIF.
***IF ausp-atflv NE space.
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
***ENDIF.
**
**
***Sloc : 3000-1801
*********************************************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB = V_KALAB / AUSP-ATFLV.
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1801' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  V_KASPE / AUSP-ATFLV.
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**  ENDIF.
**
**
***Sloc : 3000-1803
**********************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1803' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  V_KALAB / AUSP-ATFLV.
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1803' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  V_KASPE / AUSP-ATFLV.
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**  ENDIF.
**
**
**
***Sloc : 3000-1805
****************************************************************************************
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1805' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify byb ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '1805' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**  ENDIF.
**
***Sloc : 3000-2801
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2801' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2801' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**
**  ENDIF.
**
***Sloc : 3000-2803
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2803' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2803' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**  ENDIF.
**
***Sloc : 3000-2805
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2805' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2805' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
**    LC_KASPE3801  =  LC_KASPE3801 + V_KASPE.
**  ENDIF.
**
***Sloc : 3000-2901
**  CLEAR COUNTER.
**  CLEAR: AUSP, V_KALAB, V_KASPE.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2901' AND KALAB <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kalab3801 = lc_kalab3801 + it_mska-kalab.
**    V_KALAB = V_KALAB + IT_MSKA-KALAB.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kalab3801  =  ( lc_kalab3801 / ausp-atflv ).
**    V_KALAB  =  ( V_KALAB / AUSP-ATFLV ).
**    LC_KALAB3801  =  LC_KALAB3801 + V_KALAB.
**  ENDIF.
**
**  CLEAR COUNTER.
**  CLEAR AUSP.
**  LOOP AT IT_MSKA WHERE VBELN = P_VBELN AND POSNR = P_POSNR AND MATNR = VBAP-MATNR AND
**                        WERKS = '3000' AND LGORT = '2901' AND KASPE <> 0.
**    ADD 1 TO COUNTER.
***modify by ALF
***  lc_kaspe3801 = lc_kaspe3801 + it_mska-kaspe.
**    V_KASPE = V_KASPE + IT_MSKA-KASPE.
**
**    IF COUNTER = 1.
***   Get objek nr
**      SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
**                  WHERE MATNR = IT_MSKA-MATNR
**                    AND CHARG = IT_MSKA-CHARG.
**
***   Read attin nr.
**      CLEAR AUSP.
**      SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
***   Read charateristic value
**      SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
**                                  AND ATINN = CABN-ATINN
**                                  AND KLART = '023'.
**    ENDIF.
**
**  ENDLOOP.
**
**  IF AUSP-ATFLV NE SPACE.
***modify by ALF
***  lc_kaspe3801  =  ( lc_kaspe3801 / ausp-atflv ).
**    V_KASPE  =  ( V_KASPE / AUSP-ATFLV ).
**    LC_KASPE3801  =  V_KASPE + V_KASPE.
**  ENDIF.



*===================
*Quantity Delivery
*===================
  CLEAR : LC_DELV601,
          LC_DELV602,
          LC_DELV631,
          LC_DELV632.

  SELECT MATNR CHARG MENGE INTO (MSEG-MATNR, MSEG-CHARG, MSEG-MENGE) FROM MSEG WHERE MATNR = VBAP-MATNR AND
                                                                                     KDAUF = P_VBELN AND
                                                                                     KDPOS = P_POSNR AND
                                                                                     WERKS = VBAP-WERKS AND
                                                                                     BWART = '601'.
*   %_HINTS ORACLE 'INDEX(mseg"Z01")'.
*     Get objek nr
    SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                WHERE MATNR = MSEG-MATNR
                  AND CHARG = MSEG-CHARG.

*     Read attin nr.
    CLEAR AUSP.
    SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*     Read charateristic value
    SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                AND ATINN = CABN-ATINN
                                AND KLART = '023'.

    IF AUSP-ATFLV NE SPACE.
      LC_DELV601  =  LC_DELV601 + ( MSEG-MENGE / AUSP-ATFLV ).
    ENDIF.
  ENDSELECT.

  SELECT MATNR CHARG MENGE INTO (MSEG-MATNR, MSEG-CHARG, MSEG-MENGE) FROM MSEG WHERE MATNR = VBAP-MATNR AND
                                                                                     KDAUF = P_VBELN AND
                                                                                     KDPOS = P_POSNR AND
                                                                                     WERKS = VBAP-WERKS AND
                                                                                     BWART = '602'.
*   %_HINTS ORACLE 'INDEX(mseg"Z01")'.
*     Get objek nr
    SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                WHERE MATNR = MSEG-MATNR
                  AND CHARG = MSEG-CHARG.

*     Read attin nr.
    CLEAR AUSP.
    SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*     Read charateristic value
    SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                AND ATINN = CABN-ATINN
                                AND KLART = '023'.

    IF AUSP-ATFLV NE SPACE.
      LC_DELV602  =  LC_DELV602 + ( MSEG-MENGE / AUSP-ATFLV ).
    ENDIF.
  ENDSELECT.

  SELECT MATNR CHARG MENGE INTO (MSEG-MATNR, MSEG-CHARG, MSEG-MENGE) FROM MSEG WHERE MATNR = VBAP-MATNR AND
                                                                                     KDAUF = P_VBELN AND
                                                                                     KDPOS = P_POSNR AND
                                                                                     WERKS = VBAP-WERKS AND
                                                                                     BWART = '631'.
*   %_HINTS ORACLE 'INDEX(mseg"Z01")'.
*     Get objek nr
    SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                WHERE MATNR = MSEG-MATNR
                  AND CHARG = MSEG-CHARG.

*     Read attin nr.
    CLEAR AUSP.
    SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*     Read charateristic value
    SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                AND ATINN = CABN-ATINN
                                AND KLART = '023'.

    IF AUSP-ATFLV NE SPACE.
      LC_DELV631  =  LC_DELV631 + ( MSEG-MENGE / AUSP-ATFLV ).
    ENDIF.
  ENDSELECT.

  SELECT MATNR CHARG MENGE INTO (MSEG-MATNR, MSEG-CHARG, MSEG-MENGE) FROM MSEG WHERE MATNR = VBAP-MATNR AND
                                                                                     KDAUF = P_VBELN AND
                                                                                     KDPOS = P_POSNR AND
                                                                                     WERKS = VBAP-WERKS AND
                                                                                     BWART = '632'.
*   %_HINTS ORACLE 'INDEX(mseg"Z01")'.
*     Get objek nr
    SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                WHERE MATNR = MSEG-MATNR
                  AND CHARG = MSEG-CHARG.

*     Read attin nr.
    CLEAR AUSP.
    SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*     Read charateristic value
    SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                AND ATINN = CABN-ATINN
                                AND KLART = '023'.

    IF AUSP-ATFLV NE SPACE.
      LC_DELV632  =  LC_DELV632 + ( MSEG-MENGE / AUSP-ATFLV ).
    ENDIF.
  ENDSELECT.

  IF VBAP-PSTYV = 'ZKEN'.
    SELECT SINGLE VBELN POSNN INTO (VBFA-VBELN, VBFA-POSNN) FROM VBFA
    WHERE VBELV = P_VBELN AND POSNV = P_POSNR AND VBTYP_N = 'J'.
    IF SY-SUBRC = 0.
      SELECT SINGLE WADAT_IST INTO LIKP-WADAT_IST FROM LIKP WHERE VBELN = VBFA-VBELN.
    ENDIF.

    IF LIKP-WADAT_IST NE SPACE.
      CLEAR LC_DELV633.
      SELECT MATNR CHARG LFIMG INTO (LIPS-MATNR, LIPS-CHARG, LIPS-LFIMG) FROM LIPS WHERE VBELN = VBFA-VBELN AND
                                                                                         UECHA = VBFA-POSNN.
*       Get objek nr
        SELECT SINGLE CUOBJ_BM FROM MCH1 INTO MCH1-CUOBJ_BM
                    WHERE MATNR = LIPS-MATNR
                      AND CHARG = LIPS-CHARG.

*       Read attin nr.
        CLEAR AUSP.
        SELECT SINGLE ATINN INTO CABN-ATINN FROM CABN WHERE ATNAM = 'ZZCONVERSIONROLLKG'.
*       Read charateristic value
        SELECT SINGLE * FROM AUSP WHERE OBJEK = MCH1-CUOBJ_BM
                                    AND ATINN = CABN-ATINN
                                    AND KLART = '023'.

        IF AUSP-ATFLV NE SPACE.
          LC_DELV633 = LC_DELV633 + ( LIPS-LFIMG / AUSP-ATFLV ).
        ENDIF.
      ENDSELECT.
    ENDIF.
    LC_DELV = LC_DELV633.
  ELSE.
    LC_DELV = LC_DELV601 + LC_DELV631 - LC_DELV602 - LC_DELV632.
  ENDIF.

  CLEAR P_MENGE.
  P_MENGE = LC_DELV + ( LC_WEMNG + LC_KALAB1 + LC_KALAB2 + LC_KASPE1 + LC_KASPE2 + LC_KALAB1802 +
                         LC_KASPE1802 + LC_KALAB2802 + LC_KASPE2802 + LC_KALAB3802 + LC_KASPE3802 +
                         LC_KALAB1801 + LC_KASPE1801 + LC_KALAB2801 + LC_KASPE2801 + LC_KALAB3801 +
                         LC_KASPE3801 ) - KWMENG.

ENDFORM.                    " get_to_be_slit

*&---------------------------------------------------------------------*
*&      Form  f_define_lgort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DEFINE_LGORT .

**Additional Qty to be slit 8 January 2013
  CLEAR R_LGORT.
  REFRESH R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '1P01'.
  R_LGORT-HIGH   =  '1P03'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '2P01'.
  R_LGORT-HIGH   =  '2P03'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '1Z01'.
  R_LGORT-HIGH   =  '1Z02'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '2Z01'.
  R_LGORT-HIGH   =  '2Z03'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'EQ'.
  R_LGORT-LOW    =  '1A01'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'EQ'.
  R_LGORT-LOW    =  '2A01'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'EQ'.
  R_LGORT-LOW    =  '2L01'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'EQ'.
  R_LGORT-LOW    =  '2R01'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '2T01'.
  R_LGORT-HIGH   =  '2T02'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'EQ'.
  R_LGORT-LOW    =  '2S01'.
  APPEND R_LGORT.

  R_LGORT-SIGN   =  'I'.
  R_LGORT-OPTION =  'BT'.
  R_LGORT-LOW    =  '1E01'.
  R_LGORT-HIGH   =  '1E02'.
  APPEND R_LGORT.
**End Additional Qty to be slit 8 January 2013

  CLEAR R_WERKS.
  REFRESH R_WERKS.

  R_WERKS-SIGN   =  'I'.
  R_WERKS-OPTION =  'BT'.
  R_WERKS-LOW    =  '1000'.
  R_WERKS-HIGH   =  '3000'.
  APPEND R_WERKS.

  CLEAR R_LGORT1302.
  REFRESH R_LGORT1302.

  R_LGORT1302-SIGN   =  'I'.
  R_LGORT1302-OPTION =  'BT'.
  R_LGORT1302-LOW    =  '1301'.
  R_LGORT1302-HIGH   =  '1304'.
  APPEND R_LGORT1302.

  R_LGORT1302-SIGN   =  'I'.
  R_LGORT1302-OPTION =  'BT'.
  R_LGORT1302-LOW    =  '2301'.
  R_LGORT1302-HIGH   =  '2901'.
  APPEND R_LGORT1302.

**Additional 7 January 2013
  R_LGORT1302-SIGN   =  'I'.
  R_LGORT1302-OPTION =  'EQ'.
  R_LGORT1302-LOW    =  '1306'.
  APPEND R_LGORT1302.

  R_LGORT1302-SIGN   =  'I'.
  R_LGORT1302-OPTION =  'EQ'.
  R_LGORT1302-LOW    =  '1308'.
  APPEND R_LGORT1302.
**End Additional 7 January 2013

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1801'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1802'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1803'.
  APPEND R_LGORT2302.

**Additional 7 January 2013
  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1804'.
  APPEND R_LGORT2302.
**End Additional 7 January 2013

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1805'.
  APPEND R_LGORT2302.

**Additional 7 January 2013
  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1806'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'BT'.
  R_LGORT2302-LOW    =  '1808'.
  R_LGORT2302-HIGH   =  '1814'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '1STS'.
  APPEND R_LGORT2302.
**End Additional 7 January 2013

*******  R_LGORT2302-SIGN   =  'I'.
*******  R_LGORT2302-OPTION =  'EQ'.
*******  R_LGORT2302-LOW    =  '2801'.
*******  APPEND R_LGORT2302.
*******
*******  R_LGORT2302-SIGN   =  'I'.
*******  R_LGORT2302-OPTION =  'EQ'.
*******  R_LGORT2302-LOW    =  '2802'.
*******  APPEND R_LGORT2302.
*******
*******  R_LGORT2302-SIGN   =  'I'.
*******  R_LGORT2302-OPTION =  'EQ'.
*******  R_LGORT2302-LOW    =  '2803'.
*******  APPEND R_LGORT2302.
*******
*******  R_LGORT2302-SIGN   =  'I'.
*******  R_LGORT2302-OPTION =  'EQ'.
*******  R_LGORT2302-LOW    =  '2805'.
*******  APPEND R_LGORT2302.

**Additional 7 January 2013
  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'BT'.
  R_LGORT2302-LOW    =  '2301'.
  R_LGORT2302-HIGH   =  '2320'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'BT'.
  R_LGORT2302-LOW    =  '2801'.
  R_LGORT2302-HIGH   =  '2814'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '2STS'.
  APPEND R_LGORT2302.
**End Additional 7 January 2013

*  R_LGORT2302-SIGN   =  'I'.
*  R_LGORT2302-OPTION =  'EQ'.
*  R_LGORT2302-LOW    =  '2901'.
*  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3801'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3802'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3803'.
  APPEND R_LGORT2302.

**Additional 7 January 2013
  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3804'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3810'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3813'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3815'.
  APPEND R_LGORT2302.

  R_LGORT2302-SIGN   =  'I'.
  R_LGORT2302-OPTION =  'EQ'.
  R_LGORT2302-LOW    =  '3STS'.
  APPEND R_LGORT2302.
**End Additional 7 January 2013

*  R_LGORT2302-SIGN   =  'I'.
*  R_LGORT2302-OPTION =  'EQ'.
*  R_LGORT2302-LOW    =  '3805'.
*  APPEND R_LGORT2302.


ENDFORM.                    " f_define_lgort

*&---------------------------------------------------------------------*
*&      Form  l_define_lgort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM L_DEFINE_LGORT USING P_WERKS.
  IF P_WERKS = '1000'.
    CLEAR LGORT.
    REFRESH LGORT.

    LGORT-SIGN   =  'I'.
    LGORT-OPTION =  'BT'.
    LGORT-LOW    =  '1301'.
*    LGORT-HIGH   =  '1304'.
    LGORT-HIGH   =  '1308'.
    APPEND LGORT.
  ELSEIF P_WERKS = '2000'.
    CLEAR LGORT.
    REFRESH LGORT.

    LGORT-SIGN   =  'I'.
    LGORT-OPTION =  'BT'.
    LGORT-LOW    =  '2301'.
*    LGORT-HIGH   =  '2312'.
    LGORT-HIGH   =  '2320'.
    APPEND LGORT.
  ENDIF.
ENDFORM.                    "l_define_lgort
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DETAIL CHANGING P_FLAG.

  DATA: BEGIN OF IT_BATCH OCCURS 3,
          ID    TYPE C,
          CHARG LIKE MCH1-CHARG,
          TYPE  LIKE AUSP-ATWRT,
        END OF IT_BATCH.
  DATA: WA_BATCH LIKE LINE OF IT_BATCH,
        IN_CHARG LIKE MCH1-CHARG,
        V_MATNR  LIKE MCH1-MATNR.
  FIELD-SYMBOLS: <FS_BATCH> LIKE LINE OF IT_BATCH.

  CLEAR: IN_CHARG1, IN_CHARG2, IN_CHARG3, V_TYPE1, V_TYPE2, V_TYPE3, CHK1,
         IT_BATCH, IN_CHARG,V_TEXT1 , V_TEXT2, V_TEXT3.
  REFRESH: IT_BATCH.

*  READ LINE 6  FIELD VALUE IN_CHARG1.
  READ LINE 5  FIELD VALUE IN_CHARG1.
  IF IN_CHARG1 NE ''.
    CLEAR: WA_BATCH.
    WA_BATCH-ID    = 1.
    WA_BATCH-CHARG = IN_CHARG1.
    APPEND WA_BATCH TO IT_BATCH.
  ELSE.
    CLEAR: V_TYPE1, IN_CHARG1, V_TEXT1.
*    MODIFY LINE 6  FIELD VALUE V_TYPE1 IN_CHARG1 V_TEXT1.
    MODIFY LINE 5  FIELD VALUE V_TYPE1 IN_CHARG1 V_TEXT1.
  ENDIF.

*  READ LINE 8  FIELD VALUE IN_CHARG2.
  READ LINE 6  FIELD VALUE IN_CHARG2.
  IF IN_CHARG2 NE ''.
    CLEAR: WA_BATCH.
    WA_BATCH-ID    = 2.
    WA_BATCH-CHARG = IN_CHARG2.
    APPEND WA_BATCH TO IT_BATCH.
  ELSE.
    CLEAR: V_TYPE2, IN_CHARG2, V_TEXT2.
*    MODIFY LINE 8  FIELD VALUE V_TYPE2 IN_CHARG2 V_TEXT2.
    MODIFY LINE 6  FIELD VALUE V_TYPE2 IN_CHARG2 V_TEXT2.
  ENDIF.

*  READ LINE 10 FIELD VALUE IN_CHARG3.
  READ LINE 7 FIELD VALUE IN_CHARG3.
  IF IN_CHARG3 NE ''.
    CLEAR: WA_BATCH.
    WA_BATCH-ID    = 3.
    WA_BATCH-CHARG = IN_CHARG3.
    APPEND WA_BATCH TO IT_BATCH.
  ELSE.
    CLEAR: V_TYPE3, IN_CHARG3, V_TEXT3.
*    MODIFY LINE 10 FIELD VALUE V_TYPE3 IN_CHARG3 V_TEXT3.
    MODIFY LINE 7 FIELD VALUE V_TYPE3 IN_CHARG3 V_TEXT3.
  ENDIF.


  CLEAR: IN_CHARG, V_TYPE1, V_TYPE2, V_TYPE3,
         V_MATNR,V_TEXT1 , V_TEXT2, V_TEXT3.

  LOOP AT IT_BATCH ASSIGNING <FS_BATCH>.

    CLEAR: V_LGORT.
    SELECT SINGLE LGORT
      INTO V_LGORT
      FROM MCHB
     WHERE CHARG = <FS_BATCH>-CHARG.
    IF SY-SUBRC NE 0.
*******      MESSAGE I001(00) WITH 'Batch yang dimasukkan salah'. "#EC NOTEXT
      MESSAGE 'Batch yang dimasukkan salah' TYPE 'I'.       "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.

    CHECK <FS_BATCH>-CHARG NE ''.
    IN_CHARG = <FS_BATCH>-CHARG.
    SELECT SINGLE MATNR
      INTO V_MATNR
      FROM MCH1
     WHERE CHARG = IN_CHARG.
    IF <FS_BATCH>-ID = 1.
      PERFORM GET_ZZTYPE USING V_MATNR IN_CHARG1 CHANGING V_TYPE1.
      PERFORM GET_BATCH_TEXT USING V_MATNR IN_CHARG1 CHANGING V_TEXT1.
*      READ LINE 6.
      READ LINE 5.
*      MODIFY LINE 6  FIELD VALUE V_TYPE1 IN_CHARG1 V_TEXT1.
      MODIFY LINE 5  FIELD VALUE V_TYPE1 IN_CHARG1 V_TEXT1.
    ELSEIF <FS_BATCH>-ID = 2.
      PERFORM GET_ZZTYPE USING V_MATNR IN_CHARG2 CHANGING V_TYPE2.
      PERFORM GET_BATCH_TEXT USING V_MATNR IN_CHARG2 CHANGING V_TEXT2.
*      READ LINE 8.
      READ LINE 6.
*      MODIFY LINE 8  FIELD VALUE V_TYPE2 IN_CHARG2 V_TEXT2.
      MODIFY LINE 6  FIELD VALUE V_TYPE2 IN_CHARG2 V_TEXT2.
    ELSEIF <FS_BATCH>-ID = 3.
      PERFORM GET_ZZTYPE USING V_MATNR IN_CHARG3 CHANGING V_TYPE3.
      PERFORM GET_BATCH_TEXT USING V_MATNR IN_CHARG3 CHANGING V_TEXT3.
*      READ LINE 10.
      READ LINE 7.
*      MODIFY LINE 10 FIELD VALUE V_TYPE3 IN_CHARG3 V_TEXT3.
      MODIFY LINE 7 FIELD VALUE V_TYPE3 IN_CHARG3 V_TEXT3.
    ENDIF.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_DETAIL
*&---------------------------------------------------------------------*
*&      Form  GET_ZZTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZZTYPE USING V_MATNR IN_CHARG CHANGING V_TYPE1." V_TYPE2 V_TYPE3.

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
  REFRESH: CHAR_OF_BATCH.

  PERFORM VB_INIT.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = V_MATNR
      CHARG                    = IN_CHARG
*     WERKS                    =
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
             .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

*  READ TABLE CHAR_OF_BATCH INTO WA_CHAR_OF_BATCH WITH KEY ATNAM = 'ZZPOSITIONSS'.
  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCODE'." BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    V_TYPE1 = <FS_CHAR_OF_BATCH>-ATWTB.
  ENDIF.

ENDFORM.                    " GET_ZZTYPE
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BATCH_TEXT USING V_MATNR IN_CHARG CHANGING V_TEXT1.

  DATA: L_MATNR TYPE MATNR,
        L_CHARG TYPE CHARG_D,
        ZLINES LIKE TLINE OCCURS 0 WITH HEADER LINE,
        ZTHEAD LIKE THEAD,
        L_CHAR(4) VALUE '    '.

  L_MATNR = V_MATNR.
  TRANSLATE L_MATNR TO UPPER CASE.

*-- Convert Material Number to Input format.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = L_MATNR
    IMPORTING
      OUTPUT       = L_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

  L_CHARG = IN_CHARG.
  TRANSLATE L_CHARG TO UPPER CASE.

  CONCATENATE L_MATNR L_CHARG INTO ZTHEAD-TDNAME SEPARATED BY L_CHAR RESPECTING BLANKS.

  MOVE: 'VERM' TO ZTHEAD-TDID,
        'CHARGE' TO ZTHEAD-TDOBJECT.

*-- Call function to get the text.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                        = SY-MANDT
      ID                            = ZTHEAD-TDID
      LANGUAGE                      = SY-LANGU
      NAME                          = ZTHEAD-TDNAME
      OBJECT                        = ZTHEAD-TDOBJECT
*     importing
*       header                        =
    TABLES
      LINES                         = ZLINES
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

  IF SY-SUBRC = 0.
    READ TABLE ZLINES INDEX 1.
    IF SY-SUBRC = 0.
      V_TEXT1 = ZLINES-TDLINE.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_BATCH_TEXT
*&---------------------------------------------------------------------*
*&      Form  MODIF_MARK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_MARK USING MARK.

*  DO.
  DO LBASIC TIMES.
    CHECK SY-INDEX >= 7.
    READ LINE SY-INDEX.
    CHECK SY-SUBRC EQ 0.
    MODIFY LINE SY-INDEX FIELD VALUE MARK.
  ENDDO.

ENDFORM.                    " MODIF_MARK
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_BATCH_BOXER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_BATCH_BOXER .

  CLEAR: ZSTAT.

  SET PF-STATUS ''.
*  SET TITLEBAR 'BATCH'.
  WINDOW STARTING AT 25 3 "10
           ENDING AT 128 18."25.

  CLEAR: WA_POS.
  LOOP AT ITAB_POS INTO WA_POS.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_POS-MATNR
        CHARG                    = WA_POS-CHARG
        WERKS                    = WA_POS-WERKS
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZGRADE'.
    IF SY-SUBRC EQ 0.
      WA_POS-GRADE = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.
    CLEAR: V_ATINN, V_ATZHL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZGRADE'
      IMPORTING
        OUTPUT = V_ATINN.
    SELECT SINGLE ATZHL INTO V_ATZHL
      FROM CAWNT
     WHERE ATINN = V_ATINN AND ATWTB = WA_POS-GRADE.
*      %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
    IF SY-SUBRC EQ 0.
      CLEAR WA_POS-GRADE.
      SELECT SINGLE ATWRT INTO WA_POS-GRADE
        FROM CAWN
       WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPOSITIONMS'.
    IF SY-SUBRC EQ 0.
      WA_POS-POSMS = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPOSITIONSS'.
    IF SY-SUBRC EQ 0.
      WA_POS-POSSS = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC EQ 0.
      WA_POS-NOROL = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.

    MODIFY ITAB_POS FROM WA_POS TRANSPORTING GRADE POSMS POSSS NOROL.

  ENDLOOP.

  SORT ITAB_POS BY POSMS POSSS.

  WRITE:/1  'Display Batch By Order'.                       "#EC NOTEXT
  SKIP.

  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:/1(103)  SY-ULINE.
  WRITE:/1    SY-VLINE NO-GAP,
         (4)  'Post' CENTERED NO-GAP, SY-VLINE NO-GAP,      "#EC NOTEXT
         (12) 'Order Number' CENTERED NO-GAP, SY-VLINE NO-GAP, "#EC NOTEXT
         (10) 'Batch' CENTERED NO-GAP, SY-VLINE NO-GAP,     "#EC NOTEXT
         (30) 'Nomor Roll' CENTERED NO-GAP, SY-VLINE NO-GAP, "#EC NOTEXT
*         (16) 'SONUM', sy-vline,
         (10) 'SO Number' CENTERED NO-GAP, SY-VLINE NO-GAP, "#EC NOTEXT
         (6)  'SOItem' CENTERED NO-GAP, SY-VLINE NO-GAP,    "#EC NOTEXT
         (5)  'Grade' CENTERED NO-GAP, SY-VLINE NO-GAP,     "#EC NOTEXT
         (17) 'Status' CENTERED NO-GAP, SY-VLINE NO-GAP.    "#EC NOTEXT
  WRITE:/1(103)  SY-ULINE.
  FORMAT COLOR COL_BACKGROUND.

  CLEAR: V_ABLAD.
  SELECT SINGLE ABLAD
    INTO V_ABLAD
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND ABLAD IN ('SS','MS').

  LOOP AT ZBOXER.

*******    PERFORM GET_STATUS USING ZBOXER-AUFNR CHANGING E_SYSST.
    CLEAR: ZSTAT.
*******    IF E_SYSST CP '*DLV*' OR
*******       E_SYSST CP '*PDLV*'.
    PERFORM CEK_CANCEL_ORDER USING ZBOXER-AUFNR ZBOXER-MATNR CHANGING ZSTAT.
*******    ENDIF.

    LOOP AT ITAB_POS WHERE LICHA = ZBOXER-AUFNR.

      ITAB_POS-ZSTAT = ZSTAT.
*      MODIFY ITAB_POS.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ZBOXER-POSNR1
        IMPORTING
          OUTPUT = ZBOXER-POSNR1.
      PERFORM SET_COLOR.
      IF ZSTAT = 'Goods Receipt'.
        SELECT SINGLE VBELN POSNR
          INTO (ITAB_POS-VBELN,ITAB_POS-POSNR)
          FROM MSKA
         WHERE CHARG = ITAB_POS-CHARG AND KALAB > 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ITAB_POS-VBELN
          IMPORTING
            OUTPUT = ITAB_POS-VBELN.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = ITAB_POS-POSNR
          IMPORTING
            OUTPUT = ITAB_POS-POSNR.
        IF SY-SUBRC = 0.
*          IF ZBOXER-ARBPL(1)  =  'M'.
          IF V_ABLAD  =  'MS'.
            WRITE:/1    SY-VLINE NO-GAP,
                   (4)  ITAB_POS-POSMS CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (30) ITAB_POS-NOROL CENTERED NO-GAP, SY-VLINE NO-GAP,
*                   (16) zboxer-vbeln1, sy-vline,
                   (10) ITAB_POS-VBELN CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (6)  ITAB_POS-POSNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
*          ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
          ELSEIF V_ABLAD  =  'SS'.
            WRITE:/1    SY-VLINE NO-GAP,
                 (4)  ITAB_POS-POSSS CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (30) ITAB_POS-NOROL CENTERED NO-GAP, SY-VLINE NO-GAP,
*                 (16) zboxer-vbeln1, sy-vline,
                 (10) ITAB_POS-VBELN CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (6)  ITAB_POS-POSNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
          ENDIF.
        ELSE.
*          IF ZBOXER-ARBPL(1)  =  'M'.
          IF V_ABLAD  =  'MS'.
            WRITE:/1    SY-VLINE NO-GAP,
                   (4)  ITAB_POS-POSMS CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (30) ITAB_POS-NOROL CENTERED NO-GAP, SY-VLINE NO-GAP,
*                   (16) zboxer-vbeln1, sy-vline,
                   (10) ZBOXER-VBELN1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (6)  ZBOXER-POSNR1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
                   (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
*          ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
          ELSEIF V_ABLAD  =  'SS'.
            WRITE:/1    SY-VLINE NO-GAP,
                 (4)  ITAB_POS-POSSS CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (30) ITAB_POS-NOROL CENTERED NO-GAP, SY-VLINE NO-GAP,
*                 (16) zboxer-vbeln1, sy-vline,
                 (10) ZBOXER-VBELN1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (6)  ZBOXER-POSNR1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
          ENDIF.
        ENDIF.
      ELSE.
*        IF ZBOXER-ARBPL(1)  =  'M'.
        IF V_ABLAD  =  'MS'.
          WRITE:/1    SY-VLINE NO-GAP,
                 (4)  ITAB_POS-POSMS CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (30) ' ' CENTERED NO-GAP, SY-VLINE NO-GAP,
*                 (16) zboxer-vbeln1, sy-vline,
                 (10) ZBOXER-VBELN1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (6)  ZBOXER-POSNR1 CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
                 (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
*        ELSEIF ZBOXER-ARBPL(1)  =  'S' OR ZBOXER-ARBPL(1)  =  'F'.
        ELSEIF V_ABLAD  =  'SS'.
          WRITE:/1    SY-VLINE NO-GAP,
               (4)  ITAB_POS-POSSS CENTERED NO-GAP, SY-VLINE NO-GAP,
               (12) ZBOXER-AUFNR CENTERED NO-GAP, SY-VLINE NO-GAP,
               (10) ITAB_POS-CHARG CENTERED NO-GAP, SY-VLINE NO-GAP,
               (30) ' ' CENTERED NO-GAP, SY-VLINE NO-GAP,
*               (16) zboxer-vbeln1, sy-vline,
               (10) ZBOXER-VBELN1 CENTERED NO-GAP, SY-VLINE NO-GAP,
               (6)  ZBOXER-POSNR1 CENTERED NO-GAP, SY-VLINE NO-GAP,
               (5)  ITAB_POS-GRADE CENTERED NO-GAP, SY-VLINE NO-GAP,
               (17) ZSTAT CENTERED NO-GAP, SY-VLINE NO-GAP.
        ENDIF.
      ENDIF.

      MODIFY ITAB_POS.

    ENDLOOP.
    WRITE:/1(103)  SY-ULINE.

  ENDLOOP.

ENDFORM.                    " DISPLAY_BATCH_BOXER
*&---------------------------------------------------------------------*
*&      Form  GET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_STATUS USING P_AUFNR LIKE ZBOXER-AUFNR
                CHANGING E_SYSST.

  CLEAR: V_OBJNR, E_SYSST.
  SELECT SINGLE OBJNR
    INTO V_OBJNR
    FROM AUFK
   WHERE AUFNR = P_AUFNR.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'AIP9_STATUS_READ'
      EXPORTING
        I_OBJNR = V_OBJNR
        I_SPRAS = SY-LANGU
      IMPORTING
        E_SYSST = E_SYSST
*       E_ANWST =
      .
  ENDIF.

ENDFORM.                    " GET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CEK_CANCEL_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_CANCEL_ORDER USING P_AUFNR LIKE ZBOXER-AUFNR
                            P_MATNR LIKE ZBOXER-MATNR
                      CHANGING ZSTAT.

**  DATA: V_MBLNR LIKE MSEG-MBLNR.
**  SELECT SINGLE MBLNR
**    INTO V_MBLNR
**    FROM MSEG
**   WHERE MATNR = P_MATNR AND AUFNR = P_AUFNR AND BWART = '102'.
**  IF SY-SUBRC = 0.
**    ZSTAT = 'Already Cancelled'.
**  ELSE.
**    CLEAR ZSTAT.
**  ENDIF.

  DATA: V_101 TYPE I,
        V_102 TYPE I.
  SELECT COUNT( * )
    INTO V_101
    FROM MSEG
   WHERE MATNR = P_MATNR AND AUFNR = P_AUFNR AND BWART = '101'.
*    %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.
  IF SY-SUBRC = 0.
    SELECT COUNT( * )
      INTO V_102
      FROM MSEG
     WHERE MATNR = P_MATNR AND AUFNR = P_AUFNR AND BWART = '102'.
*      %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.
    IF SY-SUBRC = 0.
      IF V_101 = V_102.
        ZSTAT = 'Already Cancelled'.                        "#EC NOTEXT
      ELSEIF V_101 > V_102.
        ZSTAT = 'Goods Receipt'.                            "#EC NOTEXT
      ENDIF.
    ELSE.
      ZSTAT = 'Goods Receipt'.                              "#EC NOTEXT
    ENDIF.
  ELSE.
    CLEAR ZSTAT.
  ENDIF.
**  IF SY-SUBRC = 0.
**    ZSTAT = 'Already Cancelled'.
**  ELSE.
**    CLEAR ZSTAT.
**  ENDIF.

ENDFORM.                    " CEK_CANCEL_ORDER

*&---------------------------------------------------------------------*
*&      Form  retrieve_data_boxer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLAG  text
*----------------------------------------------------------------------*
FORM RETRIEVE_DATA_BOXER  CHANGING P_FLAG.

  DATA: P_IDX  TYPE  P,
        FLAGS,
        OFF  TYPE  I,
        OF  TYPE  I,
        V_IDX  LIKE SY-TABIX,
        ROW TYPE I.

  READ TABLE ZBOXER INDEX 1.
*   check document status
  LOOP AT ZBOXER.
    PERFORM GET_ORDER_STATUS USING ZBOXER-AUFNR
                             CHANGING STATUS.

    IF STATUS = 'DLV' OR STATUS = 'PDLV'.
*******      MESSAGE I001(00) WITH 'Order sudah di good receipt'. "#EC NOTEXT
      MESSAGE 'Order sudah di good receipt' TYPE 'I'.       "#EC NOTEXT
      CLEAR FLAG.
      FLAG  = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF FLAG  =  'X'.
    EXIT.
  ENDIF.

  CLEAR: TLOCK, FLAG.
  CONCATENATE 'PO' COM_ORDER INTO TLOCK.
  PERFORM LOCK_EZGR USING TLOCK CHANGING FLAG.
  IF FLAG = 'X'.
*******    MESSAGE I001(00) WITH 'PO sedang diproses'. "#EC NOTEXT
    MESSAGE 'PO sedang diproses' TYPE 'I'.                  "#EC NOTEXT
    EXIT.
  ENDIF.

  CLEAR: IT_MAIN, P_IDX, V_IDX, P_FLAG,
         IN_NIK, IN_RES, IN_SPEED, IN_CHARG1, IN_CHARG2, IN_CHARG3, IN_SLOC1, IN_SLOC2, IN_SLOC3,
         IN_JOINT2, IN_JOINT3, CHK1, CHK2, CHK3.
  REFRESH: IT_MAIN.

  SORT ITAB_POS BY AUFNR CHARG. " Additional 15 Okt 2012

  DO.
    READ LINE SY-INDEX.
    IF SY-SUBRC <> 0.
      EXIT.
    ENDIF.

    READ LINE SY-INDEX FIELD VALUE IN_NIK IN_CHARG1 IN_SLOC1 CHK1
                                   IN_RES IN_CHARG2 IN_SLOC2 IN_JOINT2 CHK2
                                   IN_SPEED IN_CHARG3 IN_SLOC3 IN_JOINT3 CHK3.

    ADD 1 TO P_IDX.

    IF SY-LISEL(10) = 'Keterangan'.
      V_IDX = P_IDX + 3."5.
    ENDIF.

    IF P_IDX >= V_IDX AND V_IDX NE 0.
      IF SY-LISEL+3(12) NE SPACE AND SY-LISEL+3(12) NE 'Nama Cust. :'.
        ADD 1 TO IT_MAIN-PIDX.
        MOVE SY-LISEL(2)       TO  IT_MAIN-ZPOST.
        MOVE SY-LISEL+3(12)    TO  IT_MAIN-AUFNR.
        CLEAR: VMESS.
        MOVE SY-LISEL+16(25) TO VMESS.
        CLEAR: VAR1, VAR2, VAR3, VAR4. " Additional ZZCORE 7 January 2013
        SPLIT VMESS AT SPACE INTO VAR1 VAR2 VAR3 VAR4. " Additional ZZCORE 7 January 2013
        SPLIT VAR2 AT 'x' INTO IT_MAIN-LEBAR IT_MAIN-PANJANG.
        IT_MAIN-V_WIDTH  = IT_MAIN-LEBAR.
        IT_MAIN-V_LENGTH = IT_MAIN-PANJANG.

        CLEAR ZGRADE.
*        MOVE sy-lisel+43(5)    TO  zgrade.
        MOVE SY-LISEL+58(5)    TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE1  =  ZGRADE.

*        MOVE sy-lisel+51(1)    TO  it_main-marks1.
        MOVE SY-LISEL+66(1)    TO  IT_MAIN-MARKS1.

        CLEAR ZGRADE.
*        MOVE sy-lisel+55(5)    TO  zgrade.
        MOVE SY-LISEL+70(5)    TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE2  =  ZGRADE.

*        MOVE sy-lisel+63(1)    TO  it_main-marks2.
        MOVE SY-LISEL+78(1)    TO  IT_MAIN-MARKS2.

        CLEAR ZGRADE.
*        MOVE sy-lisel+67(5)    TO  zgrade.
        MOVE SY-LISEL+82(5)    TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE3  =  ZGRADE.

*        MOVE sy-lisel+75(1)    TO  it_main-marks3.
        MOVE SY-LISEL+90(1)    TO  IT_MAIN-MARKS3.

        CLEAR ZGRADE.
*        MOVE sy-lisel+79(5)    TO  zgrade.
        MOVE SY-LISEL+94(5)    TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE4  =  ZGRADE.

*        MOVE sy-lisel+87(1)    TO  it_main-marks4.
        MOVE SY-LISEL+102(1)    TO  IT_MAIN-MARKS4.

        CLEAR ZGRADE.
*        MOVE sy-lisel+91(5)    TO  zgrade.
        MOVE SY-LISEL+106(5)    TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE5  =  ZGRADE.

*        MOVE sy-lisel+99(1)    TO  it_main-marks5.
        MOVE SY-LISEL+114(1)    TO  IT_MAIN-MARKS5.

        CLEAR ZGRADE.
*        MOVE sy-lisel+103(5)   TO  zgrade.
        MOVE SY-LISEL+118(5)   TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE6  =  ZGRADE.

*        MOVE sy-lisel+111(1)   TO  it_main-marks6.
        MOVE SY-LISEL+126(1)   TO  IT_MAIN-MARKS6.

        CLEAR ZGRADE.
*        MOVE sy-lisel+115(5)   TO  zgrade.
        MOVE SY-LISEL+130(5)   TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE7  =  ZGRADE.

*        MOVE sy-lisel+123(1)   TO  it_main-marks7.
        MOVE SY-LISEL+138(1)   TO  IT_MAIN-MARKS7.

        CLEAR ZGRADE.
*        MOVE sy-lisel+127(5)   TO  zgrade.
        MOVE SY-LISEL+142(5)   TO  ZGRADE.
        CONDENSE ZGRADE NO-GAPS.
        IT_MAIN-GRADE8  =  ZGRADE.

*        MOVE sy-lisel+135(1)   TO  it_main-marks8.
        MOVE SY-LISEL+150(1)   TO  IT_MAIN-MARKS8.

        CLEAR: WA_POS.
        READ TABLE ITAB_POS INTO WA_POS INDEX IT_MAIN-PIDX.
        IF SY-SUBRC = 0.
          IT_MAIN-CHARG = WA_POS-CHARG.
          IT_MAIN-ZZDERIVATIVEMS = WA_POS-DERMS.
          IT_MAIN-ZZDERIVATIVESS = WA_POS-DERSS.
          IT_MAIN-ZZCONV = WA_POS-CONV.
          IT_MAIN-ZZWEIGHTEL = WA_POS-ZZWEIGHTEL.
        ENDIF.

********Additional
        SELECT SINGLE MATNR DWERK LGORT INTO (IT_MAIN-MATERIAL, IT_MAIN-PLANT, IT_MAIN-STGE_LOC)
          FROM AFPO
         WHERE AUFNR = IT_MAIN-AUFNR.
********End Additional

        APPEND IT_MAIN.
        CLEAR :  IT_MAIN-ZPOST,
                 IT_MAIN-AUFNR,
                 IT_MAIN-CHARG,
                 IT_MAIN-GRADE1,
                 IT_MAIN-MARKS1,
                 IT_MAIN-GRADE2,
                 IT_MAIN-MARKS2,
                 IT_MAIN-GRADE3,
                 IT_MAIN-MARKS3,
                 IT_MAIN-GRADE4,
                 IT_MAIN-MARKS4,
                 IT_MAIN-GRADE5,
                 IT_MAIN-MARKS5,
                 IT_MAIN-GRADE6,
                 IT_MAIN-MARKS6,
                 IT_MAIN-GRADE7,
                 IT_MAIN-MARKS7,
                 IT_MAIN-GRADE8,
                 IT_MAIN-MARKS8,
                 IT_MAIN-V_WIDTH,
                 IT_MAIN-ZZDERIVATIVEMS,
                 IT_MAIN-ZZDERIVATIVESS,
                 IT_MAIN-V_LENGTH,
                 IT_MAIN-ZZCONV,
                 IT_MAIN-ZZWEIGHTEL,
                 IT_MAIN-MATERIAL,
                 IT_MAIN-PLANT,
                 IT_MAIN-STGE_LOC.
      ENDIF.
    ENDIF.

  ENDDO.

  READ TABLE ITAB_POS WITH KEY ZSTAT = 'Already Cancelled'. "#EC NOTEXT
  IF SY-SUBRC = 0.
    READ TABLE ITAB_POS WITH KEY ZSTAT = SPACE.
    IF SY-SUBRC = 0.
*******      MESSAGE I001(00) WITH 'Order harus di cancel semua'. "#EC NOTEXT
      MESSAGE 'Order harus di cancel semua' TYPE 'I'.       "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

* Validasi Batch Untuk ZZSRSHEET
  IF CLASS = 'ZZSRSHEET' AND IN_CHARG2 NE '' OR
     CLASS = 'ZZSRSHEET' AND IN_CHARG3 NE ''.

*******    MESSAGE I001(00) WITH 'Untuk Cast Sheet tidak boleh isi batch 2 dan 3'. "#EC NOTEXT
    MESSAGE 'Untuk Cast Sheet tidak boleh isi batch 2 dan 3' TYPE 'I'. "#EC NOTEXT
    P_FLAG = 'X'.
    CLEAR: IN_CHARG2, IN_SLOC2, IN_JOINT2, V_TYPE2, V_TEXT2, CHK2.
    READ LINE 8.
    MODIFY LINE 8 FIELD VALUE IN_CHARG2 IN_SLOC2 IN_JOINT2 V_TYPE2 V_TEXT2 CHK2.
    CLEAR: IN_CHARG3, IN_SLOC3, IN_JOINT3, V_TYPE3, V_TEXT3, CHK3.
    READ LINE 10.
    MODIFY LINE 10 FIELD VALUE IN_CHARG3 IN_SLOC3 IN_JOINT3 V_TYPE3 V_TEXT3 CHK3.
    EXIT.

  ENDIF.

* Validasi Batch Harus diisi berurutan
  IF IN_CHARG1 = '' AND ( IN_CHARG2 NE '' OR IN_CHARG3 NE '' ).
*******    MESSAGE I001(00) WITH 'Pastikan batch line 1 sudah ada isinya'. "#EC NOTEXT
    MESSAGE 'Pastikan batch line 1 sudah ada isinya' TYPE 'I'. "#EC NOTEXT
    P_FLAG = 'X'.
    EXIT.
  ELSE.
    IF IN_CHARG2 = '' AND IN_CHARG3 NE ''.
*******      MESSAGE I001(00) WITH 'Pastikan batch line 2 sudah ada isinya'. "#EC NOTEXT
      MESSAGE 'Pastikan batch line 2 sudah ada isinya' TYPE 'I'. "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

* Validasi NIK
  IF IN_NIK = ''.
*******    MESSAGE I001(00) WITH 'Isi NIK'. "#EC NOTEXT
    MESSAGE 'Isi NIK' TYPE 'I'.                             "#EC NOTEXT
*******    MESSAGE I001(00) WITH 'Harap isi NIK'.
    SET CURSOR 22 5.  " FIELD IN_NIK LINE 5.
    P_FLAG = 'X'.
    EXIT.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IN_NIK
      IMPORTING
        OUTPUT = IN_NIK.
    IN_NIK = IN_NIK+2(8).
  ENDIF.
* Validasi Speed
  IF IN_SPEED = ''.
*******    MESSAGE I001(00) WITH 'Isi Speed Machine'. "#EC NOTEXT
    MESSAGE 'Isi Speed Machine' TYPE 'I'.                   "#EC NOTEXT
*******    MESSAGE I001(00) WITH 'Harap isi Speed Machine'.
    SET CURSOR 22 7.
    P_FLAG = 'X'.
    EXIT.
**Penambahan Validasi Speed Machine harus angka 17 January 2013
  ELSE.
    DATA: STRING_OUT,
          HTYPE LIKE DD01V-DATATYPE.
    CLEAR: STRING_OUT, HTYPE.
    CALL FUNCTION 'NUMERIC_CHECK'
      EXPORTING
        STRING_IN  = IN_SPEED
      IMPORTING
        STRING_OUT = STRING_OUT
        HTYPE      = HTYPE.
    IF HTYPE NE 'NUMC'.
      MESSAGE 'Speed Machine Harus Numeric!!' TYPE 'I'.     "#EC NOTEXT
      SET CURSOR 22 7.
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
**End Penambahan Validasi Speed Machine harus angka 17 January 2013
  ENDIF.
* Validasi Resource
  IF IN_RES NE ''.
    CLEAR: V_ARBPL.
    SELECT SINGLE ARBPL
      INTO V_ARBPL
      FROM CRHD
     WHERE ARBPL = IN_RES.
    IF SY-SUBRC NE 0.
*******      MESSAGE I001(00) WITH 'Resource yang anda masukkan salah'. "#EC NOTEXT
      MESSAGE 'Resource yang anda masukkan salah' TYPE 'I'. "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ELSE.
      READ TABLE ZBOXER INDEX 1.
      IF SY-SUBRC = 0.
        SELECT SINGLE HRP1001~OBJID INTO DOBJID
          FROM HRP1001
          JOIN CRHD ON CRHD~HROID = HRP1001~SOBID
          WHERE WERKS = ZBOXER-WERKS AND
                ARBPL = IN_RES AND
                SCLAS = 'A' AND
                HRP1001~OBJID = IN_NIK.
        IF SY-SUBRC NE 0.
          CLEAR: VMESS.
          CONCATENATE 'NIK :' IN_NIK 'tidak diassign ke resource' IN_RES INTO VMESS SEPARATED BY SPACE.
*******          MESSAGE I001(00) WITH VMESS.
          MESSAGE VMESS TYPE 'I'.
          P_FLAG = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE ZBOXER INDEX 1.
    IF SY-SUBRC = 0.
      SELECT SINGLE HRP1001~OBJID INTO DOBJID
        FROM HRP1001
        JOIN CRHD ON CRHD~HROID = HRP1001~SOBID
        WHERE WERKS = ZBOXER-WERKS AND
              ARBPL = ZBOXER-ARBPL AND
              SCLAS = 'A' AND
              HRP1001~OBJID = IN_NIK.
      IF SY-SUBRC NE 0.
        CLEAR: VMESS.
        CONCATENATE 'NIK :' IN_NIK 'tidak diassign ke resource' ZBOXER-ARBPL INTO VMESS SEPARATED BY SPACE.
*******        MESSAGE I001(00) WITH VMESS.
        MESSAGE VMESS TYPE 'I'.
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

* Validasi Batch
  CLEAR: IT_INBATCH, VCHARG.
  REFRESH: IT_INBATCH.
  IF IN_CHARG1 = '' AND IN_CHARG2 = '' AND IN_CHARG3 = ''.
*******    MESSAGE I001(00) WITH 'Pastikan batch sudah terisi'. "#EC NOTEXT
    MESSAGE 'Pastikan batch sudah terisi' TYPE 'I'.         "#EC NOTEXT
    SET CURSOR 39 5.
    P_FLAG = 'X'.
    EXIT.
  ELSE.
    IF IN_CHARG1 = ''.
      CLEAR: IN_SLOC1, CHK1.
      READ LINE 6.
      MODIFY LINE 6 FIELD VALUE IN_SLOC1 CHK1.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IN_CHARG1
        IMPORTING
          OUTPUT = IN_CHARG1.
      CLEAR: VCHARG.
      SELECT SINGLE CHARG
        INTO VCHARG
        FROM VEPO
       WHERE CHARG = IN_CHARG1.
      IF SY-SUBRC = 0.
*******        MESSAGE I001(00) WITH 'Batch Inputan 1 Terikat HU'. "#EC NOTEXT
        MESSAGE 'Batch Inputan 1 Terikat HU' TYPE 'I'.      "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
      IT_INBATCH-ID    = 1.
      IT_INBATCH-CHARG = IN_CHARG1.
      TRANSLATE IN_SLOC1 TO UPPER CASE.
      IT_INBATCH-LGORT = IN_SLOC1.
      IT_INBATCH-SCRAP = CHK1.
      APPEND IT_INBATCH.
      CLEAR: VMATNR.
      SELECT SINGLE MATNR
        INTO VMATNR
        FROM MCH1
       WHERE CHARG = IN_CHARG1.
      IF V_ABLAD = 'MS' AND VMATNR+0(2) NE 'JR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Jumbo Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Jumbo Roll' TYPE 'I'.  "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ELSEIF V_ABLAD = 'SS' AND VMATNR+0(2) NE 'SR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Slit Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Slit Roll' TYPE 'I'.   "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******Tambahan Validasi Material reservation 9 January 2013
      CLEAR: VMATNR2.
      SELECT SINGLE MATNR
        INTO VMATNR2
        FROM RESB
       WHERE AUFNR = COM_ORDER AND MATNR = VMATNR.
      IF SY-SUBRC NE 0.
        CLEAR: VMESS.
        CONCATENATE 'Material inputan batch' IN_CHARG1 'tidak sama dengan process order' INTO VMESS SEPARATED BY SPACE.
        MESSAGE VMESS TYPE 'I'.
*        MESSAGE 'Material inputan tidak sama dengan process order' TYPE 'I'. "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******End Tambahan Validasi Material reservation 9 January 2013
    ENDIF.
    IF IN_CHARG2 = ''.
      CLEAR: IN_SLOC2, IN_JOINT2, CHK2.
      READ LINE 8.
      MODIFY LINE 8 FIELD VALUE IN_SLOC2 IN_JOINT2 CHK2.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IN_CHARG2
        IMPORTING
          OUTPUT = IN_CHARG2.
      CLEAR: VCHARG.
      SELECT SINGLE CHARG
        INTO VCHARG
        FROM VEPO
       WHERE CHARG = IN_CHARG2.
      IF SY-SUBRC = 0.
*******        MESSAGE I001(00) WITH 'Batch Inputan 2 Terikat HU'. "#EC NOTEXT
        MESSAGE 'Batch Inputan 2 Terikat HU' TYPE 'I'.      "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
      IT_INBATCH-ID    = 2.
      IT_INBATCH-CHARG = IN_CHARG2.
      TRANSLATE IN_SLOC2 TO UPPER CASE.
      IT_INBATCH-LGORT = IN_SLOC2.
      IT_INBATCH-SCRAP = CHK2.
      APPEND IT_INBATCH.
      CLEAR: VMATNR.
      SELECT SINGLE MATNR
        INTO VMATNR
        FROM MCH1
       WHERE CHARG = IN_CHARG2.
      IF V_ABLAD = 'MS' AND VMATNR+0(2) NE 'JR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Jumbo Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Jumbo Roll' TYPE 'I'.  "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ELSEIF V_ABLAD = 'SS' AND VMATNR+0(2) NE 'SR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Slit Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Slit Roll' TYPE 'I'.   "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******Tambahan Validasi Material reservation 9 January 2013
      CLEAR: VMATNR2.
      SELECT SINGLE MATNR
        INTO VMATNR2
        FROM RESB
       WHERE AUFNR = COM_ORDER AND MATNR = VMATNR.
      IF SY-SUBRC NE 0.
        CLEAR: VMESS.
        CONCATENATE 'Material inputan batch' IN_CHARG2 'tidak sama dengan process order' INTO VMESS SEPARATED BY SPACE.
        MESSAGE VMESS TYPE 'I'.
*        MESSAGE 'Material inputan tidak sama dengan process order' TYPE 'I'. "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******End Tambahan Validasi Material reservation 9 January 2013
    ENDIF.
    IF IN_CHARG3 = ''.
      CLEAR: IN_SLOC3, IN_JOINT3, CHK3.
      READ LINE 10.
      MODIFY LINE 10 FIELD VALUE IN_SLOC3 IN_JOINT3 CHK3.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IN_CHARG3
        IMPORTING
          OUTPUT = IN_CHARG3.
      CLEAR: VCHARG.
      SELECT SINGLE CHARG
        INTO VCHARG
        FROM VEPO
       WHERE CHARG = IN_CHARG3.
      IF SY-SUBRC = 0.
*******        MESSAGE I001(00) WITH 'Batch Inputan 3 Terikat HU'. "#EC NOTEXT
        MESSAGE 'Batch Inputan 3 Terikat HU' TYPE 'I'.      "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
      IT_INBATCH-ID    = 3.
      IT_INBATCH-CHARG = IN_CHARG3.
      TRANSLATE IN_SLOC3 TO UPPER CASE.
      IT_INBATCH-LGORT = IN_SLOC3.
      IT_INBATCH-SCRAP = CHK3.
      APPEND IT_INBATCH.
      CLEAR: VMATNR.
      SELECT SINGLE MATNR
        INTO VMATNR
        FROM MCH1
       WHERE CHARG = IN_CHARG3.
      IF V_ABLAD = 'MS' AND VMATNR+0(2) NE 'JR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Jumbo Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Jumbo Roll' TYPE 'I'.  "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ELSEIF V_ABLAD = 'SS' AND VMATNR+0(2) NE 'SR'.
*******        MESSAGE I001(00) WITH 'Batch Inputan Harus Slit Roll'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Harus Slit Roll' TYPE 'I'.   "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******Tambahan Validasi Material reservation 9 January 2013
      CLEAR: VMATNR2.
      SELECT SINGLE MATNR
        INTO VMATNR2
        FROM RESB
       WHERE AUFNR = COM_ORDER AND MATNR = VMATNR.
      IF SY-SUBRC NE 0.
        CLEAR: VMESS.
        CONCATENATE 'Material inputan batch' IN_CHARG3 'tidak sama dengan process order' INTO VMESS SEPARATED BY SPACE.
        MESSAGE VMESS TYPE 'I'.
*        MESSAGE 'Material inputan tidak sama dengan process order' TYPE 'I'. "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
******End Tambahan Validasi Material reservation 9 January 2013
    ENDIF.
  ENDIF.

  IF IN_CHARG1 NE ''.
    IF IN_CHARG2 NE ''.
      IF IN_CHARG1 = IN_CHARG2.
*******        MESSAGE I001(00) WITH 'Batch Inputan Tidak Boleh Sama'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Tidak Boleh Sama' TYPE 'I'.  "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
    IF IN_CHARG3 NE ''.
      IF IN_CHARG1 = IN_CHARG3.
*******        MESSAGE I001(00) WITH 'Batch Inputan Tidak Boleh Sama'. "#EC NOTEXT
        MESSAGE 'Batch Inputan Tidak Boleh Sama' TYPE 'I'.  "#EC NOTEXT
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  IF IN_CHARG2 NE '' AND IN_CHARG3 NE ''.
    IF IN_CHARG2 = IN_CHARG3.
*******      MESSAGE I001(00) WITH 'Batch Inputan Tidak Boleh Sama'. "#EC NOTEXT
      MESSAGE 'Batch Inputan Tidak Boleh Sama' TYPE 'I'.    "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  IF IN_CHARG1 NE '' AND IN_SLOC1 = '' OR
     IN_CHARG2 NE '' AND IN_SLOC2 = '' OR
     IN_CHARG3 NE '' AND IN_SLOC3 = ''.

*******    MESSAGE I001(00) WITH 'Pastikan sloc sudah terisi dengan lengkap'. "#EC NOTEXT
    MESSAGE 'Pastikan sloc sudah terisi dengan lengkap' TYPE 'I'. "#EC NOTEXT
    IF IN_SLOC1 = ''.
      SET CURSOR 75 5.
    ELSEIF IN_SLOC2 = ''.
      SET CURSOR 75 6.
    ELSEIF IN_SLOC3 = ''.
      SET CURSOR 75 7.
    ENDIF.
    P_FLAG = 'X'.
    EXIT.

  ENDIF.

  LOOP AT IT_INBATCH.
    CLEAR: V_LGORT, VMESS.
    SELECT SINGLE LGORT
      INTO V_LGORT
      FROM MCHB
     WHERE CHARG = IT_INBATCH-CHARG." AND CLABS > 0. " Tambahan Clabs > 0 diminta YAN YOHANA
    IF SY-SUBRC NE 0.
*******      MESSAGE I001(00) WITH 'Batch yang dimasukkan salah'. "#EC NOTEXT
      CLEAR: VMESS.
      CONCATENATE 'Batch' IT_INBATCH-CHARG 'salah' INTO VMESS SEPARATED BY SPACE.
*      MESSAGE 'Batch yang dimasukkan salah' TYPE 'I'. "#EC NOTEXT
      MESSAGE VMESS TYPE 'I'.
      P_FLAG = 'X'.
      EXIT.
    ELSE.
      CLEAR: V_LGORT, VMESS.
      SELECT SINGLE LGORT
        INTO V_LGORT
        FROM MCHB
       WHERE CHARG = IT_INBATCH-CHARG AND CLABS > 0.
      IF SY-SUBRC NE 0.
        CLEAR: VMESS.
        CONCATENATE 'Batch' IT_INBATCH-CHARG 'tidak ada stok' INTO VMESS SEPARATED BY SPACE.
        MESSAGE VMESS TYPE 'I'.
        P_FLAG = 'X'.
        EXIT.
      ELSE.
        CLEAR: V_LGORT, VMESS.
        SELECT SINGLE LGORT
          INTO V_LGORT
          FROM MCHB
         WHERE LGORT = IT_INBATCH-LGORT AND CHARG = IT_INBATCH-CHARG AND CLABS > 0.  "add clabs by Alifi at 02-07-2013
        IF SY-SUBRC NE 0.
          CLEAR: VMESS.
          CONCATENATE 'Batch' IT_INBATCH-CHARG 'tidak ada di Sloc' IT_INBATCH-LGORT INTO VMESS SEPARATED BY SPACE.
*          MESSAGE 'Batch dan Sloc tidak sesuai' TYPE 'I'. "#EC NOTEXT
          MESSAGE VMESS TYPE 'I'.
          P_FLAG = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

* Cek Joint (M) ke-
  CLEAR: ROW, IN_JOINT.
  DESCRIBE TABLE IT_INBATCH LINES ROW.
  IF ROW = 1.
    IF IN_JOINT2 NE '' AND IN_JOINT3 NE ''.
*******      MESSAGE I001(00) WITH 'Joint 1 dan 2 tidak boleh terisi'. "#EC NOTEXT
      MESSAGE 'Joint 1 dan 2 tidak boleh terisi' TYPE 'I'.  "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
    IF IN_JOINT2 NE '' AND IN_JOINT3 = ''.
*******      MESSAGE I001(00) WITH 'Joint 1 tidak boleh terisi'. "#EC NOTEXT
      MESSAGE 'Joint 1 tidak boleh terisi' TYPE 'I'.        "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
    IF IN_JOINT2 = '' AND IN_JOINT3 NE ''.
*******      MESSAGE I001(00) WITH 'Joint 2 tidak boleh terisi'. "#EC NOTEXT
      MESSAGE 'Joint 2 tidak boleh terisi' TYPE 'I'.        "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ELSEIF ROW = 2.
    IF IN_JOINT2 = ''.
*******      MESSAGE I001(00) WITH 'Joint 1 harus terisi'. "#EC NOTEXT
      MESSAGE 'Joint 1 harus terisi' TYPE 'I'.              "#EC NOTEXT
      SET CURSOR 130 6.
      P_FLAG = 'X'.
      EXIT.
****Penambahan Validasi Joint 1 harus angka 17 January 2013
    ELSE.
      CLEAR: STRING_OUT, HTYPE, IN_JOINT.
      IN_JOINT = IN_JOINT2.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN  = IN_JOINT
        IMPORTING
          STRING_OUT = STRING_OUT
          HTYPE      = HTYPE.
      IF HTYPE NE 'NUMC'.
        MESSAGE 'Joint 1 Harus Numeric!!' TYPE 'I'.         "#EC NOTEXT
        SET CURSOR 130 6.
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
****End Penambahan Validasi Joint 1 harus angka 17 January 2013
    ENDIF.

  ELSEIF ROW = 3.
    IF IN_JOINT2 = ''.
*******      MESSAGE I001(00) WITH 'Joint 1 harus terisi'. "#EC NOTEXT
      MESSAGE 'Joint 1 harus terisi' TYPE 'I'.              "#EC NOTEXT
      SET CURSOR 130 6.
      P_FLAG = 'X'.
      EXIT.
****Penambahan Validasi Joint 1 harus angka 17 January 2013
    ELSE.
      CLEAR: STRING_OUT, HTYPE, IN_JOINT.
      IN_JOINT = IN_JOINT2.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN  = IN_JOINT
        IMPORTING
          STRING_OUT = STRING_OUT
          HTYPE      = HTYPE.
      IF HTYPE NE 'NUMC'.
        MESSAGE 'Joint 1 Harus Numeric!!' TYPE 'I'.         "#EC NOTEXT
        SET CURSOR 130 6.
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
****End Penambahan Validasi Joint 1 harus angka 17 January 2013
    ENDIF.
    IF IN_JOINT3 = ''.
*******      MESSAGE I001(00) WITH 'Joint 2 harus terisi'. "#EC NOTEXT
      MESSAGE 'Joint 2 harus terisi' TYPE 'I'.              "#EC NOTEXT
      SET CURSOR 130 7.
      P_FLAG = 'X'.
      EXIT.
****Penambahan Validasi Joint 2 harus angka 17 January 2013
    ELSE.
      CLEAR: STRING_OUT, HTYPE, IN_JOINT.
      IN_JOINT = IN_JOINT3.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN  = IN_JOINT
        IMPORTING
          STRING_OUT = STRING_OUT
          HTYPE      = HTYPE.
      IF HTYPE NE 'NUMC'.
        MESSAGE 'Joint 2 Harus Numeric!!' TYPE 'I'.         "#EC NOTEXT
        SET CURSOR 130 7.
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
****End Penambahan Validasi Joint 2 harus angka 17 January 2013
    ENDIF.
    IF IN_JOINT2 > IN_JOINT3.
*******      MESSAGE I001(00) WITH 'Joint 2 harus lebih kecil dari Joint 3'. "#EC NOTEXT
      MESSAGE 'Joint 2 harus lebih kecil dari Joint 3' TYPE 'I'. "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

* Get characteristic batch inputan
  PERFORM GET_CHAR_BATCH_IN.
* Hitung Total Length sama Width Batch Inputan
  CLEAR: TOT_WIDTH, TOT_LENGTH, MAX_WIDTH.
  LOOP AT IT_INBATCH.
    TOT_WIDTH  = TOT_WIDTH  + IT_INBATCH-ZZWIDTH.
    IF MAX_WIDTH < IT_INBATCH-ZZWIDTH.
      MAX_WIDTH = IT_INBATCH-ZZWIDTH.
    ENDIF.
    TOT_LENGTH = TOT_LENGTH + IT_INBATCH-ZZLENGTH.
  ENDLOOP.
* Hitung Total Width dari Batch Original Order
  CLEAR: TOT_WIDTHOR.
  LOOP AT IT_MAIN.
    TOT_WIDTHOR = TOT_WIDTHOR + IT_MAIN-V_WIDTH.
  ENDLOOP.
* Validasi jika total width original order > total width batch inputan, maka error
*******  IF TOT_WIDTHOR > TOT_WIDTH.
*******    MESSAGE i001(00) WITH 'Tot. Lebar Orig.Order > Tot. Lebar Batch Inputan'.
*******    p_flag = 'X'.
*******    EXIT.
*******  ENDIF.

***Dicabut sama YAN YOHANA tgl 5 November 2012 Disaksikan oleh IRWAN YOSIA
*********** Validasi jika total width original order >= width batch inputan, maka error
**********  IF TOT_WIDTHOR >= MAX_WIDTH.
**********    MESSAGE I001(00) WITH 'Tot. Lebar Orig.Order >= Lebar Batch Inputan'.
**********    P_FLAG = 'X'.
**********    EXIT.
**********  ENDIF.
*********** Validasi jika length original order >= total length batch inputan, maka error
**********  LOOP AT IT_MAIN WHERE V_LENGTH >= TOT_LENGTH.
**********    MESSAGE I001(00) WITH 'Panjang Orig.Order >= Tot. Panjang Batch Inputan'.
**********    P_FLAG = 'X'.
**********    EXIT.
**********  ENDLOOP.
***End Dicabut sama YAN YOHANA tgl 5 November 2012 Disaksikan oleh IRWAN YOSIA

* Validasi Storage Location Per Sloc GR dan Prodline Batch Inputan Line 1
  CLEAR: WA_INBATCH, VZZPRODLINE.
  READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
  IF SY-SUBRC = 0.
    VZZPRODLINE = WA_INBATCH-ZZPRODLINE.
    CLEAR: WA_MAIN.
    LOOP AT IT_MAIN INTO WA_MAIN.
      SELECT SINGLE ZCXLGORT ZWCLGORT ZRRLGORT ZSLLGORT
        INTO (WA_MAIN-ZCXLGORT,WA_MAIN-ZWCLGORT,WA_MAIN-ZRRLGORT,WA_MAIN-ZSLLGORT)
        FROM ZTMAP_SLOCRR
       WHERE ZGRSLLGORT = WA_MAIN-STGE_LOC AND ZLINE = VZZPRODLINE.
      IF SY-SUBRC = 0.
        MODIFY IT_MAIN FROM WA_MAIN TRANSPORTING ZCXLGORT ZWCLGORT ZRRLGORT ZSLLGORT.
      ELSE.
        CLEAR: VMESS.
        CONCATENATE 'Sloc GR Slitting' WA_MAIN-STGE_LOC 'Prodline' VZZPRODLINE 'tidak ditemukan' "#EC NOTEXT " di table ZTMAP_SLOCRR'
                    INTO VMESS SEPARATED BY SPACE.
*******        MESSAGE I001(00)  WITH vmess.
        MESSAGE VMESS TYPE 'I'.
        P_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.
  CLEAR: WA_MAIN.
  LOOP AT IT_MAIN INTO WA_MAIN WHERE ZCXLGORT = '' AND MARKS8 = 'X'.
    CLEAR: VMESS.
    CONCATENATE 'Sloc Sloc Cx untuk line' VZZPRODLINE 'tidak ditemukan' "#EC NOTEXT
                INTO VMESS SEPARATED BY SPACE.
*******    MESSAGE I001(00)  WITH vmess.
    MESSAGE VMESS TYPE 'I'.
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.
  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.
  CLEAR: WA_MAIN.
  LOOP AT IT_MAIN INTO WA_MAIN WHERE ZWCLGORT = ''.
    CLEAR: VMESS.
*    CONCATENATE 'Sloc GR Slitting' WA_MAIN-STGE_LOC 'Prodline' vzzprodline 'belum ada Sloc Waste Comb'
*                INTO vmess SEPARATED BY space.
    CONCATENATE 'Sloc Waste Comb untuk line' VZZPRODLINE 'tidak ditemukan' "#EC NOTEXT
                INTO VMESS SEPARATED BY SPACE.
*******    MESSAGE I001(00)  WITH vmess.
    MESSAGE VMESS TYPE 'I'.
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.
  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.
  CLEAR: WA_MAIN.
  LOOP AT IT_MAIN INTO WA_MAIN WHERE ZRRLGORT = ''.
    CLEAR: VMESS.
*    CONCATENATE 'Sloc GR Slitting' WA_MAIN-STGE_LOC 'Prodline' vzzprodline 'belum ada Sloc Raw Recycle Gabungan'
*                INTO vmess SEPARATED BY space.
    CONCATENATE 'Sloc Raw Recycle Gabungan untul line' VZZPRODLINE 'tidak ditemukan' "#EC NOTEXT
                INTO VMESS SEPARATED BY SPACE.
*******    MESSAGE I001(00)  WITH vmess.
    MESSAGE VMESS TYPE 'I'.
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.
  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.
  CLEAR WA_INBATCH.
  READ TABLE IT_INBATCH INTO WA_INBATCH WITH KEY SCRAP = 'X'.
  IF SY-SUBRC = 0.
    CLEAR: WA_MAIN.
    LOOP AT IT_MAIN INTO WA_MAIN WHERE ZSLLGORT = ''.
      CLEAR: VMESS.
*      CONCATENATE 'Sloc GR Slitting' WA_MAIN-STGE_LOC 'Prodline' vzzprodline 'belum ada Sloc Sisa Core Slitting'
*                  INTO vmess SEPARATED BY space.
      CONCATENATE 'Sloc inputan untuk line' VZZPRODLINE 'tidak ditemukan' "#EC NOTEXT
                  INTO VMESS SEPARATED BY SPACE.
*******      MESSAGE I001(00)  WITH vmess.
      MESSAGE VMESS TYPE 'I'.
      P_FLAG = 'X'.
      EXIT.
    ENDLOOP.
    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
* End Validasi Storage Location Per Sloc GR dan Prodline Batch Inputan Line 1

*  Check position correct number
  LOOP AT IT_MAIN WHERE ZPOST = '00'.
*******    MESSAGE I001(00)  WITH  'Salah penulisan posisi'. "#EC NOTEXT
    MESSAGE 'Salah penulisan posisi' TYPE 'I'.              "#EC NOTEXT
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*  Check position ada isinya atau tidak
  LOOP AT IT_MAIN WHERE ZPOST = ''.
    MESSAGE 'Ada posisi kosong' TYPE 'I'.                   "#EC NOTEXT
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*  Check double option
  LOOP AT IT_MAIN.
    CLEAR ERR.
    IF IT_MAIN-MARKS1  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS2  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS3  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS4  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS5  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS6  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS7  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS8  NE SPACE.
      ADD 1 TO ERR.
    ENDIF.

    IF ERR > 1.
      CLEAR ERR_TEXT.
      CONCATENATE 'Ada kelebihan pilihan di posisi' IT_MAIN-ZPOST INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******      MESSAGE I001(00)  WITH  ERR_TEXT.
      MESSAGE ERR_TEXT TYPE 'I'.
      P_FLAG = 'X'.
      EXIT.
    ENDIF.

    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*  Check no option
  LOOP AT IT_MAIN.
    CLEAR ERR.
    IF IT_MAIN-MARKS1  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS2  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS3  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS4  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS5  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS6  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS7  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.
    IF IT_MAIN-MARKS8  EQ SPACE.
      ADD 1 TO ERR.
    ENDIF.

    IF ERR = 8.
      CLEAR ERR_TEXT.
      CONCATENATE 'Posisi' IT_MAIN-ZPOST 'belum ada pilihan'  INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
******      MESSAGE I001(00)  WITH  ERR_TEXT.
      MESSAGE ERR_TEXT TYPE 'I'.
      P_FLAG = 'X'.
      EXIT.
    ENDIF.

    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  LOOP AT IT_MAIN.
    CLEAR: IT_MAIN2.
    REFRESH: IT_MAIN2.
    IT_MAIN2[] = IT_MAIN[].
    DELETE IT_MAIN2 WHERE PIDX = IT_MAIN-PIDX.
    READ TABLE IT_MAIN2 WITH KEY ZPOST = IT_MAIN-ZPOST.
    IF SY-SUBRC = 0.
*******      MESSAGE I001(00) WITH 'Ada posisi yang kembar'. "#EC NOTEXT
      MESSAGE 'Ada posisi yang kembar' TYPE 'I'.            "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ENDIF.
    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM. " retrieve_data_boxer
*&---------------------------------------------------------------------*
*&      Form  get_status_issue
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_BLIST_AUFNR  text
*      <--P_WA_BLIST_STAT  text
*----------------------------------------------------------------------*
FORM GET_STATUS_ISSUE USING ORDNR
                      CHANGING STAT.

  DATA : OBJEK(22),
         ITAB  LIKE JSTAT OCCURS 2 WITH HEADER LINE.

  CONCATENATE 'OR' ORDNR INTO OBJEK.
  CALL FUNCTION 'STATUS_READ'
    EXPORTING
      OBJNR       = OBJEK
      ONLY_ACTIVE = 'X'
    TABLES
      STATUS      = ITAB.

  SELECT SINGLE * FROM TJ02T INTO *TJ02T WHERE SPRAS = 'EN'
                                           AND TXT04 = 'GMPS'.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = OBJEK
                                           AND STAT  = *TJ02T-ISTAT
                                           AND INACT = ' '.
    IF SY-SUBRC = 0.
      STAT = *TJ02T-TXT04.
    ELSE.
      STAT  =  'NONE'.
    ENDIF.
  ELSE.
    STAT  =  'NONE'.
  ENDIF.

ENDFORM.                    " get_order_status
*&---------------------------------------------------------------------*
*&      Form  LOCK_EZGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOCK_EZGR USING TLOCK CHANGING FLAG.

  IF TLOCK NE ''.
    CALL FUNCTION 'ENQUEUE_EZGR'
      EXPORTING
        MODE_ZTLOCK    = 'E'
        MANDT          = SY-MANDT
        LOOBJ          = TLOCK
*       X_LOOBJ        = ' '
*       _SCOPE         = '2'
*       _WAIT          = ' '
*       _COLLECT       = ' '
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      FLAG = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " LOCK_EZGR
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_EZGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_EZGR USING TLOCK CHANGING FLAG.

  IF TLOCK NE ''.
    CALL FUNCTION 'DEQUEUE_EZGR'
      EXPORTING
        MODE_ZTLOCK    = 'E'
        MANDT          = SY-MANDT
        LOOBJ          = TLOCK
*       X_LOOBJ        = ' '
*       _SCOPE         = '2'
*       _WAIT          = ' '
*       _COLLECT       = ' '
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      FLAG = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " UNLOCK_EZGR
*&---------------------------------------------------------------------*
*&      Form  GET_DEC_NOTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
**FORM GET_DEC_NOTATION USING SY-UNAME CHANGING RIBUAN PULUHAN.
FORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.

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
*&      Form  checking_data_boxer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLAG  text
*----------------------------------------------------------------------*
FORM CHECKING_DATA_BOXER CHANGING P_FLAG.

  DATA: ANS TYPE CHAR1.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Check condition of grade ??' "#EC NOTEXT
      TEXT_QUESTION         = 'Apakah Grade yang dimasukkan sudah benar? ' "#EC NOTEXT
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'                       "#EC NOTEXT
      DEFAULT_BUTTON        = 'A'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = ANS.

  IF ANS = '2' OR ANS = '3'.
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

*  Check correct grade
  LOOP AT ZBOXER.
    LOOP AT IT_MAIN WHERE AUFNR = ZBOXER-AUFNR.
      CONDENSE IT_MAIN-GRADE1 NO-GAPS. " SO Default
      CONDENSE IT_MAIN-GRADE2 NO-GAPS. " SO Option1
      CONDENSE IT_MAIN-GRADE3 NO-GAPS. " SO Option2
      CONDENSE IT_MAIN-GRADE4 NO-GAPS. " SO Second
      CONDENSE IT_MAIN-GRADE5 NO-GAPS. " Base Film (dulunya Free Stock)
      CONDENSE IT_MAIN-GRADE6 NO-GAPS. " Free Stock (dulunya Scrap)
      CONDENSE IT_MAIN-GRADE7 NO-GAPS. " RWRS
      CONDENSE IT_MAIN-GRADE8 NO-GAPS. " Scrap

* For SO Default
      IF IT_MAIN-GRADE1 EQ SPACE AND IT_MAIN-MARKS1 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE1 NE SPACE AND IT_MAIN-MARKS1 NE SPACE.
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE1.
*        READ TABLE it_cawn WITH KEY atwrt = it_main-grade1 BINARY SEARCH.
**      Additional Kalau gada no so,ga boleh di tick
        IF ZBOXER-VBELN1 = ''.
          CLEAR ERR_TEXT.
          ERR_TEXT = 'Tidak Ada No SO Default'.             "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ENDIF.
**      End Additional Kalau gada no so,ga boleh di tick
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER1-VBELN = ZBOXER-VBELN1
                                                    V_ORDER1-POSNR = ZBOXER-POSNR1.
          IF SY-SUBRC = 0.
            IF WA_ORDER-V_ORDER1-CHAR11 = '1'.
*              IF it_cawn-atzhl  >=  '077'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '1'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'DEFAULT'.
              ENDIF.
            ELSEIF WA_ORDER-V_ORDER1-CHAR11 = '2'.
*              IF it_cawn-atzhl  >=  '0198'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '2'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'DEFAULT'.
              ENDIF.
            ELSE.
              CLEAR ERR_TEXT.
              CONCATENATE 'Maintain Grade di SO' WA_ORDER-V_ORDER1-VBELN 'item' WA_ORDER-V_ORDER1-POSNR INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
              MESSAGE ERR_TEXT TYPE 'I'.
              P_FLAG  =  'X'.
              EXIT.
            ENDIF.
          ELSE.
            PERFORM CONFIRM_SO CHANGING ANS.
            IF ANS = '2' OR ANS = '3'.
              P_FLAG  =  'X'.
              EXIT.
            ELSE.
              IT_MAIN-ZSTAT  =  'RWRS'.
              IT_MAIN-GRADE7  =  IT_MAIN-GRADE1.
              IT_MAIN-MARKS7  =  'X'.
              CLEAR IT_MAIN-MARKS1.
              CLEAR IT_MAIN-GRADE1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* For SO Option 1
      IF IT_MAIN-GRADE2 EQ SPACE AND IT_MAIN-MARKS2 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE2 NE SPACE AND IT_MAIN-MARKS2 NE SPACE.
*        READ TABLE it_cawn WITH KEY atwrt = it_main-grade2 BINARY SEARCH.
**      Additional Kalau gada no so,ga boleh di tick
        IF ZBOXER-VBELN2 = ''.
          CLEAR ERR_TEXT.
          ERR_TEXT = 'Tidak Ada No SO Option1'.             "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ENDIF.
**      End Additional Kalau gada no so,ga boleh di tick
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE2.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER2-VBELN = ZBOXER-VBELN2
                                                    V_ORDER2-POSNR = ZBOXER-POSNR2.
          IF SY-SUBRC = 0.
            IF WA_ORDER-V_ORDER2-CHAR11 = '1'.
*              IF it_cawn-atzhl  >=  '077'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '1'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'OPTION1'.
              ENDIF.
            ELSEIF WA_ORDER-V_ORDER2-CHAR11 = '2'.
*              IF it_cawn-atzhl  >=  '0198'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '2'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'OPTION1'.
              ENDIF.
            ELSE.
              CLEAR ERR_TEXT.
              CONCATENATE 'Maintain Grade di SO' WA_ORDER-V_ORDER2-VBELN 'item' WA_ORDER-V_ORDER2-POSNR INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
              MESSAGE ERR_TEXT TYPE 'I'.
              P_FLAG  =  'X'.
              EXIT.
            ENDIF.
          ELSE.
            PERFORM CONFIRM_SO CHANGING ANS.
            IF ANS = '2' OR ANS = '3'.
              P_FLAG  =  'X'.
              EXIT.
            ELSE.
              IT_MAIN-ZSTAT  =  'RWRS'.
              IT_MAIN-GRADE7  =  IT_MAIN-GRADE2.
              IT_MAIN-MARKS7  =  'X'.
              CLEAR IT_MAIN-MARKS2.
              CLEAR IT_MAIN-GRADE2.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* For SO Option 2
      IF IT_MAIN-GRADE3 EQ SPACE AND IT_MAIN-MARKS3 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE3 NE SPACE AND IT_MAIN-MARKS3 NE SPACE.
*        READ TABLE it_cawn WITH KEY atwrt = it_main-grade3 BINARY SEARCH.
**      Additional Kalau gada no so,ga boleh di tick
        IF ZBOXER-VBELN3 = ''.
          CLEAR ERR_TEXT.
          ERR_TEXT = 'Tidak Ada No SO Option2'.             "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ENDIF.
**      End Additional Kalau gada no so,ga boleh di tick
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE3.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER3-VBELN = ZBOXER-VBELN3
                                                    V_ORDER3-POSNR = ZBOXER-POSNR3.
          IF SY-SUBRC = 0.
            IF WA_ORDER-V_ORDER3-CHAR11 = '1'.
*              IF it_cawn-atzhl  >=  '077'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '1'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'OPTION2'.
              ENDIF.
            ELSEIF WA_ORDER-V_ORDER3-CHAR11 = '2'.
*              IF it_cawn-atzhl  >=  '0198'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '2'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'OPTION2'.
              ENDIF.
            ELSE.
              CLEAR ERR_TEXT.
              CONCATENATE 'Maintain Grade di SO' WA_ORDER-V_ORDER3-VBELN 'item' WA_ORDER-V_ORDER3-POSNR INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
              MESSAGE ERR_TEXT TYPE 'I'.
              P_FLAG  =  'X'.
              EXIT.
            ENDIF.
          ELSE.
            PERFORM CONFIRM_SO CHANGING ANS.
            IF ANS = '2' OR ANS = '3'.
              P_FLAG  =  'X'.
              EXIT.
            ELSE.
              IT_MAIN-ZSTAT  =  'RWRS'.
              IT_MAIN-GRADE7  =  IT_MAIN-GRADE3.
              IT_MAIN-MARKS7  =  'X'.
              CLEAR IT_MAIN-MARKS3.
              CLEAR IT_MAIN-GRADE3.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* For SO Second
      IF IT_MAIN-GRADE4 EQ SPACE AND IT_MAIN-MARKS4 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE4 NE SPACE AND IT_MAIN-MARKS4 NE SPACE.
*        READ TABLE it_cawn WITH KEY atwrt = it_main-grade4 BINARY SEARCH.
**      Additional Kalau gada no so,ga boleh di tick
        IF ZBOXER-VBELN4 = ''.
          CLEAR ERR_TEXT.
          ERR_TEXT = 'Tidak Ada No SO Second'.              "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ENDIF.
**      End Additional Kalau gada no so,ga boleh di tick
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE4.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER4-VBELN = ZBOXER-VBELN4
                                                    V_ORDER4-POSNR = ZBOXER-POSNR4.
          IF SY-SUBRC = 0.
            IF WA_ORDER-V_ORDER4-CHAR11 = '1'.
*              IF it_cawn-atzhl  >=  '077'.
*              if itab_grade_criteria-criteria <> '1'.
              CLEAR ERR_TEXT.
              CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******              MESSAGE I001(00) WITH ERR_TEXT.
              MESSAGE ERR_TEXT TYPE 'I'.
              P_FLAG  =  'X'.
              EXIT.
*              ELSE.
*                it_main-zstat  =  'SECOND'.
*              ENDIF.
            ELSEIF WA_ORDER-V_ORDER4-CHAR11 = '2'.
*              IF it_cawn-atzhl  <  '0198'.
              IF ITAB_GRADE_CRITERIA-CRITERIA <> '2'.
                CLEAR ERR_TEXT.
                CONCATENATE 'Grade posisi' IT_MAIN-ZPOST 'tidak sesuai dengan SO' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******                MESSAGE I001(00) WITH ERR_TEXT.
                MESSAGE ERR_TEXT TYPE 'I'.
                P_FLAG  =  'X'.
                EXIT.
              ELSE.
                IT_MAIN-ZSTAT  =  'SECOND'.
              ENDIF.
            ELSE.
              CLEAR ERR_TEXT.
              CONCATENATE 'Maintain Grade di SO' WA_ORDER-V_ORDER4-VBELN 'item' WA_ORDER-V_ORDER4-POSNR INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
              MESSAGE ERR_TEXT TYPE 'I'.
              P_FLAG  =  'X'.
              EXIT.
            ENDIF.
          ELSE.
            PERFORM CONFIRM_SO CHANGING ANS.
            IF ANS = '2' OR ANS = '3'.
              P_FLAG  =  'X'.
              EXIT.
            ELSE.
              IT_MAIN-ZSTAT  =  'RWRS'.
              IT_MAIN-GRADE7  =  IT_MAIN-GRADE4.
              IT_MAIN-MARKS7  =  'X'.
              CLEAR IT_MAIN-MARKS4.
              CLEAR IT_MAIN-GRADE4.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* For Base Film
      IF IT_MAIN-GRADE5 EQ SPACE AND IT_MAIN-MARKS5 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE5 NE SPACE AND IT_MAIN-MARKS5 NE SPACE.
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE5.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          IF ITAB_GRADE_CRITERIA-CRITERIA = 'B'.
            IT_MAIN-ZSTAT = 'BASE'.
          ELSE.
*******            MESSAGE I001(00) WITH 'Grade Base Film salah'. "#EC NOTEXT
            MESSAGE 'Grade Base Film salah' TYPE 'I'.       "#EC NOTEXT
            P_FLAG = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

* For Free Stock
      IF IT_MAIN-GRADE6 EQ SPACE AND IT_MAIN-MARKS6 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE6 NE SPACE AND IT_MAIN-MARKS6 NE SPACE.
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE6.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          IF ITAB_GRADE_CRITERIA-CRITERIA = '1' OR
             ITAB_GRADE_CRITERIA-CRITERIA = '2'.
            IT_MAIN-ZSTAT = 'FREE'.
          ELSE.
*******            MESSAGE I001(00) WITH 'Grade Free Stock salah'. "#EC NOTEXT
            MESSAGE 'Grade Free Stock salah' TYPE 'I'.      "#EC NOTEXT
            P_FLAG = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

* For RW / RS
      IF IT_MAIN-GRADE7 EQ SPACE AND IT_MAIN-MARKS7 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE7 NE SPACE AND IT_MAIN-MARKS7 NE SPACE.
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE7.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          IF ITAB_GRADE_CRITERIA-CRITERIA = 'R'.
            IT_MAIN-ZSTAT = 'RWRS'.
          ELSE.
*******            MESSAGE I001(00) WITH 'Grade RW / RS salah'. "#EC NOTEXT
            MESSAGE 'Grade RW / RS salah' TYPE 'I'.         "#EC NOTEXT
            P_FLAG = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

* For Scrap (CX)
      IF IT_MAIN-GRADE8 EQ SPACE AND IT_MAIN-MARKS8 NE SPACE.
        CLEAR P_FLAG.
        P_FLAG = 'X'.
        CLEAR ERR_TEXT.
        CONCATENATE 'Posisi' IT_MAIN-ZPOST '- grade belum terisi' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        EXIT.
      ELSEIF IT_MAIN-GRADE8 NE SPACE AND IT_MAIN-MARKS8 NE SPACE.
        SORT ITAB_GRADE_CRITERIA BY GRADE.
        READ TABLE ITAB_GRADE_CRITERIA WITH TABLE KEY GRADE = IT_MAIN-GRADE8.
        IF SY-SUBRC <> 0.
          CLEAR ERR_TEXT.
          CONCATENATE 'Grade di posisi' IT_MAIN-ZPOST 'salah' INTO ERR_TEXT SEPARATED BY SPACE. "#EC NOTEXT
*******          MESSAGE I001(00) WITH ERR_TEXT.
          MESSAGE ERR_TEXT TYPE 'I'.
          P_FLAG  =  'X'.
          EXIT.
        ELSE.
          IF ITAB_GRADE_CRITERIA-CRITERIA = 'S'.
            IT_MAIN-ZSTAT  =  'SCRAP'.
          ELSE.
*******            MESSAGE I001(00) WITH 'Grade Scrap salah'. "#EC NOTEXT
            MESSAGE 'Grade Scrap salah' TYPE 'I'.           "#EC NOTEXT
            P_FLAG = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY IT_MAIN TRANSPORTING ZSTAT GRADE1 MARKS1 GRADE2 MARKS2 GRADE3 MARKS3
                                        GRADE4 MARKS4 GRADE5 MARKS5 GRADE6 MARKS6
                                        GRADE7 MARKS7 GRADE8 MARKS8 WHERE PIDX = IT_MAIN-PIDX.
    ENDLOOP.
    IF P_FLAG NE SPACE.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF P_FLAG NE SPACE.
    EXIT.
  ENDIF.

ENDFORM.                    "checking_data_boxer
*&---------------------------------------------------------------------*
*&      Form  CEK_OVER_PROD_Z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
******************************
* Protect from over production
******************************
*--- Trapment for Boxer
FORM CEK_OVER_PROD_Z .

  DATA: VSO1 TYPE P, VSO2 TYPE P, VSO3 TYPE P, VSO4 TYPE P, VSO5 TYPE P, VSO6 TYPE P.
  DATA: VBEDA TYPE P.

  LOOP AT ZBOXER.
    CLEAR: QTS_DEFAULT, QTS_OPTION1, QTS_OPTION2.
    CLEAR: VSO1, VSO2, VSO3, VSO4, VSO5, VSO6.

    IF ZBOXER-VBELN1 NE SPACE AND ZBOXER-POSNR1 NE SPACE.
      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN1 ZBOXER-POSNR1
                             CHANGING QTS_DEFAULT.
    ENDIF.

    IF ZBOXER-VBELN2 NE SPACE AND ZBOXER-POSNR2 NE SPACE.
      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN2 ZBOXER-POSNR2
                             CHANGING QTS_OPTION1.
    ENDIF.

    IF ZBOXER-VBELN3 NE SPACE AND ZBOXER-POSNR3 NE SPACE.
      PERFORM GET_TO_BE_SLIT USING    ZBOXER-VBELN3 ZBOXER-POSNR3
                             CHANGING QTS_OPTION2.
    ENDIF.

    LOOP AT IT_MAIN WHERE AUFNR = ZBOXER-AUFNR.
      IF IT_MAIN-MARKS1 = 'X'.
        VSO1 = VSO1 - 1.
      ELSEIF IT_MAIN-MARKS2 = 'X'.
        VSO2 = VSO2 - 1.
      ELSEIF IT_MAIN-MARKS3 = 'X'.
        VSO3 = VSO3 - 1.
      ELSEIF IT_MAIN-MARKS4 = 'X'.
        VSO4 = VSO4 - 1.
      ELSEIF IT_MAIN-MARKS6 = 'X' AND IT_MAIN-GRADE6+0(1) NE 'O' AND IT_MAIN-GRADE6+0(1) NE 'P' AND IT_MAIN-GRADE6+0(1) NE 'R'.
        READ TABLE ITAB_GRADE_CRITERIA WITH KEY GRADE = IT_MAIN-GRADE6 CRITERIA = '2'.
        IF SY-SUBRC NE 0.
          VSO6 = VSO6 - 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

******* Utk Free Stok Gada JAGAAN!!!!!!!!!!!!
******* Kata YAN YOHANNA
* case free stock.
*******    IF VSO6 < 0.
**************      IF ZBOXER-VBELN1 NE '0000000000'.
*******      IF ZBOXER-VBELN1 NE ''.
**************        IF QTS_DEFAULT EQ 0 AND QTS_OPTION1 EQ 0 AND QTS_OPTION2 EQ 0.
**************          MESSAGE 'Tidak boleh Free Stock kalau qty SO sudah penuh.'  TYPE 'E'.
**************        ENDIF.
*******
*******        VBEDA = QTS_DEFAULT - VSO1.
*******        IF VBEDA < 0.
*******          MESSAGE 'Tidak boleh Free Stock kalau qty SO default belum penuh.'  TYPE 'E'. "#EC NOTEXT
*******        ENDIF.
*******        VBEDA = QTS_OPTION1 - VSO2.
*******        IF VBEDA < 0.
*******          MESSAGE 'Tidak boleh Free Stock kalau qty SO option1 belum penuh.'  TYPE 'E'. "#EC NOTEXT
*******        ENDIF.
*******        VBEDA = QTS_OPTION2 - VSO3.
*******        IF VBEDA < 0.
*******          MESSAGE 'Tidak boleh Free Stock kalau qty SO option2 belum penuh.'  TYPE 'E'. "#EC NOTEXT
*******        ENDIF.
*******      ENDIF.
*******    ENDIF.
* end case of FS

    IF QTS_DEFAULT GT VSO1 AND VSO1 LT 0.
      MESSAGE 'Kelebihan Produksi untuk SO Default.'  TYPE 'E'. "#EC NOTEXT
    ELSEIF QTS_OPTION1 GT VSO2 AND VSO2 LT 0.
      MESSAGE 'Kelebihan Produksi untuk SO Option-1.'  TYPE 'E'. "#EC NOTEXT
    ELSEIF QTS_OPTION2 GT VSO3 AND VSO3 LT 0.
      MESSAGE 'Kelebihan Produksi untuk SO Option-2.'  TYPE 'E'. "#EC NOTEXT
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CEK_OVER_PROD_Z
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_SO CHANGING ANS.

  CLEAR: ANS.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Confirm Stock SO to RWRS'    "#EC NOTEXT
      TEXT_QUESTION         = 'Stock akan dimasukkan ke dalam RWRS karena tidak ada SO' "#EC NOTEXT
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'                       "#EC NOTEXT
      DEFAULT_BUTTON        = 'A'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = ANS.

ENDFORM.                    " CONFIRM_SO

*&---------------------------------------------------------------------*
*&      Form  check_length_boxer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLAG  text
*----------------------------------------------------------------------*
FORM CHECK_LENGTH_BOXER CHANGING P_FLAG.
  DATA: ANS,
        FNAME(20),
        SUBRC,
        TVAL  LIKE SVAL OCCURS 2 WITH HEADER LINE,
        PACKG LIKE MCMARKED_VALUES OCCURS 2 WITH HEADER LINE,
        CTEXT  TYPE  CHAR20.


  WRITE SY-DATUM TO DATE.
  CLEAR PACKG.
  REFRESH PACKG.

  IF CLASS = 'ZZSRSHEET'.

    PERFORM GET_PJG_LBR_JUMBO_SHEET CHANGING P_FLAG.
    IF P_FLAG EQ ''.
      PERFORM GET_ZZCASTSHEETGR CHANGING P_FLAG.
    ENDIF.

  ELSE.

    CALL FUNCTION 'ZPOPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Check condition of derivative ??' "#EC NOTEXT
        TEXT_QUESTION         = 'Apakah order ini ? '       "#EC NOTEXT
*       text_button_1         = 'Panjang Krg'
        TEXT_BUTTON_1         = 'Actual Beda'               "#EC NOTEXT
*       TEXT_BUTTON_2         = 'Join Sendiri' "#EC NOTEXT "Diminta ubah jadi Join 16 January 2013
        TEXT_BUTTON_2         = 'Join'                      "#EC NOTEXT
        DEFAULT_BUTTON        = 'A'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = ANS.

* Actual Beda
    IF ANS = '1'.
      PERFORM PANJANG_LEBAR_KURANG CHANGING P_FLAG.
* Join dengan diri sendiri
    ELSEIF ANS = '2'.
      PERFORM JOIN_DIRI_SENDIRI_BOXER CHANGING P_FLAG.
**  Jika tidak keduanya
    ELSEIF ANS = 'A'.
      P_FLAG  =  ' '.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    " check_length_boxer

*&---------------------------------------------------------------------*
*&      Form  panjang_lebar_kurang
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FLAG  text
*----------------------------------------------------------------------*
FORM PANJANG_LEBAR_KURANG  CHANGING P_FLAG.
  DATA: ANS,
        FNAME(20),
        SUBRC,
        TVAL  LIKE SVAL OCCURS 2 WITH HEADER LINE,
        PACKG LIKE MCMARKED_VALUES OCCURS 2 WITH HEADER LINE,
        CTEXT  TYPE  CHAR50.

  SORT IT_MAIN BY ZPOST.
  LOOP AT IT_MAIN.
    CLEAR FNAME.
    CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO FNAME SEPARATED BY SPACE.

    PACKG-MARKED = ' '.
    PACKG-VALUE = FNAME.
    APPEND PACKG.
    CLEAR PACKG.

  ENDLOOP.

  IF P_FLAG NE SPACE.
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'MC_POPUP_TO_MARK_VALUES'
    EXPORTING
      I_MIN_MARKED_VALUES  = 0
      I_POPUP_TITLE        = 'Different Length'             "#EC NOTEXT
*     i_textline           = 'HU already .. '
      I_TEXT_LENGTH        = 40
      I_ICONINFO_FOR_ENTER = 'Select position :'            "#EC NOTEXT
    TABLES
      T_VALUES_FOR_MARKING = PACKG
    EXCEPTIONS
      CANCEL_PUSHED        = 1
      OTHERS               = 2.

  IF SY-SUBRC = 1.
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  CLEAR: ERR, IT_DISPLAY.
  REFRESH: TVAL, IT_DISPLAY.
  LOOP AT PACKG WHERE MARKED NE SPACE.
    ADD 1 TO ERR.
    READ TABLE IT_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
    IF SY-SUBRC = 0.
      IF IT_MAIN-MARKS5 EQ SPACE AND IT_MAIN-MARKS6 EQ SPACE AND
         IT_MAIN-MARKS7 EQ SPACE AND IT_MAIN-MARKS8 EQ SPACE.
*******        MESSAGE I001(00) WITH 'Untuk ukuran beda tick di Base Film/Free Stock/RWRS/Scrap'. "#EC NOTEXT
        MESSAGE 'Untuk ukuran beda tick di Base Film/Free Stock/RWRS/Scrap' TYPE 'I'. "#EC NOTEXT
        P_FLAG  =  'X'.
        EXIT.
      ENDIF.

      IF P_FLAG = 'X'.
        EXIT.
      ENDIF.

      CLEAR: WA_DISPLAY.
*     Post Index
      WA_DISPLAY-PIDX = IT_MAIN-PIDX.
*     Post Posisi
      WA_DISPLAY-ZPOST = IT_MAIN-ZPOST.
*     Post Order Number
      WA_DISPLAY-AUFNR = IT_MAIN-AUFNR.
*     Post Posisi + Order Number
      CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO WA_DISPLAY-POSORD SEPARATED BY SPACE.
*     Set Lengk = ''
      WA_DISPLAY-LENGK = ''.
*     Set Width = ''
      WA_DISPLAY-WIDTH = ''.
      APPEND WA_DISPLAY TO IT_DISPLAY.

    ENDIF.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  IF ERR = 0.
*******    MESSAGE I001(00) WITH 'Anda tidak memilih, masukkan pilihan'. "#EC NOTEXT
    MESSAGE 'Anda tidak memilih, masukkan pilihan' TYPE 'I'. "#EC NOTEXT
    CALL FUNCTION 'MC_POPUP_TO_MARK_VALUES'
      EXPORTING
        I_MIN_MARKED_VALUES  = 0
        I_POPUP_TITLE        = 'Different Length'           "#EC NOTEXT
*       i_textline           = 'HU already .. '
        I_TEXT_LENGTH        = 40
        I_ICONINFO_FOR_ENTER = 'Select position :'          "#EC NOTEXT
      TABLES
        T_VALUES_FOR_MARKING = PACKG
      EXCEPTIONS
        CANCEL_PUSHED        = 1
        OTHERS               = 2.

    IF SY-SUBRC = 1.
      P_FLAG  =  'X'.
      EXIT.
    ENDIF.

    CLEAR: ERR, IT_DISPLAY.
    REFRESH: TVAL, IT_DISPLAY.
    LOOP AT PACKG WHERE MARKED NE SPACE.
      ADD 1 TO ERR.
      READ TABLE IT_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
      IF SY-SUBRC = 0.
        IF IT_MAIN-MARKS5 EQ SPACE AND IT_MAIN-MARKS6 EQ SPACE AND
           IT_MAIN-MARKS7 EQ SPACE AND IT_MAIN-MARKS8 EQ SPACE.
*******          MESSAGE I001(00) WITH 'Untuk ukuran beda tick di Base Film/Free Stock/RWRS/Scrap'. "#EC NOTEXT
          MESSAGE 'Untuk ukuran beda tick di Base Film/Free Stock/RWRS/Scrap' TYPE 'I'. "#EC NOTEXT
          P_FLAG  =  'X'.
          EXIT.
        ENDIF.
        CLEAR: WA_DISPLAY.
*       Post Index
        WA_DISPLAY-PIDX = IT_MAIN-PIDX.
*       Post Posisi
        WA_DISPLAY-ZPOST = IT_MAIN-ZPOST.
*       Post Order Number
        WA_DISPLAY-AUFNR = IT_MAIN-AUFNR.
*       Post Posisi + Order Number
        CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO WA_DISPLAY-POSORD SEPARATED BY SPACE.
*       Set Lengk = ''
        WA_DISPLAY-LENGK = ''.
*       Set Width = ''
        WA_DISPLAY-WIDTH = ''.
        APPEND WA_DISPLAY TO IT_DISPLAY.

      ENDIF.
    ENDLOOP.

    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.

    IF ERR = 0.
*******      MESSAGE I001(00) WITH 'Anda tidak memilih, masukkan pilihan'. "#EC NOTEXT
      MESSAGE 'Anda tidak memilih, masukkan pilihan' TYPE 'I'. "#EC NOTEXT
      P_FLAG  =  'X'.
      EXIT.
    ELSE.
*    fieldcatalogue for ALV dialog
      PERFORM BUILD_FIELDCAT.
*    Layout for ALV dialog
      PERFORM BUILD_LAYOUT.
*    *ALV dialog output
      PERFORM ALV.
    ENDIF.

    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.

  ELSE.

*fieldcatalogue for ALV dialog
    PERFORM BUILD_FIELDCAT.
*Layout for ALV dialog
    PERFORM BUILD_LAYOUT.
**ALV dialog output
    PERFORM ALV.

  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*  Additional
  CLEAR: WA_DISPLAY, D_IND.
  LOOP AT IT_DISPLAY INTO WA_DISPLAY WHERE LENGK = '' AND
                                           WIDTH = ''.
    D_IND = 'X'.
*******    MESSAGE I001(00) WITH 'Pastikan Panjang atau Lebar telah terisi'. "#EC NOTEXT
    MESSAGE 'Pastikan Panjang atau Lebar telah terisi' TYPE 'I'. "#EC NOTEXT
    EXIT.
  ENDLOOP.
  IF D_IND = 'X'.
*  fieldcatalogue for ALV dialog
    PERFORM BUILD_FIELDCAT.
*  Layout for ALV dialog
    PERFORM BUILD_LAYOUT.
*  *ALV dialog output
    PERFORM ALV.
  ENDIF.
*  End

  CLEAR: WA_DISPLAY.
  LOOP AT IT_DISPLAY INTO WA_DISPLAY WHERE LENGK = '' AND
                                           WIDTH = ''.
*******    MESSAGE I001(00) WITH 'Pastikan Panjang atau Lebar telah terisi'. "#EC NOTEXT
    MESSAGE 'Pastikan Panjang atau Lebar telah terisi' TYPE 'I'. "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  CLEAR ERR.
  LOOP AT PACKG WHERE MARKED NE SPACE.
    ADD 1 TO ERR.
    CLEAR: WA_MAIN.
    READ TABLE IT_MAIN INTO WA_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
    IF SY-SUBRC = 0.
      CLEAR: WA_DISPLAY.
      READ TABLE IT_DISPLAY INTO WA_DISPLAY WITH KEY ZPOST = WA_MAIN-ZPOST.
      IF SY-SUBRC = 0.
        CLEAR: PJ, LK.
        PJ = WA_MAIN-PANJANG+1(9).
        LK = WA_DISPLAY-LENGK.
        WA_MAIN-LENGK  =  WA_DISPLAY-LENGK.
        CLEAR: PJ, LK.
        PJ = WA_MAIN-LEBAR.
        LK = WA_DISPLAY-WIDTH.
        WA_MAIN-WIDTH  = WA_DISPLAY-WIDTH.
      ENDIF.
      WA_MAIN-ZSTAT  =  'BEDA'.
      MODIFY  IT_MAIN FROM WA_MAIN TRANSPORTING ZSTAT LENGK WIDTH WHERE ZPOST  =  PACKG-VALUE(2).
    ENDIF.
  ENDLOOP.

* Hitung Total Width dari Batch Original Order
  CLEAR: TOT_WIDTHOR.
  LOOP AT IT_MAIN." WHERE width > 0.
    IF IT_MAIN-WIDTH > 0.
      TOT_WIDTHOR = TOT_WIDTHOR + IT_MAIN-WIDTH.
    ELSE.
      TOT_WIDTHOR = TOT_WIDTHOR + IT_MAIN-V_WIDTH.
    ENDIF.
  ENDLOOP.
******** Validasi jika total width original order > total width batch inputan, maka error
*******  IF TOT_WIDTHOR > TOT_WIDTH.
*******    MESSAGE i001(00) WITH 'Tot. Lebar Aktual Beda > Tot. Lebar Batch Inputan'.
*******    p_flag = 'X'.
*******    EXIT.
*******  ENDIF.
* Validasi jika total width original order > width batch inputan, maka error
*  IF TOT_WIDTHOR >= MAX_WIDTH." 7 Januari 2013
  IF TOT_WIDTHOR > MAX_WIDTH." 7 Januari 2013
*******    MESSAGE I001(00) WITH 'Tot. Lebar Aktual Beda >= Lebar Batch Inputan'. "#EC NOTEXT
*    MESSAGE 'Tot. Lebar Aktual Beda >= Lebar Batch Inputan' TYPE 'I'. "#EC NOTEXT " 7 Januari 2013
    MESSAGE 'Tot. Lebar Aktual Beda > Lebar Batch Inputan' TYPE 'I'. "#EC NOTEXT " 7 Januari 2013
    P_FLAG = 'X'.
    EXIT.
  ENDIF.
* Validasi jika length original order > total length batch inputan, maka error
  LOOP AT IT_MAIN WHERE LENGK >= TOT_LENGTH.
*******    MESSAGE I001(00) WITH 'Panjang Aktual Beda >= Tot. Panjang Batch Inputan'. "#EC NOTEXT
    MESSAGE 'Panjang Aktual Beda >= Tot. Panjang Batch Inputan' TYPE 'I'. "#EC NOTEXT
    P_FLAG = 'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " panjang_kurang
*&------------------------------------------------------------*
*&      Form  build_fieldcat
*&------------------------------------------------------------*
FORM BUILD_FIELDCAT .
  CLEAR: LT_FIELDCATLOG.
  REFRESH: LT_FIELDCATLOG.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '1'.
  LS_FIELDCATLOG-FIELDNAME = 'PIDX'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Index'.                       "#EC NOTEXT
  LS_FIELDCATLOG-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '2'.
  LS_FIELDCATLOG-FIELDNAME = 'ZPOST'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Posisi'.                      "#EC NOTEXT
  LS_FIELDCATLOG-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '3'.
  LS_FIELDCATLOG-FIELDNAME = 'AUFNR'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'OrderNum'.                    "#EC NOTEXT
  LS_FIELDCATLOG-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '4'.
  LS_FIELDCATLOG-FIELDNAME = 'POSORD'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Position Order'.              "#EC NOTEXT
  LS_FIELDCATLOG-KEY       = 'X'.
*  ls_fieldcatlog-input     = 'X'.
*  ls_fieldcatlog-edit      = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '5'.
  LS_FIELDCATLOG-FIELDNAME = 'LENGK'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Panjang (M)'.                 "#EC NOTEXT
*  ls_fieldcatlog-input     = 'X'.
  LS_FIELDCATLOG-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '6'.
  LS_FIELDCATLOG-FIELDNAME = 'WIDTH'.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Lebar (mm)'.                  "#EC NOTEXT
*  ls_fieldcatlog-input     = 'X'.
  LS_FIELDCATLOG-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
ENDFORM.                    " build_fieldcat
*&----------------------------------------------------------*
*&      Form  build_layout
*&----------------------------------------------------------*
*Layout for ALV dialog
FORM BUILD_LAYOUT .
  LT_LAYOUT-ZEBRA = 'X'.
  LT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " build_layout
*&---------------------------------------------------------------*
*&      Form  alv
*&---------------------------------------------------------------*
*Alv dialog output.
FORM ALV .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Masukkan Panjang/Lebar Kurang' "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT
      IT_FIELDCAT              = LT_FIELDCATLOG
      I_SCREEN_START_COLUMN    = 5  "10
      I_SCREEN_START_LINE      = 3  "20
      I_SCREEN_END_COLUMN      = 50 "60 "100
      I_SCREEN_END_LINE        = 15 "30 "40
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
    TABLES
      T_OUTTAB                 = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " alv

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDPOPUP'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CASE R_UCOMM.
    WHEN '&ONT'.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
        IMPORTING
          E_GRID = REF_GRID.

      IF REF_GRID IS NOT INITIAL.
        CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).  "After calling this method your internal table will have updated values
      ENDIF.

  ENDCASE.

ENDFORM. "user_command

*&---------------------------------------------------------------------*
*&      Form  join_diri_sendiri
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FLAG  text
*----------------------------------------------------------------------*
FORM JOIN_DIRI_SENDIRI_BOXER  CHANGING P_FLAG.
  DATA: ANS,
        FNAME(20),
        SUBRC,
        TVAL  LIKE SVAL OCCURS 2 WITH HEADER LINE,
        T_VAL  LIKE SVAL OCCURS 2 WITH HEADER LINE,
*        ya LIKE zdigitctl OCCURS 0 WITH HEADER LINE,
        PACKG LIKE MCMARKED_VALUES OCCURS 2 WITH HEADER LINE,
        CTEXT  TYPE  CHAR20,
        COUNTER(2) TYPE N.

  CLEAR PACKG.
  REFRESH PACKG.
  LOOP AT IT_MAIN.
    CLEAR FNAME.
    CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO FNAME SEPARATED BY SPACE.

    PACKG-MARKED = ' '.
    PACKG-VALUE = FNAME.
    APPEND PACKG.
    CLEAR PACKG.

  ENDLOOP.

  CALL FUNCTION 'MC_POPUP_TO_MARK_VALUES'
    EXPORTING
      I_MIN_MARKED_VALUES  = 0
      I_POPUP_TITLE        = 'Joint sendiri'                "#EC NOTEXT
*     i_textline           = 'HU already .. '
      I_TEXT_LENGTH        = 40
      I_ICONINFO_FOR_ENTER = 'Select position :'            "#EC NOTEXT
    TABLES
      T_VALUES_FOR_MARKING = PACKG
    EXCEPTIONS
      CANCEL_PUSHED        = 1
      OTHERS               = 2.

  IF SY-SUBRC = 1.
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  CLEAR: ERR, IT_JOIN.
  REFRESH: TVAL, IT_JOIN.
  LOOP AT PACKG WHERE MARKED NE SPACE.
    ADD 1 TO ERR.
    READ TABLE IT_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
    IF SY-SUBRC = 0.
      CLEAR: WA_JOIN.
*     Post Index
      WA_JOIN-PIDX = IT_MAIN-PIDX.
*     Post Posisi
      WA_JOIN-ZPOST = IT_MAIN-ZPOST.
*     Post Order Number
      WA_JOIN-AUFNR = IT_MAIN-AUFNR.
*     Post Posisi + Order Number
      CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO WA_JOIN-POSORD SEPARATED BY SPACE.
*     Set Join ke-1 = ''
      WA_JOIN-JOINT1 = ''.
*     Set join ke-2 = ''
      WA_JOIN-JOINT2 = ''.
*     Set join ke-3 = ''
      WA_JOIN-JOINT3 = ''.
      APPEND WA_JOIN TO IT_JOIN.
    ENDIF.
  ENDLOOP.

  IF ERR = 0.
*******    MESSAGE I001(00) WITH 'Anda tidak memilih, masukkan pilihan'. "#EC NOTEXT
    MESSAGE 'Anda tidak memilih, masukkan pilihan' TYPE 'I'. "#EC NOTEXT
    CALL FUNCTION 'MC_POPUP_TO_MARK_VALUES'
      EXPORTING
        I_MIN_MARKED_VALUES  = 0
        I_POPUP_TITLE        = 'Joint sendiri'              "#EC NOTEXT
*       i_textline           = 'HU already .. '
        I_TEXT_LENGTH        = 40
        I_ICONINFO_FOR_ENTER = 'Select position :'          "#EC NOTEXT
      TABLES
        T_VALUES_FOR_MARKING = PACKG
      EXCEPTIONS
        CANCEL_PUSHED        = 1
        OTHERS               = 2.

    IF SY-SUBRC = 1.
      P_FLAG  =  'X'.
      EXIT.
    ENDIF.

    CLEAR: ERR, IT_JOIN.
    REFRESH: TVAL, IT_JOIN.
    LOOP AT PACKG WHERE MARKED NE SPACE.
      ADD 1 TO ERR.
      READ TABLE IT_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
      IF SY-SUBRC = 0.
        CLEAR: WA_JOIN.
*       Post Index
        WA_JOIN-PIDX = IT_MAIN-PIDX.
*       Post Posisi
        WA_JOIN-ZPOST = IT_MAIN-ZPOST.
*       Post Order Number
        WA_JOIN-AUFNR = IT_MAIN-AUFNR.
*       Post Posisi + Order Number
        CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO WA_JOIN-POSORD SEPARATED BY SPACE.
*       Set Join ke-1 = ''
        WA_JOIN-JOINT1 = ''.
*       Set join ke-2 = ''
        WA_JOIN-JOINT2 = ''.
*       Set join ke-3 = ''
        WA_JOIN-JOINT3 = ''.
        APPEND WA_JOIN TO IT_JOIN.
      ENDIF.
    ENDLOOP.

    IF ERR = 0.
*******      MESSAGE I001(00) WITH 'Anda tidak memilih, masukkan pilihan'. "#EC NOTEXT
      MESSAGE 'Anda tidak memilih, masukkan pilihan' TYPE 'I'. "#EC NOTEXT
      P_FLAG = 'X'.
      EXIT.
    ELSE.
*  fieldcatalogue for ALV dialog
      PERFORM BUILD_FIELDCAT2.
*  Layout for ALV dialog
      PERFORM BUILD_LAYOUT2.
*  *ALV dialog output
      PERFORM ALV2.
    ENDIF.

    IF P_FLAG = 'X'.
      EXIT.
    ENDIF.

  ELSE.

*fieldcatalogue for ALV dialog
    PERFORM BUILD_FIELDCAT2.
*Layout for ALV dialog
    PERFORM BUILD_LAYOUT2.
**ALV dialog output
    PERFORM ALV2.

  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*  Additional
  CLEAR: WA_JOIN, D_IND.
  LOOP AT IT_JOIN INTO WA_JOIN WHERE JOINT1 = ''.
    D_IND = 'X'.
*******    MESSAGE I001(00) WITH 'Joint 1 harus di isi'. "#EC NOTEXT
    MESSAGE 'Joint 1 harus di isi' TYPE 'I'.                "#EC NOTEXT
    EXIT.
  ENDLOOP.
  IF D_IND = 'X'.
*  fieldcatalogue for ALV dialog
    PERFORM BUILD_FIELDCAT2.
*  Layout for ALV dialog
    PERFORM BUILD_LAYOUT2.
*  *ALV dialog output
    PERFORM ALV2.
  ENDIF.
*  End

  CLEAR: WA_JOIN.
  LOOP AT IT_JOIN INTO WA_JOIN WHERE JOINT1 = ''.
*******    MESSAGE I001(00) WITH 'Joint 1 harus di isi'. "#EC NOTEXT
    MESSAGE 'Joint 1 harus di isi' TYPE 'I'.                "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  CLEAR ERR.
  LOOP AT PACKG WHERE MARKED NE SPACE.
    ADD 1 TO ERR.
    CLEAR: WA_MAIN.
    READ TABLE IT_MAIN INTO WA_MAIN WITH KEY ZPOST = PACKG-VALUE(2).
    IF SY-SUBRC = 0.
      CLEAR: WA_JOIN.
      READ TABLE IT_JOIN INTO WA_JOIN WITH KEY ZPOST = WA_MAIN-ZPOST.
      IF SY-SUBRC = 0.
        WA_MAIN-JOINT1 = WA_JOIN-JOINT1.
        WA_MAIN-JOINT2 = WA_JOIN-JOINT2.
        WA_MAIN-JOINT3 = WA_JOIN-JOINT3.
      ENDIF.
      MODIFY  IT_MAIN FROM WA_MAIN TRANSPORTING JOINT1 JOINT2 JOINT3 WHERE ZPOST  =  PACKG-VALUE(2).
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'ZPOPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Check condition of derivative ??' "#EC NOTEXT
      TEXT_QUESTION         = 'Apakah panjang/lebar turunan ini kurang ? ' "#EC NOTEXT
*     text_button_1         = 'Panjang Krg'
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'                       "#EC NOTEXT
      DEFAULT_BUTTON        = 'A'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = ANS.

*  Actual Beda
  IF ANS = '1'.
    PERFORM PANJANG_LEBAR_KURANG CHANGING P_FLAG.
**  Jika tidak keduanya
  ELSEIF ANS = 'A'.
    P_FLAG  =  ' '.
    EXIT.
  ENDIF.

ENDFORM.                    " join_diri_sendiri
*&------------------------------------------------------------*
*&      Form  build_fieldcat
*&------------------------------------------------------------*
FORM BUILD_FIELDCAT2 .
  CLEAR: LT_FIELDCATLOG2.
  REFRESH: LT_FIELDCATLOG2.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '1'.
  LS_FIELDCATLOG2-FIELDNAME = 'PIDX'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Index'.                      "#EC NOTEXT
  LS_FIELDCATLOG2-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '2'.
  LS_FIELDCATLOG2-FIELDNAME = 'ZPOST'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Posisi'.                     "#EC NOTEXT
  LS_FIELDCATLOG2-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '3'.
  LS_FIELDCATLOG2-FIELDNAME = 'AUFNR'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'OrderNum'.                   "#EC NOTEXT
  LS_FIELDCATLOG2-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '4'.
  LS_FIELDCATLOG2-FIELDNAME = 'POSORD'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Position Order'.             "#EC NOTEXT
  LS_FIELDCATLOG2-KEY       = 'X'.
*  ls_fieldcatlog-input     = 'X'.
*  ls_fieldcatlog-edit      = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '5'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT1'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 1 (M)'.                "#EC NOTEXT
*  ls_fieldcatlog-input     = 'X'.
  LS_FIELDCATLOG2-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '6'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT2'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 2 (M)'.                "#EC NOTEXT
*  ls_fieldcatlog-input     = 'X'.
  LS_FIELDCATLOG2-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
  LS_FIELDCATLOG2-ROW_POS   = '1'.
  LS_FIELDCATLOG2-COL_POS   = '7'.
  LS_FIELDCATLOG2-FIELDNAME = 'JOINT3'.
  LS_FIELDCATLOG2-TABNAME   = 'IT_JOIN'.
  LS_FIELDCATLOG2-SELTEXT_M = 'Joint 3 (M)'.                "#EC NOTEXT
*  ls_fieldcatlog-input     = 'X'.
  LS_FIELDCATLOG2-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG2 TO LT_FIELDCATLOG2.
  CLEAR LS_FIELDCATLOG2.
ENDFORM.                    " build_fieldcat
*&----------------------------------------------------------*
*&      Form  build_layout
*&----------------------------------------------------------*
*Layout for ALV dialog
FORM BUILD_LAYOUT2 .
  LT_LAYOUT2-ZEBRA = 'X'.
  LT_LAYOUT2-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " build_layout
*&---------------------------------------------------------------*
*&      Form  alv
*&---------------------------------------------------------------*
*Alv dialog output.
FORM ALV2 .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Masukkan joint di meter ke-' "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT2
      IT_FIELDCAT              = LT_FIELDCATLOG2
      I_SCREEN_START_COLUMN    = 5  "10
      I_SCREEN_START_LINE      = 3  "20
      I_SCREEN_END_COLUMN      = 57 "60 "100
      I_SCREEN_END_LINE        = 15 "30 "40
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND2'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS2'
    TABLES
      T_OUTTAB                 = IT_JOIN
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " alv

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS2 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDPOPUP2'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND2 USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CASE R_UCOMM.
    WHEN '&ONT'.
*      BREAK-POINT.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
        IMPORTING
          E_GRID = REF_GRID.

      IF REF_GRID IS NOT INITIAL.
        CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).  "After calling this method your internal table will have updated values
      ENDIF.
  ENDCASE.

ENDFORM. "user_command
*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_CONFIRMATION CHANGING P_FLAG.

  TOP_IND = 'X'.
  PERFORM GET_DATA_CONFIRM.
  CLEAR : CTRM, CTRB.
  DESCRIBE TABLE IT_MAIN LINES CTRM.
  DESCRIBE TABLE IT_INBATCH LINES CTRB.
  CLEAR: WA_CONFIRM, MAX_LENGTH, MX_LENGTH.
  DATA: LENG TYPE I,
        TWTH TYPE I,
        JOIN TYPE I.
  MAX_LENGTH = 0.
  TWTH = 0.
  LOOP AT IT_CONFIRM INTO WA_CONFIRM.
    CLEAR: LENG.
    TWTH = TWTH + WA_CONFIRM-WIDTH.
    LENG = WA_CONFIRM-LENGTH.
    IF MAX_LENGTH <= LENG.
      MAX_LENGTH = LENG.
    ENDIF.
  ENDLOOP.
*  IF twth >= max_width. " 7 Januari 2013
  IF TWTH > MAX_WIDTH. " 7 Januari 2013
    CLEAR ERR_TEXT.
*    ERR_TEXT = 'Tot. Lebar Slitroll >= Lebar Batch Inputan'. "#EC NOTEXT " 7 Januari 2013
    ERR_TEXT = 'Tot. Lebar Slitroll > Lebar Batch Inputan'. "#EC NOTEXT " 7 Januari 2013
    MESSAGE ERR_TEXT TYPE 'I'.
    FLAG  =  'X'.
    EXIT.
  ENDIF.
  CLEAR: WA_POS. " tambahan
  READ TABLE ITAB_POS INTO WA_POS INDEX 1." WITH KEY EXTRA > 0.
  IF SY-SUBRC = 0.
    MAX_LENGTH = MAX_LENGTH + WA_POS-EXTRA.
  ENDIF." end tambahan
  CLEAR: FLAG.
  IF CTRB = 1.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
    IF SY-SUBRC = 0.
      IF MAX_LENGTH >= WA_INBATCH-ZZLENGTH.
*      IF max_length > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
*        ERR_TEXT = 'Panjang Maksimal melebihi panjang batch 1'.
        ERR_TEXT = 'Panjang Maksimal >= panjang batch 1'.   "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.

        " Modified by William at 19.05.2022 (for T-Code ZPP001_WO_VAL)
        IF SY-TCODE = 'ZPP001_WO_VAL'.
          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              TITLEBAR              = ERR_TEXT              "#EC NOTEXT
              TEXT_QUESTION         = 'Apakah Anda yakin ingin tetap memproses? ' "#EC NOTEXT
              TEXT_BUTTON_1         = 'Ya'
              TEXT_BUTTON_2         = 'Tidak'               "#EC NOTEXT
              DEFAULT_BUTTON        = 'A'
              DISPLAY_CANCEL_BUTTON = ' '
            IMPORTING
              ANSWER                = ANS.

          IF ANS <> 1.
            FLAG  =  'X'.
            EXIT.
          ENDIF.
        ELSE.
          FLAG  =  'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF CTRB = 2.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
    IF SY-SUBRC = 0.
      IF IN_JOINT2 >= WA_INBATCH-ZZLENGTH.
*      IF in_joint2 > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
        ERR_TEXT = 'Join 1 >= panjang batch 1'.             "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        FLAG  =  'X'.
        EXIT.
      ENDIF.
    ENDIF.
    IF IN_JOINT2 >= MAX_LENGTH.
*    IF in_joint2 > max_length.
      CLEAR ERR_TEXT.
      ERR_TEXT = 'Panjang joint 1 >= panjang roll'.         "#EC NOTEXT
*******      MESSAGE I001(00) WITH ERR_TEXT.
      MESSAGE ERR_TEXT TYPE 'I'.
      FLAG  =  'X'.
      EXIT.
    ELSE.
*******      max_length = max_length - in_joint2.
      CLEAR: MX_LENGTH.
      MX_LENGTH = MAX_LENGTH - IN_JOINT2.
    ENDIF.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 2.
    IF SY-SUBRC = 0.
      IF MX_LENGTH >= WA_INBATCH-ZZLENGTH.
*      IF max_length > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
        ERR_TEXT = 'Panjang Maksimal >= batch inputan'.     "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        FLAG  =  'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ELSEIF CTRB = 3.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
    IF SY-SUBRC = 0.
      IF IN_JOINT2 >= WA_INBATCH-ZZLENGTH.
*      IF in_joint2 > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
        ERR_TEXT = 'Join 1 >= panjang batch 1'.             "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        FLAG  =  'X'.
        EXIT.
      ENDIF.
    ENDIF.
    CLEAR: JOIN.
    JOIN = IN_JOINT3 - IN_JOINT2.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 2.
    IF SY-SUBRC = 0.
      IF JOIN >= WA_INBATCH-ZZLENGTH.
*      IF join > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
        ERR_TEXT = 'Panjang Maksimal >= batch inputan'.     "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        FLAG  =  'X'.
        EXIT.
      ENDIF.
    ENDIF.
    IF IN_JOINT3 >= MAX_LENGTH.
*    IF in_joint3 > max_length.
      CLEAR ERR_TEXT.
      ERR_TEXT = 'Panjang joint 2 >= panjang roll'.         "#EC NOTEXT
*******      MESSAGE I001(00) WITH ERR_TEXT.
      MESSAGE ERR_TEXT TYPE 'I'.
      FLAG  =  'X'.
      EXIT.
    ELSE.
*******      max_length = max_length - in_joint3.
      CLEAR: MX_LENGTH.
      MX_LENGTH = MAX_LENGTH - IN_JOINT3.
    ENDIF.
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 3.
    IF SY-SUBRC = 0.
      IF MX_LENGTH >= WA_INBATCH-ZZLENGTH.
*      IF max_length > wa_inbatch-zzlength.
        CLEAR ERR_TEXT.
        ERR_TEXT = 'Panjang Maksimal >= batch inputan'.     "#EC NOTEXT
*******        MESSAGE I001(00) WITH ERR_TEXT.
        MESSAGE ERR_TEXT TYPE 'I'.
        FLAG  =  'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  IF FLAG = 'X'.
    EXIT.
  ENDIF.
  IF CTRM > CTRB.
    PERFORM DISPLAY_CONFIRM_DYN.
  ELSE.
    PERFORM DISPLAY_CONFIRM_STA.
  ENDIF.

ENDFORM.                    " POPUP_CONFIRMATION
*&---------------------------------------------------------------------*
*&      Form  GET_CHAR_BATCH_IN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHAR_BATCH_IN .

  DATA: THN(2), BLN(2), V_261 TYPE I, V_262 TYPE I.

  CLEAR: WA_INBATCH.
  LOOP AT IT_INBATCH INTO WA_INBATCH.

    SELECT SINGLE MATNR
      INTO WA_INBATCH-MATNR
      FROM MCH1
     WHERE CHARG = WA_INBATCH-CHARG.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_INBATCH-MATNR
        CHARG                    = WA_INBATCH-CHARG
*       WERKS                    =
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
               .
    IF SY-SUBRC <> 0.
*  Implement suitable error handling here
    ENDIF.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPRODLINE'.
    IF SY-SUBRC EQ 0.
      WA_INBATCH-ZZPRODLINE = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.
    CLEAR: V_ATINN, V_ATZHL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZPRODLINE'
      IMPORTING
        OUTPUT = V_ATINN.
    SELECT SINGLE ATZHL INTO V_ATZHL
      FROM CAWNT
     WHERE ATINN = V_ATINN AND ATWTB = WA_INBATCH-ZZPRODLINE.
*      %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
    IF SY-SUBRC EQ 0.
      CLEAR WA_INBATCH-ZZPRODLINE.
      SELECT SINGLE ATWRT INTO WA_INBATCH-ZZPRODLINE
        FROM CAWN
       WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
    ENDIF.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZSEQUENCENBR'.
    IF SY-SUBRC EQ 0.
      WA_INBATCH-ZZSEQUENCENBR = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.
    CLEAR: V_WIDTH.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC EQ 0.
      V_WIDTH = <FS_CHAR_OF_BATCH>-ATWTB.
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_WIDTH WITH SPACE.
      WA_INBATCH-ZZWIDTH = V_WIDTH.
    ENDIF.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZMONTHYEAR'.
    IF SY-SUBRC EQ 0.
      WA_INBATCH-ZZMONTHYEAR = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.

    CLEAR: VPOSMS, VTURMS.
    IF V_ABLAD = 'SS'.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPOSITIONMS'.
      IF SY-SUBRC EQ 0.
        WA_INBATCH-ZZPOSMS = <FS_CHAR_OF_BATCH>-ATWTB.
      ENDIF.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZDERIVATIVEMS'.
      IF SY-SUBRC EQ 0.
        WA_INBATCH-ZZTURMS = <FS_CHAR_OF_BATCH>-ATWTB.
      ENDIF.
    ENDIF.

    IF CLASS = 'ZZSRSHEET'.

      CLEAR: V_LENGTH.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZLENGTHSHT'.
      IF SY-SUBRC EQ 0.
        V_LENGTH = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTH WITH SPACE.
        WA_INBATCH-ZZLENGTH = V_LENGTH.
      ENDIF.

      CLEAR: V_CONV.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
      IF SY-SUBRC EQ 0.
        V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE 'Kg/PAC' IN V_CONV WITH SPACE.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
        CONDENSE V_CONV NO-GAPS.
        WA_INBATCH-ZZCONVERSION = V_CONV.
      ENDIF.

      CLEAR: V_NUMBEROFSHEET.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZNUMBEROFSHEET'.
      IF SY-SUBRC EQ 0.
        V_NUMBEROFSHEET = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_NUMBEROFSHEET WITH SPACE.
        WA_INBATCH-ZZNUMBEROFSHEET = V_NUMBEROFSHEET.
      ENDIF.

    ELSE.

      CLEAR: V_LENGTH.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC EQ 0.
        V_LENGTH = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTH WITH SPACE.
        WA_INBATCH-ZZLENGTH = V_LENGTH.
      ENDIF.

      CLEAR: V_CONV.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC EQ 0.
        V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE 'Kg/Rol' IN V_CONV WITH SPACE.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
        CONDENSE V_CONV NO-GAPS.
        WA_INBATCH-ZZCONVERSION = V_CONV.
      ENDIF.

    ENDIF.

*******    CLEAR: thn, bln.
*******    thn = sy-datum+2(2).
*******    bln = sy-datum+4(2).
********    IF bln < 10.
*******      REPLACE ALL OCCURRENCES OF '0' in bln WITH space.
********    ENDIF.
*******    CONDENSE bln NO-GAPS.
*******    CONCATENATE thn bln INTO wa_inbatch-zzmonthyear.

    CLEAR: V_261, V_262.
    SELECT COUNT( * )
      INTO V_261
      FROM MSEG
     WHERE CHARG = WA_INBATCH-CHARG AND BWART = '261' OR
           CHARG = WA_INBATCH-CHARG AND BWART = '901'. " Tambahan 28 January 2013
*      %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z07")'.
    SELECT COUNT( * )
      INTO V_262
      FROM MSEG
     WHERE CHARG = WA_INBATCH-CHARG AND BWART = '262' OR
           CHARG = WA_INBATCH-CHARG AND BWART = '902'. " Tambahan 28 January 2013
*      %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z07")'.
    WA_INBATCH-DERIVATIVE = ( V_261 - V_262 ) + 1.
    CONDENSE WA_INBATCH-DERIVATIVE NO-GAPS.
    IF WA_INBATCH-DERIVATIVE < 10.
      CONCATENATE '0' WA_INBATCH-DERIVATIVE INTO WA_INBATCH-DERIVATIVE.
    ENDIF.

    MODIFY IT_INBATCH FROM WA_INBATCH TRANSPORTING MATNR ZZPRODLINE ZZSEQUENCENBR ZZMONTHYEAR ZZDERIVATIVEMS
                                                   ZZDERIVATIVESS DERIVATIVE ZZWIDTH ZZLENGTH ZZCONVERSION ZZNUMBEROFSHEET
                                                   ZZPOSMS ZZTURMS.

  ENDLOOP.

ENDFORM.                    " GET_CHAR_BATCH_IN
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_CONFIRM .

  DATA: VAL_ZZPRODLINE     LIKE AUSP-ATWRT,
        VAL_ZZTYPE         LIKE AUSP-ATWRT,
        VAL_ZZCODE         LIKE AUSP-ATWRT,
        VAL_ZZSEQUENCENBR  LIKE AUSP-ATWRT,
        VAL_ZZMONTHYEAR    LIKE AUSP-ATWRT,
        VAL_ZZGRADE        LIKE AUSP-ATWRT,
        VAL_ZZDERIVATIVEMS LIKE AUSP-ATWRT,
        VAL_ZZPOSITIONMS   LIKE AUSP-ATWRT,
        VAL_ZZDERIVATIVESS LIKE AUSP-ATWRT,
        VAL_ZZPOSITIONSS   LIKE AUSP-ATWRT,
        VAL_CUOBJ_BM       LIKE MCH1-CUOBJ_BM. "Additional 14 January 2013

  CLEAR: IT_CONFIRM, WA_CONFIRM.
  REFRESH: IT_CONFIRM.

  CLEAR: V_ABLAD.
  SELECT SINGLE ABLAD
    INTO V_ABLAD
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND ABLAD IN ('SS','MS').

  LOOP AT ZBOXER.
    CLEAR: WA_MAIN.
    LOOP AT IT_MAIN WHERE AUFNR = ZBOXER-AUFNR.
      CLEAR: WA_CONFIRM.
*     Get Position - Order Number
      CONCATENATE IT_MAIN-ZPOST '-' IT_MAIN-AUFNR INTO WA_CONFIRM-POSORD SEPARATED BY SPACE.
*     Get No Roll
      CLEAR: VAL_ZZPRODLINE, VAL_ZZTYPE, VAL_ZZSEQUENCENBR, VAL_ZZMONTHYEAR, VAL_ZZGRADE,
             VAL_ZZDERIVATIVEMS, VAL_ZZPOSITIONMS, VAL_ZZDERIVATIVESS, VAL_ZZPOSITIONSS, VAL_ZZCODE.
      CLEAR: WA_INBATCH.
      SORT IT_INBATCH BY ID.
      READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
      IF SY-SUBRC = 0.
        VAL_ZZPRODLINE     = WA_INBATCH-ZZPRODLINE.
        VAL_ZZSEQUENCENBR  = WA_INBATCH-ZZSEQUENCENBR.
        VAL_ZZMONTHYEAR    = WA_INBATCH-ZZMONTHYEAR.
*        IF ZBOXER-ARBPL(1) = 'M'.
        IF V_ABLAD = 'MS'.
          CLEAR: VAL_ZZDERIVATIVEMS.
          VAL_ZZDERIVATIVEMS = WA_INBATCH-DERIVATIVE.
*        ELSEIF ZBOXER-ARBPL(1) = 'S' OR ZBOXER-ARBPL(1) = 'F'.
        ELSEIF V_ABLAD = 'SS'.
          CLEAR: VAL_ZZDERIVATIVESS.
          VAL_ZZDERIVATIVESS = WA_INBATCH-DERIVATIVE.
        ENDIF.
      ENDIF.
      CLEAR: WA_POS, VAL_CUOBJ_BM, VAL_ZZCODE.
      READ TABLE ITAB_POS INTO WA_POS WITH KEY CHARG = IT_MAIN-CHARG.
      IF SY-SUBRC = 0.
        VAL_ZZTYPE       = WA_POS-TYPE.
        "Revisi 14 January 2013
*        VAL_ZZCODE       = WA_POS-CODE.
        CLEAR: VAL_CUOBJ_BM, VAL_ZZCODE.
        SELECT SINGLE CUOBJ_BM INTO VAL_CUOBJ_BM
          FROM MCH1
         WHERE MCH1~MATNR  = WA_POS-MATNR AND MCH1~CHARG  = WA_POS-CHARG.
        IF SY-SUBRC = 0.
          CLEAR: V_ATINN, VAL_ZZCODE.
          CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
            EXPORTING
              INPUT  = 'ZZCODE'
            IMPORTING
              OUTPUT = V_ATINN.
          SELECT SINGLE ATWRT
            INTO VAL_ZZCODE
            FROM AUSP
           WHERE OBJEK = VAL_CUOBJ_BM AND ATINN = V_ATINN.
        ENDIF.
        "Revisi 14 January 2013
        VAL_ZZPOSITIONMS = WA_POS-POSMS.
        VAL_ZZPOSITIONSS = WA_POS-POSSS.
        IF VAL_ZZDERIVATIVEMS = ''.
          VAL_ZZDERIVATIVEMS = WA_POS-DERMS.
        ENDIF.
        IF VAL_ZZDERIVATIVESS = ''.
          VAL_ZZDERIVATIVESS = WA_POS-DERSS.
        ENDIF.
      ENDIF.

      IF IT_MAIN-MARKS1 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE1.
      ELSEIF IT_MAIN-MARKS2 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE2.
      ELSEIF IT_MAIN-MARKS3 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE3.
      ELSEIF IT_MAIN-MARKS4 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE4.
      ELSEIF IT_MAIN-MARKS5 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE5.
      ELSEIF IT_MAIN-MARKS6 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE6.
      ELSEIF IT_MAIN-MARKS7 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE7.
      ELSEIF IT_MAIN-MARKS8 = 'X'.
        VAL_ZZGRADE = IT_MAIN-GRADE8.
      ENDIF.

*      IF ZBOXER-ARBPL(1) = 'M'.
      IF V_ABLAD = 'MS'.
        CLEAR: VAL_ZZPOSITIONMS.
        VAL_ZZPOSITIONMS = IT_MAIN-ZPOST.
*      ELSEIF ZBOXER-ARBPL(1) = 'S' OR ZBOXER-ARBPL(1) = 'F'.
      ELSEIF V_ABLAD = 'SS'.
        CLEAR: VAL_ZZPOSITIONSS.
        VAL_ZZPOSITIONSS = IT_MAIN-ZPOST.
      ENDIF.

      CONDENSE VAL_ZZPRODLINE NO-GAPS.
      CONDENSE VAL_ZZTYPE NO-GAPS.
      CONDENSE VAL_ZZCODE NO-GAPS.
      CONDENSE VAL_ZZSEQUENCENBR NO-GAPS.
      CONDENSE VAL_ZZMONTHYEAR NO-GAPS.
      CONDENSE VAL_ZZGRADE NO-GAPS.
      CONDENSE VAL_ZZDERIVATIVEMS NO-GAPS.
      CONDENSE VAL_ZZPOSITIONMS NO-GAPS.
      CONDENSE VAL_ZZDERIVATIVESS NO-GAPS.
      CONDENSE VAL_ZZPOSITIONSS NO-GAPS.

      IT_MAIN-ZZPRODLINE     = VAL_ZZPRODLINE.
      IT_MAIN-ZZTYPE         = VAL_ZZTYPE.
      IT_MAIN-ZZCODE         = VAL_ZZCODE.
      IT_MAIN-ZZSEQUENCENBR  = VAL_ZZSEQUENCENBR.
      IT_MAIN-ZZMONTHYEAR    = VAL_ZZMONTHYEAR.
      IT_MAIN-ZZGRADE        = VAL_ZZGRADE.
      IF V_ABLAD = 'MS'.
        IF VAL_ZZDERIVATIVEMS NE SPACE.
          IT_MAIN-ZZDERIVATIVEMS = VAL_ZZDERIVATIVEMS.
        ELSE.
          VAL_ZZDERIVATIVEMS = IT_MAIN-ZZDERIVATIVEMS.
        ENDIF.
        IT_MAIN-ZZPOSITIONMS   = VAL_ZZPOSITIONMS.
        IF VAL_ZZDERIVATIVESS NE SPACE.
          IT_MAIN-ZZDERIVATIVESS = VAL_ZZDERIVATIVESS.
        ELSE.
          VAL_ZZDERIVATIVESS = IT_MAIN-ZZDERIVATIVESS.
        ENDIF.
        IT_MAIN-ZZPOSITIONSS   = VAL_ZZPOSITIONSS.
      ELSEIF V_ABLAD = 'SS'.
        VAL_ZZDERIVATIVEMS = WA_INBATCH-ZZTURMS.
        VAL_ZZPOSITIONMS   = WA_INBATCH-ZZPOSMS.
        IT_MAIN-ZZDERIVATIVEMS = VAL_ZZDERIVATIVEMS.
        IT_MAIN-ZZPOSITIONMS   = VAL_ZZPOSITIONMS.

        IF VAL_ZZDERIVATIVESS NE SPACE.
          IT_MAIN-ZZDERIVATIVESS = VAL_ZZDERIVATIVESS.
        ELSE.
          VAL_ZZDERIVATIVESS = IT_MAIN-ZZDERIVATIVESS.
        ENDIF.
        IT_MAIN-ZZPOSITIONSS   = VAL_ZZPOSITIONSS.
      ENDIF.

*      MODIFY it_main.

*      CONCATENATE VAL_ZZPRODLINE VAL_ZZTYPE VAL_ZZSEQUENCENBR VAL_ZZMONTHYEAR VAL_ZZGRADE
*      CONCATENATE VAL_ZZPRODLINE VAL_ZZTYPE VAL_ZZMONTHYEAR VAL_ZZSEQUENCENBR VAL_ZZGRADE
      CONCATENATE VAL_ZZPRODLINE VAL_ZZCODE VAL_ZZMONTHYEAR VAL_ZZSEQUENCENBR VAL_ZZGRADE
                  VAL_ZZDERIVATIVEMS VAL_ZZPOSITIONMS VAL_ZZDERIVATIVESS VAL_ZZPOSITIONSS
             INTO WA_CONFIRM-NOROLL SEPARATED BY SPACE.

      IT_MAIN-ZZNOMORROLL    = WA_CONFIRM-NOROLL.
      MODIFY IT_MAIN.

      IF CLASS = 'ZZSRSHEET'.
        WA_CONFIRM-LENGTH = IT_MAIN-ZZCASTSHEETGR.
      ELSE.
        IF IT_MAIN-LENGK NE ''.
          WA_CONFIRM-LENGTH = IT_MAIN-LENGK.
        ELSE.
          WA_CONFIRM-LENGTH = IT_MAIN-PANJANG.
          REPLACE ALL OCCURRENCES OF 'x' IN WA_CONFIRM-LENGTH WITH SPACE.
        ENDIF.
        CONDENSE WA_CONFIRM-LENGTH NO-GAPS.
      ENDIF.

      IF IT_MAIN-WIDTH > 0.
        WA_CONFIRM-WIDTH = IT_MAIN-WIDTH.
      ELSE.
        WA_CONFIRM-WIDTH = IT_MAIN-LEBAR."v_width
      ENDIF.
      CONDENSE WA_CONFIRM-WIDTH NO-GAPS.

      APPEND WA_CONFIRM TO IT_CONFIRM.

    ENDLOOP.

  ENDLOOP.

  SORT IT_CONFIRM BY POSORD.

ENDFORM.                    " GET_DATA_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CONFIRM_DYN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CONFIRM_DYN .

  IF CLASS = 'ZZSRSHEET'.
    SET PF-STATUS 'STCONF'.
    SET TITLEBAR  'TCONF'.
    WINDOW STARTING AT 30 3
             ENDING AT 140 18.
  ELSE.
    SET PF-STATUS 'STCONF'.
    SET TITLEBAR  'TCONF'.
    WINDOW STARTING AT 30 3
             ENDING AT 155 18.
  ENDIF.

*  WRITE:/1  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF.
  IF IN_RES NE SPACE.
    WRITE:/1(7)  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, (8) IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF,
            (2)  '  ',
            (16) 'Speed Machine : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_SPEED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
            (2)  '  ',
            (11) 'Resource : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_RES COLOR COL_POSITIVE INTENSIFIED OFF. "#EC NOTEXT
  ELSE.
    READ TABLE ZBOXER INDEX 1.
    IF SY-SUBRC = 0.
      WRITE:/1(7)  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, (8) IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF,
              (2)  '  ',
              (16) 'Speed Machine : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_SPEED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
              (2)  '  ',
              (11) 'Resource : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) ZBOXER-ARBPL COLOR COL_POSITIVE INTENSIFIED OFF. "#EC NOTEXT
    ENDIF.
  ENDIF.

*******  WRITE:/1(31)  sy-uline,
*******          (2)   ' ',
*******          (73)  sy-uline.

  IF CLASS = 'ZZSRSHEET'.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
            (73)  SY-ULINE.

    WRITE:/1(1) SY-VLINE, (13) 'Batch Inputan' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (11) 'Join(M) ke-' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (2)  ' ',
            (1) SY-VLINE, (18) 'No Order' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (30) 'No Roll' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (15) 'Cast Sheet GR' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
            (73)  SY-ULINE.

    LOOP AT IT_CONFIRM.
      IF SY-TABIX = 1.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG1 INPUT OFF CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) ' ',
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ELSEIF SY-TABIX = 2.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ELSEIF SY-TABIX = 3.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ELSE.
        WRITE:/1(1) ' ', (13) ' ',
                (1) ' ', (11) ' ',
                (1) ' ', (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  ' ',
                (2)   ' ',
                (73)  SY-ULINE.
      ENDIF.
    ENDLOOP.

  ELSE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
*            (73)  sy-uline.
            (88)  SY-ULINE.

    WRITE:/1(1) SY-VLINE, (13) 'Batch Inputan' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (11) 'Join(M) ke-' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (2)  ' ',
            (1) SY-VLINE, (18) 'No Order' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (30) 'No Roll' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (15) 'Panjang Actual' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (12) 'Lebar Actual' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
*            (73)  sy-uline.
            (88)  SY-ULINE.

    LOOP AT IT_CONFIRM.
      IF SY-TABIX = 1.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG1 INPUT OFF CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) ' ',
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) IT_CONFIRM-WIDTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ELSEIF SY-TABIX = 2.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) IT_CONFIRM-WIDTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ELSEIF SY-TABIX = 3.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) IT_CONFIRM-WIDTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ELSE.
        WRITE:/1(1) ' ', (13) ' ',
                (1) ' ', (11) ' ',
                (1) ' ', (2)  ' ',
                (1) SY-VLINE, (18) IT_CONFIRM-POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) IT_CONFIRM-NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) IT_CONFIRM-LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) IT_CONFIRM-WIDTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  ' ',
                (2)   ' ',
                (88)  SY-ULINE.
      ENDIF.
    ENDLOOP.

  ENDIF.
*******  WRITE:/1(31)  sy-uline,
*******          (2)   ' ',
*******          (73)  sy-uline.

ENDFORM.                    " DISPLAY_CONFIRM_DYN
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CONFIRM_STA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CONFIRM_STA .

  DATA: V_POSORD TYPE CHAR18,
        V_NOROLL TYPE CHAR30,
        V_LENGTH TYPE CHAR10,
        V_WIDTH  TYPE CHAR10,
        CNTR     TYPE I.

  IF CLASS = 'ZZSRSHEET'.
    SET PF-STATUS 'STCONF'.
    SET TITLEBAR  'TCONF'.
    WINDOW STARTING AT 30 3
             ENDING AT 140 18.
  ELSE.
    SET PF-STATUS 'STCONF'.
    SET TITLEBAR  'TCONF'.
    WINDOW STARTING AT 30 3
             ENDING AT 155 18.
  ENDIF.

*  WRITE:/1  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF.
  IF IN_RES NE SPACE.
    WRITE:/1(7)  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, (8) IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF,
            (2)  '  ',
            (16) 'Speed Machine : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_SPEED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
            (2)  '  ',
            (11) 'Resource : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_RES COLOR COL_POSITIVE INTENSIFIED OFF. "#EC NOTEXT
  ELSE.
    READ TABLE ZBOXER INDEX 1.
    IF SY-SUBRC = 0.
      WRITE:/1(7)  ' NIK : ' COLOR COL_POSITIVE INTENSIFIED OFF, (8) IN_NIK COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
              (2)  '  ',
              (16) 'Speed Machine : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) IN_SPEED COLOR COL_POSITIVE INTENSIFIED OFF, "#EC NOTEXT
              (2)  '  ',
              (11) 'Resource : ' COLOR COL_POSITIVE INTENSIFIED OFF, (10) ZBOXER-ARBPL COLOR COL_POSITIVE INTENSIFIED OFF. "#EC NOTEXT
    ENDIF.
  ENDIF.

*******  WRITE:/1(31)  sy-uline,
*******          (2)   ' ',
*******          (73)  sy-uline.

  IF CLASS = 'ZZSRSHEET'.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
            (73)  SY-ULINE.

    WRITE:/1(1) SY-VLINE, (13) 'Batch Inputan' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (11) 'Join(M) ke-' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (2)  ' ',
            (1) SY-VLINE, (18) 'No Order' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (30) 'No Roll' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (15) 'Cast Sheet GR' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
            (73)  SY-ULINE.

    CLEAR: CNTR.
    DO 3 TIMES.
      ADD 1 TO CNTR.
      IF CNTR = 1.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 1.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG1 INPUT OFF CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) ' ',
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ELSEIF CNTR = 2.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 2.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ELSEIF CNTR = 3.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 3.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (73)  SY-ULINE.
      ENDIF.

    ENDDO.

  ELSE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
*            (73)  sy-uline.
            (88)  SY-ULINE.

    WRITE:/1(1) SY-VLINE, (13) 'Batch Inputan' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (11) 'Join(M) ke-' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (2)  ' ',
            (1) SY-VLINE, (18) 'No Order' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (30) 'No Roll' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (15) 'Panjang Actual' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE, (12) 'Lebar Actual' COLOR COL_HEADING INTENSIFIED ON CENTERED, "#EC NOTEXT
            (1) SY-VLINE.

    WRITE:/1(31)  SY-ULINE,
            (2)   ' ',
*            (73)  sy-uline.
            (88)  SY-ULINE.

    CLEAR: CNTR.
    DO 3 TIMES.
      ADD 1 TO CNTR.
      IF CNTR = 1.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH, V_WIDTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 1.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
          V_WIDTH  = WA_CONFIRM-WIDTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG1 INPUT OFF CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) ' ',
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) V_WIDTH  CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ELSEIF CNTR = 2.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH, V_WIDTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 2.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
          V_WIDTH  = WA_CONFIRM-WIDTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT2 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) V_WIDTH  CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ELSEIF CNTR = 3.
        CLEAR: WA_CONFIRM, V_POSORD, V_NOROLL, V_LENGTH, V_WIDTH.
        READ TABLE IT_CONFIRM INTO WA_CONFIRM INDEX 3.
        IF SY-SUBRC = 0.
          V_POSORD = WA_CONFIRM-POSORD.
          V_NOROLL = WA_CONFIRM-NOROLL.
          V_LENGTH = WA_CONFIRM-LENGTH.
          V_WIDTH  = WA_CONFIRM-WIDTH.
        ENDIF.
        WRITE:/1(1) SY-VLINE, (13) IN_CHARG3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (11) IN_JOINT3 CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (2)  ' ',
                (1) SY-VLINE, (18) V_POSORD CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (30) V_NOROLL CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (15) V_LENGTH CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE, (12) V_WIDTH  CENTERED COLOR COL_NORMAL INTENSIFIED OFF,
                (1) SY-VLINE.
        WRITE:/1(31)  SY-ULINE,
                (2)   ' ',
                (88)  SY-ULINE.
      ENDIF.

    ENDDO.

  ENDIF.
*******  WRITE:/1(31)  sy-uline,
*******          (2)   ' ',
*******          (73)  sy-uline.

ENDFORM.                    " DISPLAY_CONFIRM_STA
*&---------------------------------------------------------------------*
*&      Form  POPUP_DIFLENGTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_DIFLENGTH CHANGING P_FLAG.

  DATA: ANS TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Different Length ??'         "#EC NOTEXT
      TEXT_QUESTION         = 'Apakah turunan ini untuk order dengan panjang bervariasi dalam satu turunan?' "#EC NOTEXT
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'                       "#EC NOTEXT
      DEFAULT_BUTTON        = 'A'
      DISPLAY_CANCEL_BUTTON = 'X'
    IMPORTING
      ANSWER                = ANS.

  IF ANS = '1'.
    LOOP AT IT_MAIN.
      IT_MAIN-DIFLENGTH = 'YA'.
      MODIFY IT_MAIN.
    ENDLOOP.
  ELSEIF ANS = '2'.
    LOOP AT IT_MAIN.
      IT_MAIN-DIFLENGTH = 'TIDAK'.
      MODIFY IT_MAIN.
    ENDLOOP.
  ELSE.
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " POPUP_DIFLENGTH
*&---------------------------------------------------------------------*
*&      Form  CEK_COM_ORDER_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_COM_ORDER_STATUS CHANGING P_FLAG.

* check document status
  PERFORM GET_ORDER_STATUS USING COM_ORDER
                           CHANGING STATUS.
  IF STATUS = 'REL'.
    IF SY-UCOMM = 'COMMIT' OR SY-UCOMM = 'YES'.
*******      MESSAGE i001(00)  WITH  'Order sudah di-release'.
      CLEAR P_FLAG.
      EXIT.
    ELSE.
*******      MESSAGE I001(00)  WITH  'Order sudah di-release'. "#EC NOTEXT
      MESSAGE 'Order sudah di-release' TYPE 'I'.            "#EC NOTEXT
      CLEAR P_FLAG.
      P_FLAG  = 'X'.
      EXIT.
    ENDIF.
  ELSEIF STATUS = 'PCNF'.
*******    MESSAGE I001(00)  WITH  'Order sudah di-start'. "#EC NOTEXT
    MESSAGE 'Order sudah di-start' TYPE 'I'.                "#EC NOTEXT
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'CNF'.
*******    MESSAGE I001(00)  WITH  'Order sudah di-stop'. "#EC NOTEXT
    MESSAGE 'Order sudah di-stop' TYPE 'I'.                 "#EC NOTEXT
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'DLV'.
*******    MESSAGE I001(00)  WITH  'Order sudah di-good receipt'. "#EC NOTEXT
    MESSAGE 'Order sudah di-good receipt' TYPE 'I'.         "#EC NOTEXT
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'PDLV'.
*******    MESSAGE I001(00)  WITH  'Order sudah di-good receipt'. "#EC NOTEXT
    MESSAGE 'Order sudah di-good receipt' TYPE 'I'.         "#EC NOTEXT
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'TECO'.
*******    MESSAGE I001(00)  WITH  'Order sudah di-TECO'. "#EC NOTEXT
    MESSAGE 'Order sudah di-TECO' TYPE 'I'.                 "#EC NOTEXT
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'CLSD'.   " add by ALF at 27-09-2013
    MESSAGE 'Order sudah di closed' TYPE 'I'.
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ELSEIF STATUS = 'VCAL'.   " add by ALF at 27-09-2013
    MESSAGE 'Order sudah Variances calculated' TYPE 'I'.
    CLEAR P_FLAG.
    P_FLAG  = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " CEK_COM_ORDER_STATUS
*&---------------------------------------------------------------------*
*&      Form  PROCESS_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_ALL .

  CLEAR: V_ABLAD.
  SELECT SINGLE ABLAD
    INTO V_ABLAD
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND ABLAD IN ('SS','MS').

  CLEAR: IT_RETURN2, IT_ORDERS, IT_LOG.
  REFRESH: IT_RETURN2, IT_ORDERS, IT_LOG.

  IT_ORDERS-ORDER_NUMBER = COM_ORDER.
  APPEND IT_ORDERS.
  CALL FUNCTION 'BAPI_PROCORD_RELEASE'
    EXPORTING
      RELEASE_CONTROL    = '1'
*     WORK_PROCESS_GROUP = 'COWORK_BAPI'
*     WORK_PROCESS_MAX   = 99
    IMPORTING
      RETURN             = IT_RETURN2
    TABLES
      ORDERS             = IT_ORDERS
*     DETAIL_RETURN      =
*     APPLICATION_LOG    =
    .
  LS_SUBRC = 0.
  IF IT_RETURN2 IS NOT INITIAL.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
      LS_SUBRC = 1.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Release Order'.                        "#EC NOTEXT
      IT_LOG-MESS = IT_RETURN2-MESSAGE.
      APPEND IT_LOG.
    ENDLOOP.
  ENDIF.

  IF LS_SUBRC = 0.
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Release Order'.                          "#EC NOTEXT
    IT_LOG-MESS = 'Success'.                                "#EC NOTEXT
    APPEND IT_LOG.
    PERFORM CHANGE_BATCH_ORIGINAL_ORDER.
  ELSE.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Change Batch'.                           "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'GR'.                                     "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
  ENDIF.

**Hilangkan Message Log Yang Sukses
  CLEAR: VMESS.
  READ TABLE IT_LOG WITH KEY ICON = '@0A@'.
  IF SY-SUBRC = 0.
    DELETE IT_LOG WHERE ICON = '@08@'.
  ELSE.
    CLEAR: IT_LOG, VMESS.
    REFRESH: IT_LOG.
    IT_LOG-ICON = '@08@'.
    CONCATENATE 'Sliting Process' COM_ORDER INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-TRNS = VMESS.
    IT_LOG-MESS = 'Success'.                                "#EC NOTEXT
    APPEND IT_LOG.
  ENDIF.
**End Hilangkan Message Log Yang Sukses

*Unlock ZTLOCK
  PERFORM UNLOCK_EZGR USING TLOCK CHANGING FLAG.
*fieldcatalogue for ALV dialog
  SET TITLEBAR  'TLOG'.
  PERFORM BUILD_FIELDCAT3.
*Layout for ALV dialog
  PERFORM BUILD_LAYOUT3.
**ALV dialog output
  I_GRID_TITLE  = 'Log Process Sliting'.                    "#EC NOTEXT
  I_SCREEN_START_COLUMN = 5."30.
  I_SCREEN_START_LINE   = 3.
  I_SCREEN_END_COLUMN   = 60."77."155.
  I_SCREEN_END_LINE     = 15."20.
  PERFORM ALV3.

  " *Add by Dila 24.10.2023
  READ TABLE IT_LOG WITH KEY ICON = '@0A@'.
  IF SY-SUBRC NE 0.
    CLEAR IT_TYCORE.
    PERFORM F_DISPLAY.
    CALL SCREEN 3000 STARTING AT 20 01.
  ENDIF. "************

ENDFORM.                    " PROCESS_ALL

*&------------------------------------------------------------*
*&      Form  build_fieldcat
*&------------------------------------------------------------*
FORM BUILD_FIELDCAT3 .
  CLEAR: LT_FIELDCATLOG3.
  REFRESH: LT_FIELDCATLOG3.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG3.
  LS_FIELDCATLOG3-ROW_POS   = '1'.
  LS_FIELDCATLOG3-COL_POS   = '1'.
  LS_FIELDCATLOG3-FIELDNAME = 'ICON'.
  LS_FIELDCATLOG3-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG3-SELTEXT_M = 'Mark'.                       "#EC NOTEXT
  APPEND LS_FIELDCATLOG3 TO LT_FIELDCATLOG3.
  CLEAR LS_FIELDCATLOG3.
  LS_FIELDCATLOG3-ROW_POS   = '1'.
  LS_FIELDCATLOG3-COL_POS   = '2'.
  LS_FIELDCATLOG3-FIELDNAME = 'TRNS'.
  LS_FIELDCATLOG3-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG3-SELTEXT_M = 'Transaction'.                "#EC NOTEXT
  APPEND LS_FIELDCATLOG3 TO LT_FIELDCATLOG3.
  CLEAR LS_FIELDCATLOG3.
  LS_FIELDCATLOG3-ROW_POS   = '1'.
  LS_FIELDCATLOG3-COL_POS   = '3'.
  LS_FIELDCATLOG3-FIELDNAME = 'MESS'.
  LS_FIELDCATLOG3-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG3-SELTEXT_M = 'Message Log'.                "#EC NOTEXT
  APPEND LS_FIELDCATLOG3 TO LT_FIELDCATLOG3.
ENDFORM.                    " build_fieldcat
*&----------------------------------------------------------*
*&      Form  build_layout
*&----------------------------------------------------------*
*Layout for ALV dialog
FORM BUILD_LAYOUT3 .
  LT_LAYOUT3-ZEBRA = 'X'.
  LT_LAYOUT3-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " build_layout
*&---------------------------------------------------------------*
*&      Form  alv
*&---------------------------------------------------------------*
*Alv dialog output.
FORM ALV3 .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = I_GRID_TITLE "'Log Process Sliting'
      I_SCREEN_START_COLUMN    = I_SCREEN_START_COLUMN "30  "5  "10
      I_SCREEN_START_LINE      = I_SCREEN_START_LINE"3   "20
      I_SCREEN_END_COLUMN      = I_SCREEN_END_COLUMN"155 "77 "60 "100
      I_SCREEN_END_LINE        = I_SCREEN_END_LINE"18  "15 "30 "40
      IS_LAYOUT                = LT_LAYOUT3
      IT_FIELDCAT              = LT_FIELDCATLOG3
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND3'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS3'
    TABLES
      T_OUTTAB                 = IT_LOG
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " alv
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS3 USING RT_EXTAB TYPE SLIS_T_EXTAB.
*  SET PF-STATUS 'STCONF' EXCLUDING 'YES'.
  SET PF-STATUS 'ZSTDPOPUP' EXCLUDING '&ONT'.
ENDFORM. "Set_pf_status
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND3 USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN 'BACKL'.
*      BREAK-POINT.
      LEAVE TO TRANSACTION 'ZPP001'.
  ENDCASE.

ENDFORM. "user_command
*&---------------------------------------------------------------------*
*&      Form  CHANGE_BATCH_ORIGINAL_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_BATCH_ORIGINAL_ORDER .

  CLEAR: FLAG.
  LOOP AT ZBOXER.

    LOOP AT IT_MAIN WHERE AUFNR = ZBOXER-AUFNR.

      CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

      CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
        EXPORTING
          I_MATNR      = ZBOXER-MATNR
*         I_WERKS      = IT_ORDERDATA3-PLANT
          I_CHARG      = IT_MAIN-CHARG
          I_MARA_LEVEL = 'X'
        IMPORTING
          E_CLASS      = VCLASS
          E_KLART      = VKLART
          E_OBTAB      = VOBTAB
          E_OBJEC      = VOBJEC.

      CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
      REFRESH: CHAR_OF_BATCH.

      PERFORM VB_INIT.

      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          MATNR                    = ZBOXER-MATNR
          CHARG                    = IT_MAIN-CHARG
*          WERKS                    = wa_afpo-pwerk
          GET_CLASSIFICATION       = 'X'
*         EXISTENCE_CHECK          =
*         READ_FROM_BUFFER         =
*         NO_CLASS_INIT            = ' '
*         LOCK_BATCH               = ' '
*       IMPORTING
*         YMCHA                    =
*         CLASSNAME                =
        TABLES
          CHAR_OF_BATCH            = CHAR_OF_BATCH
        EXCEPTIONS
          NO_MATERIAL              = 1
          NO_BATCH                 = 2
          NO_PLANT                 = 3
          MATERIAL_NOT_FOUND       = 4
          PLANT_NOT_FOUND          = 5
          NO_AUTHORITY             = 6
          BATCH_NOT_EXIST          = 7
          LOCK_ON_BATCH            = 8
          OTHERS                   = 9
                .
      IF SY-SUBRC <> 0.
*Implement suitable error handling here
      ENDIF.

      CLEAR: IT_CHAR.
      REFRESH: IT_CHAR.
      LOOP AT CHAR_OF_BATCH.
        IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
        IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
        APPEND IT_CHAR.
      ENDLOOP.
*     Set ZZLENGTH
      CLEAR: V_LENGTH.
      IF CLASS = 'ZZSRSHEET'.

        IF ZBOXER-VBELN1 NE SPACE OR "zboxer-vbeln1 NE '0000000000' or
           ZBOXER-VBELN2 NE SPACE OR "zboxer-vbeln2 NE '0000000000' or
           ZBOXER-VBELN3 NE SPACE OR "zboxer-vbeln3 NE '0000000000' or
           ZBOXER-VBELN4 NE SPACE ."OR zboxer-vbeln4 NE '0000000000'.
          CLEAR: WA_POS.
          READ TABLE ITAB_POS INTO WA_POS WITH KEY CHARG = IT_MAIN-CHARG.
          IF SY-SUBRC EQ 0.
            IF IT_MAIN-LENGK NE SPACE.
              V_LENGTH  = IT_MAIN-LENGK.
            ELSE.
              V_LENGTH  = WA_POS-LENG.
            ENDIF.
          ENDIF.
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR = V_LENGTH.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
            IT_CHAR-VALUE_CHAR = V_LENGTH.
            APPEND IT_CHAR.
          ENDIF.
          CLEAR: IT_MAIN-LENGTH_GR." Tambahan Buat ZPP016N
          IT_MAIN-LENGTH_GR = V_LENGTH. " Tambahan Buat ZPP016N
          MODIFY IT_MAIN." Tambahan Buat ZPP016N
        ELSE.
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
            LS_SUBRC = 1.
            IF IT_MAIN-LENGK NE SPACE.
              WA_CHAR2-VALUE_CHAR  = IT_MAIN-LENGK.
            ELSE.
              WA_CHAR2-VALUE_CHAR  = IT_MAIN-V_LENGTH.
            ENDIF.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
*            IT_CHAR-VALUE_CHAR = IT_MAIN-V_LENGTH.
            IF IT_MAIN-LENGK NE SPACE.
              IT_CHAR-VALUE_CHAR  = IT_MAIN-LENGK.
            ELSE.
              IT_CHAR-VALUE_CHAR  = IT_MAIN-V_LENGTH.
            ENDIF.
            APPEND IT_CHAR.
          ENDIF.
          CLEAR: IT_MAIN-LENGTH_GR." Tambahan Buat ZPP016N
*          IT_MAIN-LENGTH_GR = IT_MAIN-V_LENGTH. " Tambahan Buat ZPP016N
          IF IT_MAIN-LENGK NE SPACE.
            IT_MAIN-LENGTH_GR  = IT_MAIN-LENGK.
          ELSE.
            IT_MAIN-LENGTH_GR  = IT_MAIN-V_LENGTH.
          ENDIF.
          MODIFY IT_MAIN." Tambahan Buat ZPP016N
        ENDIF.

      ELSE.
        " 4 February 2013
*******        IF ZBOXER-VBELN1 NE SPACE OR "zboxer-vbeln1 NE '0000000000' or
*******           ZBOXER-VBELN2 NE SPACE OR "zboxer-vbeln2 NE '0000000000' or
*******           ZBOXER-VBELN3 NE SPACE OR "zboxer-vbeln3 NE '0000000000' or
*******           ZBOXER-VBELN4 NE SPACE ."OR zboxer-vbeln4 NE '0000000000'.
        CLEAR: WA_POS.
        READ TABLE ITAB_POS INTO WA_POS WITH KEY CHARG = IT_MAIN-CHARG.
        IF SY-SUBRC EQ 0.
*            IF it_main-lengk ne space.
          IF IT_MAIN-LENGK NE SPACE.
            IF IT_MAIN-MARKS1 = '' AND IT_MAIN-MARKS2 = '' AND
               IT_MAIN-MARKS3 = '' AND IT_MAIN-MARKS4 = '' AND
               IT_MAIN-MARKS6 = ''. "02.01.2013 Kata yan, free stock jg ga dijumlah extralength
              V_LENGTH  = IT_MAIN-LENGK + WA_POS-EXTRA.
*  ***          Set ZZEXLENGTH = 0
              CLEAR: WA_CHAR2, LS_SUBRC.
              LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
                WA_CHAR2-VALUE_CHAR = 0.
                MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
              ENDLOOP.
            ELSE.
              V_LENGTH  = IT_MAIN-LENGK.
            ENDIF.
          ELSE.
            IF IT_MAIN-MARKS1 = '' AND IT_MAIN-MARKS2 = '' AND
               IT_MAIN-MARKS3 = '' AND IT_MAIN-MARKS4 = '' AND
               IT_MAIN-MARKS6 = ''. "02.01.2013 Kata yan, free stock jg ga dijumlah extralength
              V_LENGTH  = WA_POS-LENG + WA_POS-EXTRA.
*  ***          Set ZZEXLENGTH = 0
              CLEAR: WA_CHAR2, LS_SUBRC.
              LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
                WA_CHAR2-VALUE_CHAR = 0.
                MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
              ENDLOOP.
            ELSE.
              V_LENGTH  = WA_POS-LENG.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR = V_LENGTH.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZLENGTH'.
          IT_CHAR-VALUE_CHAR = V_LENGTH.
          APPEND IT_CHAR.
        ENDIF.
        CLEAR: IT_MAIN-LENGTH_GR." Tambahan Buat ZPP016N
        IT_MAIN-LENGTH_GR = V_LENGTH. " Tambahan Buat ZPP016N
        MODIFY IT_MAIN." Tambahan Buat ZPP016N
*******        ELSE.
*******          CLEAR: WA_CHAR2, LS_SUBRC.
*******          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
*******            LS_SUBRC = 1.
*******            IF IT_MAIN-LENGK NE SPACE.
*******              WA_CHAR2-VALUE_CHAR  = IT_MAIN-LENGK.
*******            ELSE.
*******              WA_CHAR2-VALUE_CHAR  = IT_MAIN-V_LENGTH.
*******            ENDIF.
*******            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
*******          ENDLOOP.
*******          IF LS_SUBRC = 0.
*******            IT_CHAR-CHARACT    = 'ZZLENGTH'.
********            IT_CHAR-VALUE_CHAR = IT_MAIN-V_LENGTH. " 10 January 2013
********            APPEND IT_CHAR.
*******            IF IT_MAIN-LENGK NE SPACE.
*******              IT_CHAR-VALUE_CHAR  = IT_MAIN-LENGK.
*******            ELSE.
*******              IT_CHAR-VALUE_CHAR  = IT_MAIN-V_LENGTH.
*******            ENDIF.
*******            APPEND IT_CHAR.
*******          ENDIF.
*******          CLEAR: IT_MAIN-LENGTH_GR." Tambahan Buat ZPP016N
********          IT_MAIN-LENGTH_GR = IT_MAIN-V_LENGTH. " Tambahan Buat ZPP016N
*******          IF IT_MAIN-LENGK NE SPACE.
*******            IT_MAIN-LENGTH_GR  = IT_MAIN-LENGK.
*******          ELSE.
*******            IT_MAIN-LENGTH_GR  = IT_MAIN-V_LENGTH.
*******          ENDIF.
*******          MODIFY IT_MAIN." Tambahan Buat ZPP016N
*******        ENDIF.

      ENDIF.
*     Set ZZWIDTH
      IF IT_MAIN-WIDTH NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-WIDTH.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
      ELSE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-V_WIDTH.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
      ENDIF.
*     Set ZZGRADE
      CLEAR: V_GRADE.
      IF IT_MAIN-MARKS1 = 'X'.
        V_GRADE = IT_MAIN-GRADE1.
      ELSEIF IT_MAIN-MARKS2 = 'X'.
        V_GRADE = IT_MAIN-GRADE2.
      ELSEIF IT_MAIN-MARKS3 = 'X'.
        V_GRADE = IT_MAIN-GRADE3.
      ELSEIF IT_MAIN-MARKS4 = 'X'.
        V_GRADE = IT_MAIN-GRADE4.
      ELSEIF IT_MAIN-MARKS5 = 'X'.
        V_GRADE = IT_MAIN-GRADE5.
      ELSEIF IT_MAIN-MARKS6 = 'X'.
        V_GRADE = IT_MAIN-GRADE6.
      ELSEIF IT_MAIN-MARKS7 = 'X'.
        V_GRADE = IT_MAIN-GRADE7.
      ELSEIF IT_MAIN-MARKS8 = 'X'.
        V_GRADE = IT_MAIN-GRADE8.
      ENDIF.
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZGRADE'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR  = V_GRADE.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZGRADE'.
        IT_CHAR-VALUE_CHAR = V_GRADE.
        APPEND IT_CHAR.
      ENDIF.
      CLEAR: IT_MAIN-GRADE_GR, IT_MAIN-CRIT_GR, WA_GRADE." Tambahan Buat ZPP016N
      IT_MAIN-GRADE_GR = V_GRADE." Tambahan Buat ZPP016N
      READ TABLE ITAB_GRADE_CRITERIA INTO WA_GRADE WITH KEY GRADE = V_GRADE." Tambahan Buat ZPP016N
      IF SY-SUBRC = 0." Tambahan Buat ZPP016N
        IT_MAIN-CRIT_GR = WA_GRADE-CRITERIA." Tambahan Buat ZPP016N
        "02.01.2013
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCRITERIA'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = WA_GRADE-CRITERIA.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZCRITERIA'.
          IT_CHAR-VALUE_CHAR = WA_GRADE-CRITERIA.
          APPEND IT_CHAR.
        ENDIF.
        "02.01.2013
      ENDIF." Tambahan Buat ZPP016N
      MODIFY IT_MAIN." Tambahan Buat ZPP016N

*******Tambahan ZZNUMBEROFROLL 02.01.2013
*      CLEAR: WA_CHAR2, LS_SUBRC.
*      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZNUMBEROFROLL'.
*        LS_SUBRC = 1.
*        WA_CHAR2-VALUE_CHAR  = '1 ROL'.
*        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
*      ENDLOOP.
*      IF LS_SUBRC = 0.
*        IT_CHAR-CHARACT    = 'ZZNUMBEROFROLL'.
*        IT_CHAR-VALUE_CHAR = '1 ROL'.
*        APPEND IT_CHAR.
*      ENDIF.
*******End Tambahan ZZNUMBEROFROLL 02.01.2013

*     Set ZZSPLICE-1(Joint 1)
      IF IT_MAIN-JOINT1 NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-1'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-JOINT1.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-1'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-JOINT1.
          APPEND IT_CHAR.
        ENDIF.
      ELSE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-1'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = ''.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-1'.
          IT_CHAR-VALUE_CHAR = ''.
          APPEND IT_CHAR.
        ENDIF.
      ENDIF.
*     Set ZZSPLICE-2(Joint 2)
      IF IT_MAIN-JOINT2 NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-2'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-JOINT2.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-2'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-JOINT2.
          APPEND IT_CHAR.
        ENDIF.
      ELSE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-2'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = ''.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-2'.
          IT_CHAR-VALUE_CHAR = ''.
          APPEND IT_CHAR.
        ENDIF.
      ENDIF.
*     Set ZZSPLICE-3(Joint 3)
      IF IT_MAIN-JOINT3 NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-3'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-JOINT3.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-3'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-JOINT3.
          APPEND IT_CHAR.
        ENDIF.
      ELSE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-3'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = ''.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZSPLICE-3'.
          IT_CHAR-VALUE_CHAR = ''.
          APPEND IT_CHAR.
        ENDIF.
      ENDIF.
*     Set ZZDERIVATIVEMS
      IF IT_MAIN-ZZDERIVATIVEMS NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZDERIVATIVEMS'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZDERIVATIVEMS.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZDERIVATIVEMS'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-ZZDERIVATIVEMS.
          APPEND IT_CHAR.
        ENDIF.
      ENDIF.
*     Set ZZDERIVATIVESS
      IF IT_MAIN-ZZDERIVATIVESS NE SPACE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZDERIVATIVESS'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZDERIVATIVESS.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZDERIVATIVESS'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-ZZDERIVATIVESS.
          APPEND IT_CHAR.
        ENDIF.
********Additional kalau SS, isi ZZDERIVATIVEMS berdasarkan batch inputan 1
        CLEAR: WA_INBATCH.
        READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
        IF SY-SUBRC = 0.
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZDERIVATIVEMS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_INBATCH-ZZTURMS.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZDERIVATIVEMS'.
            IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZTURMS.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
********End Additional kalau SS, isi ZZDERIVATIVEMS berdasarkan batch inputan 1
      ENDIF.
*     Set ZZMONTHYEAR
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZMONTHYEAR'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZMONTHYEAR.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZMONTHYEAR'.
        IT_CHAR-VALUE_CHAR = IT_MAIN-ZZMONTHYEAR.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZSEQUENCENBR
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSEQUENCENBR'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZSEQUENCENBR.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZSEQUENCENBR'.
        IT_CHAR-VALUE_CHAR = IT_MAIN-ZZSEQUENCENBR.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZPRODLINE
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPRODLINE'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZPRODLINE.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZPRODLINE'.
        IT_CHAR-VALUE_CHAR = IT_MAIN-ZZPRODLINE.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZNOMORROLL
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZNOMORROLL'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZNOMORROLL.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZNOMORROLL'.
        IT_CHAR-VALUE_CHAR = IT_MAIN-ZZNOMORROLL.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZEXTRALENGTHASAL
      IF CLASS NE 'ZZSRSHEET'.
        CLEAR: WA_POS.
        READ TABLE ITAB_POS INTO WA_POS WITH KEY CHARG = IT_MAIN-CHARG.
        IF SY-SUBRC = 0.
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXTRALENGTHASAL'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_POS-EXTRA.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZEXTRALENGTHASAL'.
            IT_CHAR-VALUE_CHAR = WA_POS-EXTRA.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZNUMBEROFSHEET'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZZCASTSHEETGR.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZNUMBEROFSHEET'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-ZZCASTSHEETGR.
          APPEND IT_CHAR.
        ENDIF.
      ENDIF.

*     Set POSISI
*      IF zboxer-arbpl+0(1) = 'M'.
      IF V_ABLAD = 'MS'.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPOSITIONMS'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZPOST.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZPOSITIONMS'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-ZPOST.
          APPEND IT_CHAR.
        ENDIF.
*      ELSEIF zboxer-arbpl+0(1) = 'S' or zboxer-arbpl+0(1) = 'F'.
      ELSEIF V_ABLAD = 'SS'.
        CLEAR: WA_CHAR2, LS_SUBRC.
        LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPOSITIONSS'.
          LS_SUBRC = 1.
          WA_CHAR2-VALUE_CHAR  = IT_MAIN-ZPOST.
          MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
        ENDLOOP.
        IF LS_SUBRC = 0.
          IT_CHAR-CHARACT    = 'ZZPOSITIONSS'.
          IT_CHAR-VALUE_CHAR = IT_MAIN-ZPOST.
          APPEND IT_CHAR.
        ENDIF.
********Additional kalau SS, isi ZZPOSITIONMS berdasarkan batch inputan 1
        CLEAR: WA_INBATCH.
        READ TABLE IT_INBATCH INTO WA_INBATCH INDEX 1.
        IF SY-SUBRC = 0.
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPOSITIONMS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_INBATCH-ZZPOSMS.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPOSITIONMS'.
            IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZPOSMS.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
********End Additional kalau SS, isi ZZPOSITIONMS berdasarkan batch inputan 1
      ENDIF.


******Set Characteristic For SO Default & SO To SO
      IF IT_MAIN-MARKS1 = 'X'.
        CLEAR: WA_ORDER.
        READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER1-VBELN = ZBOXER-VBELN1
                                                  V_ORDER1-POSNR = ZBOXER-POSNR1.
        IF SY-SUBRC = 0.
**********Set ZZCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR17.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR17.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZTREATMENT
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZTREATMENT'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR18.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZTREATMENT'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR18.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZCRITERIA
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCRITERIA'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR11.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCRITERIA'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR11.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZALIAS
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZALIAS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR13.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZALIAS'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR13.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZLABEL
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLABEL'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR19.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLABEL'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR19.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKING
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKING'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR20.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKING'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR20.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-1
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-1'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR21.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-1'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR21.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-2
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-2'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR22.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-2'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR22.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-3
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-3'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR23.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-3'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR23.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKINGCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKINGCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER1-CHAR24.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKINGCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER1-CHAR24.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
      ELSEIF IT_MAIN-MARKS2 = 'X'.
        CLEAR: WA_ORDER.
        READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER2-VBELN = ZBOXER-VBELN2
                                                  V_ORDER2-POSNR = ZBOXER-POSNR2.
        IF SY-SUBRC = 0.
**********Set ZZCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR17.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR17.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZTREATMENT
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZTREATMENT'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR18.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZTREATMENT'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR18.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZCRITERIA
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCRITERIA'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR11.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCRITERIA'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR11.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZALIAS
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZALIAS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR13.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZALIAS'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR13.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZLABEL
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLABEL'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR19.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLABEL'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR19.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKING
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKING'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR20.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKING'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR20.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-1
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-1'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR21.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-1'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR21.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-2
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-2'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR22.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-2'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR22.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-3
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-3'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR23.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-3'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR23.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKINGCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKINGCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER2-CHAR24.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKINGCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER2-CHAR24.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
      ELSEIF IT_MAIN-MARKS3 = 'X'.
        CLEAR: WA_ORDER.
        READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER3-VBELN = ZBOXER-VBELN3
                                                  V_ORDER3-POSNR = ZBOXER-POSNR3.
        IF SY-SUBRC = 0.
**********Set ZZCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR17.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR17.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZTREATMENT
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZTREATMENT'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR18.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZTREATMENT'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR18.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZCRITERIA
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCRITERIA'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR11.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCRITERIA'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR11.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZALIAS
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZALIAS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR13.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZALIAS'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR13.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZLABEL
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLABEL'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR19.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLABEL'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR19.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKING
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKING'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR20.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKING'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR20.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-1
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-1'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR21.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-1'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR21.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-2
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-2'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR22.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-2'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR22.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-3
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-3'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR23.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-3'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR23.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKINGCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKINGCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER3-CHAR24.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKINGCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER3-CHAR24.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
      ELSEIF IT_MAIN-MARKS4 = 'X'.
        CLEAR: WA_ORDER.
        READ TABLE V_ORDER INTO WA_ORDER WITH KEY V_ORDER4-VBELN = ZBOXER-VBELN4
                                                  V_ORDER4-POSNR = ZBOXER-POSNR4.
        IF SY-SUBRC = 0.
**********Set ZZCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR17.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR17.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZTREATMENT
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZTREATMENT'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR18.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZTREATMENT'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR18.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZCRITERIA
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZCRITERIA'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR11.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZCRITERIA'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR11.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZALIAS
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZALIAS'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR13.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZALIAS'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR13.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZLABEL
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLABEL'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR19.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZLABEL'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR19.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKING
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKING'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR20.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKING'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR20.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-1
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-1'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR21.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-1'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR21.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-2
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-2'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR22.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-2'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR22.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZSPECIALTOUCH-3
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPECIALTOUCH-3'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR23.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZSPECIALTOUCH-3'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR23.
            APPEND IT_CHAR.
          ENDIF.
**********Set ZZPACKINGCODE
          CLEAR: WA_CHAR2, LS_SUBRC.
          LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZPACKINGCODE'.
            LS_SUBRC = 1.
            WA_CHAR2-VALUE_CHAR  = WA_ORDER-V_ORDER4-CHAR24.
            MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
          ENDLOOP.
          IF LS_SUBRC = 0.
            IT_CHAR-CHARACT    = 'ZZPACKINGCODE'.
            IT_CHAR-VALUE_CHAR = WA_ORDER-V_ORDER4-CHAR24.
            APPEND IT_CHAR.
          ENDIF.
        ENDIF.
      ENDIF.
******End Set Characteristic For SO To SO

      CLEAR: IT_RETURN2.
      REFRESH: IT_RETURN2.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE'
        EXPORTING
          OBJECTKEY          = VOBJEC
          OBJECTTABLE        = VOBTAB
          CLASSNUM           = VCLASS
          CLASSTYPE          = VKLART
        TABLES
          ALLOCVALUESNUMNEW  = IT_NUM
          ALLOCVALUESCHARNEW = IT_CHAR
          ALLOCVALUESCURRNEW = IT_CURR
          RETURN             = IT_RETURN2.
      LS_SUBRC = 0.
      CLEAR: VMESS, FLAG.
      LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
*        IF it_return2-type = 'E' and ls_subrc = 0.
        CLEAR: VMESS.
        CONCATENATE IT_MAIN-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
        LS_SUBRC = 1.
        FLAG = 'X'.
        IT_LOG-ICON = '@0A@'.
        IT_LOG-TRNS = 'Change Batch'.                       "#EC NOTEXT
        IT_LOG-MESS = VMESS.
        APPEND IT_LOG.
*        ENDIF.
      ENDLOOP.

      CLEAR: SY-SUBRC.

      IF LS_SUBRC = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        CLEAR: VMESS.
        CONCATENATE IT_MAIN-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
        IT_LOG-ICON = '@08@'.
        IT_LOG-TRNS = 'Change Batch'.                       "#EC NOTEXT
        IT_LOG-MESS = VMESS.
        APPEND IT_LOG.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

  IF FLAG = SPACE.
    PERFORM GR.
  ELSE.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'GR'.                                     "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " CHANGE_BATCH_ORIGINAL_ORDER
*&---------------------------------------------------------------------*
*&      Form  GR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GR .

  CLEAR: GMHEAD, GMCODE, MTHEAD, ITAB, ERRMSG,
         GMHEAD_SOTOSO, GMCODE_SOTOSO, MTHEAD_SOTOSO, ITAB_SOTOSO, ERRMSG_SOTOSO,
         GMHEAD_SOTOUN, GMCODE_SOTOUN, MTHEAD_SOTOUN, ITAB_SOTOUN, ERRMSG_SOTOUN,
         V_MBLNR, V_MJAHR, TOT_GR, R_MBLNR, R_MJAHR, S_MBLNR, S_MJAHR, U_MBLNR,
         U_MJAHR.
  REFRESH: ITAB, ERRMSG, ITAB_SOTOSO, ERRMSG_SOTOSO, ITAB_SOTOUN, ERRMSG_SOTOUN.

  GMHEAD-PSTNG_DATE = SY-DATUM.
  GMHEAD-DOC_DATE   = SY-DATUM.
  GMHEAD-PR_UNAME   = SY-UNAME.
  GMHEAD-HEADER_TXT = COM_ORDER.
  GMCODE-GM_CODE    = '02'.

  GMHEAD_SOTOSO = GMHEAD.
  GMCODE_SOTOSO-GM_CODE    = '04'.
  GMHEAD_SOTOUN = GMHEAD.
  GMCODE_SOTOUN-GM_CODE    = '04'.

**Additional 8 January 2013 Untuk Case original order tick Scrap semua
  DATA: SCRAPALL.
  CLEAR: WA_MAIN, SCRAPALL.
  SCRAPALL = 'X'.
  LOOP AT IT_MAIN INTO WA_MAIN WHERE MARKS1 = 'X' OR MARKS2 = 'X' OR MARKS3 = 'X' OR MARKS4 = 'X' OR
                                     MARKS5 = 'X' OR MARKS6 = 'X' OR MARKS7 = 'X'.
    CLEAR: SCRAPALL.
    EXIT.
  ENDLOOP.
**End Additional 8 January 2013 Untuk Case original order tick Scrap semua

  IF SCRAPALL = ''. " 8 January 2013

    CLEAR: WA_MAIN.
    LOOP AT IT_MAIN INTO WA_MAIN WHERE MARKS8 = ''.

      ITAB-MOVE_TYPE = '101'.
      ITAB-MVT_IND   = 'F'.

      SELECT SINGLE MATNR DWERK LGORT INTO (ITAB-MATERIAL, ITAB-PLANT, ITAB-STGE_LOC)
        FROM AFPO
       WHERE AUFNR = WA_MAIN-AUFNR.

      ITAB-BATCH     = WA_MAIN-CHARG.
      ITAB-ORDERID   = WA_MAIN-AUFNR.

      WA_MAIN-STGE_LOC = ITAB-STGE_LOC.
      MODIFY IT_MAIN FROM WA_MAIN TRANSPORTING STGE_LOC.

      CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH, V_CONV.
      REFRESH: CHAR_OF_BATCH.

      PERFORM VB_INIT.

      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          MATNR                    = ITAB-MATERIAL
          CHARG                    = WA_MAIN-CHARG
*          WERKS                    = V_WERKS "<fs_pos>-werks
          GET_CLASSIFICATION       = 'X'
*         EXISTENCE_CHECK          =
*         READ_FROM_BUFFER         =
*         NO_CLASS_INIT            = ' '
*         LOCK_BATCH               = ' '
*       IMPORTING
*         YMCHA                    =
*         CLASSNAME                =
        TABLES
          CHAR_OF_BATCH            = CHAR_OF_BATCH
        EXCEPTIONS
          NO_MATERIAL              = 1
          NO_BATCH                 = 2
          NO_PLANT                 = 3
          MATERIAL_NOT_FOUND       = 4
          PLANT_NOT_FOUND          = 5
          NO_AUTHORITY             = 6
          BATCH_NOT_EXIST          = 7
          LOCK_ON_BATCH            = 8
          OTHERS                   = 9
                .
      IF SY-SUBRC <> 0.
*    Implement suitable error handling here
      ENDIF.

      IF CLASS = 'ZZSRSHEET'.

        READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
        IF SY-SUBRC EQ 0.
          V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
          REPLACE 'Kg/PAC' IN V_CONV WITH SPACE.
          REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
          CONDENSE V_CONV NO-GAPS.
        ENDIF.

      ELSE.

        READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
        IF SY-SUBRC EQ 0.
          V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
          REPLACE 'Kg/Rol' IN V_CONV WITH SPACE.
          REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
          CONDENSE V_CONV NO-GAPS.
        ENDIF.

      ENDIF.

      ITAB-ENTRY_QNT = V_CONV.

      SELECT SINGLE MEINS INTO ITAB-ENTRY_UOM
        FROM MARA
       WHERE MATNR = ITAB-MATERIAL.

      CLEAR VMESS.
      VMESS = WA_MAIN-LENGTH_GR.
      CONDENSE VMESS NO-GAPS.
      CONCATENATE VMESS '/' WA_MAIN-GRADE_GR '/' WA_MAIN-CRIT_GR INTO ITAB-UNLOAD_PT." Tambahan Buat ZPP016N
      CONDENSE ITAB-UNLOAD_PT NO-GAPS.
*      ITAB-UNLOAD_PT = WA_MAIN-LENGTH_GR. " Tambahan Buat ZPP016N

      APPEND ITAB.

      CLEAR: WA_BOXER.
      READ TABLE ZBOXER INTO WA_BOXER WITH KEY AUFNR = WA_MAIN-AUFNR.
      CHECK SY-SUBRC = 0.
      CHECK WA_BOXER-VBELN1 NE SPACE AND WA_BOXER-POSNR1 NE '000000'.
      IF WA_MAIN-MARKS2 = 'X' OR WA_MAIN-MARKS3 = 'X' OR WA_MAIN-MARKS4 = 'X'.

        ITAB_SOTOSO-MOVE_TYPE      = '413'.
        ITAB_SOTOSO-SPEC_STOCK     = 'E'.
        ITAB_SOTOSO-MATERIAL       = ITAB-MATERIAL.
        ITAB_SOTOSO-PLANT          = ITAB-PLANT.
        ITAB_SOTOSO-STGE_LOC       = ITAB-STGE_LOC.
        ITAB_SOTOSO-BATCH          = ITAB-BATCH.
        ITAB_SOTOSO-ORDERID        = ITAB-ORDERID.
        ITAB_SOTOSO-ENTRY_QNT      = ITAB-ENTRY_QNT.
        ITAB_SOTOSO-ENTRY_UOM      = ITAB-ENTRY_UOM.
        ITAB_SOTOSO-MOVE_STLOC     = ITAB-STGE_LOC.
        ITAB_SOTOSO-VAL_SALES_ORD  = WA_BOXER-VBELN1.
        ITAB_SOTOSO-VAL_S_ORD_ITEM = WA_BOXER-POSNR1.
        IF WA_MAIN-MARKS2 = 'X'.
          ITAB_SOTOSO-SALES_ORD  = WA_BOXER-VBELN2.
          ITAB_SOTOSO-S_ORD_ITEM = WA_BOXER-POSNR2.
        ELSEIF WA_MAIN-MARKS3 = 'X'.
          ITAB_SOTOSO-SALES_ORD  = WA_BOXER-VBELN3.
          ITAB_SOTOSO-S_ORD_ITEM = WA_BOXER-POSNR3.
        ELSEIF WA_MAIN-MARKS4 = 'X'.
          ITAB_SOTOSO-SALES_ORD  = WA_BOXER-VBELN4.
          ITAB_SOTOSO-S_ORD_ITEM = WA_BOXER-POSNR4.
        ENDIF.
        APPEND ITAB_SOTOSO.

      ELSEIF WA_MAIN-MARKS5 = 'X' OR WA_MAIN-MARKS6 = 'X' OR WA_MAIN-MARKS7 = 'X'.

        ITAB_SOTOUN-MOVE_TYPE      = '411'."'311'.
        ITAB_SOTOUN-SPEC_STOCK     = 'E'.
*        itab_sotoun-mvt_ind        = 'F'.
        ITAB_SOTOUN-MATERIAL       = ITAB-MATERIAL.
        ITAB_SOTOUN-PLANT          = ITAB-PLANT.
        ITAB_SOTOUN-STGE_LOC       = ITAB-STGE_LOC.
        ITAB_SOTOUN-BATCH          = ITAB-BATCH.
        ITAB_SOTOUN-ORDERID        = ITAB-ORDERID.
        ITAB_SOTOUN-ENTRY_QNT      = ITAB-ENTRY_QNT.
        ITAB_SOTOUN-ENTRY_UOM      = ITAB-ENTRY_UOM.
        ITAB_SOTOUN-MOVE_STLOC     = ITAB-STGE_LOC.
        ITAB_SOTOUN-VAL_SALES_ORD  = WA_BOXER-VBELN1.
        ITAB_SOTOUN-VAL_S_ORD_ITEM = WA_BOXER-POSNR1.
        ITAB_SOTOUN-ITEM_TEXT      = 'UNREST'.
        APPEND ITAB_SOTOUN.

      ENDIF.

    ENDLOOP.

  ENDIF.

  CLEAR: FLAG.
  LOOP AT ITAB WHERE ENTRY_QNT EQ SPACE.
    FLAG = 'X'.
  ENDLOOP.

  IF FLAG = ''.

    IF SCRAPALL = ''. " 8 January 2013

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER       = GMHEAD
          GOODSMVT_CODE         = GMCODE
*         TESTRUN               = ' '
        IMPORTING
          GOODSMVT_HEADRET      = MTHEAD
*         MATERIALDOCUMENT      =
*         MATDOCUMENTYEAR       =
        TABLES
          GOODSMVT_ITEM         = ITAB
*         GOODSMVT_SERIALNUMBER =
          RETURN                = ERRMSG.

      CLEAR: FLAG, VMESS, V_MBLNR, V_MJAHR, TOT_GR.
      LS_SUBRC = 0.
      LOOP AT ERRMSG WHERE TYPE = 'E'.
        LS_SUBRC = 1.
        FLAG = 'X'.
        IT_LOG-ICON = '@0A@'.
        IT_LOG-TRNS = 'Goods Receipt'.                      "#EC NOTEXT
        IT_LOG-MESS = ERRMSG-MESSAGE.
        APPEND IT_LOG.
      ENDLOOP.

      CLEAR: SY-SUBRC.

      IF LS_SUBRC = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        CLEAR: VMESS.
        CONCATENATE 'No.Mat.Doc :' MTHEAD+0(10) '--' 'Fiscal Year' MTHEAD+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
        V_MBLNR = MTHEAD+0(10).
        V_MJAHR = MTHEAD+10(4).
        R_MBLNR = MTHEAD+0(10).
        R_MJAHR = MTHEAD+10(4).
        IT_LOG-ICON = '@08@'.
        IT_LOG-TRNS = 'Goods Receipt'.                      "#EC NOTEXT
        IT_LOG-MESS = VMESS."'Success'.
        APPEND IT_LOG.
      ENDIF.

    ENDIF.

    IF FLAG = SPACE.
      IF ITAB_SOTOSO IS NOT INITIAL AND ITAB_SOTOUN IS NOT INITIAL.
        CLEAR: FLAG.
        PERFORM SOTOSO CHANGING FLAG.
        IF FLAG = ''.
          PERFORM SOTOUN CHANGING FLAG.
          IF FLAG = ''.
*              PERFORM CONFIRMATION.
            PERFORM CHANGE_BATCH_INPUTAN.
          ELSE.
            IT_LOG-ICON = '@0A@'.
            IT_LOG-TRNS = 'Confirmation'.                   "#EC NOTEXT
            IT_LOG-MESS = 'Failed'.                         "#EC NOTEXT
            APPEND IT_LOG.
            IT_LOG-ICON = '@0A@'.
            IT_LOG-TRNS = 'Goods Issue'.                    "#EC NOTEXT
            IT_LOG-MESS = 'Failed'.                         "#EC NOTEXT
            APPEND IT_LOG.
          ENDIF.
        ELSE.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Confirmation'.                     "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Goods Issue'.                      "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDIF.
      ELSEIF ITAB_SOTOSO IS NOT INITIAL AND ITAB_SOTOUN IS INITIAL.
        CLEAR: FLAG.
        PERFORM SOTOSO CHANGING FLAG.
        IF FLAG = ''.
*            PERFORM CONFIRMATION.
          PERFORM CHANGE_BATCH_INPUTAN.
        ELSE.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Confirmation'.                     "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Goods Issue'.                      "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDIF.
      ELSEIF ITAB_SOTOSO IS INITIAL AND ITAB_SOTOUN IS NOT INITIAL.
        CLEAR: FLAG.
        PERFORM SOTOUN CHANGING FLAG.
        IF FLAG = ''.
*            PERFORM CONFIRMATION.
          PERFORM CHANGE_BATCH_INPUTAN.
        ELSE.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Confirmation'.                     "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Goods Issue'.                      "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDIF.
      ELSEIF ITAB_SOTOSO IS INITIAL AND ITAB_SOTOUN IS INITIAL.
*          PERFORM CONFIRMATION.
        PERFORM CHANGE_BATCH_INPUTAN.
      ENDIF.
    ELSE.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Confirmation'.                         "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Goods Issue'.                          "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
      PERFORM UNDO_CHANGE_BATCH_ORIG_ORDER.
    ENDIF.
  ELSE.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Receipt'.                          "#EC NOTEXT
    IT_LOG-MESS = 'Zero Quantity GR'.                       "#EC NOTEXT
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Issue'.                            "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    PERFORM UNDO_CHANGE_BATCH_ORIG_ORDER.
  ENDIF.


ENDFORM.                    " GR
*&---------------------------------------------------------------------*
*&      Form  SOTOSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SOTOSO CHANGING P_FLAG.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD_SOTOSO
      GOODSMVT_CODE         = GMCODE_SOTOSO
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD_SOTOSO
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB_SOTOSO
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG_SOTOSO.

  CLEAR: P_FLAG, VMESS.
  LS_SUBRC = 0.
  LOOP AT ERRMSG_SOTOSO WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    P_FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Receipt SO To SO'.                 "#EC NOTEXT
    IT_LOG-MESS = ERRMSG_SOTOSO-MESSAGE.
    APPEND IT_LOG.
  ENDLOOP.

  CLEAR: SY-SUBRC.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS, S_MBLNR, S_MJAHR.
    S_MBLNR = MTHEAD_SOTOSO+0(10).
    S_MJAHR = MTHEAD_SOTOSO+10(4).
    CONCATENATE 'No.Mat.Doc :' MTHEAD_SOTOSO+0(10) '--' 'Fiscal Year' MTHEAD_SOTOSO+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Goods Receipt SO To SO'.                 "#EC NOTEXT
    IT_LOG-MESS = VMESS."'Success'.
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " SOTOSO
*&---------------------------------------------------------------------*
*&      Form  SOTOUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SOTOUN CHANGING P_FLAG.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD_SOTOUN
      GOODSMVT_CODE         = GMCODE_SOTOUN
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD_SOTOUN
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB_SOTOUN
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG_SOTOUN.

  CLEAR: P_FLAG, VMESS.
  LS_SUBRC = 0.
  LOOP AT ERRMSG_SOTOUN WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    P_FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Receipt SO To Unres'.              "#EC NOTEXT
    IT_LOG-MESS = ERRMSG_SOTOUN-MESSAGE.
    APPEND IT_LOG.
  ENDLOOP.

  CLEAR: SY-SUBRC.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS, U_MBLNR, U_MJAHR.
    U_MBLNR = MTHEAD_SOTOUN+0(10).
    U_MJAHR = MTHEAD_SOTOUN+10(4).
    CONCATENATE 'No.Mat.Doc :' MTHEAD_SOTOUN+0(10) '--' 'Fiscal Year' MTHEAD_SOTOUN+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Goods Receipt SO To Unres'.              "#EC NOTEXT
    IT_LOG-MESS = VMESS."'Success'.
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " SOTOUN
*&---------------------------------------------------------------------*
*&      Form  CHANGE_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_BATCH_INPUTAN .
  DATA: V_PLANT LIKE MCHA-WERKS.
* Cek Batch Inputan ada berapa
  CLEAR: CTRB.
  DESCRIBE TABLE IT_INBATCH LINES CTRB.
****** Cek diferentlength
*****  CLEAR: wa_main, v_dif.
*****  READ TABLE it_main INTO wa_main INDEX 1.
*****  IF wa_main-diflength = 'TIDAK'.
*****    v_dif = 0.
*****  ELSEIF wa_main-diflength = 'YA'.
*****    v_dif = 1.
*****  ENDIF.

* Perhitungan Total GI
* Get ZZWIDTH & ZZLENGTH dari batch original order yang sudah di GR
* ZZWIDTH & ZZLENGTH yg baru ditampung di it_main-v_width & it_main-v_length
* Hitung Total ZZWIDTH dari batch original order, ditampung di TOT_WIDTHOR
* Hitung total extralength dari batch original, ditampung di tot_el
* Ambil Material raw recycle ditampung ke v_matraw
  CLEAR: WA_MAIN, TOT_WIDTHOR, TOT_EL, V_MATRAW, TOT_LENGTHOR.
*******  CLEAR: WA_MAIN, MAX_LENGTH, TOT_WIDTHOR, TOT_EL, V_MATRAW, TOT_LENGTHOR." Komen dulu sebelum ubah maxlength
  LOOP AT IT_MAIN INTO WA_MAIN.

    CLEAR: V_MATNR, V_CHARG, V_PLANT.
    V_CHARG = WA_MAIN-CHARG.
    SELECT SINGLE MATNR
      INTO V_MATNR
      FROM MCH1
     WHERE CHARG = V_CHARG AND LICHA = WA_MAIN-AUFNR.
*      %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z02")'.

    "    ADD NEW COMPANY
    SELECT SINGLE WERKS
      INTO V_PLANT
      FROM MCHA
     WHERE CHARG = V_CHARG AND MATNR = V_MATNR.

    CLEAR: V_MATRAW.
    SELECT SINGLE RAR_A_MATNR
      INTO V_MATRAW
      FROM ZTMAP_MATRECYCLE
     WHERE FILMT = V_MATNR+2(3) AND WERKS = V_PLANT.  "  ADD NEW COMPANY.

    CLEAR : CHAR_OF_BATCH, V_WIDTH, V_LENGTH, V_DENSITY, V_THICKNESS.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = V_MATNR "<fs_pos>-matnr
        CHARG                    = V_CHARG "<fs_pos>-charg
*        WERKS                    = V_WERKS "<fs_pos>-werks
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*  Implement suitable error handling here
    ENDIF.

    IF CLASS NE 'ZZSRSHEET'.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZWIDTH'." BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        V_WIDTH = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_WIDTH WITH SPACE.
        CONDENSE V_WIDTH NO-GAPS.
      ENDIF.
      WA_MAIN-V_WIDTH = V_WIDTH.
*     Hitung total zzwidth, ditampung di tot_widthor
      TOT_WIDTHOR = TOT_WIDTHOR + WA_MAIN-V_WIDTH.
    ENDIF.

    IF CLASS = 'ZZSRSHEET'.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZLENGTHSHT'.
      IF SY-SUBRC EQ 0.
        V_LENGTH = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTH WITH SPACE.
        CONDENSE V_LENGTH NO-GAPS.
      ENDIF.
    ELSE.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZLENGTH'.
      IF SY-SUBRC EQ 0.
        V_LENGTH = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTH WITH SPACE.
        CONDENSE V_LENGTH NO-GAPS.
      ENDIF.
    ENDIF.

    WA_MAIN-V_LENGTH = V_LENGTH.
*   Cari Length terpanjang
*******    IF MAX_LENGTH < WA_MAIN-V_LENGTH. " Komen dulu sebelum ubah maxlength
*******      MAX_LENGTH = WA_MAIN-V_LENGTH.
*******    ENDIF.
*   Hitung total zzlength, ditampung di tot_lengthor
    TOT_LENGTHOR = TOT_LENGTHOR + WA_MAIN-V_LENGTH.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZDENSITY'." BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      V_DENSITY = <FS_CHAR_OF_BATCH>-ATWTB.
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_DENSITY WITH SPACE.
      CONDENSE V_DENSITY NO-GAPS.
    ENDIF.
    WA_MAIN-ZZDENSITY = V_DENSITY.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZTHICKNESS'." BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      V_THICKNESS = <FS_CHAR_OF_BATCH>-ATWTB.
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_THICKNESS WITH SPACE.
      CONDENSE V_THICKNESS NO-GAPS.
    ENDIF.
    WA_MAIN-ZZTHICKNESS = V_THICKNESS.

    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZPRODLINE'.
    IF SY-SUBRC EQ 0.
      WA_MAIN-ZZPRODLINE = <FS_CHAR_OF_BATCH>-ATWTB.
    ENDIF.
    CLEAR: V_ATINN, V_ATZHL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZPRODLINE'
      IMPORTING
        OUTPUT = V_ATINN.
    SELECT SINGLE ATZHL INTO V_ATZHL
      FROM CAWNT
     WHERE ATINN = V_ATINN AND ATWTB = WA_MAIN-ZZPRODLINE.
*      %_HINTS ORACLE 'INDEX("CAWNT" "CAWNT~Z01")'.
    IF SY-SUBRC EQ 0.
      CLEAR WA_MAIN-ZZPRODLINE.
      SELECT SINGLE ATWRT INTO WA_MAIN-ZZPRODLINE
        FROM CAWN
       WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
    ENDIF.

    IF CLASS NE 'ZZSRSHEET'.
      CLEAR: V_EXTRA.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZWEIGHTEL'.
      IF SY-SUBRC EQ 0.
        V_EXTRA = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_EXTRA WITH SPACE.
        CONDENSE V_EXTRA NO-GAPS.
      ENDIF.
      WA_MAIN-ZZWEIGHTEL = V_EXTRA.
*     Cari total extra length ditampung ke tot_el
*      IF wa_main-marks1 = '' and wa_main-marks2 = '' and wa_main-marks3 = '' and wa_main-marks4 = ''.
      TOT_EL = TOT_EL + WA_MAIN-ZZWEIGHTEL.
*      ENDIF.
    ENDIF.

    CLEAR: V_GRAMMAGE.
    READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZGRAMMAGE'.
    IF SY-SUBRC EQ 0.
      V_GRAMMAGE = <FS_CHAR_OF_BATCH>-ATWTB.
      REPLACE ALL OCCURRENCES OF RIBUAN IN V_GRAMMAGE WITH SPACE.
      CONDENSE V_GRAMMAGE NO-GAPS.
    ENDIF.
    WA_MAIN-ZZGRAMMAGE = V_GRAMMAGE.

    MODIFY IT_MAIN FROM WA_MAIN TRANSPORTING V_WIDTH V_LENGTH ZZDENSITY ZZTHICKNESS ZZPRODLINE ZZWEIGHTEL ZZGRAMMAGE.

  ENDLOOP.

* Cari ZZLENGTH & ZZWIDTH baru di batch inputan
  CLEAR: WA_INBATCH, FLAG, COUNT.
  COUNT = 0.
  LOOP AT IT_INBATCH INTO WA_INBATCH.
    CHECK FLAG EQ SPACE.
    ADD 1 TO COUNT.
    CLEAR: MAX_LENGTH2, V_ZZJUMBOSHEETGI2.
    IF CTRB = 1.
      IF CLASS = 'ZZSRSHEET'.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - V_ZZLENGTHGI.
      ELSE.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - MAX_LENGTH.
      ENDIF.
      WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
*      wa_inbatch-sgtxt      = max_length.
      MAX_LENGTH2 = MAX_LENGTH.
      CONDENSE MAX_LENGTH2 NO-GAPS.
      V_ZZJUMBOSHEETGI2 = V_ZZJUMBOSHEETGI.
      CONDENSE V_ZZJUMBOSHEETGI2 NO-GAPS.
      CONCATENATE MAX_LENGTH2 ';' V_ZZJUMBOSHEETGI2 INTO WA_INBATCH-SGTXT.
    ELSEIF CTRB = 2.
      IF COUNT = 1.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - IN_JOINT2.
        WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
        WA_INBATCH-SGTXT      = IN_JOINT2.
      ELSEIF COUNT = 2.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - ( MAX_LENGTH - IN_JOINT2 ).
        WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
*        WA_INBATCH-SGTXT      = MAX_LENGTH + IN_JOINT2.
        WA_INBATCH-SGTXT      = MAX_LENGTH - IN_JOINT2.
      ENDIF.
    ELSEIF CTRB = 3.
      IF COUNT = 1.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - IN_JOINT2.
        WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
        WA_INBATCH-SGTXT      = IN_JOINT2.
      ELSEIF COUNT = 2.
*        wa_inbatch-zzlengthbr = wa_inbatch-zzlength - in_joint3.
*        wa_inbatch-zzlengthbr = in_joint3 - wa_inbatch-zzlength.
*        wa_inbatch-zzlengthbr = in_joint3 - in_joint2.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - ( IN_JOINT3 - IN_JOINT2 ).
        WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
*        WA_INBATCH-SGTXT      = IN_JOINT3 + IN_JOINT2.
        WA_INBATCH-SGTXT      = IN_JOINT3 - IN_JOINT2.
      ELSEIF COUNT = 3.
        WA_INBATCH-ZZLENGTHBR = WA_INBATCH-ZZLENGTH - ( MAX_LENGTH - IN_JOINT3 ).
        WA_INBATCH-ZZWIDTHBR  = WA_INBATCH-ZZWIDTH."  - tot_widthor.
*        WA_INBATCH-SGTXT      = MAX_LENGTH + IN_JOINT3.
        WA_INBATCH-SGTXT      = MAX_LENGTH - IN_JOINT3.
      ENDIF.
    ENDIF.
    MODIFY IT_INBATCH FROM WA_INBATCH TRANSPORTING ZZLENGTHBR ZZWIDTHBR SGTXT.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = WA_INBATCH-MATNR
        I_CHARG      = WA_INBATCH-CHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_INBATCH-MATNR
        CHARG                    = WA_INBATCH-CHARG
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.

    IF CLASS = 'ZZSRSHEET'.
*     Set ZZLENGTHSHT
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_INBATCH-ZZLENGTHBR.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZLENGTHBR.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZNUMBEROFSHEET
      CLEAR: WA_CHAR2, LS_SUBRC, V_NUMBEROFSHEET.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZNUMBEROFSHEET'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR - V_ZZJUMBOSHEETGI.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZNUMBEROFSHEET'.
        IT_CHAR-VALUE_CHAR = V_ZZJUMBOSHEETGI.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
*     Set ZZLENGTH
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_INBATCH-ZZLENGTHBR.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZLENGTHBR.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.

    " Modified by William at 19.05.2022 (for T-Code ZPP001_WO_VAL)
    IF SY-TCODE = 'ZPP001_WO_VAL'.
      READ TABLE IT_CHAR WITH KEY CHARACT = 'ZZLENGTH'.
      IF IT_CHAR-VALUE_CHAR < 0.
        IT_CHAR-VALUE_CHAR = 0.
        MODIFY IT_CHAR TRANSPORTING VALUE_CHAR WHERE CHARACT = 'ZZLENGTH'.
      ENDIF.
    ENDIF.
********   Set ZZWIDTH
*******    CLEAR: wa_char2, ls_subrc.
*******    LOOP AT it_char INTO wa_char2 WHERE charact = 'ZZWIDTH'.
*******      ls_subrc = 1.
*******      wa_char2-VALUE_CHAR = wa_inbatch-zzwidthbr.
*******      MODIFY it_char FROM wa_char2 TRANSPORTING value_char.
*******    ENDLOOP.
*******    IF ls_subrc = 0.
*******      IT_CHAR-CHARACT    = 'ZZWIDTH'.
*******      IT_CHAR-VALUE_CHAR = wa_inbatch-zzwidthbr.
*******      APPEND IT_CHAR.
*******    ENDIF.
*   Set ZZLENGTHASAL
*******    CLEAR: wa_char2, ls_subrc.
*******    LOOP AT it_char INTO wa_char2 WHERE charact = 'ZZLENGTHASAL'.
*******      ls_subrc = 1.
*******      wa_char2-VALUE_CHAR = wa_inbatch-zzlength.
*******      MODIFY it_char FROM wa_char2 TRANSPORTING value_char.
*******    ENDLOOP.
*******    IF ls_subrc = 0.
*******      IT_CHAR-CHARACT    = 'ZZLENGTHASAL'.
*******      IT_CHAR-VALUE_CHAR = wa_inbatch-zzlength.
*******      APPEND IT_CHAR.
*******    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
*      IF it_return2-type = 'E' and ls_subrc = 0.
      CLEAR: VMESS.
      CONCATENATE WA_INBATCH-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Change Batch Inputan'.                 "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
*      ENDIF.
    ENDLOOP.

    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE WA_INBATCH-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Change Batch Inputan'.                 "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDLOOP.

  IF FLAG = SPACE.
    PERFORM GET_ZZCONVBR.
    PERFORM CONFIRMATION.
  ELSE.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
*    PERFORM UNDO_CHANGE_BATCH_INPUTAN.
  ENDIF.

ENDFORM.                    " CHANGE_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*&      Form  GET_ZZCONVBR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZZCONVBR .

  CLEAR: WA_INBATCH.
  LOOP AT IT_INBATCH INTO WA_INBATCH.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_INBATCH-MATNR
        CHARG                    = WA_INBATCH-CHARG
*       WERKS                    =
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
               .
    IF SY-SUBRC <> 0.
*  Implement suitable error handling here
    ENDIF.

    IF CLASS = 'ZZSRSHEET'.
      CLEAR: V_CONV.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONPACKG'.
      IF SY-SUBRC EQ 0.
        V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE 'Kg/PAC' IN V_CONV WITH SPACE.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
        CONDENSE V_CONV NO-GAPS.
        WA_INBATCH-ZZCONVERSIONBR = V_CONV.
      ENDIF.
    ELSE.
      CLEAR: V_CONV.
      READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC EQ 0.
        V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
        REPLACE 'Kg/Rol' IN V_CONV WITH SPACE.
        REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
        CONDENSE V_CONV NO-GAPS.
        WA_INBATCH-ZZCONVERSIONBR = V_CONV.
      ENDIF.
    ENDIF.

    MODIFY IT_INBATCH FROM WA_INBATCH TRANSPORTING ZZCONVERSIONBR.

  ENDLOOP.

ENDFORM.                    " GET_ZZCONVBR
*&---------------------------------------------------------------------*
*&      Form  CONFIRMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRMATION .
*******  .

* Get Time Process
  CLEAR: TIME_PROC.
*  TIME_PROC = TOT_LENGTHOR / IN_SPEED.
  TIME_PROC = MAX_LENGTH / IN_SPEED.

* Get total GI
  CLEAR: WA_INBATCH, TOT_GI.
  LOOP AT IT_INBATCH INTO WA_INBATCH.
    CLEAR: TOT_GI2.
    TOT_GI2 = ( WA_INBATCH-ZZCONVERSION - WA_INBATCH-ZZCONVERSIONBR )." + TOT_GI.
    WA_INBATCH-TOT_GI = TOT_GI2.
    MODIFY IT_INBATCH FROM WA_INBATCH TRANSPORTING TOT_GI.
    TOT_GI = TOT_GI + TOT_GI2.
  ENDLOOP.

* Get total GR by V_MBLNR & V_MJAHR
  CLEAR: TOT_GR.
  SELECT SUM( MENGE )
    INTO TOT_GR
    FROM MSEG
   WHERE MBLNR = V_MBLNR AND MJAHR = V_MJAHR.

* Get total GI normal ( total GR + total EL )
  CLEAR: TOT_GI_NORMAL.
  TOT_GI_NORMAL = TOT_GR + TOT_EL.

* Get Total Scrap
  CLEAR: TOT_SCRAP, WA_MAIN, V_ZCXLGORT, V_ZWCLGORT, V_ZRRLGORT, V_ZSLLGORT.
  READ TABLE IT_MAIN INTO WA_MAIN INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR: V_ZCXLGORT, V_ZWCLGORT, V_ZRRLGORT, V_ZSLLGORT.
*******    SELECT SINGLE ZCXLGORT ZWCLGORT ZRRLGORT
*******      INTO (WA_MAIN-ZCXLGORT,WA_MAIN-ZWCLGORT,WA_MAIN-ZRRLGORT)
*******      FROM ZTMAP_SLOCRR
*******     WHERE ZLINE = WA_MAIN-ZZPRODLINE.
**********    SELECT SINGLE ZCXLGORT ZWCLGORT ZRRLGORT ZSLLGORT
**********      INTO (V_ZCXLGORT,V_ZWCLGORT,V_ZRRLGORT,V_ZSLLGORT)
**********      FROM ZTMAP_SLOCRR
**********     WHERE ZGRSLLGORT = WA_MAIN-STGE_LOC AND ZLINE = WA_MAIN-ZZPRODLINE.
    V_ZCXLGORT = WA_MAIN-ZCXLGORT.
    V_ZWCLGORT = WA_MAIN-ZWCLGORT.
    V_ZRRLGORT = WA_MAIN-ZRRLGORT.
    V_ZSLLGORT = WA_MAIN-ZSLLGORT.
  ENDIF.
  CLEAR: WA_MAIN.
  LOOP AT IT_MAIN INTO WA_MAIN WHERE MARKS8 = 'X'.

**    CLEAR: v_ZCXLGORT, v_ZWCLGORT.
**    SELECT SINGLE ZCXLGORT ZWPLGORT
**      INTO (WA_MAIN-ZCXLGORT,WA_MAIN-ZWCLGORT)
**      FROM ZTMAP_SLOCRR
**     WHERE ZLINE = WA_MAIN-ZZPRODLINE.

**    V_ZCXLGORT = WA_MAIN-ZCXLGORT.
**    V_ZWPLGORT = WA_MAIN-ZWCLGORT.

    IF WA_MAIN-ZZTHICKNESS = SPACE OR WA_MAIN-ZZDENSITY = SPACE.
      WA_MAIN-TOT_SCRAP = ( WA_MAIN-V_LENGTH * WA_MAIN-V_WIDTH * WA_MAIN-ZZGRAMMAGE ) / 1000000.
    ELSE.
      WA_MAIN-TOT_SCRAP = ( WA_MAIN-V_LENGTH * WA_MAIN-V_WIDTH * WA_MAIN-ZZTHICKNESS * WA_MAIN-ZZDENSITY ) / 1000000.
    ENDIF.

    TOT_SCRAP = TOT_SCRAP + WA_MAIN-TOT_SCRAP.
    MODIFY IT_MAIN FROM WA_MAIN TRANSPORTING TOT_SCRAP ZCXLGORT.

  ENDLOOP.

* Get total waste
  CLEAR: TOT_WASTE, V_WERKS.
  TOT_WASTE = TOT_GI - TOT_SCRAP - TOT_GI_NORMAL.

  SELECT SINGLE WERKS
    INTO V_WERKS
    FROM RESB
   WHERE AUFNR = COM_ORDER AND BWART = '261' OR
         AUFNR = COM_ORDER AND BWART = '901'. " Tambahan 28 January 2013

  CLEAR: TIMETICKETS, GOODSMOVEMENTS, DETAIL_RETURN.
  REFRESH: TIMETICKETS, GOODSMOVEMENTS, DETAIL_RETURN.

  TIMETICKETS-ORDERID         = COM_ORDER.
  TIMETICKETS-PLANT           = V_WERKS.
  TIMETICKETS-PHASE           = '0020'.
  TIMETICKETS-FIN_CONF        = '1'.
  TIMETICKETS-CONF_QUAN_UNIT  = 'KG'.
  TIMETICKETS-YIELD           = TOT_GR.
  TIMETICKETS-CONF_ACTIVITY1  = TIME_PROC.
  TIMETICKETS-CONF_ACTI_UNIT1 = 'MIN'.
  TIMETICKETS-CONF_ACTIVITY2  = TIME_PROC.
  TIMETICKETS-CONF_ACTI_UNIT2 = 'MIN'.
  TIMETICKETS-PERS_NO         = IN_NIK.
  IF IN_RES NE ''. " Additional 11 January 2013
    TIMETICKETS-RESOURCE        = IN_RES.
  ELSE." Additional 11 January 2013
    READ TABLE ZBOXER INDEX 1." Additional 11 January 2013
    IF SY-SUBRC = 0." Additional 11 January 2013
      TIMETICKETS-RESOURCE        = ZBOXER-ARBPL." Additional 11 January 2013
    ENDIF." Additional 11 January 2013
  ENDIF.
  APPEND TIMETICKETS.

******* For Bapi Goods Movement
  CLEAR: GMHEAD, GMCODE, MTHEAD, ITAB, ERRMSG.
  REFRESH: ITAB, ERRMSG.

  GMHEAD-PSTNG_DATE = SY-DATUM.
  GMHEAD-DOC_DATE   = SY-DATUM.
  GMHEAD-PR_UNAME   = SY-UNAME.
  GMHEAD-HEADER_TXT = COM_ORDER.
  GMCODE-GM_CODE    = '03'.

* Line 1 Total GI Normal
  CLEAR: WA_INBATCH, V_MATNR, V_MEINS, V_CHARG, V_LGORT.
**  READ TABLE it_inbatch INTO wa_inbatch INDEX 1.
**  IF sy-subrc = 0.
**    SELECT SINGLE MATNR
**      INTO V_MATNR
**      FROM MCH1
**     WHERE CHARG = wa_inbatch-charg.
**    SELECT SINGLE MEINS
**      INTO V_MEINS
**      FROM MARA
**     WHERE MATNR = V_MATNR.
**    v_charg = wa_inbatch-charg.
**    v_lgort = wa_inbatch-lgort.
**  ENDIF.
**  itab-move_type      = '261'.
**  itab-material       = V_MATNR.
**  itab-plant          = V_WERKS.
**  itab-stge_loc       = V_LGORT.
**  itab-BATCH          = V_CHARG.
**  itab-ORDERID        = COM_ORDER.
**  itab-ENTRY_QNT      = TOT_GI.
**  itab-ENTRY_UOM      = V_MEINS.
**  APPEND itab.
  CLEAR: TOT_GI, TOT_GI2, TOT_GI3.
  LOOP AT IT_INBATCH INTO WA_INBATCH.
    CLEAR: V_MATNR, V_MEINS, V_CHARG, V_LGORT.
    SELECT SINGLE MATNR
      INTO V_MATNR
      FROM MCH1
     WHERE CHARG = WA_INBATCH-CHARG.
    SELECT SINGLE MEINS
      INTO V_MEINS
      FROM MARA
     WHERE MATNR = V_MATNR.
    V_CHARG = WA_INBATCH-CHARG.
    V_LGORT = WA_INBATCH-LGORT.
****Tambahan Untuk Order yang type nya trial, pakai movement type 901 28 January 2013
    IF V_AUART = 'ZTC1' OR V_AUART = 'ZTC2'. "Tambahan 28 January 2013
      ITAB-MOVE_TYPE      = '901'. "Tambahan 28 January 2013
    ELSE. "Tambahan 28 January 2013
      ITAB-MOVE_TYPE      = '261'.
    ENDIF. "Tambahan 28 January 2013

    ITAB-MATERIAL       = V_MATNR.
    ITAB-PLANT          = V_WERKS.
    ITAB-STGE_LOC       = V_LGORT.
    ITAB-BATCH          = V_CHARG.
    ITAB-ORDERID        = COM_ORDER.
    ITAB-ENTRY_QNT      = WA_INBATCH-TOT_GI.
    ITAB-ENTRY_UOM      = V_MEINS.
    ITAB-ITEM_TEXT      = WA_INBATCH-SGTXT.
    APPEND ITAB.
    IF SY-TABIX = 1.
      TOT_GI  = WA_INBATCH-TOT_GI.
    ELSEIF SY-TABIX = 2.
      TOT_GI2 = WA_INBATCH-TOT_GI.
    ELSEIF SY-TABIX = 3.
      TOT_GI3 = WA_INBATCH-TOT_GI.
    ENDIF.
  ENDLOOP.

  CLEAR: V_MEINS, ITAB.
  SELECT SINGLE MEINS
    INTO V_MEINS
    FROM MARA
   WHERE MATNR = V_MATRAW.
  IF TOT_WASTE > 0.
    ITAB-MOVE_TYPE      = '531'.
    ITAB-MATERIAL       = V_MATRAW.
    ITAB-PLANT          = V_WERKS.
    ITAB-STGE_LOC       = V_ZWCLGORT.
    ITAB-ORDERID        = COM_ORDER.
    ITAB-ENTRY_QNT      = TOT_WASTE.
    ITAB-ENTRY_UOM      = V_MEINS.
    APPEND ITAB.
  ELSE. " Additional 8 January 2013
    CLEAR: TOT_WASTE. " Additional 8 January 2013
  ENDIF.

  IF TOT_SCRAP NE SPACE.
    CLEAR: ITAB.
    ITAB-MOVE_TYPE      = '531'.
    ITAB-MATERIAL       = V_MATRAW.
    ITAB-PLANT          = V_WERKS.
    ITAB-STGE_LOC       = V_ZCXLGORT.
    ITAB-ORDERID        = COM_ORDER.
    ITAB-ENTRY_QNT      = TOT_SCRAP.
    ITAB-ENTRY_UOM      = V_MEINS.
    APPEND ITAB.
  ENDIF.

  CALL FUNCTION 'BAPI_PROCORDCONF_CREATE_TT'
*   EXPORTING
*     POST_WRONG_ENTRIES             = '0'
*     TESTRUN                        =
*   IMPORTING
*     RETURN                         =
    TABLES
      TIMETICKETS                    = TIMETICKETS
*     GOODSMOVEMENTS                 = GOODSMOVEMENTS
*     LINK_CONF_GOODSMOV             =
*     CHARACTERISTICS_WIPBATCH       =
*     LINK_CONF_CHAR_WIPBATCH        =
*     CHARACTERISTICS_BATCH          =
*     LINK_GM_CHAR_BATCH             =
      DETAIL_RETURN                  = DETAIL_RETURN
            .
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT DETAIL_RETURN WHERE TYPE = 'E'.
*    IF it_return2-type = 'E' and ls_subrc = 0.
**    CLEAR: VMESS.
**    CONCATENATE wa_inbatch-charg '-' it_return2-message INTO VMESS SEPARATED BY space.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = DETAIL_RETURN-MESSAGE.
    APPEND IT_LOG.
*    ENDIF.
  ENDLOOP.

  CLEAR: SY-SUBRC.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    V_CONF_NO = DETAIL_RETURN-CONF_NO.
    CONCATENATE 'Conf.No' DETAIL_RETURN-CONF_NO INTO VMESS SEPARATED BY SPACE.
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Confirmation'.                           "#EC NOTEXT
    IT_LOG-MESS = VMESS."'Success'.
    APPEND IT_LOG.
  ENDIF.
*BREAK-POINT.
  IF FLAG = SPACE.
    IF TOT_GI >= 0 AND TOT_WASTE >= 0 AND TOT_SCRAP >= 0 AND
       TOT_GI2 >= 0 AND TOT_GI3 >= 0.
      PERFORM GI.
    ELSE.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Goods Issue'.                          "#EC NOTEXT
      IT_LOG-MESS = 'Failed - Minus Quantity'.              "#EC NOTEXT
      APPEND IT_LOG.
      PERFORM UNDO_CHANGE_BATCH_INPUTAN.
    ENDIF.
  ELSE.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Issue'.                            "#EC NOTEXT
    IT_LOG-MESS = 'Failed'.                                 "#EC NOTEXT
    APPEND IT_LOG.
    PERFORM UNDO_CHANGE_BATCH_INPUTAN.
  ENDIF.

ENDFORM.                    " CONFIRMATION
*&---------------------------------------------------------------------*
*&      Form  UNDO_CHANGE_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNDO_CHANGE_BATCH_INPUTAN .

  CLEAR: WA_INBATCH, FLAG.
  LOOP AT IT_INBATCH INTO WA_INBATCH.

    CHECK FLAG EQ SPACE.

    DO 20 TIMES.
      CALL FUNCTION 'ENQUEUE_EMMCH1E'
        EXPORTING
          MATNR          = WA_INBATCH-MATNR
          CHARG          = WA_INBATCH-CHARG
        EXCEPTIONS
          FOREIGN_LOCK   = 2
          SYSTEM_FAILURE = 3.

      IF SY-SUBRC  NE 0.
        WAIT UP TO 1 SECONDS.
      ELSE.
        CALL FUNCTION 'DEQUEUE_EMMCH1E'
          EXPORTING
            MATNR = WA_INBATCH-MATNR
            CHARG = WA_INBATCH-CHARG.
        EXIT.
      ENDIF.
    ENDDO.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = WA_INBATCH-MATNR
        I_CHARG      = WA_INBATCH-CHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_INBATCH-MATNR
        CHARG                    = WA_INBATCH-CHARG
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.

    IF CLASS = 'ZZSRSHEET'.
*     Set ZZLENGTHST
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_INBATCH-ZZLENGTH.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZLENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
*     Set ZZLENGTH
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_INBATCH-ZZLENGTH.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = WA_INBATCH-ZZLENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.
********   Set ZZWIDTH
*******    CLEAR: wa_char2, ls_subrc.
*******    LOOP AT it_char INTO wa_char2 WHERE charact = 'ZZWIDTH'.
*******      ls_subrc = 1.
*******      wa_char2-VALUE_CHAR = wa_inbatch-zzwidth.
*******      MODIFY it_char FROM wa_char2 TRANSPORTING value_char.
*******    ENDLOOP.
*******    IF ls_subrc = 0.
*******      IT_CHAR-CHARACT    = 'ZZWIDTH'.
*******      IT_CHAR-VALUE_CHAR = wa_inbatch-zzwidth.
*******      APPEND IT_CHAR.
*******    ENDIF.
********   Set ZZWEIGHTEL
*******    CLEAR: wa_char2, ls_subrc, wa_main.
*******    READ TABLE it_main INTO wa_main WITH KEY charg = wa_inbatch-charg.
*******    IF sy-subrc = 0.
*******      LOOP AT it_char INTO wa_char2 WHERE charact = 'ZZWEIGHTEL'.
*******        ls_subrc = 1.
*******        wa_char2-VALUE_CHAR = wa_main-zzweightel.
*******        MODIFY it_char FROM wa_char2 TRANSPORTING value_char.
*******      ENDLOOP.
*******      IF ls_subrc = 0.
*******        IT_CHAR-CHARACT    = 'ZZWEIGHTEL'.
*******        IT_CHAR-VALUE_CHAR = wa_main-zzweightel.
*******        APPEND IT_CHAR.
*******      ENDIF.
*******    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
*      IF it_return2-type = 'E' and ls_subrc = 0.
      CLEAR: VMESS.
      CONCATENATE WA_INBATCH-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Undo Change Batch Inputan'.            "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
*      ENDIF.
    ENDLOOP.

    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE WA_INBATCH-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Undo Change Batch Inputan'.            "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
      PERFORM CANCEL_CONFIRMATION." USING V_CONF_NO.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " UNDO_CHANGE_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*&      Form  GI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GI .

  CLEAR: ERRMSG, MTHEAD, ITAB_TRSFR, ITAB_TRSFR2, WA_TRSFR, WA_TRSFR2.
  REFRESH: ERRMSG, ITAB_TRSFR, ITAB_TRSFR2.

  ITAB_TRSFR[] = ITAB[].
  DELETE ITAB_TRSFR WHERE MOVE_TYPE NE '531'.
  ITAB_TRSFR2[] = ITAB_TRSFR[].

  SORT ITAB_TRSFR BY MOVE_TYPE.
*  DELETE ADJACENT DUPLICATES FROM itab_trsfr COMPARING move_type.

  CLEAR: WA_TRSFR.
  LOOP AT ITAB_TRSFR INTO WA_TRSFR.
    CLEAR: WA_TRSFR2, WA_TRSFR-MOVE_STLOC.
*    LOOP AT itab_trsfr INTO wa_trsfr2 WHERE move_type = wa_trsfr-move_type. " Disuruh nyalain lagi sama YAN YOHANA diminta komen lagi
*      wa_trsfr-ENTRY_QNT = wa_trsfr-ENTRY_QNT + wa_trsfr2-ENTRY_QNT. " Disuruh nyalain lagi sama YAN YOHANA
*    ENDLOOP. " Disuruh nyalain lagi sama YAN YOHANA
    WA_TRSFR-ORDERID    = ''.
    WA_TRSFR-MOVE_STLOC = V_ZRRLGORT.
    WA_TRSFR-ITEM_TEXT  = 'RAW'.
    WA_TRSFR-MOVE_TYPE  = '311'.
    MODIFY ITAB_TRSFR FROM WA_TRSFR TRANSPORTING ENTRY_QNT ITEM_TEXT MOVE_STLOC MOVE_TYPE ORDERID.
  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD
      GOODSMVT_CODE         = GMCODE
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG.

  CLEAR: FLAG, VMESS, V_MBLNR, V_MJAHR.
  LS_SUBRC = 0.
  LOOP AT ERRMSG WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Goods Issue'.                            "#EC NOTEXT
    IT_LOG-MESS = ERRMSG-MESSAGE.
    APPEND IT_LOG.
  ENDLOOP.

  CLEAR: SY-SUBRC.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    CONCATENATE 'No.Mat.Doc :' MTHEAD+0(10) '--' 'Fiscal Year' MTHEAD+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    V_MBLNR = MTHEAD+0(10).
    V_MJAHR = MTHEAD+10(4).
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Goods Issue'.                            "#EC NOTEXT
    IT_LOG-MESS = VMESS."'Success'.
    APPEND IT_LOG.
  ENDIF.

  IF FLAG EQ SPACE.
    PERFORM SLOC_TO_SLOC.
  ELSE.
    PERFORM UNDO_CHANGE_BATCH_INPUTAN.
  ENDIF.

ENDFORM.                    " GI
*&---------------------------------------------------------------------*
*&      Form  SCRAP_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SCRAP_BATCH_INPUTAN.

  DATA: V_FDATE LIKE SY-DATUM,  "ADDED BY FATHIR ON 19.05.2021 - get PO by current month
        V_EDATE LIKE SY-DATUM.
  CLEAR: V_FDATE, V_EDATE.

  CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST' "ADDED BY FATHIR ON 19.05.2021 - GET PO BY CURRENT MONTH
   EXPORTING
     I_MONTH           = SY-DATUM+4(2)
     I_YEAR            = SY-DATUM(4)
   IMPORTING
     E_FIRST_DAY       = V_FDATE  " first date of the month-year
     E_LAST_DAY        = V_EDATE  " end date of the month-year
   EXCEPTIONS
     WRONG_DATE        = 1
     OTHERS            = 2.

**Get Combine Order
  CLEAR: IT_SCRAP, WA_SCRAP, WA_INBATCH.
  REFRESH: IT_SCRAP.
  LOOP AT IT_INBATCH INTO WA_INBATCH WHERE SCRAP EQ 'X'.

    SELECT SINGLE CLABS
      INTO WA_INBATCH-CLABS
      FROM MCHB
     WHERE MATNR = WA_INBATCH-MATNR AND CHARG = WA_INBATCH-CHARG AND
           LGORT = WA_INBATCH-LGORT AND CLABS > 0. " Tambahan 03.01.2013

    MODIFY IT_INBATCH FROM WA_INBATCH TRANSPORTING CLABS.

****Tambahan 28 January 2013
    IF V_AUART = 'ZTC1' OR V_AUART = 'ZTC2'.
      CLEAR: V_MBLNR, V_MJAHR.
      SELECT MBLNR MJAHR AUFNR
        INTO (V_MBLNR,V_MJAHR,V_COMORD)
        FROM MSEG
       WHERE CHARG = WA_INBATCH-CHARG AND BWART = '901'
         AND BUDAT_MKPF BETWEEN V_FDATE AND V_EDATE. "ADDED BY FATHIR ON 19.05.2021 - get PO by current month
*        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z07")'.
        IF V_MBLNR NE SPACE AND V_MJAHR NE SPACE.
          SELECT SINGLE SMBLN
            INTO V_MBLNR
            FROM MSEG
           WHERE SMBLN = V_MBLNR AND BWART = '902'.
*            %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z09")'.
          IF SY-SUBRC NE 0.
            CLEAR: WA_SCRAP.
            WA_SCRAP-CHARG   = WA_INBATCH-CHARG.
            WA_SCRAP-MBLNR   = V_MBLNR.
            WA_SCRAP-MJAHR   = V_MJAHR.
            WA_SCRAP-COM_ORD = V_COMORD.
            APPEND WA_SCRAP TO IT_SCRAP.
          ENDIF.
        ENDIF.
      ENDSELECT.
    ELSE.
****End Tambahan 28 January 2013
      CLEAR: V_MBLNR, V_MJAHR.
      SELECT MBLNR MJAHR AUFNR
        INTO (V_MBLNR,V_MJAHR,V_COMORD)
        FROM MSEG
       WHERE CHARG = WA_INBATCH-CHARG AND BWART = '261'
         AND BUDAT_MKPF BETWEEN V_FDATE AND V_EDATE. "ADDED BY FATHIR ON 19.05.2021 - get PO by current month
*        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z07")'.
        IF V_MBLNR NE SPACE AND V_MJAHR NE SPACE.
          SELECT SINGLE SMBLN
            INTO V_MBLNR
            FROM MSEG
           WHERE SMBLN = V_MBLNR AND BWART = '262'.
*            %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z09")'.
          IF SY-SUBRC NE 0.
            CLEAR: WA_SCRAP.
            WA_SCRAP-CHARG   = WA_INBATCH-CHARG.
            WA_SCRAP-MBLNR   = V_MBLNR.
            WA_SCRAP-MJAHR   = V_MJAHR.
            WA_SCRAP-COM_ORD = V_COMORD.
            APPEND WA_SCRAP TO IT_SCRAP.
          ENDIF.
        ENDIF.
      ENDSELECT.
    ENDIF.

  ENDLOOP.

**Get Original Order
  CLEAR: WA_SCRAP, WA_SCRAPOR, IT_SCRAPOR.
  REFRESH: IT_SCRAPOR.
  LOOP AT IT_SCRAP INTO WA_SCRAP.
    CLEAR: WA_SCRAPOR.
    SELECT AUFNR MILL_OC_AUFNR_U
      INTO (WA_SCRAPOR-COMORD,WA_SCRAPOR-ORORD)
      FROM AFPO
     WHERE AUFNR = WA_SCRAP-COM_ORD.
      APPEND WA_SCRAPOR TO IT_SCRAPOR.
      CLEAR: WA_SCRAPOR.
    ENDSELECT.
  ENDLOOP.

  CLEAR: WA_SCRAPOR, WA_SCRAP.
  LOOP AT IT_SCRAP INTO WA_SCRAP.
*******    CLEAR: WA_SCRAPOR.
*******    LOOP AT IT_SCRAPOR INTO WA_SCRAPOR WHERE COMORD = WA_SCRAP-COM_ORD.

    CLEAR: V_OBJNR.
    SELECT SINGLE OBJNR
      INTO V_OBJNR
      FROM AUFK
     WHERE AUFNR = WA_SCRAP-COM_ORD.
    IF SY-SUBRC = 0.
      SELECT SINGLE * FROM JEST INTO *JEST WHERE OBJNR = V_OBJNR
                                             AND STAT  = 'I0046'
                                             AND INACT = ''.
      IF SY-SUBRC = 0.
        WA_SCRAP-CLSD = 'X'.
      ELSE.
        WA_SCRAP-CLSD = ''.
      ENDIF.
    ENDIF.

    SELECT SINGLE MENGE
      INTO WA_SCRAP-MENGE
      FROM MSEG
     WHERE MBLNR = WA_SCRAP-MBLNR AND MJAHR = WA_SCRAP-MJAHR AND CHARG = WA_SCRAP-CHARG.
    MODIFY IT_SCRAP FROM WA_SCRAP TRANSPORTING CLSD MENGE.
*******      CLEAR: V_101, V_102.
*******      SELECT SUM( MENGE )
*******        INTO V_101
*******        FROM MSEG
*******       WHERE AUFNR = WA_SCRAPOR-ORORD AND BWART = '101'.
********        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z08")'.
*******      SELECT SUM( MENGE )
*******        INTO V_102
*******        FROM MSEG
*******       WHERE AUFNR = WA_SCRAPOR-ORORD AND BWART = '102'.
********        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z08")'.
*******      WA_SCRAPOR-MENGE = V_101 - V_102.
*******
*******      WA_SCRAPOR-CHARG  = WA_SCRAP-CHARG.
*******      MODIFY IT_SCRAPOR FROM WA_SCRAPOR TRANSPORTING MENGE CHARG CLSD.
*******    ENDLOOP.

  ENDLOOP.

**Delete combine order yg di closed
*******  DELETE IT_SCRAPOR WHERE CLSD = 'X'.
  DELETE IT_SCRAP WHERE CLSD = 'X'.

*****  CLEAR: WA_SCRAPOR, WA_TOTSCRAP, IT_TOTSCRAP.
*****  REFRESH: IT_TOTSCRAP.
*****
*****  IT_TOTSCRAP[] = IT_SCRAPOR[].
*****  SORT IT_TOTSCRAP BY COMORD.
*****  DELETE ADJACENT DUPLICATES FROM IT_TOTSCRAP COMPARING COMORD.
*****
*******Get total quantity per combine order
*****  CLEAR: WA_TOTSCRAP.
*****  LOOP AT IT_TOTSCRAP INTO WA_TOTSCRAP.
*****    CLEAR: WA_SCRAPOR.
*****    LOOP AT IT_SCRAPOR INTO WA_SCRAPOR WHERE COMORD = WA_TOTSCRAP-COMORD.
*****      WA_TOTSCRAP-TOTCOM = WA_TOTSCRAP-TOTCOM + WA_SCRAPOR-MENGE.
*****    ENDLOOP.
*****    MODIFY IT_TOTSCRAP FROM WA_TOTSCRAP TRANSPORTING TOTCOM.
*****  ENDLOOP.

**Get total quantity per batch GI
  CLEAR: IT_SCRAP2.
  REFRESH: IT_SCRAP2.
  IT_SCRAP2[] = IT_SCRAP[].
  SORT IT_SCRAP BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_SCRAP COMPARING CHARG.
  CLEAR: WA_SCRAP.
  LOOP AT IT_SCRAP INTO WA_SCRAP.
    CLEAR: WA_SCRAP-MENGE.
    LOOP AT IT_SCRAP2 ASSIGNING <FS_SCRAP2> WHERE CHARG = WA_SCRAP-CHARG.
      WA_SCRAP-MENGE = WA_SCRAP-MENGE + <FS_SCRAP2>-MENGE.
    ENDLOOP.
    MODIFY IT_SCRAP FROM WA_SCRAP TRANSPORTING MENGE.
  ENDLOOP.

*********Get total quantity per batch
*******  CLEAR: IT_TOTBATCH, WA_TOTBATCH.
*******  REFRESH: IT_TOTBATCH.
*******  IT_TOTBATCH[] = IT_TOTSCRAP[].
*******  SORT IT_TOTBATCH BY CHARG.
*******  DELETE ADJACENT DUPLICATES FROM IT_TOTBATCH COMPARING CHARG.
*******  LOOP AT IT_TOTBATCH INTO WA_TOTBATCH.
*******    CLEAR: WA_TOTSCRAP.
*******    LOOP AT IT_TOTSCRAP INTO WA_TOTSCRAP WHERE CHARG = WA_TOTBATCH-CHARG.
*******      WA_TOTBATCH-TOTBCH = WA_TOTBATCH-TOTBCH + WA_TOTSCRAP-TOTCOM.
*******    ENDLOOP.
*******    MODIFY IT_TOTBATCH FROM WA_TOTBATCH TRANSPORTING TOTBCH.
*******  ENDLOOP.

  CLEAR: WA_INBATCH.

  LOOP AT IT_INBATCH INTO WA_INBATCH WHERE CLABS > 0.

    CLEAR: GMHEAD, GMCODE, MTHEAD, ITAB, ERRMSG, V_MATNR, V_CHARG,
           V_LENGTH, V_EXTRA, V_WIDTH, V_LENGTHSHT.
    REFRESH: ITAB, ERRMSG.

    GMHEAD-PSTNG_DATE = SY-DATUM.
    GMHEAD-DOC_DATE   = SY-DATUM.
    GMHEAD-PR_UNAME   = SY-UNAME.
    GMHEAD-HEADER_TXT = COM_ORDER."wa_inbatch-charg.
*    gmhead-REF_DOC_NO = 'SCR'.
    CONCATENATE 'SCR;' WA_INBATCH-CHARG INTO GMHEAD-REF_DOC_NO.
    GMCODE-GM_CODE    = '03'.

    CLEAR: V_WERKS, V_MATNR, V_MEINS, V_LGORT, V_MATRAW.
    SELECT SINGLE WERKS
      INTO V_WERKS
      FROM MCHB
     WHERE MATNR = WA_INBATCH-MATNR AND CHARG = WA_INBATCH-CHARG AND CLABS > 0. "Penambahan CLABS > 0 6February2013
*      %_HINTS ORACLE 'INDEX("MCHB" "MCHB~Z02")'.

    SELECT SINGLE RAR_A_MATNR
      INTO V_MATRAW
      FROM ZTMAP_MATRECYCLE
     WHERE FILMT = WA_INBATCH-MATNR+2(3) AND ZTMAP_MATRECYCLE~WERKS = V_WERKS. "ADD PLANT NEW COMPANY.

    SELECT SINGLE MEINS
      INTO V_MEINS
      FROM MARA
     WHERE MATNR = V_MATRAW.

*******    CLEAR: v_ZSLLGORT.
*******    SELECT SINGLE ZSLLGORT
*******      INTO v_ZSLLGORT
*******      FROM ZTMAP_SLOCRR
*******     WHERE ZLINE = WA_INBATCH-ZZPRODLINE.

    V_MATNR = WA_INBATCH-MATNR.
    V_CHARG = WA_INBATCH-CHARG.

    CLEAR: V_MEINS2.
    SELECT SINGLE MEINS
      INTO V_MEINS2
      FROM MARA
     WHERE MATNR = WA_INBATCH-MATNR.

    PERFORM GET_LENGTH_WIDTH USING V_MATNR V_CHARG
                             CHANGING V_LENGTH V_EXTRA V_WIDTH V_LENGTHSHT.

    CLEAR: WA_TOTSCRAP, CTRLINE, V_TOTENTRY, LS_TABIX, IT_TOTSCRAP2, IT_SCRAPTMP.
    REFRESH: IT_TOTSCRAP2, IT_SCRAPTMP.
    IT_SCRAPTMP[] = IT_SCRAP2[].
    DELETE IT_SCRAPTMP WHERE CHARG NE WA_INBATCH-CHARG.
    DELETE IT_SCRAPTMP WHERE MENGE <= 0.
    DESCRIBE TABLE IT_SCRAPTMP LINES CTRLINE.
    CLEAR: WA_SCRAP.
    LOOP AT IT_SCRAP2 INTO WA_SCRAP WHERE CHARG = WA_INBATCH-CHARG AND MENGE > 0.
      ADD 1 TO LS_TABIX.
      CLEAR: ITAB.
      ITAB-MOVE_TYPE      = '531'.
      ITAB-MATERIAL       = V_MATRAW.
      ITAB-PLANT          = V_WERKS.
      ITAB-STGE_LOC       = V_ZSLLGORT.
      ITAB-ORDERID        = WA_SCRAP-COM_ORD.
*******      CLEAR: WA_TOTBATCH, V_TOTBCH.
*******      READ TABLE IT_TOTBATCH INTO WA_TOTBATCH WITH KEY CHARG = WA_TOTSCRAP-CHARG.
*******      IF SY-SUBRC = 0.
*******        V_TOTBCH = WA_TOTBATCH-TOTBCH.
*******      ENDIF.
*******      IF LS_TABIX = CTRLINE.
*******        ITAB-ENTRY_QNT      = WA_INBATCH-CLABS - V_TOTENTRY.
*******      ELSE.
*******        ITAB-ENTRY_QNT      = ( WA_TOTSCRAP-TOTCOM / V_TOTBCH ) * WA_INBATCH-CLABS.
*******      ENDIF.
      CLEAR: WA_TOTBATCH, V_TOTBCH.
      READ TABLE IT_SCRAP ASSIGNING <FS_SCRAP2> WITH KEY CHARG = WA_SCRAP-CHARG.
      IF SY-SUBRC = 0.
        V_TOTBCH = <FS_SCRAP2>-MENGE.
      ENDIF.
      IF LS_TABIX = CTRLINE.
        ITAB-ENTRY_QNT      = WA_INBATCH-CLABS - V_TOTENTRY.
      ELSE.
        ITAB-ENTRY_QNT      = ( WA_SCRAP-MENGE / V_TOTBCH ) * WA_INBATCH-CLABS.
      ENDIF.
      V_TOTENTRY = V_TOTENTRY + ITAB-ENTRY_QNT.
*      itab-BATCH          = wa_totscrap-charg.
      ITAB-ENTRY_UOM      = V_MEINS.
      CONCATENATE V_LENGTH ';' V_EXTRA ';' V_WIDTH ';' V_LENGTHSHT INTO ITAB-ITEM_TEXT.
      APPEND ITAB.

******Tambahan Line Batch buat movement type 261
**Tambahan 28 January 2013
      IF V_AUART = 'ZTC1' OR V_AUART = 'ZTC2'.
        ITAB-MOVE_TYPE      = '901'.
      ELSE.
**End Tambahan 28 January 2013
        ITAB-MOVE_TYPE      = '261'.
      ENDIF.
      ITAB-MATERIAL       = WA_INBATCH-MATNR.
      ITAB-PLANT          = V_WERKS.
      ITAB-STGE_LOC       = WA_INBATCH-LGORT.
      ITAB-ENTRY_UOM      = V_MEINS2.
      ITAB-BATCH          = WA_INBATCH-CHARG.
      APPEND ITAB.
******End Tambahan Line Batch buat movement type 261
    ENDLOOP.
*******    REFRESH: IT_TOTSCRAP2.
********    DESCRIBE TABLE IT_TOTSCRAP LINES CTRLINE.
*******    IT_TOTSCRAP2[] = IT_TOTSCRAP[].
*******    DELETE IT_TOTSCRAP2 WHERE CHARG NE WA_INBATCH-CHARG.
*******    DELETE IT_TOTSCRAP2 WHERE TOTCOM <= 0.
*******    DESCRIBE TABLE IT_TOTSCRAP2 LINES CTRLINE.
*******    LOOP AT IT_TOTSCRAP INTO WA_TOTSCRAP WHERE CHARG = WA_INBATCH-CHARG AND TOTCOM > 0.
*******      ADD 1 TO LS_TABIX.
*******      CLEAR: ITAB.
*******      ITAB-MOVE_TYPE      = '531'.
*******      ITAB-MATERIAL       = V_MATRAW.
*******      ITAB-PLANT          = V_WERKS.
*******      ITAB-STGE_LOC       = V_ZSLLGORT.
*******      ITAB-ORDERID        = WA_TOTSCRAP-COMORD.
*******      CLEAR: WA_TOTBATCH, V_TOTBCH.
*******      READ TABLE IT_TOTBATCH INTO WA_TOTBATCH WITH KEY CHARG = WA_TOTSCRAP-CHARG.
*******      IF SY-SUBRC = 0.
*******        V_TOTBCH = WA_TOTBATCH-TOTBCH.
*******      ENDIF.
*******      IF LS_TABIX = CTRLINE.
*******        ITAB-ENTRY_QNT      = WA_INBATCH-CLABS - V_TOTENTRY.
*******      ELSE.
*******        ITAB-ENTRY_QNT      = ( WA_TOTSCRAP-TOTCOM / V_TOTBCH ) * WA_INBATCH-CLABS.
*******      ENDIF.
*******      V_TOTENTRY = V_TOTENTRY + ITAB-ENTRY_QNT.
********      itab-BATCH          = wa_totscrap-charg.
*******      ITAB-ENTRY_UOM      = V_MEINS.
*******      CONCATENATE V_LENGTH ';' V_EXTRA ';' V_WIDTH ';' V_LENGTHSHT INTO ITAB-ITEM_TEXT.
*******      APPEND ITAB.
*******
*************Tambahan Line Batch buat movement type 261
*******      ITAB-MOVE_TYPE      = '261'.
*******      ITAB-MATERIAL       = WA_INBATCH-MATNR.
*******      ITAB-PLANT          = V_WERKS.
*******      ITAB-STGE_LOC       = WA_INBATCH-LGORT.
*******      ITAB-ENTRY_UOM      = V_MEINS2.
*******      ITAB-BATCH          = WA_INBATCH-CHARG.
*******      APPEND ITAB.
*************End Tambahan Line Batch buat movement type 261
*******
*******    ENDLOOP.

    CLEAR: ERRMSG, MTHEAD, ITAB_SCRAP, ITAB_SCRAP2, WA_SCRAP1, WA_SCRAP2.
    REFRESH: ERRMSG, ITAB_SCRAP, ITAB_SCRAP2.

    ITAB_SCRAP[] = ITAB[].
    DELETE ITAB_SCRAP WHERE MOVE_TYPE NE '531'.
    ITAB_SCRAP2[] = ITAB_SCRAP[].
*    SORT ITAB_SCRAP BY MOVE_TYPE.
*    DELETE ADJACENT DUPLICATES FROM ITAB_SCRAP COMPARING MOVE_TYPE.
    SORT ITAB_SCRAP BY MOVE_TYPE STGE_LOC.
    DELETE ADJACENT DUPLICATES FROM ITAB_SCRAP COMPARING MOVE_TYPE STGE_LOC.

****Tambahan kalau entry qty nya <= 0, ga dilakukan BAPI nya 5 Nov 2012
    CLEAR: FLAG.
    DELETE ITAB WHERE ENTRY_QNT <= 0.
    READ TABLE ITAB INDEX 1.
    IF SY-SUBRC NE 0.
      FLAG = 'X'.
    ENDIF.
    CHECK FLAG EQ SPACE.
****End Tambahan kalau entry qty nya <= 0, ga dilakukan BAPI nya 5 Nov 2012

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER       = GMHEAD
        GOODSMVT_CODE         = GMCODE
*       TESTRUN               = ' '
      IMPORTING
        GOODSMVT_HEADRET      = MTHEAD
*       MATERIALDOCUMENT      =
*       MATDOCUMENTYEAR       =
      TABLES
        GOODSMVT_ITEM         = ITAB
*       GOODSMVT_SERIALNUMBER =
        RETURN                = ERRMSG.

    CLEAR: FLAG, VMESS.
    LS_SUBRC = 0.
    LOOP AT ERRMSG WHERE TYPE = 'E'.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Scrap Batch Inputan'.                  "#EC NOTEXT
      IT_LOG-MESS = ERRMSG-MESSAGE.
      APPEND IT_LOG.
    ENDLOOP.

    CLEAR: SY-SUBRC.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE 'No.Mat.Doc :' MTHEAD+0(10) '--' 'Fiscal Year' MTHEAD+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      V_MBLNR = MTHEAD+0(10).
      V_MJAHR = MTHEAD+10(4).
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Scrap Batch Inputan'.                  "#EC NOTEXT
      IT_LOG-MESS = VMESS."'Success'.
      APPEND IT_LOG.
    ENDIF.

    IF FLAG EQ SPACE.
      V_MATNR = WA_INBATCH-MATNR.
      V_CHARG = WA_INBATCH-CHARG.
      PERFORM CHANGE_BATCH_INPUTAN_SCRAP USING V_MATNR V_CHARG.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " SCRAP_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*&      Form  COLLECT_DATA_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COLLECT_DATA_CANCEL .

**Get class dulu
  CLEAR: CLASS, V_MATNR.
  SELECT SINGLE MATNR
    INTO V_MATNR
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND MATNR NE SPACE.
  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      I_MATNR      = V_MATNR
      I_MARA_LEVEL = 'X'
    IMPORTING
      E_CLASS      = CLASS.

  CLEAR: RIBUAN, PULUHAN.
**  PERFORM GET_DEC_NOTATION USING SY-UNAME CHANGING RIBUAN PULUHAN.
  PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.

  CLEAR: IT_CANCEL, WA_CANCEL, IT_REVERSAL, WA_REVERSAL.
  REFRESH: IT_CANCEL, IT_REVERSAL, IT_LOG.

**Ambil semua matdoc & matdoc year
  SELECT MBLNR MJAHR
    INTO CORRESPONDING FIELDS OF TABLE IT_CANCEL
    FROM MKPF
   WHERE BKTXT = COM_ORDER ##TOO_MANY_ITAB_FIELDS.

**Ambil dokumen reversal nya
  CLEAR: WA_CANCEL.
  LOOP AT IT_CANCEL INTO WA_CANCEL.

    SELECT SINGLE BWART SJAHR SMBLN SGTXT CHARG MATNR XBLNR_MKPF
      INTO (WA_CANCEL-BWART, WA_CANCEL-SJAHR, WA_CANCEL-SMBLN, WA_CANCEL-SGTXT,
            WA_CANCEL-CHARG, WA_CANCEL-MATNR, WA_CANCEL-XBLNR_MKPF)
      FROM MSEG
     WHERE MBLNR = WA_CANCEL-MBLNR AND MJAHR = WA_CANCEL-MJAHR.
*      %_HINTS ORACLE 'INDEX("MSEG" "MSEG~Z10")'.

    MODIFY IT_CANCEL FROM WA_CANCEL TRANSPORTING BWART SJAHR SMBLN SGTXT CHARG MATNR XBLNR_MKPF.

  ENDLOOP.

  CLEAR: IT_REVERSAL, WA_REVERSAL.
  REFRESH: IT_REVERSAL.

  IT_REVERSAL[] = IT_CANCEL[].

**Hapus yang ada matdoc reversal
  DELETE IT_CANCEL WHERE SMBLN NE ''.

**Hapus yang gada matdoc reversal
  DELETE IT_REVERSAL WHERE SMBLN = ''.

  CLEAR: WA_REVERSAL.
  LOOP AT IT_REVERSAL INTO WA_REVERSAL.
    CLEAR: WA_CANCEL.
    LOOP AT IT_CANCEL INTO WA_CANCEL WHERE MBLNR = WA_REVERSAL-SMBLN AND
                                           MJAHR = WA_REVERSAL-SJAHR.

******Reversal Indicator
      WA_CANCEL-FLAG = 'R'.
      MODIFY IT_CANCEL FROM WA_CANCEL TRANSPORTING FLAG.

    ENDLOOP.
  ENDLOOP.

**Hapus matdoc yg di reverse
  DELETE IT_CANCEL WHERE FLAG = 'R'.

*********Cek Stok Cancel GR (101)
*******  DATA: BEGIN OF IT_GR OCCURS 0,
*******          CHARG LIKE MSEG-CHARG, " Batch
*******          MENGE LIKE MSEG-MENGE, " Quantity GR
*******          CLABS LIKE MCHB-CLABS, " Unrestricted
*******        END OF IT_GR.
*******  DATA: wa_gr LIKE LINE OF it_gr.
*******
*******  CLEAR: wa_cancel.
*******  READ TABLE it_cancel INTO wa_cancel WITH KEY bwart = '101'.
*******  IF sy-subrc = 0.
*******
*******    SELECT CHARG MENGE
*******      INTO CORRESPONDING FIELDS OF TABLE it_gr
*******      FROM mseg
*******     WHERE MBLNR = wa_cancel-mblnr and MJAHR = wa_cancel-mjahr.
*******
*******    CLEAR: wa_gr, flag.
*******    LOOP AT it_gr INTO wa_gr.
*******
*******      CHECK flag eq space.
*******
*******      SELECT SINGLE CLABS
*******        INTO WA_GR-CLABS
*******        FROM MCHB
*******       WHERE CHARG = wa_gr-charg.
*******
*******      MODIFY it_gr FROM wa_gr TRANSPORTING clabs.
*******
*******      IF wa_gr-menge > wa_gr-clabs.
*******        MESSAGE i001(00) WITH 'Stok Slitting Tidak Cukup Untuk Dicancel'.
*******        flag = 'X'.
*******        EXIT.
*******      ENDIF.
*******
*******    ENDLOOP.
*******
*******    IF flag = 'X'.
*******      EXIT.
*******    ENDIF.
*******
*******  ENDIF.

ENDFORM.                    " COLLECT_DATA_CANCEL
*&---------------------------------------------------------------------*
*&      Form  UNDO_CHANGE_BATCH_ORIG_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNDO_CHANGE_BATCH_ORIG_ORDER .

  CLEAR: WA_POS, FLAG.
  LOOP AT ITAB_POS INTO WA_POS.

    CHECK FLAG EQ SPACE.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = WA_POS-MATNR
        I_CHARG      = WA_POS-CHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_POS-MATNR
        CHARG                    = WA_POS-CHARG
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.
    IF CLASS = 'ZZSRSHEET'.
*     Set ZZLENGTHSHT
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_POS-LENG.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = WA_POS-LENG.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
*     Set ZZLENGTH
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = WA_POS-LENG.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = WA_POS-LENG.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.

*   Set ZZWIDTH
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR = WA_POS-WIDTH.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZWIDTH'.
      IT_CHAR-VALUE_CHAR = WA_POS-WIDTH.
      APPEND IT_CHAR.
    ENDIF.
*   Set ZZEXLENGTH
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR = WA_POS-EXTRA.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZEXLENGTH'.
      IT_CHAR-VALUE_CHAR = WA_POS-EXTRA.
      APPEND IT_CHAR.
    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
*      IF it_return2-type = 'E' and ls_subrc = 0.
      CLEAR: VMESS.
      CONCATENATE WA_POS-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Undo Change Batch Original Order'.     "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
*      ENDIF.
    ENDLOOP.

    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE WA_POS-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Undo Change Batch Original Order'.     "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " UNDO_CHANGE_BATCH_ORIG_ORDER
*&---------------------------------------------------------------------*
*&      Form  PROCESS_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_CANCEL .
*BREAK-POINT.
  DATA: FLAG2,
        PROC TYPE I.
  DATA: IT_STATUS TYPE TABLE OF JSTAT,
        WA_STATUS TYPE JSTAT,
        V_OBJNR LIKE AUFK-OBJNR.
  CLEAR: WA_STATUS, IT_STATUS.
  REFRESH:IT_STATUS.
  WA_STATUS-STAT  = 'I0045'.
  WA_STATUS-INACT = 'X'.
  APPEND WA_STATUS TO IT_STATUS.
  CLEAR: WA_STATUS.
  WA_STATUS-STAT  = 'I0002'.
  WA_STATUS-INACT = ''.
  APPEND WA_STATUS TO IT_STATUS.

  SELECT SINGLE RUECK RMZHL
    FROM AFRU
    INTO (V_RUECK,V_RMZHL)
   WHERE AUFNR = COM_ORDER AND STOKZ = '' AND STZHL = ''.
*    %_HINTS ORACLE 'INDEX("AFRU" "AFRU~Z02")'.

  IF V_RUECK = SPACE OR V_RUECK = '0000000000'.
*******    MESSAGE i001(00) WITH 'Tidak ada konfirmasi yang dicancel'.
    FLAG2 = 'X'.
  ENDIF.

  CLEAR: FLG.
  IF FLAG2 = ''.
*  *Popup get values reason cancel confirmation
    DATA: ANSWER   TYPE C,
          VALUEOUT LIKE AFRU-LTXA1.
    CALL FUNCTION 'POPUP_TO_GET_VALUE'
      EXPORTING
        FIELDNAME           = 'LTXA1'
        TABNAME             = 'AFRU'
        TITEL               = 'Alasan Cancel'               "#EC NOTEXT
        VALUEIN             = ''
      IMPORTING
        ANSWER              = ANSWER
        VALUEOUT            = VALUEOUT
      EXCEPTIONS
        FIELDNAME_NOT_FOUND = 1
        OTHERS              = 2
      .                                                   "#EC FB_OLDED
    IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      FLG = 'X'.
    ENDIF.
    IF ANSWER = 'C'.
      FLG = 'X'.
    ENDIF.
  ENDIF.

  IF FLG = ''.

    PROC = 0.

***Revoke TECO Status Original Order
*    BREAK-POINT.
    CLEAR: FLAG.
    DELETE V_AFPO WHERE AUFNR NE COM_ORDER.
    LOOP AT V_AFPO.
      CHECK FLAG EQ SPACE.
      CLEAR: E_SYSST.
      PERFORM GET_STATUS USING V_AFPO-ZMILL CHANGING E_SYSST.
      IF E_SYSST CP '*TECO*'.
        ADD 1 TO PROC.
        CLEAR: V_OBJNR.
        SELECT SINGLE OBJNR
          INTO V_OBJNR
          FROM AUFK
         WHERE AUFNR = V_AFPO-ZMILL.
        IF SY-SUBRC = 0 AND V_OBJNR NE SPACE.

          CALL FUNCTION 'STATUS_CHANGE_INTERN'
            EXPORTING
              CLIENT                    = SY-MANDT
              OBJNR                     = V_OBJNR
*           IMPORTING
*             ERROR_OCCURRED            =
*             OBJECT_NOT_FOUND          =
*             STATUS_INCONSISTENT       =
*             STATUS_NOT_ALLOWED        =
            TABLES
              STATUS                    = IT_STATUS
            EXCEPTIONS
              OBJECT_NOT_FOUND          = 1
              STATUS_INCONSISTENT       = 2
              STATUS_NOT_ALLOWED        = 3
              OTHERS                    = 4
                    .
          IF SY-SUBRC <> 0.
            FLAG = 'X'.
            CLEAR: VMESS.
            CONCATENATE 'Order' V_AFPO-ZMILL 'gagal di unteco' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
            FLAG = 'X'.
            IT_LOG-ICON = '@0A@'.
            IT_LOG-TRNS = 'Revoke TECO Original Order'.     "#EC NOTEXT
            IT_LOG-MESS = VMESS.
          ELSE.
            COMMIT WORK.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDLOOP.

****Revoke TECO Combine Order
    IF FLAG EQ SPACE.

      READ TABLE V_AFPO INDEX 1.
      IF SY-SUBRC = 0.

        CLEAR: E_SYSST.
        PERFORM GET_STATUS USING COM_ORDER CHANGING E_SYSST.
        IF E_SYSST CP '*TECO*'.
          ADD 1 TO PROC.
          CLEAR: V_OBJNR.
          SELECT SINGLE OBJNR
            INTO V_OBJNR
            FROM AUFK
           WHERE AUFNR = COM_ORDER.
          IF SY-SUBRC = 0 AND V_OBJNR NE SPACE.

            CALL FUNCTION 'STATUS_CHANGE_INTERN'
              EXPORTING
                CLIENT                    = SY-MANDT
                OBJNR                     = V_OBJNR
*             IMPORTING
*               ERROR_OCCURRED            =
*               OBJECT_NOT_FOUND          =
*               STATUS_INCONSISTENT       =
*               STATUS_NOT_ALLOWED        =
              TABLES
                STATUS                    = IT_STATUS
              EXCEPTIONS
                OBJECT_NOT_FOUND          = 1
                STATUS_INCONSISTENT       = 2
                STATUS_NOT_ALLOWED        = 3
                OTHERS                    = 4
                      .
            IF SY-SUBRC <> 0.
              FLAG = 'X'.
              CLEAR: VMESS.
              CONCATENATE 'Order' COM_ORDER 'gagal di unteco' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
              FLAG = 'X'.
              IT_LOG-ICON = '@0A@'.
              IT_LOG-TRNS = 'Revoke TECO Combine Order'.    "#EC NOTEXT
              IT_LOG-MESS = VMESS.
            ELSE.
              COMMIT WORK.
            ENDIF.

          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

*  *Cancel Mat.doc SO To SO
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '413'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Mat.Doc SO To SO'.          "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GR'.                        "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        CLEAR: SY-SUBRC.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel Mat.Doc SO To SO'.          "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
        ENDIF.

      ENDIF.
    ENDIF.

*  *Cancel Mat.doc SO To Unres
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
*      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '311' SGTXT = 'UNREST'.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '411' SGTXT = 'UNREST'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Mat.Doc SO To Unres'.       "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GR'.                        "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        CLEAR: SY-SUBRC.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel Mat.Doc SO To Unres'.       "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
        ENDIF.
      ENDIF.
    ENDIF.

*  *Cancel Mat.doc GR
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '101'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GR'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        CLEAR: SY-SUBRC.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel GR'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          IF CLASS NE 'ZZSRSHEET'.
            PERFORM REVERSE_ZZEXLENGTH.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*  *Cancel Mat.doc Sloc To Sloc Scrap Batch Inputan
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
***      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '311' SGTXT = 'SCRAP'.
***      IF SY-SUBRC = 0.
      LOOP AT IT_CANCEL INTO WA_CANCEL WHERE BWART = '311' AND SGTXT = 'SCRAP'.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Transfer Sloc To Sloc Scrap'. "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel Transfer Sloc To Sloc Scrap'. "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
        ENDIF.
      ENDLOOP.
***      ENDIF.
    ENDIF.

*  *Cancel Mat.doc Scrap Batch Inputan
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
*  ****    READ TABLE it_cancel INTO wa_cancel WITH KEY bwart = '531'.
*  ****    IF sy-subrc = 0.
      LOOP AT IT_CANCEL INTO WA_CANCEL WHERE BWART = '531'.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.
        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        CLEAR: SY-SUBRC.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          IF WA_CANCEL-XBLNR_MKPF+0(3) = 'SCR'.
            CLEAR: V_CHARG, V_MATNR.
*            BREAK-POINT.
            V_CHARG = WA_CANCEL-XBLNR_MKPF+4(10).
            SELECT SINGLE MATNR
              INTO V_MATNR
              FROM MCH1
             WHERE CHARG = V_CHARG.
            PERFORM REVERSE_CHAR_BATCH_INPUTAN USING MATERIALDOCUMENT MATDOCUMENTYEAR.
          ENDIF.
        ENDIF.
      ENDLOOP.
*  ****    ENDIF.
    ENDIF.

*  *Cancel Mat.doc Sloc To Sloc
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '311' SGTXT = 'RAW'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Transfer Sloc To Sloc'.     "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel Transfer Sloc To Sloc'.     "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
        ENDIF.
      ENDIF.
    ENDIF.

*  *Cancel Mat.doc GI
    IF FLAG EQ SPACE.
      CLEAR: WA_CANCEL, V_BWART.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '261'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        V_BWART          = WA_CANCEL-BWART.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          PERFORM REVERSE_ZZLENGTH_BATCH_INPUTAN USING MATERIALDOCUMENT MATDOCUMENTYEAR V_BWART.
        ENDIF.
      ENDIF.
******Tambahan Untuk Cancel GI yang movement type nya 901 28 January 2013
      CLEAR: WA_CANCEL, V_BWART.
      READ TABLE IT_CANCEL INTO WA_CANCEL WITH KEY BWART = '901'.
      IF SY-SUBRC = 0.
        ADD 1 TO PROC.
        CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
        REFRESH: RETURN.
        MATERIALDOCUMENT = WA_CANCEL-MBLNR.
        MATDOCUMENTYEAR  = WA_CANCEL-MJAHR.
        V_BWART          = WA_CANCEL-BWART.
        PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.
        LOOP AT RETURN WHERE TYPE = 'E'.
          CLEAR: VMESS.
          CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS."'Failed'.
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.       "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = 'Cancel Confirmation'.              "#EC NOTEXT
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        IF LS_SUBRC = 0.
          PERFORM BAPI_COMMIT.
          CLEAR: VMESS.
          CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = 'Cancel GI'.                        "#EC NOTEXT
          IT_LOG-MESS = VMESS.
          APPEND IT_LOG.
          PERFORM REVERSE_ZZLENGTH_BATCH_INPUTAN USING MATERIALDOCUMENT MATDOCUMENTYEAR V_BWART.
        ENDIF.
      ENDIF.
******End Tambahan Untuk Cancel GI yang movement type nya 901 28 January 2013
    ENDIF.

*  *Cancel Confirmation
    IF V_RUECK NE '0000000000'. " Kalau gada nomor confirmation, jangan jalanin BDC nya 29 January 2013
      IF FLAG EQ SPACE AND FLAG2 EQ SPACE.

        ADD 1 TO PROC.

        REFRESH BDCDATA.
        PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5100'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'CORUF-RMZHL'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM BDC_FIELD       USING 'CORUF-RUECK'
                                      V_RUECK.
        PERFORM BDC_FIELD       USING 'CORUF-RMZHL'
                                      V_RMZHL.
        PERFORM BDC_FIELD       USING 'CORUF-AUFNR'
                                      ''.
        PERFORM BDC_FIELD       USING 'CORUF-VORNR'
                                      ''.
        PERFORM BDC_FIELD       USING 'CORUF-UVORN'
                                      ''.
        PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5150'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=LTXS'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'AFRUD-LMNGA'.
        PERFORM BDC_DYNPRO      USING 'SAPLSTXX' '1100'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'RSTXT-TXLINE(02)'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=TXBA'.
        PERFORM BDC_FIELD       USING 'RSTXT-TXLINE(02)'
                                      VALUEOUT.
        PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5150'.
        PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                      '=BU'.
        PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                      'AFRUD-LMNGA'.

        OPT-DISMODE = 'E'. "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
        OPT-UPDMODE = 'A'. "S: synchronously "A: asynchronously "L: local
        OPT-DEFSIZE = 'X'.

*        perform bdc_transaction using 'CORS'.
        REFRESH : MESSTAB.
        CALL TRANSACTION 'CORS' USING BDCDATA OPTIONS FROM OPT
                                MESSAGES INTO MESSTAB.
        REFRESH BDCDATA.

        LS_SUBRC = 0.
        CLEAR: VMESS, FLAG.

        LOOP AT MESSTAB WHERE MSGTYP = 'E'.
          CLEAR: VMESS.
          CONCATENATE 'Cancel Confirmation' V_RUECK INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          LS_SUBRC = 1.
          FLAG = 'X'.
          IT_LOG-ICON = '@0A@'.
          IT_LOG-TRNS = VMESS.
          IT_LOG-MESS = 'Failed'.                           "#EC NOTEXT
          APPEND IT_LOG.
        ENDLOOP.

        CLEAR: SY-SUBRC.

        IF LS_SUBRC = 0.
          CLEAR: VMESS.
          CONCATENATE 'Cancel Confirmation' V_RUECK INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
          IT_LOG-ICON = '@08@'.
          IT_LOG-TRNS = VMESS.
          IT_LOG-MESS = 'Success'.                          "#EC NOTEXT
          APPEND IT_LOG.
        ENDIF.

      ENDIF.
    ENDIF.


    IF PROC > 0.

******Hilangkan Message Log Yang Sukses
      CLEAR: VMESS.
      READ TABLE IT_LOG WITH KEY ICON = '@0A@'.
      IF SY-SUBRC = 0.
        DELETE IT_LOG WHERE ICON = '@08@'.
      ELSE.
        CLEAR: IT_LOG, VMESS.
        REFRESH: IT_LOG.
        IT_LOG-ICON = '@08@'.
        CONCATENATE 'Cancel Sliting Process' COM_ORDER INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
        IT_LOG-TRNS = VMESS.
        IT_LOG-MESS = 'Success'.                            "#EC NOTEXT
        APPEND IT_LOG.
      ENDIF.

      "Added By: Carfin on 22.04.2019 for RTP CORE
      DATA: BEGIN OF LT_CHARG OCCURS 0,
              CHARG LIKE MCH1-CHARG,
              DWERK LIKE AFPO-DWERK,
            END OF LT_CHARG.

      SELECT B~CHARG A~DWERK INTO TABLE LT_CHARG
        FROM AFPO AS A LEFT JOIN MCH1 AS B ON A~MILL_OC_AUFNR_U = B~LICHA
        WHERE A~AUFNR EQ COM_ORDER.

      LOOP AT LT_CHARG.
        PERFORM F_LEPAS_CORE_RTP USING LT_CHARG-CHARG LT_CHARG-DWERK.
      ENDLOOP.
      "Added By: Carfin on 22.04.2019 for RTP CORE

******End Hilangkan Message Log Yang Sukses

******fieldcatalogue for ALV dialog
****      SET TITLEBAR  'TLOGC'.
      PERFORM BUILD_FIELDCAT3.
******Layout for ALV dialog
      PERFORM BUILD_LAYOUT3.
******ALV dialog output
      I_GRID_TITLE = 'Log Process Batal Start-Stop'.        "#EC NOTEXT
      I_SCREEN_START_COLUMN = 5.
      I_SCREEN_START_LINE   = 3.
      I_SCREEN_END_COLUMN   = 60."77.
      I_SCREEN_END_LINE     = 15.
      PERFORM ALV3.
    ELSE.

      MESSAGE 'Order Belum Di Start/Stop' TYPE 'I'.         "#EC NOTEXT
      FLAG = 'X'.
      EXIT.

    ENDIF.

  ENDIF.

ENDFORM.                    " PROCESS_CANCEL
*&---------------------------------------------------------------------*
*&      Form  CANCEL_GOODSMVT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

  CLEAR: GOODSMVT_HEADRET, RETURN.
  REFRESH: RETURN.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = MATERIALDOCUMENT
      MATDOCUMENTYEAR     = MATDOCUMENTYEAR
*     GOODSMVT_PSTNG_DATE =
*     GOODSMVT_PR_UNAME   =
    IMPORTING
      GOODSMVT_HEADRET    = GOODSMVT_HEADRET
    TABLES
      RETURN              = RETURN.
*     GOODSMVT_MATDOCITEM       =
  .

ENDFORM.                    " CANCEL_GOODSMVT
*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_COMMIT .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.                    " BAPI_COMMIT
*&---------------------------------------------------------------------*
*&      Form  REVERSE_ZZEXLENGTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_ZZEXLENGTH .

  DATA: BEGIN OF IT_BATCH OCCURS 0,
          MATNR LIKE MCH1-MATNR,
          CHARG LIKE MCH1-CHARG,
          LICHA LIKE MCH1-LICHA,
        END OF IT_BATCH.
  DATA: WA_BATCH LIKE LINE OF IT_BATCH,
        V_ZZEXTRALENGTHASAL LIKE AUSP-ATWRT.

  LOOP AT V_AFPO.

    SELECT MATNR CHARG LICHA
      APPENDING CORRESPONDING FIELDS OF TABLE IT_BATCH
      FROM MCH1
     WHERE MATNR = V_AFPO-MATNR AND LICHA = V_AFPO-ZMILL.

  ENDLOOP.

  CLEAR: WA_BATCH, FLAG.
  LOOP AT IT_BATCH INTO WA_BATCH.

    CHECK FLAG EQ SPACE.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = WA_BATCH-MATNR
        I_CHARG      = WA_BATCH-CHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_BATCH-MATNR
        CHARG                    = WA_BATCH-CHARG
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.
*   Get ZZEXTRALENGTHASAL and Set to ''
    CLEAR: WA_CHAR2, V_ZZEXTRALENGTHASAL.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXTRALENGTHASAL'.
      V_ZZEXTRALENGTHASAL = WA_CHAR2-VALUE_CHAR.
**    Additional kalau udah cancel,zzextralengthasal dikosongin
      WA_CHAR2-VALUE_CHAR = ''.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
*   Set ZZEXLENGTH
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR = V_ZZEXTRALENGTHASAL.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZEXLENGTH'.
      IT_CHAR-VALUE_CHAR = V_ZZEXTRALENGTHASAL.
      APPEND IT_CHAR.
    ENDIF.

    CLEAR: V_WIDTH, V_LENGTH.
    SELECT SINGLE ZWIDTH ZLENGTH
      INTO (V_WIDTH, V_LENGTH)
      FROM AUFK
     WHERE AUFNR = WA_BATCH-LICHA.
    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_WIDTH
        IMPORTING
          OUTPUT = V_WIDTH.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_LENGTH
        IMPORTING
          OUTPUT = V_LENGTH.
    ENDIF.
*   Set ZZWIDTH
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR = V_WIDTH.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZWIDTH'.
      IT_CHAR-VALUE_CHAR = V_WIDTH.
      APPEND IT_CHAR.
    ENDIF.

*   Set ZZLENGTH
    IF CLASS = 'ZZSRSHEET'.
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = V_LENGTH.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = V_LENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        WA_CHAR2-VALUE_CHAR = V_LENGTH.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = V_LENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.

***Tambahan kalau di cancel ZZSPLICE nya dikosongin 03.01.2013
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-1'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR = ''.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZSPLICE-1'.
      IT_CHAR-VALUE_CHAR = ''.
      APPEND IT_CHAR.
    ENDIF.
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-2'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR  = ''.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZSPLICE-2'.
      IT_CHAR-VALUE_CHAR = ''.
      APPEND IT_CHAR.
    ENDIF.
    CLEAR: WA_CHAR2, LS_SUBRC.
    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZSPLICE-3'.
      LS_SUBRC = 1.
      WA_CHAR2-VALUE_CHAR  = ''.
      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
    ENDLOOP.
    IF LS_SUBRC = 0.
      IT_CHAR-CHARACT    = 'ZZSPLICE-3'.
      IT_CHAR-VALUE_CHAR = ''.
      APPEND IT_CHAR.
    ENDIF.
***End Tambahan kalau di cancel ZZSPLICE nya dikosongin 03.01.2013

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
      CLEAR: VMESS.
      CONCATENATE WA_BATCH-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Set Extralength Batch Original Order'. "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel GI'.                            "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.           "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel Confirmation'.                  "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
    ENDLOOP.
    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE WA_BATCH-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Set Extralength Batch Original Order'. "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " REVERSE_ZZEXLENGTH
*&---------------------------------------------------------------------*
*&      Form  REVERSE_ZZLENGTH_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_ZZLENGTH_BATCH_INPUTAN USING MATERIALDOCUMENT MATDOCUMENTYEAR V_BWART.

  DATA: BEGIN OF IT_BATCH OCCURS 0,
          MATNR LIKE MCH1-MATNR,
          CHARG LIKE MCH1-CHARG,
          SGTXT LIKE MSEG-SGTXT,
        END OF IT_BATCH.
  DATA: WA_BATCH LIKE LINE OF IT_BATCH.

  SELECT MATNR CHARG SGTXT
APPENDING CORRESPONDING FIELDS OF TABLE IT_BATCH
    FROM MSEG
   WHERE MBLNR = MATERIALDOCUMENT AND MJAHR = MATDOCUMENTYEAR AND
*         BWART = '261'.
         BWART = V_BWART. " Perubahan 28 January 2013

  CLEAR: WA_BATCH, FLAG.
  LOOP AT IT_BATCH INTO WA_BATCH.

    CHECK FLAG EQ SPACE.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC, MAX_LENGTH2, V_ZZJUMBOSHEETGI2.
    SPLIT WA_BATCH-SGTXT AT ';' INTO MAX_LENGTH2 V_ZZJUMBOSHEETGI2.
    CONDENSE MAX_LENGTH2 NO-GAPS.
    CONDENSE V_ZZJUMBOSHEETGI2 NO-GAPS.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = WA_BATCH-MATNR
        I_CHARG      = WA_BATCH-CHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = WA_BATCH-MATNR
        CHARG                    = WA_BATCH-CHARG
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.

    IF CLASS = 'ZZSRSHEET'.
*     Set ZZLENGTHSHT
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR + MAX_LENGTH2.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = MAX_LENGTH2."wa_batch-sgtxt.
        APPEND IT_CHAR.
      ENDIF.
*     Set ZZNUMBEROFSHEET
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZNUMBEROFSHEET'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR + V_ZZJUMBOSHEETGI2.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZNUMBEROFSHEET'.
        IT_CHAR-VALUE_CHAR = V_ZZJUMBOSHEETGI2."wa_batch-sgtxt.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
*     Set ZZLENGTH
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR + MAX_LENGTH2." wa_batch-sgtxt.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = MAX_LENGTH2."wa_batch-sgtxt.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
      CLEAR: VMESS.
      CONCATENATE WA_BATCH-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Set Length Batch Inputan'.             "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel Scrap Batch Inputan'.           "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel Confirmation'.                  "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
    ENDLOOP.
    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE WA_BATCH-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Set Length Batch Inputan'.             "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " REVERSE_ZZLENGTH_BATCH_INPUTAN

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  GET_PJG_LBR_JUMBO_SHEET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PJG_LBR_JUMBO_SHEET CHANGING P_FLAG.

  CLEAR: IT_DISPLAY2, WA_DISPLAY2.
  CLEAR: WA_DISPLAY2.
* Post Index
  WA_DISPLAY2-PIDX = 1.
* Post Keterangan
  WA_DISPLAY2-KET  = 'Jumlah Jumbo Sheet Yang Dipakai :'.   "#EC NOTEXT
* Post Order Number
  WA_DISPLAY2-JML  = ''.
  APPEND WA_DISPLAY2 TO IT_DISPLAY2.
  CLEAR: WA_DISPLAY2.
* Post Index
  WA_DISPLAY2-PIDX = 2.
* Post Keterangan
  WA_DISPLAY2-KET  = 'Panjang Jumbo Sheet Yang Digunakan (milimeter):'. "#EC NOTEXT
* Post Order Number
  WA_DISPLAY2-JML  = ''.
  APPEND WA_DISPLAY2 TO IT_DISPLAY2.

*fieldcatalogue for ALV dialog
  PERFORM BUILD_FIELDCAT4.
*Layout for ALV dialog
  PERFORM BUILD_LAYOUT4.
**ALV dialog output
  PERFORM ALV4.

  CLEAR: WA_DISPLAY2, V_ZZJUMBOSHEETGI, V_ZZLENGTHGI.
  READ TABLE IT_DISPLAY2 INTO WA_DISPLAY2 WITH KEY PIDX = 1.
  IF SY-SUBRC = 0.
    V_ZZJUMBOSHEETGI = WA_DISPLAY2-JML.
  ENDIF.
  CLEAR: WA_DISPLAY2.
  READ TABLE IT_DISPLAY2 INTO WA_DISPLAY2 WITH KEY PIDX = 2.
  IF SY-SUBRC = 0.
    V_ZZLENGTHGI = WA_DISPLAY2-JML.
  ENDIF.

  IF V_ZZJUMBOSHEETGI = ''.
*******    MESSAGE I001(00) WITH 'Jumlah Jumbo Sheet Yang Dipakai Harus Diisi'. "#EC NOTEXT
    MESSAGE 'Jumlah Jumbo Sheet Yang Dipakai Harus Diisi' TYPE 'I'. "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

  IF V_ZZLENGTHGI = ''.
*******    MESSAGE I001(00) WITH 'Panjang Jumbo Sheet Yang Digunakan Harus Diisi'. "#EC NOTEXT
    MESSAGE 'Panjang Jumbo Sheet Yang Digunakan Harus Diisi' TYPE 'I'. "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDIF.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*******  LOOP AT IT_INBATCH WHERE ZZLENGTH < V_ZZLENGTHGI.
  LOOP AT IT_INBATCH WHERE ZZLENGTH <= V_ZZLENGTHGI.
*******    MESSAGE I001(00) WITH 'panjang sheet yang digunakan > panjang batch inputan'. "#EC NOTEXT
*******    MESSAGE 'panjang sheet yang digunakan > panjang batch inputan' TYPE 'I'. "#EC NOTEXT
    MESSAGE 'panjang sheet yang digunakan >= panjang batch inputan' TYPE 'I'. "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

*******  LOOP AT IT_INBATCH WHERE ZZNUMBEROFSHEET < V_ZZJUMBOSHEETGI.
  LOOP AT IT_INBATCH WHERE ZZNUMBEROFSHEET <= V_ZZJUMBOSHEETGI.
*******    MESSAGE I001(00) WITH 'jumlah sheet yang digunakan lebih banyak dari jumlah sheet yang ada di batch'.
*******    MESSAGE 'jumlah sheet yang digunakan lebih banyak dari jumlah sheet yang ada di batch' TYPE 'I'.
    MESSAGE 'jumlah sheet yang digunakan >= jumlah sheet yang ada di batch' TYPE 'I'.
    P_FLAG  =  'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_PJG_LBR_JUMBO_SHEET

*&------------------------------------------------------------*
*&      Form  build_fieldcat4
*&------------------------------------------------------------*
FORM BUILD_FIELDCAT4 .
  CLEAR: LT_FIELDCATLOG4.
  REFRESH: LT_FIELDCATLOG4.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG4.
  LS_FIELDCATLOG4-ROW_POS   = '1'.
  LS_FIELDCATLOG4-COL_POS   = '1'.
  LS_FIELDCATLOG4-FIELDNAME = 'PIDX'.
  LS_FIELDCATLOG4-TABNAME   = 'IT_DISPLAY2'.
  LS_FIELDCATLOG4-SELTEXT_M = 'Index'.                      "#EC NOTEXT
  LS_FIELDCATLOG4-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG4 TO LT_FIELDCATLOG4.
  CLEAR LS_FIELDCATLOG4.
  LS_FIELDCATLOG4-ROW_POS   = '1'.
  LS_FIELDCATLOG4-COL_POS   = '2'.
  LS_FIELDCATLOG4-FIELDNAME = 'KET'.
  LS_FIELDCATLOG4-TABNAME   = 'IT_DISPLAY2'.
  LS_FIELDCATLOG4-SELTEXT_M = 'Keterangan'.                 "#EC NOTEXT
  APPEND LS_FIELDCATLOG4 TO LT_FIELDCATLOG4.
  CLEAR LS_FIELDCATLOG4.
  LS_FIELDCATLOG4-ROW_POS   = '1'.
  LS_FIELDCATLOG4-COL_POS   = '3'.
  LS_FIELDCATLOG4-FIELDNAME = 'JML'.
  LS_FIELDCATLOG4-TABNAME   = 'IT_DISPLAY2'.
  LS_FIELDCATLOG4-SELTEXT_M = 'Quantity'.                   "#EC NOTEXT
  LS_FIELDCATLOG4-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG4 TO LT_FIELDCATLOG4.
ENDFORM.                    " build_fieldcat4

*&----------------------------------------------------------*
*&      Form  build_layout4
*&----------------------------------------------------------*
*Layout for ALV dialog
FORM BUILD_LAYOUT4 .
  LT_LAYOUT4-ZEBRA = 'X'.
  LT_LAYOUT4-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " build_layout4
*&---------------------------------------------------------------*
*&      Form  alv4
*&---------------------------------------------------------------*
*Alv dialog output.
FORM ALV4.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Cast Sheet Information'   "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT4
      IT_FIELDCAT              = LT_FIELDCATLOG4
      I_SCREEN_START_COLUMN    = 5  "10
      I_SCREEN_START_LINE      = 3  "20
      I_SCREEN_END_COLUMN      = 60 "60 "100
      I_SCREEN_END_LINE        = 15 "30 "40
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND4'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS4'
    TABLES
      T_OUTTAB                 = IT_DISPLAY2
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " alv

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS4 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDPOPUP'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND4 USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CASE R_UCOMM.
    WHEN '&ONT'.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
        IMPORTING
          E_GRID = REF_GRID.

      IF REF_GRID IS NOT INITIAL.
        CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).  "After calling this method your internal table will have updated values
      ENDIF.

  ENDCASE.

ENDFORM. "user_command
*&---------------------------------------------------------------------*
*&      Form  GET_ZZCASTSHEETGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZZCASTSHEETGR CHANGING P_FLAG.

  CLEAR: IT_DISPLAY3, WA_DISPLAY3, WA_MAIN.
  REFRESH: IT_DISPLAY3.

  LOOP AT IT_MAIN INTO WA_MAIN.

    CONCATENATE WA_MAIN-ZPOST '-' WA_MAIN-AUFNR INTO WA_DISPLAY3-KET SEPARATED BY SPACE.
    WA_DISPLAY3-JML = ''.
    APPEND WA_DISPLAY3 TO IT_DISPLAY3.

  ENDLOOP.

*fieldcatalogue for ALV dialog
  PERFORM BUILD_FIELDCAT5.
*Layout for ALV dialog
  PERFORM BUILD_LAYOUT5.
**ALV dialog output
  PERFORM ALV5.

  CLEAR: WA_DISPLAY3.
  LOOP AT IT_DISPLAY3 INTO WA_DISPLAY3.

    CLEAR: WA_MAIN.
    LOOP AT IT_MAIN INTO WA_MAIN WHERE ZPOST = WA_DISPLAY3-KET+0(2).
      WA_MAIN-ZZCASTSHEETGR = WA_DISPLAY3-JML.
      MODIFY IT_MAIN FROM WA_MAIN TRANSPORTING ZZCASTSHEETGR.
    ENDLOOP.

  ENDLOOP.

  LOOP AT IT_MAIN WHERE ZZCASTSHEETGR = ''.
*******    MESSAGE I001(00) WITH 'Jumlah Cast Sheet Yang Dihasilkan Harus Diisi'. "#EC NOTEXT
    MESSAGE 'Jumlah Cast Sheet Yang Dihasilkan Harus Diisi' TYPE 'I'. "#EC NOTEXT
    P_FLAG  =  'X'.
    EXIT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_ZZCASTSHEETGR

*&------------------------------------------------------------*
*&      Form  build_fieldcat5
*&------------------------------------------------------------*
FORM BUILD_FIELDCAT5 .
  CLEAR: LT_FIELDCATLOG5.
  REFRESH: LT_FIELDCATLOG5.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG5.
  LS_FIELDCATLOG5-ROW_POS   = '1'.
  LS_FIELDCATLOG5-COL_POS   = '1'.
  LS_FIELDCATLOG5-FIELDNAME = 'PIDX'.
  LS_FIELDCATLOG5-TABNAME   = 'IT_DISPLAY3'.
  LS_FIELDCATLOG5-SELTEXT_M = 'Index'.                      "#EC NOTEXT
  LS_FIELDCATLOG5-NO_OUT    = 'X'.
  APPEND LS_FIELDCATLOG5 TO LT_FIELDCATLOG5.
  CLEAR LS_FIELDCATLOG5.
  LS_FIELDCATLOG5-ROW_POS   = '1'.
  LS_FIELDCATLOG5-COL_POS   = '2'.
  LS_FIELDCATLOG5-FIELDNAME = 'KET'.
  LS_FIELDCATLOG5-TABNAME   = 'IT_DISPLAY3'.
  LS_FIELDCATLOG5-SELTEXT_M = 'Position Order'.             "#EC NOTEXT
  APPEND LS_FIELDCATLOG5 TO LT_FIELDCATLOG5.
  CLEAR LS_FIELDCATLOG5.
  LS_FIELDCATLOG5-ROW_POS   = '1'.
  LS_FIELDCATLOG5-COL_POS   = '3'.
  LS_FIELDCATLOG5-FIELDNAME = 'JML'.
  LS_FIELDCATLOG5-TABNAME   = 'IT_DISPLAY3'.
  LS_FIELDCATLOG5-SELTEXT_M = 'Quantity'.                   "#EC NOTEXT
  LS_FIELDCATLOG5-EDIT      = 'X'.
  APPEND LS_FIELDCATLOG5 TO LT_FIELDCATLOG5.
ENDFORM.                    " build_fieldcat4

*&----------------------------------------------------------*
*&      Form  build_layout5
*&----------------------------------------------------------*
*Layout for ALV dialog
FORM BUILD_LAYOUT5 .
  LT_LAYOUT5-ZEBRA = 'X'.
  LT_LAYOUT5-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " build_layout5
*&---------------------------------------------------------------*
*&      Form  alv5
*&---------------------------------------------------------------*
*Alv dialog output.
FORM ALV5.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Jumlah Output Cast Sheet' "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT5
      IT_FIELDCAT              = LT_FIELDCATLOG5
      I_SCREEN_START_COLUMN    = 5  "10
      I_SCREEN_START_LINE      = 3  "20
      I_SCREEN_END_COLUMN      = 50 "60 "100
      I_SCREEN_END_LINE        = 15 "30 "40
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND5'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS5'
    TABLES
      T_OUTTAB                 = IT_DISPLAY3
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " alv

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS5 USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDPOPUP'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND5 USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CASE R_UCOMM.
    WHEN '&ONT'.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'   "This FM will get the reference of the changed data in ref_grid
        IMPORTING
          E_GRID = REF_GRID.

      IF REF_GRID IS NOT INITIAL.
        CALL METHOD REF_GRID->CHECK_CHANGED_DATA( ).  "After calling this method your internal table will have updated values
      ENDIF.

  ENDCASE.

ENDFORM. "user_command
*&---------------------------------------------------------------------*
*&      Form  CHANGE_BATCH_INPUTAN_SCRAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_BATCH_INPUTAN_SCRAP USING V_MATNR V_CHARG.
*BREAK-POINT.
  CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      I_MATNR      = V_MATNR
      I_CHARG      = V_CHARG
      I_MARA_LEVEL = 'X'
    IMPORTING
      E_CLASS      = VCLASS
      E_KLART      = VKLART
      E_OBTAB      = VOBTAB
      E_OBJEC      = VOBJEC.

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
  REFRESH: CHAR_OF_BATCH.

  PERFORM VB_INIT.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = V_MATNR
      CHARG                    = V_CHARG
*      WERKS                    = wa_afpo-pwerk
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
            .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

  CLEAR: IT_CHAR.
  REFRESH: IT_CHAR.
  LOOP AT CHAR_OF_BATCH.
    IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
    IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
    APPEND IT_CHAR.
  ENDLOOP.

* Set ZZLENGTH
  CLEAR: WA_CHAR2, LS_SUBRC.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
    LS_SUBRC = 1.
    WA_CHAR2-VALUE_CHAR = ''.
    MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
  ENDLOOP.
* Set ZZEXLENGTH
  CLEAR: WA_CHAR2, LS_SUBRC.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
    LS_SUBRC = 1.
    WA_CHAR2-VALUE_CHAR = ''.
    MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
  ENDLOOP.
******** Set ZZWIDTH
*******  CLEAR: WA_CHAR2, LS_SUBRC.
*******  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
*******    LS_SUBRC = 1.
*******    WA_CHAR2-VALUE_CHAR = ''.
*******    MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
*******  ENDLOOP.
* Set ZZLENGTHSHT
  CLEAR: WA_CHAR2, LS_SUBRC.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
    LS_SUBRC = 1.
    WA_CHAR2-VALUE_CHAR = ''.
    MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
  ENDLOOP.

  CLEAR: IT_RETURN2.
  REFRESH: IT_RETURN2.
  CALL FUNCTION 'BAPI_OBJCL_CHANGE'
    EXPORTING
      OBJECTKEY          = VOBJEC
      OBJECTTABLE        = VOBTAB
      CLASSNUM           = VCLASS
      CLASSTYPE          = VKLART
    TABLES
      ALLOCVALUESNUMNEW  = IT_NUM
      ALLOCVALUESCHARNEW = IT_CHAR
      ALLOCVALUESCURRNEW = IT_CURR
      RETURN             = IT_RETURN2.
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE V_CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Change Batch Inputan Scrap'.             "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.

  CLEAR: SY-SUBRC.
  CHECK FLAG EQ SPACE.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    CONCATENATE V_CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Change Batch Inputan Scrap'.             "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDIF.

  IF FLAG EQ SPACE.
    PERFORM SLOC_TO_SLOC_SCRAP.
  ENDIF.

ENDFORM.                    " CHANGE_BATCH_INPUTAN_SCRAP
*&---------------------------------------------------------------------*
*&      Form  SLOC_TO_SLOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SLOC_TO_SLOC .
*BREAK-POINT.
  CLEAR: ERRMSG_TRSFR, MTHEAD_TRSFR, GMCODE_TRSFR, GMHEAD_TRSFR.
  REFRESH: ERRMSG_TRSFR.

  GMHEAD_TRSFR-PSTNG_DATE = SY-DATUM.
  GMHEAD_TRSFR-DOC_DATE   = SY-DATUM.
  GMHEAD_TRSFR-PR_UNAME   = SY-UNAME.
  GMHEAD_TRSFR-HEADER_TXT = COM_ORDER.
  GMCODE_TRSFR-GM_CODE    = '04'.

  READ TABLE ITAB_TRSFR INDEX 1.
  IF SY-SUBRC = 0. " Add 7 Januari 2013 "Karena ada case lebar input = output jadi gada proses sloc to sloc

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER       = GMHEAD_TRSFR
        GOODSMVT_CODE         = GMCODE_TRSFR
*       TESTRUN               = ' '
      IMPORTING
        GOODSMVT_HEADRET      = MTHEAD_TRSFR
*       MATERIALDOCUMENT      =
*       MATDOCUMENTYEAR       =
      TABLES
        GOODSMVT_ITEM         = ITAB_TRSFR
*       GOODSMVT_SERIALNUMBER =
        RETURN                = ERRMSG_TRSFR.

    CLEAR: FLAG, VMESS, V_MBLNR, V_MJAHR.
    LS_SUBRC = 0.
    LOOP AT ERRMSG_TRSFR WHERE TYPE = 'E'.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Sloc To Sloc Raw Recycle'.             "#EC NOTEXT
      IT_LOG-MESS = ERRMSG_TRSFR-MESSAGE.
      APPEND IT_LOG.
    ENDLOOP.

    CLEAR: SY-SUBRC.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE 'No.Mat.Doc :' MTHEAD_TRSFR+0(10) '--' 'Fiscal Year' MTHEAD_TRSFR+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      V_MBLNR = MTHEAD_TRSFR+0(10).
      V_MJAHR = MTHEAD_TRSFR+10(4).
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Sloc To Sloc Raw Recycle'.             "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDIF.

  IF FLAG EQ SPACE.
*** Check tick di line batch inputan
    CLEAR: WA_INBATCH.
    READ TABLE IT_INBATCH INTO WA_INBATCH WITH KEY SCRAP = 'X'.
    IF SY-SUBRC = 0.
      PERFORM SCRAP_BATCH_INPUTAN.
    ELSE.
      PERFORM TECO_COMBINE USING COM_ORDER.
    ENDIF.
  ENDIF.

ENDFORM.                    " SLOC_TO_SLOC
*&---------------------------------------------------------------------*
*&      Form  SLOC_TO_SLOC_SCRAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SLOC_TO_SLOC_SCRAP .
*BREAK-POINT.
  CLEAR: WA_SCRAP1, WA_SCRAP2.
  LOOP AT ITAB_SCRAP INTO WA_SCRAP1.
    CLEAR: WA_SCRAP2, WA_SCRAP1-MOVE_STLOC, WA_SCRAP1-ENTRY_QNT.
    LOOP AT ITAB_SCRAP2 INTO WA_SCRAP2 WHERE MOVE_TYPE = WA_SCRAP1-MOVE_TYPE AND " Di Uncomment Permintaan YAN YOHANA
                                             BATCH = WA_SCRAP1-BATCH. " Di Uncomment Permintaan YAN YOHANA
      WA_SCRAP1-ENTRY_QNT = WA_SCRAP1-ENTRY_QNT + WA_SCRAP2-ENTRY_QNT. " Di Uncomment Permintaan YAN YOHANA
    ENDLOOP. " Di Uncomment Permintaan YAN YOHANA
    WA_SCRAP1-ORDERID    = ''.
    WA_SCRAP1-MOVE_STLOC = V_ZRRLGORT.
    WA_SCRAP1-ITEM_TEXT  = 'SCRAP'.
    WA_SCRAP1-MOVE_TYPE  = '311'.
    MODIFY ITAB_SCRAP FROM WA_SCRAP1 TRANSPORTING ENTRY_QNT ITEM_TEXT MOVE_STLOC MOVE_TYPE ORDERID.
  ENDLOOP.

  CLEAR: ERRMSG_SCRAP, MTHEAD_SCRAP, GMCODE_SCRAP, GMHEAD_SCRAP.
  REFRESH: ERRMSG_SCRAP.

  GMHEAD_SCRAP-PSTNG_DATE = SY-DATUM.
  GMHEAD_SCRAP-DOC_DATE   = SY-DATUM.
  GMHEAD_SCRAP-PR_UNAME   = SY-UNAME.
  GMHEAD_SCRAP-HEADER_TXT = COM_ORDER.
  GMCODE_SCRAP-GM_CODE    = '04'.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD_SCRAP
      GOODSMVT_CODE         = GMCODE_SCRAP
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD_SCRAP
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB_SCRAP
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG_SCRAP.

  CLEAR: FLAG, VMESS, V_MBLNR, V_MJAHR.
  LS_SUBRC = 0.
  LOOP AT ERRMSG_SCRAP WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Sloc To Sloc Scrap Batch Inputan'.       "#EC NOTEXT
    IT_LOG-MESS = ERRMSG_SCRAP-MESSAGE.
    APPEND IT_LOG.
  ENDLOOP.

  CLEAR: SY-SUBRC.

  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    CONCATENATE 'No.Mat.Doc :' MTHEAD_SCRAP+0(10) '--' 'Fiscal Year' MTHEAD_SCRAP+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    V_MBLNR = MTHEAD_SCRAP+0(10).
    V_MJAHR = MTHEAD_SCRAP+10(4).
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Sloc To Sloc Scrap Batch Inputan'.       "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
    PERFORM TECO_COMBINE USING COM_ORDER.
  ENDIF.

ENDFORM.                    " SLOC_TO_SLOC_SCRAP
*&---------------------------------------------------------------------*
*&      Form  GET_LENGTH_WIDTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LENGTH_WIDTH USING V_MATNR V_CHARG
                      CHANGING V_LENGTH V_EXTRA V_WIDTH V_LENGTHSHT.

  CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      I_MATNR      = V_MATNR
      I_CHARG      = V_CHARG
      I_MARA_LEVEL = 'X'
    IMPORTING
      E_CLASS      = VCLASS
      E_KLART      = VKLART
      E_OBTAB      = VOBTAB
      E_OBJEC      = VOBJEC.

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
  REFRESH: CHAR_OF_BATCH.

  PERFORM VB_INIT.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = V_MATNR
      CHARG                    = V_CHARG
*      WERKS                    = wa_afpo-pwerk
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
            .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

  CLEAR: IT_CHAR.
  REFRESH: IT_CHAR.
  LOOP AT CHAR_OF_BATCH.
    IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
    IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
    APPEND IT_CHAR.
  ENDLOOP.

* Get ZZLENGTH
  CLEAR: WA_CHAR2, LS_SUBRC, V_LENGTH.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
    V_LENGTH = WA_CHAR2-VALUE_CHAR.
    REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTH WITH SPACE.
    CONDENSE V_LENGTH NO-GAPS.
  ENDLOOP.
* Get ZZEXLENGTH
  CLEAR: WA_CHAR2, LS_SUBRC, V_EXTRA.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZEXLENGTH'.
    V_EXTRA = WA_CHAR2-VALUE_CHAR.
    REPLACE ALL OCCURRENCES OF RIBUAN IN V_EXTRA WITH SPACE.
    CONDENSE V_EXTRA NO-GAPS.
  ENDLOOP.
* Get ZZWIDTH
  CLEAR: WA_CHAR2, LS_SUBRC, V_WIDTH.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
    V_WIDTH = WA_CHAR2-VALUE_CHAR.
    REPLACE ALL OCCURRENCES OF RIBUAN IN V_WIDTH WITH SPACE.
    CONDENSE V_WIDTH NO-GAPS.
  ENDLOOP.
* Get ZZLENGTHSHT
  CLEAR: WA_CHAR2, LS_SUBRC, V_LENGTHSHT.
  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
    V_LENGTHSHT = WA_CHAR2-VALUE_CHAR.
    REPLACE ALL OCCURRENCES OF RIBUAN IN V_LENGTHSHT WITH SPACE.
    CONDENSE V_LENGTHSHT NO-GAPS.
  ENDLOOP.

ENDFORM.                    " GET_LENGTH_WIDTH
*&---------------------------------------------------------------------*
*&      Form  REVERSE_CHAR_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_CHAR_BATCH_INPUTAN USING MATERIALDOCUMENT MATDOCUMENTYEAR.
*BREAK-POINT.
  DATA: BEGIN OF IT_BATCH OCCURS 0,
          MATNR LIKE MCH1-MATNR,
          CHARG LIKE MCH1-CHARG,
          SGTXT LIKE MSEG-SGTXT,
        END OF IT_BATCH.
  DATA: WA_BATCH LIKE LINE OF IT_BATCH,
        V_ZZLENGTH LIKE AUSP-ATWRT.

  SELECT MATNR CHARG SGTXT
APPENDING CORRESPONDING FIELDS OF TABLE IT_BATCH
    FROM MSEG
   WHERE MBLNR = MATERIALDOCUMENT AND MJAHR = MATDOCUMENTYEAR AND
         BWART = '531'.

*Additional 5 Nov 2012
  SORT IT_BATCH BY CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_BATCH COMPARING CHARG.
*End Additional 5 Nov 2012

  CLEAR: WA_BATCH, FLAG.
  LOOP AT IT_BATCH INTO WA_BATCH.

    CHECK FLAG EQ SPACE.

    DO 20 TIMES.
      CALL FUNCTION 'ENQUEUE_EMMCH1E'
        EXPORTING
          MATNR          = V_MATNR
          CHARG          = V_CHARG
        EXCEPTIONS
          FOREIGN_LOCK   = 2
          SYSTEM_FAILURE = 3.

      IF SY-SUBRC  NE 0.
        WAIT UP TO 1 SECONDS.
      ELSE.
        CALL FUNCTION 'DEQUEUE_EMMCH1E'
          EXPORTING
            MATNR = V_MATNR
            CHARG = V_CHARG.
        EXIT.
      ENDIF.
    ENDDO.

    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC, V_LENGTH, V_EXTRA, V_WIDTH, V_LENGTHSHT, V_ZZLENGTH.
    SPLIT WA_BATCH-SGTXT AT ';' INTO V_LENGTH V_EXTRA V_WIDTH V_LENGTHSHT.
    CONDENSE V_LENGTH NO-GAPS.
    CONDENSE V_EXTRA  NO-GAPS.
    CONDENSE V_WIDTH  NO-GAPS.
    CONDENSE V_LENGTHSHT NO-GAPS.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = V_MATNR "wa_batch-matnr
        I_CHARG      = V_CHARG "wa_batch-charg
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR                    = V_MATNR "wa_batch-matnr
        CHARG                    = V_CHARG "wa_batch-charg
*        WERKS                    = wa_afpo-pwerk
        GET_CLASSIFICATION       = 'X'
*       EXISTENCE_CHECK          =
*       READ_FROM_BUFFER         =
*       NO_CLASS_INIT            = ' '
*       LOCK_BATCH               = ' '
*     IMPORTING
*       YMCHA                    =
*       CLASSNAME                =
      TABLES
        CHAR_OF_BATCH            = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL              = 1
        NO_BATCH                 = 2
        NO_PLANT                 = 3
        MATERIAL_NOT_FOUND       = 4
        PLANT_NOT_FOUND          = 5
        NO_AUTHORITY             = 6
        BATCH_NOT_EXIST          = 7
        LOCK_ON_BATCH            = 8
        OTHERS                   = 9
              .
    IF SY-SUBRC <> 0.
*Implement suitable error handling here
    ENDIF.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.
    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.

    IF CLASS = 'ZZSRSHEET'.
*     Set ZZLENGTHSHT
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTHSHT'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR + V_LENGTH.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTHSHT'.
        IT_CHAR-VALUE_CHAR = V_LENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ELSE.
*     Set ZZLENGTH
      CLEAR: WA_CHAR2, LS_SUBRC.
      LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
        LS_SUBRC = 1.
        REPLACE ALL OCCURRENCES OF RIBUAN IN WA_CHAR2-VALUE_CHAR WITH SPACE.
        CONDENSE WA_CHAR2-VALUE_CHAR NO-GAPS.
        WA_CHAR2-VALUE_CHAR = WA_CHAR2-VALUE_CHAR + V_LENGTH." wa_batch-sgtxt.
        MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
      ENDLOOP.
      IF LS_SUBRC = 0.
        IT_CHAR-CHARACT    = 'ZZLENGTH'.
        IT_CHAR-VALUE_CHAR = V_LENGTH.
        APPEND IT_CHAR.
      ENDIF.
    ENDIF.

***   Set ZZEXLENGTH
**    CLEAR: wa_char2, ls_subrc.
**    LOOP AT it_char INTO wa_char2 WHERE charact = 'ZZEXLENGTH'.
**      ls_subrc = 1.
**      wa_char2-VALUE_CHAR = v_extra.
**      MODIFY it_char FROM wa_char2 TRANSPORTING value_char.
**    ENDLOOP.
**    IF ls_subrc = 0.
**      IT_CHAR-CHARACT    = 'ZZEXLENGTH'.
**      IT_CHAR-VALUE_CHAR = v_extra.
**      APPEND IT_CHAR.
**    ENDIF.

********   Set ZZWIDTH
*******    CLEAR: WA_CHAR2, LS_SUBRC.
*******    LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZWIDTH'.
*******      LS_SUBRC = 1.
*******      WA_CHAR2-VALUE_CHAR = V_WIDTH.
*******      MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
*******    ENDLOOP.
*******    IF LS_SUBRC = 0.
*******      IT_CHAR-CHARACT    = 'ZZWIDTH'.
*******      IT_CHAR-VALUE_CHAR = V_WIDTH.
*******      APPEND IT_CHAR.
*******    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.
    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
      CLEAR: VMESS.
      CONCATENATE WA_BATCH-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Set Length Batch Inputan Scrap'.       "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
      APPEND IT_LOG.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel Confirmation'.                  "#EC NOTEXT
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
    ENDLOOP.
    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE V_CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Set Length Batch Inputan Scrap'.       "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " REVERSE_CHAR_BATCH_INPUTAN
*&---------------------------------------------------------------------*
*&      Form  VALIDASI_ORDER_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDASI_ORDER_TYPE CHANGING FLAG.

**Range Auart untuk jagaan
  CLEAR: RANGE_AUART, WA_RANGE_AUART.
  REFRESH: RANGE_AUART.

  " Added by William at 24.07.2022 (OPP7 CPP1)
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCC2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCD2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCB1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCB2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  " End added by William at 24.07.2022 (OPP7 CPP1)

  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCP1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCP2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCE2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCA1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCA2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCL2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCZ1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCZ2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCT2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCS2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZTC1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZTC2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  "Tambahan 26 February 2013
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCR1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCR2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  "ADDED FOR EXLAM 23.01.2019 - ADD ORDER TYPE ZCX2
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCX2'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  "ADDED FOR EXLAM 23.01.2019 - ADD ORDER TYPE ZCX2
  "Tambahan 26 February 2013

  "ADDED FOR LAM #2 #3 Dila 11.02.2025 - ADD ORDER TYPE ZCL1
  CLEAR:WA_RANGE_AUART.
  WA_RANGE_AUART-SIGN   = 'I'.
  WA_RANGE_AUART-OPTION = 'EQ'.
  WA_RANGE_AUART-LOW    = 'ZCL1'.
  APPEND WA_RANGE_AUART TO RANGE_AUART.
  "END ADDED FOR LAM #2 #3 Dila 11.02.2025 - ADD ORDER TYPE ZCL1
**End Range Auart untuk jagaan

  LOOP AT SO_AUART.
    IF SO_AUART-LOW NOT IN RANGE_AUART.
      MESSAGE 'Order Type Bukan Combine Order' TYPE 'I'.    "#EC NOTEXT
      FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDASI_ORDER_TYPE
*&---------------------------------------------------------------------*
*&      Form  F4_AUART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3309   text
*----------------------------------------------------------------------*
FORM F4_AUART.

  DATA: BEGIN OF IT_AUART OCCURS 0,
          AUART LIKE AUFK-AUART,
          TXT   LIKE T003P-TXT,
        END OF IT_AUART.
  DATA: WA_AUART LIKE LINE OF IT_AUART,
        IT_RETURN1 LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

**Range Auart untuk f4
  " Added by William at 24.07.2022 (OPP7 CPP1)
  IT_AUART = 'ZCC2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCD2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCB1'.
  APPEND IT_AUART.
  IT_AUART = 'ZCB2'.
  APPEND IT_AUART.
  " End added by William at 24.07.2022 (OPP7 CPP1)

  " Added by Dila at 11.02.2025 (LAMINATOR #2 #3)
  IT_AUART = 'ZCL1'.
  APPEND IT_AUART.
  " End added by Dila at 11.02.2025 (LAMINATOR #2 #3)

  IT_AUART = 'ZCP1'.
  APPEND IT_AUART.
  IT_AUART = 'ZCP2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCE2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCA1'.
  APPEND IT_AUART.
  IT_AUART = 'ZCA2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCL2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCZ1'.
  APPEND IT_AUART.
  IT_AUART = 'ZCZ2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCT2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCS2'.
  APPEND IT_AUART.
  IT_AUART = 'ZTC1'.
  APPEND IT_AUART.
  IT_AUART = 'ZTC2'.
  APPEND IT_AUART.
  IT_AUART = 'ZCR1'. "Tambahan 26 February 2013
  APPEND IT_AUART. "Tambahan 26 February 2013
  IT_AUART = 'ZCR2'. "Tambahan 26 February 2013
  APPEND IT_AUART. "Tambahan 26 February 2013
  "ADDED FOR EXLAM 23.01.2019 - ADD ORDER TYPE ZCX2
  IT_AUART = 'ZCX2'.
  APPEND IT_AUART.
  "ADDED FOR EXLAM 23.01.2019 - ADD ORDER TYPE ZCX2
**End Range Auart untuk f4

  CLEAR: WA_AUART.
  LOOP AT IT_AUART INTO WA_AUART.

    SELECT SINGLE TXT
      INTO WA_AUART-TXT
      FROM T003P
     WHERE SPRAS = 'EN' AND AUART = WA_AUART-AUART.

    MODIFY IT_AUART FROM WA_AUART TRANSPORTING TXT.

  ENDLOOP.

  CLEAR: IT_RETURN1.
  REFRESH: IT_RETURN1.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'AUART'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IT_AUART
      RETURN_TAB      = IT_RETURN1
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

**  LOOP AT it_return1.
**    CLEAR: wa_auart.
**    READ TABLE it_auart INTO wa_auart WITH KEY txt = it_return1-fieldval.
**    IF sy-subrc = 0.
**      so_auart-low = wa_auart-auart.
**    ENDIF.
**  ENDLOOP.
  SO_AUART-LOW = IT_RETURN1-FIELDVAL.

ENDFORM.                    " F4_AUART
*&---------------------------------------------------------------------*
*&      Form  MODIFY_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_REFRESH .

  DO LBASIC TIMES.
    CHECK SY-INDEX >= 7.
    READ LINE SY-INDEX.
    CHECK SY-SUBRC EQ 0.
    CLEAR: VCOM_ORDER.
    VCOM_ORDER = SY-LISEL+4(12).
    CLEAR: WA_BASIC.
    READ TABLE V_BASIC INTO WA_BASIC WITH KEY AUFNR = VCOM_ORDER.
    IF SY-SUBRC = 0.
      CASE WA_BASIC-ZSTAT.
        WHEN 'CRTD'.
          WA_BASIC-ZSTAT = 'Created'.                       "#EC NOTEXT
        WHEN 'REL'.
          WA_BASIC-ZSTAT = 'Active'.                        "#EC NOTEXT
        WHEN 'PCNF'.
          WA_BASIC-ZSTAT = 'In Progress'.                   "#EC NOTEXT
        WHEN 'CNF'.
          WA_BASIC-ZSTAT = 'Completed'.                     "#EC NOTEXT
        WHEN 'DLV'.
          WA_BASIC-ZSTAT = 'GoodReceipt'.                   "#EC NOTEXT
        WHEN 'TECO'.
          WA_BASIC-ZSTAT = 'TECO'.                          "#EC NOTEXT
        WHEN 'CLSD'.
          WA_BASIC-ZSTAT = 'Closed'.
      ENDCASE.
*      MODIFY v_basic FROM wa_basic TRANSPORTING ZSTAT.
      SY-LISEL+32(11) = WA_BASIC-ZSTAT.
      MODIFY LINE SY-INDEX.
    ENDIF.
*    MODIFY LINE SY-INDEX FIELD VALUE MARK.
  ENDDO.

ENDFORM.                    " MODIFY_REFRESH
*&---------------------------------------------------------------------*
*&      Form  CANCEL_CONFIRMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_CONFIRMATION." USING V_CONF_NO.

  CLEAR: V_RUECK, V_RMZHL, FLAG, VMESS.
  SELECT SINGLE RUECK RMZHL
    FROM AFRU
    INTO (V_RUECK,V_RMZHL)
   WHERE AUFNR = COM_ORDER AND STOKZ = '' AND STZHL = ''.
*    %_HINTS ORACLE 'INDEX("AFRU" "AFRU~Z02")'.

  IF V_RUECK = SPACE OR V_RUECK = '0000000000'.
    FLAG = 'X'.
  ENDIF.

  CONCATENATE 'Gagal GI combine order nomor' COM_ORDER INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT

  IF FLAG = ''.

    REFRESH BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'CORUF-RMZHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'CORUF-RUECK'
                                  V_RUECK.
    PERFORM BDC_FIELD       USING 'CORUF-RMZHL'
                                  V_RMZHL.
    PERFORM BDC_FIELD       USING 'CORUF-AUFNR'
                                  ''.
    PERFORM BDC_FIELD       USING 'CORUF-VORNR'
                                  ''.
    PERFORM BDC_FIELD       USING 'CORUF-UVORN'
                                  ''.
    PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5150'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=LTXS'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'AFRUD-LMNGA'.
    PERFORM BDC_DYNPRO      USING 'SAPLSTXX' '1100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RSTXT-TXLINE(02)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=TXBA'.
    PERFORM BDC_FIELD       USING 'RSTXT-TXLINE(02)'
                                  VMESS.
    PERFORM BDC_DYNPRO      USING 'SAPLCORU' '5150'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'AFRUD-LMNGA'.

    OPT-DISMODE = 'E'. "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
    OPT-UPDMODE = 'A'. "S: synchronously "A: asynchronously "L: local
    OPT-DEFSIZE = 'X'.

    REFRESH : MESSTAB.
    CALL TRANSACTION 'CORS' USING BDCDATA OPTIONS FROM OPT
                            MESSAGES INTO MESSTAB.
    REFRESH BDCDATA.

    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.

    LOOP AT MESSTAB WHERE MSGTYP = 'E'.
      CLEAR: VMESS.
      CONCATENATE 'Cancel Confirmation saat GI gagal' V_RUECK INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = VMESS.
      IT_LOG-MESS = 'Failed'.                               "#EC NOTEXT
      APPEND IT_LOG.
    ENDLOOP.

    CLEAR: SY-SUBRC.

    IF LS_SUBRC = 0.
      CLEAR: VMESS.
      CONCATENATE 'Cancel Confirmation saat GI gagal' V_RUECK INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = VMESS.
      IT_LOG-MESS = 'Success'.                              "#EC NOTEXT
      APPEND IT_LOG.
      IF S_MBLNR NE '' AND FLAG EQ ''.
        PERFORM CANCEL_SOTOSO USING S_MBLNR S_MJAHR.
      ENDIF.
      IF U_MBLNR NE '' AND FLAG EQ ''.
        PERFORM CANCEL_SOTOUN USING U_MBLNR U_MJAHR.
      ENDIF.
      IF FLAG EQ ''.
        PERFORM CANCEL_GR USING R_MBLNR R_MJAHR.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    " CANCEL_CONFIRMATION
*&---------------------------------------------------------------------*
*&      Form  CANCEL_GR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_GR USING R_MBLNR R_MJAHR.

  CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
  REFRESH: RETURN.
  MATERIALDOCUMENT = R_MBLNR.
  MATDOCUMENTYEAR  = R_MJAHR.
  PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Cancel GR saat gagal GI'.                "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    CLEAR: VMESS.
    CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Cancel GR saat gagal GI'.                "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
    IF CLASS NE 'ZZSRSHEET'.
      PERFORM UNDO_CHANGE_BATCH_ORIG_ORDER.
*      PERFORM REVERSE_ZZEXLENGTH.
    ENDIF.
  ENDIF.

ENDFORM.                    " CANCEL_GR
*&---------------------------------------------------------------------*
*&      Form  CANCEL_SOTOSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_SOTOSO USING S_MBLNR S_MJAHR.

  CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
  REFRESH: RETURN.
  MATERIALDOCUMENT = S_MBLNR.
  MATDOCUMENTYEAR  = S_MJAHR.
  PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Cancel SO To SO saat gagal GI'.          "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
    IF U_MBLNR NE ''.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Cancel SO To Unrest saat gagal GI'.    "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDIF.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Cancel GR saat gagal GI'.                "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    CLEAR: VMESS.
    CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Cancel SO To SO saat gagal GI'.          "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " CANCEL_SOTOSO
*&---------------------------------------------------------------------*
*&      Form  CANCEL_SOTOUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_SOTOUN USING U_MBLNR U_MJAHR.

  CLEAR: MATERIALDOCUMENT, MATDOCUMENTYEAR, GOODSMVT_HEADRET, RETURN.
  REFRESH: RETURN.
  MATERIALDOCUMENT = U_MBLNR.
  MATDOCUMENTYEAR  = U_MJAHR.
  PERFORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE MATERIALDOCUMENT '-' RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Cancel SO To Unrest saat gagal GI'.      "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'Cancel GR saat gagal GI'.                "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    CLEAR: VMESS.
    CONCATENATE 'No.Mat.Doc :' GOODSMVT_HEADRET+0(10) '--' 'Fiscal Year' GOODSMVT_HEADRET+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'Cancel SO To Unrest saat gagal GI'.      "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " CANCEL_SOTOUN
*&---------------------------------------------------------------------*
*&      Form  TECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TECO_COMBINE USING P_COM_ORDER TYPE AUFNR.

*******  CLEAR: CAUFVTAB, MESSAGE_TABLE.
*******  REFRESH: CAUFVTAB, MESSAGE_TABLE.
*******
*******  SELECT * INTO TABLE CAUFVTAB FROM CAUFV WHERE AUFNR = p_com_order.
*******  CALL FUNCTION 'ORDER_CHANGE_FOR_ACTIVITY'
*******    EXPORTING
*******      TESTRUN              = ' '
*******      FLG_TERM             = ' '
*******      FLG_COST             = ' '
*******      FLG_TECL             = 'X'
*******      FLG_CAPA             = ' '
*******      FLG_LVS              = ' '
*******      FLG_CLOS             = ' '
*******      MAXNUMBER            = '999'
*******      INIT_TABLES          = 'X'
*******      EXPORT_MSG_TO_MEMORY = ' '
*******    TABLES
*******      TABLE_OF_MESSAGES    = MESSAGE_TABLE
*******      CAUFV_TAB            = CAUFVTAB
*******    EXCEPTIONS
*******      NOTHING_TO_DO        = 0
*******      WRONG_SELID          = 0
*******      OTHERS               = 0.
*******
*******  READ TABLE MESSAGE_TABLE WITH KEY MSGNR = '889'  .
*******  IF SY-SUBRC = 0.
*******    IT_LOG-ICON = '@08@'.
*******    IT_LOG-TRNS = 'TECO Combine Order'."#EC NOTEXT
*******    IT_LOG-MESS = 'Success'.
*******    APPEND IT_LOG.
*******    PERFORM TECO_ORIGINAL USING com_order.
*******  ELSE.
*******    IT_LOG-ICON = '@0A@'.
*******    IT_LOG-TRNS = 'TECO Combine Order'."#EC NOTEXT
*******    IT_LOG-MESS = 'Failed'.
*******    APPEND IT_LOG.
*******  ENDIF.

  CLEAR: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.
  REFRESH: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.

  TECO_ORDERS-ORDER_NUMBER = P_COM_ORDER.
  APPEND TECO_ORDERS.

  CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
    EXPORTING
      SCOPE_COMPL_TECH   = '1'
      WORK_PROCESS_GROUP = 'COWORK_BAPI'
      WORK_PROCESS_MAX   = 99
    IMPORTING
      RETURN             = TECO_RETURN
    TABLES
      ORDERS             = TECO_ORDERS
      DETAIL_RETURN      = TECO_DEAIL_RETURN
*     APPLICATION_LOG    =
    .
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT TECO_DEAIL_RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE 'Failed -' TECO_DEAIL_RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'TECO Combine Order'.                     "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'TECO Combine Order'.                     "#EC NOTEXT
    IT_LOG-MESS = 'Success'.
    APPEND IT_LOG.
    PERFORM TECO_ORIGINAL USING COM_ORDER.
  ENDIF.

ENDFORM.                    " TECO
*&---------------------------------------------------------------------*
*&      Form  TECO_ORIGINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TECO_ORIGINAL USING P_COM_ORDER TYPE AUFNR.

*******  CLEAR IT_TECO.
*******  REFRESH IT_TECO.
*******  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*******    EXPORTING
*******      INPUT  = p_com_order
*******    IMPORTING
*******      OUTPUT = p_com_order.
*******
*******  IT_TECO-AUFNR = p_com_order.
*******  SELECT MILL_OC_AUFNR_U INTO IT_TECO-ZMILL FROM AFPO WHERE AUFNR = p_com_order.
*******    APPEND IT_TECO.
*******  ENDSELECT.
*******  IF SY-SUBRC <> 0.
*******    APPEND IT_TECO.
*******  ENDIF.
*******  CLEAR IT_TECO.
*******
*******  CLEAR: CAUFVTAB, MESSAGE_TABLE.
*******  REFRESH: CAUFVTAB, MESSAGE_TABLE.
*******  SELECT * INTO TABLE CAUFVTAB FROM CAUFV FOR ALL ENTRIES IN IT_TECO WHERE AUFNR = IT_TECO-ZMILL.
*******  CALL FUNCTION 'ORDER_CHANGE_FOR_ACTIVITY'
*******    EXPORTING
*******      TESTRUN              = ' '
*******      FLG_TERM             = ' '
*******      FLG_COST             = ' '
*******      FLG_TECL             = 'X'
*******      FLG_CAPA             = ' '
*******      FLG_LVS              = ' '
*******      FLG_CLOS             = ' '
*******      MAXNUMBER            = '999'
*******      INIT_TABLES          = 'X'
*******      EXPORT_MSG_TO_MEMORY = ' '
*******    TABLES
*******      TABLE_OF_MESSAGES    = MESSAGE_TABLE
*******      CAUFV_TAB            = CAUFVTAB
*******    EXCEPTIONS
*******      NOTHING_TO_DO        = 0
*******      WRONG_SELID          = 0
*******      OTHERS               = 0.
*******
*******  READ TABLE MESSAGE_TABLE WITH KEY MSGNR = '889'  .
*******  IF SY-SUBRC = 0.
*******    IT_LOG-ICON = '@08@'.
*******    IT_LOG-TRNS = 'TECO Original Order'."#EC NOTEXT
*******    IT_LOG-MESS = 'Success'.
*******    APPEND IT_LOG.
*******  ELSE.
*******    IT_LOG-ICON = '@0A@'.
*******    IT_LOG-TRNS = 'TECO Original Order'."#EC NOTEXT
*******    IT_LOG-MESS = 'Failed'.
*******    APPEND IT_LOG.
*******  ENDIF.

  CLEAR: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.
  REFRESH: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_COM_ORDER
    IMPORTING
      OUTPUT = P_COM_ORDER.

  SELECT MILL_OC_AUFNR_U INTO TECO_ORDERS-ORDER_NUMBER FROM AFPO WHERE AUFNR = P_COM_ORDER.
    APPEND TECO_ORDERS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    APPEND TECO_ORDERS.
  ENDIF.
  CLEAR TECO_ORDERS.
  CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
    EXPORTING
      SCOPE_COMPL_TECH   = '1'
      WORK_PROCESS_GROUP = 'COWORK_BAPI'
      WORK_PROCESS_MAX   = 99
    IMPORTING
      RETURN             = TECO_RETURN
    TABLES
      ORDERS             = TECO_ORDERS
      DETAIL_RETURN      = TECO_DEAIL_RETURN
*     APPLICATION_LOG    =
    .
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT TECO_DEAIL_RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE 'Failed -' TECO_DEAIL_RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE.
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-ICON = '@0A@'.
    IT_LOG-TRNS = 'TECO Original Order'.                    "#EC NOTEXT
    IT_LOG-MESS = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    IT_LOG-ICON = '@08@'.
    IT_LOG-TRNS = 'TECO Original Order'.                    "#EC NOTEXT
    IT_LOG-MESS = 'Success'.
    APPEND IT_LOG.
  ENDIF.

ENDFORM.                    " TECO_ORIGINAL
*&---------------------------------------------------------------------*
*&      Form  VB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VB_INIT .
  CALL FUNCTION 'VB_INIT'
    EXPORTING
      INIT_RESET = 'X'.
ENDFORM.                    " VB_INIT



*&---------------------------------------------------------------------*
*&      Form  CHECKING_LOCK_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FLAG       text
*----------------------------------------------------------------------*
FORM CHECKING_LOCK_MATNR CHANGING FLAG.
  DATA: V_GARG LIKE SEQG3-GARG,
        V_LMAT LIKE MARA-MATNR,
        V_PESAN(100).
  DATA: IT_ENQ LIKE SEQG3 OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE MATNR INTO V_LMAT FROM MCH1 WHERE CHARG = IN_CHARG1.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GCLIENT = SY-MANDT
      GUNAME  = ''
    TABLES
      ENQ     = IT_ENQ.

  CONCATENATE SY-MANDT V_LMAT INTO V_GARG.
  LOOP AT IT_ENQ WHERE GARG = V_GARG.
    CONCATENATE 'Material' V_LMAT 'is locked by' IT_ENQ-GUNAME 'with T-code' IT_ENQ-GTCODE INTO V_PESAN SEPARATED BY SPACE.
    MESSAGE V_PESAN TYPE 'I'.
    FLAG = 'X'.
  ENDLOOP.

  V_GARG+21(10) = IN_CHARG1.
  LOOP AT IT_ENQ WHERE GARG = V_GARG.
    CONCATENATE 'Batch' IN_CHARG1 'is locked by' IT_ENQ-GUNAME 'with T-code' IT_ENQ-GTCODE INTO V_PESAN SEPARATED BY SPACE.
    MESSAGE V_PESAN TYPE 'I'.
    FLAG = 'X'.
  ENDLOOP.

  V_GARG+21(10) = IN_CHARG2.
  LOOP AT IT_ENQ WHERE GNAME = 'MCH1' AND GARG = V_GARG.
    CONCATENATE 'Batch' IN_CHARG2 'is locked by' IT_ENQ-GUNAME 'with T-code' IT_ENQ-GTCODE INTO V_PESAN SEPARATED BY SPACE.
    MESSAGE V_PESAN TYPE 'I'.
    FLAG = 'X'.
  ENDLOOP.

  V_GARG+21(10) = IN_CHARG3.
  LOOP AT IT_ENQ WHERE GNAME = 'MCH1' AND GARG = V_GARG.
    CONCATENATE 'Batch' IN_CHARG3 'is locked by' IT_ENQ-GUNAME 'with T-code' IT_ENQ-GTCODE INTO V_PESAN SEPARATED BY SPACE.
    MESSAGE V_PESAN TYPE 'I'.
    FLAG = 'X'.
  ENDLOOP.

  CLEAR: V_LMAT, V_GARG, V_PESAN.
  REFRESH: IT_ENQ.

ENDFORM.                    "CHECKING_LOCK_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_LEPAS_CORE_RTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BATCH    text
*      -->P_DWERKS   text
*----------------------------------------------------------------------*
FORM F_LEPAS_CORE_RTP USING P_BATCH P_DWERKS.
  DATA: LT_ZCORER LIKE STANDARD TABLE OF ZCORER WITH HEADER LINE,
        WA_ZCORER LIKE LINE OF LT_ZCORER,
        WA_ZCORER2 LIKE LINE OF LT_ZCORER,
        LV_MAX_SEQ LIKE ZCORER-SEQNO,
        LV_TERMINAL LIKE ZCORER-ZUSER,
        LV_IP LIKE USR41-TERMINAL.

  IF P_BATCH IS INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION 'TERMINAL_ID_GET'
    EXPORTING
      USERNAME             = SY-UNAME
    IMPORTING
      TERMINAL             = LV_IP
    EXCEPTIONS
      MULTIPLE_TERMINAL_ID = 1
      NO_TERMINAL_FOUND    = 2
      OTHERS               = 3.

  CONCATENATE: SY-UNAME ';' LV_IP INTO LV_TERMINAL.

  "Step 1: Cek apakah Roll sudah terikat dengan Core RTP
*  SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER WHERE CHARG = P_BATCH.
  SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER WHERE CHARG = P_BATCH AND WERKS = P_DWERKS. "Change by Jarwo 16.07.2019
  IF LV_MAX_SEQ > 0.
    CLEAR: LT_ZCORER, WA_ZCORER, WA_ZCORER2.
    REFRESH: LT_ZCORER.

    SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE SEQNO = LV_MAX_SEQ.
    IF SY-SUBRC = 0.
*      SELECT SINGLE * INTO WA_ZCORER2 FROM ZCORER WHERE COREID = WA_ZCORER-COREID AND CHARG = 'MASTER'.
      SELECT SINGLE * INTO WA_ZCORER2 FROM ZCORER WHERE COREID = WA_ZCORER-COREID AND CHARG = 'MASTER' AND WERKS = P_DWERKS. "Change by Jarwo 16.07.2019
      IF SY-SUBRC = 0.
        "Cek status terakhir dari Core
        IF WA_ZCORER2-STATUS = 'R' OR WA_ZCORER2-STATUS = 'B'.
          "Cek batch terakhir yang terikat Core ID tersebut.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZCORER UP TO 1 ROWS
          FROM ZCORER
          WHERE
            COREID = WA_ZCORER2-COREID AND
            CHARG <> 'MASTER' AND
            CHARG <> '' AND
            WERKS = P_DWERKS  "Add by Jarwo 16.07.2019
          ORDER BY SEQNO DESCENDING.

          "Ambil Batch terakhir dr Core ID yg bersangkutan.
          READ TABLE LT_ZCORER INDEX 1.

          "Cek apakah Batch yang akan di-Cancel sama dengan Batch terakhir yang terikat Core ID.
          "Jika maka perlu dilepas.
          IF LT_ZCORER-CHARG = P_BATCH.
            CLEAR: LV_MAX_SEQ.
            SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER.

            WA_ZCORER-SEQNO = LV_MAX_SEQ + 1.
            WA_ZCORER-COREID = LT_ZCORER-COREID.
            WA_ZCORER-CHARG = ''.
            WA_ZCORER-STATUS = 'U'.
            WA_ZCORER-ERSDA = SY-DATUM.
            WA_ZCORER-ERZET = SY-UZEIT.
            WA_ZCORER-ZUSER = LV_TERMINAL.
            WA_ZCORER-REMARK = 'Cancel SR.'.

            MODIFY ZCORER FROM WA_ZCORER.
            COMMIT WORK.

            CLEAR: WA_ZCORER.
*            SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.
            SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER' AND WERKS = P_DWERKS. "Change by Jarwo 16.07.2019
            WA_ZCORER-STATUS = 'U'.
            WA_ZCORER-ERSDA = SY-DATUM.
            WA_ZCORER-ERZET = SY-UZEIT.
            WA_ZCORER-ZUSER = LV_TERMINAL.
            MODIFY ZCORER FROM WA_ZCORER.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_LEPAS_CORE_RTP

* Added by Dila 16.10.2023
*----------------------------------------------------------------------*
*  MODULE TBLCORE_ADD_TYPE_CORE OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TBLCORE_ADD_TYPE_CORE OUTPUT.
  DESCRIBE TABLE IT_TYCORE LINES TBLCORE-LINES.
ENDMODULE.                    "TBLCORE_ADD_TYPE_CORE OUTPUT

*----------------------------------------------------------------------*
*  MODULE TBLCORE_GET_LINES OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TBLCORE_GET_LINES OUTPUT.
  G_TBLCORE_LINES = SY-LOOPC.
ENDMODULE.                    "TBLCORE_GET_LINES OUTPUT

*----------------------------------------------------------------------*
*  MODULE F4_TYPECORE INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE F4_TYPECORE INPUT.
  TYPES: BEGIN OF T_CORE,
           ATWRT LIKE CAWN-ATWRT,
        END OF T_CORE.

  DATA: IT_TYPECORE TYPE T_CORE OCCURS 0 WITH HEADER LINE.
  DATA: RETURN_TAB TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  LOOP AT ITAB_POS.
    R_DIAMETER_CORE-SIGN = 'I'.
    R_DIAMETER_CORE-OPTION = 'CP'.
    R_DIAMETER_CORE-LOW = ITAB_POS-CORE && '*'.
    APPEND R_DIAMETER_CORE.
  ENDLOOP.

  SELECT T1~ATWRT
    INTO CORRESPONDING FIELDS OF TABLE IT_TYPECORE
    FROM CAWN AS T1
    JOIN CABN AS T2 ON T2~ATINN = T1~ATINN AND T2~ADZHL = T2~ADZHL
    WHERE T2~ATNAM IN ('ZZCORETYPE') AND T1~ATWRT IN R_DIAMETER_CORE. "AND T1~ATWRT LIKE '3%'.
*    WHERE T2~ATNAM IN ('ZZCORETYPE') AND T1~ATWRT eq IT_TYCORE-ZZCORE. "AND T1~ATWRT LIKE '3%'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ATWRT'
      WINDOW_TITLE    = 'Core Type List'
      VALUE_ORG       = 'S'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'IT_TYCORE-TYPECORE'
    TABLES
      VALUE_TAB       = IT_TYPECORE
      RETURN_TAB      = RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDMODULE.                    "F4_TYPECORE INPUT

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY.

  FIELD-SYMBOLS: <FS_POS> LIKE LINE OF ITAB_POS.

*Tambahan Combine Order Type 28 January 2013
  CLEAR: V_AUART.
  SELECT SINGLE AUART
    INTO V_AUART
    FROM AUFK
   WHERE AUFNR = COM_ORDER.
*End Tambahan Combine Order Type 28 January 2013

*Get Resource Indicator
  CLEAR: V_ABLAD.
  SELECT SINGLE ABLAD
    INTO V_ABLAD
    FROM AFPO
   WHERE AUFNR = COM_ORDER AND ABLAD IN ('SS','MS').

* Get position in batch
  CLEAR: ITAB_POS.
  REFRESH: ITAB_POS.
  LOOP AT ZBOXER.
    CHECK ZBOXER-AUFNR NE '' AND ZBOXER-AUFNR NE SPACE.
    CLEAR: WA_POS, V_LICHA, V_CHARG, V_AUFNR, MCH1.
    WA_POS-AUFNR = ZBOXER-AUFNR.
    WA_POS-MATNR = ZBOXER-MATNR.
    WA_POS-WERKS = ZBOXER-WERKS.
    SELECT LICHA CHARG "*
      INTO (MCH1-LICHA,MCH1-CHARG)
      FROM MCH1
     WHERE MATNR = ZBOXER-MATNR AND LICHA = ZBOXER-AUFNR.
*      %_HINTS ORACLE 'INDEX("MCH1" "MCH1~Z03")'.
      WA_POS-LICHA = MCH1-LICHA.
      WA_POS-CHARG = MCH1-CHARG.
      CLEAR: MCH1.
      APPEND WA_POS TO ITAB_POS.
    ENDSELECT.
  ENDLOOP.
  CLEAR: RIBUAN, PULUHAN.
**  PERFORM GET_DEC_NOTATION USING SY-UNAME CHANGING RIBUAN PULUHAN.
  PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.
  LOOP AT ITAB_POS ASSIGNING <FS_POS>.
    CLEAR: V_MATNR, V_CHARG, V_WERKS, V_POSMS, V_POSSS, V_GRADE, V_TYPE, V_THICKNESS, V_WIDTH, V_LENGTH,
           V_IN, V_OUT, V_TREATMENT, V_DERMS, V_DERSS, V_EXTRA, V_EXTRA2, V_CONV, V_EXTRALASL, V_CODE, V_CORE, V_CORETYPE.
    V_MATNR = <FS_POS>-MATNR.
    V_CHARG = <FS_POS>-CHARG.
    V_WERKS = <FS_POS>-WERKS.
    PERFORM GET_POSITION USING V_MATNR V_CHARG V_WERKS
                         CHANGING V_POSMS V_POSSS V_GRADE V_TYPE V_THICKNESS V_WIDTH V_LENGTH V_IN V_OUT
                                  V_TREATMENT V_DERMS V_DERSS V_EXTRA V_EXTRA2 V_CONV V_EXTRALASL V_CODE V_CORE V_CORETYPE.
    <FS_POS>-POSMS = V_POSMS.
    <FS_POS>-POSSS = V_POSSS.
    <FS_POS>-GRADE = V_GRADE.
    <FS_POS>-TYPE  = V_TYPE.
    <FS_POS>-CODE  = V_CODE.
    <FS_POS>-ZZCORETYPE  = V_CORETYPE. "Additional 17.10.2023 (Dila)
    <FS_POS>-THICK = V_THICKNESS.
    CLEAR: V_WIDTH, V_LENGTH.
    SELECT SINGLE ZWIDTH ZLENGTH
      INTO (V_WIDTH, V_LENGTH)
      FROM AUFK
     WHERE AUFNR = <FS_POS>-AUFNR.
    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_WIDTH
        IMPORTING
          OUTPUT = <FS_POS>-WIDTH.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = V_LENGTH
        IMPORTING
          OUTPUT = <FS_POS>-LENG.
    ENDIF.
    <FS_POS>-IN    = V_IN.
    <FS_POS>-OUT   = V_OUT.
    <FS_POS>-TREAT = V_TREATMENT.
    <FS_POS>-DERMS = V_DERMS.
    <FS_POS>-DERSS = V_DERSS.
    <FS_POS>-EXTRA = V_EXTRA.
    <FS_POS>-CONV  = V_CONV.
    <FS_POS>-ZZEXTRALENGTHASAL  = V_EXTRALASL.
    <FS_POS>-CORE  = V_CORE. " Additional ZZCORE 7 January 2013
  ENDLOOP.

  REFRESH: IT_TYCORE.
  CLEAR: IT_TYCORE.

  LOOP AT ITAB_POS.

    IF V_ABLAD = 'MS'.
      IT_TYCORE-POSISI = ITAB_POS-POSMS.
    ELSE.
      IT_TYCORE-POSISI = ITAB_POS-POSSS.
    ENDIF.
    IT_TYCORE-PORI = ITAB_POS-AUFNR.
    IT_TYCORE-ZZCHARG = ITAB_POS-CHARG.
    IT_TYCORE-ZZCORE = ITAB_POS-CORE.
    IT_TYCORE-TYPECORE = ITAB_POS-ZZCORETYPE.

    APPEND IT_TYCORE.
  ENDLOOP.
ENDFORM.                    "F_DISPLAY

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_3000 OUTPUT.
  SET PF-STATUS 'STCONFCORE'.
  SET TITLEBAR 'TADDCORE'.

ENDMODULE.                 " STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.
  CASE SY-UCOMM.
    WHEN 'CLOSE'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'SIMPAN'.
      PERFORM F_SAVE.
    WHEN 'BTN_PUSH'.
      PERFORM F_SET_MASS_CORE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_3000  INPUT


*----------------------------------------------------------------------*
*  MODULE TC_tycore_MODIFY INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TBLCORE_MODIFY INPUT.
  PERFORM MOVE_SCREEN_TO_TYCORE.
ENDMODULE.                 " TC_HALHRM_MODIFY  INPUT


*----------------------------------------------------------------------*
*  MODULE tblcore_INITIAL INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TBLCORE_INITIAL INPUT.
  IF IT_TEMP[] IS NOT INITIAL AND IT_TYCORE[] IS INITIAL.
    IT_TYCORE[] = IT_TEMP[].
    CLEAR IT_TEMP. REFRESH IT_TEMP.
  ENDIF.
ENDMODULE.                 " TC_HALHRM_INITIAL  INPUT

*&---------------------------------------------------------------------*
*&      Form  MOVE_SCREEN_TO_TYCORE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MOVE_SCREEN_TO_TYCORE .
  DATA: LINE TYPE I.

  DESCRIBE TABLE IT_TYCORE LINES LINE.
  IF LINE = 0.
    CLEAR IT_TEMP.
    IF IT_TYCORE-PORI NE SPACE.
      MOVE IT_TYCORE TO IT_TEMP.
    ENDIF.
    APPEND IT_TEMP. CLEAR IT_TEMP.
  ELSE.
    MODIFY IT_TYCORE
      INDEX TBLCORE-CURRENT_LINE.
  ENDIF.
ENDFORM.                    "MOVE_SCREEN_TO_TYCORE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_SAVE.
  IF IT_TYCORE-TYPECORE IS NOT INITIAL.
    DATA : TEMP_ATWRT LIKE CAWN-ATWRT,
           TEMP_TYPECORE LIKE CAWN-ATWRT.

    LOOP AT ITAB_POS.
      R_DIAMETER_CORE-SIGN = 'I'.
      R_DIAMETER_CORE-OPTION = 'CP'.
      R_DIAMETER_CORE-LOW = ITAB_POS-CORE && '*'.
      APPEND R_DIAMETER_CORE.

    ENDLOOP.

    SELECT SINGLE T1~ATWRT
    INTO TEMP_TYPECORE
    FROM CAWN AS T1
    JOIN CABN AS T2 ON T2~ATINN = T1~ATINN AND T2~ADZHL = T2~ADZHL
    WHERE T2~ATNAM IN ('ZZCORETYPE') AND T1~ATWRT IN R_DIAMETER_CORE AND ATWRT = IT_TYCORE-TYPECORE.

    SELECT SINGLE ATWRT FROM CAWN INTO TEMP_ATWRT
      WHERE CAWN~ATWRT = IT_TYCORE-TYPECORE.

    IF TEMP_TYPECORE EQ SPACE.
      MESSAGE 'Type core is invalid' TYPE 'I'.
      LEAVE TO SCREEN 3000.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE 'Type core field is required' TYPE 'I'.
    LEAVE TO SCREEN 3000.
    EXIT.
  ENDIF.
  LOOP AT IT_TYCORE WHERE TYPECORE IS NOT INITIAL.
    CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC, V_MESS.

    READ TABLE ITAB_POS WITH KEY CHARG = IT_TYCORE-ZZCHARG.

    IF IT_TYCORE-ZZCORE(1) NE IT_TYCORE-TYPECORE(1).
      MESSAGE 'Core Type and Core is different!' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 3000.
    ENDIF.

    CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
      EXPORTING
        I_MATNR      = ITAB_POS-MATNR
        I_CHARG      = IT_TYCORE-ZZCHARG
        I_MARA_LEVEL = 'X'
      IMPORTING
        E_CLASS      = VCLASS
        E_KLART      = VKLART
        E_OBTAB      = VOBTAB
        E_OBJEC      = VOBJEC.

    CLEAR : CHAR_OF_BATCH.
    REFRESH: CHAR_OF_BATCH.

    PERFORM VB_INIT.

    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
      EXPORTING
        MATNR              = ITAB_POS-MATNR
        CHARG              = ITAB_POS-CHARG
        GET_CLASSIFICATION = 'X'
      TABLES
        CHAR_OF_BATCH      = CHAR_OF_BATCH
      EXCEPTIONS
        NO_MATERIAL        = 1
        NO_BATCH           = 2
        NO_PLANT           = 3
        MATERIAL_NOT_FOUND = 4
        PLANT_NOT_FOUND    = 5
        NO_AUTHORITY       = 6
        BATCH_NOT_EXIST    = 7
        LOCK_ON_BATCH      = 8
        OTHERS             = 9.

    CLEAR: IT_CHAR.
    REFRESH: IT_CHAR.

    LOOP AT CHAR_OF_BATCH.
      IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
      APPEND IT_CHAR.
    ENDLOOP.

    READ TABLE IT_CHAR WITH KEY CHARACT = 'ZZCORETYPE'.
    IF SY-SUBRC EQ 0.
      IT_CHAR-VALUE_CHAR = IT_TYCORE-TYPECORE.
      MODIFY IT_CHAR TRANSPORTING VALUE_CHAR WHERE CHARACT = 'ZZCORETYPE'.
    ELSE.
      IT_CHAR-CHARACT = 'ZZCORETYPE'.
      IT_CHAR-VALUE_CHAR = IT_TYCORE-TYPECORE.
      APPEND IT_CHAR.
    ENDIF.

    CLEAR: IT_RETURN2.
    REFRESH: IT_RETURN2.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
      EXPORTING
        OBJECTKEY          = VOBJEC
        OBJECTTABLE        = VOBTAB
        CLASSNUM           = VCLASS
        CLASSTYPE          = VKLART
      TABLES
        ALLOCVALUESNUMNEW  = IT_NUM
        ALLOCVALUESCHARNEW = IT_CHAR
        ALLOCVALUESCURRNEW = IT_CURR
        RETURN             = IT_RETURN2.

    LS_SUBRC = 0.
    CLEAR: VMESS, FLAG.
    LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
      CLEAR: VMESS.
      CONCATENATE ITAB_POS-CHARG '-' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE.
      LS_SUBRC = 1.
      FLAG = 'X'.
      IT_LOG-ICON = '@0A@'.
      IT_LOG-TRNS = 'Input Type Core'.
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.
    ENDLOOP.

    IF LS_SUBRC NE 0.
      CONCATENATE ITAB_POS-CHARG '-' IT_RETURN2-MESSAGE INTO V_MESS SEPARATED BY SPACE.
      MESSAGE V_MESS TYPE 'I'.
      LEAVE TO SCREEN 3000.
      EXIT.
    ENDIF.

    CLEAR: SY-SUBRC.
    CHECK FLAG EQ SPACE.

    IF LS_SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      CLEAR: VMESS.
      CONCATENATE ITAB_POS-CHARG '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-ICON = '@08@'.
      IT_LOG-TRNS = 'Input Type Core'.                      "#EC NOTEXT
      IT_LOG-MESS = VMESS.
      APPEND IT_LOG.

      ITAB_POS-ZZCORETYPE = IT_TYCORE-TYPECORE.
      MODIFY ITAB_POS TRANSPORTING ZZCORETYPE WHERE CHARG = IT_TYCORE-ZZCHARG.
    ENDIF.
  ENDLOOP.

  IF LS_SUBRC = 0.
    MESSAGE 'Change Core Type Success!' TYPE 'S' DISPLAY LIKE 'I'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    "F_SAVE

*&---------------------------------------------------------------------*
*&      Module  TBLCORE_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TBLCORE_MARK INPUT.
  DATA: G_TC_CORETYPE_WA2 LIKE LINE OF IT_TYCORE.
  IF TBLCORE-LINE_SEL_MODE = 1
  AND IT_TYCORE-MARK = 'X'.
    LOOP AT IT_TYCORE INTO G_TC_CORETYPE_WA2
      WHERE MARK = 'X'.
      G_TC_CORETYPE_WA2-MARK = ''.
      MODIFY IT_TYCORE
        FROM G_TC_CORETYPE_WA2
        TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY IT_TYCORE
    INDEX TBLCORE-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.                 " TBLCORE_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MASS_CORE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SET_MASS_CORE.
  TYPES: BEGIN OF T_CORE,
           ATWRT LIKE CAWN-ATWRT,
        END OF T_CORE.
  DATA: IT_TYPECORE TYPE T_CORE OCCURS 0 WITH HEADER LINE.

  LOOP AT IT_TYCORE WHERE ZZCORE NE IN_CORETYPE(1) AND MARK EQ 'X'.
    MESSAGE 'Core Type and Core is different!' TYPE 'I'.
    EXIT.
  ENDLOOP.

  CLEAR: R_DIAMETER_CORE.
  REFRESH: R_DIAMETER_CORE.

  LOOP AT ITAB_POS.
    R_DIAMETER_CORE-SIGN = 'I'.
    R_DIAMETER_CORE-OPTION = 'CP'.
    R_DIAMETER_CORE-LOW = ITAB_POS-CORE && '*'.
    APPEND R_DIAMETER_CORE.
  ENDLOOP.

  SELECT T1~ATWRT
    INTO CORRESPONDING FIELDS OF TABLE IT_TYPECORE
    FROM CAWN AS T1
    JOIN CABN AS T2 ON T2~ATINN = T1~ATINN AND T2~ADZHL = T2~ADZHL
    WHERE T2~ATNAM IN ('ZZCORETYPE') AND T1~ATWRT IN R_DIAMETER_CORE.

  READ TABLE IT_TYPECORE WITH KEY ATWRT = IN_CORETYPE.
  IF SY-SUBRC NE 0.
    MESSAGE 'Type core is invalid' TYPE 'I'.
    EXIT.
  ENDIF.

  READ TABLE IT_TYCORE WITH KEY MARK = 'X'.
  IF SY-SUBRC NE 0.
    IT_TYCORE-TYPECORE = IN_CORETYPE.
    MODIFY IT_TYCORE TRANSPORTING TYPECORE WHERE ZZCORE IS NOT INITIAL.
  ELSE.
    LOOP AT IT_TYCORE WHERE MARK EQ 'X'.
      IT_TYCORE-TYPECORE = IN_CORETYPE.
      MODIFY IT_TYCORE.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SET_BATCH_CORE
* End ***************************************