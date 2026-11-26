*----------------------------------------------------------------------*
*   INCLUDE LMIGODN1                                                   *
*   Detail tabstrip output determination definition                    *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_output DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

ENDCLASS.