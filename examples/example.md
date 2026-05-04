# Ejemplos mínimos

Los siguientes comandos están pensados para ejecutarse desde la raíz del
proyecto sobre los ejemplos de datos de la carpeta `examples/`

## Ejemplo con lm

```bash
estimator lm examples/calibration.txt examples/evaluation.txt \
  examples/results_lm 3 --remain --trim:1.5
```

## Ejemplo con sx

```bash
estimator sx examples/calibration.txt examples/evaluation.txt \
  examples/results_sx 3 --remain
```

## Ejemplo con ts

```bash
estimator ts examples/calibration_ts.txt examples/evaluation_ts.txt \
  examples/results_ts 3 dE --remain
```
