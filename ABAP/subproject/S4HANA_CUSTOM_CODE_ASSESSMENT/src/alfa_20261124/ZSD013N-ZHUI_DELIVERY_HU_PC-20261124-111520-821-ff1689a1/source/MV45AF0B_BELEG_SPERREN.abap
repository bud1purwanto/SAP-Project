*eject
*---------------------------------------------------------------------*
*       FORM BELEG_SPERREN                                            *
*---------------------------------------------------------------------*
*       Der Beleg wird komplett und exklusiv gesperrt                 *
*       US_INIT NE SPACE: Im Fehlerfall wird der Beleg initialisiert. *
*---------------------------------------------------------------------*
FORM BELEG_SPERREN USING VALUE(US_VBELN)
                         US_INIT.

  DATA: DA_VBELN LIKE VBAK-VBELN,
        DA_UNAME LIKE SY-UNAME,
        LV_SCENARIO_A    TYPE CHAR01,
        LV_CRM_LOCK_MODE TYPE CHAR01.


* Bei Ergebnisübernahme aus der Rückstandsauflösung ist ber. gesperrt
  IF BACKORDER_RESULT NE SPACE AND CALL_FUNCTION NE SPACE.
    GESPERRT = CHARX.
    EXIT.
  ENDIF.

  IF CALL_ACTIVITY EQ ACTIVITY_GOOD_MOVEMENT OR
     CALL_ACTIVITY EQ ACTIVITY_INVOICE_REQUEST.
    EXIT.
  ENDIF.

  CHECK: T180-TRTYP NE CHARA,
         NOT US_VBELN IS INITIAL.
* Sperre abfragen wg. Batchprogramme
  if T180-TRTYP eq CHARv.
    PERFORM BELEG_SPERREN_BATCH USING 'VBAK'.
  endif.

*-Szenario lesen
*  call function 'CRM_GET_SCENARIO'
*       exporting
*           is_vbak        = vbak
*           iv_updkz       = xvbak_updkz
*       importing
*           ev_scenario_a = lv_scenario_a.
*  if lv_scenario_a = chara.
*    lv_crm_lock_mode = lv_scenario_a.
*    if xvbak_updkz = updkz_new.
*      lv_crm_lock_mode = charx.
*    endif.
*  else.
*    lv_crm_lock_mode = crm_lock_mode.
*  endif.

  CALL FUNCTION 'SD_SALES_DOCUMENT_ENQUEUE'
       EXPORTING
            VBELN           = US_VBELN
*           i_crm_lock_mode = lv_crm_lock_mode
            i_check_scenario_a = charx
            i_vbak             = vbak
            i_xvbak_updkz      = xvbak_updkz
       EXCEPTIONS
            FOREIGN_LOCK   = 2
            SYSTEM_FAILURE = 3
            no_change      = 4.

  DA_UNAME = SY-MSGV1.

  if sy-subrc = 2 and call_from_crm = charx and not us_vbapkom-vgbel is initial.
     do 10 times.
        wait up to 1 seconds.
        CALL FUNCTION 'SD_SALES_DOCUMENT_ENQUEUE'
          EXPORTING
            VBELN              = US_VBELN
            i_check_scenario_a = charx
            i_vbak             = vbak
            i_xvbak_updkz      = xvbak_updkz
          EXCEPTIONS
            FOREIGN_LOCK   = 2
            SYSTEM_FAILURE = 3
            no_change      = 4.
       if sy-subrc = 0.
          exit.
       endif.
     enddo.
  endif.

  CASE SY-SUBRC.
    WHEN 2.
      DA_VBELN = VBAK-VBELN.
      IF US_INIT NE SPACE.
        PERFORM BELEG_INITIALISIEREN.
      ENDIF.
      VBAK-VBELN = DA_VBELN.
      PERFORM BELEG_ENTSPERREN_BTCH USING VBAK-VBELN.
      MESSAGE E042 WITH US_VBELN DA_UNAME.
    WHEN 3.
      MESSAGE A043.
    when 4.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

  GESPERRT = CHARX.

ENDFORM.