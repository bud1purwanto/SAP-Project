*----------------------------------------------------------------------*
*   INCLUDE LMIGODW1                                                   *
*----------------------------------------------------------------------*
*   Detail tabstrip warehouse management                               *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_wm DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION.
ENDCLASS.