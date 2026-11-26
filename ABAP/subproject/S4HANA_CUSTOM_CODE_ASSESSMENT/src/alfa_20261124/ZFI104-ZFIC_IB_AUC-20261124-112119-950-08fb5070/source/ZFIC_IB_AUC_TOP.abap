*&---------------------------------------------------------------------*
*&  Include           ZFIC_IB_AUC_TOP
*&---------------------------------------------------------------------*
DATA :  FNAME type STRING.

DATA: BEGIN OF IRESULT OCCURS 400,
         ANLN1    LIKE AICOM-ANLN1,
         DRESULT  TYPE C LENGTH 200, "Successfully / Unsuccessfully
  END OF IRESULT.

DATA: BEGIN OF IDATA_AIAB OCCURS 0,
        BUKRS     LIKE AICOM-BUKRS,
        ANLN1     LIKE AICOM-ANLN1,
        ANLN2     LIKE AICOM-ANLN2,
        KONTY     TYPE C LENGTH 3,
        EMPGE     LIKE DKOBR-EMPGE,
        PROZS     LIKE COBRB-PROZS,
  END OF IDATA_AIAB.

DATA: BEGIN OF IDATA_AIBU OCCURS 0,
        BUKRS     LIKE AICOM-BUKRS,
        ANLN1     LIKE AICOM-ANLN1,
        ANLN2     LIKE AICOM-ANLN2,
        BLDAT     TYPE C LENGTH 10,
        BZDAT     TYPE C LENGTH 10,
        BUDAT     TYPE C LENGTH 10,
        MONAT     LIKE ANBZ-MONAT,
        SGTXT     LIKE KOMK3-SGTXT,
        BLART     LIKE KOMK1-BLART,
        ZUONR     LIKE KOMK3-ZUONR,
  END OF IDATA_AIBU.

DATA: v_dum(3) TYPE n,
      vtext(220) TYPE c,
      vtext1(50) TYPE c,
      vtext2(50) TYPE c,
      vtext3(50) TYPE c,
      vtext4(50) TYPE c.

DATA :IT_BDCDATA LIKE BDCDATA OCCURS 400 WITH HEADER LINE,
      IT_BDCMSGCOLL LIKE BDCMSGCOLL OCCURS 400 WITH HEADER LINE.

DATA: PATH    LIKE RLGRAP-FILENAME,
      VBLDAT  TYPE ANEK-BLDAT,
      VBZDAT  TYPE ANEP-BZDAT,
      VBUDAT  TYPE ANEK-BUDAT.

DATA: GS_LAYOUT                 TYPE SLIS_LAYOUT_ALV,
      G_EXIT_CAUSED_BY_CALLER,
      GS_EXIT_CAUSED_BY_USER    TYPE SLIS_EXIT_BY_USER,
      GT_FIELDCAT               TYPE SLIS_T_FIELDCAT_ALV,
      GT_LIST_TOP_OF_PAGE       TYPE SLIS_T_LISTHEADER,
      G_REPID                   LIKE SY-REPID,
      Y_PRINT                   TYPE SLIS_PRINT_ALV,
      GS_SORT_INFO              TYPE SLIS_SORTINFO_ALV.

DATA: GS_VARIANT  LIKE DISVARIANT,
      GT_EVENTS   TYPE SLIS_T_EVENT,
      G_SAVE.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: R1 RADIOBUTTON GROUP RAD1 DEFAULT 'X'.
PARAMETERS: R2 RADIOBUTTON GROUP RAD1.
SELECTION-SCREEN END OF BLOCK B1.
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE text-002.
PARAMETERS: FPATH LIKE RLGRAP-FILENAME MEMORY ID pid LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FPATH.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = FPATH.
  IF SY-SUBRC <> 0 OR FPATH EQ ''.
    LEAVE PROGRAM.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GUI_UPLOAD_AIAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GUI_UPLOAD_AIAB .
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      data_tab            = IDATA_AIAB
    EXCEPTIONS
      conversion_error    = 1
      invalid_table_width = 2
      invalid_type        = 3
      no_batch            = 4
      unknown_error       = 5
      file_open_error     = 6
      file_read_error     = 7
      OTHERS              = 8.
  IF sy-subrc <> 0.
    message i000(0k) with 'File cannot be opened'.
    stop.
  ENDIF.
ENDFORM.                    " GUI_UPLOAD_AIAB
*&---------------------------------------------------------------------*
*&      Form  GUI_UPLOAD_AIBU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GUI_UPLOAD_AIBU .
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      data_tab            = IDATA_AIBU
    EXCEPTIONS
      conversion_error    = 1
      invalid_table_width = 2
      invalid_type        = 3
      no_batch            = 4
      unknown_error       = 5
      file_open_error     = 6
      file_read_error     = 7
      OTHERS              = 8.
  IF sy-subrc <> 0.
    message i000(0k) with 'File cannot be opened'.
    stop.
  ENDIF.
ENDFORM.                    " GUI_UPLOAD_AIBU