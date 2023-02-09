# stanをコンパイルし、mcmcを実行するファイル

library(tidyverse)
library(here)
library(cmdstan)
library(bayesplot)
library(tidybayes)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 関数の読み込み
common_functions_path <- here("Rfunctions", "common")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

model_functions_path <- here("Rfunctions", "model_analysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

# フィッティング結果の出力先
recovery_output_path <- here("Model_Simulation_Recovery", "Fit_Results")
expfit_output_path <- here("FitResults_ExpData")


# ------ basicRL model ----------

# * fit01 -------

stan_name <- "basicRL.stan"
fit_index <- "fit01"

# ファイルの保存先を作成 & 取得
save_path <- output_setup(expfit_output_path, stan_name, fit_index) 

# データパスの取得
dir_list <- list("Simulated_Data", "basicRL")
target_data_path <- make_filepath(dir_list, "_20210322151628", ".csv")

# set cmdstanr arguments
stan_set <- 
  list(
    seed = 123,
    init = NULL,
    chains = 4,
    parallel_chains
    iter_sampling = 2000,
    iter_warmup = 1000,
    adapt_delta = 0.95
    thin = 1,
    cores = 4
  )

# get .stan path
stanfile_path <- here("Model_StanFiles", stan_name)

# compile
mod <- cmdstanr::cmdstan_model(stanfile_path)

# sampling
fit_basicRL(target_data_path, mod, save_path, stan_set)


