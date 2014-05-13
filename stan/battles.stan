data {
  int N; // number of battles
  int M; // number of latent variables
  int K; // number of covariates
  vector[K] X[N];
  // observations
  int J; // number of observations
  int Jn[J];
  // observation variable 1
  vector[Jn[1]] y1;
  int idx1[Jn[1]];
}
parameters {
  vector[M] theta[N];
  matrix[K, M] beta;
  vector[M] alpha;
  cov_matrix[M] Sigma;
  // variables
  real<lower=0.0> zeta1;
}
transformed parameters {
  matrix[M, M] Sigma_chol;
  Sigma_chol <- cholesky_decompose(Sigma);
}
model {
  // measurement
  for (i in 1:N) {
    theta[i] ~ multi_normal_cholesky(alpha + beta * X[i], Sigma_chol);
  }
  // observations
  for (i in 1:Jn[1]) {
    y1[i] ~ normal(theta[i, 1], zeta1);
  }
}
