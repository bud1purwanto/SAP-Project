*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MERKMALE_BEARBEITEN                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MERKMALE_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*       Merkmalswerte in der Konfiguration ändern
*----------------------------------------------------------------------*
MODULE  MERKMALE_BEARBEITEN.

  PERFORM PROCESS_CHARACTERISTIC(SAPFV45S) USING CHARX
                                        CHANGING SY-SUBRC.

ENDMODULE.