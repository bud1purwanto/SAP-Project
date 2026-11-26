*----------------------------------------------------------------------*
*   INCLUDE MV45AO0X_XVBEPDG_LESEN                                     *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  XVBEPDG_LESEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
         MODULE XVBEPDG_LESEN OUTPUT.

           DATA: I_VBEPDG_WA LIKE VBEPDG.
           CLEAR I_VBEPDG_WA.

           CALL FUNCTION 'SD_VBEPDG_DYNPRO_FIELDS_GET'
                EXPORTING
                     I_TRTYP     = T180-TRTYP
                     IMVBAK      = VBAK
                     IMVBEP      = VBEP
                IMPORTING
                     E_VBEPDG_WA = I_VBEPDG_WA
                EXCEPTIONS
                     OTHERS      = 10.


         ENDMODULE.                    " XVBEPDG_LESEN  OUTPUT