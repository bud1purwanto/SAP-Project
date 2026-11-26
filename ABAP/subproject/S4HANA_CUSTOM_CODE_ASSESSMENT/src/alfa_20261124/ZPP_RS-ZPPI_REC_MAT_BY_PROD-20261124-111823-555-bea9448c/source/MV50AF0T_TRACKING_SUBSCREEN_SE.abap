*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRACKING_SUBSCREEN_SE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TRACKING_SUBSCREEN_SET_DATA
*&---------------------------------------------------------------------*
FORM TRACKING_SUBSCREEN_SET_DATA.

  CALL FUNCTION 'XSI_SET_DELIVERY_DATA'
       EXPORTING
            I_TRTYP          = T180-TRTYP
            I_LIKP           = LIKP
       TABLES
            XLIPSVB          = XLIPS
            XVBPAVB          = XVBPA
            YVBPAVB          = YVBPA
            XVBADR           = XVBADR
            YVBADR           = YVBADR
       EXCEPTIONS
            UNEXPECTED_ERROR = 1
            OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* CALL FUNCTION 'HU_PACKING_REFRESH'.         "n_1359993/1521090

ENDFORM.                               " TRACKING_SUBSCREEN_SET_DATA