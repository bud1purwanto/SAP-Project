*----------------------------------------------------------------------*
*   INCLUDE LMIGOTP1                                                   *
*   Tips
*----------------------------------------------------------------------*

CLASS lcl_migo_tip DEFINITION INHERITING FROM lcl_migo_screenobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    pbo REDEFINITION,
    pai REDEFINITION.

PRIVATE SECTION.
  DATA:
    p_oref_settings  TYPE REF TO cl_mmim_userdefaults,
    p_oref_container TYPE REF TO cl_gui_custom_container,
    p_oref_html      TYPE REF TO cl_gui_html_viewer,
    p_docuobject     TYPE dokhl-object.
  METHODS:
    popup_call,
    tips_reset.

ENDCLASS.