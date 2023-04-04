# stanをコンパイルし、mcmcを実行するファイル

library(tidyverse)
library(here)
library(cmdstanr)
library(bayesplot)
library(tidybayes)

options(mc.cores = parallel::detectCores())

# 関数の読み込み
common_functions_path <- here("Rfunctions", "common")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

model_functions_path <- here("Rfunctions", "model_analysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

project_functions_path <- here("Rfunctions", "project")
project_functions <- here(project_functions_path, dir(project_functions_path))
purrr::walk(project_functions, ~source(.x))


# ------ basicRL ----------

# * fit01 -------

stan_name <- "basicRL.stan"
sub_index <- "fit02"

# データパスの取得
dir_list <- list("Model_Simulation_Recovery", "basicRL_sim")
target_data_path <- make_filepath(dir_list, "_20230217142523", "simulated_data.csv")

# set cmdstanr arguments
stan_set <- 
  list(
    seed = 123,
    init = NULL,
    chains = 4,
    parallel_chains = 4,
    iter_sampling = 1000,
    iter_warmup = 1000,
    adapt_delta = NULL,
    thin = 1
  )


# ファイルの保存先を作成 & 取得
save_path <- setup_savepath(target_data_path, stan_name, sub_index, fit_sim = "fit", same_as_file = TRUE)

# get .stan path
stanfile_path <- here("Model_StanFiles", stan_name)

# compile
mod <- cmdstanr::cmdstan_model(stanfile_path)

# 保存する変数のリスト
save_var_list <- 
  list(
    main_params = c("alpha", "beta"),
    loglik = "log_lik",
    pred = c("Q", "prob_choice")
    )

# sampling
fit_basicRL(target_data_path, mod, stan_set, save_path, save_var_list)


# ------ RandRsp ----------

# * fit01 -------

stan_name <- "RandRsp.stan"
sub_index <- "fit02"

# データパスの取得
dir_list <- list("Model_Simulation_Recovery", "RandRsp_sim")
target_data_path <- make_filepath(dir_list, "_20230217142944", "simulated_data.csv")


# set cmdstanr arguments
stan_set <- 
  list(
    seed = 234,
    init = NULL,
    chains = 4,
    parallel_chains = 4,
    iter_sampling = 1000,
    iter_warmup = 1000,
    adapt_delta = NULL,
    thin = 1,
    cores = 4
  )


# ファイルの保存先を作成 & 取得
save_path <- setup_savepath(target_data_path, stan_name, sub_index, fit_sim = "fit", same_as_file = TRUE)

# get .stan path
stanfile_path <- here("Model_StanFiles", stan_name)

# compile
mod <- cmdstanr::cmdstan_model(stanfile_path)

# 保存する変数のリスト
save_var_list <- 
  list(
    main_params = "b",
    loglik = "log_lik"
  )

# sampling
fit_RandRsp(target_data_path, mod, save_path, stan_set, save_var_list)



# ------ NWSLS ----------

# * fit01 -------

stan_name <- "NWSLS.stan"
sub_index <- "fit02"


# データパスの取得
dir_list <- list("Model_Simulation_Recovery", "NWSLS_sim")
target_data_path <- make_filepath(dir_list, "_20230217142916", "simulated_data.csv")

# set cmdstanr arguments
stan_set <- 
  list(
    seed = 567,
    init = NULL,
    chains = 4,
    parallel_chains = 4,
    iter_sampling = 1000,
    iter_warmup = 1000,
    adapt_delta = NULL,
    thin = 1,
    cores = 4
  )


# ファイルの保存先を作成 & 取得
save_path <- setup_savepath(target_data_path, stan_name, sub_index, fit_sim = "fit", same_as_file = TRUE)

# get .stan path
stanfile_path <- here("Model_StanFiles", stan_name)

# compile
mod <- cmdstanr::cmdstan_model(stanfile_path)

# 保存する変数のリスト
save_var_list <- 
  list(
    main_params = c("epsilon", "init_prob"),
    loglik = "log_lik",
    pred = "prob_choice"
  )

# sampling
fit_NWSLS(target_data_path, mod, save_path, stan_set, save_var_list)





