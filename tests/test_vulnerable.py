import subprocess
import sys
import unittest
from pathlib import Path


APP = Path(__file__).resolve().parents[1] / "app" / "vulnerable.py"


class TestVulnerableApp(unittest.TestCase):

    def run_app(self, argument):
        return subprocess.run(
            [sys.executable, str(APP), argument],
            capture_output=True,
            text=True,
            check=True,
        )

    def test_date_command_allowed(self):
        result = self.run_app("date")
        self.assertNotIn("Command not allowed", result.stdout)

    def test_whoami_command_allowed(self):
        result = self.run_app("whoami")
        self.assertNotIn("Command not allowed", result.stdout)

    def test_invalid_command_rejected(self):
        result = self.run_app("anything")
        self.assertEqual(result.stdout.strip(), "Command not allowed")


if __name__ == "__main__":
    unittest.main()
