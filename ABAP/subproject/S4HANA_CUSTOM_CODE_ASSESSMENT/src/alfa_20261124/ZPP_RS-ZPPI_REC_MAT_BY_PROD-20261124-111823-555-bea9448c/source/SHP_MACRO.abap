***INCLUDE SHP_MACRO .



define  mmove.

*   conditional move, if target(&2) is initial.

    if          &2 is initial.
     move &1 to &2.
    endif.

end-of-definition.


define  mmove2.

*   conditional move &1, &2, if targets (&3 AND &4) are initial.

    if          &3 is initial
    and         &4 is initial.
     move &1 to &3.
     move &2 to &4.
    endif.

end-of-definition.

* debug of parallel processing in vl10
define _break_vl10.

  data: lf_debug_mode(20).
  get parameter id 'LEDSP_DEBUG_MODE' field lf_debug_mode.
  if lf_debug_mode cs 'VL10' or
     lf_debug_mode cs 'vl10'.
    set extended check off.
    break-point.
    set extended check on.
  endif.

end-of-definition.


data: begin of common part likpdebug.
data:                       gf_debug(20).
data: end   of common part likpdebug.

* Stop at main steps of delivery processing
define  %x.
  if gf_debug = 'X'.    break-point.             "#EC NOBREAK
  endif.
end-of-definition.

* Stop at main parts of item processing
define  %xi.
  if gf_debug = 'I'.    break-point.             "#EC NOBREAK
  endif.
end-of-definition.


define  %x1.
  if gf_debug ca '1'.   break-point.             "#EC NOBREAK
  endif.
end-of-definition.


*--- begin of AIP

define           %shp_protocol.

  call function 'SHP_PROTOCOL'
       exporting if_action =  &1.

end-of-definition.

define mbreak_aip.

*  data: lf_debug_mode(20).

  perform shp_core_get_debug_mode(shp_core_debug)
    changing  sy-prtxt.
  if sy-prtxt cs 'AIP'.
    set extended check off.
    break-point.
    set extended check on.
  endif.

end-of-definition.



define _get_field_xlips_ref.

  field-symbols: <ls_xlips_ref> like line of xlips_ref,
                 <ls_component>.

  read table xlips_ref assigning <ls_xlips_ref>
                       with table key handle = &1.
  assign component &2 of structure <ls_xlips_ref> to <ls_component>.
  &3 = <ls_component>.

end-of-definition.


define _get_field_xlips_ref_1.

  field-symbols: <ls_component>.


  read table xlips_ref assigning <ls_xlips_ref>
                       with table key handle = &1.
  assign component &2 of structure <ls_xlips_ref> to <ls_component>.
  &3 = <ls_component>.


end-of-definition.


*--- end of AIP