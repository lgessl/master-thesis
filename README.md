# Classify Lymphoma

Master thesis by Lukas Gessl

## Outline

Roughly 70% of lymphoma patients have quite good chances for complete recovery, for the remaining 30% it's a hard fight. I want to find a classifier that identifies a sufficiently large cohort with low life expectation among lymphoma patients, i.e.,

1. The alert must be justified (life expectation sufficiently low) and
2. it must not just ring for a couple of lymphoma patients.

### Feaatues

This is up to me, but the project states that the final test should cost no more than $500 per patient. Features will certainly include **RNA seq** and maybe also some phenotypes.

### Classifiers

Rainer proposes to empower ever more-difficult classifiers, namely

- the Cox (proportional hazards) model,
- some discretization approach (discretize outcome, i.e. life expectation),
- a classifier with an own objective function (and a suitable optimization algorithm).

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