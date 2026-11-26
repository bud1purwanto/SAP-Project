*WTH END NOTE 180691
*&---------------------------------------------------------------------*
*&      Form  RESERVATION_ENQUEUE
*&---------------------------------------------------------------------*
*       Enqueue reservations
*----------------------------------------------------------------------*
*      -->IT_RESERVATION_ENQUEUE  text
*----------------------------------------------------------------------*
FORM RESERVATION_ENQUEUE USING IT_RESERVATION_ENQUEUE TYPE TABLE."205978
  DATA: L_RSNUM LIKE RESB-RSNUM.                                 "205978
  LOOP AT IT_RESERVATION_ENQUEUE INTO L_RSNUM.                   "205978
    CALL FUNCTION 'ENQUEUE_EMRKPF'                               "205978
        EXPORTING                                                "205978
             MODE_RKPF      = 'E'                                "205978
             MANDT          = SY-MANDT                           "205978
             RSNUM          = L_RSNUM                            "205978
             _COLLECT       = 'X'.                               "205978
  ENDLOOP.                                                       "205978
  CALL FUNCTION 'FLUSH_ENQUEUE'                                  "205978
      EXCEPTIONS                                                 "205978
           FOREIGN_LOCK   = 1                                    "205978
           SYSTEM_FAILURE = 2.                                   "205978
  CASE SY-SUBRC.                                                 "205978
    WHEN 1.                                                      "205978
      MESSAGE E545.                                              "205978
    WHEN 2.                                                      "205978
      MESSAGE E110.                                              "205978
  ENDCASE.                                                       "205978
ENDFORM.                    " RESERVATION_ENQUEUE                "205978