import subprocess
import sys

user_input = sys.argv[1]

subprocess.call(user_input, shell=True)
