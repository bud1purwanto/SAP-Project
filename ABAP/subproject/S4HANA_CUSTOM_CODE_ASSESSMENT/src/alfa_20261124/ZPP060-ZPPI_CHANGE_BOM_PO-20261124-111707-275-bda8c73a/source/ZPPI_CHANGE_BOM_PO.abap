*----------------------------------------------------------------------*
*          ZPPI_CHANGE_BOM_PO                                          *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description:  Change Goods Movement Jumbo ROll                       *
*                                                                      *
* Specification - PP                                                   *
* Abaper        - Bagus Aditya Putra ^^                                *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* 1     19 okt 12  bagus        - upload & download tidak lagi di screen
*                                 100 di pindah ke screen alv          *
*                               - report cogi sampai dengan sekarang   *
*                                 di hide dulu                         *
*                               - penambahan field di report           *
* 2   | 1 NOV 12  | bap        | perhitungan formula & proses gr       *
* 3   | 21 nop 12 | bap        | material yang di gi dan field xabln   *
* 4   | 27 nop 12 | bap        | @#$%^&*()(*&%$  ????????????????      *
* 5   | 7 jan 12  | bap        | download ke excel disamain ke bom     *
*----------------------------------------------------------------------*


INCLUDE ZPPI_CHANGE_BOM_PO_TOP                  .    " global Data
INCLUDE ZPPI_CHANGE_BOM_PO_F01                  .  " FORM-Routines

INCLUDE ZPPI_CHANGE_BOM_PO_PBO .
INCLUDE ZPPI_CHANGE_BOM_PO_PAI .
INCLUDE ZPPI_CHANGE_BOM_PO_F02 .

START-OF-SELECTION.

  PERFORM GETZ_DATA USING SY-UCOMM.
  PERFORM ALV.

END-OF-SELECTION.