data {
  int nobs;
  int n_times;
  int n_series;
  vector[n_times] tdiff;
  int time[nobs];
  int series[nobs];
  vector<lower = 0.0>[nobs] logprice;
  int n_payments_max;
  int<lower = 1, upper = n_payments_max> n_payments[nobs];
  vector[n_payments_max] payment[nobs];
  vector<lower = 0.0>[n_payments_max] maturity[nobs];
  vector<lower = 0.0>[n_series] yield_peace;
  vector<lower = 0.0>[n_series] yield_war;
  real loglambda_init_mean;
  real<lower = 0.0> loglambda_init_sd;  
}
transformed data {
  vector[n_times] sqrt_tdiff;
  for (i in 1:n_times) {
    sqrt_tdiff[i] <- sqrt(tdiff[i]);
  }
}
parameters {
  vector[n_times] loglambda_innov;
  real<lower = 0.0> sigma;
  vector<lower = 0.0>[n_series] psi;
}
transformed parameters {
  vector[nobs] mu;
  vector[n_times] loglambda;
  vector<lower = 0.0>[n_times] lambda;
  loglambda[1] <- loglambda_init_mean + loglambda_init_sd * loglambda_innov[1];
  for (i in 2:n_times) {
    loglambda[i] <- loglambda[i - 1] + sqrt_tdiff[i] * sigma * loglambda_innov[i];
  }
  lambda <- exp(loglambda);
  for (i in 1:nobs) {
    vector[n_payments[i]] mu_i;
    for (j in 1:n_payments[i]) {
      mu_i[j] <-
      	payment[i, j] * (exp(exponential_cdf_log(maturity[i, j], lambda[time[i]])
			      - maturity[i, j] * yield_war[series[i]])
			  + exp(exponential_ccdf_log(maturity[i, j], lambda[time[i]])
				- maturity[i, j] * yield_peace[series[i]]));
    }
    mu[i] <- log(sum(mu_i));
  }
}
model {
  vector[nobs] psi_t;
  for (i in 1:nobs) {
    psi_t[i] <- psi[series[i]];
  }
  loglambda_innov ~ normal(0, 1);
  logprice ~ normal(mu, psi_t);
}
generated quantities {
  vector[n_times] logprwar;
  for (i in 1:n_times) {
    logprwar[i] <- exponential_cdf_log(1, lambda[i]);
  }
}
