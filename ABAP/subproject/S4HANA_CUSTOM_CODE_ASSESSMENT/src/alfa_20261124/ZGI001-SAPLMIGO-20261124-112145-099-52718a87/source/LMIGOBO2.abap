*----------------------------------------------------------------------*
*   INCLUDE LMIGOBO2                                                   *
*   BOM explosion parameters
*----------------------------------------------------------------------*

CLASS lcl_migo_bom IMPLEMENTATION.

************************************************************************
* Create the BOM object and fill the initial data into
* the public section
************************************************************************
  METHOD constructor.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    CREATE OBJECT oref_settings EXPORTING i_action = 'MIGO_BOM'.
* Presets, if no user defaults in the database
    CALL METHOD oref_settings->preset( i_element = 'AUSKZ'
                                       i_active  = 'X' ).
    CALL METHOD oref_settings->preset( i_element = 'BREMS'
                                       i_active  = 'X' ).
    CALL METHOD oref_settings->preset( i_element = 'SCHGT'
                                       i_active  = ' ' ).
    CALL METHOD oref_settings->preset( i_element = 'BEIKZ'
                                       i_active  = ' ' ).
  ENDMETHOD.

************************************************************************
* Send the popup with the user defaults
************************************************************************
  METHOD gobom_popup.
    CALL METHOD gobom_fill EXPORTING i_werks = i_werks.
    gobom = s_gobom.
    CALL SCREEN 1200 STARTING AT 5 5.
    IF sy-ucomm = 'OK_BOM_GO'.
      s_gobom = gobom.
      CALL METHOD gobom_update EXPORTING i_werks = i_werks.
     ENDIF.
  ENDMETHOD.

************************************************************************
* Fill structure GODEFAULT with the current user defaults
************************************************************************
  METHOD gobom_fill.
    DATA: ls_goplant TYPE goplant,
          ls_element TYPE es_element.
* Default values from database
    s_gobom-auskz = oref_settings->get( 'AUSKZ' ).
    s_gobom-beikz = oref_settings->get( 'BEIKZ' ).
    s_gobom-brems = oref_settings->get( 'BREMS' ).
    s_gobom-schgt = oref_settings->get( 'SCHGT' ).
* CAPID and STLAN are set in table T159L (GOPLANT)
    CONCATENATE i_werks 'CAPID' INTO ls_element.
    s_gobom-capid = oref_settings->get( ls_element ).
    CONCATENATE i_werks 'STLAN' INTO ls_element.
    s_gobom-stlan = oref_settings->get( ls_element ).
    IF s_gobom-capid IS INITIAL.
      CALL METHOD lcl_migo_buffer=>plant_get
           EXPORTING  i_plant   = i_werks
           RECEIVING  e_goplant = ls_goplant
           EXCEPTIONS OTHERS   = 1.
      IF s_gobom-capid IS INITIAL.
        s_gobom-capid = ls_goplant-capid.
      ENDIF.
      IF s_gobom-stlan IS INITIAL.
        s_gobom-stlan = ls_goplant-stlan.
      ENDIF.
    ENDIF.
    CLEAR s_gobom-stlal.
  ENDMETHOD.

************************************************************************
* PBO
************************************************************************
  METHOD pbo.
* PBO-Functions from superclass (cursor handling, SFAC).
    CALL METHOD super->pbo.
    SET PF-STATUS 'BOM_POPUP'.
    SET TITLEBAR  'BOM_POPUP'.
  ENDMETHOD.

************************************************************************
* PAI
* Handle SY-UCOMM
************************************************************************
  METHOD pai.
    CALL METHOD super->pai.
* Evaluate SY-UCOMM
    CASE sy-ucomm.
      WHEN 'OK_BOM_GO'.
        SET SCREEN 0.
        LEAVE SCREEN.
    ENDCASE.
  ENDMETHOD.

************************************************************************
* Exit-command: Return to the caller.
************************************************************************
  METHOD exit_command.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDMETHOD.

************************************************************************
* Write the data from GOBOM to the user defaults
************************************************************************
  METHOD gobom_update.
    DATA: ls_element TYPE es_element.
    DEFINE d_set.
      call method oref_settings->set( i_element = &1
                                      i_active  = &2 ).
    END-OF-DEFINITION.
    d_set 'STLAL' s_gobom-stlal.
    d_set 'AUSKZ' s_gobom-auskz.
    d_set 'BEIKZ' s_gobom-beikz.
    d_set 'BREMS' s_gobom-brems.
    d_set 'SCHGT' s_gobom-schgt.
    CONCATENATE i_werks 'CAPID' INTO ls_element.
    CALL METHOD oref_settings->set( i_element = ls_element
                                    i_active  = s_gobom-capid ).
    CONCATENATE i_werks 'STLAN' INTO ls_element.
    CALL METHOD oref_settings->set( i_element = ls_element
                                    i_active  = s_gobom-stlan ).
  ENDMETHOD.

ENDCLASS.