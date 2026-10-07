import sys
import tempfile
import unittest
from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[2] / "scripts" / "python_app"
sys.path.insert(0, str(APP_ROOT))

from app.config import load_config
from app.database import Database
from app.service import AutoTecoService, ServiceError


class FakeGateway:
    def system_info(self, server):
        return {
            "info": {
                "system_info": {
                    "RFCSYSID": server.expected_sid,
                    "RFCIPADDR": server.expected_ip,
                    "RFCHOST": "test-host",
                }
            }
        }


class ServerVerificationTests(unittest.TestCase):
    def test_server_is_verified_before_use(self):
        config = load_config()
        with tempfile.TemporaryDirectory() as directory:
            database = Database(Path(directory) / "test.sqlite3")
            service = AutoTecoService(config, FakeGateway(), database)
            verified = service.verify_server("sandbox_new")
        self.assertEqual("TRD", verified["sid"])
        self.assertEqual("130", verified["client"])

    def test_unknown_server_is_rejected(self):
        config = load_config()
        with tempfile.TemporaryDirectory() as directory:
            database = Database(Path(directory) / "test.sqlite3")
            service = AutoTecoService(config, FakeGateway(), database)
            with self.assertRaises(Exception):
                service.verify_server("made_up")


if __name__ == "__main__":
    unittest.main()
