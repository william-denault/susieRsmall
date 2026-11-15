test_that("the small-sample default equals the explicit Student-df-n prior", {
  set.seed(410)
  X = matrix(rnorm(240),30,8)
  y = X[,1] + rnorm(30)
  fit = function(...) susie(X,y,L=2,small=TRUE,...)
  default = fit()
  explicit = fit(alpha0=2,beta0=2*var(y))
  expect_equal(default$alpha,explicit$alpha)
  expect_equal(default$mu2,explicit$mu2)
  expect_equal(default$V,explicit$V)
  expect_equal(default$nig$alpha0,2)
  expect_equal(default$nig$beta0,2*var(y))
  # Explicit priors remain available, including the manuscript specification.
  manuscript = fit(alpha0=1/sqrt(30),beta0=1/sqrt(30))
  expect_equal(manuscript$nig$alpha0,1/sqrt(30))
  expect_equal(manuscript$nig$beta0,1/sqrt(30))
})

test_that("posterior draws have the integrated coefficient variance", {
  set.seed(412)
  X = matrix(rnorm(10),10,1)
  y = X[,1]+rnorm(10)
  fit = susie(X,y,L=1,small=TRUE,estimate_prior_variance=FALSE)
  samples = as.numeric(susie_get_posterior_samples(fit,20000)$b)
  # Independent moment from the already integration-tested NIG posterior.
  expected = as.numeric(fit$mu2-fit$mu^2)/fit$X_column_scale_factors^2
  expect_lt(abs(var(samples)/expected-1),0.08)
})

test_that("the integrated Bayes factor equals a ratio of Student densities", {
  set.seed(411)
  for (n in c(10,30,75)) {
    X = scale(matrix(rnorm(n*5),n,5),center=TRUE,scale=FALSE)
    y = as.numeric(scale(X[,1]+rnorm(n),center=TRUE,scale=FALSE))
    d = colSums(X^2)
    xy = drop(crossprod(X,y))
    bhat = xy/d
    rss = sum(y^2) - xy^2/d
    lambda = 2*var(y)
    for (V in c(0,0.2,2)) {
      # Independent reference: normalized Student densities at the MLE.
      s0 = sqrt((lambda+rss)/(n*d))
      s1 = s0*sqrt(1+d*V)
      reference = dt(bhat/s1,df=n,log=TRUE)-log(s1) -
                  dt(bhat/s0,df=n,log=TRUE)+log(s0)
      fit = single_effect_regression_nig(xy,d,sum(y^2),n-1,V,
                                         alpha0=2,beta0=lambda)
      expect_equal(fit$lbf,reference,tolerance=1e-10)
      expect_equal(2*fit$shape,n+1)
    }
  }
})
