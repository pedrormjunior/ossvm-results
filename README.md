<!-- -*- eval: (git-gutter-mode); -*- -->
# Specialized Support Vector Machines (SSVM) — Results

In this repository, we provide the raw results obtained from the experiments accomplished in the paper entitled "Specialized Support Vector Machines for Open-set Recognition".
We also provide the scripts we have employed for performing the statistical tests and generating diagrams present in the paper.
For generating those diagrams, it is required to have [Python 3](https://www.python.org/) and [GNU make](https://www.gnu.org/software/make/) installed.

## Raw data

Raw results are available in [CSV_files](CSV_files/) directory following the [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) format.  Each evaluation measure has its corresponding CSV file.  Those CSV files contain the following fields:

Field | Description
-|-
`lenacs` | Number of available classes for training
`dataset` | Name of the dataset
`classifier` | Name of the classifier
`experiment` | A number in the range 1–10 specifying one of the 10 experiments per combination of number of available classes, dataset, and classifier
`result` | Specifying the result for the respective measure indicated in the filename

The evaluation measures employed are the following:

Repr. | Description | Acronym
-|-|-
`NA` | Normalized Accuracy | ![](figs/NA.png)
`HNA` | Harmonic Normalized Accuracy | ![](figs/HNA.png)
`OSFMmacro` | Macro-Averaging Open-Set F-Measure | ![](figs/OSFMmacro.png)
`OSFMmicro` | Micro-Averaging Open-Set F-Measure | ![](figs/OSFMmicro.png)
`FMmacro` | Multiclass Macro-Averaging F-Measure | ![](figs/FMmacro.png)
`FMmicro` | Multiclass Micro-Averaging F-Measure | ![](figs/FMmicro.png)
`AKS` | Accuracy on Known Samples | ![](figs/AKS.png)
`AUS` | Accuracy on Unknown Samples | ![](figs/AUS.png)

Evaluated methods include:

Repr. | Description | Acronym | Reference
-|-|-|-
`svm` | Support Vector Machines | ![](figs/svm.png) | Chih-Chung Chang and Chih-Jen Lin. [LIBSVM: A library for Support Vector Machines](https://doi.org/10.1145/1961189.1961199). _**ACM Transactions on Intelligent Systems and Technology**_, 2(3):27:1–27:27, April 2011.
`ocsvm` | One-class SVM | ![](figs/ocsvm.png) | Dimitrios A. Pritsos and Efstathios Stamatatos. [Open-set classification for automated genre identification](https://doi.org/10.1007/978-3-642-36973-5_18). In _**European Conference on Information Retrieval**_, volume 7814 of Lecture Notes in Computer Science, pages 207–217, Moscow, Russia, March 2013. Springer, Berlin, Heidelberg.
`svdd` | Support Vector Data Description | ![](figs/svdd.png) | David M. J. Tax and Robert P. W. Duin. [Support vector data description](https://doi.org/10.1023/B:MACH.0000008084.60811.49). _**Springer Machine Learning**_, 54(1):45–66, January 2004.
`dbc` | SVM Decision Boundary Carving | ![](figs/dbc.png) | Filipe de Oliveira Costa, Ewerton Silva, Michael Eckmann, Walter J. Scheirer, and Anderson Rocha. [Open set source camera attribution and device linking](https://doi.org/10.1016/j.patrec.2013.09.006). _**Elsevier Pattern Recognition Letters**_, 39:92–101, April 2014.
`onevset` | 1-vs-Set Machine | ![](figs/onevset.png) | Walter J. Scheirer, Anderson de Rezende Rocha, Archana Sapkota, and Terrance E. Boult. [Towards open set recognition](https://doi.org/10.1109/TPAMI.2012.256). _**IEEE Transactions on Pattern Analysis and Machine Intelligence**_, 35(7):1757–1772, July 2013.
`wsvm` | Weibull-calibrated SVM | ![](figs/wsvm.png) | Walter J. Scheirer, Lalit P. Jain, and Terrance E. Boult. [Probability models for open set recognition](https://doi.org/10.1109/TPAMI.2014.2321392). _**IEEE Transactions on Pattern Analysis and Machine Intelligence**_, 36(11):2317–2324, November 2014.
`pisvm` | SVM with Probability of Inclusion | ![](figs/pisvm.png) | Lalit P. Jain, Walter J. Scheirer, and Terrance E. Boult. [Multi-class open set recognition using probability of inclusion](https://doi.org/10.1007/978-3-319-10578-9_26). In _**European Conference on Computer Vision**_, volume 8691, part III of Lecture Notes in Computer Science, pages 393–409, September 2014.
`evm` | Extreme Value Machine | ![](figs/evm.png) | Ethan M. Rudd, Lalit P. Jain, Walter J. Scheirer, and Terrance E. Boult. [The Extreme Value Machine](https://doi.org/10.1109/TPAMI.2017.2707495). _**IEEE Transactions on Pattern Analysis and Machine Intelligence**_, 40(3):762–768, March 2018.
`ssvm` | Specialized SVM | ![](figs/ssvm.png) | **Proposed method**

The suffix `O` or `C` in the representation name of each of those classifiers indicate if it was trained by performing open- or closed-set grid search approach, respectively.

**Note:**
As stated in our manuscript, in this work we have discussed only the experiments with open-set grid search, as previous work have shown it to be superior to closed-set grid search.
For reproducibility of the results presented in the manuscript, one should employ only the data with suffix `O` although below we also present the Critical Difference’s diagrams for all methods implemented with closed-set grid search as well.

## Generating Critical Difference’s diagrams

For generating the Critical Difference (CD) diagrams, Python 3 is required.
The required packages are specified in [requirements.txt](requirements.txt).
For installation of the required packages, run:

```shell
> pip3 install -r requirements.txt
```


For generating the CD diagrams, run:

```shell
> make plot_CD
```


It will generate the CD diagrams inside the `CD_diagrams/` directory.

The main script responsible for generating the diagrams is [plot_CD.py](plot_CD.py).

## Critical Difference’s diagrams

**Note:** In our paper, we have included only the CD diagrams referring to the column “**Open-set grid search**” herein.
This supplementary material contains CD diagrams also for AKS and AUS measures, which are not presented in the paper.

<table>
	<tr><th>Open-set grid search</th><th>Closed-set grid search</th></tr>
	<!-- NA -->
	<tr><td align="middle" colspan="2"><b>Normalized Accuracy — <img src="figs/NA.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_NA_O.png" /></td><td><img src="CD_diagrams/CD_normal_NA_C.png" /></td></tr>
	<!-- HNA -->
	<tr><td align="middle" colspan="2"><b>Harmonic Normalized Accuracy — <img src="figs/HNA.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_HNA_O.png" /></td><td><img src="CD_diagrams/CD_normal_HNA_C.png" /></td></tr>
	<!-- OSFMmacro -->
	<tr><td align="middle" colspan="2"><b>Macro-averaging Open-Set F-Measure — <img src="figs/OSFMmacro.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_OSFMmacro_O.png" /></td><td><img src="CD_diagrams/CD_normal_OSFMmacro_C.png" /></td></tr>
	<!-- OSFMmicro -->
	<tr><td align="middle" colspan="2"><b>Micro-averaging Open-Set F-Measure — <img src="figs/OSFMmicro.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_OSFMmicro_O.png" /></td><td><img src="CD_diagrams/CD_normal_OSFMmicro_C.png" /></td></tr>
	<!-- FMmacro -->
	<tr><td align="middle" colspan="2"><b>Multiclass Macro-averaging F-Measure — <img src="figs/FMmacro.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_FMmacro_O.png" /></td><td><img src="CD_diagrams/CD_normal_FMmacro_C.png" /></td></tr>
	<!-- FMmicro -->
	<tr><td align="middle" colspan="2"><b>Multiclass Micro-averaging F-Measure — <img src="figs/FMmicro.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_FMmicro_O.png" /></td><td><img src="CD_diagrams/CD_normal_FMmicro_C.png" /></td></tr>
	<!-- AKS -->
	<tr><td align="middle" colspan="2"><b>Normalized Accuracy — <img src="figs/AKS.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_AKS_O.png" /></td><td><img src="CD_diagrams/CD_normal_AKS_C.png" /></td></tr>
	<!-- AUS -->
	<tr><td align="middle" colspan="2"><b>Normalized Accuracy — <img src="figs/AUS.png" /></b></td></tr>
	<tr><td><img src="CD_diagrams/CD_normal_AUS_O.png" /></td><td><img src="CD_diagrams/CD_normal_AUS_C.png" /></td></tr>
</table>
