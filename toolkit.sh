#!/usr/bin/env bash

set -e

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    LINK_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    case "$SCRIPT_PATH" in
        /*) ;;
        *) SCRIPT_PATH="$LINK_DIR/$SCRIPT_PATH" ;;
    esac
done

ROOT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
VENV_PYTHON="$ROOT_DIR/.toolkit2venv/bin/python"

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "---help" ] || [ "$1" = "help" ]; then
    echo "Usage:"
    echo "  estimator METHOD calibration_file evaluation_file output_dir"
    echo "            [K] [--remain] [--trim:VALUE]"
    echo "  estimator ts calibration_file evaluation_file output_dir"
    echo "            [K] [--remain] [ce|dE|DE]"
    echo "  estimator lm|sx grouped_calibration_file grouped_evaluation_file output_dir"
    echo "            K --grouped [--remain] [--trim:VALUE]"
    echo "  estimator ts grouped_calibration_file grouped_evaluation_file output_dir"
    echo "            K --grouped [--remain]"
    echo
    echo "Inputs and order:"
    echo "  METHOD              Estimator type: lm, sx, or ts"
    echo "  calibration_file    Calibration file"
    echo "  evaluation_file     Evaluation file"
    echo "  output_dir          Root directory where results are saved."
    echo "                      This argument is required"
    echo "  K                   Number of groups. If omitted without --grouped,"
    echo "                      the default is 100. With --grouped, K is required"
    echo "                      and is used only to label the experiment folder"
    echo "  --remain            If included, the remainder is saved as a separate"
    echo "                      final block (t=1). If omitted, t=0"
    echo "  --grouped           The input files are already grouped as:"
    echo "                      m mean_estimated_error mean_empirical_error"
    echo "                      In this mode, K and t are not used for computation,"
    echo "                      only to make the output path understandable"
    echo "  --trim:VALUE        Only for lm and sx. Enables trimming with"
    echo "                      the given threshold"
    echo "  ce|dE|DE            Only for ts. Temperature optimization criterion."
    echo "                      Default: ce"
    echo
    echo "Notes:"
    echo "  lm  -> Levenberg-Marquardt fit"
    echo "  sx  -> Simplex fit"
    echo "  ts  -> temperature scaling"
    echo
    echo "Output metrics:"
    echo "  Ecal -> calibrated error (%)"
    echo "  Ee   -> input estimated error (%), mean of 1-Pmax"
    echo "  E    -> empirical error (%)"
    echo "  DE   -> |Ecal - E| (%)"
    echo
    echo "Examples:"
    echo 
    echo "  estimator lm examples/calibration.txt examples/evaluation.txt results 3 \\"
    echo "      --remain"
    echo
    echo "  estimator ts examples/calibration_ts.txt examples/evaluation_ts.txt \\"
    echo "      results 3 dE"
    exit 0
fi

if [ ! -x "$VENV_PYTHON" ]; then
    echo "No existe .toolkit2venv. Ejecuta ./install.sh primero."
    exit 1
fi

exec "$VENV_PYTHON" "$ROOT_DIR/code/wraper.py" "$@"
