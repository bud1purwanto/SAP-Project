*&---------------------------------------------------------------------*
*&  Include           /SPE/SPED_MV50A
*Check whether the output type has to be executed for 2-step stock
*stock transfer.
*If the follow-up movement type (LIPS-FOBWA) is filled and the receiving
*plant (UMWRK) and storage location (UMLGO) are given, SPED can be
*processed.
*&---------------------------------------------------------------------*
FORM spe_sped_relevancy  USING  lv_vbeln    TYPE vbeln_vl
                                lv_sped_rel    TYPE boolean.

  DATA : ls_lips       TYPE lipsvb.
  CLEAR lv_sped_rel.

  READ TABLE xlips WITH KEY vbeln = lv_vbeln INTO ls_lips BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF NOT ls_lips-fobwa IS INITIAL AND
       NOT ls_lips-umwrk IS INITIAL AND
       NOT ls_lips-umlgo IS INITIAL.
      lv_sped_rel = gc_true.
    ENDIF.
  ELSE.
    CLEAR lv_sped_rel.
  ENDIF.


ENDFORM.                    "spe_sped_relevancy