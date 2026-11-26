*----------------------------------------------------------------------*
*   INCLUDE LMIGODP1                                                   *
*   Detail tabstrip purchase order definition
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_po DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor,
    pbo redefinition.

ENDCLASS.