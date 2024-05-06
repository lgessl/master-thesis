# Beating the IPI for high-risk DLBCL patients

Master thesis by Luks Gessl

Kick-off for MMML predict project

## Introduction: Setting the scene

See [introduction](documents/writing/introduction.md).

## What this master thesis wants to do

We want to lay the groundwork for building a classifier that detects a group of high-risk DLBCL patients, i.e., progression-free survival (PFS) < 2 years, with 

1. PFS significantly differing from that of patients not in the group according to a logrank test,
2. a precision whose 95% confidence interval excludes the IPI's precision of 65% (for PFS >= 2).

Calculations on the sample-size scenarios of MMML-Predict, i.e.,

- n = 200 samples for training cohort,
- n = 100 samples for the test cohort,

suggest that a proportion of 15% for the high-risk group with a PFS>=2 rate of less than 50%

1. boasts the desired power of at least 80% (namely even 94%) for the above logrank test,
2. ensures the 95% CI for the precision does not include the IPI's 65% precision.

## Methods

For an introduction into survival analysis and the basic machine-learning models we use see [general methods](documents/writing/general_methods.md).

### Choosing a classifier

We split the data into a training and validation data set in the very beginning. 

We fit models on the training data, 

- including tuning the regularization parameter 
- in a k-fold cross validation (usually k = 10)
- according to the loss function we also use for fitting (e.g., binomial deviance, partial likelihood deviance), 

and assess them on the validation data, including plotting

- precision versus rate of positive predictions in terms of 2-years-PFS,
- p-values according to a logrank test for being in the detected high-risk group versus being not,
- 95% CI for the precision

for every possible cut-off value (all classifiers output scores we need to threshold). In the end, we choose the model together with a cut-off value that boasts "best overall performance" in the two above categories (logrank test, CI).  

### Building promising classifiers

We tend to integrate late.

#### First-stage models

One the one hand, this includes fitting

- Cox proportional-hazards regression models,
- binomial regression (preferred) models

both *with LASSO regularization and zero-sum constraint*, applied on bulk RNA-seq data (raw molecular data). Another exotic idea: first deconvolve the bulk expression profiles into cell-type proportions, then use them as input for one of the above models.

On the other hand, we want to incorporate well-established molecular signatures such as 

- [Rosenwald et al. The use of molecular profiling to predict survival after chemotherapy for diffuse large-B-cell lymphoma (2002).](ttps://www.nejm.org/doi/full/10.1056/NEJMoa012914),
- [Rosenwald et al. Prognostic Significance of MYC Rearrangement and Translocation Partner in Diffuse Large B-Cell Lymphoma: A Study by the Lunenburg Lymphoma Biomarker Consortium (2019)](https://ascopubs.org/doi/full/10.1200/JCO.19.00743),
- [Schmitz et al. Genetics and Pathogenesis of Diffuse Large B-Cell Lymphoma (2018)](https://www.nejm.org/doi/10.1056/NEJMoa1801445),
- [Chapuy et al. Molecular subtypes of diffuse large B cell lymphoma are associated with distinct pathogenic mechanisms and outcomes (2018)](https://www.nature.com/articles/s41591-018-0016-8),
- [Staiger et al. A novel lymphoma-associated macrophage interaction signature (LAMIS) provides robust risk prognostication in diffuse large B-cell lymphoma clinical trial cohorts of the DSHNHL (2020)](https://www.nature.com/articles/s41375-019-0573-y),
- [Masque-Soler et al. Molecular classification of mature aggressive B-cell lymphoma using digital multiplexed gene expression on formalin-fixed paraffin-embedded biopsy specimens (2013)](https://ashpublications.org/blood/article/122/11/1985/31885/Molecular-classification-of-mature-aggressive-B).

Other MMML-Predict contributors might deliver these signatures.

#### Second-stage models

All of the above models yield a score, i.e., a continuous random variable we can again use as a predictor variable for another model. Moreover we can add features from the pheno data (such as the IPI features) and those features delivered by other MMML-Predict members to the predictor variables. Since now the number of features should be less than the number of samples, we no longer need to resort to regularization like with LASSO. Also, if existent, we should have addressed scaling problems in first-stage models, so we no longer need scale-invariance enforcing constraints like zero sum. Therefore, candidate models include

- binomial regression (with no further constraints) as the most natural choice,
- neural networks,
- many more.

In the long term, we consider modifying the cost function to prefer potentially larger groups and restricting the parameter search during coordiante-descent optimization to implement the trade-off between a sufficiently-high risk and a sufficiently large group with this risk. 

## Data

The data gathered for the MMML-Predict project won't be available until 2025, so we need other sources.

### Available at the moment

- Freely downloadable bulk RNA-seq data from [Schmitz et al. Genetics and Pathogenesis of Diffuse Large B-Cell Lymphoma (2018)](https://www.nejm.org/doi/10.1056/NEJMoa1801445), n = 229. For details see [info](data/schmitz/info.json).

### Wanted

- Bulk RNA-seq data [EGAC00000000011](https://ega-archive.org/datasets/EGAD00001003783), n = 376. Access requested, need to submit more authentification data.

### Received, but not what I wanted

- Bulk RNA-seq data [EGAD00001003600](https://ega-archive.org/datasets/EGAD00001003600), n = 775. Used by [Reddy et al. Genetic and Functional Drivers of Diffuse Large B Cell Lymphoma (2017)](https://www.sciencedirect.com/science/article/pii/S0092867417311212?via%3Dihub). Got access via Peter Oefner, but the pheno data only includes overall survival, no progression-free survival.

## Coding

### Already available software

1. `zeroSum` is the working horse. Without the zero-sum constraint it is considerably faster than with, and the results are only slightly worse; hece, `zeroSum` without zero-sum constraint is a perfect to try a new things, we can then train the best models again with zero sum.
2. `glmnet` can do everything `zeroSum` can, but without zero-sum constraint. The documentation for `zeroSum` promises equivalent results for the case `zeroSum::zeroSum()` with parameters `zeroSum = FALSE`, `standardize = TRUE` and `glmnet::cv.glmnet()`. This is not entirely true, so we keep `glmnet` here to check `zeroSum`.


### [`lymphomSurvivalPipeline`](https://github.com/lgessl/patroklos)

I outsourced all the reused and reusable code for

- preprocessing data (including splitting it into train and validation samples),
- bringing it in shape for a certain model (for fitting as well as predicting, this includes adding pheno variables to the predictor matrix),
- fitting models (including late integration by nesting multiple models (t.b.d)) and
- assessing models in plots and tables

into an R package called `patroklos` you can find on GitHub. Most importantly, the `patroklos` makes integrating new data and models into a running project easy.

Now, the `patroklos` also enables

- splitting the data into a training and test set multiple times and averaging accordingly in the assessment step,
- censoring samples with time to event greater than a certain value at this value (Cox) and thresholding PFS for training differently than for assessing the fits.

### This repo...

... brings the `patroklos` into action.

## Results

### Predicting survival with binomial, Cox regression only with RNAseq data works well

In the key prevalence area, [15%, 20%],

1. the precision is better than that of the IPI (close to 75% for the best models),
2. the logrank test gives p-values below .05, for the best models we get to 0.1%, and 
3. the precision 95% CI interval for the best models does not contain 35.1% (2-years PFS of IPI 4-5 in pooled DSHNHL trials, n = 2721).

Censoring samples with time to event greater than t for t = 1.5, 1.75 at t or thresholding it according to this cutoff for binomial regression gives best results (in pratice better than t = 2).

### Early integration of pheno data leads to overfitting

Early integrating the IPI features from the pheno data causes more overfitting, worse results on the test data. Discard this idea for now.

## To do

Sorted by decreasing priority.

### Late integration

- Find out about random forests ("The Elements of Statistical Learning", Hastie et al.)
- Find out about nested CV: For every left-out fold, do another CV with the remaining folds for the first-stage model to get cross-validated predictions we can use as input for the second-stage model.
- Implement this (zeroSumLI seems useless)

### More data

- Only the models deemed best in earlier evaluations get a try on the new data.
- Reddy et al.: Prepro, talk to Paul about the paper
- Nanostring: find out which data set is meant from Rainer, ask Christian then

### Use sample-wise weights in cost function

- With something decreasing (molecular pattern for very low risk group might differ from that of low-risk group)
- For censored samples: take censoring time to calculate sample weight