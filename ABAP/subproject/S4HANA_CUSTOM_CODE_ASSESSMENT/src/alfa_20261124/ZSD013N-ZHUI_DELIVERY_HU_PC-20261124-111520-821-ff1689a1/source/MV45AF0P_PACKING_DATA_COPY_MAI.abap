*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PACKING_DATA_COPY_MAI                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PACKING_DATA_COPY_MAIS
*&---------------------------------------------------------------------*
*       Kopieren des Verpackungsvorschlags aus dem Lieferplan in den
*       Auslieferungsauftrag.
*       Die Routine läuft erst beim Beleg sichern, da das Kopieren
*       des Verpackungsvorschlags aus dem Lieferplan nur dann
*       stattfinden darf, wenn beim Anlegen des Auslieferungsauftrags
*       kein Verpackungsvorschlag manuell oder per EDI erzeugt wurde.
*----------------------------------------------------------------------*
FORM PACKING_DATA_COPY_MAIS.

  DATA: BEGIN OF VVBAK OCCURS 1.
          INCLUDE STRUCTURE VBAK.
  DATA: END OF VVBAK.

  DATA: DA_FOUND_COPY(1) TYPE C,
        DA_ACTIVE(1) TYPE C.

* nur beim Anlegen eines Auslieferungsauftrags
  CHECK T180-TRTYP EQ CHARH AND
        VBAK-VBKLT EQ VBKLT_AUSL_AUFT.

* Aufruf Customer-Function zum Beeinflußen des Kopiervorgangs
  CALL CUSTOMER-FUNCTION '005'
       EXPORTING
            I_VBAK   = VBAK
       IMPORTING
            E_ACTIVE = DA_ACTIVE
            E_COPY   = DA_FOUND_COPY
       TABLES
            T_VBAP   = XVBAP
            T_VBFA   = XVBFA.

  IF DA_FOUND_COPY NE CHARX AND
     DA_ACTIVE = CHARX.
* falls überhaupt nicht kopiert werden soll -> Exit
    EXIT.
  ENDIF.

* Tabelle VVBAK erzeugen
  VVBAK = VBAK.
  APPEND VVBAK.

* Verpackungspositionsdaten für den Auslieferungsauftrag erzeugen
    CALL FUNCTION 'HU_PACKING_SALES_PROPOSAL'
       exporting
            IF_ANZEIGEMODUS          = T180-TRTYP
            IF_DUNKEL                = CHARX
            if_profile               = '0002'
            IS_VBAK                  = VBAK
            IT_XVBAP                 = XVBAP[]
            IT_XVBPA                 = XVBPA[]
       CHANGING
            CT_XVBFA                 = XVBFA[]
            CT_YVBFA                 = YVBFA[]
            CT_XVBAPF                = XVBAPF[].
  IF DA_ACTIVE IS INITIAL.
* prüfen, ob zur Position bereits ein Verpackungsvorschlag existiert -
* in diesem Fall wird bei Positionen, wo noch kein
* Verpackungsvorschlag existiert, aus dem Lieferplan kopiert
    LOOP AT XVBFA WHERE VBELV EQ VBAK-VBELN AND
                        VBTYP_N EQ CHARX AND
                        UPDKZ EQ UPDKZ_NEW.
      DA_FOUND_COPY = CHARX.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF DA_FOUND_COPY EQ CHARX.
* es gibt bereits einen Verpackungsvorschlag in der Position, deshalb
* werden zu den übrigen Positionen die Verpackungsvorschläge kopiert,
* weil davon ausgegangen wird, daß wenn es zu einer Position einen
* Verpackungsvorschlag gibt, auch die übrigen Positionen verpackt
* werden sollen
    PERFORM COPY_PACKING_PROPOSAL.
  ELSE.
* Kopiersteuerung Versand prüfen
    PERFORM COPY_CONDITION_CHECK CHANGING DA_FOUND_COPY.
* Verpackungsvorschlag nur kopieren, wenn es relevante Einträge in der
* TVCPL mit Kopierbedingung Versandelement gibt
    IF DA_FOUND_COPY EQ CHARX.
      PERFORM COPY_PACKING_PROPOSAL.
    ENDIF.
  ENDIF.

ENDFORM.                               " PACKING_DATA_COPY_MAIS