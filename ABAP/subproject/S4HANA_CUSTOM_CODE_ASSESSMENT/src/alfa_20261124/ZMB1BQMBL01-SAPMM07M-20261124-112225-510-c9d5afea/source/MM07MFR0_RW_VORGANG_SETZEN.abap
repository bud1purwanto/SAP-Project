*eject
*---------------------------------------------------------------------*
*       FORM RW_VORGANG_SETZEN                                        *
*---------------------------------------------------------------------*
*       Der Vorgang für das Rechnungswesen wird gesetzt.              *
*---------------------------------------------------------------------*
FORM rw_vorgang_setzen USING r-vgart LIKE t158-vgart.

DATA: l_wipbatch_active TYPE xfeld.

  CALL FUNCTION 'CO_WIPB_TCUWIPB_READ'
    IMPORTING
      e_wipbatch_active       = l_wipbatch_active
    EXCEPTIONS
      not_found               = 1
      OTHERS                  = 2.

  IF l_wipbatch_active IS NOT INITIAL.              "WIP batch active
ENHANCEMENT-SECTION     EHP4_RW_VORGANG_SETZEN_01 SPOTS ES_SAPMM07M.
    CASE r-vgart.
      WHEN vgart_wa.
        rw_vorgang = 'RMWA'.
      WHEN vgart_we.
        rw_vorgang = 'RMWE'.
      WHEN vgart_wf.
        rw_vorgang = 'RMWF'.
      WHEN vgart_wi.
        rw_vorgang = 'RMWI'.
      WHEN vgart_wl.
        rw_vorgang = 'RMWL'.
      WHEN vgart_wo.
        rw_vorgang = 'RMWE'.
      WHEN vgart_wq.
        rw_vorgang = 'RMWQ'.
      WHEN vgart_wr.
        rw_vorgang = 'RMRU'.
      WHEN vgart_ws.
        rw_vorgang = 'RMRU'.
      WHEN vgart_wz.
        rw_vorgang = 'RMWA'.
      WHEN OTHERS.
        rw_vorgang = 'RMWA'.
    ENDCASE.
END-ENHANCEMENT-SECTION.
  ELSE.                                          "WIP batch not active
ENHANCEMENT-SECTION     RW_VORGANG_SETZEN_02 SPOTS ES_SAPMM07M.
    CASE r-vgart.
      WHEN vgart_wa.
        rw_vorgang = 'RMWA'.
      WHEN vgart_we.
        rw_vorgang = 'RMWE'.
      WHEN vgart_wf.
        rw_vorgang = 'RMWF'.
      WHEN vgart_wi.
        rw_vorgang = 'RMWI'.
      WHEN vgart_wl.
        rw_vorgang = 'RMWL'.
      WHEN vgart_wo.
        rw_vorgang = 'RMWE'.
      WHEN vgart_wq.
        rw_vorgang = 'RMWQ'.
      WHEN vgart_wr.
        rw_vorgang = 'RMRU'.
      WHEN vgart_ws.
        rw_vorgang = 'RMRU'.
      WHEN vgart_wz.
        rw_vorgang = 'RMWA'.
      WHEN OTHERS.
        rw_vorgang = 'RMWA'.
    ENDCASE.
END-ENHANCEMENT-SECTION.
  ENDIF.

ENDFORM.