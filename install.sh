#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$ROOT_DIR/.toolkit2venv"
PYTHON_BIN=""
LOCAL_BIN_DIR="$HOME/.local/bin"
ESTIMATOR_CMD="$LOCAL_BIN_DIR/estimator"
PYTHON_VERSION_CHECK="import sys; raise SystemExit(0 if (3, 9) <= sys.version_info[:2] <= (3, 13) else 1)"

for candidate in python3.13 python3.12 python3.11 python3.10 python3.9 python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
        if "$candidate" -c "$PYTHON_VERSION_CHECK" >/dev/null 2>&1; then
            PYTHON_BIN="$candidate"
            break
        fi
    fi
done

if [ -z "$PYTHON_BIN" ]; then
    echo "No se ha encontrado una version de Python compatible en el sistema."
    echo "Se requiere Python entre 3.9 y 3.13."
    echo "En Ubuntu puedes instalar Python y venv con:"
    echo "  sudo apt update && sudo apt install python3 python3-venv"
    exit 1
fi

if ! "$PYTHON_BIN" -c "import venv" >/dev/null 2>&1; then
    echo "El modulo venv no esta disponible en $PYTHON_BIN."
    echo "En Ubuntu puedes instalarlo con:"
    echo "  sudo apt update && sudo apt install python3-venv"
    exit 1
fi

mkdir -p "$LOCAL_BIN_DIR"

if [[ ":$PATH:" != *":$LOCAL_BIN_DIR:"* ]]; then
    echo "Falta $LOCAL_BIN_DIR en PATH."
    echo "Anadelo y vuelve a ejecutar este instalador."
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

if [ ! -x "$VENV_DIR/bin/python" ]; then
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

if ! "$VENV_DIR/bin/python" -c "$PYTHON_VERSION_CHECK" >/dev/null 2>&1; then
    echo "El entorno virtual existente usa una version de Python fuera del rango soportado."
    echo "Se requiere Python entre 3.9 y 3.13."
    echo "Elimina $VENV_DIR y vuelve a ejecutar este instalador."
    exit 1
fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip

if "$VENV_DIR/bin/python" -c "import sys; raise SystemExit(0 if sys.version_info[:2] == (3, 9) else 1)" >/dev/null 2>&1; then
    "$VENV_DIR/bin/python" -m pip install numpy==2.0.1 scipy==1.13.1 matplotlib==3.9.4
else
    "$VENV_DIR/bin/python" -m pip install numpy==2.2.6 scipy==1.15.2 matplotlib==3.10.8
fi

chmod +x "$ROOT_DIR/toolkit.sh"
ln -sfn "$ROOT_DIR/toolkit.sh" "$ESTIMATOR_CMD"

echo "Comando instalado: estimator"
