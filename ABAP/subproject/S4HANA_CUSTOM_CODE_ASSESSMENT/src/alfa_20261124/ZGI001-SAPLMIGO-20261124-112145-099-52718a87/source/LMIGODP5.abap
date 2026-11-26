* New with Outsourced Manufacturing EhP 4
*----------------------------------------------------------------------*
*   INCLUDE LMIGODP1                                                   *
*   Detail tabstrip purchase order SC components definition
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_po_sc DEFINITION
      INHERITING FROM lcl_migo_detailobject.

PUBLIC SECTION.

  METHODS:

    pbo redefinition,
    pbo_loop.

PRIVATE SECTION.
  DATA:
    pt_comp_tv        TYPE STANDARD TABLE OF gocomp_tv.

ENDCLASS.