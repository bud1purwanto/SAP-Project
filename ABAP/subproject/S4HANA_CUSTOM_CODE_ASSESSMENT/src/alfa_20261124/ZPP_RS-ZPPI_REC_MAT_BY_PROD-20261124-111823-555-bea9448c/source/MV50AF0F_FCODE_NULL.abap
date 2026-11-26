***INCLUDE MV50AF0F_FCODE_NULL .
*---------------------------------------------------------------------*
*       FORM FCODE_NULL                                               *
*---------------------------------------------------------------------*
*       Uebergabe der Folgeparameter                                  *
*---------------------------------------------------------------------*
FORM FCODE_NULL.
  FCODE = T185-FFCODE.
  T185F-FCODE = T185-FFCODE.
  T185-BLDGR  = T185-FBLDGR.
  T185-PANEL  = T185-FPANEL.
  PERFORM SET_SCREEN_0_LEAVE_SCREEN.
* set screen 0.
* leave screen.
ENDFORM.