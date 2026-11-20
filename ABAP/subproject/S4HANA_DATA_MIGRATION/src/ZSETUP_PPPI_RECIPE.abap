*&---------------------------------------------------------------------*
*& Report ZSETUP_PPPI_RECIPE
*& Setup PP-PI Master Recipe (PLKO, MAPL, PLAS, PLPO) & Prod Version (MKAL)
*&---------------------------------------------------------------------*
REPORT ZSETUP_PPPI_RECIPE.

DATA: ls_plko TYPE plko,
      ls_mapl TYPE mapl,
      ls_plas TYPE plas,
      ls_plpo TYPE plpo,
      ls_mkal TYPE mkal.

* 1. Clean existing Recipe JRAAAI if any
DELETE FROM plko WHERE plnty = '2' AND plnnr = 'JRAAAI'.
DELETE FROM mapl WHERE plnty = '2' AND plnnr = 'JRAAAI'.
DELETE FROM plas WHERE plnty = '2' AND plnnr = 'JRAAAI'.
DELETE FROM plpo WHERE plnty = '2' AND plnnr = 'JRAAAI'.
DELETE FROM mkal WHERE matnr = 'JRAAAI' AND werks = '1000' AND verid = '0002'.

* 2. Insert PLKO (Recipe Header)
ls_plko-plnty = '2'.
ls_plko-plnnr = 'JRAAAI'.
ls_plko-plnal = '10'.
ls_plko-zaehl = '00000001'.
ls_plko-werks = '1000'.
ls_plko-ktext = 'Jumbo Roll PLE-18 Master Recipe'.
ls_plko-statu = '4'.
ls_plko-verwe = '1'.
ls_plko-plnme = 'KG'.
ls_plko-bmsch = '100.000'.
ls_plko-datuv = '20201210'.
INSERT plko FROM ls_plko.

* 3. Insert MAPL (Material Assignment)
ls_mapl-matnr = 'JRAAAI'.
ls_mapl-werks = '1000'.
ls_mapl-plnty = '2'.
ls_mapl-plnnr = 'JRAAAI'.
ls_mapl-plnal = '10'.
ls_mapl-zkriz = '0000001'.
ls_mapl-zaehl = '00000001'.
ls_mapl-datuv = '20201210'.
INSERT mapl FROM ls_mapl.

* 4. Insert PLAS & PLPO for Op 0010 (Operation)
CLEAR: ls_plas, ls_plpo.
ls_plas-plnty = '2'.
ls_plas-plnnr = 'JRAAAI'.
ls_plas-plnal = '10'.
ls_plas-plnkn = '00000001'.
ls_plas-zaehl = '00000001'.
ls_plas-datuv = '20201210'.
INSERT plas FROM ls_plas.

ls_plpo-plnty = '2'.
ls_plpo-plnnr = 'JRAAAI'.
ls_plpo-plnkn = '00000001'.
ls_plpo-zaehl = '00000001'.
ls_plpo-vornr = '0010'.
ls_plpo-steus = 'PI01'.
ls_plpo-arbid = '10000178'.
ls_plpo-werks = '1000'.
ls_plpo-ltxa1 = 'Extrusion Line 1 Waru'.
ls_plpo-pvzkn = '00000000'.
ls_plpo-bmsch = '100.000'.
ls_plpo-meinh = 'KG'.
INSERT plpo FROM ls_plpo.

* 5. Insert PLAS & PLPO for Op 0020 (Phase)
CLEAR: ls_plas, ls_plpo.
ls_plas-plnty = '2'.
ls_plas-plnnr = 'JRAAAI'.
ls_plas-plnal = '10'.
ls_plas-plnkn = '00000002'.
ls_plas-zaehl = '00000002'.
ls_plas-datuv = '20201210'.
INSERT plas FROM ls_plas.

ls_plpo-plnty = '2'.
ls_plpo-plnnr = 'JRAAAI'.
ls_plpo-plnkn = '00000002'.
ls_plpo-zaehl = '00000002'.
ls_plpo-vornr = '0020'.
ls_plpo-steus = 'PI01'.
ls_plpo-arbid = '10000178'.
ls_plpo-werks = '1000'.
ls_plpo-ltxa1 = 'Extrusion Production Phase'.
ls_plpo-pvzkn = '00000001'.
ls_plpo-bmsch = '100.000'.
ls_plpo-meinh = 'KG'.
INSERT plpo FROM ls_plpo.

* 6. Insert MKAL Production Version 0002 for PP-PI
ls_mkal-matnr = 'JRAAAI'.
ls_mkal-werks = '1000'.
ls_mkal-verid = '0002'.
ls_mkal-text1 = 'JR PLE-18 PP-PI Recipe (Line 1)'.
ls_mkal-adatu = '20201210'.
ls_mkal-bdatu = '99991231'.
ls_mkal-plnty = '2'.
ls_mkal-plnnr = 'JRAAAI'.
ls_mkal-alnal = '10'.
ls_mkal-stlal = '02'.
ls_mkal-stlan = '1'.
ls_mkal-bstmi = '0.000'.
ls_mkal-bstma = '99999999.000'.
INSERT mkal FROM ls_mkal.

COMMIT WORK AND WAIT.
WRITE: / 'SUCCESS: Master Recipe JRAAAI and Production Version 0002 created!'.
