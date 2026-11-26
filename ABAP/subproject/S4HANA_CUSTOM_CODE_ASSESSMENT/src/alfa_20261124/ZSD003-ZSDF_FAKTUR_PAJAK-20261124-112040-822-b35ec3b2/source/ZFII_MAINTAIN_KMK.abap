*&---------------------------------------------------------------------*
*& Report  ZFII_MAINTAIN_KMK
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFII_MAINTAIN_KMK.

TABLES: ZZKMK.

DATA BEGIN OF IT_KMK OCCURS 0.
        INCLUDE STRUCTURE ZZKMK.
DATA: MARK(1),
      END OF IT_KMK.

CONTROLS: TC_KMK TYPE TABLEVIEW USING SCREEN 0100.
DATA: COLS LIKE LINE OF TC_KMK-COLS,
      LINES TYPE I.
DATA: OK_CODE TYPE SY-UCOMM,
      SAVE_OK TYPE SY-UCOMM.

SELECT * FROM ZZKMK INTO TABLE IT_KMK.

CALL SCREEN 100.

*----------------------------------------------------------------------*
*  MODULE TC_KMK_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TC_KMK_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_KMK LINES TC_KMK-LINES.
ENDMODULE.                    "TC_KMK_CHANGE_TC_ATTR OUTPUT


*----------------------------------------------------------------------*
*  MODULE user_command_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.
  CASE SAVE_OK.
    WHEN 'TOGGLE'.
      LOOP AT TC_KMK-COLS INTO COLS. " WHERE INDEX GT 2.
        IF  COLS-SCREEN-INPUT = '0'.
          COLS-SCREEN-INPUT = '1'.
        ELSEIF  COLS-SCREEN-INPUT = '1'.
          COLS-SCREEN-INPUT = '0'.
        ENDIF.
        MODIFY TC_KMK-COLS FROM COLS INDEX SY-TABIX.
      ENDLOOP.
    WHEN 'APPEND'.
      PERFORM ADD_KMK.
    WHEN 'DELETE'.
*      READ TABLE TC_KMK-COLS INTO COLS WITH KEY SCREEN-INPUT = '1'.
*      IF SY-SUBRC = 0.

      LOOP AT IT_KMK WHERE MARK = 'X'.
        PERFORM DELETE_KMK.
      ENDLOOP.
*      ENDIF.
  ENDCASE.
ENDMODULE.                    "user_command_0100 INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'SCREEN_100'.
  SET TITLEBAR 'SCREEN_100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CANCEL INPUT.
  LEAVE PROGRAM.
ENDMODULE.                 " CANCEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_TABLE_CONTROL INPUT.
  MODIFY IT_KMK FROM IT_KMK INDEX TC_KMK-CURRENT_LINE.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT



*&---------------------------------------------------------------------*
*&      Form  add_kmk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_KMK.
  DATA: BEGIN OF FIELDS OCCURS 1.
          INCLUDE STRUCTURE SVAL.
  DATA: END OF FIELDS,
        RETURNCODE TYPE C.
  FIELDS-TABNAME = 'ZZKMK'.
  FIELDS-FIELDNAME = 'DATEKMK'.
  FIELDS-FIELDTEXT = 'KMK date : '.
  FIELDS-VALUE = ''.
  APPEND FIELDS.

  FIELDS-TABNAME = 'ZZKMK'.
  FIELDS-FIELDNAME = 'DATERATE'.
  FIELDS-FIELDTEXT = 'Rate date : '.
  FIELDS-VALUE = ''.
  APPEND FIELDS.

  FIELDS-TABNAME = 'ZZKMK'.
  FIELDS-FIELDNAME = 'NOKMK'.
  FIELDS-FIELDTEXT = 'KMK Number : '.
  FIELDS-VALUE = ''.
  APPEND FIELDS.


  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE  = 'Tambahkan nomor KMK baru'
      START_COLUMN = '5'
      START_ROW    = '5'
    IMPORTING
      RETURNCODE   = RETURNCODE
    TABLES
      FIELDS       = FIELDS.

  IF RETURNCODE NE 'A'.
    CLEAR IT_KMK.
    READ TABLE FIELDS WITH KEY FIELDNAME = 'DATEKMK'.
    IF SY-SUBRC = 0.
      LOOP AT IT_KMK WHERE DATEKMK > FIELDS-VALUE.
      ENDLOOP.
      IF SY-SUBRC = 0.
        MESSAGE 'Tanggal KMK tidak boleh lebih kecil dari yang sudah ada...!' TYPE 'I'.
        EXIT.
      ELSE.
        IT_KMK-DATEKMK = FIELDS-VALUE.
      ENDIF.
    ENDIF.

    READ TABLE FIELDS WITH KEY FIELDNAME = 'DATERATE'.
    IF SY-SUBRC = 0.
      IT_KMK-DATERATE = FIELDS-VALUE.
    ENDIF.

    READ TABLE FIELDS WITH KEY FIELDNAME = 'NOKMK'.
    IF SY-SUBRC = 0.
      IT_KMK-NOKMK = FIELDS-VALUE.
    ENDIF.

    IF IT_KMK-DATEKMK = '' OR IT_KMK-DATERATE = '' OR IT_KMK-NOKMK = ''.
      MESSAGE 'Data harus diisi semua...!' TYPE 'I'.
    ELSE.
      APPEND IT_KMK.
      MODIFY ZZKMK FROM IT_KMK.
    ENDIF.

  ENDIF.
ENDFORM.                    "add_kmk



*&---------------------------------------------------------------------*
*&      Form  delete_kmk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DELETE_KMK.
  DATA: V_ANS, V_TXT(50).

  CONCATENATE 'Yakin mau delete KMK tgl' IT_KMK-DATEKMK 'no' IT_KMK-NOKMK '...?' INTO V_TXT SEPARATED BY SPACE.
  CALL FUNCTION 'TRINT_TCE_POPUP_TO_CONFIRM'
    EXPORTING
      IV_TITLE         = 'Delete KMK'
      IV_QUESTION      = V_TXT  "'Yakin mau delete KMK..? '
*     IV_ADDTEXT       = ' add text'
      IV_DEFAULTBUTTON = 'N'
      IV_STARTCOLUMN   = 25
      IV_STARTROW      = 6
      IV_DISPLAYCANCEL = 'X'
    IMPORTING
      EV_ANSWER        = V_ANS.

  IF V_ANS = 'J'.
    DELETE IT_KMK.
    DELETE ZZKMK FROM IT_KMK.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    "delete_kmk