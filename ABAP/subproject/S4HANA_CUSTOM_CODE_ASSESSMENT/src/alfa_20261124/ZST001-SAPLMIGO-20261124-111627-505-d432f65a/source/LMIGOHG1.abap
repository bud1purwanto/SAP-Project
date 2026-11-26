*----------------------------------------------------------------------*
*   INCLUDE LMIGOHG1                                                   *
*----------------------------------------------------------------------*
*   Header tabstrip general definition
*----------------------------------------------------------------------*

CLASS lcl_migo_header_general DEFINITION
      INHERITING FROM lcl_migo_headerobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION,
      pai_xblnr,
      pai_frbnr,
      pai_wever,  "315434
      pov_date.
ENHANCEMENT-POINT LMIGOHG1_01 SPOTS ES_SAPLMIGO STATIC.
  PRIVATE SECTION.
    METHODS:
      print_text_set,
      print_parameter_set.
ENDCLASS.