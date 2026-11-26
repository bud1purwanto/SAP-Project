*&---------------------------------------------------------------------*
*&      Form  SD_CREATE_BATCH
*&---------------------------------------------------------------------*
*       Create new batch + Classification
*----------------------------------------------------------------------*
form sd_create_batch.

  call function 'VB_INSERT_BATCH_PREPARE'.
  call function 'VB_UPDATE_BATCH_PREPARE'.

endform.                               " SD_CREATE_BATCH