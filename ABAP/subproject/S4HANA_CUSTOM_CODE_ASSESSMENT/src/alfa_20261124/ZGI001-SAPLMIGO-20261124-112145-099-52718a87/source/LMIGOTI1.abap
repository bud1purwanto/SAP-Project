*----------------------------------------------------------------------*
*   INCLUDE LMIGOTI1                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_titlebar DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

PRIVATE SECTION.
  DATA:
    p_action_text TYPE char50,
    p_refdoc_text TYPE char50,
    p_document    TYPE char50,
    p_username    TYPE migo_username,
    p_title       TYPE char100.
ENDCLASS.