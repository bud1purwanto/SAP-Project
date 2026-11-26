*----------------------------------------------------------------------*
* Report  ZPPI_DL_PO_JR                                                *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Download Process order Jumbo roll                       *
*                                                                      *
* Specification - pp                                                   *
* Abaper        - B.A.P                                                *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* 01  | 31.10.12 | Bagus Aditya| alv grid => alv hierarchi
*----------------------------------------------------------------------*

INCLUDE ZPPI_DL_PO_JRTOP.

INCLUDE ZPPI_DL_PO_JRF01.
INCLUDE ZPPI_DL_PO_JRF02.

INITIALIZATION.
TEXT  = 'Selection Screen'.
TEXT1 = 'Created'.
TEXT2 = 'In Progress'.
TEXT3 = 'Completed'.
TEXT4 = 'Teco '.

START-OF-SELECTION.
PERFORM CHECK_STATUS.
PERFORM GET_DATA.
*PERFORM ALV.  "-> REF1 (alv grid with dialog box)
PERFORM ALV_HIE.