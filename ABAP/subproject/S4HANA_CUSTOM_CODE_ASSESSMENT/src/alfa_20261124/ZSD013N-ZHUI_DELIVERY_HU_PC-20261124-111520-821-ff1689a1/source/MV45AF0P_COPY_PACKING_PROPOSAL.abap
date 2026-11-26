*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_COPY_PACKING_PROPOSAL                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  COPY_PACKING_PROPOSAL
*&---------------------------------------------------------------------*
*       Der Verpackungsvorschlag wird je Position kopiert
*----------------------------------------------------------------------*
FORM COPY_PACKING_PROPOSAL.

  DATA: BEGIN OF DA_XVBFA OCCURS 1,
           POSNV LIKE XVBFA-POSNV,
           UPDKZ LIKE XVBFA-UPDKZ,
        END OF DA_XVBFA.

  DATA: DA_DATA_CHANGED TYPE xfeld,
        DA_NUMBER_SHIPPING_UNITS LIKE SY-TABIX,
        DA_FOUND_SH_UNIT(1) TYPE C,
        DA_VBAK LIKE VBAK,
        DA_COUNTER LIKE SY-TABIX.

* Belegnummer übergeben
  DA_VBAK-VBELN = VBAK-VBELN.

  LOOP AT XVBAP WHERE VBELN EQ DA_VBAK-VBELN AND
                      UPDKZ NE UPDKZ_DELETE.
    CHECK XVBAP-ABGRU IS INITIAL.
* prüfen, ob zur Position bereits ein Verpackungsvorschlag existiert -
* in diesem Fall wird nicht aus dem Lieferplan
    LOOP AT XVBFA WHERE VBELV EQ VBAK-VBELN AND
                        POSNV EQ XVBAP-POSNR AND
                        VBTYP_N EQ CHARX AND
                        UPDKZ EQ UPDKZ_NEW.
* bereits beim Sichern vorhandene Einträge merken mit UPDKZ_OLD
      DA_XVBFA-POSNV = XVBFA-POSNV.
      DA_XVBFA-UPDKZ = UPDKZ_OLD.
      APPEND DA_XVBFA.
      DA_FOUND_SH_UNIT = CHARX.
      EXIT.
    ENDLOOP.
    IF DA_FOUND_SH_UNIT NE CHARX.
* Belegnummer des Referenzbelegs übergeben
      DA_VBAK-VGBEL = XVBAP-VGBEL.
* Verpackungsvorschlag aus dem Vorgängerbeleg kopieren
      CALL FUNCTION 'HU_COPY_PACKING_PROPOSAL'
          EXPORTING
               IS_VBAK                 = DA_VBAK
               IT_VBAP                 = XVBAP[]
          IMPORTING
               EF_DATA_CHANGED          = DA_DATA_CHANGED
          CHANGING
               CT_XVBFA                = XVBFA[]
               CT_YVBFA                = YVBFA[]
               CT_XVBAPF               = XVBAPF[]
          EXCEPTIONS
               PACKING_EXISTS          = 1.
    ENDIF.
    CLEAR DA_FOUND_SH_UNIT.
  ENDLOOP.

  SORT DA_XVBFA.
  LOOP AT XVBFA WHERE POSNV NE POSNR_LOW AND
                      VBTYP_N EQ CHARX AND
                      UPDKZ EQ UPDKZ_NEW.
    DA_XVBFA-POSNV = XVBFA-POSNV.
    DA_XVBFA-UPDKZ = UPDKZ_OLD.
    READ TABLE DA_XVBFA WITH KEY DA_XVBFA.
    IF SY-SUBRC NE 0.
      DA_XVBFA-POSNV = XVBFA-POSNV.
      DA_XVBFA-UPDKZ = XVBFA-UPDKZ.
      APPEND DA_XVBFA.
    ENDIF.
  ENDLOOP.

  LOOP AT DA_XVBFA WHERE UPDKZ EQ UPDKZ_NEW.
    MESSAGE I827 WITH DA_XVBFA-POSNV.
* Pos. &1: Der Verpackungsvorschlag wurde aus dem Referenzbeleg kopiert
  ENDLOOP.

ENDFORM.                               " COPY_PACKING_PROPOSAL