*---------------------------------------------------------------------*
*       FORM   TEXT_FEHLT_FUELLEN.                                    *
*---------------------------------------------------------------------*
*       Die MAIL_ZEILEn werden mit der Fehlteiletabelle gefüllt.      *
*       Die FORM-Routine wird bei der Nachrichtenart MLFH aufgerufen. *
*---------------------------------------------------------------------*
FORM TEXT_FEHLT_FUELLEN TABLES XTLINES STRUCTURE TLINE
                        USING XTHEAD STRUCTURE THEAD
                              SNAST  STRUCTURE NAST.
  DATA: CHANGED,
        CURRENTPROGRAM LIKE SY-REPID.
  DATA: X_NEW_CURSOR_COLUMN LIKE SY-TABIX,
        X_NEW_CURSOR_LINE   LIKE SY-TABIX.
  MKPF = XMKPF.
  DESCRIBE TABLE XTLINES LINES  SY-TABIX.
  IF SY-TABIX = 0 AND NOT XTHEAD IS INITIAL.
    CALL FUNCTION 'READ_TEXT'
         EXPORTING
              ID                      = XTHEAD-TDID
              LANGUAGE                = XTHEAD-TDSPRAS
              NAME                    = XTHEAD-TDNAME
              OBJECT                  = XTHEAD-TDOBJECT
         TABLES
              LINES                   = XTLINES
         EXCEPTIONS
              ID                      = 01
              LANGUAGE                = 02
              NAME                    = 03
              NOT_FOUND               = 04
              OBJECT                  = 05
              REFERENCE_CHECK         = 06
              WRONG_ACCESS_TO_ARCHIVE = 07.
  ENDIF.
  DESCRIBE TABLE XTLINES LINES SY-TABIX.
  CHECK SY-TABIX GT 0.
  DATA: FORMAT like tline-tdformat,
        F_WERKS LIKE T001W-WERKS,
        F_DUSER LIKE VM07M-DUSER.
* The format of the last line will be used as format for the missing
* part table. Format is stored in local field FORMAT.
  READ TABLE XTLINES INDEX SY-TABIX.
  format = xtlines-tdformat.
* Format is undefined, so use * to force a new line
  if format is initial.
    format = '*'.
  endif.
  CLEAR: XTLINES.
  READ TABLE XTFMAT INDEX 1.
  IF NOT XTFMAT-DETAIL IS INITIAL.
    PERFORM TEXT_FEHLT_UNVERDICHTET TABLES XTLINES USING FORMAT.
    DELETE XTFMAT INDEX 1.
  ELSE.
    MOVE: XTFMAT-WERKS TO F_WERKS,
          XTFMAT-DUSER TO F_DUSER.
    REFRESH YTFMAT.
    LOOP AT XTFMAT WHERE WERKS = F_WERKS
                   AND   DUSER = F_DUSER.
      MOVE-CORRESPONDING XTFMAT TO YTFMAT.
      COLLECT YTFMAT.
      DELETE XTFMAT.
    ENDLOOP.
    DESCRIBE TABLE YTFMAT LINES SY-TABIX.
    IF SY-TABIX = 1.
      PERFORM TEXT_FEHLT_UNVERDICHTET TABLES XTLINES USING FORMAT.
    ELSE.
      PERFORM TEXT_FEHLT_VERDICHTET TABLES XTLINES USING FORMAT.
    ENDIF.
  ENDIF.
  CURRENTPROGRAM = SY-REPID.
  CALL FUNCTION 'TEXT_SYMBOL_REPLACE'
       EXPORTING
            ENDLINE = SY-TABIX
            HEADER = XTHEAD
*          INIT = 'X'
*          OPTION_DIALOG = E04
            PROGRAM = CURRENTPROGRAM
*          REPLACE_PROGRAM = E06
*          REPLACE_STANDARD = 'X'
*          REPLACE_SYSTEM = 'X'
*          REPLACE_TEXT = 'X'
*          STARTLINE = E10
       IMPORTING
            CHANGED = CHANGED
*          NEWHEADER =
       TABLES
            LINES = XTLINES.
  CALL FUNCTION 'FORMAT_TEXTLINES'
*      EXPORTING
*           CURSOR_COLUMN = E01
*           CURSOR_LINE = E02
*           ENDLINE = E03
*           FORMATWIDTH = E04
*           LINEWIDTH = E05
*           STARTLINE = E06
       IMPORTING
            NEW_CURSOR_COLUMN = X_NEW_CURSOR_COLUMN
            NEW_CURSOR_LINE =   X_NEW_CURSOR_LINE
       TABLES
            LINES = XTLINES.
ENDFORM.