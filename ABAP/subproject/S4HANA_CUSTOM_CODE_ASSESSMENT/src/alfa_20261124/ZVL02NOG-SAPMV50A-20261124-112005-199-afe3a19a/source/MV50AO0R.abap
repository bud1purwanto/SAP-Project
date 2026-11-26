*----------------------------------------------------------------------*
***INCLUDE MV50AO0R .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  REFERENCE_OUTB_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
MODULE REFERENCE_OUTB_PREPARE OUTPUT.

  CALL FUNCTION 'SHP_LIPSRF_MAINTAIN_PREP'
       EXPORTING
            IF_HANDLE_OBJ = LIKP-HANDLE
            IF_HANDLE     = LIPS-HANDLE
            IF_TRTYP      = T180-TRTYP
       EXCEPTIONS
            NO_DISPLAY    = 1
            OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                             " REFERENCE_OUTB_PREPARE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  REFERENCE_INB_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
MODULE REFERENCE_INB_PREPARE OUTPUT.

  CALL FUNCTION 'SHP_LIPSPO_MAINTAIN_PREP'
       EXPORTING
            IF_HANDLE_OBJ = LIKP-HANDLE
            IF_HANDLE     = LIPS-HANDLE
            IF_TRTYP      = T180-TRTYP
       EXCEPTIONS
            NO_DISPLAY    = 1
            OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                             " REFERENCE_INB_PREPARE  OUTPUT
