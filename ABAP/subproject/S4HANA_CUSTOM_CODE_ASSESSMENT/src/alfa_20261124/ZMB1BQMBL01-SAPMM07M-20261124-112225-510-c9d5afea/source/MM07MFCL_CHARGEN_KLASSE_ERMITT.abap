*eject
*---------------------------------------------------------------------*
*       FORM CHARGEN_KLASSE_ERMITTELN                                 *
*---------------------------------------------------------------------*
*       Die Klasse der Chargen wird ermittelt.                        *
*---------------------------------------------------------------------*
FORM chargen_klasse_ermitteln
  USING
    i_class
    i_matnr
    i_charg
    i_werks
    e_class
    e_exist.

  DATA:
    lv_cuobj            type cuobj,
    lv_inob_checked     TYPE c,
    lv_object           type objnum.

  CLEAR e_class.
  CLEAR e_exist.
  CLEAR lv_inob_checked.

CALL FUNCTION 'VB_GET_AND_WRITE_INOB_BUFFER'
  EXPORTING
    iv_matnr                  = i_matnr
    IV_WERKS                  = i_werks
    iv_charg                  = i_charg
  IMPORTING
    EV_CUOBJ                  = lv_cuobj
    EV_ALREADY_BUFFERED       = lv_inob_checked
    EV_OBJECT                 = lv_object.

  if lv_cuobj is initial.
    clear E_EXIST.
  else.
    E_EXIST = 'X'.
  ENDIF.

  IF E_EXIST = 'X'.
    IF CL_KZCLA IS INITIAL.
      CL_KZCLA = EINS.
    ENDIF.
  ELSEIF LV_INOB_CHECKED = 'X'.
    IF CL_KZCLA IS INITIAL.
      EXIT.
    ENDIF.
* Im Klassenpuffer schauen
  ELSE.
    CALL FUNCTION 'VB_BATCH_READ_CLOG_BUFFER'
      EXPORTING
        imp_object       = lv_object
      IMPORTING
        batch_class      = e_class
      EXCEPTIONS
        object_not_found = 1.
    IF sy-subrc IS INITIAL.
      e_exist = x.
      IF cl_kzcla IS INITIAL.
        cl_kzcla = eins.
      ENDIF.

*-- Keine Klassifizierung erwünscht bzw. notwendig
    ELSEIF cl_kzcla IS INITIAL.
      EXIT.
    ENDIF.
  ENDIF.

* Klasse der Materials/Chargen ermitteln
  IF NOT i_class IS INITIAL.
    e_class = i_class.
  ELSEIF e_class IS INITIAL.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material  = i_matnr
        plant     = i_werks
        classtype = cl_klart
      IMPORTING
        classtype = cl_klart
        class     = e_class
      EXCEPTIONS
        OTHERS    = 0.
  ENDIF.

*- distribution of batches - change global fields possible?
  DATA:
    lv_change_local_fields_only TYPE xfeld.

  CALL FUNCTION 'VB_CHRG_BATCH_DIST_STATUS_GET'
    EXPORTING
      i_matnr                    = i_matnr
      i_charg                    = i_charg
      i_werks                    = i_werks
    IMPORTING
      e_change_local_fields_only = lv_change_local_fields_only
    EXCEPTIONS
      no_material                = 1
      no_batch                   = 2
      no_plant                   = 3
      inconsistency              = 4
      OTHERS                     = 99.
  IF sy-subrc IS INITIAL.
    IF  NOT lv_change_local_fields_only IS INITIAL AND
            cl_kzcla GE 2.
*! due to distribution status only 'display' of global characteristics
      MESSAGE s011(vbw).
    ENDIF.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "CHARGEN_KLASSE_ERMITTELN