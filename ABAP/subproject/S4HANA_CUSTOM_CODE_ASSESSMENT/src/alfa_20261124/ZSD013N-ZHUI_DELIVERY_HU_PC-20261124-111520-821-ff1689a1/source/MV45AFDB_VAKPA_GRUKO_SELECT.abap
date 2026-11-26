*---------------------------------------------------------------------*
*       FORM VAKPA_GRUKO_SELECT                                       *
*---------------------------------------------------------------------*
*       Referenzierbare Gruppenkontrakte lesen                        *
*---------------------------------------------------------------------*
FORM VAKPA_GRUKO_SELECT USING US_VBTYP
                              US_KUNDE
                              US_PARVW
                              US_VKORG
                              US_TRVOG
                              US_VTWEG
                              US_SPART
                              US_KUNNR
                              CH_HEADER_EXIST.

  SELECT * FROM VAKPA_REF WHERE KUNDE = US_KUNDE AND
                                PARVW = US_PARVW AND
                                VKORG = US_VKORG AND
                                TRVOG = US_TRVOG AND
                                VTWEG = US_VTWEG AND
                                SPART = US_SPART AND
                                KUNNR = US_KUNNR AND
                                VBTYP = US_VBTYP.

*   Gültigkeitszeitraum prüfen
    IF VAKPA_REF-DATAB <= SY-DATLO AND
       VAKPA_REF-DATBI >= SY-DATLO.

      CH_HEADER_EXIST = CHARX.
      HNW_VBAK-VBELN = VAKPA_REF-VBELN.
      HNW_VBAK-DATAB = VAKPA_REF-DATAB.
      HNW_VBAK-DATBI = VAKPA_REF-DATBI.
      HNW_VBAK-TRVOG = VAKPA_REF-TRVOG.
      HNW_VBAK-AUART = VAKPA_REF-AUART.
      APPEND HNW_VBAK.
    ENDIF.

  ENDSELECT.

ENDFORM.