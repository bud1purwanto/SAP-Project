*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_HEAD_SET_DATO01 .
*----------------------------------------------------------------------*
MODULE customer_head_set_data OUTPUT.

  PERFORM vbak_bearbeiten_vorbereiten(sapfv45k).

  perform customer_head_set_data.

ENDMODULE.                 " CUSTOMER_HEAD_SET_DATA  OUTPUT