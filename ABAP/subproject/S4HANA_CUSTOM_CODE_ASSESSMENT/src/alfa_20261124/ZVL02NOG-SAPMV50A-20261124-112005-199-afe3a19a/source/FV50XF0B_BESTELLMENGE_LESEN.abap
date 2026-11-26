***INCLUDE FV50XF0B_BESTELLMENGE_LESEN .
*---------------------------------------------------------------------*
*       FORM BESTELLMENGE_LESEN                                       *
*---------------------------------------------------------------------*
*       Lesen der Bestellposition bei Vorgängerbeleg Bestellung       *
*---------------------------------------------------------------------*
FORM bestellmenge_lesen USING value(if_vgbel) LIKE lips-vgbel
                              value(if_vgpos) LIKE lips-vgpos
                        CHANGING    ef_lsmeng LIKE vbap-lsmeng.

  DATA: BEGIN OF tekpo OCCURS 1.
          INCLUDE STRUCTURE ekpo.
  DATA: END   OF tekpo.
  DATA: BEGIN OF teket OCCURS 1.
          INCLUDE STRUCTURE eket.
  DATA: END   OF teket.

  ef_lsmeng = xekpo-menge.
* Gewünschtes bereits in Kopfzeile ?
  CHECK NOT ( xekpo-ebeln = if_vgbel AND
              xekpo-ebelp = if_vgpos     ).
* Gewünschtes in interner Tabelle ?
  READ TABLE xekpo WITH KEY ebeln = if_vgbel
                            ebelp = if_vgpos.
  IF sy-subrc = 0.
    ef_lsmeng = xekpo-menge.
    EXIT.
  ENDIF.

* Belegposition lesen
  xeket-ebelp = if_vgpos.
  CALL FUNCTION 'ME_READ_ITEM_SD'
    EXPORTING
      ebeln     = if_vgbel
      ebelp     = xeket-ebelp
    TABLES
      xekpo     = tekpo
      xeket     = teket
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

* Belegposition selektieren
  IF sy-subrc = 0.
    READ TABLE tekpo INDEX 1.
    xekpo = tekpo.
    APPEND xekpo.
    ef_lsmeng = xekpo-menge.
  ELSE.
    CLEAR xekpo.
    CLEAR ef_lsmeng.
  ENDIF.

ENDFORM.                    "BESTELLMENGE_LESEN