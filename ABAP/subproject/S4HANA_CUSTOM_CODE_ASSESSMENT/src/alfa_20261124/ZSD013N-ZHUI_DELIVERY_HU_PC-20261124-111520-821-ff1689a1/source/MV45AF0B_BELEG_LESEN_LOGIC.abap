*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_BELEG_LESEN_LOGIC
*&---------------------------------------------------------------------*

form beleg_lesen_logic.

  data: ls_pkey type tds_vbeln.
  data: ls_object_class type tds_object_class,
        lt_object_class type tdt_object_class.


  ls_object_class-object_id = 'VBAP'.
  ls_object_class-class_name = 'CL_LOGIC_VBAP'.
  append ls_object_class to lt_object_class.
  ls_object_class-object_id = 'VBAK'.
  ls_object_class-class_name = 'CL_LOGIC_VBAK'.
  append ls_object_class to lt_object_class.

  cl_logic_access=>set_object_class( exporting it_object_class = lt_object_class ).

  ls_pkey-vbeln = vbak-vbeln.

  call method cl_logic_access=>get_object
    exporting
      iv_object_id   = 'VBAK'
      is_pkey        = ls_pkey
      if_with_load   = 'X'
    importing
      er_object      = gr_logic_vbak.

  call method cl_logic_access=>get_object
    exporting
      iv_object_id   = 'VBAP'
      is_pkey        = ls_pkey
      if_with_load   = 'X'
    importing
      er_object      = gr_logic_vbap.

endform.                    "beleg_lesen_logic