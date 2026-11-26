*&---------------------------------------------------------------------*
*&  Include           ZQM_DELIVERY_INSPECTION_F01
*&---------------------------------------------------------------------*
INCLUDE Z_PROG_INFO.
INCLUDE ZABAPALV.


*Display Parameters

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: P_PRUEF  FOR QALS-PRUEFLOS ,
                P_VBELN FOR LIPS-VBELN,
                P_ENSTE FOR QALS-ENSTEHDAT OBLIGATORY. "change by Irma on (02-04-2013)
PARAMETER     : P_WERKS LIKE VEPO-WERKS. " OBLIGATORY.
SELECTION-SCREEN SKIP 2.
PARAMETERS :
             R2 RADIOBUTTON GROUP RAD1 DEFAULT 'X',
             R1 RADIOBUTTON GROUP RAD1.

SELECTION-SCREEN END OF BLOCK BLK1.
SELECTION-SCREEN SKIP 2.

SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.
  DELETE FROM ZTDELINSP_I WHERE PRUEFLOS NE ''.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

START-OF-SELECTION.
*    CLEAR : RET_CODE, ZTEXT.
*    PERFORM CHECK_AUTH_PLANT USING P_WERKS.
*    IF RET_CODE <> 0.
*      CONCATENATE  'Anda tidak bisa melakukan transaksi di Plant' P_WERKS INTO ZTEXT SEPARATED BY SPACE.
*      MESSAGE ZTEXT TYPE 'I'.
*      STOP.
*    ENDIF.

  PERFORM DISPLAY_DATA.

  INCLUDE ZQMI_DEL_INS_LIST_ALV.

*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RETRIEVAL.
DATA : MAGRV LIKE VEKP-MAGRV.

  IF R1 = 'X'.
    CLEAR IT_LIST[]. REFRESH IT_LIST[].
*    SELECT DISTINCT QALS~LS_VBELN AS VBELN "LIPS~VBELN
"JOIN VEPO ON  QALS~PRUEFLOS = VEPO~QPLOS "QALS~CHARG = VEPO~CHARG
                "JOIN LIPS ON LIPS~VBELN = "VEPO~VBELN

    SELECT DISTINCT QALS~LS_VBELN "LIPS~VBELN "diubah
           QALS~PRUEFLOS
           QALS~ENSTEHDAT
           QAVE~VNAME
           QAVE~VCODE
           QALS~WERK
      INTO (IT_LIST-VBELN, IT_LIST-PRUEFLOS, IT_LIST-ENSTEHDAT, IT_LIST-VNAME,
            IT_LIST-VCODE, IT_LIST-WERK)
      FROM QALS JOIN QAVE ON QAVE~PRUEFLOS = QALS~PRUEFLOS
      WHERE QALS~ART = 'Z05' AND
            QAVE~VCODE IN ('P', 'H') AND
            QAVE~KZART EQ 'L' AND
            QALS~PRUEFLOS IN P_PRUEF AND
            QALS~ENSTEHDAT IN P_ENSTE AND
            QALS~LS_VBELN IN P_VBELN. "tambahan tanggal 02-04-2013

      IF SY-SUBRC = 0.
        APPEND IT_LIST.
      ENDIF.
    ENDSELECT.

    IF IT_LIST[] IS NOT INITIAL.
*      IF P_VBELN NE ''.
*        DELETE IT_LIST WHERE VBELN NOT IN P_VBELN.
*      ENDIF.

      IF P_WERKS NE ''.
        DELETE IT_LIST WHERE WERK NE P_WERKS.
      ENDIF.

      SORT IT_LIST BY VBELN PRUEFLOS.
      DELETE ADJACENT DUPLICATES FROM IT_LIST COMPARING ALL FIELDS.

      CLEAR CTR.
      LOOP AT IT_LIST.
        CTR = CTR + 1.
        IT_LIST-NO = CTR.
        IF IT_LIST-VCODE EQ 'P'.
          MOVE 'PASS' TO IT_LIST-VCODE.
        ELSEIF IT_LIST-VCODE EQ 'H'.
          MOVE 'HOLD' TO IT_LIST-VCODE.
        ENDIF.
        MODIFY IT_LIST.
      ENDLOOP.
    ENDIF.

    SORT IT_LIST BY VBELN PRUEFLOS ENSTEHDAT VNAME VCODE.
    DELETE ADJACENT DUPLICATES FROM IT_LIST COMPARING VBELN PRUEFLOS ENSTEHDAT VNAME VCODE.
    IF IT_LIST[] IS INITIAL .
      MESSAGE I000(0K) WITH 'No Data Selected.'.
      STOP.
    ENDIF.
  ELSEIF R2 = 'X'. "Without UD
    PERFORM INIT.
    CLEAR CTR.
*   baca venum dari vepo
    SELECT QALS~LS_VBELN AS VBELN
           VEPO~QPLOS AS PRUEFLOS
           QALS~ENSTEHDAT
           QALS~STAT35
           QALS~WERK
           VEPO~VENUM
      INTO CORRESPONDING FIELDS OF TABLE IT_EXEC
      FROM QALS JOIN JEST ON QALS~OBJNR = JEST~OBJNR
                JOIN VEPO ON QALS~LS_VBELN = VEPO~VBELN
      WHERE QALS~ART = 'Z05' AND  QALS~MATNR NE '' AND QALS~PLNNR NE '' AND
            ( ( JEST~STAT EQ 'I0224' AND JEST~INACT NE '' ) OR ( JEST~STAT NE 'I0224' ) ) AND
            QALS~PRUEFLOS IN P_PRUEF AND
            QALS~LS_VBELN IN P_VBELN AND
            QALS~ENSTEHDAT IN P_ENSTE AND
            QALS~PRUEFLOS EQ VEPO~QPLOS . "AND
*            VEPO~WERKS = P_WERKS. "ADDED ON 3-1-2012
    IF SY-SUBRC = 0.
      SORT IT_EXEC BY VBELN PRUEFLOS EXIDV VENUM.
      DELETE ADJACENT DUPLICATES FROM IT_EXEC COMPARING VBELN PRUEFLOS EXIDV VENUM.
      DELETE IT_EXEC WHERE VBELN EQ ''.

      IF P_WERKS NE ''.
        DELETE IT_EXEC WHERE WERK NE P_WERKS.
      ENDIF.

*     baca venum dan masukin ke unvel di vepo
      LOOP AT IT_EXEC.
        CLEAR: VENUM, MAGRV.
*        SELECT SINGLE VENUM
*         FROM VEPO
*          INTO VENUM
*          WHERE UNVEL EQ IT_EXEC-VENUM.
*        IF VENUM NE ''.
**         baca HU number by venum
*          IT_EXEC-VENUM = VENUM.
*        ENDIF.

* BACA HU
        SELECT SINGLE EXIDV MAGRV
            FROM VEKP
            INTO (IT_EXEC-EXIDV, IT_EXEC-MAGRV)
            WHERE VENUM EQ IT_EXEC-VENUM .

* BACA MAGRV
*        SELECT SINGLE MAGRV
*            FROM VEKP
*            INTO IT_EXEC-MAGRV
*            WHERE VENUM EQ IT_EXEC-VENUM .

        MODIFY IT_EXEC.
      ENDLOOP.

*      SORT IT_EXEC BY VBELN PRUEFLOS EXIDV.
*      DELETE ADJACENT DUPLICATES FROM IT_EXEC COMPARING VBELN PRUEFLOS EXIDV.

*changed with :
      SORT IT_EXEC BY VBELN PRUEFLOS EXIDV VENUM.
      DELETE ADJACENT DUPLICATES FROM IT_EXEC COMPARING VBELN PRUEFLOS EXIDV VENUM.

*cek HU = 1
*      LOOP AT IT_EXEC WHERE EXIDV+10(1) EQ '1' OR EXIDV+10(1) EQ '9'.
      LOOP AT IT_EXEC WHERE MAGRV EQ 'BOX' OR MAGRV EQ 'TRS'.
        CLEAR: EXIDV, VENUM.

*         cek hu   = BOX
        IF IT_EXEC-MAGRV EQ 'BOX'.
          SELECT SINGLE VENUM
            FROM VEPO
            INTO VENUM
            WHERE UNVEL = IT_EXEC-VENUM.
          IF VENUM NE ''. "SY-SUBRC = 0.
*           *baca HU number by venum
            SELECT SINGLE EXIDV
              FROM VEKP
              INTO IT_EXEC-EXIDV
              WHERE VENUM EQ VENUM.
            IT_EXEC-VENUM = VENUM.
            MODIFY IT_EXEC.
          ENDIF.
        ENDIF.

*       CEK HU BERAWALAN 9/ TRUK
        CLEAR VENUM.
        IF IT_EXEC-MAGRV EQ 'TRS'.
          SELECT SINGLE UNVEL
            FROM VEPO
            INTO VENUM
            WHERE VENUM = IT_EXEC-VENUM.
          IF  VENUM NE ''. "SY-SUBRC = 0.
            CLEAR IT_EXEC-VENUM.
            SELECT SINGLE VENUM
            FROM VEPO
            INTO IT_EXEC-VENUM
            WHERE VENUM EQ VENUM.
            IF IT_EXEC-VENUM NE ''. "SY-SUBRC = 0.
*             *baca HU number by venum
              SELECT SINGLE EXIDV
                FROM VEKP
                INTO IT_EXEC-EXIDV
                WHERE VENUM EQ IT_EXEC-VENUM.
              MODIFY IT_EXEC.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT IT_EXEC.
        CLEAR WA_QAVE.
        SELECT SINGLE *
          FROM QAVE
          INTO WA_QAVE
          WHERE PRUEFLOS EQ IT_EXEC-PRUEFLOS.
        IF SY-SUBRC = 0.
          IF WA_QAVE NE ''.
            IF WA_QAVE-VCODE NE ''.
              DELETE IT_EXEC.
            ELSE.
              IT_EXEC-USDEC = WA_QAVE-VCODE.
              IT_EXEC-INSPE = WA_QAVE-VNAME.
              MODIFY IT_EXEC.
            ENDIF.
          ENDIF.
        ENDIF.
        IF IT_EXEC-STAT35 EQ 'X'.
          IF IT_EXEC-USDEC NE ''.
            DELETE IT_EXEC.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SORT IT_EXEC BY VBELN EXIDV.
      DELETE ADJACENT DUPLICATES FROM IT_EXEC COMPARING ALL FIELDS.
      LOOP AT IT_EXEC WHERE EXIDV EQ ''.
        DELETE IT_EXEC.
        CONTINUE.
      ENDLOOP.
*        CEK LAST PROCESSED
      LOOP AT IT_EXEC.
        CLEAR WA_EXEC.
        SELECT SINGLE PRUEFLOS
          FROM ZTDELINSP_I
          INTO WA_EXEC-PRUEFLOS
          WHERE PRUEFLOS EQ IT_EXEC-PRUEFLOS.
        IF WA_EXEC-PRUEFLOS NE ''. "SY-SUBRC = 0.
          DELETE IT_EXEC.
          CONTINUE.
        ENDIF.
      ENDLOOP.
*
      CLEAR CTR.
      LOOP AT IT_EXEC.
        CTR = CTR + 1.
        IT_EXEC-NO = CTR.
        MODIFY IT_EXEC.
        MOVE IT_EXEC-EXIDV TO IT_VEKP-EXIDV.
        MOVE IT_EXEC-VENUM TO IT_VEKP-VENUM.
        APPEND IT_VEKP.
      ENDLOOP.
    ENDIF.

*     GET HU QTY
    SORT IT_VEKP BY EXIDV VENUM.
    DELETE ADJACENT DUPLICATES FROM IT_VEKP COMPARING EXIDV VENUM.

*   GET VENUM/LOWER LEVEL HU / LEVEL BOX
    LOOP AT IT_VEKP.
      CLEAR WA_VEPO.
      SELECT *
        FROM VEPO
        INTO WA_VEPO
        WHERE VENUM = IT_VEKP-VENUM.
        IF SY-SUBRC = 0.
          IT_VEPO-PEXIDV = IT_VEKP-EXIDV.
          IT_VEPO-VENUM = WA_VEPO-VENUM.
          IT_VEPO-UNVEL = WA_VEPO-UNVEL.
          APPEND IT_VEPO.
          DELETE IT_VEKP.
        ENDIF.
        CLEAR WA_VEPO.
      ENDSELECT.
    ENDLOOP.
*   CEK apakah ada roll dalam box
    CLEAR CTR.
    LOOP AT IT_VEPO WHERE UNVEL NE ''.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.
*      READ TABLE IT_VEPO INDEX 1.
    IF CTR > 0.
      LOOP AT IT_VEPO WHERE UNVEL NE ''.
        CLEAR WA_VEPO.
        SELECT *
          FROM VEPO
          INTO WA_VEPO
          WHERE VENUM EQ IT_VEPO-UNVEL.
          IF WA_VEPO-VENUM NE ''.
            IT_VEPOR-PEXIDV = IT_VEPO-PEXIDV.
            IT_VEPOR-VENUM = WA_VEPO-VENUM.
            IT_VEPOR-UNVEL = WA_VEPO-UNVEL.
            APPEND IT_VEPOR.
            DELETE IT_VEPO.
          ENDIF.
          CLEAR WA_VEPO.
        ENDSELECT.
      ENDLOOP.

      READ TABLE IT_VEPOR INDEX 1.
      IF SY-SUBRC = 0.
        CLEAR CTR.
        LOOP AT IT_VEPOR WHERE UNVEL NE ''.
          CTR = CTR + 1.
          EXIT.
        ENDLOOP.
        IF CTR > 1.
          LOOP AT IT_VEPOR WHERE UNVEL NE ''.
            CLEAR WA_VEPO.
            SELECT *
              FROM VEPO
              INTO WA_VEPO
              WHERE VENUM EQ IT_VEPOR-UNVEL.
              IF WA_VEPO-VENUM NE ''.
                IT_VEPOR1-PEXIDV = IT_VEPOR-PEXIDV.
                IT_VEPOR1-VENUM = WA_VEPO-VENUM.
                IT_VEPOR1-UNVEL = WA_VEPO-UNVEL.
                APPEND IT_VEPOR1.
                DELETE IT_VEPOR.
              ENDIF.
              CLEAR WA_VEPO.
            ENDSELECT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR CTR.
    DESCRIBE TABLE IT_VEPO LINES CTR.
    IF CTR > 0.
      APPEND LINES OF IT_VEPO FROM 1 TO CTR TO IT_VEPOR1.
    ENDIF.

    CLEAR CTR.
    DESCRIBE TABLE IT_VEPOR LINES CTR.
    IF CTR > 0.
      APPEND LINES OF IT_VEPOR FROM 1 TO CTR TO IT_VEPOR1.
    ENDIF.

    IT_HUQTY[] = IT_VEPOR1[].
    DELETE ADJACENT DUPLICATES FROM IT_HUQTY COMPARING PEXIDV.
    LOOP AT IT_HUQTY.
      CLEAR CTR.
      LOOP AT IT_VEPOR1 WHERE PEXIDV = IT_HUQTY-PEXIDV.
        CTR = CTR + 1.
        EXIT.
      ENDLOOP.
      IF CTR > 0.
        IT_HUQTY-QTY = CTR.
        MODIFY IT_HUQTY.
      ENDIF.
    ENDLOOP.

    LOOP AT IT_EXEC.
      CLEAR CTR.
      LOOP AT IT_HUQTY WHERE PEXIDV EQ IT_EXEC-EXIDV.
        MOVE IT_HUQTY-QTY TO CTR.
        EXIT.
      ENDLOOP.
      IF CTR > 0.
        IT_EXEC-POSNR = CTR.
      ELSE. "jika unvel tidak ada
        IT_EXEC-POSNR = 1.
      ENDIF.

*     CONVERT TO EXTERNAL VALUE OF DOC NUMBER
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = IT_EXEC-VBELN
        IMPORTING
          OUTPUT = IT_EXEC-VBELN.

*       CONVERT TO EXTERNAL VALUE OF HU NUMBER
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = IT_EXEC-EXIDV
        IMPORTING
          OUTPUT = IT_EXEC-EXIDV.
*        IT_EXEC-INSPE = .
      IT_EXEC-SDATA = 'MANUAL'.
      MODIFY IT_EXEC.
    ENDLOOP.

    SORT IT_EXEC BY PRUEFLOS.
    IF IT_EXEC[] IS INITIAL .
      MESSAGE I000(0K) WITH 'No Data Selected.'.
      STOP.
    ENDIF.
  ENDIF.
ENDFORM.                    "DATA_RETRIEVAL

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
  LS_LINE-INFO = 'DELIVERY INSPECTION LIST'.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    " COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
*  PERFORM DATA_RETRIEVAL.
*  PERFORM F_FIELD_CATALOG.
  IF R1 = 'X'.
    PERFORM DATA_RETRIEVAL.
    PERFORM F_FIELD_CATALOG_LIST.
    PERFORM F_LAYOUT.
    PERFORM F_LIST_DETAIL.
  ELSEIF R2 = 'X'.
    IF R NE 'X'.
      PERFORM DATA_RETRIEVAL.
      CALL SCREEN '0100'.
    ELSE.
      SET PF-STATUS 'ESTATUS'.
      CALL SCREEN '0100'.
    ENDIF.
  ELSE.
    CALL SCREEN '1000'.
  ENDIF.

  IF SY-UCOMM EQ 'YES'.
    LEAVE TO TRANSACTION 'ZQM014'.
  ENDIF.
ENDFORM.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ESTATUS'.
  SET TITLEBAR 'TL0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCHU_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCDEL_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_EXEC LINES TCDEL-LINES.
  LOOP AT SCREEN.
    SCREEN-INPUT = 0.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                 " TCHU_CHANGE_TC_ATTR  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA   : VANSWER(1).
  CLEAR OKCODE.
  OKCODE = SY-UCOMM.
  CASE OKCODE.
    WHEN 'EEXEC'.
*     Confirm to Creator
      CLEAR VANSWER.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Confirmation'
          TEXT_QUESTION         = 'Are you sure to execute this ?'
          TEXT_BUTTON_1         = 'Yes'
          TEXT_BUTTON_2         = 'No'
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = ''
        IMPORTING
          ANSWER                = VANSWER.
      CASE VANSWER.
        WHEN '1'.
          R1 = 'X'.
          R = 'X'.
          CLEAR R2.
          PERFORM GET_NIK.
*         INSERT TABEL ZTDELINSP
          PERFORM INSERT_ZTDELINSP.
*         DO BAPI BAPI_INSPOPER_RECORDRESULTS
          PERFORM INSERT_TO_TRANSACTION.
          PERFORM DISPLAY_DATA.
      ENDCASE.
      CLEAR OKCODE.
    WHEN 'EREF'.
*      PERFORM INACTIVE_SCREEN .
      PERFORM INIT.
      R2 = 'X'.
      CLEAR: R1, R.
      PERFORM DISPLAY_DATA.
      CLEAR OKCODE.
    WHEN 'ELIST'.
      PERFORM INIT.
      R1 = 'X'.
      CLEAR R2.
      PERFORM DISPLAY_DATA.
      CLEAR OKCODE.
    WHEN 'ETPDA'.
      READ TABLE IT_EXEC INDEX 1.
      IF SY-SUBRC = 0.
        PERFORM DOWNLOAD_TO_PDA.
      ELSE.
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            TITEL = 'Empty Data'
            TXT1  = 'No data will be downloaded.'
            TXT2  = ''.
        R2 = 'X'.
        R1 = ''.
      ENDIF.
      CLEAR OKCODE.
    WHEN 'ETEXC'.
      READ TABLE IT_EXEC INDEX 1.
      IF SY-SUBRC = 0.
        PERFORM UPLOAD_FROM_PDA.
      ELSE.
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            TITEL = 'Empty Data'
            TXT1  = 'No data will be uploaded.'
            TXT2  = ''.
        R2 = 'X'.
        R1 = ''.
      ENDIF.
      CLEAR OKCODE.
    WHEN 'EBACK'.
      R1 = 'X'.
      R = ''.
      R2 = ''.
*      LEAVE TO SCREEN '0'.
      LEAVE TO TRANSACTION 'ZQM014'.
      CLEAR OKCODE.
    WHEN '&F03' OR '&F15' OR '&F12' OR 'YES'.
      LEAVE TO TRANSACTION 'ZQM014'.
      CLEAR OKCODE.
*    WHEN OTHERS.
*      PERFORM INIT.
*      R2 = 'X'.
*      CLEAR: R1, R.
*      PERFORM DISPLAY_DATA.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_TO_PDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_TO_PDA.
  DATA:BEGIN OF IT_DOWNLOAD OCCURS 0,
        DATA TYPE STRING,
       END OF IT_DOWNLOAD,
       F_NAME TYPE STRING.

  CLASS CL_ABAP_CHAR_UTILITIES DEFINITION LOAD.
  CONSTANTS:
  CON_TAB  TYPE C VALUE CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

  CLEAR : F_NAME, P_FILE, IT_DOWNLOAD[].
  REFRESH : IT_DOWNLOAD[].

  READ TABLE IT_EXEC INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR IT_DOWNLOAD.
    LOOP AT IT_EXEC.
      CLEAR CTR.
      MOVE IT_EXEC-POSNR TO CTR.
      IT_TPDA-VBELN = IT_EXEC-VBELN.
      IT_TPDA-PRUEFLOS = IT_EXEC-PRUEFLOS.
      IT_TPDA-EXIDV = IT_EXEC-EXIDV.
      IT_TPDA-POSNR = CTR.
      APPEND IT_TPDA.
      CONCATENATE IT_TPDA-VBELN
                  IT_TPDA-PRUEFLOS
                  IT_TPDA-EXIDV
                  IT_TPDA-POSNR
      INTO IT_DOWNLOAD-DATA
      SEPARATED BY CON_TAB.
      APPEND IT_DOWNLOAD.
      CLEAR  IT_DOWNLOAD.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = ' '
      DEF_PATH         = 'C:\'
      MASK             = ',*.txt.'
      MODE             = 'S'
      TITLE            = TEXT-011
    IMPORTING
      FILENAME         = P_FILE
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.


  MOVE P_FILE TO F_NAME.
  IF F_NAME CS '.TXT'.
  ELSE.
    CONCATENATE F_NAME '.TXT' INTO F_NAME.
  ENDIF.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE = '#'
      FILENAME     = F_NAME"'C:\tmp\test1.txt'
      FILETYPE     = 'ASC'
    TABLES
      DATA_TAB     = IT_DOWNLOAD.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "DOWNLOAD_TO_PDA

*&---------------------------------------------------------------------*
*&      Form UPLOAD_FROM_PDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_FROM_PDA.
  CALL FUNCTION 'UPLOAD'
    EXPORTING
      FILETYPE         = 'DAT'
      FILETYPE_NO_SHOW = 'X'
    TABLES
      DATA_TAB         = IT_FPDA.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE IT_FPDA INDEX 1.
  IF SY-SUBRC = 0.
*    UPDATE RESULT (OK, NOT OK OR , UNCHECK)
    LOOP AT IT_FPDA.
      CLEAR WA_EXEC.
      WA_EXEC-VBELN = IT_FPDA-VBELN.
      WA_EXEC-PRUEFLOS = IT_FPDA-PRUEFLOS.
      WA_EXEC-INSPE = IT_FPDA-INSPE.
      WA_EXEC-EXIDV = IT_FPDA-EXIDV.
      WA_EXEC-POSNR = IT_FPDA-POSNR.

      IF IT_FPDA-RESOK NE ''.
        WA_EXEC-RESOK = 'X'.
      ELSE.
        WA_EXEC-RESNOK = 'X'.
      ENDIF.

      WA_EXEC-STATUS = 'X'.

      APPEND WA_EXEC TO IT_EFPDA.
      DELETE IT_FPDA.
    ENDLOOP.
  ENDIF.

  READ TABLE IT_EFPDA INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR WA_EXEC.
    CLEAR IT_EXEC2[]. REFRESH IT_EXEC2[].
    LOOP AT IT_EFPDA.
      CLEAR WA_EXEC.
      MOVE-CORRESPONDING IT_EFPDA TO WA_EXEC.
      LOOP AT IT_EXEC WHERE VBELN EQ WA_EXEC-VBELN AND
                            PRUEFLOS EQ WA_EXEC-PRUEFLOS AND
                            EXIDV EQ WA_EXEC-EXIDV AND
                            POSNR EQ WA_EXEC-POSNR.
*       yang diisi adalah yang dari PDA
        IT_EXEC-RESOK = ''.
        IT_EXEC-RESNOK = ''.

        IT_EXEC-SDATA = 'PDA'.
        IT_EXEC-INSPE =  WA_EXEC-INSPE.
        IF WA_EXEC-RESOK EQ 'X'.
          IT_EXEC-RESOK = WA_EXEC-RESOK.
        ELSE.
          IT_EXEC-RESNOK = 'X'.
        ENDIF.
        MODIFY IT_EXEC.
*            ENDIF.
      ENDLOOP.
      DELETE IT_EFPDA.
      IT_EXEC2[] = IT_EXEC[].

**    DELETE ADJACENT DUPLICATES FROM IT_EXEC2 COMPARING VBELN.
      LOOP AT IT_EXEC2.
        CLEAR CTR.
        LOOP AT IT_EXEC WHERE VBELN EQ IT_EXEC2-VBELN AND
                              RESOK EQ ''.
          CTR =  CTR + 1.
          EXIT.
        ENDLOOP.

        IF IT_EXEC2-SDATA EQ 'PDA'.
          IF CTR > 0.
            IT_EXEC2-USDEC = 'HOLD'.
          ELSE.
            IT_EXEC2-USDEC = 'PASS'.
          ENDIF.
          MODIFY IT_EXEC2.
        ENDIF.
      ENDLOOP.

      LOOP AT IT_EXEC2.
        LOOP AT IT_EXEC WHERE VBELN EQ IT_EXEC2-VBELN.
          IT_EXEC-USDEC = IT_EXEC2-USDEC.
          MODIFY IT_EXEC.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    R = 'X'.
    PERFORM DISPLAY_DATA.
  ENDIF.
ENDFORM.                    "UPLOAD_FROM_PDA

*&---------------------------------------------------------------------*
*&      Form INSERT_ZTDELINSP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ZTDELINSP.
  DATA : IT_ZTDELINSP TYPE ZTDELINSP OCCURS 0 WITH HEADER LINE,
         WA_ZTDELINSP LIKE IT_ZTDELINSP,
         VANSWER(1).

  CLEAR VANSWER.
  REFRESH CONTROL 'TCDEL' FROM SCREEN '0100'.
  READ TABLE IT_EXEC INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR CTR.
    LOOP AT IT_EXEC WHERE RESOK NE '' AND RESNOK NE ''.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.
*    jika ada 2 status per line , maka error
    IF CTR > 0.
      MESSAGE 'There are some item have 2 result status.' TYPE 'E'.
    ELSE.
*     jika ada yang kosong 1 line, maka popup
      CLEAR CTR.
      LOOP AT IT_EXEC WHERE RESOK EQ '' AND RESNOK EQ ''.
        CTR = CTR + 1.
        EXIT.
      ENDLOOP.
      PERFORM FILL_USDEC.
      IF CTR > 0.
*         Confirm to Creator
        CLEAR VANSWER.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = 'Confirmation'
            TEXT_QUESTION         = 'Are you sure doing this ?'
            TEXT_BUTTON_1         = 'Yes'
            TEXT_BUTTON_2         = 'No'
            DEFAULT_BUTTON        = '2'
            DISPLAY_CANCEL_BUTTON = ''
          IMPORTING
            ANSWER                = VANSWER.

        CASE VANSWER.
          WHEN '1'.
            LOOP AT IT_EXEC.
              CLEAR WA_ZTDELINSP.
              WA_ZTDELINSP-VBELN = IT_EXEC-VBELN.
              WA_ZTDELINSP-PRUEFLOS = IT_EXEC-PRUEFLOS.
              WA_ZTDELINSP-EXIDV = IT_EXEC-EXIDV.
              IF IT_EXEC-RESOK NE ''.
                WA_ZTDELINSP-STATUS = 'OK'.
              ELSEIF IT_EXEC-RESNOK NE ''.
                WA_ZTDELINSP-STATUS = 'NOT OK'.
              ELSE.
                WA_ZTDELINSP-STATUS = ''.
              ENDIF.
              WA_ZTDELINSP-SDATA = IT_EXEC-SDATA.
              MODIFY ZTDELINSP FROM WA_ZTDELINSP.
*                    INSERT INTO ZTDELINSP VALUES WA_ZTDELINSP.
            ENDLOOP.
          WHEN OTHERS.
            CLEAR R1.
            R = 'X'. R2 = 'X'.
            PERFORM DISPLAY_DATA.
        ENDCASE.
      ENDIF.
    ENDIF.
  ELSE.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Empty Data'
        TXT1  = 'No data will be executed.'
        TXT2  = ''
*       TXT3  = ' '
*       TXT4  = ' '
      .
    R2 = 'X'.
    R1 = ''.
  ENDIF.
ENDFORM.                    "INSERT_ZTDELINSP

*&---------------------------------------------------------------------*
*&      Form INSERT_TO_TRANSACTION
*&---------------------------------------------------------------------*
*       Insert to transaction QA01 AND QA11
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_TO_TRANSACTION.
*DATA FOR TCODE QE01
  DATA :  INSPLOT  LIKE  BAPI2045D4-INSPLOT,
          INSPOPER  LIKE  BAPI2045D4-INSPOPER,
          INSPCHAR  LIKE  BAPI2045D4-INSPCHAR,
          INSPSAMPLE  LIKE  BAPI2045D4-INSPSAMPLE,
          CHAR_RESULT LIKE  BAPI2045D2,
          SAMPLE_RESULT LIKE  BAPI2045D3,
          RETURN  LIKE  BAPIRET2 OCCURS 0 WITH HEADER LINE,
          LINE TYPE I,

          CHAR_RESULTS  LIKE  BAPI2045D2 OCCURS 0 WITH HEADER LINE,
          SAMPLE_RESULTS  LIKE  BAPI2045D3 OCCURS 0 WITH HEADER LINE,
          SINGLE_RESULTS  LIKE  BAPI2045D4 OCCURS 0 WITH HEADER LINE,
          RETURNTABLE LIKE  BAPIRET2 OCCURS 0 WITH HEADER LINE.

*DATA FOR TCODE QA11
  DATA :  NUMBER  LIKE  BAPI2045UD-INSPLOT,
          WERK LIKE BAPI2045UD-UD_PLANT,
          UD_DATA LIKE  BAPI2045UD OCCURS 0 WITH HEADER LINE,
          RETURN1 LIKE BAPIRETURN1 OCCURS 0 WITH HEADER LINE.

  DATA : INSPOPER_LIST LIKE BAPI2045L2 OCCURS 0 WITH HEADER LINE,
         RETURN2 LIKE BAPIRETURN1 OCCURS 0 WITH HEADER LINE,
         CHOICE LIKE SY-TABIX VALUE 1.

  CLEAR CTR.
  CLEAR: IT_EXEC2NOK, IT_ERRINSPECTOR.
  REFRESH: IT_EXEC2NOK, IT_ERRINSPECTOR.
*  cek jika masih ada UD yang vcode na kosong,
  DELETE IT_EXEC2 WHERE RESOK EQ '' AND RESNOK EQ ''.
*  cek apakah inspector masing-valid.
  PERFORM CHECK_INSPECTOR.
*gabung dengan error NIK (08-11-2012)
      IF IT_ERRINSPECTOR[] IS NOT INITIAL.
        CLEAR: WA_ERRINSPECTOR, CTR.
        LOOP AT IT_ERRINSPECTOR INTO WA_ERRINSPECTOR.
          CTR = CTR + 1.
          IT_POPMSG-NO = CTR.
          IT_POPMSG-FLAG = 'E'.
          IT_POPMSG-DATA = WA_ERRINSPECTOR-PRUEFLOS.
          IT_POPMSG-MESSAGE = WA_ERRINSPECTOR-ERRROR.
          APPEND IT_POPMSG.
        ENDLOOP.
      ENDIF.

*UD Yng hold akan menjadi NOT OK
  READ TABLE IT_EXEC2 INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR : INSPLOT, INSPOPER, INSPSAMPLE, RETURN.
    CLEAR : CHAR_RESULTS[], SAMPLE_RESULTS[], SINGLE_RESULTS[], IT_INERR[], IT_EXEC3[],
            RETURNTABLE[], IT_ZTDELINSP_I[], IT_INSLOT[].
    REFRESH: CHAR_RESULTS[], SAMPLE_RESULTS[], SINGLE_RESULTS[], IT_INERR[], IT_EXEC3[],
             RETURNTABLE[], IT_ZTDELINSP_I[], IT_INSLOT[].
*   table penampung error bapi
    CLEAR : IT_INERR[], IT_HOLD[]. REFRESH : IT_INERR[], IT_HOLD[]. "

    SORT IT_EXEC2 BY PRUEFLOS.
    DELETE ADJACENT DUPLICATES FROM IT_EXEC2 COMPARING PRUEFLOS.

*    TAMBAHAN TANGGAL 13-09-2012
*    pengecekan untuk pertial lot
    LOOP AT IT_EXEC2.
      CLEAR CTR.
      CLEAR WA_EXEC.
      SELECT * FROM
        QALT INTO WA_QALT
        WHERE PRUEFLOS EQ IT_EXEC2-PRUEFLOS.
        IF SY-SUBRC = 0.
          APPEND WA_QALT TO IT_QALT.
          CTR = CTR + 1.
        ENDIF.
      ENDSELECT.

      IF CTR > 0.
        MOVE IT_EXEC2 TO WA_EXEC.
        APPEND WA_EXEC TO IT_EXEC3.
        DELETE IT_EXEC2.
        CONTINUE.
      ENDIF.
    ENDLOOP.
*   PROCESS1 : RESULT RECORDING
*   proses untuk partial inspection lot
    CLEAR CTR.
    DESCRIBE TABLE IT_EXEC3 LINES CTR.
    IF CTR > 0.
        PERFORM PARTIAL_PROCESS.
    ENDIF.

*   yang tidak punya partial lot
    LOOP AT IT_EXEC2 .
      CLEAR : INSPLOT, INSPOPER, INSPSAMPLE, RETURN.
      CLEAR : CHAR_RESULTS[], SAMPLE_RESULTS[], SINGLE_RESULTS[], RETURNTABLE[]." IT_INERR[].
      REFRESH: CHAR_RESULTS[], SAMPLE_RESULTS[], SINGLE_RESULTS[], RETURNTABLE[]." IT_INERR[].

      MOVE IT_EXEC2-PRUEFLOS TO INSPLOT.
*        CALLING BAPI HERE
      CHAR_RESULTS-INSPLOT = INSPLOT. "'100000000775'.
      CHAR_RESULTS-INSPOPER = '0010'.
      CHAR_RESULTS-INSPCHAR = '0010'.
      CHAR_RESULTS-CLOSED = 'X'.
      CHAR_RESULTS-INSPECTOR = IT_EXEC2-INSPE. "'PST_ABAP'.
      IF IT_EXEC2-USDEC EQ 'PASS'.
        CHAR_RESULTS-EVALUATION = 'A'.
        CHAR_RESULTS-CODE1 = 'OK'.
      ELSEIF IT_EXEC2-USDEC EQ 'HOLD'.
        CHAR_RESULTS-EVALUATION = 'R'.
        CHAR_RESULTS-CODE1 = 'NO'.
      ENDIF.
      CHAR_RESULTS-CODE_GRP1 = RESREC. "'1-QL-HU'. "QLTV-HU
      APPEND CHAR_RESULTS.

*       BAPI FOR TCODE QE01
      CALL FUNCTION 'BAPI_INSPOPER_RECORDRESULTS'
        EXPORTING
          INSPLOT                    = INSPLOT "'100000000775'
          INSPOPER                   = '0010'
*           INSPPOINTDATA              = ' '
*           HANDHELD_APPLICATION       = ' '
*         IMPORTING
*           RETURN                     =
       TABLES
         CHAR_RESULTS               = CHAR_RESULTS
         SAMPLE_RESULTS             = SAMPLE_RESULTS
         SINGLE_RESULTS             = SINGLE_RESULTS
         RETURNTABLE                = RETURNTABLE
                .
      CLEAR CTR.
      READ TABLE RETURNTABLE INDEX 1.
      IF SY-SUBRC = 0.
        LOOP AT RETURNTABLE WHERE TYPE EQ 'E'.
          CTR = CTR + 1.
          EXIT.
        ENDLOOP.
      ENDIF.
      IF CTR = 0.
        CLEAR RETURN. REFRESH RETURN.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT          = 'X'
         IMPORTING
           RETURN        = RETURN
                  .
****    PROCESS II : CANCEL UD UNTUK INSPECTION LOT YANG TIDAK PUNYA PARSIAL
        CLEAR : INSPLOT, INSPOPER, INSPSAMPLE.
        CLEAR : RETURN.
        MOVE IT_EXEC2-PRUEFLOS TO INSPLOT.
*               BAPI FOR TCODE QA11
        CLEAR: NUMBER, WERK.
        CLEAR: UD_DATA, RETURN1.
        REFRESH: UD_DATA, RETURN1.

        MOVE INSPLOT TO NUMBER.
        MOVE IT_EXEC3-WERK TO WERK.

        MOVE NUMBER TO UD_DATA-INSPLOT.
        UD_DATA-UD_SELECTED_SET = UD_DEL. "'0-UD-DEL'. " 'UD-DEL'.
        UD_DATA-UD_PLANT = WERK.
        UD_DATA-UD_CODE_GROUP = UD_DEL. "'0-UD-DEL'."'UD-DEL'.
        IF IT_EXEC2-USDEC EQ 'PASS'.
          UD_DATA-UD_CODE = 'P'.
        ELSEIF IT_EXEC2-USDEC EQ 'HOLD'.
          UD_DATA-UD_CODE = 'H'.
        ENDIF.
        MOVE IT_EXEC2-INSPE TO UD_DATA-UD_RECORDED_BY_USER.
        UD_DATA-UD_STOCK_POSTING = 'X'.
        APPEND UD_DATA.

        CALL FUNCTION 'BAPI_INSPLOT_SETUSAGEDECISION'
          EXPORTING
            NUMBER  = NUMBER
            UD_DATA = UD_DATA
          IMPORTING
            RETURN  = RETURN1.
        IF RETURN1-TYPE NE ''.
          APPEND RETURN1.
        ENDIF.
        READ TABLE RETURN1 INDEX 1.
        CLEAR CTR.
        LOOP AT RETURN1 WHERE TYPE EQ 'E'.
          CTR = CTR + 1.
          EXIT.
        ENDLOOP.
        IF CTR > 0.
          CLEAR : WA_INSLOT, WA_INERR .
          MOVE IT_EXEC2-PRUEFLOS TO WA_INSLOT-INSLOT .
          MOVE-CORRESPONDING IT_EXEC2 TO WA_INERR.
          LOOP AT RETURN1 WHERE TYPE EQ 'E'.
            CONCATENATE WA_INERR-ERROR RETURN1-MESSAGE INTO WA_INERR-ERROR SEPARATED BY SPACE.
          ENDLOOP.
          APPEND WA_INERR TO IT_INERR.
        ELSE.
          CLEAR RETURN. REFRESH RETURN.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT          = 'X'
           IMPORTING
             RETURN        = RETURN
                    .

          CLEAR :WA_ZTDELINSP_I.
          MOVE IT_EXEC2-PRUEFLOS TO WA_ZTDELINSP_I-PRUEFLOS .
          INSERT INTO ZTDELINSP_I VALUES WA_ZTDELINSP_I.

*         CEK STATUS UD YANG BERHASIL, JIKA HOLD (TAMBAHAN 13-09-2012)
          IF IT_EXEC2-USDEC EQ 'HOLD'.
            CLEAR WA_EXEC.
            MOVE IT_EXEC2 TO WA_EXEC.
            APPEND WA_EXEC TO IT_HOLD.
          ENDIF.
          DELETE IT_EXEC2.
        ENDIF.
      ELSE.
        CLEAR : WA_INSLOT, WA_INERR .
        MOVE IT_EXEC2-PRUEFLOS TO WA_INSLOT-INSLOT .
*           APPEND WA_INSLOT TO IT_INSLOT.
        MOVE-CORRESPONDING IT_EXEC2 TO WA_INERR.
        LOOP AT RETURNTABLE WHERE TYPE EQ 'E'.
          CONCATENATE WA_INERR-ERROR RETURNTABLE-MESSAGE INTO WA_INERR-ERROR SEPARATED BY SPACE.
        ENDLOOP.
        APPEND WA_INERR TO IT_INERR.
      ENDIF.
    ENDLOOP.

* PROCESS IV : RUN BDC VL02N
* PROSES SEMUA INSLOT YANG UD STATUSNYA : HOLD
*cek apakah ada
    CLEAR CTR .
    DESCRIBE TABLE IT_HOLD LINES CTR.
    IF CTR > 0.
      PERFORM BDC_VL02.
    ENDIF.

*tampilkan semua data yang tidak dieksekusi
*karena sudah masuk ke ZTABEL
    CLEAR CTR.
    DESCRIBE TABLE IT_INERR LINES CTR.
    IF CTR > 0.
*     CLEAR IT_POPMSG[]. REFRESH IT_POPMSG[].
      CLEAR: CTR, LINE.
      LINE = LINES( IT_POPMSG ).
      CTR = LINE.
      LOOP AT IT_INERR.
        CLEAR WA_ERROR.
        CONCATENATE IT_INERR-PRUEFLOS IT_INERR-ERROR INTO WA_ERROR-ERROR.
        APPEND WA_ERROR TO IT_ERROR.

        CTR = CTR + 1.
        IT_POPMSG-NO = CTR.
        IT_POPMSG-DATA = IT_INERR-PRUEFLOS.
        IT_POPMSG-MESSAGE = IT_INERR-ERROR.
        APPEND IT_POPMSG.
      ENDLOOP.

      CLEAR CTR.
      DESCRIBE TABLE IT_POPMSG LINES CTR.
      IF CTR > 0.
        SORT IT_POPMSG BY DATA MESSAGE DESCENDING.
        DELETE ADJACENT DUPLICATES FROM IT_POPMSG COMPARING DATA.
        CLEAR CTR .
        LOOP AT  IT_POPMSG.
          CTR = CTR + 1.
          IT_POPMSG-NO = CTR.
          MODIFY IT_POPMSG.
        ENDLOOP.
        PERFORM CALL_POPUP.
      ENDIF.

      CLEAR: R1, R.
      R2 = 'X'.
      PERFORM DISPLAY_DATA.
    ENDIF.
  ELSE.
      CLEAR CTR.
      DESCRIBE TABLE IT_POPMSG LINES CTR.
      IF CTR > 0.
        PERFORM CALL_POPUP.
      ENDIF.
    R2 = 'X'.
    CLEAR: R1, R.
*    SET PF-STATUS 'EXEC_STATUS'.
*    CALL SCREEN '0100'.
    PERFORM DISPLAY_DATA.
  ENDIF.
ENDFORM.                    "INSERT_TO_TRANSACTION

*&---------------------------------------------------------------------*
*&      Form INIT
*&---------------------------------------------------------------------*
*       CLEARING ALL IT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT.
  CLEAR : IT_EXEC[], IT_VEKP[], IT_VEPO[], IT_HUQTY[], IT_VEPOR[], IT_VEPOR1[].
  REFRESH: IT_EXEC[], IT_VEKP[], IT_VEPO[], IT_HUQTY[], IT_VEPOR[], IT_VEPOR1[].
ENDFORM.                    "INIT
*&---------------------------------------------------------------------*
*&      Module  TCDEL_CHK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCDEL_CHK INPUT.
  DATA: G_TCDEL_WA2 LIKE LINE OF IT_EXEC.
  "UPDATE DATA IN TABLE CONTROL

  IF TCDEL-LINE_SEL_MODE = 1.
*    ( IT_EXEC-RESOK = 'X' OR IT_EXEC-RESNOK = 'X' OR IT_EXEC-RESOK = '' OR IT_EXEC-RESNOK = '').
    LOOP AT IT_EXEC INTO G_TCDEL_WA2.
*      G_TDEL_WA2-RESOK = ''.
      MODIFY IT_EXEC
        FROM G_TCDEL_WA2
        TRANSPORTING RESOK RESNOK INSPE SDATA.
    ENDLOOP.
  ENDIF.
  MODIFY IT_EXEC
    FROM WA_EXEC
    INDEX TCDEL-CURRENT_LINE.
ENDMODULE.                 " TCDEL_CHK  INPUT

*&---------------------------------------------------------------------*
*&      FORM  FILL_USDEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_USDEC.
  IT_EXEC2[] = IT_EXEC[].
  LOOP AT IT_EXEC.
    CLEAR CTR.
    LOOP AT IT_EXEC2 WHERE VBELN EQ IT_EXEC-VBELN AND
                          RESNOK NE ''.
      CTR =  CTR + 1.
      EXIT.
    ENDLOOP.

    IF CTR > 0.
      LOOP AT IT_EXEC2 WHERE VBELN EQ IT_EXEC-VBELN .
        IT_EXEC2-USDEC = 'HOLD'.
        MODIFY IT_EXEC2.
      ENDLOOP.
    ELSE.
      LOOP AT IT_EXEC2 WHERE VBELN EQ IT_EXEC-VBELN .
        IT_EXEC2-USDEC = 'PASS'.
        MODIFY IT_EXEC2.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IT_EXEC[] = IT_EXEC2[].
ENDFORM.                    "FILL_USDEC

*&---------------------------------------------------------------------*
*&      Form  PARTIAL_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PARTIAL_PROCESS .
  DATA :  INSPOPER  LIKE  BAPI2045D4-INSPOPER,
          INSPCHAR  LIKE  BAPI2045D4-INSPCHAR,
          INSPSAMPLE  LIKE  BAPI2045D4-INSPSAMPLE,
          CHAR_RESULT LIKE  BAPI2045D2,
          SAMPLE_RESULT LIKE  BAPI2045D3,
          RETURN  LIKE  BAPIRET2 OCCURS 0 WITH HEADER LINE.

*DATA FOR TCODE QA11
  DATA :  NUMBER  LIKE  BAPI2045UD-INSPLOT,
          UD_DATA LIKE  BAPI2045UD OCCURS 0 WITH HEADER LINE,
          RETURN1 LIKE BAPIRETURN1 OCCURS 0 WITH HEADER LINE.

  DATA : INSPLOT  LIKE  BAPI2045D4-INSPLOT,
         IT_QAPP TYPE QAPP OCCURS 0 WITH HEADER LINE,
         WA_QAPP LIKE LINE OF IT_QAPP,
         IT_INSPPOINTDATA LIKE  BAPI2045L4 OCCURS 0 WITH HEADER LINE,
         SAMPLE_RESULTS  LIKE  BAPI2045D3 OCCURS 0 WITH HEADER LINE,
         SINGLE_RESULTS  LIKE  BAPI2045D4 OCCURS 0 WITH HEADER LINE,
         RETURNTABLE LIKE  BAPIRET2 OCCURS 0 WITH HEADER LINE,
         WA_INSPPOINTDATA LIKE LINE OF IT_INSPPOINTDATA.

  CLEAR WA_EXEC.
  LOOP AT IT_EXEC3.
    CLEAR : IT_INSPPOINTDATA, SAMPLE_RESULTS, SINGLE_RESULTS, RETURNTABLE, RETURN.
    REFRESH : IT_INSPPOINTDATA, SAMPLE_RESULTS, SINGLE_RESULTS, RETURNTABLE, RETURN.
    CLEAR: WA_QALT, WA_EXEC, INSPLOT, SAMPLE_RESULTS.
    REFRESH : SAMPLE_RESULTS.

    MOVE IT_EXEC3 TO WA_EXEC.
    MOVE WA_EXEC-PRUEFLOS TO INSPLOT.
*   PREPARE ALL DATA PARTIAL
    LOOP AT IT_QALT INTO WA_QALT
      WHERE PRUEFLOS EQ WA_EXEC-PRUEFLOS.
*     GET POINT
      CLEAR: WA_INSPPOINTDATA, WA_QAPP.
      SELECT SINGLE *
        FROM QAPP
        INTO WA_QAPP
        WHERE PRUEFLOS EQ WA_QALT-PRUEFLOS AND
              TEILLOS EQ WA_QALT-TEILLOS.
*     PARTIAL DATA FOR BAPI
      WA_INSPPOINTDATA-INSPLOT =  INSPLOT.
      WA_INSPPOINTDATA-INSPOPER = '0010'. "IT_QALT-INSPOPER'.
      WA_INSPPOINTDATA-INSPPOINT = WA_QAPP-PPSORTKEY.
      WA_INSPPOINTDATA-PART_LOT = WA_QALT-TEILLOS.
      WA_INSPPOINTDATA-PHYS_SMPL = WA_QALT-TEILLOS.
      WA_INSPPOINTDATA-CODE_GRP = RESREC. "'1-QL-HU'.
      WA_INSPPOINTDATA-CODE = 'OK'.
      WA_INSPPOINTDATA-INSPECTOR = WA_EXEC-INSPE.
      APPEND WA_INSPPOINTDATA TO IT_INSPPOINTDATA.
*     SAMPLE DATA FOR BAPI
      SAMPLE_RESULTS-INSPLOT = INSPLOT.
      SAMPLE_RESULTS-INSPOPER =  '0010'.
      SAMPLE_RESULTS-INSPCHAR = '0010'.
      SAMPLE_RESULTS-INSPSAMPLE = WA_QAPP-PROBENR.
      SAMPLE_RESULTS-CLOSED = 'X'.
      SAMPLE_RESULTS-EVALUATION = 'A'.
      SAMPLE_RESULTS-MAXIMUM = 100.
      SAMPLE_RESULTS-MINIMUM = 30.
      SAMPLE_RESULTS-INSPECTOR = WA_EXEC-INSPE.
      SAMPLE_RESULTS-CODE1 = 'OK'.
      SAMPLE_RESULTS-CODE_GRP1 = RESREC. "'1-QL-HU'.
      APPEND SAMPLE_RESULTS.
    ENDLOOP.


*   PROSES BAPI RESULT RECORDING
    CALL FUNCTION 'BAPI_INSPOPER_RECORDRESULTS'
    EXPORTING
      INSPLOT                    = INSPLOT
      INSPOPER                   =  '0010'
      INSPPOINTDATA              = IT_INSPPOINTDATA
*     HANDHELD_APPLICATION       = ' '
*   IMPORTING
*     RETURN                     =
   TABLES
*     CHAR_RESULTS               = CHAR_RESULTS
     SAMPLE_RESULTS             = SAMPLE_RESULTS
     SINGLE_RESULTS             = SINGLE_RESULTS
     RETURNTABLE                = RETURNTABLE
            .
    CLEAR CTR.
    LOOP AT RETURNTABLE WHERE TYPE EQ 'E'.
      CTR = CTR + 1.
      EXIT.
    ENDLOOP.
    IF CTR = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
       EXPORTING
         WAIT          = 'X'
       IMPORTING
         RETURN        = RETURN
                .


      CLEAR : IT_INSPPOINTDATA, SAMPLE_RESULTS, SINGLE_RESULTS, RETURNTABLE, RETURN.
      REFRESH : IT_INSPPOINTDATA, SAMPLE_RESULTS, SINGLE_RESULTS, RETURNTABLE, RETURN.
*       lanjut cancel UD
*       PROCESS II CANCEL UD UNTUK PARTIAL LOT

      CLEAR : INSPLOT.
      CLEAR : NUMBER, WERK.
      CLEAR: UD_DATA[], RETURN1[].
      REFRESH: UD_DATA[], RETURN1[].

      MOVE WA_EXEC-PRUEFLOS TO INSPLOT.
      MOVE INSPLOT TO NUMBER.
      MOVE WA_EXEC-WERK TO WERK.
      MOVE NUMBER TO UD_DATA-INSPLOT.
      UD_DATA-UD_SELECTED_SET = UD_DEL. "'0-UD-DEL'. "'UD-DEL'.
      UD_DATA-UD_PLANT = WERK.
      UD_DATA-UD_CODE_GROUP = UD_DEL. "'0-UD-DEL'. "'UD-DEL'.
      IF WA_EXEC-USDEC EQ 'PASS'.
        UD_DATA-UD_CODE = 'P'.
      ELSEIF WA_EXEC-USDEC EQ 'HOLD'.
        UD_DATA-UD_CODE = 'H'.
      ENDIF.
      MOVE WA_EXEC-INSPE TO UD_DATA-UD_RECORDED_BY_USER.
      UD_DATA-UD_STOCK_POSTING = 'X'.
      APPEND UD_DATA.

      CALL FUNCTION 'BAPI_INSPLOT_SETUSAGEDECISION'
        EXPORTING
          NUMBER  = NUMBER
          UD_DATA = UD_DATA
        IMPORTING
          RETURN  = RETURN1.

      IF RETURN1-TYPE NE ''.
          APPEND RETURN1.
      ENDIF.
      READ TABLE RETURN1 INDEX 1.
      CLEAR CTR.
      LOOP AT RETURN1 WHERE TYPE EQ 'E'.
        CTR = CTR + 1.
        EXIT.
      ENDLOOP.
      IF CTR = 0.
        CLEAR RETURN. REFRESH RETURN.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT          = 'X'
         IMPORTING
           RETURN        = RETURN.
*        COMMIT WORK AND WAIT.
        CLEAR :WA_ZTDELINSP_I.
        MOVE WA_EXEC-PRUEFLOS TO WA_ZTDELINSP_I-PRUEFLOS .
        INSERT INTO ZTDELINSP_I VALUES WA_ZTDELINSP_I.
***     persiapan data bdc khusus untuk hold
        IF WA_EXEC-USDEC = 'HOLD'.
          APPEND WA_EXEC TO IT_HOLD.
        ENDIF.
        DELETE IT_EXEC3.
      ELSE.
*       MASUKKAN KE TABEL ERROR
        CLEAR : WA_INSLOT, WA_INERR .
        MOVE WA_EXEC-PRUEFLOS TO WA_INSLOT-INSLOT .
        APPEND WA_INSLOT TO IT_INSLOT.
        MOVE-CORRESPONDING WA_EXEC TO WA_INERR.
        LOOP AT RETURN1 WHERE TYPE EQ 'E'.
          CONCATENATE WA_INERR-ERROR RETURN1-MESSAGE INTO WA_INERR-ERROR SEPARATED BY SPACE.
        ENDLOOP.
        APPEND WA_INERR TO IT_INERR.
      ENDIF.
    ELSE.
*     MASUKKAN KE TABEL ERROR
      CLEAR : WA_INSLOT, WA_INERR .
      MOVE WA_EXEC-PRUEFLOS TO WA_INSLOT-INSLOT .
      APPEND WA_INSLOT TO IT_INSLOT.
      MOVE-CORRESPONDING WA_EXEC TO WA_INERR.
      LOOP AT RETURNTABLE WHERE TYPE EQ 'E'.
        CONCATENATE WA_INERR-ERROR RETURNTABLE-MESSAGE INTO WA_INERR-ERROR SEPARATED BY SPACE.
      ENDLOOP.
      APPEND WA_INERR TO IT_INERR.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PARTIAL_PROCESS

*&---------------------------------------------------------------------*
*&      Form  BDC_VL02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VL02 .
*ERROR BDC
  DATA : BEGIN OF IT_ERROR OCCURS 0,
          VBELN(10).
          INCLUDE STRUCTURE BDCMSGCOLL.
  DATA : END OF IT_ERROR.

  DATA : VBELNIN LIKE LIKP-VBELN,
         VBELNOUT LIKE LIKP-VBELN,
         TRSTA LIKE VBUK-TRSTA,
         VBELN(10).

  CLEAR: VBELNIN, VBELNOUT, TRSTA, VBELN.
  CLEAR IT_ERROR[]. REFRESH IT_ERROR[].

  SORT IT_HOLD BY VBELN.
  DELETE ADJACENT DUPLICATES FROM IT_HOLD COMPARING VBELN.

  LOOP AT IT_HOLD.
    CLEAR: IT_BDCDATA[], IT_BDCMSGCOLL[], VBELN.
    REFRESH: IT_BDCDATA[], IT_BDCMSGCOLL[].
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIKP-VBELN'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                  IT_HOLD-VBELN. "'85000490'.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=HTRA_T'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIPS-MATNR(02)'.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '2000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH_T'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIKP-TRSPG'.

    PERFORM BDC_FIELD       USING 'LIKP-TRSPG'
                                  '02'.
*    perform bdc_transaction using 'VL02N'.
    CALL TRANSACTION 'VL02N' USING IT_BDCDATA
                                  MODE 'N'
                                  UPDATE 'S'
                                  MESSAGES INTO IT_BDCMSGCOLL.
    LOOP AT IT_BDCMSGCOLL WHERE MSGTYP EQ 'E'.
      CLEAR WA_BDCMSGCOLLD.
      MOVE IT_BDCMSGCOLL TO WA_BDCMSGCOLLD.
      MOVE IT_HOLD-VBELN TO VBELN.
      IT_BDCMSGCOLLD-VBELN = VBELN.
      IT_BDCMSGCOLLD-MSGID = WA_BDCMSGCOLLD-MSGID.
      IT_BDCMSGCOLLD-MSGNR = WA_BDCMSGCOLLD-MSGNR.
      IT_BDCMSGCOLLD-MSGV1 = WA_BDCMSGCOLLD-MSGV1.
      IT_BDCMSGCOLLD-MSGV2 = WA_BDCMSGCOLLD-MSGV2.
      IT_BDCMSGCOLLD-MSGV3 = WA_BDCMSGCOLLD-MSGV3.
      IT_BDCMSGCOLLD-MSGV4 = WA_BDCMSGCOLLD-MSGV4.
      APPEND IT_BDCMSGCOLLD.
    ENDLOOP.
  ENDLOOP.

* display error here
  CLEAR CTR.
  SORT IT_BDCMSGCOLLD BY MSGID.
  DESCRIBE TABLE IT_BDCMSGCOLLD LINES CTR.
  IF CTR > 0.
    PERFORM DISPLAY_ERROR.
  ENDIF.
ENDFORM.                    " BDC_VL02

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
*&      Form  DISPLAY_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ERROR .
  DATA: BEGIN OF ERRMSG OCCURS 10,
          VBELN(10).
          INCLUDE STRUCTURE BAPIRET2.
  DATA: END OF ERRMSG,
        MESSAGE LIKE BAPIRET2-MESSAGE,
        LINE TYPE I.
  DATA : BEGIN OF IT_ERR OCCURS 0,
          ERR LIKE BAPIRET2-MESSAGE,
         END OF IT_ERR.

  CLEAR: WA_BDCMSGCOLLD, MESSAGE.
  CLEAR IT_ERR[].
  REFRESH: IT_ERR[].

  LOOP AT IT_BDCMSGCOLLD. " INTO WA_BDCMSGCOLLD.
    ERRMSG-VBELN = IT_BDCMSGCOLLD-VBELN.
    ERRMSG-ID  =  IT_BDCMSGCOLLD-MSGID.
    ERRMSG-NUMBER =  IT_BDCMSGCOLLD-MSGNR.
    ERRMSG-MESSAGE_V1 = IT_BDCMSGCOLLD-MSGV1.
    ERRMSG-MESSAGE_V2 = IT_BDCMSGCOLLD-MSGV2.
    ERRMSG-MESSAGE_V3 = IT_BDCMSGCOLLD-MSGV3.
    ERRMSG-MESSAGE_V4 = IT_BDCMSGCOLLD-MSGV4.
    APPEND ERRMSG.
  ENDLOOP.

  CLEAR : CTR, LINE.
  LINE = LINES( IT_POPMSG ).
  CTR = LINE.
  LOOP AT ERRMSG.
    CLEAR MESSAGE.
    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        ID         = ERRMSG-ID
        NUMBER     = ERRMSG-NUMBER
        LANGUAGE   = SY-LANGU
        TEXTFORMAT = 'HTM'
        MESSAGE_V1 = ERRMSG-MESSAGE_V1
        MESSAGE_V2 = ERRMSG-MESSAGE_V2
        MESSAGE_V3 = ERRMSG-MESSAGE_V3
        MESSAGE_V4 = ERRMSG-MESSAGE_V4
      IMPORTING
        MESSAGE    = MESSAGE.
*    CONCATENATE ERRMSG-VBELN MESSAGE INTO MESSAGE SEPARATED BY SPACE.
    IT_ERR-ERR = MESSAGE.
    APPEND IT_ERR.

*   FILL POPUP DATA

    CTR = CTR + 1.
    IT_POPMSG-NO = CTR.
    IT_POPMSG-DATA = ERRMSG-VBELN.
    IT_POPMSG-MESSAGE = MESSAGE.
    APPEND IT_POPMSG.
  ENDLOOP.

*  CLEAR CTR.
*  DESCRIBE TABLE IT_POPMSG LINES CTR.
*  IF CTR > 0.
*    CLEAR FIELDS[]. REFRESH FIELDS[].
*    FIELDS-TABNAME = 'ZTDELINSP_I'.
*    FIELDS-FIELDNAME = 'INSLOTPROCTXT'.
*    APPEND FIELDS.

*    CALL FUNCTION 'POPUP_TO_SHOW_DB_DATA_IN_TABLE'
*                EXPORTING
*                  TITLE_TEXT              = 'Error When transaction VL02N'
*                TABLES
*                  FIELDS                  = FIELDS
*                  VALUETAB                = IT_ERR
**               EXCEPTIONS
**                 FIELD_NOT_IN_DDIC       = 1
**                 OTHERS                  = 2
*                        .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*************    PERFORM CALL_POPUP.
*  ENDIF.
ENDFORM.                    " DISPLAY_ERROR

*&---------------------------------------------------------------------*
*&      Module  POPULATE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POPULATE_SCREEN OUTPUT.
  G_TCOUT_LINES =  SY-LOOPC.
  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'WA_EXEC-INSPE'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                 " POPULATE_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TCHU_CHANGE_FIELD_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCHU_CHANGE_FIELD_ATTR OUTPUT.
    IF WA_EXEC-SDATA EQ 'PDA'.
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'WA_EXEC-INSPE'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'WA_EXEC-RESOK' OR SCREEN-NAME = 'WA_EXEC-RESNOK'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
ENDMODULE.                 " TCHU_CHANGE_FIELD_ATTR  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCPOP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TCPOP_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_POPMSG LINES TCPOP-lines.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TCPOP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TCPOP_MARK INPUT.
  DATA: g_TCPOP_wa2 like line of IT_POPMSG.
    if TCPOP-line_sel_mode = 1
    and WA_POPMSG-FLAG = 'X'.
     loop at IT_POPMSG into g_TCPOP_wa2
       where FLAG = 'X'.
       g_TCPOP_wa2-FLAG = ''.
       modify IT_POPMSG
         from g_TCPOP_wa2
         transporting FLAG.
     endloop.
  endif.
  MODIFY IT_POPMSG
    FROM WA_POPMSG
    INDEX TCPOP-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form  CALL_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_POPUP .
  CALL SCREEN 0150 STARTING AT 10 4 ENDING AT 90 16.
ENDFORM.                    " CALL_POPUP
*&---------------------------------------------------------------------*
*&      Module  STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0150 OUTPUT.
  SET PF-STATUS 'POPSTATUS'.
  SET TITLEBAR 'Log Status'.
ENDMODULE.                 " STATUS_0150  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0150 INPUT.
  CASE SY-UCOMM.
    WHEN 'BTN_OK'.
      CLEAR: IT_POPMSG.
      REFRESH: IT_POPMSG.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0150  INPUT

***&SPWIZARD: OUTPUT MODULE FOR TC 'TCERRINS'. DO NOT CHANGE THIS LINE!
***&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
**MODULE TCERRINS_CHANGE_TC_ATTR OUTPUT.
**  DESCRIBE TABLE IT_ERRINSPECTOR LINES TCERRINS-lines.
**ENDMODULE.

***&SPWIZARD: OUTPUT MODULE FOR TC 'TCERRINS'. DO NOT CHANGE THIS LINE!
***&SPWIZARD: GET LINES OF TABLECONTROL
**MODULE TCERRINS_GET_LINES OUTPUT.
**  G_TCERRINS_LINES = SY-LOOPC.
**ENDMODULE.

***&SPWIZARD: INPUT MODULE FOR TC 'TCERRINS'. DO NOT CHANGE THIS LINE!
***&SPWIZARD: PROCESS USER COMMAND
**MODULE TCERRINS_USER_COMMAND INPUT.
**  OKCODE = SY-UCOMM.
**  PERFORM USER_OK_TC USING    'TCERRINS'
**                              'IT_ERRINSPECTOR'
**                              ' '
**                     CHANGING OKCODE.
**  SY-UCOMM = OKCODE.
**ENDMODULE.

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                          P_TABLE_NAME
                          P_MARK_NAME
                 CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: L_OK              TYPE SY-UCOMM,
         L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.

     WHEN 'DELE'.                      "delete row
       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME.
       CLEAR P_OK.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME   .
       CLEAR P_OK.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                           P_TABLE_NAME
                                           P_MARK_NAME .
       CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE L_SELLINE.
   IF SY-SUBRC <> 0.                   " append line to table
     L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
     IF L_SELLINE > <LINES>.
       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
     ELSE.
       <TC>-TOP_LINE = 1.
     ENDIF.
   ELSE.                               " insert line into table
     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE L_LINE.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       DELETE <TABLE> INDEX SYST-TABIX.
       IF SY-SUBRC = 0.
         <TC>-LINES = <TC>-LINES - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                       P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TC_NEW_TOP_LINE     TYPE I.
   DATA L_TC_NAME             LIKE FELD-NAME.
   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
   FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
   ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
   IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
     L_TC_NEW_TOP_LINE = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
               ENTRY_ACT             = <TC>-TOP_LINE
               ENTRY_FROM            = 1
               ENTRY_TO              = <TC>-LINES
               LAST_PAGE_FULL        = 'X'
               LOOPS                 = <LINES>
               OK_CODE               = P_OK
               OVERLAPPING           = 'X'
          IMPORTING
               ENTRY_NEW             = L_TC_NEW_TOP_LINE
          EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
               OTHERS                = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD L_TC_FIELD_NAME
              AREA  L_TC_NAME.

   IF SYST-SUBRC = 0.
     IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  CHECK_INSPECTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INSPECTOR.
DATA : BEGIN OF IT_NIK OCCURS 0,
        OBJID LIKE HRP1001-OBJID,
       END OF IT_NIK,
       INSPECTOR LIKE QAQEE-PRUEFER,
       INSPEC1 LIKE  QAQEE-PRUEFER,
       INSPECPOP LIKE  QAQEE-PRUEFER,
       NIKST(8),
       HTYPE  LIKE  DD01V-DATATYPE,
       CTR TYPE I.
DATA : PLNNR LIKE QALS-PLNNR,
       PLNAL LIKE QALS-PLNAL,
       ARBID LIKE PLPO-ARBID,
       OBJID LIKE CRHD-OBJID,
       HROID LIKE CRHD-HROID,
       NIK LIKE HRP1001-OBJID,
       ARBPL LIKE CRHD-ARBPL,
       MSG(80).

CLEAR: WA_ERRINSPECTOR, IT_ERRINSPECTOR. REFRESH IT_ERRINSPECTOR.
  LOOP AT IT_EXEC2.
    CLEAR: INSPECTOR, PLNNR, PLNAL, ARBID, HROID, ARBPL, IT_NIK, NIK.
    REFRESH IT_NIK.

    SELECT SINGLE PLNNR PLNAL
      INTO (PLNNR, PLNAL)
      FROM QALS
      WHERE PLNTY = 'Q' AND
            PRUEFLOS = IT_EXEC2-PRUEFLOS.

    SELECT SINGLE ARBID
      INTO ARBID
      FROM PLPO
      WHERE PLNNR = PLNNR AND
            PLNTY = 'Q'.

    SELECT SINGLE HROID ARBPL
      INTO (HROID, ARBPL)
      FROM CRHD
      WHERE OBJID = ARBID AND
            OBJTY = 'A'.

    SELECT OBJID
      INTO CORRESPONDING FIELDS OF TABLE IT_NIK
      FROM HRP1001
      WHERE SOBID = HROID AND
            OTYPE = 'P'.

    CLEAR OBJID.
      OBJID = IT_EXEC2-INSPE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = OBJID
        IMPORTING
          OUTPUT = OBJID.


      LOOP AT IT_NIK WHERE OBJID EQ OBJID.
        NIK = IT_NIK-OBJID.
        EXIT.
      ENDLOOP.

      IF NIK EQ ''.
        CONCATENATE 'NIK is not assigned in W.cntr' ARBPL '!' INTO MSG SEPARATED BY SPACE.
        WA_ERRINSPECTOR-PRUEFLOS = IT_EXEC2-PRUEFLOS.
        WA_ERRINSPECTOR-ERRROR = MSG.
        APPEND WA_ERRINSPECTOR TO IT_ERRINSPECTOR.
        DELETE IT_EXEC2.
      ENDIF.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM IT_ERRINSPECTOR COMPARING PRUEFLOS.
ENDFORM.                    " CHECK_INSPECTOR

*&---------------------------------------------------------------------*
*&      Form  GET_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NIK .
DATA : TAB TYPE STANDARD TABLE OF SVAL WITH HEADER LINE,
       LINE TYPE I, RETURNCODE(1), INSPECTOR LIKE QAQEE-PRUEFER,
       INSPEC1 LIKE  QAQEE-PRUEFER.

CLEAR LINE.
  IF IT_EXEC[] IS NOT INITIAL.
    LOOP AT IT_EXEC WHERE SDATA EQ 'MANUAL' AND ( RESOK NE '' OR RESNOK NE '' ).
      LINE = LINE + 1.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF LINE > 0.
*   POPUP GET_NIK
    CLEAR RETURNCODE.
    CLEAR TAB. REFRESH TAB.
    TAB-TABNAME = 'ZINSPECTOR'.
    TAB-VALUE = INSPEC1.
    TAB-FIELDNAME = 'INSPECTOR'.
    APPEND TAB.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*               NO_VALUE_CHECK        = ' '
       POPUP_TITLE           = 'Masukkan Inspector'
       START_COLUMN          = '5'
       START_ROW             = '5'
      IMPORTING
       RETURNCODE            = RETURNCODE
      TABLES
        FIELDS                = TAB
     EXCEPTIONS
       ERROR_IN_FIELDS       = 1
       OTHERS                = 2
              .
    IF SY-SUBRC <> 0 OR RETURNCODE EQ 'A'.
      MESSAGE 'Transaction cancelled!' TYPE 'E'.
    ELSE.
      CLEAR INSPECTOR.
      INSPECTOR = TAB-VALUE.
      IF INSPECTOR EQ ''.
        MESSAGE 'Transaction cancelled, inspector is required!' TYPE 'E'.
      ELSE.
        LOOP AT IT_EXEC WHERE SDATA EQ 'MANUAL' AND ( RESOK NE '' OR RESNOK NE '' ).
          IT_EXEC-INSPE = INSPECTOR. "'123'.
          MODIFY IT_EXEC.
        ENDLOOP.
        REFRESH CONTROL 'TCDEL' FROM SCREEN '0100'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_NIK

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_AUTH_PLANT USING P_WERKS.
  RET_CODE = '4'.
  AUTHORITY-CHECK OBJECT 'ZQMD'
    ID 'WERKS' FIELD P_WERKS.

  RET_CODE = SY-SUBRC.

ENDFORM.                    " CHECK_AUTH_PLANT