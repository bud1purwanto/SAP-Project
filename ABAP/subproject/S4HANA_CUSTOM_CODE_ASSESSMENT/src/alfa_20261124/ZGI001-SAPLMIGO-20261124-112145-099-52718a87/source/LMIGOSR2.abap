*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR2                                                   *
*   Search functions
*----------------------------------------------------------------------*

CLASS lcl_migo_search IMPLEMENTATION.
  INCLUDE lmigosr3.  " Constructor, commonly used routines
  INCLUDE lmigosr4.  " Search for purchase order
  INCLUDE lmigosr5.  " Search for material document
  INCLUDE lmigosr6.  " Search for (production) orders
  INCLUDE lmigosr7.  " Search for reservations
ENDCLASS.

************************************************************************
* Module for popup 3000 (search purchase order).
************************************************************************
MODULE pai_search_po_werks INPUT.                                "411519
  CALL FUNCTION 'MM_PLANT_CONVERT'                               "411519
    CHANGING                                                     "411519
      c_plant     = gosearch_po-werks                            "411519
      c_planttext = gosearch_po-werksname.                       "411519
ENDMODULE.                                                       "411519