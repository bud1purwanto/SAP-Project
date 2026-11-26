*&---------------------------------------------------------------------*
*&      Form  BOYKOTT_KOPF
*&---------------------------------------------------------------------*
*       - Pruefen der Partner auf Boykott-Faehigkeit                   *
*       - Welches Land ist die Frage ?                                 *
*       - Ueber alle Laender aus dem Kundenstamm gehen                 *
*----------------------------------------------------------------------*
*  ==>  US_KUAGV  : Auftraggeber   auf Kopfebene                       *
*  ==>  US_KUWEV  : Warenempfänger auf Kopfebene                       *
*  ==>  US_KURGV  : Regulierer     auf Kopfebene                       *
*  ==>  US_DIALOG : Kopierkennzeichen                                  *
*  <==  CH_SUBRC  : Systemkennzeichen                                  *
*----------------------------------------------------------------------*
FORM BOYKOTT_KOPF USING US_KUAGV
                        US_KUWEV
                        US_KURGV
                        US_DIALOG
                        CH_SUBRC.

  DATA: H_KUNNR  LIKE VBPA-KUNNR,
        H_BOYLD  LIKE T001-LAND1,
        H_SPERRE LIKE SY-SUBRC.

  CLEAR: CH_SUBRC,
         H_SPERRE.

*----Prüfung des Auftraggebers auf Boykottlistenzugehörigkeit
  H_KUNNR = US_KUAGV.
  CALL FUNCTION 'FT_SLS_PARTNER_DOCUMENT_CHECK'
    EXPORTING
      I_BASE_DOCUMENT  = '2VA'
      I_PARTNER_NUMBER = H_KUNNR
      I_COUNTRY_KNEX   = SPACE
    IMPORTING
      E_SPERRE         = H_SPERRE
      E_SLS_COUNTRY    = H_BOYLD
    EXCEPTIONS
      NOT_FOUND        = 1
      OTHERS           = 2.

  IF NOT ( H_SPERRE IS INITIAL ).

    IF US_DIALOG NE SPACE.
      MESSAGE W525 WITH 'AG' H_KUNNR H_BOYLD.
    ELSEIF US_DIALOG = SPACE AND
       NOT KOPIEREN IS INITIAL.
      MESSAGE I525 WITH 'AG' H_KUNNR H_BOYLD.
    ELSE.
      MESSAGE I525 WITH 'AG' H_KUNNR H_BOYLD.
      CH_SUBRC = 525.
      EXIT.
    ENDIF.

  ENDIF.

*----Prüfung des Warenempfängers auf Boykottlistenzugehörigkeit
  IF           US_KUWEV NE US_KUAGV
     AND NOT ( US_KUWEV IS INITIAL )
     AND       H_SPERRE IS INITIAL.

    H_KUNNR = US_KUWEV.
    CALL FUNCTION 'FT_SLS_PARTNER_DOCUMENT_CHECK'
      EXPORTING
        I_BASE_DOCUMENT  = '2VA'
        I_PARTNER_NUMBER = H_KUNNR
        I_COUNTRY_KNEX   = SPACE
      IMPORTING
        E_SPERRE         = H_SPERRE
        E_SLS_COUNTRY    = H_BOYLD
      EXCEPTIONS
        NOT_FOUND        = 1
        OTHERS           = 2.

    IF NOT ( H_SPERRE IS INITIAL ).

      IF US_DIALOG NE SPACE.
        MESSAGE W525 WITH 'WE' H_KUNNR H_BOYLD.
      ELSEIF US_DIALOG = SPACE AND
         NOT KOPIEREN IS INITIAL.
        MESSAGE I525 WITH 'AG' H_KUNNR H_BOYLD.
      ELSE.
        MESSAGE I525 WITH 'WE' H_KUNNR H_BOYLD.
        CH_SUBRC = 525.
        EXIT.
      ENDIF.

    ENDIF.

  ENDIF.

*----Prüfung des Regulierers auf Boykottlistenzugehörigkeit
  IF           US_KURGV NE US_KUAGV
     AND       US_KURGV NE US_KUWEV
     AND NOT ( US_KURGV IS INITIAL )
     AND       H_SPERRE IS INITIAL.

    H_KUNNR = US_KURGV.
    CALL FUNCTION 'FT_SLS_PARTNER_DOCUMENT_CHECK'
      EXPORTING
        I_BASE_DOCUMENT  = '2VA'
        I_PARTNER_NUMBER = H_KUNNR
        I_COUNTRY_KNEX   = SPACE
      IMPORTING
        E_SPERRE         = H_SPERRE
        E_SLS_COUNTRY    = H_BOYLD
      EXCEPTIONS
        NOT_FOUND        = 1
        OTHERS           = 2.

    IF NOT ( H_SPERRE IS INITIAL ).

      IF US_DIALOG NE SPACE.
        MESSAGE W525 WITH 'RG' H_KUNNR H_BOYLD.
      ELSEIF US_DIALOG = SPACE AND
         NOT KOPIEREN IS INITIAL.
        MESSAGE I525 WITH 'AG' H_KUNNR H_BOYLD.
      ELSE.
        MESSAGE I525 WITH 'RG' H_KUNNR H_BOYLD.
        CH_SUBRC = 525.
        EXIT.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    "BOYKOTT_KOPF