import json
import subprocess
import sys
from pathlib import Path


def fix_token(token):
    for dash in ("\u2013", "\u2014", "\u2015", "\u2212"):
        token = token.replace(dash, "-")
    return token


def get_experiment_dir(tool, outdir, K, remain, trim, metric, grouped):
    outdir = str(Path(outdir).absolute())
    t_flag = int(remain)

    if grouped and tool == "lm":
        trim_flag = int(trim is not None)
        lim = 0.0 if trim is None else trim
        experiment = f"lm_grouped_tr{trim_flag}_lim{lim}"
    elif grouped and tool == "sx":
        trim_flag = int(trim is not None)
        lim = 0.0 if trim is None else trim
        experiment = f"simplex_grouped_tr{trim_flag}_lim{lim}"
    elif grouped:
        experiment = "ts_grouped"
    elif tool == "lm":
        trim_flag = int(trim is not None)
        lim = 0.0 if trim is None else trim
        experiment = f"lm_K{K}_t{t_flag}_tr{trim_flag}_lim{lim}"
    elif tool == "sx":
        trim_flag = int(trim is not None)
        lim = 0.0 if trim is None else trim
        experiment = f"simplex_K{K}_t{t_flag}_tr{trim_flag}_lim{lim}"
    else:
        experiment = f"ts_K{K}_t{t_flag}_{metric}"

    return Path(outdir) / experiment


def get_expected_inputs(tool, archivo_calibracion, archivo_evaluacion, outdir, K, remain, trim, metric, grouped):
    experiment_dir = get_experiment_dir(tool, outdir, K, remain, trim, metric, grouped)
    expected = {
        "archivo1": str(Path(archivo_calibracion).absolute()),
        "archivo2": str(Path(archivo_evaluacion).absolute()),
        "outdir": str(Path(outdir).absolute()),
        "experiment_dir": str(experiment_dir.absolute()),
    }

    if grouped:
        expected["grouped"] = True
    else:
        expected["K"] = K
        expected["t"] = remain

    if tool in {"lm", "sx"}:
        expected["trim"] = trim is not None
        expected["lim"] = 0.0 if trim is None else trim
    elif not grouped:
        expected["optimization"] = metric

    return expected, experiment_dir


def should_recalculate(experiment_dir):
    prompt = (
        f"\nEl experimento:\n"
        f"{experiment_dir}\n"
        "ya existe con la misma entrada.\n"
        "¿Sobrescribir y recalcular? [y/N]: "
    )
    try:
        answer = input(prompt).strip().lower()
    except EOFError:
        print("No se pudo leer la respuesta. Se cancela para no sobrescribir.")
        return False

    return answer in {"y", "yes", "s", "si", "sí"}


args = [fix_token(arg) for arg in sys.argv[1:]]

tool = args[0]
archivo_calibracion = args[1]
archivo_evaluacion = args[2]
outdir = args[3]

K = 100
remain = False
trim = None
metric = "ce"
grouped = False

i = 4
while i < len(args):
    token = args[i]

    if token in {"grouped", "--grouped"}:
        grouped = True
        i += 1
        continue

    if token in {"remain", "--remain"}:
        remain = True
        i += 1
        continue

    if token.startswith("--trim:") or token.startswith("trim:"):
        trim = float(token.split(":", 1)[1])
        i += 1
        continue

    if token in {"--trim", "trim"}:
        trim = float(args[i + 1])
        i += 2
        continue

    if tool == "ts" and token in {"ce", "dE", "DE"}:
        metric = token
        i += 1
        continue

    K = int(token)
    i += 1

if grouped:
    K = None
    remain = False
    metric = None

expected_inputs, experiment_dir = get_expected_inputs(
    tool,
    archivo_calibracion,
    archivo_evaluacion,
    outdir,
    K,
    remain,
    trim,
    metric,
    grouped,
)

metadata_path = experiment_dir / "metadata.json"
if metadata_path.is_file():
    try:
        with metadata_path.open() as f:
            metadata = json.load(f)
    except (OSError, json.JSONDecodeError):
        metadata = None

    if metadata is not None:
        saved_inputs = metadata.get("inputs", {})
        if all(saved_inputs.get(key) == value for key, value in expected_inputs.items()):
            if not should_recalculate(experiment_dir):
                print("Experimento cancelado. Se conservan los resultados existentes.")
                raise SystemExit(0)

base_dir = Path(__file__).resolve().parent

scripts = {
    "lm": base_dir / "toolkitLm.py",
    "sx": base_dir / "toolkitSimplex.py",
    "ts": base_dir / "toolkitTs.py",
}

cmd = [
    sys.executable,
    str(scripts[tool]),
    archivo_calibracion,
    archivo_evaluacion,
]

if grouped:
    cmd.append("--grouped")
else:
    cmd.append(str(K))

if tool == "ts" and not grouped:
    cmd.append(metric)

if not grouped:
    cmd.extend(["--t", "True" if remain else "False"])

if tool in {"lm", "sx"} and trim is not None:
    cmd.extend(["--trim", "True", "--lim", str(trim)])

cmd.extend(["--outdir", outdir])

result = subprocess.run(cmd)
raise SystemExit(result.returncode)
