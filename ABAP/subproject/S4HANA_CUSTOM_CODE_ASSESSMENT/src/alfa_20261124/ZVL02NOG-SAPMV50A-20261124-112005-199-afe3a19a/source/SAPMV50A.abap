*-----------------------------------------------------------------------
*        Modulpool Versand
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*        Report-Header / Tabellen / Daten / Field-Symbols
*-----------------------------------------------------------------------
         include mv50atop.
*-----------------------------------------------------------------------
*        PBO - Module alphabetisch geordnet
*-----------------------------------------------------------------------
         include mv50ao0a.
         include mv50ao0c.
         include mv50ao0d.
         include mv50ao0f.
         include mv50ao0m.
         include mv50ao0g.
         include mv50ao0i.
         include mv50ao0l.
         include mv50ao0p.
         include mv50ao0r.
         include mv50ao0s.
         include mv50ao0t.
         include mv50ao0w.
*-----------------------------------------------------------------------
*        Tabellen-spezifische Module   PBO
*-----------------------------------------------------------------------
         include mv50aolk.
         include mv50aolp.
*-----------------------------------------------------------------------
*        Textverarbeitung     Module   PBO
*-----------------------------------------------------------------------
         include mv50aotx.
*-----------------------------------------------------------------------
*        PAI - Module alphabetisch geordnet
*-----------------------------------------------------------------------
         include mv50ai0a.
         include mv50ai0b.
         include mv50ai0c.
         include mv50ai0d.
         include mv50ai0e.
         include mv50ai0f.
         include mv50ai0g.
         include mv50ai0l.
         include mv50ai0m.
         include mv50ai0p.
         include mv50ai0r.
         include mv50ai0s.
         include mv50ai0t.
         include mv50ai0u.
         include mv50ai0v.
         include mv50ai0w.
*-----------------------------------------------------------------------
*        Tabellen-spezifische Module   PAI
*-----------------------------------------------------------------------
         include mv50ailp.
*-----------------------------------------------------------------------
*        Textverarbeitung     Module   PAI
*-----------------------------------------------------------------------
         include mv50aitx.
*-----------------------------------------------------------------------
*        FORM-Routinen alphabetisch geordnet
*-----------------------------------------------------------------------
         include mv50af0a.
         include mv50af0b.
         include mv50af0c.
         include mv50af0d.
         include mv50af0d_docubatch.
         include mv50af0e.
         include mv50af0f.
         include mv50af0f_apo_integration_2.
         include mv50af0i.
         include mv50af0k.
         include mv50af0l.
         include mv50af0m.
         include mv50af0n.
         include mv50af0p.
         include mv50af0r.
         include mv50af0s.
         include mv50af0s_set_global_data.
         include mv50af0t.
         include mv50af0u.
         include mv50af0v.
         include mv50af0w.
*-----------------------------------------------------------------------
*        FORM-Routinen für List-Processing
*-----------------------------------------------------------------------
         include mv50afli.
*-----------------------------------------------------------------------
*        FORM-Routinen Call Back Listviewer
*-----------------------------------------------------------------------
         include mv50alcb.
*-----------------------------------------------------------------------
*        FORM-Routinen für Änderungsbelege
*-----------------------------------------------------------------------
         include mv50afcd.
*-----------------------------------------------------------------------
*        FORM-Routinen für Datenbankzugriffe
*-----------------------------------------------------------------------
         include mv50afen.
         include mv50afdb.
         include mv50afpa.

*-----------------------------------------------------------------------
*        FORM-Routinen für HELP bei POV
*-----------------------------------------------------------------------
         include mv50av0v.

*-----------------------------------------------------------------------
*        FORM-Routinen für ALV GRID CONTROL
*-----------------------------------------------------------------------
         include mv50afst.

*-----------------------------------------------------------------------
*        FORM-Routinen für Terminpflege
*-----------------------------------------------------------------------
         include mv50afdm.

*-----------------------------------------------------------------------
*        Routinen der Nachrichtensteuerung
*-----------------------------------------------------------------------

         include fv61bf00.                                  "K11K084898

*-----------------------------------------------------------------------
*        FORM-Routinen für Dialog und Sammelgang gemeinsam
*-----------------------------------------------------------------------
         include fv50xinc.


*-----------------------------------------------------------------------
*        Forms for buffered access in 'BELEG_LESEN'
* ----------------------------------------------------------------------

         include mv50abuff.

*-----------------------------------------------------------------------
*        Forms for claims & returns data                    "SPE_RET
* ----------------------------------------------------------------------

         include /spe/ret_mv50adia_pbo.
         include /spe/ret_mv50adia_f01.
         include /spe/ret_mv50adia_f02.
         include /spe/ret_mv50adia_f03.
         include /spe/ret_mv50adia_f04.


*-----------------------------------------------------------------------
*        Forms for getting gobal data of common parts for LES_ATP
* ----------------------------------------------------------------------

         include fv50xatp.

*        Delivery split
         include fv50xdsp.
ENHANCEMENT-POINT SAPMV50A_05 SPOTS ES_SAPMV50A STATIC.

*-----------------------------------------------------------------------
*        Forms for Cross docking outbound                      "SPE_CD
*        CD relevance check from output control                "24.2.05
* ----------------------------------------------------------------------
         include /SPE/CD_MV50ACDREL.


ENHANCEMENT-POINT SAPMV50A_01 SPOTS ES_SAPMV50A STATIC.

* Please delete this comment, after having implemented the enhancement
**----------------------------------------------------------------------
**        Forms for Kanban
**----------------------------------------------------------------------
*         INCLUDE MV50AKAB.


*-----------------------------------------------------------------------
*        FORM-Routinen für Userexits
*-----------------------------------------------------------------------
         include mv50afzz.
         include mv50afz1.
         include mv50afz2.
         include mv50afz3.          "Userexit neu zu Release 3.0A
         include mv50afzk.          "Userexit 4.6A (KOMKG/KOMPG)
         include mv50afzl.          "Userexit 4.6A Liefergruppen
                                                               "n_693000
         include mv50afzp.          "Userexit for pricing screen input
         include mv50afzt.          "Userexit for text changes n_1657178

ENHANCEMENT-POINT SAPMV50A_02 SPOTS ES_SAPMV50A STATIC.

ENHANCEMENT-POINT SAPMV50A_03 SPOTS ES_SAPMV50A STATIC.

ENHANCEMENT-POINT SAPMV50A_04 SPOTS ES_SAPMV50A STATIC.

* SPE100 OUTB Message handling
  INCLUDE /SPE/MV50AF01.

* SPE100 OUTB Kits completeness check
  INCLUDE /SPE/MV50AF02.

* SPE Kit to Order
  INCLUDE /SPE/MV50AF03.

* New items with stock keeping units
  INCLUDE /SPE/MV50AF04.                                     "n_1614770

* SPE X-HU
  INCLUDE /spe/xhu_mv50af04.
  INCLUDE /spe/xhu_mv50af05.

* SPE MP 18.01.2005 Update of returns deliveries
  INCLUDE /SPE/RET_MV50AF0S.
  include /spe/ret_FV50XFIN.

***********************************************************************
*       Include of Industry Solutions (IIS)                           *
***********************************************************************
INCLUDE MV50AIIS.

INCLUDE MV50A_DISPLAY_ORDER_CRMF01.

INCLUDE /SPE/MV50AF_POD_INSERT_EKBE.

include /spe/sped_mv50a.

*INCLUDE MV50AF0F_FCODE_COMP_T.

INCLUDE MV50AF0C_COPY_SERIAL_NUMBERS_.

INCLUDE MV50AF0C_CUA_FCODE_BADI.

INCLUDE MV50A_SIT_BUCHENF01.

INCLUDE MV50A_GET_ITEMI01.

INCLUDE MV50A_START_VL03NI01.

* Includes for TM-ERP status/docflow UI
INCLUDE MV50A_TM_HANDLER_CLASS.
INCLUDE MV50A_TMF01.
INCLUDE MV50A_TM_PBO_1115.

ENHANCEMENT-POINT SAPMV50A_06 SPOTS ES_SAPMV50A STATIC .