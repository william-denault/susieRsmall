# susieRsmall 0.14.21.9003

* Package the corrected implementation as `susieRsmall`, alongside vanilla `susieR`.
* Add `prior = "nig"`; retain the equivalent `small = TRUE` call.
* Provide a standalone package at the root of `william-denault/susieRsmall`.
* Preserve the fitting calculations from the corrected .9002 implementation.

# susieR 0.14.21.9002 (small-sample branch)

* Use a consistent normal-inverse-gamma SER: V is a variance ratio,
  alpha0 is twice the inverse-gamma shape, and beta0 is twice its scale.
* Default to alpha0 = 2 and beta0 = 2 * var(y) with an intercept. Each
  SER Bayes factor then equals a ratio of Student densities with df = n.
* Fit V using the NIG likelihood and use the correct posterior moments.
* Use twice the inverse-gamma posterior shape as the Student degrees of
  freedom for posterior draws and local false sign rates.
* Preserve the Gaussian calculations and explicit prior overrides.
* Document that multiple-effect NIG IBSS has no established joint ELBO
  or calibration guarantee. Add integration, invariance and Student-ratio tests.
* Rename the existing test helper to the naming convention recognized by
  current testthat, so the complete legacy test suite can run normally.

See SMALL_SAMPLE_UPDATE.md for the derivation and a guide to the changed files.
