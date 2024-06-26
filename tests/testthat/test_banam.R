set.seed(3)
n <- 50
d1 <- .1
Wadj1 <- sna::rgraph(n, tprob=d1, mode="graph")
W1 <- sna::make.stochastic(Wadj1, mode="row")
d2 <- .3
Wadj2 <- sna::rgraph(n, tprob=d2, mode="graph")
W2 <- sna::make.stochastic(Wadj2, mode="row")
# set rho, beta, sigma2, and generate y
rho1 <- 0
rho2 <- .4
K <- 3
beta <- rnorm(K)
sigma2 <- 1
X <- matrix(c(rep(1, n), rnorm(n*(K-1))), nrow=n, ncol=K)
y <- c(solve(diag(n) - rho1*W1 - rho2*W2)%*%(X%*%beta + rnorm(n)))

#Bayesian estimation of NAM with a single weight matrix using a flat prior for rho
best1 <- banam(y,X,W1,postdraws=1e3,burnin=1e1)
test_that("Test correct estimated rho for a NAM with one weight matrix", {
  expect_equivalent(
    best1$rho.mean,0.171, tolerance = .03
  )})
BF1a <- BF(x=best1,hypothesis="rho < .4")
test_that("Test correct exploratory PHPs for a NAM with one weight matrix", {
  expect_equivalent(
    BF1a$PHP_exploratory[1,],c(0.73,0.06,0.21), tolerance = .03
  )})
test_that("Test correct one-sided PHPs for a NAM with one weight matrix", {
  expect_equivalent(
    BF1a$PHP_confirmatory[1],.775, tolerance = .05
  )})
BF1b <- BF(x=best1,hypothesis="beta1 < beta2 < 0 ; beta1 = beta2 = 0")
test_that("Test correct multiple test on beta's for a NAM with one weight matrix", {
  expect_equivalent(
    BF1b$PHP_confirmatory[1],.273, tolerance = .05
  )})

#Bayesian estimation of NAM with two weight matrices using standard normal priors
set.seed(123)
best2 <- banam(y,X,W=list(W1,W2),prior.mean=c(0,0),prior.Sigma=.25*diag(2),postdraws=5e2,burnin=1e2)
test_that("Test correct estimates for rho's for a NAM with two weight matrices", {
  expect_equivalent(
    best2$rho.mean,c(0.10,0.17), tolerance = .05
  )})
BF2b <- BF(x=best2, hypothesis = "rho1 = 0; rho2 = 0; rho1=rho2=0; rho1>rho2>0;
        rho1=rho2<0",postdraws=5e2,burnin=1e2)
test_that("Test correct exploratory PHPs for a NAM with two weight matrices", {
  expect_equivalent(
    BF2b$PHP_exploratory[1:2,1],c(0.76,.76), tolerance = .05
  )})
test_that("Test correct confirmatory PHPs for a NAM with two weight matrices", {
  expect_equivalent(
    BF2b$PHP_confirmatory[1:3],c(0.11,0.12,0.66), tolerance = .05
  )})
BF2c <- BF(x=best2, hypothesis = "beta1 < beta2 = 0",postdraws=5e2,burnin=1e2)
test_that("Test correct confirmatory PHPs for a NAM with two weight matrices", {
  expect_equivalent(
    BF2c$PHP_confirmatory,c(0.93,0.07), tolerance = .05
  )})



