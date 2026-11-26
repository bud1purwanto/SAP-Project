*----------------------------------------------------------------------*
*   INCLUDE LMIGOHP2                                                   *
*----------------------------------------------------------------------*
*   Header tabstrip people implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_header_people IMPLEMENTATION.
************************************************************************
* Get the last setting from the user defaults and show it
************************************************************************
  METHOD constructor.
*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    CREATE OBJECT poref_people_default TYPE cl_mmim_userdefaults
      EXPORTING
        i_action = 'MIGO_PEOPLE'.
  ENDMETHOD.

************************************************************************
* At pbo, the last shown username is read and converted
************************************************************************
  METHOD pbo.
    p_usnam = poref_people_default->get( 'USER_SEARCH' ).
    IF NOT p_usnam IS INITIAL.
* Find telephone number and update buffer
      CALL METHOD lcl_migo_buffer=>name_and_phone_get
           EXPORTING i_usnam = p_usnam
           IMPORTING e_exnam = godynpro-username
                     e_telnr = godynpro-telusername.
    ENDIF.
* Routine must be below reading the name, otherwise basis rule 2
* will remove the telephone field in screen modification
    CALL METHOD super->pbo.
  ENDMETHOD.

************************************************************************
* Function ON REQUEST: Convert a new name
************************************************************************
  METHOD pai_header_people_search.
    DATA: l_adrname TYPE so_adrnam.
    CLEAR godynpro-telusername.
* User has deleted contact name
    IF godynpro-username IS INITIAL.
      CLEAR p_usnam.
      CALL METHOD poref_people_default->set
           EXPORTING i_element = 'USER_SEARCH'
                     i_active  = p_usnam.
      EXIT.
    ENDIF.
* Search name from string
    CALL METHOD lcl_migo_globals=>kernel->name_search
         EXPORTING i_string  = godynpro-username
         IMPORTING e_sapname = p_usnam
                   e_adrname = l_adrname
         EXCEPTIONS OTHERS = 1.
* S-Message if not found.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
* Set complete name on dynpro
    godynpro-username = l_adrname.
* Find telephone number and update buffer
    CALL METHOD lcl_migo_buffer=>name_and_phone_get
         EXPORTING i_usnam = p_usnam
         IMPORTING e_exnam = l_adrname
                   e_telnr = godynpro-telusername.
* Update settings in ESDUS under MIGO_PEOPLE/USER_SEARCH
    CALL METHOD poref_people_default->set
         EXPORTING i_element = 'USER_SEARCH'
                   i_active  = p_usnam.

  ENDMETHOD.

ENDCLASS.