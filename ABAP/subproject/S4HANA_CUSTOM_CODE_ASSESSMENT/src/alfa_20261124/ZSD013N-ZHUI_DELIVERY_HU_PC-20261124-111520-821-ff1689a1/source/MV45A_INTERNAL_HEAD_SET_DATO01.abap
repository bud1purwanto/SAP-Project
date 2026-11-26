*----------------------------------------------------------------------*
***INCLUDE MV45A_INTERNAL_HEAD_SET_DATO01 .
*----------------------------------------------------------------------*
MODULE internal_head_set_data OUTPUT.

  PERFORM vbak_bearbeiten_vorbereiten(sapfv45k).

  PERFORM internal_head_set_data.

ENDMODULE.                 " INTERNAL_HEAD_SET_DATA  OUTPUT