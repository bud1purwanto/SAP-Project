INCLUDE RSTXLCCALC.
*----------------------------------------------------------------
*"  subroutines for smart form ZLABEL_001
*----------------------------------------------------------------

*----------------------------------------------------------------
*"  MAKRO FILL_TEXTAREA
*----------------------------------------------------------------

DEFINE FILL_TEXTAREA.
  CLEAR %TEXTAREA.
  %TEXTAREA-ENABLED  = &1.
  %TEXTAREA-NCOLS    = &2.
  %TEXTAREA-NROWS    = &3.
  %TEXTAREA-READONLY = &4.
END-OF-DEFINITION.

*----------------------------------------------------------------
*"  FORM %WRITE_TEXT
*----------------------------------------------------------------

FORM %WRITE_TEXT USING NAME        TYPE SSFKEYNAME
                       STYLE       TYPE TDSSNAME
                       STYLEVARI   TYPE TDVARIANT
                       APP_MODE    TYPE TDSFAMODE
                       PROTECT     TYPE TDSFFLAG
                       INPUTFIELDS TYPE TSFINPUT
                       TEXTAREA    TYPE SSFTXTAREA.

DATA: LANGU TYPE SPRAS,
      L_TOKEN TYPE TSFTOKEN.

  CALL FUNCTION 'SSFRT_READ_TEXT'
       EXPORTING I_FORMNAME  = 'ZLABEL_001'
                 I_TEXTNAME  = NAME
                 I_LANGUAGES = %LANGUAGES
                 I_ACTIVE    = 'X'
       IMPORTING O_LANGU     = LANGU
                 O_TEXT      = %TEXT
       EXCEPTIONS LANGUAGE_NOT_FOUND = 1
                  OTHERS             = 2.
  IF SY-SUBRC = 0.
    SFSY-SUBRC = 0.
  ELSE.
    SFSY-SUBRC = 4.
    CALL FUNCTION 'SSFRT_SET_ERROR_PARAMETERS'
        EXPORTING I_FORM      = 'ZLABEL_001'.
    CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_NO_TEXTMODULE
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'W'
                  I_MSGNO     = '618'
                  I_MSGV1     = NAME.
    EXIT.
  ENDIF.
  CALL FUNCTION 'SSFCOMP_CONVERT_ITF_TO_TOKEN'
       EXPORTING I_NAME     = NAME
                 I_TEXT     = %TEXT
                 I_TEXTNAME = SPACE
                 I_TEXTTYPE = SPACE
                 I_LANGU    = LANGU
       IMPORTING E_TOKEN    = L_TOKEN.
  CALL FUNCTION 'SSFCOMP_WRITE_TEXT'
       EXPORTING  NAME              = NAME
                  LANGU             = LANGU
                  STYLE             = STYLE
                  STYLEVARI         = STYLEVARI
                  TEXT              = L_TOKEN
                  TEXTTYPE          = SPACE
                  APPEND_MODE       = APP_MODE
                  PROTECT           = PROTECT
                  INPUTFIELDS       = INPUTFIELDS
                  TEXTAREA          = TEXTAREA
       EXCEPTIONS NON_MAIN_OVERFLOW = 1
                  OTHERS            = 2.
  CASE SY-SUBRC.
  WHEN 1.
    %WEXIT = 'X'.
  WHEN 2.
    RAISE ERROR.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %WRITE_TEXT_MODULE
*----------------------------------------------------------------

FORM %WRITE_TEXT_MODULE USING NAME        TYPE SSFKEYNAME
                              TEXT        TYPE TDSFNAME
                              TLANG       TYPE SPRAS
                              STYLE       TYPE TDSSNAME
                              STYLEVARI   TYPE TDVARIANT
                              APP_MODE    TYPE TDSFAMODE
                              PROTECT     TYPE TDSFFLAG
                              IGNORE      TYPE TDSFFLAG
                              INPUTFIELDS TYPE TSFINPUT
                              TEXTAREA    TYPE SSFTXTAREA.

DATA: LANGU        TYPE SPRAS,
      L_TOKEN      TYPE TSFTOKEN,
      L_LANGUAGES  TYPE SSFRLANG,
      L_XSF_STATUS TYPE SSFXSF.

  CALL FUNCTION 'SSFRT_ADD_LANGUAGE'
       EXPORTING  I_LANG       = TLANG
                  I_LANGUAGES  = %LANGUAGES
       IMPORTING  O_LANGUAGES  = L_LANGUAGES.
  CALL FUNCTION 'SSFRT_READ_TEXTMODULE'
       EXPORTING  I_TEXTMODULE = TEXT
                  I_LANGUAGES  = L_LANGUAGES
       IMPORTING  O_LANGU      = LANGU
                  O_TEXT       = %TEXT
       EXCEPTIONS LANGUAGE_NOT_FOUND = 1
                  OTHERS             = 2.
  IF SY-SUBRC = 0.
    SFSY-SUBRC = 0.
  ELSE.
    SFSY-SUBRC = 4.
    CALL FUNCTION 'SSFRT_SET_ERROR_PARAMETERS'
      EXPORTING I_FORM      = 'ZLABEL_001'.
    IF IGNORE = SPACE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_NO_TEXTMODULE
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'E'
                  I_MSGNO     = '615'
                  I_MSGV1     = TEXT.
      PERFORM RESET_ALL IN PROGRAM SAPLSTXBC.
      RAISE ERROR.
    ELSE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_NO_TEXTMODULE
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'W'
                  I_MSGNO     = '615'
                  I_MSGV1     = TEXT.
      PERFORM XSF_IS_ACTIVE IN PROGRAM SAPLSTXBC
              CHANGING L_XSF_STATUS.
      IF L_XSF_STATUS = 'X' AND TEXTAREA-ENABLED = 'A'.
        SFSY-SUBRC = 0.
        CALL FUNCTION 'SSFRT_XSF_DUMMY_TEXT'
          EXPORTING  I_LANGUAGES = L_LANGUAGES
          IMPORTING  O_LANGU     = LANGU
                     O_TEXT      = %TEXT.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'SSFCOMP_CONVERT_ITF_TO_TOKEN'
       EXPORTING I_NAME     = NAME
                 I_TEXT     = %TEXT
                 I_TEXTNAME = TEXT
                 I_TEXTTYPE = 'R'
                 I_LANGU    = LANGU
       IMPORTING E_TOKEN    = L_TOKEN.
  CALL FUNCTION 'SSFCOMP_WRITE_TEXT'
       EXPORTING  NAME              = NAME
                  LANGU             = LANGU
                  STYLE             = STYLE
                  STYLEVARI         = STYLEVARI
                  TEXT              = L_TOKEN
                  TEXTTYPE          = 'R'
                  APPEND_MODE       = APP_MODE
                  PROTECT           = PROTECT
                  INPUTFIELDS       = INPUTFIELDS
                  TEXTAREA          = TEXTAREA
       EXCEPTIONS NON_MAIN_OVERFLOW = 1
                  OTHERS            = 2.
  CASE SY-SUBRC.
  WHEN 1.
    %WEXIT = 'X'.
  WHEN 2.
    RAISE ERROR.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %GET_TEXTSTYLE
*----------------------------------------------------------------

FORM %GET_TEXTSTYLE USING    NAME     TYPE TDSFNAME
                             TLANG    TYPE SPRAS
                             IGNORE   TYPE TDSFFLAG
                    CHANGING STYLE    TYPE TDSSNAME.

DATA: NODENAME     TYPE SSFNAME VALUE 'HEADER',
      IVARHEADER   TYPE TSFIVHD,
      VARHEADER_WA TYPE SSFIVHD,
      SUBRC        TYPE SY-SUBRC,
      TEXTSTYLE_WA TYPE TY_TEXTSTYLE.

  READ TABLE %TEXTSTYLE_TAB INTO TEXTSTYLE_WA
       WITH KEY NAME = NAME TLANG = TLANG.
  IF SY-SUBRC = 0.
    STYLE = TEXTSTYLE_WA-STYLE.
    EXIT.
  ENDIF.

  CALL FUNCTION 'SSF_READ_FORM'
       EXPORTING  I_FORMNAME     = NAME
                  I_LANGUAGE     = TLANG
       EXCEPTIONS OTHERS         = 4.
  IF SY-SUBRC <> 0.
    SUBRC = SY-SUBRC.
  ENDIF.

  CALL FUNCTION 'SSF_READ_NODE_BEGIN'
       EXPORTING  I_NODETYPE     = 'SF'
                  I_NODENAME     = NODENAME
       EXCEPTIONS OTHERS         = 4.
  IF SY-SUBRC <> 0.
    SUBRC = SY-SUBRC.
  ENDIF.

  CALL FUNCTION 'SSF_READ_DATE'
       EXPORTING  I_NAME         = 'IVARHEADER'
       IMPORTING  O_DATE         = IVARHEADER
       EXCEPTIONS OTHERS         = 4.
  IF SY-SUBRC <> 0.
    SUBRC = SY-SUBRC.
  ENDIF.

  LOOP AT IVARHEADER INTO VARHEADER_WA TO 1.
    STYLE = VARHEADER_WA-STDSTYLE.
  ENDLOOP.
  IF SY-SUBRC <> 0 OR STYLE = SPACE.
    CALL FUNCTION 'SSFRT_SET_ERROR_PARAMETERS'
      EXPORTING I_FORM      = 'ZLABEL_001'.
    IF IGNORE = SPACE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_NO_TEXTSTYLE
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'E'
                  I_MSGNO     = '619'
                  I_MSGV1     = NAME.
      PERFORM RESET_ALL IN PROGRAM SAPLSTXBC.
      RAISE ERROR.
    ELSE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_NO_TEXTSTYLE
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'W'
                  I_MSGNO     = '619'
                  I_MSGV1     = NAME.
    ENDIF.
  ELSE.
    TEXTSTYLE_WA-NAME  = NAME.
    TEXTSTYLE_WA-TLANG = TLANG.
    TEXTSTYLE_WA-STYLE = STYLE.
    INSERT TEXTSTYLE_WA INTO TABLE %TEXTSTYLE_TAB.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %WRITE_INCLUDE_TEXT
*----------------------------------------------------------------

FORM %WRITE_INCLUDE_TEXT USING NAME        TYPE SSFKEYNAME
                               TEXTKEY     TYPE SSFTKEY
                               STYLE       TYPE TDSSNAME
                               STYLEVARI   TYPE TDVARIANT
                               APP_MODE    TYPE TDSFAMODE
                               PROTECT     TYPE TDSFFLAG
                               IGNORE      TYPE TDSFFLAG
                               INPUTFIELDS TYPE TSFINPUT
                               TEXTAREA    TYPE SSFTXTAREA.

DATA: LANGU        TYPE SPRAS,
      L_TOKEN      TYPE TSFTOKEN,
      L_LANGUAGES  TYPE SSFRLANG,
      L_XSF_STATUS TYPE SSFXSF.

  CALL FUNCTION 'SSFRT_READ_INCLUDE_TEXT'
       EXPORTING  I_TEXTKEY   = TEXTKEY
                  I_LANGUAGES = %LANGUAGES
       IMPORTING  O_LANGU     = LANGU
                  O_TEXT      = %TEXT
       EXCEPTIONS OTHERS      = 1.
  IF SY-SUBRC <> 0.
    SFSY-SUBRC = 4.
      CALL FUNCTION 'SSFRT_SET_ERROR_PARAMETERS'
        EXPORTING I_FORM      = 'ZLABEL_001'.
    IF IGNORE = SPACE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_INCLUDE_TEXT_NOT_FOUND
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'E'
                  I_MSGNO     = '610'
                  I_MSGV1     = TEXTKEY-NAME
                  I_MSGV2     = TEXTKEY-OBJECT
                  I_MSGV3     = TEXTKEY-ID.
      PERFORM RESET_ALL IN PROGRAM SAPLSTXBC.
      RAISE ERROR.
    ELSE.
      CALL FUNCTION 'SSFRT_WRITE_ERROR'
        EXPORTING I_ERRNUMBER = SSF_ERR_INCLUDE_TEXT_NOT_FOUND
                  I_MSGID     = 'SSFCOMPOSER'
                  I_MSGTY     = 'W'
                  I_MSGNO     = '610'
                  I_MSGV1     = TEXTKEY-NAME
                  I_MSGV2     = TEXTKEY-OBJECT
                  I_MSGV3     = TEXTKEY-ID.
      PERFORM XSF_IS_ACTIVE IN PROGRAM SAPLSTXBC
              CHANGING L_XSF_STATUS.
      IF L_XSF_STATUS = 'X' AND TEXTAREA-ENABLED = 'A'.
        SFSY-SUBRC = 0.
        CALL FUNCTION 'SSFRT_ADD_LANGUAGE'
          EXPORTING  I_LANG       = TEXTKEY-LANG
                     I_LANGUAGES  = %LANGUAGES
          IMPORTING  O_LANGUAGES  = L_LANGUAGES.
        CALL FUNCTION 'SSFRT_XSF_DUMMY_TEXT'
          EXPORTING  I_LANGUAGES = L_LANGUAGES
          IMPORTING  O_LANGU     = LANGU
                     O_TEXT      = %TEXT.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
  ELSE.
    SFSY-SUBRC = 0.
  ENDIF.
  CALL FUNCTION 'SSFCOMP_CONVERT_ITF_TO_TOKEN'
       EXPORTING I_NAME     = NAME
                 I_TEXT     = %TEXT
                 I_TEXTNAME = SPACE
                 I_TEXTTYPE = 'I'
                 I_LANGU    = LANGU
       IMPORTING E_TOKEN = L_TOKEN.
  CALL FUNCTION 'SSFCOMP_WRITE_TEXT'
       EXPORTING  NAME              = NAME
                  LANGU             = LANGU
                  STYLE             = STYLE
                  STYLEVARI         = STYLEVARI
                  TEXT              = L_TOKEN
                  TEXTTYPE          = 'I'
                  APPEND_MODE       = APP_MODE
                  PROTECT           = PROTECT
                  INPUTFIELDS       = INPUTFIELDS
                  TEXTAREA          = TEXTAREA
       EXCEPTIONS NON_MAIN_OVERFLOW = 1
                  OTHERS            = 2.
  CASE SY-SUBRC.
  WHEN 1.
    %WEXIT = 'X'.
  WHEN 2.
    RAISE ERROR.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %WRITE_DYNAMIC_TEXT
*----------------------------------------------------------------

FORM %WRITE_DYNAMIC_TEXT USING NAME        TYPE SSFKEYNAME
                               DYNTEXT     TYPE TSFTEXT
                               TLANG       TYPE SPRAS
                               STYLE       TYPE TDSSNAME
                               STYLEVARI   TYPE TDVARIANT
                               APP_MODE    TYPE TDSFAMODE
                               PROTECT     TYPE TDSFFLAG
                               INPUTFIELDS TYPE TSFINPUT
                               TEXTAREA    TYPE SSFTXTAREA.

DATA: L_TOKEN      TYPE TSFTOKEN.

  CALL FUNCTION 'SSFCOMP_CONVERT_ITF_TO_TOKEN'
       EXPORTING I_NAME     = NAME
                 I_TEXT     = DYNTEXT
                 I_TEXTNAME = SPACE
                 I_TEXTTYPE = 'D'
                 I_LANGU    = TLANG
       IMPORTING E_TOKEN    = L_TOKEN.
  CALL FUNCTION 'SSFCOMP_WRITE_TEXT'
       EXPORTING  NAME              = NAME
                  LANGU             = TLANG
                  STYLE             = STYLE
                  STYLEVARI         = STYLEVARI
                  TEXT              = L_TOKEN
                  TEXTTYPE          = 'D'
                  APPEND_MODE       = APP_MODE
                  PROTECT           = PROTECT
                  INPUTFIELDS       = INPUTFIELDS
                  TEXTAREA          = TEXTAREA
       EXCEPTIONS NON_MAIN_OVERFLOW = 1
                  OTHERS            = 2.
  CASE SY-SUBRC.
  WHEN 1.
    %WEXIT = 'X'.
  WHEN 2.
    RAISE ERROR.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %MOVE
*----------------------------------------------------------------

FORM %MOVE USING TARGET TYPE ANY
                 SOURCE TYPE ANY.

DATA: L_PROGRAM LIKE SY-REPID,
      L_TARGET(1000).

  IF SOURCE(1) = '&'.
    L_PROGRAM = SY-REPID.
    CALL FUNCTION 'SSFRT_SYMBOL_VALUE'
         EXPORTING  I_PROGRAM      = L_PROGRAM
                    I_SYMBOLNAME   = SOURCE
                    I_MOVE_LOGIC   = 'X'
         IMPORTING  O_SYMBOL_VALUE = L_TARGET
         EXCEPTIONS OTHERS         = 1.
    IF SY-SUBRC <> 0.
      PERFORM RESET_ALL IN PROGRAM SAPLSTXBC.
      RAISE ERROR.
    ENDIF.
    TARGET = L_TARGET.
  ELSE.
    TARGET = SOURCE.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------
*"  FORM %RAISE
*----------------------------------------------------------------

FORM %RAISE.

DATA: L_ERROR TYPE SSFERROR,
      L_EXIST(1).

  CALL FUNCTION 'SSFRT_READ_ERROR'
       IMPORTING  O_ERROR = L_ERROR
       EXCEPTIONS OTHERS  = 1.
  IF SY-SUBRC = 0 AND L_ERROR-MSGID <> SPACE.
    L_EXIST = 'X'.
  ENDIF.
  IF L_EXIST = SPACE.
    MESSAGE E003(SSFCOMPOSER) RAISING INTERNAL_ERROR.
  ENDIF.
  CASE L_ERROR-ERRNUMBER(2).
  WHEN '00'.
    MESSAGE ID     L_ERROR-MSGID
            TYPE   L_ERROR-MSGTY
            NUMBER L_ERROR-MSGNO
            WITH   L_ERROR-MSGV1 L_ERROR-MSGV2
                   L_ERROR-MSGV3 L_ERROR-MSGV4
            RAISING USER_CANCELED.
  WHEN '01'.
    MESSAGE ID     L_ERROR-MSGID
            TYPE   L_ERROR-MSGTY
            NUMBER L_ERROR-MSGNO
            WITH   L_ERROR-MSGV1 L_ERROR-MSGV2
                   L_ERROR-MSGV3 L_ERROR-MSGV4
            RAISING SEND_ERROR.
  WHEN '02'.
    MESSAGE ID     L_ERROR-MSGID
            TYPE   L_ERROR-MSGTY
            NUMBER L_ERROR-MSGNO
            WITH   L_ERROR-MSGV1 L_ERROR-MSGV2
                   L_ERROR-MSGV3 L_ERROR-MSGV4
            RAISING FORMATTING_ERROR.
  WHEN '03'.
    MESSAGE ID     L_ERROR-MSGID
            TYPE   L_ERROR-MSGTY
            NUMBER L_ERROR-MSGNO
            WITH   L_ERROR-MSGV1 L_ERROR-MSGV2
                   L_ERROR-MSGV3 L_ERROR-MSGV4
            RAISING INTERNAL_ERROR.
  ENDCASE.

ENDFORM.


*----------------------------------------------------------------
*   FORM %WI1
*   NODE %GRAPHIC3
*----------------------------------------------------------------

FORM %WI1.

CLEAR %WEXIT.
PERFORM %WI1_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI1

*----------------------------------------------------------------
*   FORM %WI1_BODY
*----------------------------------------------------------------

FORM %WI1_BODY.

CLEAR %GRAPHICKEY.
PERFORM %MOVE USING %GRAPHICKEY-TDNAME 'LOGO_ASTRIA_BW'.
PERFORM %MOVE USING %GRAPHICKEY-TDOBJECT 'GRAPHICS'.
PERFORM %MOVE USING %GRAPHICKEY-TDID 'BMAP'.
PERFORM %MOVE USING %GRAPHICKEY-TDBTYPE 'BMON'.
CALL FUNCTION 'SSFCOMP_PRINT_GRAPHIC'
     EXPORTING  BM_NAME           = %GRAPHICKEY-TDNAME
                BM_OBJECT         = %GRAPHICKEY-TDOBJECT
                BM_ID             = %GRAPHICKEY-TDID
                BM_TYPE           = %GRAPHICKEY-TDBTYPE
                BM_DPI            = '0300'
                BM_RESIDENT       = ' '
                BM_RELMODE        = 'W'
                BM_ALIGNMENT      = 'L'
                BM_MARGIN         = '0.00'
                BM_UMARGIN        = 'CM'
                BM_VALIGNMENT     = 'C'
                NAME              = '%GRAPHIC3'
     EXCEPTIONS NON_MAIN_OVERFLOW = 1
                OTHERS            = 2.
CASE SY-SUBRC.
WHEN 1.
  %WEXIT = 'X'.
WHEN 2.
  RAISE ERROR.
ENDCASE.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI1_BODY

*----------------------------------------------------------------
*   FORM %WI2
*   NODE MAIN
*----------------------------------------------------------------

FORM %WI2.

CLEAR %WEXIT.
PERFORM %WI2_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI2

*----------------------------------------------------------------
*   FORM %WI2_BODY
*----------------------------------------------------------------

FORM %WI2_BODY.


ENDFORM.                      " %WI2_BODY

*----------------------------------------------------------------
*   FORM %WI3
*   NODE BOPET
*----------------------------------------------------------------

FORM %WI3.

CLEAR %WEXIT.
PERFORM %WI3_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI3

*----------------------------------------------------------------
*   FORM %WI3_BODY
*----------------------------------------------------------------

FORM %WI3_BODY.

REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING '%TEXT6' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI3_BODY

*----------------------------------------------------------------
*   FORM %WI4
*   NODE CLEAR
*----------------------------------------------------------------

FORM %WI4.

CLEAR %WEXIT.
PERFORM %WI4_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI4

*----------------------------------------------------------------
*   FORM %WI4_BODY
*----------------------------------------------------------------

FORM %WI4_BODY.

REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING '%TEXT5' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI4_BODY

*----------------------------------------------------------------
*   FORM %WI5
*   NODE WIDTH
*----------------------------------------------------------------

FORM %WI5.

CLEAR %WEXIT.
PERFORM %WI5_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI5

*----------------------------------------------------------------
*   FORM %WI5_BODY
*----------------------------------------------------------------

FORM %WI5_BODY.

CLEAR %SECTION.
%SECTION-NAME = '%OUTATTRIB4'.
%SECTION-STYLE = 'ZLABEL_WIN'.
%SECTION-LANGU = %LANGUAGES-LANGU1.
CALL FUNCTION 'SSFCOMP_BEGIN_SECTION'
     EXPORTING  SECTION = %SECTION
     EXCEPTIONS OTHERS  = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_BEGIN'
     EXPORTING  I_DEFINITION = '%TEMPLATE1'
     EXCEPTIONS OTHERS       = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_XSF_BODY'
     EXPORTING  MODE   = %OPEN
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 001
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'TYPE' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'TWIDTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 002
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VWIDTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 003
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'UWIDTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 004
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VWIDTH2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 005
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'UWITH2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'TLENGTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 002
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VLENGTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 003
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'ULENGTH' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 004
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VLENGTH2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 005
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'ULENGTH2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'TWEIGHT' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 002
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VWEIGHT' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 003
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'UWEIGHT' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 004
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VWEIGHT2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 005
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'UWEIGHT2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_XSF_BODY'
     EXPORTING  MODE   = %CLOSE
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_END'
     EXCEPTIONS NON_MAIN_OVERFLOW = 1
                OTHERS            = 2.
CASE SY-SUBRC.
WHEN 1.
  %WEXIT = 'X'.
WHEN 2.
  RAISE ERROR.
ENDCASE.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_END_SECTION'
     EXCEPTIONS OTHERS  = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.

ENDFORM.                      " %WI5_BODY

*----------------------------------------------------------------
*   FORM %WI6
*   NODE INSIDE
*----------------------------------------------------------------

FORM %WI6.

CLEAR %WEXIT.
PERFORM %WI6_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI6

*----------------------------------------------------------------
*   FORM %WI6_BODY
*----------------------------------------------------------------

FORM %WI6_BODY.

CLEAR %SECTION.
%SECTION-NAME = '%OUTATTRIB18'.
%SECTION-STYLE = 'ZLABEL_WIN'.
%SECTION-LANGU = %LANGUAGES-LANGU1.
CALL FUNCTION 'SSFCOMP_BEGIN_SECTION'
     EXPORTING  SECTION = %SECTION
     EXCEPTIONS OTHERS  = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_BEGIN'
     EXPORTING  I_DEFINITION = '%TEMPLATE2'
     EXCEPTIONS OTHERS       = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_XSF_BODY'
     EXPORTING  MODE   = %OPEN
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 001
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'INSIDE' 'ZLABEL_WIN' SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 002
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'VINSIDE' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 003
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'CORE' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 004
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'THICK' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 005
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'EXPIRED' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_GOTO_CELL'
     EXPORTING  I_ROW  = 006
                I_COL  = 001
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING 'SONUM' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_XSF_BODY'
     EXPORTING  MODE   = %CLOSE
     EXCEPTIONS OTHERS = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.
CALL FUNCTION 'SSFCOMP_TABLE_END'
     EXCEPTIONS NON_MAIN_OVERFLOW = 1
                OTHERS            = 2.
CASE SY-SUBRC.
WHEN 1.
  %WEXIT = 'X'.
WHEN 2.
  RAISE ERROR.
ENDCASE.
IF %WEXIT <> SPACE. EXIT. ENDIF.
CALL FUNCTION 'SSFCOMP_END_SECTION'
     EXCEPTIONS OTHERS  = 1.
IF SY-SUBRC <> 0. RAISE ERROR. ENDIF.

ENDFORM.                      " %WI6_BODY

*----------------------------------------------------------------
*   FORM %WI7
*   NODE ROLNO
*----------------------------------------------------------------

FORM %WI7.

CLEAR %WEXIT.
PERFORM %WI7_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI7

*----------------------------------------------------------------
*   FORM %WI7_BODY
*----------------------------------------------------------------

FORM %WI7_BODY.

REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING '%TEXT4' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI7_BODY

*----------------------------------------------------------------
*   FORM %WI8
*   NODE BATCH
*----------------------------------------------------------------

FORM %WI8.

CLEAR %WEXIT.
PERFORM %WI8_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI8

*----------------------------------------------------------------
*   FORM %WI8_BODY
*----------------------------------------------------------------

FORM %WI8_BODY.

REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING '%TEXT1' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI8_BODY

*----------------------------------------------------------------
*   FORM %WI9
*   NODE BARCODE
*----------------------------------------------------------------

FORM %WI9.

CLEAR %WEXIT.
PERFORM %WI9_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI9

*----------------------------------------------------------------
*   FORM %WI9_BODY
*----------------------------------------------------------------

FORM %WI9_BODY.

REFRESH %INPUTFIELDS.
FILL_TEXTAREA 'F'  0  0 ' '.
PERFORM %WRITE_TEXT USING '%TEXT2' SPACE SPACE 'P' SPACE %INPUTFIELDS %TEXTAREA.
IF %WEXIT <> SPACE. EXIT. ENDIF.

ENDFORM.                      " %WI9_BODY

*----------------------------------------------------------------
*   FORM %WI10
*   NODE SPLICE
*----------------------------------------------------------------

FORM %WI10.

CLEAR %WEXIT.
PERFORM %WI10_BODY.
CLEAR %WEXIT.

ENDFORM.                      " %WI10

*----------------------------------------------------------------
*   FORM %WI10_BODY
*----------------------------------------------------------------

FORM %WI10_BODY.


ENDFORM.                      " %WI10_BODY
