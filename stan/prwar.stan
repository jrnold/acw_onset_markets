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
}
transformed data {
  vector[n_times] sqrt_tdiff;
  for (i in 1:n_times) {
    sqrt_tdiff[i] <- sqrt(tdiff[i]);
  }
}
parameters {
  vector<lower = 0.0, upper = 1000>[n_times] beta;
  vector<lower = 0.0>[n_series] psi;
}
transformed parameters {
  vector[nobs] mu;
  for (i in 1:nobs) {
    vector[n_payments[i]] mu_i;
    for (j in 1:n_payments[i]) {
      real P1;
      real P2;
      if (j == 1) {
	P1 <- exp(exponential_cdf_log(maturity[i, j], beta[time[i]]));
      } else {
	P1 <- (exp(exponential_cdf_log(maturity[i, j], beta[time[i]]))
	       - exp(exponential_cdf_log(maturity_lag[i, j], beta[time[i]])));
      }
      P2 <- exp(exponential_ccdf_log(maturity_lag[i, j], beta[time[i]]));
      mu_i[j] <- ((P2 * payment[i, j] + P1 * warpv[i, j])
      		  * exp(- maturity[i, j] * yield_peace[series[i]]));
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
}
generated quantities {
  vector[n_times] logprwar;
  for (i in 1:n_times) {
    logprwar[i] <- exponential_cdf_log(1, beta[i]);
  }
}
