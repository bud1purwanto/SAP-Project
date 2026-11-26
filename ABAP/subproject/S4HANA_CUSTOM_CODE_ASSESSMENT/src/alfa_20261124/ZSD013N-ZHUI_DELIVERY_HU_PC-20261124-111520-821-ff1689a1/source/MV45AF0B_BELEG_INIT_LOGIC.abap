*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_BELEG_INIT_LOGIC
*&---------------------------------------------------------------------*

form beleg_init_logic.

  cl_logic_access=>initialize( ).
  clear gr_logic_vbak.
  clear gr_logic_vbap.

endform.