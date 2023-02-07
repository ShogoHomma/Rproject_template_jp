
// Memo: see https://mc-stan.org/docs/2_18/stan-users-guide/indexing-efficiency-section.html
// matrix: column-major order - matrix[m, n] n -> m,
// array: row-major order - array[m, n] m -> n

data {
  
  int<lower=1> N;
  int<lower=1> T;
  int Choice[N, T];
  matrix[T, N] Reward;
  
}

parameters {
  
  vector<lower=0, upper=1>[N] alpha; // learning rate
  vector<lower=0, upper=10>[N] beta; // inverse temperature
  
}

model {
  
  matrix[2, T] Q[N];
  
  for (n in 1:N) {
    
    // initialize the Qvalue matrix
    Q[n, 1, 1] = 0;
    Q[n, 2, 1] = 0; 
    
    // calculate likelihood & update Q value 
    for (t in 1:T) {
      
      // add log-likelihood
      target += log(1.0/(1.0 + exp(-beta[n] * (Q[n, Choice[n, t], t] - Q[n, 3-Choice[n, t], t]))));
      
      if (t < T) {
        
        Q[n, Choice[n, t], t+1] = Q[n, Choice[n, t], t] + alpha[n] * (Reward[t, n] - Q[n, Choice[n, t], t]);
        Q[n, 3-Choice[n, t], t+1] = Q[n, 3-Choice[n, t], t];
        
      }
      
    }
    
  }
  
  // prior (vectorized)
	to_vector(alpha) ~ normal(0.5, 10);
	to_vector(beta) ~ cauchy(0, 10);
  
}
