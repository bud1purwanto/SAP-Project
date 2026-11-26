*&---------------------------------------------------------------------*
*&  Include           MV50AF0B_BELEG_LESEN_ARCHIV
*&---------------------------------------------------------------------*
FORM beleg_lesen_archiv USING if_likp_vbeln TYPE likp-vbeln
                              if_likp_erdat TYPE likp-erdat.


  DATA: lf_subrc TYPE sy-subrc.

  likp-vbeln = if_likp_vbeln.
  IF likp-vbeln IS INITIAL.
    MESSAGE e045(v1).
  ENDIF.

* setzen Parameter
  CASE t180-trvog.
    WHEN chard.
      SET PARAMETER ID 'VLM' FIELD likp-vbeln.
    WHEN charg.
      SET PARAMETER ID 'VLG' FIELD likp-vbeln.
  ENDCASE.

  likp-mandt = sy-mandt.
  PERFORM lieferung_sperren USING likp-vbeln.

* Richtigen FCode setzen, wenn nach WABU ENT2 folgen soll

  IF sy-ucomm EQ space.
    fcode = 'ENT2'.
    PERFORM transform_fcode CHANGING fcode.
  ENDIF.


  PERFORM read_delivery_from_archive USING    likp-vbeln
                                              if_likp_erdat
                                     CHANGING lf_subrc.
  IF lf_subrc EQ 0.
*       Delivery could be reloaded successfully
    IF fcode EQ 'IFLU_T'.
*         Display of document flow is not supported for archived
*         deliveries -> use Document Relationsship Browser instead
      MESSAGE e576.
    ENDIF.
    EXIT.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    "beleg_lesen_archiv