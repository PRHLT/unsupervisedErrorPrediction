# Minimal examples

The following commands are intended to be run from the root of the
project using the sample data files in the `examples/` folder.

## Example with lm

```bash
estimator lm examples/calibration.txt examples/evaluation.txt \
  examples/results_lm 3 --remain --trim:1.5
```

## Example with sx

```bash
estimator sx examples/calibration.txt examples/evaluation.txt \
  examples/results_sx 3 --remain
```

## Example with ts

```bash
estimator ts examples/calibration_ts.txt examples/evaluation_ts.txt \
  examples/results_ts 3 dE --remain
```

## Example with already grouped files

```bash
estimator lm examples/results_lm/lm_K3_t1_tr1_lim1.5/grouped/calibrationK3 \
  examples/results_lm/lm_K3_t1_tr1_lim1.5/grouped/evaluationK3 \
  examples/results_lm_grouped 3 --grouped --remain --trim:1.5
```
