**&---------------------------------------------------------------------*
**&  Include           ZQMI_CHANGE_STAT_HU_F01
**&---------------------------------------------------------------------*
**INCLUDE ZABAPALV.

INCLUDE Z_PROG_INFO.

INCLUDE ZQMI_CHANGE_STAT_HU_ALV.

*Display Parameters
DATA : BEGIN OF IT_EXIDV OCCURS 0,
        EXIDV LIKE VEKP-EXIDV,
       END OF IT_EXIDV.

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: P_EXIDV FOR VEKP-EXIDV,
                P_WERKS FOR VEPO-WERKS OBLIGATORY DEFAULT '2000',
                P_MATNR FOR VEPO-MATNR,
                P_ERDAT FOR VEKP-ERDAT,
                P_LGORT FOR VEPO-LGORT.

SELECTION-SCREEN END OF BLOCK BLK1.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.



AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

START-OF-SELECTION.
  PERFORM DATA_RETRIEVAL.

AT USER-COMMAND.
  CASE SY-UCOMM.
    WHEN 'YES' OR 'LEAVE'.
      LEAVE TO TRANSACTION 'ZQM001P'."'ZQM017'.
  ENDCASE.

END-OF-SELECTION.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.
*  CLEAR : IT_EXIDV. REFRESH IT_EXIDV.
  IMPORT IT_EXIDV FROM MEMORY ID 'IT_EXIDV'.

  CLEAR CTR.
  MOVE: 'I' TO P_EXIDV-SIGN,
        'EQ' TO P_EXIDV-OPTION.

  LOOP AT IT_EXIDV.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IT_EXIDV-EXIDV
      IMPORTING
        OUTPUT = IT_EXIDV-EXIDV.

    MOVE IT_EXIDV-EXIDV TO P_EXIDV-LOW.
    APPEND P_EXIDV.
  ENDLOOP.


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM DATA_RETRIEVAL.
DATA : HU_ST_INIT LIKE HEADER51-PLANHU.
*  tambahan tanggal 22-10.2012(status yang diambil dari tabel zqm001 adalah
*  status terahir)

* get   HU no and stat
  SELECT VEKP~EXIDV
         ZQM001~PSTAT
         VEPO~MATNR
         VEKP~ERDAT
         VEKP~VENUM
        INTO CORRESPONDING FIELDS OF TABLE ITRESULT
        FROM VEKP JOIN ZQM001 ON VEKP~EXIDV EQ ZQM001~EXIDV
                  JOIN VEPO ON VEKP~VENUM EQ VEPO~VENUM
        WHERE VEKP~EXIDV IN P_EXIDV.

  IF SY-SUBRC = 0.
    SORT ITRESULT BY EXIDV.
    DELETE ADJACENT DUPLICATES FROM ITRESULT COMPARING ALL FIELDS.
    IF P_ERDAT[] IS NOT INITIAL.
      DELETE ITRESULT WHERE ERDAT NOT IN P_ERDAT.
    ENDIF.
*HU yang bisa dichange hanya jika low level HU nya ada di SLOC Production
    LOOP AT ITRESULT.
      CLEAR: ITVENUM[], ITUNVEL[], ITLGORT[].
      REFRESH: ITVENUM[], ITUNVEL[], ITLGORT[].

*get venum by HU Number
      SELECT VENUM
        FROM VEKP
        INTO CORRESPONDING FIELDS OF TABLE ITVENUM
        WHERE EXIDV = ITRESULT-EXIDV.
      IF SY-SUBRC = 0.
*get lower level HU
        LOOP AT ITVENUM.
          SELECT UNVEL
          FROM VEPO
          INTO CORRESPONDING FIELDS OF TABLE ITUNVEL
          WHERE VENUM = ITVENUM-VENUM.
        ENDLOOP.
      ENDIF.

      CLEAR CTR.
      DESCRIBE TABLE ITUNVEL LINES CTR.
*     jika HU punya Unvel/lower level HU
      IF CTR > 0.
        LOOP AT ITUNVEL.
          SELECT VENUM LGORT CHARG
          FROM VEPO
          INTO CORRESPONDING FIELDS OF TABLE ITLGORT
          WHERE VENUM = ITUNVEL-UNVEL AND
                WERKS IN P_WERKS. " AND
*                  LGORT IN ('2301','2303', '2305', '2307', '2309',
*                            '2311', '2313', '2315', '2317', '2319',
*                            '1301', '1303', '1305', '1307').
        ENDLOOP.
      ENDIF.

      CLEAR: AD, CTR.
      DESCRIBE TABLE ITLGORT LINES CTR.
      IF CTR = 0.
        CLEAR ITLGORT. REFRESH ITLGORT.

        SELECT VENUM LGORT CHARG
            FROM VEPO
            INTO CORRESPONDING FIELDS OF TABLE ITLGORT
            WHERE VENUM = ITRESULT-VENUM AND
                  WERKS IN P_WERKS.
        READ TABLE ITLGORT INDEX 1.
        IF SY-SUBRC = 0 .
          ITRESULT-VENUM = ITLGORT-VENUM.
          ITRESULT-LGORT = ITLGORT-LGORT.
          ITRESULT-CHARG = ITLGORT-CHARG.

          ITRESULT-VENUM1 = ITLGORT-VENUM.
          MODIFY ITRESULT.
        ELSE.
*          SELECT SINGLE VENUM
*            INTO ITRESULT-VENUM
*            FROM VEKP
*            WHERE EXIDV = ITRESULT-EXIDV AND
*                  WERKS IN P_WERKS.
*
*          SELECT SINGLE LGORT CHARG
*              INTO (ITRESULT-LGORT, ITRESULT-CHARG )
*              FROM VEPO
*              WHERE VENUM = ITRESULT-VENUM AND
*                    WERKS IN P_WERKS.
*
*          IF SY-SUBRC = 0.
            ITRESULT-VENUM1 = ITRESULT-VENUM.
            MODIFY ITRESULT.
*          ELSE.
**            DELETE ITRESULT.
**            CONTINUE.
*            ITRESULT-VENUM1 = ITRESULT-VENUM.
*            MODIFY ITRESULT.
*          ENDIF.
        ENDIF.

      ELSE.
        READ TABLE ITLGORT INDEX 1.
        ITRESULT-VENUM = ITLGORT-VENUM.
        ITRESULT-LGORT = ITLGORT-LGORT.
        ITRESULT-CHARG = ITLGORT-CHARG.

        READ TABLE ITVENUM INDEX 1.
        ITRESULT-VENUM1 = ITVENUM-VENUM.
        MODIFY ITRESULT.
      ENDIF.
    ENDLOOP.

*cek STAT EQ 'E0001'.
    DELETE ITRESULT WHERE PSTAT NE 'P' AND PSTAT NE 'H'.
    LOOP AT ITRESULT.
*        Set HU Status
      IF ITRESULT-PSTAT EQ 'P'.
        ITRESULT-PSTATD = 'Pass'.
      ELSEIF ITRESULT-PSTAT = 'H'.
        ITRESULT-PSTATD = 'Hold'.
      ELSE.
        ITRESULT-PSTATD = ' '.
      ENDIF.
      MODIFY ITRESULT.

*PENGISIAN MATERIAL DARI LOWER LEVEL HU
      SELECT SINGLE WERKS
        INTO P_WERKS
        FROM VEKP
        WHERE EXIDV EQ ITRESULT-EXIDV.

      SELECT SINGLE
         VEPO~MATNR
        INTO ITRESULT-MATNR
        FROM  VEPO  "JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
        WHERE VENUM = ITRESULT-VENUM.
*              AND WERKS IN P_WERKS.
*              AND MATNR IN P_MATNR
*                    AND VEPO~WDATU IN P_WDATU
*              AND VEPO~LGORT IN P_LGORT.
      IF SY-SUBRC NE 0.
        DELETE ITRESULT.
        CONTINUE.
      ELSE.
        CLEAR: POBJNR, VENUM.
        MOVE ITRESULT-VENUM1 TO VENUM.
        CONCATENATE 'HU' VENUM INTO POBJNR.
        MOVE VENUM TO ITRESULT-VENUM1.
        MOVE POBJNR TO ITRESULT-OBJNR.

        SELECT SINGLE STAT
          INTO ITRESULT-STAT
          FROM HUSSTAT
          WHERE STAT EQ 'E0001'
          AND INACT EQ ''
          AND OBJNR = ITRESULT-OBJNR.
        IF SY-SUBRC NE 0.
          DELETE ITRESULT.
          CONTINUE.
        ELSE.
          ITRESULT-K = 'QA IN'.
        ENDIF.

        SHIFT ITRESULT-EXIDV LEFT DELETING LEADING '0'.
        MODIFY ITRESULT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM ITRESULT COMPARING ALL FIELDS.
  DELETE ITRESULT WHERE STAT NE 'E0001'.


*  PERFORM DISPLAY_DATA.

*  tambahan tanggal 25-10-2012
  IF ITRESULT[] IS NOT INITIAL.
    CLEAR HU_ST_INIT.
*      PERFORM SETHU02HEADER.
    SET PARAMETER ID 'WRK' FIELD '1000'. "HUPAST_T-PLANT.
    SET PARAMETER ID 'LAG' FIELD SPACE. "'2L32'. "HUPAST_T-STGE_LOC.
    SET PARAMETER ID 'HANDLINGUNIT' FIELD SPACE.
    CALL FUNCTION 'HU_PACKING_REFRESH'.
  ENDIF.

  GET PARAMETER ID 'HU_ST_INIT' FIELD HU_ST_INIT.
*  IF IT_BDCMSGCOLL[] IS NOT INITIAL.
*    CLEAR WA_BDCMSGCOLL.
*    LOOP AT IT_BDCMSGCOLL INTO WA_BDCMSGCOLL WHERE MSGTYP = 'E' .
*      EXIT.
*    ENDLOOP.
*  ENDIF.
  IF HU_ST_INIT NE ''.
    CLEAR WA_BDCMSGCOLL.
    LOOP AT ITRESULT.
      CLEAR :IT_BDCMSGCOLLE. REFRESH IT_BDCMSGCOLLE.
      PERFORM CHANGE_HUBYBDC.
    ENDLOOP.
  ELSE.
*    PERFORM SETHU02HEADER.
    LOOP AT ITRESULT.
      CLEAR :IT_BDCMSGCOLLE. REFRESH IT_BDCMSGCOLLE.
      PERFORM CHANGE_HUBYBDC1.
    ENDLOOP.
  ENDIF.

*  LOOP AT ITRESULT.
*    CLEAR :IT_BDCMSGCOLLE. REFRESH IT_BDCMSGCOLLE.
*    PERFORM CHANGE_HUBYBDC.
*  ENDLOOP.

* BACA SEMUA PESAN TERAHIR
  IF IT_BDCMSGCOLLE[] IS   NOT INITIAL.
    EXPORT IT_BDCMSGCOLLE TO MEMORY ID 'IT_BDCMSGCOLLE'.
  ENDIF.

  SET SCREEN 0.
  LEAVE TO SCREEN 0.
ENDFORM.                    "DATA_RETRIEVAL

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE
                                        SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.

  CLEAR LS_LINE.
  REFRESH LT_TOP_OF_PAGE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = 'CHANGE HU STATUS'.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    " COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL.
  LOOP AT ITRESULT WHERE BOX EQ ''.
    ITRESULT-BOX = 'X'.
    MODIFY ITRESULT.
  ENDLOOP.
*  PERFORM DISPLAY_ALV.
  PERFORM DISPLAY_DATA.
ENDFORM.                    "SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESELECT_ALL.
  LOOP AT ITRESULT WHERE BOX NE ''.
    CLEAR ITRESULT-BOX.
    MODIFY ITRESULT.
  ENDLOOP.
*  PERFORM DISPLAY_ALV.
  PERFORM DISPLAY_DATA.
ENDFORM.                    "DESELECT_ALL

*&---------------------------------------------------------------------*
*&      Form EDIT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EDIT_STATUS.

  DATA : STSMA LIKE TJ30T-STSMA,
         ESTAT LIKE TJ30T-ESTAT.
  DATA : WA_HUSSTAT TYPE HUSSTAT.
  DATA: BEGIN OF ERROR OCCURS 10,
          EXIDV LIKE VEKP-EXIDV.
          INCLUDE STRUCTURE BAPIRET2.
  DATA: END OF ERROR.
  DATA : FIELDS LIKE HELP_VALUE OCCURS 0 WITH HEADER LINE.
  DATA : MESSAGE LIKE BAPIRET2-MESSAGE.
  DATA : BEGIN OF IT_ERR OCCURS 0,
          ERR LIKE BAPIRET2-MESSAGE,
         END OF IT_ERR.

  CLEAR : WA_HUSSTAT, ERROR[]. REFRESH ERROR[].

  LOOP AT ITRESULT WHERE BOX = 'X'.
    CLEAR WA_HUSSTAT.
    CLEAR: POBJNR, VENUM, STSMA, ESTAT.
*      IF ITRESULT-K = 'QA OK' AND ITRESULT-BOX EQ 'X'.

    SELECT SINGLE TJ30T~STSMA
         INTO STSMA
         FROM TJ30T
         JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
         JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
         WHERE HUSSTAT~OBJNR = ITRESULT-OBJNR "POBJNR
         AND HUSSTAT~STAT = TJ30T~ESTAT
         AND HUSSTAT~INACT = ''
         AND TJ30T~SPRAS = 'EN'.

    SELECT SINGLE TJ30T~ESTAT
         INTO ESTAT
         FROM TJ30T
         JOIN HUSTOBJ ON TJ30T~STSMA = HUSTOBJ~STSMA
         JOIN HUSSTAT ON HUSTOBJ~OBJNR  =  HUSSTAT~OBJNR
         WHERE HUSSTAT~OBJNR = ITRESULT-OBJNR "POBJNR
         AND HUSSTAT~STAT = TJ30T~ESTAT
         AND HUSSTAT~INACT = ''
         AND TJ30T~SPRAS = 'EN'.

    CLEAR: POBJNR, VENUM.
    SELECT SINGLE VEPO~VENUM INTO VENUM
      FROM  VEPO JOIN VEKP ON VEKP~VENUM = VEPO~VENUM
      WHERE VEKP~EXIDV = ITRESULT-EXIDV.

    CONCATENATE 'HU' VENUM INTO POBJNR.
*          MOVE VENUM TO ITRESULT-VENUM.
*          MOVE POBJNR TO ITRESULT-OBJNR.

    SELECT SINGLE STAT
      INTO ITRESULT-STAT
      FROM HUSSTAT
      WHERE STAT EQ 'E0001'
      AND INACT EQ ''
      AND OBJNR = ITRESULT-OBJNR.

*             UPDATE TJ30T SET TXT04 = 'QAOK'
*                WHERE STSMA EQ STSMA
*                AND ESTAT EQ ESTAT.

    MOVE ITRESULT-OBJNR TO POBJNR.
    WA_HUSSTAT-OBJNR = POBJNR.
    WA_HUSSTAT-STAT = 'E0001'.
    WA_HUSSTAT-INACT = ''.

    SELECT SINGLE *
      FROM HUSSTAT
      INTO WA_HUSSTAT
      WHERE OBJNR = ITRESULT-OBJNR
      AND STAT = 'E0001'
      AND INACT = ''.
    IF SY-SUBRC = 0.
      CLEAR IT_BDCMSGCOLL[]. REFRESH IT_BDCMSGCOLL[].
      CLEAR: AD, ERRMSG, MSGID, MSGNR.
      PERFORM CHANGE_HUBYBDC.
      CLEAR CTR.
      LOOP AT IT_BDCMSGCOLL WHERE MSGTYP EQ 'E'.
        CTR = CTR  + 1.
        ERROR-EXIDV = ITRESULT-EXIDV.
        ERROR-ID  =  IT_BDCMSGCOLL-MSGID.
        ERROR-NUMBER =  IT_BDCMSGCOLL-MSGNR.
        ERROR-MESSAGE_V1 = IT_BDCMSGCOLL-MSGV1.
        ERROR-MESSAGE_V2 = IT_BDCMSGCOLL-MSGV2.
        ERROR-MESSAGE_V3 = IT_BDCMSGCOLL-MSGV3.
        ERROR-MESSAGE_V4 = IT_BDCMSGCOLL-MSGV4.
        APPEND ERROR.
      ENDLOOP.

      IF CTR = 0.
        LOOP AT IT_BDCMSGCOLL WHERE MSGTYP EQ 'S'.
          MOVE IT_BDCMSGCOLL-MSGTYP TO AD.
          MOVE IT_BDCMSGCOLL-MSGID TO MSGID.
          MOVE IT_BDCMSGCOLL-MSGNR TO MSGNR.
        ENDLOOP.

        IF MSGID EQ 'HUDIALOG' AND MSGNR EQ '008' AND AD EQ 'S'.
          ITRESULT-K = 'QA OK'.
          MODIFY ITRESULT.
        ELSE.
          LOOP AT IT_BDCMSGCOLL WHERE MSGTYP EQ 'S'.
            ERROR-EXIDV = ITRESULT-EXIDV.
            ERROR-ID  =  IT_BDCMSGCOLL-MSGID.
            ERROR-NUMBER =  IT_BDCMSGCOLL-MSGNR.
            ERROR-MESSAGE_V1 = IT_BDCMSGCOLL-MSGV1.
            ERROR-MESSAGE_V2 = IT_BDCMSGCOLL-MSGV2.
            ERROR-MESSAGE_V3 = IT_BDCMSGCOLL-MSGV3.
            ERROR-MESSAGE_V4 = IT_BDCMSGCOLL-MSGV4.
            APPEND ERROR.
          ENDLOOP.
        ENDIF.
      ELSE.

      ENDIF.
    ENDIF.
*        MODIFY ITRESULT.
  ENDLOOP.

  CLEAR CTR.
  DESCRIBE TABLE ERROR LINES CTR.
  IF CTR > 0.
    LOOP AT ERROR.
      CLEAR MESSAGE.
      IF ERROR-ID NE 'HUDIALOG'.
        CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
          EXPORTING
            ID         = ERROR-ID
            NUMBER     = ERROR-NUMBER
            LANGUAGE   = SY-LANGU
            TEXTFORMAT = 'HTM'
            MESSAGE_V1 = ERROR-MESSAGE_V1
            MESSAGE_V2 = ERROR-MESSAGE_V2
            MESSAGE_V3 = ERROR-MESSAGE_V3
            MESSAGE_V4 = ERROR-MESSAGE_V4
          IMPORTING
            MESSAGE    = MESSAGE.

        IF MESSAGE CS 'No batch input data'.
          CLEAR MESSAGE.
          CONCATENATE 'No data in HU02 for HU ' ERROR-EXIDV INTO MESSAGE SEPARATED BY SPACE.
        ENDIF.
      ELSE.
        MESSAGE = ERROR-MESSAGE.
      ENDIF.
      IT_ERR-ERR = MESSAGE.
      APPEND IT_ERR.
    ENDLOOP.
  ENDIF.

  CLEAR CTR.
  DESCRIBE TABLE IT_ERR LINES CTR.
  IF CTR > 0.
    CLEAR FIELDS[]. REFRESH FIELDS[].
    FIELDS-TABNAME = 'ZTDELINSP_I'.
    FIELDS-FIELDNAME = 'INSLOTPROCTXT'.
    APPEND FIELDS.

    CALL FUNCTION 'POPUP_TO_SHOW_DB_DATA_IN_TABLE'
                EXPORTING
                  TITLE_TEXT              = 'Error When running BDC'
                TABLES
                  FIELDS                  = FIELDS
                  VALUETAB                = IT_ERR
*               EXCEPTIONS
*                 FIELD_NOT_IN_DDIC       = 1
*                 OTHERS                  = 2
                        .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

* REFRESH DATA (hilangin yang berhasil/sudah ok)
  PERFORM REFRESH_DATA.
*  PERFORM DISPLAY_ALV.
  PERFORM DISPLAY_DATA.
ENDFORM.                    "EDIT_STATUS

*&---------------------------------------------------------------------*
*&      Form FILTER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILTER_DATA.
  DELETE ITRESULT WHERE BOX = 'X'.
*  PERFORM DISPLAY_ALV.
  PERFORM DISPLAY_DATA.
ENDFORM.                    "FILTER_DATA

*&---------------------------------------------------------------------*
*&      Form REFRESH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM REFRESH_DATA.
  DELETE ITRESULT WHERE K EQ 'QA OK' AND STAT EQ 'E0002'.
ENDFORM.                    "REFRESH_DATA


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  CHANGE_HUBYBDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_HUBYBDC.
  DATA : VENUM LIKE VEPO-VENUM,
         UNVEL LIKE VEPO-UNVEL,
         TXT(15), TXTNO(5),
         TXT1(15),
        CTR2 TYPE I,
        LGORT LIKE T001L-LGORT.

  CLEAR: IT_BDCDATA, IT_BDCMSGCOLL.
  REFRESH: IT_BDCDATA, IT_BDCMSGCOLL.
  CLEAR: CTR, UNVEL, CTR2, VENUM, TXT, TXTNO, TXT1, LGORT.

***  CTR2 = 1.
***  UNVEL = ITRESULT-VENUM1.
***  SELECT COUNT(*)
***    INTO CTR
***    FROM VEPO
***    WHERE VENUM = UNVEL AND UNVEL NE ''.
***  CTR = CTR + 1.
***  TXTNO = CTR.
***  CONDENSE TXTNO.
***  IF CTR >= 10.
***    CONCATENATE 'V51VE-EXIDV(' TXTNO ')' INTO TXT.
***    CONCATENATE 'V51VE-SELKZ('TXTNO ')' INTO TXT1.
***  ELSE.
***    CONCATENATE 'V51VE-EXIDV(0' TXTNO ')' INTO TXT.
***    CONCATENATE 'V51VE-SELKZ(0'TXTNO ')' INTO TXT1.
***  ENDIF.
***  SELECT SINGLE LGORT
***    INTO LGORT
***    FROM T001L WHERE WERKS = '2000'.
***
***  SET PARAMETER ID 'WRK' FIELD '2000'. "HUPAST_T-PLANT.
***  SET PARAMETER ID 'LAG' FIELD LGORT .
***  IF CTR > 1."ITRESULT-VENUM1 NE ITRESULT-VENUM.
****   jika pallet berisi box
******    perform bdc_dynpro      using 'SAPLV51G' '6000'.
******    perform bdc_field       using 'BDC_OKCODE'
******                                  '=SICH'.
******    perform bdc_field       using 'BDC_CURSOR'
******                                  'HUM_MM_KOPFDATEN-WERKS'.
******    perform bdc_field       using 'HUM_MM_KOPFDATEN-WERKS'
******                                  '2000'.
******    perform bdc_field       using 'HUM_MM_KOPFDATEN-LGORT'
******                                  ' '.
********
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=UE6POS'.
****    perform bdc_field       using 'BDC_CURSOR'
****                                  'HEADER51-PLANHU'.
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=ENTR'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  TXT."'V51VE-EXIDV(01)'.
***    PERFORM BDC_FIELD       USING TXT "'V51VE-EXIDV(01)'
***                                  ITRESULT-EXIDV.
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=DETVERTR'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  TXT. "'V51VE-EXIDV(01)'.
***    PERFORM BDC_FIELD       USING TXT1 "'V51VE-SELKZ(01)'
***                                  'X'.
***
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6100'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=HUSTAT02'.
****    perform bdc_field       using 'VEKP-VHILM'
****                                  'PPB1057017600270'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'VEKP_TXT-ANW_STATUS'.
***    PERFORM BDC_FIELD       USING 'VEKPVB-WERKS'
***                                  ITRESULT-WERKS. "'2000'.
***    PERFORM BDC_DYNPRO      USING 'SAPLBSVA' '0201'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'J_STMAINT-ANWS(02)'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=OKAY'.
****    perform bdc_field       using 'J_STMAINT-ANWS(01)'
****                                  ''.
****    perform bdc_field       using 'J_STMAINT-ANWS(02)'
****                                  'X'.
***    PERFORM BDC_FIELD       USING 'J_STMAINT-ANWS(01)' "STATUS
***                                  ''.
***    PERFORM BDC_FIELD       USING 'J_STMAINT-ANWS(02)'
***                                  'X'.
***
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6100'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'VEKP-VHILM'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=SICH'.
****    perform bdc_field       using 'VEKP-VHILM'
****                                  'PPB1057017600270'.
****    perform bdc_field       using 'VEKPVB-WERKS'
****                                  ITRESULT-WERKS. "'2000'.
***
***  ELSE.
****   jika hanya pallet
******    perform bdc_dynpro      using 'SAPLV51G' '6000'.
******    perform bdc_field       using 'BDC_OKCODE'
******                                  '=SICH'.
******    perform bdc_field       using 'BDC_CURSOR'
******                                  'HUM_MM_KOPFDATEN-WERKS'.
******    perform bdc_field       using 'HUM_MM_KOPFDATEN-WERKS'
******                                  '2000'.
******    perform bdc_field       using 'HUM_MM_KOPFDATEN-LGORT'
******                                  ' '.
********
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=ENTR'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  TXT. "'V51VE-EXIDV(01)'.
***    PERFORM BDC_FIELD       USING TXT "'V51VE-EXIDV(01)'
***                                  ITRESULT-EXIDV.
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6000'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=DETVERTR'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  TXT. "'V51VE-EXIDV(01)'.
***    PERFORM BDC_FIELD       USING TXT1 "'V51VE-SELKZ(01)'
***                                  'X'.
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6100'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'VEKP-VHILM'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=HUSTAT02'.
***    PERFORM BDC_DYNPRO      USING 'SAPLBSVA' '0201'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'J_STMAINT-ANWS(02)'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=OKAY'.
***    PERFORM BDC_FIELD       USING 'J_STMAINT-ANWS(01)'
***                                  ''.
***    PERFORM BDC_FIELD       USING 'J_STMAINT-ANWS(02)'
***                                  'X'.
***    PERFORM BDC_DYNPRO      USING 'SAPLV51G' '6100'.
***    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
***                                  'VEKP-VHILM'.
***    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
***                                  '=SICH'.
***  ENDIF.
  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'BDC_CURSOR'
                                'V51VE-EXIDV(01)'.
  perform bdc_field       using 'V51VE-EXIDV(01)'
                                ITRESULT-EXIDV. "'6000002208'.
  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=HUSUCH'.
  perform bdc_field       using 'BDC_CURSOR'
                                'V51VE-EXIDV(01)'.

  perform bdc_dynpro      using 'SAPLV51G' '6001'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  perform bdc_field       using 'VEKP-EXIDV'
                                ITRESULT-EXIDV. "'6000002208'.
  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=DETVERTR'.
  perform bdc_field       using 'BDC_CURSOR'
                                'V51VE-EXIDV(01)'.
  perform bdc_dynpro      using 'SAPLV51G' '6100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-VHILM'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=HUSTAT02'.
  perform bdc_dynpro      using 'SAPLBSVA' '0201'.
  perform bdc_field       using 'BDC_CURSOR'
                                'J_STMAINT-ANWS(02)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=OKAY'.
  perform bdc_field       using 'J_STMAINT-ANWS(01)'
                                ''.
  perform bdc_field       using 'J_STMAINT-ANWS(02)'
                                'X'.
  perform bdc_dynpro      using 'SAPLV51G' '6100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-VHILM'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SICH'.

  CALL TRANSACTION 'HU02' USING IT_BDCDATA
                                  MODE  'N'
                                  UPDATE 'S'
                                  MESSAGES INTO IT_BDCMSGCOLL.

  IF IT_BDCMSGCOLL[] IS NOT INITIAL.
    CLEAR WA_BDCMSGCOLL.
    LOOP AT IT_BDCMSGCOLL.
      WA_BDCMSGCOLL = IT_BDCMSGCOLL.
    ENDLOOP.
    APPEND WA_BDCMSGCOLL TO IT_BDCMSGCOLLE.
  ENDIF.
ENDFORM.                    "CHANGE_HUBYBDC


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
*&      Form  SETHU02HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SETHU02HEADER .
  CLEAR: IT_BDCDATA, IT_BDCMSGCOLL.
  REFRESH: IT_BDCDATA, IT_BDCMSGCOLL.

perform bdc_dynpro      using 'SAPLV51G' '6000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SICH'.
perform bdc_field       using 'BDC_CURSOR'
                              'HUM_MM_KOPFDATEN-WERKS'.
perform bdc_field       using 'HUM_MM_KOPFDATEN-WERKS'
                              '1000'.
perform bdc_field       using 'HUM_MM_KOPFDATEN-LGORT'
                              ' '.
CALL TRANSACTION 'HU02'
  USING IT_BDCDATA
                                  MODE  'N'
                                  UPDATE 'S'
                                  MESSAGES INTO IT_BDCMSGCOLL.
*perform bdc_transaction using 'HU02'.
ENDFORM.                    " SETHU02HEADER


FORM CHANGE_HUBYBDC1.
  DATA : VENUM LIKE VEPO-VENUM,
         UNVEL LIKE VEPO-UNVEL,
         TXT(15), TXTNO(5),
         TXT1(15),
        CTR2 TYPE I,
        LGORT LIKE T001L-LGORT.

  CLEAR: IT_BDCDATA, IT_BDCMSGCOLL.
  REFRESH: IT_BDCDATA, IT_BDCMSGCOLL.
  CLEAR: CTR, UNVEL, CTR2, VENUM, TXT, TXTNO, TXT1, LGORT.

    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6ALLG'.
*    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6030TAB'.
*   General Header Data
    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
*    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6030TAB'.
    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'HEADER51-PLANHU'.
    PERFORM BDC_FIELD   USING 'HEADER51-PLANHU'         'C'.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-WERKS'  '1000'. ""HUPAST_T-PLANT.
    PERFORM BDC_FIELD   USING 'HUM_MM_KOPFDATEN-LGORT'  SPACE. "'1302'. "HUPAST_T-STGE_LOC.

*   Entering packg matr (ADDED)
**    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
**    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
**    'SAPLV51G                                6020TAB'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=UE6HUS'.
***    PERFORM BDC_FIELD   USING 'BDC_CURSOR'      'V51VE-VHILM(01)'.
*    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.

    PERFORM BDC_DYNPRO  USING 'SAPLV51G'    '6000'.
    PERFORM BDC_FIELD   USING 'BDC_SUBSCR'
    'SAPLV51G                                6020TAB'.
    perform bdc_field       using 'V51VE-EXIDV(01)'
                                ITRESULT-EXIDV. "'6000002208'.
    PERFORM BDC_FIELD   USING 'BDC_OKCODE'    '=ENTR'.

  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'V51VE-EXIDV(01)'.
*  perform bdc_field       using 'V51VE-EXIDV(01)'
*                                ITRESULT-EXIDV. "'6000002208'.

  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=HUSUCH'.
  perform bdc_field       using 'BDC_CURSOR'
                                'V51VE-EXIDV(01)'.
  perform bdc_dynpro      using 'SAPLV51G' '6001'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-EXIDV'.
  perform bdc_field       using 'VEKP-EXIDV'
                                ITRESULT-EXIDV. "'6000002208'.
  perform bdc_dynpro      using 'SAPLV51G' '6000'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=DETVERTR'.
  perform bdc_field       using 'BDC_CURSOR'
                                'V51VE-EXIDV(01)'.
  perform bdc_dynpro      using 'SAPLV51G' '6100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-VHILM'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=HUSTAT02'.
  perform bdc_dynpro      using 'SAPLBSVA' '0201'.
  perform bdc_field       using 'BDC_CURSOR'
                                'J_STMAINT-ANWS(02)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=OKAY'.
  perform bdc_field       using 'J_STMAINT-ANWS(01)'
                                ''.
  perform bdc_field       using 'J_STMAINT-ANWS(02)'
                                'X'.
  perform bdc_dynpro      using 'SAPLV51G' '6100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'VEKP-VHILM'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SICH'.

  CALL TRANSACTION 'HU02' USING IT_BDCDATA
                                  MODE  'N'
                                  UPDATE 'S'
                                  MESSAGES INTO IT_BDCMSGCOLL.

  IF IT_BDCMSGCOLL[] IS NOT INITIAL.
    CLEAR WA_BDCMSGCOLL.
    LOOP AT IT_BDCMSGCOLL.
      WA_BDCMSGCOLL = IT_BDCMSGCOLL.
    ENDLOOP.
    APPEND WA_BDCMSGCOLL TO IT_BDCMSGCOLLE.
  ENDIF.
ENDFORM.