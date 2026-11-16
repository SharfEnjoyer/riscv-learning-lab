# inst.py — example
import re, sys, pathlib
name = sys.argv[1]
txt = pathlib.Path(f"{name}.sv").read_text()
ports = re.findall(r'\b(input|output|inout)\b[^,;)]*\b(\w+)\s*[,;)]', txt)
print(f"{name} uut_{name} (")
for _, p in ports:
    print(f"    .{p}({p}),")
print(");")