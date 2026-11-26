*----------------------------------------------------------------------*
*   INCLUDE LMIGODF1                                                   *
*   detail tabstrip freight definition                                 *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_freight DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo_loop,
      pbo REDEFINITION,
      pai_loop,
      pai REDEFINITION,
      cursor_position_resolve REDEFINITION.

  PRIVATE SECTION.
    DATA: p_displayed_lines TYPE sytabix,       "displayed lines in TV
          p_lines           TYPE sytabix.       "lines in t_gofreight
    METHODS:
      column_hide,
      cursor_set.

ENDCLASS.