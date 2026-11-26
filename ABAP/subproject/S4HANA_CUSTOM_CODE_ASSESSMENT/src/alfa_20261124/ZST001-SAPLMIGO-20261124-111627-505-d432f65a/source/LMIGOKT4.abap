*----------------------------------------------------------------------*
*   INCLUDE LMIGOKT4                                                   *
*   Transfer data
*----------------------------------------------------------------------*
METHOD transfer_read.
  DATA: ls_goplant TYPE goplant,
        ls_got001l TYPE got001l.
  DATA: cs_displ_mseg TYPE mseg.     "for saving display data  "H702056
  CHECK NOT cs_goitem-ummat IS INITIAL OR
        NOT cs_goitem-umwrk IS INITIAL OR
        NOT cs_goitem-umlgo IS INITIAL.
* buffer removed as per note 409029
  IF NOT cs_goitem-ummat IS INITIAL.
    MOVE-CORRESPONDING cs_goitem TO cs_displ_mseg.               "702056
*   read material master
    CALL METHOD material_read
      EXPORTING
        i_transfer = abap_true
      CHANGING
        cs_goitem  = cs_goitem.
    IF s_action-display = abap_true.                             "702056
      MOVE-CORRESPONDING cs_displ_mseg TO cs_goitem.             "702056
    ENDIF.                                                       "702056
  ENDIF.
* read plant
  IF NOT cs_goitem-umwrk IS INITIAL.
    CLEAR ls_goplant.
    CALL METHOD lcl_migo_buffer=>plant_get
      EXPORTING
        i_plant   = cs_goitem-umwrk
      RECEIVING
        e_goplant = ls_goplant
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc = 0.
      cs_goitem-umname1 = ls_goplant-name1.
      cs_goitem-umxwmhd = ls_goplant-xwmhd.
    ENDIf.
  ENDIF.
* read storage location
  IF NOT cs_goitem-umlgo IS INITIAL.
    CLEAR ls_got001l.
    CALL METHOD lcl_migo_buffer=>storage_loc_get
      EXPORTING
        i_plant       = cs_goitem-umwrk
        i_storage_loc = cs_goitem-umlgo
      RECEIVING
        e_storage_loc = ls_got001l
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc = 0.
      cs_goitem-umlgobe = ls_got001l-lgobe.
    ENDIF.
  ENDIF.
ENDMETHOD.