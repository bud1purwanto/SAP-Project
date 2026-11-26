FUNCTION ZMM_TEXT_MAT_TO_MAT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(MATNR) TYPE  MATNR
*"     REFERENCE(CHARG) TYPE  CHARG_D
*"     REFERENCE(WERKS) TYPE  WERKS_D
*"     REFERENCE(LENGTH_I) TYPE  P
*"     REFERENCE(CANC) TYPE  BOOLEAN OPTIONAL
*"  EXPORTING
*"     VALUE(LENGTH_O) TYPE  P
*"  TABLES
*"      MESSAGE STRUCTURE  SYMSG OPTIONAL
*"----------------------------------------------------------------------

  DATA: V_NAME   LIKE THEAD-TDNAME,
        THEAD    LIKE THEAD,
        TLINE    LIKE TLINE OCCURS 0 WITH HEADER LINE,
        V_INDEX  TYPE SY-TABIX,
        V_LENGTH TYPE P,
        V_DELLEN TYPE TLINE-TDLINE.

  V_NAME+0(10) = MATNR.
  V_NAME+22(10) = CHARG.

  THEAD-TDID      = 'VERM'.
  THEAD-TDSPRAS   = SY-LANGU.
  THEAD-TDNAME    = V_NAME.
  THEAD-TDOBJECT  = 'CHARGE'.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = THEAD-TDID
      LANGUAGE                = THEAD-TDSPRAS
      NAME                    = THEAD-TDNAME
      OBJECT                  = THEAD-TDOBJECT
    TABLES
      LINES                   = TLINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  "Set Length
  IF CANC EQ ''.
    TLINE-TDFORMAT = '*'.
    TLINE-TDLINE   = LENGTH_I.
    CONDENSE TLINE-TDLINE NO-GAPS.
    APPEND TLINE.
    "Delete Length
  ELSEIF CANC EQ 'X'.
    V_DELLEN = LENGTH_I.
    CONDENSE V_DELLEN NO-GAPS.
    READ TABLE TLINE WITH KEY TDLINE = V_DELLEN.
    IF SY-SUBRC EQ 0.
      DELETE TLINE INDEX SY-TABIX.
    ENDIF.
  ENDIF.

  "Get Total Length
  LOOP AT TLINE.
    IF TLINE-TDLINE NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      LENGTH_O = LENGTH_O + TLINE-TDLINE.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = THEAD
      SAVEMODE_DIRECT = 'X'
    TABLES
      LINES           = TLINE
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBIECT          = 4
      OTHERS          = 5.



ENDFUNCTION.