*----------------------------------------------------------------------*
*   INCLUDE MV45AF0M_MOVE_KUAGV_TO_VBAK                                *
*----------------------------------------------------------------------*
FORM move_kuagv_to_vbak.
  IF kuagv-kunnr NE vbak-kunnr.
    PERFORM vbak_bearbeiten_vorbereiten(sapfv45k).
    MOVE kuagv-kunnr TO vbak-kunnr.
    PERFORM vbak_bearbeiten(sapfv45k).
  ENDIF.
ENDFORM.




















