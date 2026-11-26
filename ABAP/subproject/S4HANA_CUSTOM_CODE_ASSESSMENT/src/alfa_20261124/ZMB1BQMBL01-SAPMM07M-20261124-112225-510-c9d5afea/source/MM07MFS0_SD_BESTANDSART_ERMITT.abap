*----------------------------------------------------------------------*
*       Form  SD_BESTANDSART_ERMITTELN
*----------------------------------------------------------------------*
*    Füllen der Felder BESTQ und UMBSQ, damit in der Lieferung
*    die korrekten Bestände verarbeitet werden.
*----------------------------------------------------------------------*
form sd_bestandsart_ermitteln changing lbbsa like vm07m-lbbsa
                                       bestq like xmseg-bestq.

  call function 'L_LBBSA_TO_BESTQ_CONVERT'
       exporting
            i_lbbsa       = lbbsa
       importing
            e_bestq       = bestq
       exceptions
            unknown_lbbsa = 1
            others        = 2.

  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                               " SD_BESTANDSART_ERMITTELN