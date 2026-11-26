*&---------------------------------------------------------------------*
*&  Include           LMIGOO01
*&---------------------------------------------------------------------*
*&      Module  convert_number  OUTPUT
*&---------------------------------------------------------------------*

MODULE convert_number OUTPUT.

  DATA cl_change TYPE REF TO /sappspro/cl_numbers.
  DATA lf_active TYPE boolean.

  CLEAR: lf_active.
  CREATE OBJECT cl_change.

  CALL METHOD cl_change->is_active
    RECEIVING
      rv_active = lf_active.

  IF lf_active = 'X'.
    TRY.
        goitem-longnum =
        /sappspro/cl_numbers=>lookup( goitem-ebeln ).
      CATCH /sappspro/cx_number_not_found.
*             number does not exist.
    ENDTRY.
  ENDIF.


ENDMODULE.                 " convert_number  OUTPUT