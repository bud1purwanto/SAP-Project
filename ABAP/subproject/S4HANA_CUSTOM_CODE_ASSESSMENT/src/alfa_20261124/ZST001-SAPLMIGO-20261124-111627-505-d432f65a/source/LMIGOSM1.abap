*----------------------------------------------------------------------*
*   INCLUDE LMIGOSM1                                                   *
*   Screenmanager
*----------------------------------------------------------------------*

CLASS lcl_migo_screenmanager DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

PRIVATE SECTION.
  DATA:
    p_status TYPE char3.

ENDCLASS.