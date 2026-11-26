*&---------------------------------------------------------------------*
*&  Include           LMIGODR4
*&---------------------------------------------------------------------*
CLASS lcl_migo_detail_ga IMPLEMENTATION.

*----------------------------------------------------------------------*
* METHOD CONSTRUCTOR
*----------------------------------------------------------------------*
  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

  ENDMETHOD.                    "constructor
*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
  METHOD pbo.
    CALL METHOD super->pbo.
  ENDMETHOD.                    "pbo

*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
  METHOD pai.
    CALL METHOD super->pai.
*   transfer fcode
    CALL FUNCTION 'WMMB_MATRIX_FCODE'
       EXPORTING
           fcode = okcode.
    IF g_tablev_current_dyn = '0201'.
      PERFORM CTMX_OK_CODE IN PROGRAM SAPLWMMB.
    ENDIF.
    CALL METHOD lcl_migo_globals=>kernel->ga_variants_pai
      EXPORTING i_line = oref_detail->current_line.
  ENDMETHOD.                    "pai

*----------------------------------------------------------------------*
* Interface
*----------------------------------------------------------------------*

  METHOD lif_migo_frame~okcode_handler.
* call method...
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler


ENDCLASS.                    "lcl_migo_detail_ga IMPLEMENTATION