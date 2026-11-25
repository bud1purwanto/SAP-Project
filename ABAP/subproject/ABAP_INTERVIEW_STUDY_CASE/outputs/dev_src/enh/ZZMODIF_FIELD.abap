ENHANCEMENT 1  .
*******************************************************
* Created by: William
* Created on: 18.10.2012
* Usage: Screen untuk Field Plant menjadi editable
*        untuk kondisi:
*        - tcode bukan VA03,
*        - overall status VBUP-GBSTA selain 'C'
*******************************************************
DATA: DGBSTA LIKE VBUP-GBSTA.

IF ( SY-TCODE NE 'VA03' AND
  SY-TCODE NE 'VA23' AND
  SY-TCODE NE 'ZVA03A'
  ) .

"Add by yulius - Disable filed order qty
    CASE SCREEN-NAME.
       WHEN 'RV45A-KWMENG'.
         SCREEN-INPUT = 0.
        MODIFY SCREEN.
    ENDCASE.
"End add by yulius - Disable filed order qty

  DGBSTA = XVBUP-GBSTA.
    IF DGBSTA NE 'C'.
     CASE SCREEN-NAME.
       WHEN 'VBAP-WERKS'.

        SCREEN-ACTIVE = 1.
        SCREEN-INPUT  = 1.
        MODIFY SCREEN.

       WHEN 'VBAP-LGORT'.

        SCREEN-ACTIVE = 1.
        SCREEN-INPUT  = 1.
        MODIFY SCREEN.

     ENDCASE.
     ENDIF.

ENDIF.

ENDENHANCEMENT.
