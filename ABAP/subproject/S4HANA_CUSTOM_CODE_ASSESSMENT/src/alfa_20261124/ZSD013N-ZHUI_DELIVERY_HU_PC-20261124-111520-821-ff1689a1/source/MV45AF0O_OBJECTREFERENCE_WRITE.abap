
************************************************************************
*         FORM OBJECTREFERENCE_WRITE                                   *
*----------------------------------------------------------------------*
* Schreiben der allgemeinen Objektreferenz beim Anlegen und Löschen    *
* 0. Only create or delete                                             *
* 1. Beim Anlegen müssen die Referenzdaten gefüllt sein                *
* 2. Bestimmen des Businessobjektes des zu erzeugenden Beleges         *
* 3. Bestimmen des eigenen Systems                                     *
* 4. Nachfolgerdaten füllen                                            *
* 5. Vorgängerdaten  füllen                                            *
* 6. Aufruf der FORMs zu den Objektreferenzen entspr. UPDKZ            *
************************************************************************
FORM OBJECTREFERENCE_WRITE TABLES US_ATTR_TAB    STRUCTURE BRELATTR
                           USING  US_VBAK        STRUCTURE VBAK
                                  US_VBAKKOM_REF STRUCTURE VBAKKOM_REF.

  DATA: US_OBJTYPE LIKE BAPIUSW01-OBJTYPE.
  DATA: US_LOGSYS  LIKE TBDLS-LOGSYS.
  DATA: DA_ROLEA LIKE BORIDENT,
        DA_ROLEB LIKE BORIDENT,
        DA_RELATIONTYPE LIKE BRELTYP-RELTYPE.
* Attributdaten
  DATA: DA_PZUO  LIKE VBREFITEM .

* 0. Only create or delete                                             *
  CHECK: XVBAK_UPDKZ = UPDKZ_NEW OR
         XVBAK_UPDKZ = UPDKZ_DELETE.
* 1. Beim Anlegen müssen die Referenzdaten gefüllt sein                *
  IF XVBAK_UPDKZ = UPDKZ_NEW.
     check not: us_vbakkom_ref-refobjecttype is initial,
                us_vbakkom_ref-refobjectkey  is initial,
                us_vbakkom_ref-refreltype    is initial.
  ENDIF.
* 2. Bestimmen des Businessobjektes des zu erzeugenden Beleges         *
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE   = US_VBAK-VBTYP
       IMPORTING
            E_BUSINESS_OBJECT = US_OBJTYPE
       EXCEPTIONS
            OTHERS            = 1.
* 3. Bestimmen des eigenen Systems                                     *
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
       IMPORTING
            OWN_LOGICAL_SYSTEM             = US_LOGSYS
       EXCEPTIONS
            OWN_LOGICAL_SYSTEM_NOT_DEFINED = 1
            OTHERS = 2.
  check sy-subrc = 0.
* 4. Nachfolgerdaten füllen                                            *
  DA_ROLEB-OBJKEY  = US_VBAK-VBELN.
  DA_ROLEB-OBJTYPE = US_OBJTYPE.
  DA_ROLEB-LOGSYS  = US_LOGSYS.
* 5. Vorgängerdaten  füllen                                            *
  DA_ROLEA-OBJKEY  = US_VBAKKOM_REF-REFOBJECTKEY.
  DA_ROLEA-OBJTYPE = US_VBAKKOM_REF-REFOBJECTTYPE.
  DA_ROLEA-LOGSYS  = US_VBAKKOM_REF-REFOBJECTLOGSYS.
* bei externe ist das VORL, bei R/3 R/3 kann das was anderes sein.
  DA_RELATIONTYPE  = US_VBAKKOM_REF-REFRELTYPE.        "'VORL'.

* n. Attributtabelle mit Belegnummer füllen
  LOOP AT US_ATTR_TAB.
       DA_PZUO                = US_ATTR_TAB-GATTRDATA.
       DA_PZUO-OBJECTTYPE     = US_OBJTYPE.
       DA_PZUO-VBELN          = US_VBAK-VBELN.
       US_ATTR_TAB-GATTRDATA  = DA_PZUO.
       MODIFY US_ATTR_TAB.
  ENDLOOP.
* 6. Aufruf der FORMs zu den Objektreferenzen entspr. UPDKZ            *
  CASE XVBAK_UPDKZ.
       WHEN UPDKZ_NEW.
            PERFORM OBJECTREFERENCE_CREAT TABLES US_ATTR_TAB
                                          USING  DA_ROLEA
                                                 DA_ROLEB
                                                 DA_RELATIONTYPE.
       WHEN UPDKZ_DELETE.
            PERFORM OBJECTREFERENCE_DELET USING DA_ROLEA
                                                DA_ROLEB
                                                DA_RELATIONTYPE.
  ENDCASE.

  CLEAR: US_VBAKKOM_REF.

ENDFORM.