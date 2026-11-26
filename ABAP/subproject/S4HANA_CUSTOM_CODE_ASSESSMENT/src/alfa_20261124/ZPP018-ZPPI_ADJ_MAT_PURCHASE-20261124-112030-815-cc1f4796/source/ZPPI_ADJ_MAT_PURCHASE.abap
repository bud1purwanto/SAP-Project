*----------------------------------------------------------------------*
* Report  ZPPI_SR_PROCESS
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Adjustment Material Purchase
*
* Application Area - PP
* ABAPer           - William
* Date             - November, 27 2012
*----------------------------------------------------------------------*
* Amendment History                                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
* 002 | 20.11.19 | Fathir      |            | Insert GI/GR data to AGS (TTE Only)
*----------------------------------------------------------------------*

INCLUDE ZPPI_ADJ_MAT_PURCHASE_TOP                    .  " Global Data

INCLUDE ZPPI_ADJ_MAT_PURCHASE_O01                    .  " PBO-Modules
INCLUDE ZPPI_ADJ_MAT_PURCHASE_I01                    .  " PAI-Modules
INCLUDE ZPPI_ADJ_MAT_PURCHASE_F01                    .  " FORM-Routines

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mblnr-low.
  PERFORM f4_mblnr USING 'LOW'.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mblnr-high.
  PERFORM f4_mblnr USING 'HIGH'.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_nik-low.
  PERFORM f4_nik USING 'SO_NIK-LOW'.

AT SELECTION-SCREEN OUTPUT.
  CLEAR: flagmjahr.
  IF sy-dynnr = 7110.
    IF so_mjahr[] IS INITIAL.
      flagmjahr = 'X'.
      so_mjahr-low = sy-datum+0(4).
      APPEND so_mjahr.
    ENDIF.
    PERFORM MODIFY_SCREEN_7110.
  ENDIF.

START-OF-SELECTION.
  CALL SCREEN 7000.