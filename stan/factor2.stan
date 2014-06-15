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
  matrix[r, p] loadings;
  vector[p] theta_init_loc;
  vector[p] theta_init_scale;
}
transformed data {
}
parameters {
  // vector[p] epsilon[n];
  vector[p] theta[n];
  vector<lower = 0.0>[p] tau_global;
  // vector<lower = 0.0>[p] tau_local[n];
  real<lower = 0.0> sigma;
}
transformed parameters {
  vector[y_nobs] mu;
  // for (j in 1:p) {
  //   theta[1, j] <- theta_init_loc[j] + theta_init_scale[j] * epsilon[1, j];
  //   for (i in 2:n) {
  //     theta[i, j] <- (theta[i - 1, j]
  // 		      + sigma * tau_global[j] * epsilon[i, j]);
  //   }
  // }
  for (i in 1:y_nobs) {
    mu[i] <- dot_product(loadings[y_variable[i]] , theta[y_time[i]]);
  }
}
model {
  tau_global ~ cauchy(0, 1);
  // for (i in 1:n) {
  //   tau_local[i] ~ cauchy(0, 1);
  // }
  for (i in 1:n) {
    // epsilon[i] ~ normal(0, 1);
    theta[i] ~ normal(6, 20);
  }
  y ~ normal(mu, sigma);
}
