# Read this first: the small-sample update

The package is now named `susieRsmall`, so it can coexist with vanilla `susieR`:

```r
fit <- susieRsmall::susie(X, y, prior = "nig", L = 10, max_iter = 300)
```

This now uses `alpha0 = 2` and `beta0 = 2 * var(y)` when an intercept
is fitted (the default). Explicit `alpha0` and `beta0` still override them.
The legacy `small=TRUE` call is equivalent. The Gaussian default (also
`prior="gaussian"`) keeps its existing calculations. Version .9003 only adds
the package name and prior selector; its NIG fitting code is unchanged from
.9002. `prior` is appended to the argument list for positional compatibility.
It currently applies to individual-level `susie()`, not summary-statistic APIs.

## The model, in one convention

The nonzero coefficient has prior `b | sigma2 ~ N(0, V * sigma2)`.
The noise variance has prior `sigma2 ~ IG(alpha0/2, beta0/2)`, with
density proportional to `sigma2^(-alpha0/2 - 1) * exp(-beta0/(2*sigma2))`.
Thus **V is a variance ratio**, and **beta0 is in squared response units**.
It must be multiplied by c^2 if an explicitly supplied prior is used
after multiplying y by c. The default does this automatically.

With an intercept, let m = n - 1, d = x'x, bhat = x'y/d, and
RSS = y'y - d*bhat^2, using centered data. The single-effect Bayes
factor is exactly the ratio of Student densities evaluated at bhat:

```
df = m - 1 + alpha0
s0^2 = (beta0 + RSS) / (df * d)
s1^2 = s0^2 * (1 + d * V)
BF = [dt(bhat/s1, df) / s1] / [dt(bhat/s0, df) / s0]
```

Choosing alpha0 = 2 gives **df = n**, matching the original Student-ratio
idea. The coefficient posterior instead has df = m + alpha0 = n + 1.
Without an intercept, m = n and the same prior gives BF df = n + 1.
The code evaluates the algebraically equivalent integrated likelihood
in log space, including zero-information columns where bhat is undefined.

The default beta0 is fixed from the original response before IBSS;
it is not recalculated from each partial residual. At alpha0 = 2 the
inverse-gamma prior has infinite mean. var(y) is a scale anchor, not
a claimed prior mean for the residual variance.

## What changed, and where to review it

1. `R/single_effect_regression_nig.R` contains the entire NIG SER:
   integrated Bayes factors, posterior moments and optimization of V.
2. `R/single_effect_regression.R` dispatches to it for `small = TRUE`.
   `R/update_each_effect.R` stores its posterior summaries.
3. `R/susie.R` handles the effective sample dimension, the prior defaults
   and convergence. V is never converted into an absolute variance on
   the NIG path. The prior optimizer uses the NIG likelihood.
4. `R/susie_utils.R` uses Student posterior summaries and sampling,
   with degrees of freedom equal to twice the inverse-gamma shape.
   Correcting that factor of two affects posterior draws and sign
   probabilities; it does not change PIPs or the simulated credible sets.
   `R/elbo.R` no longer presents the Gaussian objective as NIG evidence.

For one effect the integrated evidence is available. With several effects,
this remains the manuscript's iterative partial-residual approximation;
there is no established joint NIG ELBO for this implementation. The code
reports that limitation rather than inventing an evidence value.

## What the tests establish

`test_nig_parameterization.R` checks the SER against numerical integration,
response rescaling, dense/sparse equivalence, null effects, posterior
moments and prior optimization. `test_nig_student_default.R` checks the
new default against the explicit simulation settings and the Student
density ratio. The existing suite checks the Gaussian implementation too.

These tests establish numerical consistency, not 95% frequentist coverage.
Preliminary simulations show improved coverage in some difficult cases
and reduced CS-based power; undercoverage remains, especially with two
causal variants. The prior is a reasoned working choice, not a proven optimum.

## Install and retain the old prior if needed

After publishing this repository, install in a fresh R session:

```r
remotes::install_github("william-denault/susieRsmall")
packageVersion("susieRsmall")

# Explicit manuscript hyperparameters (with the corrected calculations):
fit <- susieRsmall::susie(X, y, prior = "nig",
                    alpha0 = 1/sqrt(nrow(X)), beta0 = 1/sqrt(nrow(X)))
```

The package contains no compiled code. It derives from the upstream
`stephenslab/susieR` small-sample branch and retains the original BSD license
and author attribution. Its separate name allows installation alongside
vanilla `susieR`.
