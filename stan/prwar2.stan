data {
  int n; // number of observations
  int r; // number of variables
  int y_nobs;
  vector[y_nobs] y;
  int<lower = 1, upper = r> y_variable[y_nobs];
  int<lower = 1, upper = n> y_time[y_nobs];
  vector[y_nobs] recovery;
  vector[r] riskfree_mean;
  vector<lower=0.0>[r] riskfree_sd;
}
transformed data {
  real<lower = 0.0> ysd;
  ysd <- sd(y);
}
parameters {
  real<lower = 0.0> sigma;
  real<lower = 0.0> tau;
  vector[n] theta;
  vector<lower = 0.0>[n - 1] tau_local;
  vector<lower = 0.0>[r] riskfree;
  real<lower = 0.0> nu;
}
transformed parameters {
  vector<lower = 0.0, upper = 1.0>[n] phi;
  vector[y_nobs] mu;
  for (i in 1:n) {
    phi[i] <- inv_logit(theta[i]);
  }
  for (i in 1:y_nobs) {
    mu[i] <- ((1 - recovery[i]) * phi[y_time[i]]
	      + riskfree[y_variable[i]]);
  }
}
model {
  riskfree ~ lognormal(riskfree_mean, riskfree_sd);
  theta ~ normal(0, 10);
  for (i in 2:n) {
    theta[i] ~ normal(theta[i - 1], tau * tau_local[i - 1]);
  }
  sigma ~ cauchy(0.0, ysd);
  for (i in 1:(n - 1)) {
    tau_local[i] ~ cauchy(0.0, 1.0);
  }
  nu ~ gamma(2, 0.1);
  y ~ student_t(nu, mu, sigma);
}
generated quantities {
  vector[y_nobs] loglik;
  for (i in 1:y_nobs) {
    loglik[i] <- normal_log(y[i], mu[i], sigma);
  }
}
