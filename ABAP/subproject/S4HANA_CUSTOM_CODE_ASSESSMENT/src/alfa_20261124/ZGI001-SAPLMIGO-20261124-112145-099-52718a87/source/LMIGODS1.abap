*----------------------------------------------------------------------*
*   INCLUDE LMIGODS1                                                   *
*   detail tabstrip serial numbers definition                          *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_serial_numbers DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    pbo_loop,
    pbo REDEFINITION,
    pai_loop,
    pai_after_loop,
      pbo_show_inv,                                              "637093
      cursor_position_resolve REDEFINITION.

  PRIVATE SECTION.
    DATA: p_lines TYPE sy-tabix,       "for exit from step-loop
          p_loopc TYPE sy-loopc,
          pt_iseg_buffer TYPE TABLE OF iseg,                     "637093
          p_old_mblnr TYPE mseg-mblnr,                           "637093
          p_old_mjahr TYPE mseg-mjahr,                           "637093
          lt_goserial TYPE lcl_migo_kernel=>ty_t_goserial.  "400986

   METHODS: tableview_serial_cursor,
            tableview_serial_line_get,
            tableview_serial_line_set,
            tableview_serial_mod_button,
            tableview_serial_modify,
            tableview_serial_size,
             tableview_serial_table_prepare,
             serial_join,                                   "400986
             serial_search,                                 "400986
             serial_show_inv,                                    "637093
             serial_ref.                                    "688602





ENDCLASS.