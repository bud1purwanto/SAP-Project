*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_THIRD_PARTY_CHECK                                 *
*----------------------------------------------------------------------*

form third_party_check .
  if third_party_status is initial.
    raise not_active.
  endif.
endform.