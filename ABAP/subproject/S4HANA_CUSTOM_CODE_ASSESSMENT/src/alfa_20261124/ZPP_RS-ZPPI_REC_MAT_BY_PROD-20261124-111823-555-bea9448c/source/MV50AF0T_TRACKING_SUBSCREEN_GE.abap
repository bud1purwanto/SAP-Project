*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRACKING_SUBSCREEN_GE                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TRACKING_SUBSCREEN_GET_DATA
*&---------------------------------------------------------------------*
FORM TRACKING_SUBSCREEN_GET_DATA.

*-> begin delete: note 398165
*  CALL FUNCTION 'XSI_GET_DELIVERY_DATA'
*       TABLES
*            XVBPAVB          = XVBPA
*            YVBPAVB          = YVBPA
*       EXCEPTIONS
*            OTHERS           = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*-> end delete: note 398165

* Workaround: Filter invalid FCODES
  IF FCODE NS '_T'   AND
     FCODE NS 'T\'   AND
     FCODE NE 'UCNX' AND
     FCODE NE 'ENT1'.
    FCODE = 'ENT1'.
  ENDIF.

ENDFORM.                               " TRACKING_SUBSCREEN_GET_DATA