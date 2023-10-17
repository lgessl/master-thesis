# Classify Lymphoma

Master thesis by Lukas Gessl

## Outline

Roughly 70% of lymphoma patients have quite good chances for complete recovery, for the remaining 30% it's a hard fight. I want to find a classifier that identifies a sufficiently large cohort with low life expectation among lymphoma patients, i.e.,

1. The alert must be justified (life expectation sufficiently low) and
2. it must not just ring for a couple of lymphoma patients.

### Featues

This is up to me, but the project states that the final test should cost no more than $500 per patient. Features will certainly include **RNA seq** and maybe also some phenotypes.

- certainly RNAseq
- thickness of tumor
- age at diagnosis

### Classifiers

Rainer proposes to empower ever more-difficult classifiers, namely

- the Cox (proportional hazards) model,
- some discretization approach (discretize outcome, i.e. life expectation),
- a classifier with an own objective function (and a suitable optimization algorithm).

## Theory

### General Definitions

#### Hazard Function

See https://en.wikipedia.org/wiki/Failure_rate.

Given the probability space $(\mathbb{R}, \mathcal{L}(\mathbb{R}), \lambda_f)$ with 

- $\lambda_f(A) = \int_A f d\lambda$ 
- for some Lebesgue-integrable $f: \mathbb{R} \to \mathbb{R}_{\geq 0}$ 
- with $\int_\mathbb{R} f d\lambda = 1$ and
- $\lambda$ being the Lebesgue measure on $\mathbb{R}$

i.e. a density-defined real probability distribution, we define the hazard function of $f$ to be

$$
    h(t) = \frac{f(t)}{1 - F(t)} = \frac{f(t)}{R(t)} \quad \text{for all } t \in \mathbb{R},
$$

where $F: \mathbb{R} \to \mathbb{R}, t \mapsto \int_{-\infty}^t f(\tau) d\tau$, is the cumulative distribution function belonging to $f$ and $R(t) = 1 - F(t)$ for all $t \in \mathbb{R}$ is called the reliability function.

If $\lambda_f$ defines a discrete distribution with only finitely many outcomes, i.e., $f$ is a step function, then one often uses the letter $\lambda$ instead of $h$ for the hazard function. (But — at least here — we already need it for the Lebesgue measure.)

### How We Use Hazard Functions

$\lambda_f$ is the probability distribution of the **failure** of a **system** over **time**; a failure can only occur once over time. In our case, the system is a lymphoma patient and its failure is death. We're not interested in the distribution itself, but in the ratio of hazard functions between patients. Assuming proportional hazards, these ratios are constant.

### The Cox Proportional Hazards Model

Original paper: https://www.jstor.org/stable/pdf/2985181.pdf?refreqid=fastly-default%3A5d5834de4e320736013b2ed1ab5b2297&ab_segments=&origin=&initiator=&acceptTC=1.

See https://en.wikipedia.org/wiki/Survival_analysis, https://en.wikipedia.org/wiki/Proportional_hazards_model.

Assume proportional hazards
$$
    \lambda(t|X_i) = \lambda_0(t) \exp\left( \beta X_i \right)
$$
for the covariates $X_i$ of sample $i$.

- "Regression models, including the Cox model, generally give more reliable results with normally-distributed variables." Hence, transform data to normally distributed data in adavance if necessary.

## Coding
### Languages
No decisions made so far. Depends on already available code. A polyglossial consortium of code is well imaginable.

## Data
Should I just search for already available lymphoma data, especially RNAseq data? Will there be data generated for this project specifically at some point?
Ask Rainer!

## Literature and links

### Cox model
- Proportional hazards model on Wikipedia: https://en.wikipedia.org/wiki/Proportional_hazards_model
- YouTube

### Similar publications

## Todos

- Ask Rainer for data, project description (email sent)