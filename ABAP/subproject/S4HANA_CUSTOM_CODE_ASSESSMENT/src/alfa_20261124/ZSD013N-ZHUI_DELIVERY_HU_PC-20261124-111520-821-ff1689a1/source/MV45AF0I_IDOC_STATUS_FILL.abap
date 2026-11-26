*----------------------------------------------------------------------*
*   INCLUDE MV45AF0I_IDOC_STATUS_FILL                                  *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  IDOC_STATUS_FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM idoc_status_fill USING us_edi_stop.

  DATA: da_posnr LIKE vbap-posnr.

  IF idoc_number NE space AND
     t180-trtyp NE chara AND
     us_edi_stop IS INITIAL.

*-- Belegnummer wird in ein Memory abgestellt, damit im EDI-Programm --*
*-- mit der Belegnummer Texte hinzugefügt werden kann -----------------*
    EXPORT vbak-vbeln TO MEMORY ID 'SDEDIVBELN'.
*-- Positionsnummer wird, wenn eindeutig, ins Memory eingestellt, damit*
*-- im EDI-Programm die geänderte Positionsnummer bekannt ist ---------*
    CLEAR da_posnr.

    LOOP AT xvbap WHERE updkz NE updkz_old.
      IF     da_posnr IS INITIAL.
        da_posnr = xvbap-posnr.
      ELSEIF da_posnr NE xvbap-posnr.
*       Geänderte Positionsnummer ist nicht eindeutig und kann deshalb
*       nicht gesetzt werden.
        CLEAR da_posnr.
        EXIT.
      ENDIF.
    ENDLOOP.
    EXPORT vbap-posnr FROM da_posnr TO MEMORY ID 'SDEDIPOSNR'.

*- Idoc-Status füllen  ------------------------------------------------*
    idoc_status-docnum = idoc_number.
    idoc_status-status = beleg_gebucht.
    idoc_status-msgid  = sy-msgid.
    idoc_status-msgno  = sy-msgno.
    idoc_status-msgv1  = sy-msgv1.
    idoc_status-msgty  = 'I'.
    idoc_status-msgv2  = sy-msgv2.
    idoc_status-msgv3  = sy-msgv3.
    idoc_status-msgv4  = sy-msgv4.
    APPEND idoc_status.

*- Idoc-Kontrollsatz füllen -------------------------------------------*
    CLEAR idoc_control.
    idoc_control = idoc_edidc.
    APPEND idoc_control.

*- Return Variablen für Workflow füllen -------------------------------*
    return_variables-wf_param = pid.
    return_variables-doc_number = idoc_number.
    APPEND return_variables.
    return_variables-wf_param = aot.
    return_variables-doc_number = businessobjekt.
    APPEND return_variables.
    return_variables-wf_param = apo.
    return_variables-doc_number = vbak-vbeln.
    APPEND return_variables.

*- Call Workflow ------------------------------------------------------*
    CALL FUNCTION 'IDOC_INPUT_CLOSE'
       EXPORTING
            workflow_result    = c_wf_result_ok
       TABLES
            idoc_control       = idoc_control
            idoc_status        = idoc_status
            return_variables   = return_variables
            serialization_info = serialization_info.

  ENDIF.

ENDFORM.                               " IDOC_STATUS_FILL
ENHANCEMENT-POINT IDOC_STATUS_FILL_10 SPOTS ES_SAPMV45A STATIC.