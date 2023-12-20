### Survival analysis

#### Dealing with right censoring

We want to get a hand on the distribution $F$ of survival times after treatment. The practical problem: Patients get lost in studies because, e.g.,

- the patient withdraws from the study,
- the study ends before the patient dies,
- the patient disappears.

Hence, in general we don't know an individual's survival time $T_i$, but only *observed* survival times $t_i = \min (T_i, L_i)$, where $L_i$ is the time when the follow-up was lost, called limit of observation. At least we know whether a patient was knocked out due to death or loss of follow-up.

Let $t$ be fixed.

A simple approach to estimate $P(t) = 1 - F(t)$ would be a binomial estimate for those samples with $L_i \geq t$. Especially for large $t$ this would amount to discarding a large fraction of our valuable data. We can do better.

[Kaplan and Meier (1958)](https://www.jstor.org/stable/pdf/2281868.pdf?refreqid=fastly-default%3A3fde7b928c0b03b03f90e2e83f39b4d9&ab_segments=&origin=&initiator=&acceptTC=1) did the following: Split up the time frame into intervals in such a way that

- either only death events
- or only loss of follow-up events lie within one interval.

For every interval $(u_{j-1}, u_j)$, we can now calculate the (conditional) probability $p_j$ that, given a patient has survived time $u_{j-1}$, they will also survive $u_j$ via
$$
    \hat{p}_j = \frac{n_j - \delta_j}{n_j} = \frac{n_j'}{n_j},
$$
where $n_j$ is the number of patients alive and under observation at time $u_{j-1}$ and $\delta_j$ is the number of death events in $(u_{j-1}, j)$. Exploiting the chain rule for conditional probabilities, this yields the estimate for $P(t)$
$$
    \hat{P}(t) = \prod_{j: u_j \leq t} \hat{p}_j = \prod_{j: u_j \leq t} \frac{n_j'}{n_j}.
$$
$$
    \hat{P}(t) = \prod_{r: t_r \leq t \text{ and } L_r > t} \frac{N - r}{N - r + 1}.
$$

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

### Classfiers

#### The Cox Proportional Hazards Model

Above $\lambda_f$ is the probability distribution of the **failure** of a **system** over **time**; a failure can only occur once over time. In our case, the system is a lymphoma patient and its failure is death. We're not interested in the distribution itself, but in the ratio of hazard functions between patients. Assuming proportional hazards, these ratios are constant.

Original paper: https://www.jstor.org/stable/pdf/2985181.pdf?refreqid=fastly-default%3A5d5834de4e320736013b2ed1ab5b2297&ab_segments=&origin=&initiator=&acceptTC=1.

See https://en.wikipedia.org/wiki/Survival_analysis, https://en.wikipedia.org/wiki/Proportional_hazards_model.

Assume proportional hazards
$$
    \lambda(t|X_i) = \lambda_0(t) \exp\left( \beta X_i \right)
$$
for the covariates $X_i$ of sample $i$.

##### Estimating $\beta$ for unique **times**

Determine $\beta$ with the maximum-likelihood estimation
$$
    L(\beta) = \prod_{i: C_i = 1} \frac{\lambda(t_i|X_i)}{\sum_{t_j \geq t_i} \lambda(t_j|X_j)} = \prod_{i: C_i = 1} \frac{\exp(X_i \beta)}{\sum_{t_j \geq t_i} \exp(X_j \beta)} = \prod_{i: C_i = 1} \frac{\theta_i}{\sum_{t_j \geq t_i} \theta_j},
$$
where $t_i$ is the time when the event occurs for sample $X_i$. For censored samples, we formally set $t_i = \infty$. With this notation, $C_i = 1$ iff $t_i < \infty$. That means: When the event occurs for a sample, we want the hazard for this sample to be as high as possible compared to the other samples still in the race.

##### Estimating $\beta$ for tied times

One can procede as above, or use a refined maximum likelihood estimator, see https://en.wikipedia.org/wiki/Proportional_hazards_model#Likelihood_when_there_exist_tied_times. Do we need this in our case? Depends on how detailed deaths are reported in the data. So have a look at the data.

#### LASSO Regularization

Since we have much more values per sample (roughly 25000) than samples, ordinary linear model would exploit their vast freedom to run into overfitting. We will therefore add another cost term to the loss function, namely the $\ell_1$ norm of the model coefficients via $\lambda |\beta|_1$ for a shrinkage parameter $\lambda > 0$. For the Cox Proportional Hazards Model this leads to the loss function
$$
    L(\beta) = \prod_{i: C_i = 1} \frac{\exp(X_i \beta)}{\sum_{t_j \geq t_i} \exp(X_j \beta)} + \lambda |\beta|_1.
$$

#### Zero-Sum Regression

The proportion of tumor RNA sequenced varies from bulk to bulk. Given a (non-logarithmized) bulk expression profile $\hat{X}_i$, the actual tumor bulk expression profile is $\gamma_i \hat{X}_i$ for some unknown $\gamma_i \in [0, 1]$. For a (now logarithmized) bulk expression profile $X_i = \log(\hat{X}_i)$, we have $\log(\gamma_i) + X_i$ for the tumor expression. To achieve $\gamma_i$-insensitivity, we modify the objective function into
$$
    L(\beta) = \prod_{i: C_i = 1} \frac{\exp(X_i \beta)}{\sum_{t_j \geq t_i} \exp(X_j \beta)} \quad \text{subject to } \sum_i \beta_i = 0.
$$
More in 
- [Thorsten Rehberg's PhD thesis](documents/zerosum/thesis_thorsten.pdf),
- [Rainer's lecture](documents/zerosum/lecture_rainer.pdf).