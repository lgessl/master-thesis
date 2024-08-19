# Detection of a high-risk DLBCL group

Master thesis by Lukas Gessl.

## The problem

Chemotherapy with R-CHOP is the standard treatment for diffuse large B-cell lymphoma, 
the most common type of non-Hodgkin lymphoma, achieving a cure for about two thirds of 
patients. Survival for the remaining third with refractory or relapsed disease, however, 
remains poor. Pharma-sponsored randomized trials in the whole DLBCL population to date have 
failed to improve R-CHOP. The International Prognostic Index (IPI), the only widely accepted 
risk-assessment tool for DLBCL and an easy clinical test, fails to identify 
a high-risk DLBCL subpopulation that is 
large and precise enough to trigger research and enable clinical trials for new treatments 
that outperform R-CHOP on this subpopulation. 

## The solution

This thesis aims to develop a computational method that identifies DLBCL patients with 
progression-free survival (PFS) below two years with higher prevalence and significantly 
higher precision than the IPI and wants to show this on independent data. It also deals with the 
question under which circumstances we can do so reliably. By a *significantly* higher precision, 
we mean that the 95%-confidence interval of the precision of our model must not include the 
precision of the IPI on independent test data. We develop the models in a train-validation-test 
split of our data, where we fit and validate a bunch of models on a training set, pick the best 
validated model and test it on a test set.

## The results

We apply our methods to three different data sets and a big one comprised of these three. 
We show that we can indeed deliver a model with the desired properties. Analysis after 
freezing the models and unlocking the test data suggest that, for a reliable internal 
validation and high test performance, 

- data sets with a large number of samples, even if they result from combining somewhat different, 
  partly non-prospective data sets, 
- relying on already-existing molecular signatures rather than fitting new ones and 
- deploying simple, generalized linear models that can handle batch effects 

play a key role.

## The structure of this repository

- [`data`](data) is supposed to hold the data sets. We used three of them for this thesis and a 
    big one combining all three of them in [`data/all`](data/all).
- [`documents`](documents) holds presentation slides for the 
  [progress talk](documents/progress-report/main.pdf) and the 
  [final talk](documents/final-talk/) — compiling them from source does not work due to missing 
  included plot files — and the [thesis](documents/thesis/main.pdf) itself.
- [`models`](models) is supposed to hold the models we train and validate as `.rds` files.
- [`results`](results) holds validation and testing results as well meta analysis in the form of 
  tables and plots.
- [`src`](src) holds all the source code to preprocess data and reproduce the results of this 
  thesis. It takes the center role in this repo and we therefore dedicate the next section to it.
 
## Reproducing the results

We recommend reading the [thesis](documents/thesis/main.pdf) first. 

We outsourced all reusable 
code of this thesis to the R package [`patroklos`](https://github.com/lgessl/patroklos), which 
is tailored for this thesis and still applicable to a more general class of problems, namely 
machine-learning projects that aim to develop a model predicting thresholded survival in the 
classical train-validate-test split.

### Prerequisites

#### Software

- We used R version 4.4.1.
- Install the latest version of [`patroklos`](https://github.com/lgessl/patroklos) from GitHub 
  (see there for more). Installing it will make sure you have installed almost all depending R 
  packages already as well.
- If you want to use the Fira Sans font by Mozilla 
  in plots, install it [from GitHub](https://github.com/mozilla/Fira/tree/master/ttf) and install 
  the sysfonts package from CRAN (we used version 0.8.9) in plots. Otherwise set 
  `use_fira_sans <- FALSE` in `src/assess/ass.R`.

#### Data

Only one of the thee data sets, the Schmitz data, is publicly available. 
[`src/prepro/schmitz.R`](src/prepro/schmitz.R) will download it 
if it is not available locally. To gain access to the two other data sets (and hence to the 
combined data set), ask the system administrator of the Spang lab, 
[Christian Kohler](mailto:christian.kohler@ur.de), for access to our compute servers 
where we provide all three data sets on a mounted volume.

### All in one run

With the above requisites fulfilled, you can now run

```
Rscript src/run_all.R 
```

in your terminal from the root directory of this repo. In general, all scripts below `src` are 
expected to be run with the repo root directory as the current working directory.

### The structure of [`src`](src)

- [`src/prepro`](src/prepro/) holds the scripts preprocessing the four data sets into 
  [`Data`](https://lgessl.github.io/patroklos/reference/Data.html) 
  R6 objects, the data format `patroklos` works with.
- [`src/models`](src/models) holds the scripts that define all trained and validated models with 
  their hyperparameters for every data set. We do so by initializing a bunch of 
  [`Model`](https://lgessl.github.io/patroklos/reference/Model.html) 
  R6 objects, the model format `patroklos` works with.
- [`src/train`](src/train/) holds the scripts that fit the models defined below `src/models` and 
  validate them `Model`-internally by calling 
  [`patroklos::training_camp()`](https://lgessl.github.io/patroklos/reference/training_camp.html). 
  They store the readily trained models with their validated predictions below [`models`](models).
- [`src/assess`](src/assess/) holds the scripts that finalize validation, pick the best model 
  according to validation on the respective training cohort and test it on the test cohort.
  Beyond the error, they calculate a bunch of model properties that show up as tables below 
  [`results`](results). The 
  [`AssScalar`](https://lgessl.github.io/patroklos/reference/AssScalar.html) 
  R6 class from `patroklos` is the working horse of this directory.
- [`src/analyze`](src/analyze/) holds the scripts that unfreeze the respective test data for all 
  models to do some meta analysis about the trained models and the validation: reporting the 
  non-zero coefficients of the picked models, plots on thresholding the continuous output of the 
  picked models and plots on validation versus test error for all models. The 
  [`Ass2d`](https://lgessl.github.io/patroklos/reference/Ass2d.html) 
  R6 class from `patroklos` and 
  [`patroklos::val_vs_test()`](https://lgessl.github.io/patroklos/reference/val_vs_test.html) 
  are the stars of this directory.