*---------------------------------------------------------------------*
*  Include           LMIGODR3
*----------------------------------------------------------------------*
*   Detail tabstrip generic articles                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_ga DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION.
ENDCLASS.