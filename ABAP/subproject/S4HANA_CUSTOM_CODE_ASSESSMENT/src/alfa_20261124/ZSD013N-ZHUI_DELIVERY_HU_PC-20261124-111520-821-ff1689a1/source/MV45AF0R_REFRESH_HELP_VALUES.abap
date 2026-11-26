*----------------------------------------------------------------------*
*   INCLUDE MV45AF0R_REFRESH_HELP_VALUES                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REFRESH_HELP_VALUES
*&---------------------------------------------------------------------*
*       refresh help values for refrehing loading listbox
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_HELP_VALUES.

  TYPE-POOLS VRM.
  DATA: WA_VALUES_ID TYPE VRM_ID.
  DATA: VALUES_IDS TYPE VRM_IDS.

  CALL FUNCTION 'VRM_GET_IDS'
       IMPORTING
            IDS = VALUES_IDS.

  DATA: VALUES_ID TYPE VRM_ID.

  LOOP AT VALUES_IDS INTO WA_VALUES_ID.
    SEARCH WA_VALUES_ID FOR 'SAP'.
    MOVE WA_VALUES_ID(SY-FDPOS) to VALUES_ID.
    CALL FUNCTION 'VRM_DELETE_VALUES'
         EXPORTING
              ID = VALUES_ID
    EXCEPTIONS
         ID_NOT_FOUND = 4.

    IF SY-SUBRC = 4.
*     EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " REFRESH_HELP_VALUES