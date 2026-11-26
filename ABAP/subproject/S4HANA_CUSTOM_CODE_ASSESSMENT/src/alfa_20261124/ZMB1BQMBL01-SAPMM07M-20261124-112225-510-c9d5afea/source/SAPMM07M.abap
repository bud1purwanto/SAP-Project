*---------------------------------------------------------------------*
*                                                                     *
*        Modulpool fuer die Materialbewegungen                        *
*                                                                     *
*        B E S T A N D S F U E H R U N G                              *
*                                                                     *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*        Report-Header / Tabellen / Daten / Field-Symbols             *
*---------------------------------------------------------------------*
         INCLUDE MM07MTOP.

*---------------------------------------------------------------------*
*        PBO-Module zum Modulpool SAPMM07M                            *
*---------------------------------------------------------------------*
         INCLUDE MM07MO00.
         INCLUDE MM07MOLV.             "Output-Module für LVS

*---------------------------------------------------------------------*
*        PAI-Module zum Modulpool SAPMM07M                            *
*---------------------------------------------------------------------*
         INCLUDE MM07MI00.
         INCLUDE MM07MH00.             "Input-Module für Helpfunktionen

*-----------------------------------------------------------------------
*        FORM-Routinen ( alphabetisch )
*-----------------------------------------------------------------------
         INCLUDE MM07MFA0.
         INCLUDE MM07MFBB.
         INCLUDE MM07MFBC.
         INCLUDE MM07MFB0.
         INCLUDE MM07MFB1.
         INCLUDE MM07MFB7.
         INCLUDE MM07MFB9.
         INCLUDE MM07MFC0.
         INCLUDE MM07MFCL.
         INCLUDE MM07MFC9.
         INCLUDE MM07MFD0.
         INCLUDE MM07MFE0.
         INCLUDE MM07MFF0.
         INCLUDE MM07MFF9.
         INCLUDE MM07MFG0.
         INCLUDE MM07MFI0.
         INCLUDE MM07IFI1.
         INCLUDE MM07MFJ1.
         INCLUDE MM07MFJ2.
         INCLUDE MM07MFK0.
         INCLUDE MM07MFK1.
         INCLUDE MM07MFL0.
         INCLUDE MM07MFM0.
         INCLUDE MM07MMHD.
         INCLUDE MM07MFN0.
         INCLUDE MM07MFO0.
         INCLUDE MM07MFP0.
         INCLUDE MM07MFR0.
         INCLUDE MM07MFS0.
         INCLUDE MM07MFS8.
         INCLUDE MM07MFS9.
         INCLUDE MM07MFT0.
         INCLUDE MM07MFU0.
         INCLUDE MM07MFV0.
         INCLUDE MM07MFZ0.
         INCLUDE MM07MSE0.

*-----------------------------------------------------------------------
*        FORM-Routinen mit Funktionseinheiten
*-----------------------------------------------------------------------
         INCLUDE MM07MJVA.             "Formroutinen Joint Venture Accou
         INCLUDE MM07MLVS.             "Formroutinen Lagerverwaltung
         INCLUDE MM07MPOP.             "POP-UP-Abwicklungen
         INCLUDE MM07MPPS.             "Formroutinen Auftragsabwicklung
         INCLUDE MM07MQSS.             "Formroutinen Qualitätssicherung
         INCLUDE MM07MSTA.             "Formroutinen Bestandscontrolling
         INCLUDE FV61BF00.             "Nachrichtenfindung

INCLUDE MM07MFO1.
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
ENHANCEMENT-POINT SAPMM07M_02 SPOTS ES_SAPMM07M STATIC .

INCLUDE MM07MF01_SHORTLOCK. "396879

INCLUDE MM07MFE1.
INCLUDE MM07MF01_CALL_BADI_CONSI.        " note  663537 - Fashion

ENHANCEMENT-POINT SAPMM07M_01 SPOTS ES_SAPMM07M STATIC.

*INCLUDE MM07M_J_1BFIFONFGETO01.

*INCLUDE MM07M_J_1BFIFONFGETF01.