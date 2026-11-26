*----------------------------------------------------------------------*
*   INCLUDE LMIGODC1                                                   *
*   Detail carrier (data manager)
*----------------------------------------------------------------------*

CLASS lcl_migo_detail DEFINITION
      INHERITING FROM lcl_migo_screenobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    DATA:
*   Line in the model which is currently displayed
      current_line  TYPE sytabix READ-ONLY,
*   table for working with serial numbers internally
      t_goserial TYPE lcl_migo_kernel=>ty_t_goserial,
                                       " need to be changed when friend
                                       " concept is available
*   table for working with freight vendors internally
    t_gofreight TYPE TABLE OF gofreight." need to be changed when friend
    " concept is availible

    METHODS:
      constructor,
      pbo REDEFINITION,
      pbo_godynpro_fill,
      pai REDEFINITION,
      pai_get,
      pai_transfer_fields_fill,
      line_find.                         "ON REQUEST

  PRIVATE SECTION.
    DATA:
      p_global_counter TYPE goitem-global_counter, "old gobal_counter
                                       "(before sort/Not OK)
      p_last_new_line_mode TYPE char1,
      poref_settings TYPE REF TO cl_mmim_userdefaults,
      ps_old_goitem TYPE goitem.    "goitem before PAI-field transport
    METHODS:
        transfer_item_copy.

ENDCLASS.                    "lcl_migo_detail  DEFINITIO