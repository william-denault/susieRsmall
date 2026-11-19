# susieRsmall

Sum of Single Effects regression with a corrected normal-inverse-gamma (NIG)
single-effect model for small samples. This package is named `susieRsmall` so
it can be installed alongside the original `susieR` package.

## Installation

Once this source is pushed to `william-denault/susieRsmall`, install it with:

```r
install.packages("remotes") # once, if needed
remotes::install_github("william-denault/susieRsmall")
```

 
## Usage

```r
fit <- susieRsmall::susie(X, y, prior = "nig", L = 10, max_iter = 300)
fit$pip
fit$sets
```

For a reproducible example:

```r
set.seed(1)
X <- matrix(rnorm(50 * 100), nrow = 50)
y <- X[, 1] + rnorm(50)
fit <- susieRsmall::susie(X, y, prior = "nig", L = 10, max_iter = 300)
```

## Comparing with susieR on RCC

The `Package` field in `DESCRIPTION` is `susieRsmall`. Both packages can be
installed in the same R library and called in the same R session. Use explicit
namespaces to compare the NIG implementation with vanilla SuSiE on identical
inputs:

```r
fit_nig <- susieRsmall::susie(X, y, prior = "nig", L = 10, max_iter = 300)
fit_standard <- susieR::susie(X, y, L = 10, max_iter = 300)

c(susieRsmall = as.character(packageVersion("susieRsmall")),
  susieR = as.character(packageVersion("susieR")))
```

Record both package versions with the RCC results. The namespaces keep the two
implementations distinct without attaching either package with `library()`.

`prior = "nig"` uses `alpha0 = 2` and `beta0 = 2 * var(y)` with an intercept.
The initial coefficient-to-noise variance ratio is 0.2 and is estimated during
fitting by default. `small = TRUE` is an equivalent legacy argument. The default
prior remains Gaussian; NIG must be selected explicitly. The named prior applies
to individual-level `susie()`, not the summary-statistic functions.

Read [SMALL_SAMPLE_UPDATE.md](SMALL_SAMPLE_UPDATE.md) for the model, prior
conventions, and limitations. Version 0.14.21.9003 preserves the corrected
fitting calculations. Numerical consistency does not guarantee nominal
frequentist credible-set coverage.

## Package contents

This repository contains the R package source, help files, example data,
vignettes, tests, and original license and attribution. Simulation workflows,
private configuration, fitted results, backups, and installed libraries are
not included. The package itself does not require compilation; some dependencies
may require build tools when installed from source.

## Citation and license

This package derives from [stephenslab/susieR](https://github.com/stephenslab/susieR)
and retains its BSD 3-Clause license and author attribution. See
[LICENSE](LICENSE) and `citation("susieRsmall")`.

Wang, G., Sarkar, A., Carbonetto, P. and Stephens, M. (2020).
A simple new approach to variable selection in regression, with application
to genetic fine mapping. *Journal of the Royal Statistical Society: Series B*,
82, 1273-1300. https://doi.org/10.1111/rssb.12388

Zou, Y., Carbonetto, P., Wang, G. and Stephens, M. (2022).
Fine-mapping from summary data with the Sum of Single Effects model.
*PLoS Genetics*, 18, e1010299. https://doi.org/10.1371/journal.pgen.1010299
