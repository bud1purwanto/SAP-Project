*&---------------------------------------------------------------------*
*&  Include LMIGOKM3                                                   *
*&  Movement type determination for Subsequent Adjustment              *
*&---------------------------------------------------------------------*

************************************************************************
* mvt_move_component_get:                                              *
* Determination of the right movement type for a given SC_ADJUST value *
*     -> i_sc_adjust                                                   *
*     -> i_shkzg                                                       *
*     <- c_move                                                        *
************************************************************************
METHOD mvt_move_component_get.

  DATA: l_fcode TYPE fcode.

  IF i_sc_adjust IS INITIAL.
    IF i_shkzg = s.
       l_fcode = 'LBWA'.            "excess consumption
    ELSE.
       l_fcode = 'LBNA'.            "excess receipt
    ENDIF.
  ELSE.
    IF i_shkzg = s.
       l_fcode = 'LBNS'.            "short receipt
    ELSE.
       l_fcode = 'LBWS'.            "under consumption
    ENDIF.
  ENDIF.

  CALL METHOD  lcl_migo_buffer=>move_type_next_get
     EXPORTING
       i_move  = space
       i_fcode = l_fcode
     RECEIVING
       e_move_next = c_move.

ENDMETHOD.

************************************************************************
* mvt_sc_adjust_component_get                                          *
* Determination of the right SC_ADJUST value for a given movement type *
*     -> i_move                                                        *
*     <- c_sc_adjust                                                   *
************************************************************************
METHOD mvt_sc_adjust_component_get.

  DATA: l_move  TYPE bwart.

* Only under consumption and short receipt has to be checked as
* for excess consumption and excess receipt the value of
* c_sc_adjust is already determined (value = blank).

* 1. try: check if BWART_NEXT of T156N = actual move type
* with fcode = under consumption
  CALL METHOD  lcl_migo_buffer=>move_type_next_get
     EXPORTING
       i_move  = space
       i_fcode = 'LBWS'
     RECEIVING
       e_move_next = l_move.

  IF i_move = l_move.
    c_sc_adjust = x.
  ELSE.
*   2. try: check if BWART_NEXT of T156N = actual move type
*   with fcode = short receipt
    CALL METHOD  lcl_migo_buffer=>move_type_next_get
     EXPORTING
       i_move  = space
       i_fcode = 'LBNS'
     RECEIVING
       e_move_next = l_move.

     IF i_move = l_move.
       c_sc_adjust = x.
     ENDIF.
  ENDIF.

ENDMETHOD.