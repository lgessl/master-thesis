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
higher precision than the IPI and to show this on independent data. It also deals with the 
question under which circumstances we can do so reliably. By a *significantly* higher precision, 
we mean that the 95%-confidence interval of the precision of our model must not include the 
precision of the IPI on independent test data. We develop the models in a train-validation-test 
split of our data, where we fit and validate a bunch of models on a training set, pick the best 
validated model and test it on a test set.

## The results

We apply our method to three different data sets and one big data set comprised of these three 
data sets. We show that we can indeed deliver a model with the desired properties. Analysis after 
freezing the models and unlocking the test data suggest that, for a reliable internal 
validation and high test performance, 

- data sets with a large number of samples, even if they result from combining somewhat different, 
  partly non-prospective data sets, 
- relying on already-existing molecular signatures rather than fitting new ones and 
- deploying simple, generalized linear models that can handle batch effects 

play a key role.

## The structure of this repository

- [`data`](data) is supposed to hold the data sets. We used three of them for this thesis and one 
    big data sets combining all three of them in [`data/all`](data/all).
- [`documents`](documents) holds presentation slides for the 
    [progress talk](documents/progress-report/main.pdf) and the 
    [final talk](documents/final-talk/) — compiling them from source does not work due to missing 
    included plot files — and the [thesis](documents/thesis/main.pdf) itself.
- [`models`](models) is supposed to hold the models we train and validate as `.rds` files.
- [`results`](results) holds validation and testing results as well meta analysis in the form of 
    tables and plots.
- [`src`](src) holds all the source code to preprocess data and reproduce the results of this 
    thesis. It is key to this repo and we therefore dedicate it the next section.
 
## Reproducing the results

We recommend reading the [thesis](documents/thesis/main.pdf) first.

### Prerequisites

#### Software

- We used R version 4.4.1.
- Install the [`patroklos`](https://github.com/lgessl/patroklos) from GitHub (see there for more).
  Installing it will make sure you have installed almost all depending R packages already as well.
- If you want to use the Fira Sans font by Mozilla 
    in plots, install it [from GitHub](https://github.com/mozilla/Fira/tree/master/ttf) and install 
    the sysfonts package from CRAN (we used version 0.8.9) in plots. Otherwise set 
    `use_fira_sans = FALSE` in `src/assess/ass.R`.

#### Data

Only one of the thee data sets is publicly available and [`src/prepro/schmitz.R] will download it 
if it is not available locally. To gain access to the two other data sets (and hence to the 
combined data set), 

- ask the system administrator of the spang lab for access to our compute servers where we provide 
  the Schmitz and Reddy data on a mounted volume,
- ask Tobias Schmidt for his `toscdata` R package, which holds the Staiger data and the LAMIS 
  signature.


### All at once