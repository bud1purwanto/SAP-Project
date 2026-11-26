*----------------------------------------------------------------------*
*   INCLUDE LMIGOSM4                                                   *
*   Screenmodification
*----------------------------------------------------------------------*


CLASS lcl_migo_screenmodification IMPLEMENTATION.
  INCLUDE lmigosmb.  "Generation of fieldselection table
  INCLUDE lmigosmc.  "generate fieldselection depending on migo_mode
  INCLUDE lmigosmd.  "analyse required fields in fieldselection
ENDCLASS.