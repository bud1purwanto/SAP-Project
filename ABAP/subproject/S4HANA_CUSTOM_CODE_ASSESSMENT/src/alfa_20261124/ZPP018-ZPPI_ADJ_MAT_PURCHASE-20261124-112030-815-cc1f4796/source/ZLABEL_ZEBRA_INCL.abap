*&---------------------------------------------------------------------*
*&  Include           ZLABEL_ZEBRA_INCL
*&---------------------------------------------------------------------*
DATA : LV_COMPNAME(100),
       LV_PRINTERNAME(100),
       LV_RETURNCODE TYPE I,
       LV_ISZEBRA TYPE I VALUE 0. "1 true, 0 false

DATA : BEGIN OF IT_ZPL OCCURS 0,
          COMMAND(150),
       END OF IT_ZPL.

DATA : IT_CHGEMU LIKE IT_ZPL OCCURS 0 WITH HEADER LINE,
       IT_PRINTZEBRA LIKE IT_ZPL OCCURS 0 WITH HEADER LINE.


*-----------------------------------------
*            For zebra printer
*-----------------------------------------
*Added By Fany 22.04.2024
*1) Enable printer share in control panel > devices and printers
*2) Get computer name

FORM GET_DESKTOP_INFO.
  CALL FUNCTION 'GUI_GET_DESKTOP_INFO'
    EXPORTING
      TYPE   = '1'
    CHANGING
      RETURN = LV_COMPNAME.
ENDFORM.                    "GET_DESKTOP_INFO
*&---------------------------------------------------------------------*
*&      Form  CHANGE_ZEBRA_EMULATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->EMUL       text
*----------------------------------------------------------------------*
FORM CHANGE_ZEBRA_EMULATION USING EMUL.
  DATA : LV_TEMP_EMUL_COMMAND(100).
  PERFORM GET_DESKTOP_INFO.
  LOOP AT IT_ZPL.
    IF SY-TABIX EQ 2.
      CONCATENATE '! U1 setvar "apl.enable" "'  EMUL '"' INTO LV_TEMP_EMUL_COMMAND.
      IT_ZPL-COMMAND = LV_TEMP_EMUL_COMMAND.
      MODIFY IT_ZPL.
    ENDIF.
  ENDLOOP.

* Update zebra.zpl
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME        = 'c:/tslabel/zebra.zpl'
      FILETYPE        = 'ASC'
    TABLES
      DATA_TAB        = IT_ZPL
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      FILE_READ_ERROR = 2
      OTHERS          = 3.

  REFRESH IT_CHGEMU.
  CONCATENATE 'COPY /B c:\tslabel\zebra.zpl \\' LV_COMPNAME '\' LV_PRINTERNAME INTO IT_CHGEMU-COMMAND.
  APPEND IT_CHGEMU TO IT_CHGEMU.


*Update CHANGE_EMULATION_ZEBRA.bat
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME        = 'c:/tslabel/CHANGE_EMULATION_ZEBRA.BAT'
      FILETYPE        = 'ASC'
    TABLES
      DATA_TAB        = IT_CHGEMU
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      FILE_READ_ERROR = 2
      OTHERS          = 3.

* Execute change emulation
  CALL FUNCTION 'GUI_RUN'
    EXPORTING
      COMMAND    = 'CHANGE_EMULATION_ZEBRA.BAT'
      CD         = 'C:\tslabel\'
    IMPORTING
      RETURNCODE = LV_RETURNCODE.

  IF LV_RETURNCODE <> 0.
    MESSAGE I000(0K) WITH 'Change Emulation Error'.
    STOP.
  ENDIF.
  WAIT UP TO 1 SECONDS.

ENDFORM.                    "CHANGE_ZEBRA_EMULATION

*&---------------------------------------------------------------------*
*&      Form  PRINT_ZEBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_ZEBRA_RETURNCODES  text
*----------------------------------------------------------------------*
FORM PRINT_ZEBRA CHANGING V_ZEBRA_RETURNCODES.
* Execute print label
  CONCATENATE 'COPY /B c:\tslabel\DATA.DAX \\' LV_COMPNAME '\' LV_PRINTERNAME INTO IT_PRINTZEBRA-COMMAND.
  REFRESH IT_PRINTZEBRA.
  APPEND  IT_PRINTZEBRA TO IT_PRINTZEBRA.

  PERFORM CLEAR_ZEBRA.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME        = 'c:/tslabel/PRINT_ZEBRA.BAT'
      FILETYPE        = 'ASC'
    TABLES
      DATA_TAB        = IT_PRINTZEBRA
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      FILE_READ_ERROR = 2
      OTHERS          = 3.

  CLEAR LV_RETURNCODE.

  CALL FUNCTION 'GUI_RUN'
    EXPORTING
      COMMAND    = 'PRINT_ZEBRA.BAT'
      CD         = 'C:\tslabel\'
    IMPORTING
      RETURNCODE = LV_RETURNCODE.

  V_ZEBRA_RETURNCODES = LV_RETURNCODE.
ENDFORM.                    "PRINT_ZEBRA

*&---------------------------------------------------------------------*
*&      Form  CHECK_USING_ZEBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_USING_ZEBRA CHANGING V_IS_USING_ZEBRA.
  REFRESH IT_ZPL.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME        = 'c:/tslabel/zebra.zpl'
      FILETYPE        = 'ASC'
    TABLES
      DATA_TAB        = IT_ZPL
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      FILE_READ_ERROR = 2
      OTHERS          = 3.

  IF SY-SUBRC EQ 0 .
    V_IS_USING_ZEBRA = 'X'.
    LOOP AT IT_ZPL.
      IF SY-TABIX EQ 3.
        LV_PRINTERNAME = IT_ZPL-COMMAND+18.
        CONDENSE LV_PRINTERNAME.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "CHECK_USING_ZEBRA

FORM CLEAR_ZEBRA .
  CLEAR LV_RETURNCODE.
  CALL FUNCTION 'GUI_RUN'
    EXPORTING
      COMMAND    = 'CLEAR_ZEBRA.BAT'
      CD         = 'C:\tslabel\'
    IMPORTING
      RETURNCODE = LV_RETURNCODE.
ENDFORM.

*-----------------------------------------
*            End zebra printer
*-----------------------------------------