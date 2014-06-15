data {
  // dimensions
  int n; // number of observations
  int r; // number of variables
  int p; // number of states
  // observations
  vector[r] y[n];
  int observed[n, r];
  // system matrices
  // observation equation
  matrix[r, p] F;
  vector[p] m0;
  cov_matrix[p] C0;
  real Qfill;
  vector[p] g;
  matrix[p, p] G;
  vector[r] b;
}
transformed data {
  matrix[p, p] Ip;
  {
    vector[p] Ip_vector;
    Ip_vector <- rep_vector(1, p);
    Ip <- diag_matrix(Ip_vector);
  }
}
parameters {
  vector<lower = 0.0>[p] tau;
  real<lower = 0.0> sigma;
}
transformed parameters {
  // log-likelihood
  matrix[n, r] loglik_obs;
  real loglik;
  // prior of state: p(theta_t | y_t, ..., y_{t-1})
  vector[p] a[n];
  cov_matrix[p] R[n];
  // likelihood of obs: p(y_t | y_t, ..., y_t-1)
  vector[r] f[n];
  vector<lower=0.0>[r] Q[n];
  // posterior of states: p(theta_t | y_t, ..., y_t)
  vector[p] m[n + 1];
  cov_matrix[p] C[n + 1];
  vector[r] V;
  matrix[p, p] W[n];

  W <- rep_matrix(0, p, p);
  for (j in 1:p) {
    W[j, j] <- pow(sigma * tau[j], 2);
  }
  V <- rep_vector(pow(sigma, 2), r);
  
  {
    
    real err;
    vector[p] K;
    matrix[p, p] J;
    vector[p] m_tmp;
    matrix[p, p] C_tmp;
    vector[p] Fj;
    
    // set initial states
    m[1] <- m0;
    C[1] <- C0;
    // loop through observations
    for (t in 1:n) {
      a[t] <- g + G * m[t];
      R[t] <- quad_form(C[t], G ') + W;
      m_tmp <- a[t];
      C_tmp <- R[t];
      for (j in 1:r) {
	if (observed[t, j]) {
	  Fj <- row(F, j) ';
	  // one step ahead predictive distribion of \theta_t | y_{1:(t-1)}
	  // one step ahead predictive distribion of y_t | y_{1:(t-1)}
	  f[t, j] <- b[j] + dot_product(Fj, m_tmp);
	  Q[t, j] <- Fj ' * C_tmp * Fj + V[j]; 
	  // forecast error
	  err <- y[t, j] - f[t, j];
	  // Kalman gain
	  K <- C_tmp * Fj / Q[t, j];
	  // posterior distribution of \theta_t | y_{1:t}
	  m_tmp <- m_tmp + K * err;
	  // matrix used in Joseph stabilized form
	  J <- (Ip - K * Fj ');
	  C_tmp <- quad_form(C_tmp, J ') + K ' * K * V[j];
	  // log likelihood
	  loglik_obs[t, j] <- - 0.5 * (log(2 * pi())
				       + log(Q[t, j])
				       + pow(err, 2) / Q[t, j]);
	} else {
	  f[t, j] <- 0.0;
	  Q[t, j] <- Qfill;
	  loglik_obs[t, j] <- 0.0;
	}
      }
      m[t + 1] <- m_tmp;
      C[t + 1] <- 0.5 * (C_tmp + C_tmp ');
    }
  }
  loglik <- sum(loglik_obs);
}
model {
  increment_log_prob(loglik);
  tau ~ cauchy(0, 1);
}
generated quantities {
  vector[p] theta[n + 1];
  theta[n + 1] <- multi_normal_rng(m[n + 1], C[n + 1]);
  for (i in 1:n) {
    int t;
    vector[p] h;
    matrix[p, p] H;
    matrix[p, p] Rinv;
    t <- n - i + 1;
    Rinv <- inverse(R[t]);
    // sample 
    h <- m[t] + C[t] * G ' * Rinv * (theta[t + 1] - a[t]);
    H <- C[t] - C[t] * G ' * Rinv * G * C[t];
    theta[t] <- multi_normal_rng(h, 0.5 * (H + H '));
  }
}