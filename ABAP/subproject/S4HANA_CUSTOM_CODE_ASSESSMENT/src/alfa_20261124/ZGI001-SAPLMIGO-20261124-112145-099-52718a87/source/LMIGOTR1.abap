*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR1                                                   *
*   Tracer
*----------------------------------------------------------------------*

CLASS lcl_migo_trace DEFINITION
      INHERITING FROM lcl_migo_screenobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.

  METHODS:
    constructor.

PRIVATE SECTION.
  DATA:
    poref_toolbarcontainer  TYPE REF TO cl_gui_custom_container,
    poref_toolbar           TYPE REF TO cl_gui_toolbar,
    poref_settings          TYPE REF TO cl_mmim_userdefaults.
  METHODS:
    toolbar_init,
    toolbar_handler FOR EVENT function_selected OF cl_gui_toolbar
      IMPORTING
        fcode.
ENDCLASS.