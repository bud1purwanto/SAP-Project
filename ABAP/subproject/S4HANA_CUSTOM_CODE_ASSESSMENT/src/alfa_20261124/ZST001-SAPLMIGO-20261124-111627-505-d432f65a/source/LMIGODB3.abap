*----------------------------------------------------------------------*
*   INCLUDE LMIGODB3                                                   *
*   Detail tabstrip documentary batch definition                       *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_doc_batch DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION,
      reset,
*     Method does the same as MOVE-CORRESPONDING, but has to handle
*     structures field by field
      doc_batch_move_goitem_to_com
        IMPORTING
          i_goitem            TYPE goitem
        EXPORTING
          e_docubatch_com     TYPE docubatch_com,
*     determine business process to call LO-BM
      doc_batch_set_process_id
        IMPORTING
          i_goitem            TYPE goitem
        EXPORTING
          et_process_ids      TYPE docubatch_process_id_t
          e_ebeln             TYPE ebeln
          e_ebelp             TYPE ebelp
          e_aufnr             TYPE aufnr
          e_posnr             TYPE co_posnr,
      doc_batch_item_delete
        IMPORTING
          i_global_counter    TYPE goitem-global_counter.

  PRIVATE SECTION.
    TYPES: BEGIN OF pty_db_process_buffer,
             global_counter TYPE goitem-global_counter,
             ebeln          TYPE ebeln,
             ebelp          TYPE ebelp,
             aufnr          TYPE aufnr,
             pps_aufnr      TYPE aufnr,
             pps_posnr      TYPE co_posnr,
             process_ids    TYPE docubatch_process_id_t,
           END OF pty_db_process_buffer,
           BEGIN OF pty_db_buffer_compare,
             global_counter TYPE goitem-global_counter,
             ebeln          TYPE ebeln,
             ebelp          TYPE ebelp,
             aufnr          TYPE aufnr,
             pps_aufnr      TYPE aufnr,
             pps_posnr      TYPE co_posnr,
           END OF pty_db_buffer_compare.
*         buffer table to keep information about business process
*         for calling VBDOCUBATCH_DM
    DATA: pt_process_buffer TYPE SORTED TABLE OF pty_db_process_buffer
                                 WITH UNIQUE KEY global_counter.

ENDCLASS.                    "lcl_migo_detail_doc_batch  DEFINITION