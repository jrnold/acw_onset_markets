data {
  int n; // number of observations
  int r; // number of variables
  int y_nobs;
  vector[y_nobs] y;
  int<lower = 1, upper = r> y_variable[y_nobs];
  int<lower = 1, upper = n> y_time[y_nobs];
  vector[y_nobs] recovery;
  vector<lower = 0.0>[r] riskfree;
  real theta_init_loc;
  real<lower = 0.0> theta_init_scale;
}
transformed data {
  real<lower = 0.0> ysd;
  ysd <- sd(log(y));
}
parameters {
  vector<lower = 0.0>[r] sigma;
  real<lower = 0.0> tau;
  vector<lower = 0.0>[n - 1] tau_local;
  vector[n] epsilon;
}
transformed parameters {
  vector[n] theta;
  vector<lower = 0.0, upper = 1.0>[n] phi;
  vector[y_nobs] mu;
  vector[y_nobs] sigma_vec;
  theta[1] <- theta_init_loc + theta_init_scale * epsilon[1];
  for (i in 2:n) {
    theta[i] <- theta[i - 1] + tau * tau_local[i - 1] * epsilon[i];
  }
  for (i in 1:n) {
    phi[i] <- inv_logit(theta[i]);
  }
  for (i in 1:y_nobs) {
    mu[i] <- log(((1 - recovery[i]) * phi[y_time[i]]
	                 + riskfree[y_variable[i]]));
  }
  for (i in 1:y_nobs) {
    sigma_vec[i] <- sigma[y_variable[i]];
  }
}
model {
  epsilon ~ normal(0.0, 1.0);
  sigma ~ cauchy(0.0, ysd);
  // global shrinkage parameter
  tau ~ cauchy(0.0, 1.0 / n);
  tau_local ~ cauchy(0.0, 1.0);
  y ~ lognormal(mu, sigma_vec);
}
generated quantities {
  vector[y_nobs] loglik;
  for (i in 1:y_nobs) {
    loglik[i] <- lognormal_log(y[i], mu[i], sigma_vec[i]);
  }
}
