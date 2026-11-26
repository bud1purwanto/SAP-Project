*---------------------------------------------------------------------*
*       FORM CHARGE_INIT                                              *
*---------------------------------------------------------------------*
*       Initialisierung der Chargendefinition (TCUCH)                 *
*       und feststellen der Klassenart für die Chargen.               *
*---------------------------------------------------------------------*
FORM charge_init.
  IF sy-tcode EQ 'MB05'.
* Abbruch: MB05 soll nicht im Dialog ausgeführt werden!
    MESSAGE e256(lb).
  ENDIF.

  CALL FUNCTION 'VB_INIT'.

  CALL FUNCTION 'VB_BATCH_DEFINITION'
    IMPORTING
      kzdch = kzdch
      kzdzv = kzdzv
      kzdws = kzdws              "ALRK011222SW
      autbn = autbn
      msgid = sy-msgid
      msgty = sy-msgty
      msgno = sy-msgno
    TABLES
      werke = wrkzv.
  IF NOT sy-msgid IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno.
  ENDIF.
  cl_table  = k_table_mcha.
  IF kzdch EQ charge_auf_werk.
    cl_ptable = k_table_mcha.
  ELSE.
    cl_ptable = k_table_mch1.
  ENDIF.
  CALL FUNCTION 'CLOB_GET_CLASSTYPE_FOR_BATCH'
    EXPORTING
      table                = cl_table
      ptable               = cl_ptable
      spras                = sy-langu
    IMPORTING
      classtype            = cl_klart
      typetext             = cl_artxt
    EXCEPTIONS
      classtype_not_found  = 01
      classtype_not_active = 02.


  CASE sy-subrc.
* if customer works with batches in general the error from the function
* is a really problem, because classification data might be lost.
* Therefore the following source will issue an error if any batch exist.
* There is still the gap in source that possibly the first batch will
* be created without classification data. See as well notes 195765
* and 27106.
    WHEN 1.
      SELECT * FROM mch1 UP TO 1 ROWS.                  "#EC CI_NOWHERE
      ENDSELECT.
      IF sy-subrc IS INITIAL.
        MESSAGE e662(vk) WITH cl_klart.
      ELSE.
        MESSAGE w662(vk) WITH cl_klart.
      ENDIF.
    WHEN 2.
      SELECT * FROM mch1 UP TO 1 ROWS.                  "#EC CI_NOWHERE
      ENDSELECT.
      IF sy-subrc IS INITIAL.
        MESSAGE e663(vk) WITH cl_klart.
      ELSE.
        MESSAGE w663(vk) WITH cl_klart.
      ENDIF.
  ENDCASE.


* documentary batch
  IF xmbwl = x.
    CALL FUNCTION 'VBDBBF_ACTIVE_CHECK_GENERAL'
      IMPORTING
        ev_docubatch_active = g_docubatch_active
      EXCEPTIONS
        OTHERS              = 99.
    IF sy-subrc IS NOT INITIAL.
      CLEAR g_docubatch_active.
    ENDIF.
  ENDIF.

ENDFORM.                    "CHARGE_INIT