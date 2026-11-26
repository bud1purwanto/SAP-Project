*----------------------------------------------------------------------*
*   INCLUDE LMIGOSP1                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_split_quantity DEFINITION
      INHERITING FROM lcl_migo_screenobject.


  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pbo_loop,
      pai_exit,
      pai_loop,
      pai_end,
      pai_convert,
      pov_gosplit_bwtar,
      cursor_position_resolve REDEFINITION.

  PRIVATE SECTION.
    DATA:
*   Private dat:
*   !!! Clear the following fields in method 'reset_split_quantity' !!!!
*_______________________________________________________________________
      p_selected_line    TYPE sytabix, "goitem line to be splitted
      p_split_line       TYPE sytabix, "global counter for Split-TV
      p_displayed_lines  TYPE sytabix, "displayed lines in TV
      ps_goitem          TYPE goitem,  "goitem to be splitted
      ps_gosplit         TYPE gosplit, "actual gosplit line
      ps_gosplit_default TYPE gosplit, "info from goitem in gosplit
      pt_gosplit        TYPE STANDARD TABLE OF gosplit,
      ps_column TYPE lcl_migo_screenmodification=>ty_s_column.
*______________________________________________________________________
*   Private methods
    METHODS:
      popup_call,
      status_set,
      cursor_set,
      split_insert,
      sum_get,
      ucomm_handle,
      reset_split_quantity.

ENDCLASS.