/*

  Local level model with constant trend and informative prior on measurement error.
  Estimated without the Kalman filter.

  $$
  \begin{aligned}[t]
  y_{t} &\sim N(\theta_t, \tau^2) \\
  theta_t \sim N(\alpha + \rho \theta_{t-1}, \sigma^2)  \\
  theta_0 \sim N(m0, C0)
  \end{aligned}
  $$

 */
data {
  int<lower=1> nobs;
  vector[nobs] y;
  vector[nobs] s2;
  int<lower=1> N;
  int<lower=1, upper=N> time[nobs];

  real theta0_loc;
  real<lower=0.0> theta0_scale;

  int n_battles;
  int n_outcomes;

  int n_lag_wgts;
  vector[n_lag_wgts] lag_wgts;
  int<lower=1, upper=n_battles> lag_battle[n_lag_wgts];
  int<lower=1, upper=n_outcomes> lag_outcome[n_lag_wgts];
  int<lower=1, upper=N> lag_times[n_lag_wgts];
}
parameters {
  real<lower=0.0> tau;
  real alpha;
  real<lower=0, upper=1> rho;
  vector[N + 1] theta_innov;
  real<lower=0.0> sigma;
  // regression coefs
  vector[n_outcomes] beta;
  // battle random effects
  vector[n_battles] omega;
  // scale of battle random effects
  real<lower=0.0> xi;
}
transformed parameters {
  vector[N + 1] theta;
  vector[N] Dtheta;  
  vector[nobs] mu;
  vector[nobs] tau_vec;

  Dtheta <- rep_vector(0.0, N);
  for (i in 1:n_lag_wgts) {
    Dtheta[lag_times[i]] <-
      lag_wgts[i] * (omega[lag_battle[i]] + beta[lag_outcome[i]]);
  }
  
  theta[1] <- theta0_loc + theta0_scale * theta_innov[1];
  for (i in 2:(N + 1)) {
    theta[i] <- alpha + rho * theta[i - 1] + Dtheta[i - 1] + sigma * theta_innov[i];
  }
  for (i in 1:nobs) {
    mu[i] <- theta[time[i]];
    tau_vec[i] <- sqrt(pow(tau, 2) + s2[i]);
  }
}
model {
  omega ~ normal(0, xi);
  theta_innov ~ normal(0, 1);
  y ~ normal(mu, tau_vec);
}
generated quantities {
  vector[nobs] log_lik;
  for (i in 1:nobs) {
    log_lik[i] <- normal_log(y[i], mu[i], tau_vec[i]);
  }
}
