*eject
*----------------------------------------------------------------------*
*       Form  Leerg_Stueli_Lesen
*----------------------------------------------------------------------*
*   Lesen der Leergut-Stückliste                                       *
*----------------------------------------------------------------------*
FORM LEERG_STUELI_LESEN USING VG_MATNR VG_MEINH.

  REFRESH SLCOMP.
  CALL FUNCTION 'MGW0_PACKAGING_COMPONENTS'
       EXPORTING
            MGW0_ARTICLE    = VG_MATNR
  "         MGW0_DATE_FROM  = SY-DATUM
  "         MGW0_DATE_TO    = SY-DATUM
  "         MGW0_PLANT      = '    '
            MGW0_UNIT       = VG_MEINH
       TABLES
            MGW0_COMPONENTS = SLCOMP
       EXCEPTIONS
            NOT_FOUND       = 01.

ENDFORM.