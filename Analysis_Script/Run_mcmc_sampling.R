# stanをコンパイルし、mcmcを実行するファイル

library(tidyverse)
library(rstan)
library(here) 
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 関数の読み込み
model_functions_path <- here("Analysis_Script", "_functions_Model-BasedAnalysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

# フィッティング結果の出力先
output_path <- here("Data", "Models_Results")


### ------ Run Model-Fitting ----- ###

# ------ basic_RL model ----------

# * fit01 -------

stan_name <- "basic_RL.stan"
fit_number <- "fit01"

# ファイルの保存先を作成 & 取得
save_path <- output_setup(output_path, stan_name, "stanfit", fit_number) 

# データパスの取得
target_data <- make_DataPath("Data", "DummyData_RL", "_20210322151628", ".csv")

# コンパイル & MCMCの実行

stan_set <- 
  list(
    seed = 123, 
    chains = 4, 
    iter = 2000, 
    warmup = 1000,
    init = "random",
    thin = 1,
    cores = 4
  )

stan_path <- here("Analysis_Script", "Models_Stan", stan_name)
stan_model <- rstan::stan_model(file = stan_path) # コンパイル (あとで rstan::samplingでモデルを実行)

fit_basicRL(target_data, stan_model, save_path, stan_set)




