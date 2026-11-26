*----------------------------------------------------------------------*
*   INCLUDE RM07DEBG                                                   *
*----------------------------------------------------------------------*

* Definition of the debug class to access components
CLASS cl_mmim_debug_control DEFINITION LOAD.

* Macro with the intelligent break-point (see note 316105).
DEFINE def_break.
  if cl_mmim_debug_control=>gf_active = 'X'.
*   Save SY-status as the coding within CHECK may manipulate it
    cl_mmim_debug_control=>gs_sy = sy.
    if cl_mmim_debug_control=>check( &1 ) = 'X'.
*     Active break-point. Restore SY ***before***, so that on the
*     point the fields can be evaluated and manipulated.
      sy = cl_mmim_debug_control=>gs_sy.
      break-point.
    else.
      sy = cl_mmim_debug_control=>gs_sy.
    endif.
  endif.
END-OF-DEFINITION.