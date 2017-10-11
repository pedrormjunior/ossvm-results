# Specialized Support Vector Machines (SSVM)

In this repository, we provide the results obtained from the experiments accomplished in the paper entitled "Specialized Support Vector Machines for Open-set Recognition".
To replicate the results, it is required to have [R](https://cran.r-project.org/) and [GNU make](https://www.gnu.org/software/make/) installed.
If requirements are satisfied, just type `make` from the command line to perform statistical tests.

## Raw data

Files in [normal](statcsv_ossvm_R1_normal/), [ocbb](statcsv_ossvm_R1_normal_ocbb/), [onlyImageNet](statcsv_ossvm_R1_onlyImageNet/), and [unbalanced](statcsv_ossvm_R1_unbalanced_open/) directories contain the raw data.
[CSV](https://en.wikipedia.org/wiki/Comma-separated_values) files are named `stat___<measure>.csv`, in which `<measure>` can be one of the following.
- `na` Normalized accuracy (![](figs/na.png))
- `harmonicNA` Harmonic normalized accuracy (![](figs/hna.png))
- `mafm` Macro-averaging open-set f-measure (![](figs/mafm.png))
- `mifm` Micro-averaging open-set f-measure (![](figs/mifm.png))
- `bbmafm` Multiclass macro-averaging f-measure (![](figs/bbmafm.png))
- `bbmifm` Multiclass micro-averaging f-measure (![](figs/bbmifm.png))

Evaluated methods include:
- `svm` ![](figs/svm.png)
- `dbc` ![](figs/dbc.png)
- `1vs` ![](figs/1vs.png)
- `mcocsvm` ![](figs/mcocsvm.png)
- `mcocbbsvm` ![](figs/mcocbbsvm.png)
- `mcocbbsvmovo` ![](figs/mcocbbsvmOVO.png)
- `mcsvdd` ![](figs/mcsvdd.png)
- `mcsvddbb` ![](figs/mcsvddbb.png)
- `mcsvddbbovo` ![](figs/mcsvddbbOVO.png)
- `wsvm` ![](figs/wsvm.png)
- `pisvm` ![](figs/pisvm.png)
- `ssvm` ![](figs/ssvm.png)
