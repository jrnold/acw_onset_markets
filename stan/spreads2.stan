data {
  // dimensions
  int n; // number of observations
  int r; // number of variables
  int p; // number of states
  // observations
  int y_nobs;
  vector[y_nobs] y;
  int<lower = 1, upper = r> y_variable[y_nobs];
  int<lower = 1, upper = n> y_time[y_nobs];
  // system matrices
  // observation equation
  vector[p] loadings[r];
  vector[p] theta_init_loc;
  vector<lower = 0.0>[p] theta_init_scale;
  vector<lower = 0.0>[p] tau_scale;
}
transformed data {
  real<lower = 0.0> ysd;
  ysd <- sd(y);
}
parameters {
  real<lower = 0.0> sigma;
  vector<lower = 0.0>[p] tau;
  vector[p] theta[n];
  vector<lower = 0.0>[p] tau_local[n - 1];
  real<lower = 0.0> nu;
}
transformed parameters {
  vector[y_nobs] mu;
  for (i in 1:y_nobs) {
    mu[i] <- dot_product(loadings[y_variable[i]], theta[y_time[i]]);
  }
}
model {
  // AR(1) errors
  theta[1] ~ normal(theta_init_loc, theta_init_scale);
  for (i in 2:n) {
    theta[i] ~ normal(theta[i - 1], sigma * tau .* tau_local[i - 1]);
  }
  sigma ~ cauchy(0.0, ysd);
  tau ~ cauchy(0.0, tau_scale);
  for (i in 1:(n - 1)) {
    tau_local[i] ~ cauchy(0.0, 1.0);
  }
  nu ~ gamma(2, 0.1);
  y ~ student_t(nu, mu, sigma);
}
