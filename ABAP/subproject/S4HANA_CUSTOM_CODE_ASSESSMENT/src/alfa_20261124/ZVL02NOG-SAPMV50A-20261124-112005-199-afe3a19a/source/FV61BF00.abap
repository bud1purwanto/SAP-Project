***INCLUDE FV61BF00 .

*----------------------------------------------------------------------*
*     aufgerufen in                                                    *
*     - SAPMV45A                                                       *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*     - Routinen für                                                   *
*       - Textvariablenersetzung                                       *
*       - Parameter der Mailaktion ersetzen                            *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       Textvariablenersetzung                                        *
*---------------------------------------------------------------------*
FORM TEXT_SYMBOL_REPLACE TABLES XTLINES STRUCTURE TLINE
                         USING XTHEAD STRUCTURE THEAD
                               SNAST  STRUCTURE NAST.

DATA: CHANGED,
      CURRENTPROGRAM LIKE SY-REPID.
DATA: X_NEW_CURSOR_COLUMN LIKE SY-TABIX,
      X_NEW_CURSOR_LINE   LIKE SY-TABIX.
  DESCRIBE TABLE XTLINES LINES  SY-TABIX.
  IF SY-TABIX EQ 0 AND NOT XTHEAD IS INITIAL.
    CALL FUNCTION 'READ_TEXT'
         EXPORTING
              ID        = XTHEAD-TDID
              LANGUAGE  = XTHEAD-TDSPRAS
              NAME      = XTHEAD-TDNAME
              OBJECT    = XTHEAD-TDOBJECT
*        IMPORTING
*             HEADER    =
         TABLES
              LINES     = XTLINES
         EXCEPTIONS
              ID        = 01
              NOT_FOUND = 04
              OBJECT    = 05
*              SAVEMODE  = 06                             " K11K065531
              LANGUAGE  = 02
              NAME      = 03.
  ENDIF.
  DESCRIBE TABLE XTLINES LINES  SY-TABIX.
  CHECK SY-TABIX GT 0.
  CURRENTPROGRAM = SY-REPID.
* In case of updating SO from MM.
  Case sy-cprog.
     WHEN 'RM_MEPO_GUI'.
       CURRENTPROGRAM = 'SAPLMEPO'.
     WHEN 'SAPMM06E'.    "ME21
       CURRENTPROGRAM = 'SAPMM06E'.
     WHEN 'RM06BB10'.    "ME59
       CURRENTPROGRAM = 'SAPMM06E'.
     WHEN 'RM06BB30'.    "ME59N
       CURRENTPROGRAM = 'SAPLMEPO'.
  ENDCASE.

  CALL FUNCTION 'TEXT_SYMBOL_REPLACE'
       EXPORTING
            ENDLINE = SY-TABIX
            HEADER = XTHEAD
*           INIT = 'X'
*           OPTION_DIALOG = E04
            PROGRAM = CURRENTPROGRAM
*           REPLACE_PROGRAM = E06
*           REPLACE_STANDARD = 'X'
*           REPLACE_SYSTEM = 'X'
*           REPLACE_TEXT = 'X'
*           STARTLINE = E10
       IMPORTING
            CHANGED = CHANGED
*           NEWHEADER =
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

*----------------------------------------------------------------------*
*       Parameter der Mailaktion ersetzen
*----------------------------------------------------------------------*
FORM MAILAKTIONSPARAMETER USING PARAFELD PARAWERT
                                PNAST STRUCTURE NAST.

  DATA: FELDNAME LIKE NAST-PFLD1,
        FELDWERT LIKE NAST-PFLD1,
        KONSTANTE_ANFANG VALUE '"'.
  FIELD-SYMBOLS: <FELDWERT>.

  FELDNAME = PARAFELD.
  CHECK FELDNAME NE SPACE.
  IF FELDNAME+0(1) EQ KONSTANTE_ANFANG.
    SHIFT FELDNAME .
    REPLACE KONSTANTE_ANFANG WITH SPACE INTO FELDNAME.
    PARAWERT = FELDNAME.
  ELSE.
    DATA: L_TARGET TYPE CHAR80.
    WRITE (FELDNAME) TO L_TARGET.
    IF SY-SUBRC EQ 0.
* FELDNAME is a variable
      PARAWERT = L_TARGET.
    ELSE.
* FELDNAME has already been replaced
      PARAWERT = FELDNAME.
    ENDIF.
  ENDIF.


ENDFORM.