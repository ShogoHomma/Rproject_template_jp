
// 変数宣言の古い書き方はstan 2.32からできなくなるので、新しい宣言の方法で書いている
// see https://mc-stan.org/docs/reference-manual/brackets-array-syntax.html

// Memo: see https://mc-stan.org/docs/2_18/stan-users-guide/indexing-efficiency-section.html
// matrix: column-major order - matrix[m, n] n -> m,
// array: row-major order - array[m, n] m -> n

data {
  
  int<lower=1> N;
  int<lower=1> T;
  array[N, T] int choice;
  array[T, N] real reward;
  
}

parameters {
  
  vector<lower=0, upper=1>[N] alpha; // learning rate
  vector<lower=0, upper=10>[N] beta; // inverse temperature
  
}

model {
  
  array[N] matrix[2, T] Q; 
  // memo: matrix[M, N] b[I, J] (b[i, j, m, n]) → array[I, J] matrix[M, N] b (b[i, j, m, n]);
  
  // prior (vectorized)
	to_vector(alpha) ~ uniform(0, 1);
	to_vector(beta) ~ exponential(1);
  
  for (n in 1:N) {
    
    // initialize the Qvalue matrix
    Q[n, 1, 1] = 0.0;
    Q[n, 2, 1] = 0.0; 
    
    // calculate likelihood & update Q value 
    for (t in 1:T) {
      
      // add log-likelihood
      target += 
      log( 1.0/(1.0 + exp(-beta[n] * ( Q[n, choice[n, t], t] - Q[n, 3-choice[n, t], t] ))) );
      
      if (t < T) {
        
        Q[n, choice[n, t], t+1] = Q[n, choice[n, t], t] + alpha[n] * (reward[t, n] - Q[n, choice[n, t], t]);
        Q[n, 3-choice[n, t], t+1] = Q[n, 3-choice[n, t], t];
        
      }
      
    }
    
  }
  
}

generated quantities {
  
  vector[T*N] log_lik;
  array[N] matrix[2, T] Q;
  array[T, N] real prob_choice;
  
  int trial_count;
  trial_count = 0;
  
  for (n in 1:N) {
    
    Q[n, 1, 1] = 0.0;
    Q[n, 2, 1] = 0.0; 
    
    for (t in 1:T) {
      
      trial_count = trial_count + 1;
      
      log_lik[trial_count] = log( 1.0/( 1.0 + exp(-beta[n] * (Q[n, choice[n, t], t] - Q[n, 3-choice[n, t], t])) ) );
      
      prob_choice[t, n] = 1.0/( 1.0 + exp(-beta[n] * (Q[n, 1, t] - Q[n, 2, t])) );
      
      
      if (t < T) {
        
        Q[n, choice[n, t], t+1] = Q[n, choice[n, t], t] + alpha[n] * (reward[t, n] - Q[n, choice[n, t], t]);
        Q[n, 3-choice[n, t], t+1] = Q[n, 3-choice[n, t], t];
        
      }
      
    }
    
  }
  
}
