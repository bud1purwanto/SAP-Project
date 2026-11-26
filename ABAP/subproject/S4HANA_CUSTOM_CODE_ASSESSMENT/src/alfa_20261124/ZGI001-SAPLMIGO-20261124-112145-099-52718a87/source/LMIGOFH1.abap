*&---------------------------------------------------------------------*
*   Include           LMIGOFH1                                         *
*   Own F4-helps for the Batch and Vendor_Batch                                                      *
*&---------------------------------------------------------------------*
CLASS lcl_migo_field_help DEFINITION.
  PUBLIC SECTION.
    METHODS:
      f4_help_field.

  PRIVATE SECTION.
    METHODS:
      f4_help_charg IMPORTING iv_line TYPE sy-stepl,

      f4_help_licha IMPORTING iv_line TYPE sy-stepl.




ENDCLASS.                    "lcl_migo_field_help DEFINITION