*---------------------------------------------------------------------*
*       FORM MWOFF_STEUERFLAGS                                        *
*---------------------------------------------------------------------*
*     Initialsierung der Steuerflags für SAPMM07M                     *
*---------------------------------------------------------------------*
FORM mwoff_steuerflags USING tcurm LIKE tcurm CHANGING xwert mbval.
ENHANCEMENT-POINT MWOFF_STEUERFLAGS_01 SPOTS ES_SAPMM07M.
  IF tcurm-mbval = 'E'.
    MESSAGE e233(m7).
  ELSEIF  tcurm-mbval = 'X'.
    IF tcurm-mbequ IS INITIAL.
      MESSAGE e253(m7).
    ENDIF.
    mbval = 'X'. CLEAR xwert.
    CALL FUNCTION 'ENQUEUE_EMWOFFS'
*    EXPORTING
*         MODE_TCURM     = 'S'
*         MANDT          = SY-MANDT
*         _SCOPE         = '2'
*         _WAIT          = ' '
*         _COLLECT       = ' '
         EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CLEAR: xwert, mbval.
  ENDIF.
ENDFORM.