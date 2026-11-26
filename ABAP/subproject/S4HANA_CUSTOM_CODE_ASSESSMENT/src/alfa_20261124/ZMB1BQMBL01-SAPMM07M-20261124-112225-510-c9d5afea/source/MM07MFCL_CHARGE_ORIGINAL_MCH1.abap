*eject
*---------------------------------------------------------------------*
*       FORM   CHARGE_ORIGINAL_MCH1                                   *
*---------------------------------------------------------------------*
*       Die Daten der Originalcharge werden beschafft                 *
*---------------------------------------------------------------------*
FORM CHARGE_ORIGINAL_MCH1 USING LOC_MATNR
                                LOC_CHARG.

  DATA: LOC_SUBRC LIKE SY-SUBRC.

  CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
       EXPORTING
            MATNR            = LOC_MATNR
            CHARG            = LOC_CHARG
            READ_FROM_BUFFER = SPACE
            READ_FROM_DB     = X
       IMPORTING
            MCH1_DB          = OMCH1
            RC_MCH1_DB       = LOC_SUBRC
       EXCEPTIONS
            OTHERS           = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF NOT LOC_SUBRC IS INITIAL.
    CLEAR OMCH1.
  ENDIF.

ENDFORM.