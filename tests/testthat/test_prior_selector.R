test_that("the named NIG prior reproduces the simulation and legacy fits", {
  set.seed(913)
  X = matrix(rnorm(30*12),30,12)
  y = X[,1] + 0.5*X[,2] + rnorm(30)
  fit = function(...) susie(X,y,L=3,max_iter=300,...)
  named = fit(prior="nig")
  legacy = fit(small=TRUE)
  explicit = fit(small=TRUE,alpha0=2,beta0=2*var(y),
                 scaled_prior_variance=0.2,estimate_prior_method="optim")
  for (field in c("alpha","mu","mu2","V","pip","sets","nig","converged")) {
    expect_equal(named[[field]],legacy[[field]])
    expect_equal(named[[field]],explicit[[field]])
  }
  expect_true(named$small)
  expect_equal(fit(prior="nig",small=TRUE)$alpha,named$alpha)
})

test_that("the selector preserves Gaussian defaults and rejects contradictions", {
  set.seed(914)
  X = matrix(rnorm(30*8),30,8)
  y = X[,1] + rnorm(30)
  fit = function(...) susie(X,y,L=2,...)
  expect_equal(fit(prior="gaussian")$alpha,fit()$alpha)
  expect_equal(fit(prior="gaussian",small=FALSE)$alpha,fit()$alpha)
  expect_error(fit(prior="nig",small=FALSE),"select different priors")
  expect_error(fit(prior="gaussian",small=TRUE),"select different priors")
  expect_error(fit(prior="invalid"),"arg")
})
