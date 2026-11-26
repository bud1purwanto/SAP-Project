*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE lmigotop.                          " Global Data
  INCLUDE lmigouxx.                          " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************

  INCLUDE lmigopbo.  " PBO modules
  INCLUDE lmigopai.  " PAI modules
  INCLUDE lmigopov.  " POV modules

  INCLUDE lmigobu2.  " Buffer
  INCLUDE lmigocu2.  " Cursor
  INCLUDE lmigoda2.  " Detail tabstrip account
  INCLUDE lmigoda4.  " Detail tabstrip MAA - MAA-DEV
  INCLUDE lmigodb2.  " Detail tabstrip batch
  INCLUDE lmigodb4.  " Detail tabstrip documentary batch
  INCLUDE lmigodc2.  " Detail carrier
  INCLUDE lmigodd2.  " Detail tabstrip destination
  INCLUDE lmigode2.  " Default values kernel section
  INCLUDE lmigodf2.  " Detail tabstrip freight
  INCLUDE lmigodi2.  " Detail tabstrip import
  INCLUDE lmigodl2.  " Dynpro locator
  INCLUDE lmigodm2.  " Detail tabstrip material
  INCLUDE lmigodn2.  " Detail tabstrip output determination (NAST)
  INCLUDE lmigodr4.  " Detail Retail generic articles
  INCLUDE lmigodo2.  " Detailobject (abstract)
  INCLUDE lmigodp2.  " Detail tabstrip purchase order
  INCLUDE lmigodo4.  " Detail tabstrip order
  INCLUDE lmigodp4.  " Detail tabstrip partners
  INCLUDE lmigodp6.  " Detail tabstrip PO components    " Outsourced Manufacturing EhP 4
  INCLUDE lmigodt4.  " Detail tabstrip transfer po
  INCLUDE lmigodt6.  " Detail TAKE_IT
  INCLUDE lmigodt8.  " Detail tabstrip transfer
  INCLUDE lmigodq2.  " Detail tabstrip quantity
  INCLUDE lmigodt2.  " Detail tabstrip taxes
  INCLUDE lmigods2.  " Detail tabstrip serial numbers
  INCLUDE lmigodw2.  " Detail tabstrip wm
  INCLUDE lmigodx2.  " Detail tabstrip ewm
  INCLUDE lmigody2.  " Detail tabstrib external dynpro for internal
  INCLUDE lmigoen2.  " Environment
  INCLUDE lmigoeq2.  " Enqueue
  INCLUDE lmigofh2.  " Field help
  INCLUDE lmigofl2.  " First line
  INCLUDE lmigofr2.  " Framework
  INCLUDE lmigogl2.  " Globals
  INCLUDE lmigohc2.  " Header carrier
  INCLUDE lmigoht2.  " HTML-help
  INCLUDE lmigohd2.  " Header tabstrip document info
  INCLUDE lmigohg2.  " Header tabstrip general
  INCLUDE lmigohi2.  " Header tabstrip foreign trade
  INCLUDE lmigoho2.  " Headerobject (abstract)
  INCLUDE lmigohp2.  " Header tabstrip people
  INCLUDE lmigohv2.  " Header tabstrip vendor
  INCLUDE lmigojb2.  " Nota fiscal
  INCLUDE lmigobo2.  " BOM parameters
  INCLUDE lmigoin1.  " Initialization routine
  INCLUDE lmigoke2.  " Kernel
  INCLUDE lmigolo2.  " Application log
  INCLUDE lmigopr2.  " Predocument
  INCLUDE lmigosm2.  " Screenmanager
  INCLUDE lmigosm4.  " Screenmodification
  INCLUDE lmigoso2.  " Screenobject (abstract)
  INCLUDE lmigosp2.  " Split quantity
  INCLUDE lmigods6.  " Determine stock
  INCLUDE lmigosr2.  " Search functions
  INCLUDE lmigost2.  " GUI status
  INCLUDE lmigoti2.  " Titlebar
  INCLUDE lmigoto2.  " Toggler
  INCLUDE lmigotp2.  " Tips
  INCLUDE lmigoca2.  " Control area
  INCLUDE lmigogd2.  " Grid display
  INCLUDE lmigotr2.  " Trace
  INCLUDE lmigotv2.  " Tableview
  INCLUDE lmigotr4.  " Tree
  INCLUDE lmigotrb.  " New tree main structure
  INCLUDE lmigotrc.  " New tree node base class
  INCLUDE lmigore1.  " Reservation
  INCLUDE lmigodr2.  " Detail tabstrip reservation
  INCLUDE lmigoar2.  " Archiving

*  INCLUDE LMIGODE3.

  INCLUDE lmigoiis.  " IS2ERP, contains dummy modules

ENHANCEMENT-POINT SAPLMIGO_01 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-POINT SAPLMIGO_03 SPOTS ES_SAPLMIGO STATIC .

  INCLUDE lmigoo01.
  INCLUDE lmigoo02.  " EWM Integration: Scrap Indicator
  INCLUDE lmigoi01.  " EWM Integration: Scrap Indicator

  INCLUDE iuid_migo. " IUID Enhancements