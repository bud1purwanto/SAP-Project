*----------------------------------------------------------------------*
* Report  ZPPI_UP_REV_PR_JR                                            *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Upload revisi process order jumbo roll                  *
*                                                                      *
* Specification - pp                                                   *
* Abaper        - Bagus aditya putra (bap)                             *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

INCLUDE ZPPI_UP_REV_PR_JR_TOP.
INCLUDE ZPPI_UP_REV_PR_JR_F01.

START-OF-SELECTION.
  PERFORM UPLOAD.
  PERFORM RECORD.
END-OF-SELECTION.