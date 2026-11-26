*eject
*---------------------------------------------------------------------*
*       FORM CHARGE_CHANGE_DOCUMENT
*---------------------------------------------------------------------*
FORM charge_change_document.

  DATA:
    lv_change_document_to_create TYPE xfeld.

  IF kzdch EQ charge_auf_werk.
    LOOP AT xmcha.

*- check for real batches - only in plant level (no valuation types)
      READ TABLE xmch1
           WITH KEY matnr = xmcha-matnr
                    charg = xmcha-charg.
      CHECK sy-subrc IS INITIAL.

*- batch is created or changed
      IF NOT xmcha-xchup IS INITIAL AND
       ( NOT xmcha-rmcha IS INITIAL OR
         NOT xmcha-xdbup IS INITIAL ).
        lv_change_document_to_create = x.

*- check for to be created storage location segment
      ELSE.
        LOOP AT xmchb
             TRANSPORTING NO FIELDS
             WHERE matnr EQ xmcha-matnr
               AND werks EQ xmcha-werks
               AND charg EQ xmcha-charg
               AND NOT rmchb IS initial.
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          lv_change_document_to_create = x.
        ENDIF.
      ENDIF.

      CHECK NOT lv_change_document_to_create IS INITIAL.
      CALL FUNCTION 'VB_CHANGE_DOCUMENT_REGISTER'
        EXPORTING
          i_matnr                = xmcha-matnr
          i_charg                = xmcha-charg
          i_werks                = xmcha-werks
          i_no_perform_on_commit = ' '
        EXCEPTIONS
          no_material            = 1
          no_batch               = 2
          no_plant               = 3
          OTHERS                 = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.

  ELSE.
    LOOP AT xmch1.

*- batch is created or changed
      IF NOT xmch1-xchup IS INITIAL AND
       ( NOT xmch1-rmch1 IS INITIAL OR
         NOT xmch1-xdbup IS INITIAL ).
        lv_change_document_to_create = x.

*- check for to be created plant segment or valuation type set
      ELSE.
        LOOP AT xmcha
             TRANSPORTING NO FIELDS
             WHERE matnr EQ xmch1-matnr
               AND charg EQ xmcha-charg
               AND   NOT xchup IS initial
               AND ( NOT rmcha IS initial OR
                     NOT xdbup IS initial ).
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          lv_change_document_to_create = x.

*- check for to be created storage location segment
        ELSE.
          LOOP AT xmchb
               TRANSPORTING NO FIELDS
               WHERE matnr EQ xmch1-matnr
                 AND charg EQ xmch1-charg
                 AND NOT rmchb IS initial.
            EXIT.
          ENDLOOP.
          IF sy-subrc IS INITIAL.
            lv_change_document_to_create = x.
          ENDIF.
        ENDIF.
      ENDIF.

      CHECK NOT lv_change_document_to_create IS INITIAL.
      CALL FUNCTION 'VB_CHANGE_DOCUMENT_REGISTER'
        EXPORTING
          i_matnr                = xmch1-matnr
          i_charg                = xmch1-charg
          i_no_perform_on_commit = ' '
        EXCEPTIONS
          no_material            = 1
          no_batch               = 2
          no_plant               = 3
          OTHERS                 = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Check, if Valuation will change (BWART = 340 and creation is ok!)
  LOOP AT xmcha WHERE NOT bwtar IS initial.
    PERFORM charge_original_mcha USING xmcha-matnr
                                       xmcha-werks
                                       xmcha-charg.
    IF xmcha-bwtar NE omcha-bwtar AND
       omcha-bwtar NE space.

      READ TABLE xmseg WITH KEY matbf = xmcha-matnr
                                werks = xmcha-werks
                                charg = xmcha-charg
                                bwart = bwart_340.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE a599(m7) WITH omcha-matnr
                              omcha-charg
                              omcha-bwtar
                              xmcha-bwtar.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "CHARGE_CHANGE_DOCUMENT