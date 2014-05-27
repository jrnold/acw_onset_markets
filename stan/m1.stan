/*

  Local level model with constant trend and informative prior on measurement error.
  Estimated without the Kalman filter.

  $$
  \begin{aligned}[t]
  y_{t,j} &\sim N(gamma_j + \theta_t, \tau^2) \\
  theta_t \sim N(\alpha + \rho \theta_{t-1}, \sigma^2)  \\
  theta_0 \sim N(m0, C0)
  \end{aligned}
  $$

 */
data {
  int<lower=1> nobs;
  vector[nobs] y;
  int<lower=1> N;
  int<lower=1, upper=N> time[nobs];
  int<lower=1> r;
  int<lower=1, upper=r> variable[nobs];

  real theta0_loc;
  real<lower=0.0> theta0_scale;

}
parameters {
  vector<lower=0.0>[r] tau;
  real alpha;
  vector[r] gamma;
  real<lower=0, upper=1> rho;
  vector[N + 1] theta_innov;
  real<lower=0.0> sigma;
}
transformed parameters {
  vector[N + 1] theta;
  vector[N] Dtheta;  
  vector[nobs] mu;
  vector[nobs] tau_vec;
  theta[1] <- theta0_loc + theta0_scale * theta_innov[1];
  for (i in 2:(N + 1)) {
    theta[i] <- alpha + rho * theta[i - 1] + Dtheta[i - 1] + sigma * theta_innov[i];
  }
  for (i in 1:nobs) {
    mu[i] <- gamma[variable[i]] + theta[time[i] + 1];
    tau_vec[i] <- tau[variable[i]];
  }
}
model {
  theta_innov ~ normal(0, 1);
  y ~ normal(mu, tau_vec);
}
generated quantities {
  vector[nobs] loglik;
  for (i in 1:nobs) {
    loglik[i] <- normal_log(y[i], mu[i], tau_vec[i]);
  }
}
