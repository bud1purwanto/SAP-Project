import sys
import tempfile
import unittest
import zipfile
from io import BytesIO
from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[2] / "scripts" / "python_app"
sys.path.insert(0, str(APP_ROOT))

from app.config import load_config
from app.domain import (
    OrderResult,
    evaluate_eligibility,
    executable_dependency_groups,
    remove_reversed_movements,
)
from app.reporting import build_xlsx


class ConfigTests(unittest.TestCase):
    def test_python_mapping_contains_109_unique_order_types(self):
        config = load_config()
        self.assertEqual(109, len(config.order_group_by_type))
        self.assertEqual(31, len(config.groups["JR"]))
        self.assertEqual(18, len(config.groups["SR COMBINE"]))
        self.assertEqual(28, len(config.groups["SR ORIGINAL"]))
        self.assertEqual(32, len(config.groups["OTHERS"]))

    def test_production_transaction_is_disabled(self):
        config = load_config()
        self.assertFalse(config.server("prod").capabilities["transaction"])
        self.assertFalse(config.server("prod_win").capabilities["transaction"])
        self.assertTrue(config.server("sandbox_new").capabilities["transaction"])


class DomainTests(unittest.TestCase):
    def test_reversal_removes_original_and_reversal(self):
        rows = [
            {"MBLNR": "100", "MJAHR": "2026", "ZEILE": "001", "SMBLN": "", "SJAHR": "", "SMBLP": ""},
            {"MBLNR": "101", "MJAHR": "2026", "ZEILE": "001", "SMBLN": "100", "SJAHR": "2026", "SMBLP": "001"},
            {"MBLNR": "200", "MJAHR": "2026", "ZEILE": "001", "SMBLN": "", "SJAHR": "", "SMBLP": ""},
        ]
        result = remove_reversed_movements(rows)
        self.assertEqual(["200"], [row["MBLNR"] for row in result])

    def test_eligibility(self):
        self.assertEqual("ELIGIBLE", evaluate_eligibility(["I0002"], ["I0002"], ["I0045"])[0])
        self.assertEqual("NOT_ELIGIBLE", evaluate_eligibility(["I0002", "I0045"], ["I0002"], ["I0045"])[0])
        self.assertEqual("NOT_ELIGIBLE", evaluate_eligibility([], ["I0002"], ["I0045"])[0])

    def test_dependency_group_is_not_split(self):
        orders = [
            OrderResult(aufnr="A", dependency_group_id="G1", eligibility="ELIGIBLE"),
            OrderResult(aufnr="B", dependency_group_id="G1", eligibility="NOT_ELIGIBLE"),
            OrderResult(aufnr="C", dependency_group_id="G2", eligibility="ELIGIBLE"),
        ]
        groups = executable_dependency_groups(orders)
        self.assertNotIn("G1", groups)
        self.assertEqual(["C"], [order.aufnr for order in groups["G2"]])


class ReportTests(unittest.TestCase):
    def test_xlsx_is_valid_zip_with_group_sheet(self):
        run = {
            "id": "abc123",
            "server_id": "sandbox_new",
            "sid": "TRD",
            "client": "130",
            "environment": "sandbox",
            "mode": "REPORT",
            "date_from": "2026-10-01",
            "date_to": "2026-10-01",
            "mapping_version": "test",
            "state": "PREVIEW_READY",
        }
        payload = build_xlsx(run, [OrderResult(aufnr="100", group_name="JR", result="REL")])
        with zipfile.ZipFile(BytesIO(payload)) as archive:
            self.assertIn("xl/workbook.xml", archive.namelist())
            workbook = archive.read("xl/workbook.xml").decode("utf-8")
            self.assertIn('name="JR"', workbook)


if __name__ == "__main__":
    unittest.main()
