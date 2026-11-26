*----------------------------------------------------------------------*
***INCLUDE MV50A_START_VL03NI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  START_VL03N  INPUT
*&---------------------------------------------------------------------*
module start_vl03n input.

* Check TCode authorization
  authority-check object 'S_TCODE'
                  id     'TCD'
                  field  'VL03N'.
  if not sy-subrc is initial.
    message e172(00) with 'VL03N'.
  endif.

* Set PID and call TA
  set parameter id 'VL' field lips-vbeln.
  call transaction 'VL03N' and skip first screen.

endmodule.                 " START_VL03N  INPUT