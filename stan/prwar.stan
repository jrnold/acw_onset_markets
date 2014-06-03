data {
  int<lower = 1> nobs;
  int<lower = 1> n_times;
  int<lower = 1> n_series;
  int<lower = 1, upper = n_times> time[nobs];
  vector<lower = 1>[n_times] tdiff;
  int<lower = 1, upper = n_series>  series[nobs];
  vector<lower = 0.0>[nobs] logprice;
  int<lower = 1> n_payments_max;
  int<lower = 1, upper = n_payments_max> n_payments[nobs];
  vector<lower = 0.0>[n_payments_max] payment[nobs];
  vector<lower = 0.0>[n_payments_max] maturity[nobs];
  vector<lower = 0.0>[n_payments_max] maturity_lag[nobs];
  vector<lower = 0.0>[n_payments_max] warpv[nobs];    
  vector<lower = 0.0>[n_series] yield_peace;
  vector<lower = 0.0>[n_series] yield_war;
  real logbeta_init_mean;
  real<lower = 0.0> logbeta_init_sd;
}
transformed data {
  vector[n_times] sqrt_tdiff;
  for (i in 1:n_times) {
    sqrt_tdiff[i] <- sqrt(tdiff[i]);
  }
}
parameters {
  vector<lower = 0.0>[n_times] logbeta_eps;
  vector<lower = 0.0>[n_series] psi;
  real<lower = 0.0> sigma;
}
transformed parameters {
  vector[nobs] mu;
  vector[n_times] logbeta;
  vector<lower = 0.0>[n_times] beta;
  logbeta[1] <- logbeta_init_mean + logbeta_init_sd * logbeta_eps[1];
  for (i in 2:n_times) {
    logbeta[i] <- logbeta[i - 1] + sigma * logbeta_eps[i];
  }
  beta <- exp(logbeta);
  for (i in 1:nobs) {
    vector[n_payments[i]] mu_i;
    for (j in 1:n_payments[i]) {
      // real P1
      real P2;
      real P1;      
      P1 <- exponential_cdf_log(maturity_lag[i, j], beta[time[i]]);
      P2 <- exponential_ccdf_log(maturity_lag[i, j], beta[time[i]]);
      mu_i[j] <-
	(exp(P2 + log(payment[i, j]) - (maturity[i, j] * yield_peace[series[i]]))
	 + exp(P1 + log(payment[i, j]) - (maturity[i, j] * yield_war[series[i]])));
    }
    mu[i] <- log(sum(mu_i));
  }
}
model {
  vector[nobs] psi_t;
  for (i in 1:nobs) {
    psi_t[i] <- psi[series[i]];
  }
  logprice ~ normal(mu, psi_t);
  logbeta_eps ~ normal(0, 1);
}
generated quantities {
  vector[n_times] logprwar;
  for (i in 1:n_times) {
    logprwar[i] <- exponential_cdf_log(1, beta[i]);
  }
}
