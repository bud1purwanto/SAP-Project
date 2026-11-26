*----------------------------------------------------------------------*
*   INCLUDE MV45AI0X_XVBEPDG_AKTUALISIEREN                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  XVBEPDG_AKTUALISIEREN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
         module xvbepdg_aktualisieren input.

           clear i_vbepdg_wa.
* wenn das Material kein Gefahrgutkennzeichen hat, wird es nicht
* in der Anhangstabelle VBEPDG abgespeichert.

*   Überprüfung ob Gefahrgutkennzeichenprofil gefahrgutrelevant
           CALL FUNCTION 'SD_PROFL_CHECK'
                EXPORTING
                     PROFL  = vbapd-profl
                EXCEPTIONS
                     NO_DG  = 1
                     OTHERS = 2.

           if sy-subrc <> 0.
             exit.
           endif.

* Belegnummer, Positionsnummer und Einteilungsnummer
           move-corresponding vbep to i_vbepdg_wa.

           call function 'SD_VBEPDG_INITIALIZE'
                EXPORTING
                     i_vbepdg_wa = i_vbepdg_wa
                IMPORTING
                     cf_dataloss = r185d-dataloss
                EXCEPTIONS
                     others      = 10.

         endmodule.                    " XVBEPDG_AKTUALISIEREN  INPUT