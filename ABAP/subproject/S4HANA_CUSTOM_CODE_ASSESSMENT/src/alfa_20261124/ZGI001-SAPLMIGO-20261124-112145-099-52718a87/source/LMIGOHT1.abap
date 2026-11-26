*----------------------------------------------------------------------*
*   INCLUDE LMIGOHT1                                                   *
*   HTML-help
*----------------------------------------------------------------------*

CLASS lcl_migo_html_help DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

PRIVATE SECTION.
  METHODS:
    initialize,
    show.

ENDCLASS.