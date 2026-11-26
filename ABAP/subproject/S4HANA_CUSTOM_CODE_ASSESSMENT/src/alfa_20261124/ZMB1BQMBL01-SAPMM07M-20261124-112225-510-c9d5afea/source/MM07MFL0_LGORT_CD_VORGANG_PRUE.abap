*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_VORGANG_PRUEFEN
*&---------------------------------------------------------------------*
*       text: ueberpruefen, ob fuer die vorliegende Position cross-
*             docking Verfahren in Frage kommt
*----------------------------------------------------------------------*
*      <--P_CD_VORGANG
*----------------------------------------------------------------------*
FORM LGORT_CD_VORGANG_PRUEFEN CHANGING P_CD_VORGANG.

  DATA: STATU-AUFT  LIKE EKKO-STATU  VALUE 'E', " Bestellg aus Aufteiler
        STATU-SABST LIKE EKKO-STATU  VALUE 'S', " Sammelbestellung
        UPVOR_VG    LIKE EKPO-UPVOR  VALUE '3', " Unterpos.typ Leergut
        TRKEY_GR    LIKE TWZLA-KEYTR VALUE '200', "Goods Receipt
        ART_EXPLODE LIKE TWZLA-KZKSN.           " article exploded in GR


* nur Sammelbestellungen und Bestellungen aus Aufteiler
  IF  ( ( FUSS-ESTAK  EQ  STATU-AUFT  OR
          FUSS-ESTAK  EQ  STATU-SABST OR
      NOT FUSS-AUREL  IS  INITIAL     )          AND
* strukturierte Artikel sind komplett aussen vor; ein Sammelartikel
* selbst wird nicht behandelt aber die Varianten;
        ( FUSS-ATTYP  NE ATTYP-SAM  AND
          FUSS-ATTYP  NE ATTYP-VKS  AND
          FUSS-ATTYP  NE ATTYP-LOT  AND
          FUSS-ATTYP  NE ATTYP-DIS )             AND
        ( FUSS-UPTYP  NE UPTYP_LOT  AND
          FUSS-UPTYP  NE UPTYP_DIS  AND
          FUSS-UPTYP  NE UPTYP_SET )             AND
* Vollgutartikel und das gebundene Leergut sind aussen vor
        ( FUSS-UPVOR  NE UPVOR_VG )              AND
        ( FUSS-UPTYP  NE UPTYP_LG ) )            AND
* value added service ist aussen vor
***** begin EP 2.0
       FUSS-XVASH IS INITIAL or
       not XMBWL is initial and
      ( ( DM07M-ESTAK  EQ  STATU-AUFT  OR
          dM07M-ESTAK  EQ  STATU-SABST OR
      NOT vM07M-AUREL  IS  INITIAL     )          AND
* strukturierte Artikel sind komplett aussen vor; ein Sammelartikel
* selbst wird nicht behandelt aber die Varianten;
        ( vM07M-ATTYP  NE ATTYP-SAM  AND
          vM07M-ATTYP  NE ATTYP-VKS  AND
          vM07M-ATTYP  NE ATTYP-LOT  AND
          vM07M-ATTYP  NE ATTYP-DIS )             AND
        ( dM07M-UPTYP  NE UPTYP_LOT  AND
          dM07M-UPTYP  NE UPTYP_DIS  AND
          dM07M-UPTYP  NE UPTYP_SET )             AND
* Vollgutartikel und das gebundene Leergut sind aussen vor
        ( dM07M-UPVOR  NE UPVOR_VG )              AND
        ( dM07M-UPTYP  NE UPTYP_LG ) )            AND
* value added service ist aussen vor
       dM07M-XVASH IS INITIAL.
***** end EP 2.0


    IF FUSS-EBELN EQ CD_EBELN  AND
       FUSS-EBELP EQ CD_EBELP
       AND XMBWL IS INITIAL.                      "653231
* verhindert, dass fuer die gleiche Bestellpos. mehrmals CD aufgerufen
* wird
* HSt, 653231: nur optimieren bei Aufruf aus MB01/MB0A
      CLEAR P_CD_VORGANG.
    ELSE.
      P_CD_VORGANG = 'X'.
      CD_EBELN = FUSS-EBELN.
      CD_EBELP = FUSS-EBELP.
      if not xmbwl is initial.                    "EP 2.0
        fuss-estak = dm07m-estak.                 "EP 2.0
        fuss-aurel = vm07m-aurel.                 "EP 2.0
      endif.                                      "EP 2.0
    ENDIF.
  ELSE.
    CLEAR P_CD_VORGANG.
  ENDIF.



*   * BSI / note 813828 {
** dmx - EP2.0 (12.2002)  special treatment for structured articles:
**    Lot, Set, Display 'allowed' for CD if not 'exploded' in GR
*  IF  ( ( FUSS-ESTAK  EQ  STATU-AUFT  OR
*          FUSS-ESTAK  EQ  STATU-SABST OR
*      NOT FUSS-AUREL  IS  INITIAL     )    AND
*        ( FUSS-ATTYP  EQ ATTYP-LOT  OR
*          FUSS-ATTYP  EQ ATTYP-DIS  OR
*          FUSS-ATTYP  EQ ATTYP-VKS )       ).
*
**  check for BOM-explosion in GR
*      CALL FUNCTION 'STRUC_ART_KEY_TODO'
*          EXPORTING
*            PI_MATNR           = FUSS-MATNR
*            PI_WERKS           = FUSS-WERKS
**           PI_LOCNR           =
*            PI_ATTYP           = FUSS-ATTYP
*            PI_KEY             = TRKEY_GR
*          IMPORTING
*            PE_HEADFL          = ART_EXPLODE
*          EXCEPTIONS
*            NO_TWZLA_FOUND     = 1
*            OTHERS             = 99.
*          .

** dmx - EP2.0 (12.2002)  special treatment for structured articles:
**    Lot, Set, Display 'allowed' for CD if not 'exploded' in GR
  IF  ( ( FUSS-ESTAK  EQ  STATU-AUFT  OR
          FUSS-ESTAK  EQ  STATU-SABST OR
      NOT FUSS-AUREL  IS  INITIAL       )  AND
        ( FUSS-ATTYP  EQ  ATTYP-LOT   OR
          FUSS-ATTYP  EQ  ATTYP-DIS   OR
          FUSS-ATTYP  EQ  ATTYP-VKS     )  )
     OR
      NOT XMBWL IS INITIAL                 AND
      ( ( DM07M-ESTAK  EQ  STATU-AUFT  OR
          DM07M-ESTAK  EQ  STATU-SABST OR
      NOT VM07M-AUREL  IS  INITIAL       ) AND
        ( VM07M-ATTYP  EQ  ATTYP-LOT   OR
          VM07M-ATTYP  EQ  ATTYP-DIS   OR
          VM07M-ATTYP  EQ  ATTYP-VKS     )  ).


*   check for BOM-explosion in GR
    IF XMBWL IS INITIAL.
      CALL FUNCTION 'STRUC_ART_KEY_TODO'
          EXPORTING
            PI_MATNR           = FUSS-MATNR
            PI_WERKS           = FUSS-WERKS
*           PI_LOCNR           =
            PI_ATTYP           = FUSS-ATTYP
            PI_KEY             = TRKEY_GR
          IMPORTING
            PE_HEADFL          = ART_EXPLODE
          EXCEPTIONS
            NO_TWZLA_FOUND     = 1
            OTHERS             = 99.
    ELSE.
      CALL FUNCTION 'STRUC_ART_KEY_TODO'
          EXPORTING
            PI_MATNR           = MSEG-MATNR
            PI_WERKS           = MSEG-WERKS
*           PI_LOCNR           =
            PI_ATTYP           = VM07M-ATTYP
            PI_KEY             = TRKEY_GR
          IMPORTING
            PE_HEADFL          = ART_EXPLODE
          EXCEPTIONS
            NO_TWZLA_FOUND     = 1
            OTHERS             = 99.
    ENDIF.
*   * BSI / note 813828 }


*   struct. art. not exploded in GR
    IF ( ( SY-SUBRC EQ 0 AND ART_EXPLODE EQ 0 ) OR ( SY-SUBRC EQ 1 ) ).
      IF FUSS-EBELN EQ CD_EBELN  AND
         FUSS-EBELP EQ CD_EBELP
         AND XMBWL IS INITIAL.                      "653231
* verhindert, dass fuer die gleiche Bestellpos. mehrmals CD aufgerufen
* wird
* HSt, 653231: nur optimieren bei Aufruf aus MB01/MB0A
        CLEAR P_CD_VORGANG.
      ELSE.
        P_CD_VORGANG = 'X'.
        CD_EBELN = FUSS-EBELN.
        CD_EBELP = FUSS-EBELP.
*       * BSI / note 813828 {
        IF NOT XMBWL IS INITIAL.
          FUSS-ESTAK = DM07M-ESTAK.
          FUSS-AUREL = VM07M-AUREL.
        ENDIF.
*       * BSI / note 813828 }
      ENDIF.
    ENDIF.                                       " no BOM explosion

  ENDIF.








ENDFORM.                               " LGORT_CD_VORGANG_PRUEFEN