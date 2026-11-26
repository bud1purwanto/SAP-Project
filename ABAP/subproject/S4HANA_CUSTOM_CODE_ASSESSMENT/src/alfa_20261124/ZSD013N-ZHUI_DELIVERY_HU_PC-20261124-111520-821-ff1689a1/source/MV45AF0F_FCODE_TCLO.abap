*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_TCLO                                        *
*----------------------------------------------------------------------*

FORM FCODE_TCLO.

* Text muß gegebenenfalls erst entsperrt werden
  IF TEXT_CONTROL_REFERIERT = CHARX.
    PERFORM FCODE_TCEN.
  ENDIF.

  LOOP AT XTHEAD WHERE TDID = TVAK-TDID
                   AND TDOBJECT = 'VBBK'
                   AND ( TDSPRAS = SY-LANGU OR
                         TDSPRAS = SPACE OR
                         TDSPRAS = CHAR* )
                   AND UPDKZ NE UPDKZ_DELETE.
  ENDLOOP.

  READ TABLE ITHEAD WITH KEY TDOBJECT = 'VBBK'
                             TDID     = TVAK-TDID
                             TDSPRAS  = XTHEAD-TDSPRAS.

  IF SY-SUBRC EQ 0.
    ITHEAD-SELKZ = 'X'.
    MODIFY ITHEAD INDEX SY-TABIX TRANSPORTING SELKZ TDSPRAS.
    PERFORM FCODE_TELO(SAPFV45T).
  ENDIF.

ENDFORM.
*eject