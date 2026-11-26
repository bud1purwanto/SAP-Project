*&---------------------------------------------------------------------*
*&      Form  SERIAL_LISTE_COMPLETE_CHECK
*&---------------------------------------------------------------------*
FORM serial_liste_complete_check.

*------ Prüfung darf nicht stattfinden bei: -
*       1) Chargenzustandsänderung
* if not ( xmseg-bwart eq bwart_341 or xmseg-bwart eq bwart_342 )
* and not ( zdm07m-sernp is initial and xmseg-kzbew = l ).
  CHECK inventur IS INITIAL.
  CHECK NOT ( xmseg-bwart EQ bwart_341 OR xmseg-bwart EQ bwart_342 )
        AND NOT zdm07m-sernp IS INITIAL.                     "note313695

  data ser_quan LIKE RISA0-ANZAHL.                           "note313695
  ser_quan = xmseg-menge / 1000.                             "note313695

  CALL FUNCTION 'SERIAL_LISTE_COMPLETE_CHECK'
       EXPORTING
            operation      = op_mmsl
            profile        = zdm07m-sernp
*            snbwg          = s156s-snbwg
            snbwg          = zdm07m-snbwg
*           quantity       = zdm07m-anzsn                    "note313695
            quantity       = ser_quan                        "note313695
            document       = xmkpf-mblnr
            item_no        = xmseg-zeile
            xauto          = xmseg-xauto
       EXCEPTIONS
            quantity_error = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                               " SERIAL_LISTE_COMPLETE_CHECK