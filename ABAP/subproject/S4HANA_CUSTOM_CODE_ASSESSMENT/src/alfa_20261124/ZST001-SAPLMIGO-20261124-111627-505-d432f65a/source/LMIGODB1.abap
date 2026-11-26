*----------------------------------------------------------------------*
*   INCLUDE LMIGODB1                                                   *
*   Detail tabstrip batch definition                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_batch DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

ENDCLASS.