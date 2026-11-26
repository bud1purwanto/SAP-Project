*----------------------------------------------------------------------*
*   INCLUDE FV50XFGL                                                   *
*----------------------------------------------------------------------*
FORM GLOBAL_DATA_INIT.
  DATA: V50AGL-BATCH.

  SELECT SINGLE * FROM TVSHP.

  SELECT SINGLE * FROM TVPAD where uname = sy-uname.
  if tvpad-lgofi = 'X' and
     tvpad-fadat = sy-datum.
     move 'L'         to lepad_pakti-kzakt.
     move tvpad-uname to lepad_pakti-uname.
  endif.


  CALL FUNCTION 'BDC_RUNNING'
       IMPORTING
            BI_INFO         = BDCRUN
       EXCEPTIONS
            BI_INVALID_DATA = 1
            BI_NOTAKTIV     = 2
            OTHERS          = 3.

  GS_MHPAR-APPLI = 'L'.

  GS_MHPAR-REFMD = GC_REFMD-CHANGE_CREATE_DELETE.

  IF NOT BDCRUN-BDC_AKTIV IS INITIAL OR  "batch input
*    NOT BDCRUN-CDU_AKTIV IS INITIAL or  "call dialog using
     NOT BDCRUN-CTU_AKTIV IS INITIAL .  "call transaction using
     GS_MHPAR-GLOMD = GC_GLOMD-BACKGROUND.
  ENDIF.

  v50agl-huactive = 'X'.

* Synchron heißt: Alles, was in UPDATE TASK aufgerufen wird, wird
* mit SET UPDATE TASK LOCAL verbucht, somit ist alles in einem
* Rollback und die Nachrichten können weiterhin in UPDATE TASK
* verbucht werden
  IF V50AGL-SYNCHRON = CHARX.
    PERFORM SYNCHRON(SAPMV50A).
  ENDIF.

* documentary batch
  CALL FUNCTION 'VBDBBF_ACTIVE_CHECK_GENERAL'
    IMPORTING
      ev_docubatch_active = gf_docubatch_active
    EXCEPTIONS
      OTHERS              = 0.
  IF gf_docubatch_active IS NOT INITIAL.
    CALL FUNCTION 'VBDBDM_INIT'.
  ENDIF.

ENDFORM.