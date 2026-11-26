*----------------------------------------------------------------------*
* Report  ZPPI_GCHART_PR_JR                                            *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Gantchart report                                        *
*                                                                      *
* Specification - pp                                                   *
* Abaper        - Bagus aditya putra (bap)                             *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

INCLUDE ZPPI_GCHART_PR_JRTOP.
INCLUDE ZPPI_GCHART_PR_JRF01.

START-OF-SELECTION.
PERFORM GET_DATA.
PERFORM REPORT.