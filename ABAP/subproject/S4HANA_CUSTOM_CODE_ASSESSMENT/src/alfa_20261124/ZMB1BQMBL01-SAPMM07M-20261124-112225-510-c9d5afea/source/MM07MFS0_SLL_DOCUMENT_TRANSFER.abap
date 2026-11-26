***INCLUDE MM07MFS0_SLL_DOCUMENT_TRANSFER .

*----------------------------------------------------------------------*
*   Form SLL_DOCUMENT_ACTIVATE                                         *
*----------------------------------------------------------------------*
*  Aktivierung Beleg in Legal & Logistics Services                     *
*----------------------------------------------------------------------*
FORM sll_document_activate.                                 "#EC CALLED





ENDFORM.                    "SLL_DOCUMENT_ACTIVATE
*eject

*----------------------------------------------------------------------*
*   Form SLL_DOCUMENT_TRANSFER                                         *
*----------------------------------------------------------------------*
*  Ueberleitung Beleg an Legal & Logistics Services                    *
*----------------------------------------------------------------------*
*  IV_MODE = 'N': Aufruf VOR Nachrichtensteuerung
*  IV_MODE = 'V': Aufruf zur Verbuchung
*----------------------------------------------------------------------*
FORM sll_document_transfer
     USING iv_mode TYPE c.                                  "#EC CALLED

  DATA: li_sll_pi_mm0c_transfer TYPE REF TO sll_pi_mm0c_transfer.

  GET BADI li_sll_pi_mm0c_transfer.

  IF li_sll_pi_mm0c_transfer IS BOUND.
    CALL BADI li_sll_pi_mm0c_transfer->material_doc_transfer
      EXPORTING
        it_xmkpf  = xmkpf[]
        it_xmseg  = xmseg[]
        it_xvm07m = xvm07m[]
        iv_mode   = iv_mode.
  ENDIF.

ENDFORM.                    "SLL_DOCUMENT_TRANSFER
*eject