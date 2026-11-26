*eject
*----------------------------------------------------------------------*
*       FORM  CHARGENDATEN_SETZEN
*----------------------------------------------------------------------*
FORM chargendaten_setzen USING loc_matnr
                               loc_werks
                               loc_charg
                               loc_kzuml.
  CLEAR cl_mcha.
  CLEAR cl_mch1.
  CLEAR mcha.
  DATA: loc_rc_batch_db LIKE sy-subrc.

* Charge aus dem Puffer lesen
  CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
    EXPORTING
      matnr            = loc_matnr
      charg            = loc_charg
      werks            = loc_werks
      read_from_buffer = x
      read_from_db     = x
    IMPORTING
      batch_buffer     = mcha
      rc_batch_db      = loc_rc_batch_db
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Ist die Charge neu
  IF loc_rc_batch_db IS INITIAL.
    cl_batch_new = space.
  ELSE.
    cl_batch_new = x.
  ENDIF.

* Korrekte Workaera setzen für Werte, die in der Bestandsführung
* verändert werden könnten und noch nicht in der Sperrtabelle sind
  IF t158-trtyp EQ h AND
     mseg-kzbew NE 'O'. " batch has not been read - note 414165
    IF loc_kzuml IS INITIAL.
      mcha-lifnr = vm07m-lifch.
      mcha-licha = vm07m-licha.
      mcha-lwedt = vm07m-lwedt.
      mcha-vfdat = mseg-vfdat.
      mcha-hsdat = mseg-hsdat.
      mcha-qndat = vm07m-qndat.
      IF mcha-bwtar IS INITIAL.
        mcha-bwtar = mseg-bwtar.
      ENDIF.
    ELSE.
      mcha-lifnr = dm07m-umlifch.
      mcha-licha = dm07m-umlicha.
      mcha-lwedt = dm07m-umlwedt.
      mcha-vfdat = dm07m-umvfdat.
      mcha-hsdat = dm07m-umhsdat.
      mcha-qndat = dm07m-umqndat.
    ENDIF.
  ENDIF.

* Chargendaten übertragen
  IF kzdch EQ charge_auf_werk.
    MOVE-CORRESPONDING mcha TO cl_mcha.
    mcha_key-mandt = sy-mandt.
    mcha_key-matnr = xmcha_key-matnr = loc_matnr.
    mcha_key-werks = xmcha_key-werks = loc_werks.
    mcha_key-charg = xmcha_key-charg = loc_charg.
    cl_object = xmcha_key.
  ELSE.
    MOVE-CORRESPONDING mcha TO cl_mch1.
    mch1_key-mandt = sy-mandt.
    mch1_key-matnr = xmch1_key-matnr = loc_matnr.
    mch1_key-charg = xmch1_key-charg = loc_charg.
    cl_object = xmch1_key.
  ENDIF.


ENDFORM.                    "CHARGENDATEN_SETZEN