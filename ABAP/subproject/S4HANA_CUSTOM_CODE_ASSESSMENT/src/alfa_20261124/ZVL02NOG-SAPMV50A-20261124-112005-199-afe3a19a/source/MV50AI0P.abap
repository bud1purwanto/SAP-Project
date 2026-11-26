************************************************************************
*                                                                      *
* PAI Module Lieferscheinbearbeitung                                   *
*     Module alphabetisch geordnet; hier mit "P" beginnend             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       MODULE PICKMENGE_BEARBEITEN                                   *
*---------------------------------------------------------------------*
*       bei Eingabe einer Pickmenge wird der Fluß entsprechend        *
*       verändert                                                     *
*---------------------------------------------------------------------*
MODULE PICKMENGE_BEARBEITEN.

  PERFORM PICKMENGE_BEARBEITEN(SAPFV50P).

ENDMODULE.
*eject

*&---------------------------------------------------------------------*
*&      Module  PODAT_PRUFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PODAT_PRUFEN INPUT.

  PERFORM PODAT_PRUEFEN.

ENDMODULE.                             " PODAT_PRUFEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  POTIM_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POTIM_PRUEFEN INPUT.

  PERFORM POTIM_PRUEFEN.

ENDMODULE.                             " POTIM_PRUEFEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_PASS_FCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRICING_PASS_FCODE INPUT.

  PERFORM TRANSFORM_DOUBLECLICK CHANGING FCODE.
  CALL FUNCTION 'PRICING_PASS_FCODE'
       EXPORTING
            OKCODE = FCODE.

ENDMODULE.                             " PRICING_PASS_FCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRICING_GET_FCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRICING_GET_FCODE INPUT.

  CALL FUNCTION 'PRICING_FETCH_FCODE'
       IMPORTING
            OKCODE = FCODE.

  IF FCODE IS INITIAL.
    FCODE = FCODE_GLEICHE_SEITE.
  ENDIF.

ENDMODULE.                             " PRICING_GET_FCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRICING_SUBSCREEN_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRICING_SUBSCREEN_GET_DATA INPUT.

  PERFORM PRICING_SUBSCREEN_GET_DATA.

ENDMODULE.                 " PRICING_SUBSCREEN_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  PARTNER_FCODE_PASS  INPUT
*&---------------------------------------------------------------------*
MODULE PARTNER_FCODE_PASS INPUT.

  PERFORM PARTNER_FCODE_PASS.

ENDMODULE.                             " PARTNER_FCODE_PASS  INPUT
*&---------------------------------------------------------------------*
*&      Module  PARTNER_FCODE_GET  INPUT
*&---------------------------------------------------------------------*
MODULE PARTNER_FCODE_GET INPUT.

  PERFORM PARTNER_FCODE_GET.

ENDMODULE.                             " PARTNER_FCODE_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  PARTNER_SCREEN_PROCESSING  INPUT
*&---------------------------------------------------------------------*
MODULE PARTNER_SCREEN_PROCESSING INPUT.

  PERFORM PARTNER_SCREEN_PROCESSING.

ENDMODULE.                 " PARTNER_SCREEN_PROCESSING  INPUT
*&---------------------------------------------------------------------*
*&      Module  POD_SEGMENT_LESEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POD_SEGMENT_LESEN INPUT.

  PERFORM POD_SEGMENT_LESEN.

ENDMODULE.                             " POD_SEGMENT_LESEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  POD_DATEN_UEBERNAHME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POD_DATEN_UEBERNAHME INPUT.

  TVPODVB-HANDLE_LIPS = LIPS-HANDLE.
  PERFORM POD_DATEN_UEBERNAHME(SAPFV50P) USING TVPODVB.

ENDMODULE.                             " POD_DATEN_UEBERNAHME  INPUT

*&---------------------------------------------------------------------*
*&      Module  POD_DATEN_UPDATE  INPUT
*&---------------------------------------------------------------------*
*       Insert, delete, update of TVPOD
*----------------------------------------------------------------------*
MODULE POD_DATEN_UPDATE INPUT.

  PERFORM POD_DATEN_UPDATE.

ENDMODULE.                             " POD_DATEN_UPDATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  POD_DATEN_UEBERNA_DETAIL  INPUT
*&---------------------------------------------------------------------*
*       Take over POD Data from detail screen
*----------------------------------------------------------------------*
MODULE POD_DATEN_UEBERNA_DETAIL INPUT.

  TVPODVB-HANDLE_LIPS = LIPS-HANDLE.
  PERFORM POD_DATEN_UEBERNA_DET(SAPFV50P) USING TVPODVB.

ENDMODULE.                             " POD_DATEN_UEBERNA_DETAIL  INPUT
*&---------------------------------------------------------------------*
*&      Module  POD_DATEN_UPDATE_DETAIL  INPUT
*&---------------------------------------------------------------------*
*       Insert, delete, append GT_TVPOD on detail screen
*----------------------------------------------------------------------*
MODULE POD_DATEN_UPDATE_DETAIL INPUT.

  PERFORM POD_DATEN_UPDATE_DETAIL.

ENDMODULE.                             " POD_DATEN_UPDATE_DETAIL  INPUT

*&---------------------------------------------------------------------*
*&      Module  PROCESS_DEADLINE_SCREEN  INPUT
*&---------------------------------------------------------------------*
MODULE PROCESS_DEADLINE_SCREEN INPUT.

  PERFORM PROCESS_DEADLINE_SCREEN.

ENDMODULE.                             " PROCESS_DEADLINE_SCREEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  POD_ERROR_MESSAGE  INPUT
*&---------------------------------------------------------------------*
*       POD Error handling
*----------------------------------------------------------------------*
MODULE POD_ERROR_MESSAGE INPUT.
  IF NOT GF_ERROR_POD IS INITIAL.
    PERFORM POD_MESSAGE_HANDLING USING GF_ERROR_POD T185V-PANEL.
  ENDIF.

ENDMODULE.                             " POD_ERROR_MESSAGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  POD_CONFIRM  INPUT
*&---------------------------------------------------------------------*
*       Confirmation or reversal of POD
*----------------------------------------------------------------------*
MODULE POD_CONFIRM INPUT.

  PERFORM POD_CONFIRM(SAPMV50A).

ENDMODULE.                             " POD_CONFIRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRICING_PROCESS_HEAD  INPUT
*&---------------------------------------------------------------------*
*       Process pricing data from the header screen for conditions
*----------------------------------------------------------------------*
MODULE PRICING_PROCESS_HEAD INPUT.

  PERFORM PRICING_PROCESS_HEAD.

ENDMODULE.                             " PRICING_PROCESS_HEAD  INPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_PROCESS_ITEM  INPUT
*&---------------------------------------------------------------------*
*       Process pricing data from the item screen for conditions
*----------------------------------------------------------------------*
MODULE PRICING_PROCESS_ITEM INPUT.

  PERFORM PRICING_PROCESS_ITEM.

ENDMODULE.                             " PRICING_PROCESS_ITEM  INPUT

*&---------------------------------------------------------------------*
*&      Module  POD_INBOUND_DATA_PROCESSING  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POD_INBOUND_DATA_PROCESSING INPUT.

  CHECK NOT LIKP-VBTYP CA VBTYP_LIEF.
  IF NOT LIPS-KZPOD IS INITIAL.
    PERFORM LIPS-LFIMG_PRUEFEN(SAPFV50P) USING '6789'.
  ENDIF.
* Teil-WE
  PERFORM LIPS-LFIMG_PRUEFEN(SAPFV50P) USING 'b'.

  PERFORM POD_INBOUND_DATA_PROCESSING.

ENDMODULE.                 " POD_INBOUND_DATA_PROCESSING  INPUT
*&---------------------------------------------------------------------*
*&      Module  POD_STATUS_MAINTAIN  INPUT
*&---------------------------------------------------------------------*
*       Maintains POD status
*----------------------------------------------------------------------*
MODULE POD_STATUS_MAINTAIN INPUT.                            "v_n_569399

  PERFORM POD_STATUS_MAINTAIN.

ENDMODULE.                 " POD_STATUS_MAINTAIN  INPUT       ^_n_569399