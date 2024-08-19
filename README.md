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

