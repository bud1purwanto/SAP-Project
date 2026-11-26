*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSFORM_TC_FCODE                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_TC_FCODE
*&---------------------------------------------------------------------*
*       Fcodes coming from the table control are decomposed into the
*       fcode to be sent to the screen sequence control and the step
*       loop line in which the push button has been pressed
*       These fcodes should be defined as FCODE_T%% in the screen
*       painter. %% is replaced by the step loop line.
*----------------------------------------------------------------------*
FORM TRANSFORM_TC_FCODE CHANGING CF_FCODE           TYPE FCODE
                                 CF_PUSHBUTTON_LINE TYPE SYSTEPL.

  DATA: LF_FCODE TYPE FCODE,
        LF_C_PUSHBUTTON_LINE(2) TYPE C.

  CHECK CF_FCODE CS '_T'.

* Decompose given function code
  SPLIT CF_FCODE AT '_T' INTO LF_FCODE LF_C_PUSHBUTTON_LINE.

  CHECK LF_C_PUSHBUTTON_LINE NE SPACE.

* Suffix must be appended again
  CONCATENATE LF_FCODE '_T' INTO CF_FCODE.
* Transform character string to line number
  CF_PUSHBUTTON_LINE = LF_C_PUSHBUTTON_LINE.

ENDFORM.                               " TRANSFORM_TC_FCODE































