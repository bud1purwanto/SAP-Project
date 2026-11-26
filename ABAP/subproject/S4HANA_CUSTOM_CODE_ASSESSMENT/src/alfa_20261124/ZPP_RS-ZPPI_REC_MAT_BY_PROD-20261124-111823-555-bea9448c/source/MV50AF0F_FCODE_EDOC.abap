*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FCODE_EDOC
*&---------------------------------------------------------------------*
FORM fcode_edoc_t USING h185f STRUCTURE t185f
                        h185  STRUCTURE t185
                        h185v STRUCTURE t185v.

  IF lips-posnr IS NOT INITIAL.
    CALL FUNCTION 'ME_CCP_DOC_FLOW'
      EXPORTING
        i_vbeln = likp-vbeln
        i_posnr = lips-posnr
        i_vbtyp = likp-vbtyp
      EXCEPTIONS
        OTHERS  = 0.
  ELSE.
    MESSAGE s323(vl).
  ENDIF.

ENDFORM.                    "FCODE_EDOC_T