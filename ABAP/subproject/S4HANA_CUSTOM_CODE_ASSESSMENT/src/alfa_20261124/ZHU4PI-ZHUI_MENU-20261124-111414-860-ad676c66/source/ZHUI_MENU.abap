*----------------------------------------------------------------------*
* Report   ZHUI_MENU                                                   *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: HU - Menu Packing Processes                             *
*                                                                      *
* Specification - MM                                                   *
* Abaper        - Bagus Aditya Putra                                   *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

REPORT  ZHUI_MENU.

DATA : FLAG_START VALUE 'X'.

SELECTION-SCREEN: SKIP,
BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-100,
                  BEGIN OF LINE.
PARAMETERS:     BUT1  RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN: POSITION 4, COMMENT (45) TEXT-110,
                  POSITION 30.
SELECTION-SCREEN: END OF LINE,
                  BEGIN OF LINE.
PARAMETERS:     BUT2 RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN: POSITION 4, COMMENT (50) TEXT-120,
                  END OF LINE,
END OF BLOCK BLOCK1.

START-OF-SELECTION.
FREE MEMORY ID 'ZHUI'.
IF BUT1 = 'X'.
  EXPORT FLAG_START TO MEMORY ID 'ZHUI'.
  CALL TRANSACTION 'ZHU4SO'.
ELSEIF BUT2 = 'X'.
  EXPORT FLAG_START TO MEMORY ID 'ZHUI'.
  CALL TRANSACTION 'ZHU4FS'.
ENDIF.