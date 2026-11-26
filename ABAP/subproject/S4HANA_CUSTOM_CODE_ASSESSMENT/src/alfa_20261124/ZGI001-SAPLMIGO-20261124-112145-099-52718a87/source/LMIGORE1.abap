*----------------------------------------------------------------------*
*   INCLUDE LMIGORE1                                                   *
*----------------------------------------------------------------------*
*       FORM rkpf_get_search                                          *
* This routine has to be defined as FORM to allow a dynamic perform:
* callback routin for ldb_process
*---------------------------------------------------------------------*

FORM rkpf_get_search USING name  TYPE ldbn-ldbnode
                           wa    TYPE rkpf
                           evt   TYPE c
                           check TYPE c.                     "#EC CALLED
  CALL METHOD lcl_migo_globals=>kernel->reservation_header_receive
                                          EXPORTING
                                            is_resheader = wa.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM resb_get_search                                          *
*---------------------------------------------------------------------*
* This routine has to be defined as FORM to allow a dynamic perform
*---------------------------------------------------------------------*
*  -->  name                                                          *
*  -->  wa                                                            *
*  -->  mode                                                          *
*  -->  check                                                         *
*---------------------------------------------------------------------*
FORM resb_get_search USING name  TYPE ldbn-ldbnode
                           wa    TYPE resb
                           evt   TYPE c
                           check TYPE c.                     "#EC CALLED
 CALL METHOD lcl_migo_globals=>kernel->reservation_items_receive
                                         EXPORTING
                                           is_resitem = wa.
ENDFORM.