*----------------------------------------------------------------------*
*   INCLUDE LMIGODQ1                                                   *
*   Detail tabstrip quantity definition                                *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_quantity DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  public section.
    interfaces:
      lif_migo_frame.
    methods:
      constructor.
ENHANCEMENT-POINT LMIGODQ1_02 SPOTS ES_SAPLMIGO STATIC.

ENDCLASS.