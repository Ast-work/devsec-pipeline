import subprocess
import sys

user_input = sys.argv[1]

allowed_commands = {
    "date": ["date"],
    "whoami": ["whoami"],
}

if user_input in allowed_commands:
    subprocess.run(allowed_commands[user_input], check=True)
else:
    print("Command not allowed")
