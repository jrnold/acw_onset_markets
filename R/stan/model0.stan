/*

  Univariate local level Dynamic linear model.

 */
data {
  int<lower=1> N;
  vector[N] y;
  int<lower=0, upper=1> missing[N];

  real m0;
  real<lower=0.0> C0;

  real xi_loc;
  real<lower=0.0> xi_scale;
}
parameters {
  real<lower=0.0> xi;
  real<lower=0.0> sigma;
}
transformed parameters {
  vector[N] loglik;
  // Kalman filter
  vector[N] a;
  vector<lower=0.0>[N] R;
  vector[N + 1] m;
  vector<lower=0.0>[N + 1] C;

  { // Kalman Filter
    real V; 
    real W; 
    real m_tmp;
    real C_tmp;
    real f;
    real err;
    real Q;
    real Qinv;
    V <- pow(xi, 2);
    W <- V * pow(sigma, 2);

    m_tmp <- m0;
    C_tmp <- C0;
    m[1] <- m_tmp;
    C[1] <- C_tmp;
    for (i in 1:N) {
      a[i] <- m_tmp;
      R[i] <- C_tmp + W;
      if (missing[i]) {
        // m does not change
        m_tmp <- a[i];
        m[i + 1] <- m_tmp;
        C_tmp <- R[i];
        C[i + 1] <- C_tmp;
        loglik[i] <- 0.0;
      } else {
        f <- a[i];
        Q <- R[i] + V;
        Qinv <- 1.0 / Q;
        err <- y[i] - f;
        m_tmp <- a[i] + R[i] * Qinv * err;
        C_tmp <- R[i] - pow(R[i], 2) * Qinv;
        m[i + 1] <- m_tmp;
        C[i + 1] <- C_tmp;
        loglik[i] <- -0.5 * (log(2 * pi()) + log(fabs(Q)) + pow(err, 2) * Qinv);
      }
    }
    increment_log_prob(sum(loglik));
  }

}
model {
  sigma ~ cauchy(0.0, 1.0);
  xi ~ lognormal(xi_loc, xi_scale);
}
generated quantities {
  vector[N + 1] theta;
  // Backward sample theta
  theta[N + 1] <- normal_rng(m[N + 1], sqrt(C[N + 1]));
  for (i in 1:N) {
    real h;
    real H;
    int j;
    real m_tmp;
    real C_tmp;
    j <- N - i;
    m_tmp <- m[j + 1];
    C_tmp <- C[j + 1];
    h <- m_tmp + C_tmp * (theta[j + 2] - a[j + 1]) / R[j + 1];
    H <- C_tmp - pow(C_tmp, 2) / R[j + 1];
    theta[j + 1] <- normal_rng(h, sqrt(H));
  }
}
