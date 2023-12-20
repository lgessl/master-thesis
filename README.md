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
- Bulk RNA-seq data [EGAD00001003600](https://ega-archive.org/datasets/EGAD00001003600), n = 775. Used by [Reddy et al. Genetic and Functional Drivers of Diffuse Large B Cell Lymphoma (2017)](https://www.sciencedirect.com/science/article/pii/S0092867417311212?via%3Dihub). Access requested, no answer yet. 

## Coding

### [`lymphomSurvivalPipeline`](https://github.com/lgessl/lymphomaSurvivalPipeline)

I outsourced all the reused and reusable code for

- preprocessing data (including splitting it into train and validation samples),
- bringing it in shape for a certain model (for fitting as well as predicting, this includes adding pheno variables to the predictor matrix),
- fitting models (including late integration by nesting multiple models) and
- assessing models in plots and tables

into an R package called `lymphomaSurvivalPipeline` you can find on GitHub. Most importantly, the `lymphomaSurvivalPipeline` makes integrating new data and models into a running project easy.

### This repo...

... brings the `lymphomaSurvivalPipeline` into action.

## Results

### On Schmitz et al. (2018) data

IPI-defined high-risk group heavily depends on how we split data into training and validation samples. Study distrubtion of IPI scores in more detail. Strive for bigger data sets.

#### Only Cox and binomial regression

with LASSO and zero sum on RNA-seq data 

1. is okay (AUC = 72%), but we need more. And, yet, there is a link between gene expression profile and survival outcome.
2. Discretizing and training a binomial model always performs slightly better than Cox.
3. Plenty of overfitting, model performance on left-out fold already fluctuates heavily.

#### Cox and binomial regression on gene expression *and* pheno data

This leads to even more overfitting. Therefore: discard and do late integration.