*---------------------------------------------------------------------*
*       FORM SADR_SELECT                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VS_ADRNR                                                      *
*---------------------------------------------------------------------*
FORM SADR_SELECT USING VS_ADRNR
*#MOSbegin----------------------------------rearrange address management
                       VS_ADRNP
                       VS_ADRDA.
  DATA: READ_SADR_ONLY.
  DATA: DA_PERSNUMBER TYPE AD_PERSNUM.
  DATA: DA_VBADR TYPE VBADR.

  IF VS_ADRDA CA 'ABC'.
    READ_SADR_ONLY = CHARX.
  ELSE.
    CLEAR READ_SADR_ONLY.
  ENDIF.
*#MOSend------------------------------------rearrange address management
  CLEAR: XVBADR, YVBADR.               "P30K073004/30E
  CLEAR SADR.
  READ TABLE XVBADR WITH KEY VS_ADRNR.
  IF SY-SUBRC NE 0.
*#MOSbegin--------------- ------------------rearrange address management
*   select single * from sadr where adrnr = vs_adrnr
*                              and   natio = space.
    ADDRESS_SELECTION-ADDRNUMBER = VS_ADRNR.
    ADDRESS_SELECTION-NATION     = SPACE.
* address_selection-date       = likp-lfdat.  " not yet implemented
    CALL FUNCTION 'SD_ADDRESS_GET'
         EXPORTING
              FIF_ADDRESS_NUMBER      = ADDRESS_SELECTION-ADDRNUMBER
              FIF_PERSONAL_NUMBER     = DA_PERSNUMBER
              FIF_ADDRESS_INDICATOR   = VS_ADRDA
              FIF_READ_SADR_ONLY      = READ_SADR_ONLY
         IMPORTING
              FES_ADDRESS             = DA_VBADR
         EXCEPTIONS
              ADDRESS_NOT_FOUND       = 1
              ADDRESS_TYPE_NOT_EXISTS = 2
              NO_PERSON_NUMBER        = 3
              OTHERS                  = 4.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*#MOSend------------------------------------rearrange address management
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING DA_VBADR TO SADR.
      MOVE-CORRESPONDING DA_VBADR TO XVBADR.
      APPEND XVBADR.
    ENDIF.
  ENDIF.
ENDFORM.