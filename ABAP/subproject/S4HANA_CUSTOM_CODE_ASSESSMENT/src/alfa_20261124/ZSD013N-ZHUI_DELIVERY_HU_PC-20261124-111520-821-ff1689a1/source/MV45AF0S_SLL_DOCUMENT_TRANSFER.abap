***INCLUDE MV45AF0S_SLL_DOCUMENT_TRANSFER .

*----------------------------------------------------------------------*
*   Form SLL_DOCUMENT_ACTIVATE                                         *
*----------------------------------------------------------------------*
*  Aktivierung Beleg in Legal & Logistics Services                     *
*----------------------------------------------------------------------*
FORM sll_document_activate.                                 "#EC CALLED

  CHECK 1 = 1.



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
     USING iv_mode TYPE c.

  DATA: li_sll_pi_sd0a_transfer TYPE REF TO sll_pi_sd0a_transfer.

  GET BADI li_sll_pi_sd0a_transfer.

  IF li_sll_pi_sd0a_transfer IS BOUND.
    CALL BADI li_sll_pi_sd0a_transfer->sales_doc_transfer
      EXPORTING
        is_vbak               = vbak
        is_tvak               = tvak
        iv_deletion_indicator = yvbak_updkz
        iv_business_object    = businessobjekt
        iv_trtyp              = t180-trtyp
        it_xvbpa              = xvbpa[]
        it_yvbpa              = yvbpa[]
        it_xvbap              = xvbap[]
        it_yvbap              = yvbap[]
        it_xvbup              = xvbup[]
        it_xvbep              = xvbep[]
        it_xvbkd              = xvbkd[]
        it_xvbadr             = xvbadr[]
        iv_mode               = iv_mode.
  ENDIF.

ENDFORM.                    "SLL_DOCUMENT_TRANSFER
*eject