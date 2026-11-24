* Report  ZPPI_JR_EXEC
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Report Jumbo Roll
* Application Area - PP
* ABAPer           - Jeffri Pranata
* Date             - 6 Agustus, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 06.08.12 | Jeffri      |            | Program created          *
*----------------------------------------------------------------------*
* 002 | 19.09.12 | Jeffri      |            | Program finished         *
*----------------------------------------------------------------------*

REPORT ZPPI_JR_EXEC.
INCLUDE Z_PROG_INFO.             "Program Documentation
INCLUDE ZPPI_JR_EXEC_TOP." GLOBAL DATA
INCLUDE ZABAPALV.
INCLUDE ZPPI_JR_EXEC_F01." FORM-Routines
INCLUDE ZPPI_JR_EXEC_LYT." LAYOUT
INCLUDE ZPPI_JR_EXEC_FTE." Function Front End
*INCLUDE BDCRECX1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ARBPL-LOW.
  PERFORM GET_RSC CHANGING SO_ARBPL-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ARBPL-HIGH.
  PERFORM GET_RSC CHANGING SO_ARBPL-HIGH.

INITIALIZATION.
  PERFORM SBU.

  TXT1 = 'Resources'.
  TXT2 = 'Periode'.
  MOVE 'Program Information' TO INFO. "DOCUMENTATION

  "DOCUMENTATION*************************

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.
*  *************************************

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM SET_ALV.

END-OF-SELECTION.