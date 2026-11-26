*&---------------------------------------------------------------------*
*&      Form  LESE_VOLLGUT
*&---------------------------------------------------------------------*
*       text: material_read in order to get matbf
*----------------------------------------------------------------------*
FORM LESE_VOLLGUT USING    P_H_WERKS LIKE IMSEG-WERKS
                           P_H_LGORT LIKE IMSEG-LGORT
                           P_H_MATNR LIKE IMSEG-MATNR
                  CHANGING H_MBEFU   LIKE MBEFU.

  DATA: H_MTCOM LIKE MTCOM,
        H_MTCOR LIKE MTCOR.

  CLEAR H_MTCOM.
  MOVE:  P_H_WERKS       TO H_MTCOM-WERKS,
         P_H_LGORT       TO H_MTCOM-LGORT,
         P_H_MATNR       TO H_MTCOM-MATNR,
         'MBEFU'       TO H_MTCOM-KENNG,
         SY-LANGU      TO H_MTCOM-SPRAS.
  MOVE X        TO H_MTCOM-XVKBW.

  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            SCHLUESSEL = H_MTCOM
       IMPORTING
            MATDATEN   = H_MBEFU
            RETURN     = H_MTCOR
       TABLES
            SEQMAT01   = DUMMY
       EXCEPTIONS
            PLANT_NOT_FOUND = 1.              "note 570790

  IF SY-SUBRC = 1.                            "note 570790
     SY-MSGID = 'M3'.                         "note 570790
     SY-MSGNO = '351'.                        "note 570790
     SY-MSGTY = 'E'.                          "note 570790
     SY-MSGV1 = P_H_MATNR.                    "note 570790
     SY-MSGV2 = P_H_WERKS.                    "note 570790
  ENDIF.                                      "note 570790

ENDFORM.                               " LESE_VOLLGUT