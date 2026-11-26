* ----- begin of AIP

*----------------------------------------------------------------------*
***INCLUDE MV50AF0K_KORR_XLIPSREF_LSMENG .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  korr_xlipsref_lsmeng
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XLIPS_HANDLE  text
*      <--P_KORRTAB_UEPOS_LSMENG  text
*      <--P_KORRTAB_UEPOS_VRKME  text
*----------------------------------------------------------------------*
form korr_xlipsref_lsmeng using    is_xlips        type lipsvb
                          changing cf_uepos_lsmeng type lsmeng
                                   cf_uepos_vrkme  type vrkme.

  field-symbols: <ls_xlips_ref> like line of xlips_ref.

  if is_xlips-kmpmg is initial.
*    "not nice, but should not happen
*    if not v50agl-ucdel_to_del is initial.
*      message x001(vl) with space.
*    endif.
    read table xlips_ref assigning <ls_xlips_ref>
                         with table key handle = is_xlips-handle.
    cf_uepos_lsmeng = <ls_xlips_ref>-ref_lsmeng.
    cf_uepos_vrkme  = <ls_xlips_ref>-ref_vrkme.
  else.
    cf_uepos_lsmeng = is_xlips-kmpmg.
    cf_uepos_vrkme  = is_xlips-meins.
  endif.

endform.                    " korr_xlipsref_lsmeng


* ----- end   of AIP