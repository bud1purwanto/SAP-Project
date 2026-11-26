************************************************************************
*                                                                      *
* PBO Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "L" beginnend             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*     Lieferung ohne Auftrag vorbereiten                              *
*---------------------------------------------------------------------*
MODULE LIEF_O_AUFT_INIT OUTPUT.
  PERFORM LIEF_O_AUFT_INIT.
ENDMODULE.
*eject

*&---------------------------------------------------------------------*
*&      Module  LIPS_WORKAREA_SELECT  OUTPUT
*&---------------------------------------------------------------------*
* The work areas LIPS/XLIPS of the item to be displayed and processed on
* the detail screen must be set. SLIPS-TABIX may not be correct if
* detail screen is accessed from batch split screen -> set to
* ILIPS-TABIX
*---------------------------------------------------------------------*
MODULE LIPS_WORKAREA_SELECT OUTPUT.

  CASE TAXI_SCREEN_GROUP(1).
    WHEN C_TAXI_SCRGRP_ITEM(1).
      LIPS  = GS_LIPS_MAIN.
      XLIPS = GS_XLIPS_MAIN.
      ILIPS = GS_ILIPS_MAIN.
      SLIPS-TABIX = ILIPS-TABIX.
    WHEN C_TAXI_SCRGRP_BATCH(1).
      LIPS  = GS_LIPS_CHSP.
      XLIPS = GS_XLIPS_CHSP.
      ILIPS = GS_ILIPS_CHSP.
      SLIPS-TABIX = ILIPS-TABIX.
  ENDCASE.

ENDMODULE.                             " LIPS_WORKAREA_SELECT  OUTPUT

ENHANCEMENT-POINT MV50AO0L_01 SPOTS ES_SAPMV50A STATIC .