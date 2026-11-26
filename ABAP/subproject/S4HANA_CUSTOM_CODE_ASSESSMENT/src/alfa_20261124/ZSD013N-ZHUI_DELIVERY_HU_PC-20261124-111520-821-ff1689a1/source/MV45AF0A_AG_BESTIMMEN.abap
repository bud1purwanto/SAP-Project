*&---------------------------------------------------------------------*
*&      Form  AG_BESTIMMEN
*&---------------------------------------------------------------------*
*       Auftraggeber aus Warenempfänger ermitteln :
*       Dazu werden alle Kunden bestimmt, in deren KNVP der
*       Warenempfänger unter der Rolle 'WE' eingetragen ist.
*       Bei Mehrdeutigkeit : Auswahl-Popup
*----------------------------------------------------------------------*
FORM AG_BESTIMMEN USING US_WE    LIKE KNA1-KUNNR
                        US_AG    LIKE KNA1-KUNNR
                        US_VKORG LIKE TVTA-VKORG
                        US_VTWEG LIKE TVTA-VTWEG
                        US_SPART LIKE TVTA-SPART.

  DATA: H_KNVP LIKE KNVP,
        H_RETURNCODE TYPE I.

* Auftraggeber zum Warenempfänger bestimmen
  CALL FUNCTION 'SD_PARTNER_GET_SOURCE_PARTNER'
    EXPORTING
      I_KUNNR             = US_WE
      I_PARVW             = 'WE'
      I_PARVW_SOURCE      = 'AG'
      I_VKORG             = US_VKORG
      I_VTWEG             = US_VTWEG
      I_SPART             = US_SPART
      I_CALL_BAPI         = CALL_BAPI
    IMPORTING
      E_KUNNR             = US_AG
    EXCEPTIONS
      NO_PARTNER_FOUND    = 1
      NO_PARTNER_SELECTED = 2
      OTHERS              = 3.

  CASE SY-SUBRC.
    WHEN 1.
*     Der Warenempfänger ist keinem Auftraggeber zugeordnet
      MESSAGE E211(VP) WITH US_WE.
    WHEN 2.
*     Bearbeitung des Kunden wurde abgebrochen, dann werden auch die
*     Orgdaten neu bestimmt (falls sie nicht im Transaktionseinstieg
*     festgelegt wurden)
      IF ORGDATEN_VORBELEGT IS INITIAL.
        CLEAR VBAK-VKORG.
        CLEAR VBAK-VTWEG.
        CLEAR VBAK-SPART.
      ENDIF.
      MESSAGE E113(VP) WITH US_WE.
  ENDCASE.

ENDFORM.                               " AG_BESTIMMEN