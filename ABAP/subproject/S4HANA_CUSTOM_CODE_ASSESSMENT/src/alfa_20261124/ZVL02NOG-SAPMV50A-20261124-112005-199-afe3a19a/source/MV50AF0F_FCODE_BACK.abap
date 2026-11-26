*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_BACK                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_BACK                                               *
*---------------------------------------------------------------------*
*       Die Transaktion VL02 kann aus einer Listanzeige aufgerufen    *
*       werden.                                                       *
*       Beim Funktionscode "BACK" auf den Ort U0 wird durch diese     *
*       Form der Rücksprung in die Liste erreicht.
*       Wegen des Rollbereichsübergreifenden Textmemory muß dieses
*       vor dem Verlassen der Transaktion in jedem Fall gelöscht
*       werden.
*       Ansonsten wird vor dem Verlassen der Erfassungsmaske der      *
*       Beleg initialisiert.                                          *
*---------------------------------------------------------------------*
form fcode_back.

* LEAVE.                               "bis 45B
  perform text_memory_init.
  leave.                               "ab 45B
  perform beleg_daten_init.
  if not gf_param_tcode is initial.                         "v_n_532957
    leave to transaction gf_param_tcode.
  endif.                                                    "^_n_532957

endform.