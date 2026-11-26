*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_ADD_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  status_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '9000'.

*  zpack_pch-pinst = c_pinst_completed.
  DATA S_TCODE LIKE SY-TCODE.
  DATA S_PINS  TYPE ZPINNR.
  GET PARAMETER ID 'TSOURCE' FIELD S_TCODE.

  IF S_TCODE = 'ZHU4SO' OR S_TCODE = 'ZAHU4SO'.
     GET PARAMETER ID 'AUN' FIELD ZPACK_PCH-VBELN.
     GET PARAMETER ID 'ZSOIT' FIELD ZPACK_PCH-POSNR.
  ENDIF.
  IF S_TCODE = 'ZHU4SO' OR S_TCODE = 'ZHU4FS' OR S_TCODE = 'ZAHU4SO' OR S_TCODE = 'ZAHU4FS' .
    GET PARAMETER ID 'ZPI' FIELD S_PINS.
    ZPACK_PCH-PINNR = S_PINS.

    LOOP AT SCREEN.
      IF SCREEN-NAME = 'ZPACK_PCH-PINNR' OR
         SCREEN-NAME = 'ZPACK_PCH-VBELN' OR
         SCREEN-NAME = 'ZPACK_PCH-POSNR'.

        SCREEN-INPUT = '0'.
      ELSE.
        SCREEN-INPUT = '1'.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " status_9000  OUTPUT