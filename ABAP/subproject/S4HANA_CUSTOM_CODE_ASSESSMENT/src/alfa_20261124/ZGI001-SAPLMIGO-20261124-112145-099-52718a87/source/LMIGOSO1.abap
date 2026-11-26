*----------------------------------------------------------------------*
*   INCLUDE LMIGOSO1                                                   *
*   Abstract master class for screen objects in MIGO
*----------------------------------------------------------------------*

CLASS lcl_migo_screenobject DEFINITION ABSTRACT.

PUBLIC SECTION.

  TYPES: ty_name TYPE char20.

  DATA:
    dynnr TYPE sydynnr.

  METHODS:
    pbo
      IMPORTING i_global_counter TYPE migo_global_counter OPTIONAL,
    pai,
    cursor_position_resolve
      EXPORTING
        e_name            TYPE ty_name
        e_tabix           TYPE sytabix "tabix for model-line
                                       "(tv_goitem)
        e_secondary_tabix TYPE sytabix."tabix for dependent tables
                                       "(tv_gofreight/tv_goserial)
ENDCLASS.