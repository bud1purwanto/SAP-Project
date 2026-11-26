*----------------------------------------------------------------------*
*   INCLUDE MV45AO0W_WMITX_SELECT                                      *
*----------------------------------------------------------------------*

MODULE WMITX_SELECT OUTPUT.

  DATA: DA_WWMI  LIKE  WWMI,
        DA_WWMIT LIKE  WWMIT.


* wurde Katalog gelöscht, so auch die Bezeichnung löschen
  IF VBKD-WMINR IS INITIAL.
    CLEAR WWMIT-WMITX.
  ENDIF.

  CHECK NOT VBKD-WMINR IS INITIAL.

  CALL FUNCTION 'ADV_MED_READ'
       EXPORTING
            PI_ADV_MED        =  VBKD-WMINR
            PI_WITH_TEXT      =  'X'
            PI_LANGUAGE       =  SY-LANGU
*    TABLES
*          PE_T_WWMIT        =
       CHANGING
            PE_WWMI           =  DA_WWMI
            PE_WWMIT          =  DA_WWMIT
     EXCEPTIONS
         ADV_MED_NOT_FOUND = 1
         OTHERS            = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3  SY-MSGV4.
  ELSE.
    WWMIT-WMITX = DA_WWMIT-WMITX.

    IF RV45A-CCODE_HEAD IS INITIAL.
      RV45A-CCODE_HEAD = DA_WWMI-CCODE.
    ENDIF.
  ENDIF.



ENDMODULE.




























