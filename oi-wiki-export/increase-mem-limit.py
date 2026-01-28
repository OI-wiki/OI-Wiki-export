#!/usr/bin/env python3

import subprocess

# Get the path to the texmf.cnf file
config_file = subprocess.check_output(["kpsewhich", "texmf.cnf"]).decode().strip()

memory_setting = "main_memory"
new_value = "12000000"

output_lines = []
with open(config_file, "r") as f:
    found = False
    for line in f:
        # If the line contains the memory setting, update its value
        if line.startswith(memory_setting):
            line = memory_setting + " = " + new_value + "\n"
            found = True
        output_lines.append(line)
    # If the setting is not present, add it to the end of the file
    if not found:
        output_lines.append(memory_setting + " = " + new_value + "\n")

with open(config_file, "w") as f:
    f.writelines(output_lines)
