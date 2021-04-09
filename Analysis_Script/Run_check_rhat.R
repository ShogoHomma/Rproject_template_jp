# stanオブジェクトを読み込み、Rhatが1.1以上のパラメータを出力するファイル

library(tidyverse)
library(rstan)
library(here) 

# 関数の読み込み
model_functions_path <- here("Analysis_Script", "_functions_ModelBasedAnalysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

common_functions_path <- here("Analysis_Script", "_functions_common")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

# 出力の保存先
output_path <- here("Data", "Models_Results")


# ------ basic_RL model ----------

# * fit01 -------

stan_name <- "basic_RL"
fit_number <- "fit01"
stanfit_pattern <- "stanfit.obj"

# 出力の保存先を作成 & 取得
save_path <- output_setup(output_path, stan_name, "Rhat", fit_number)

# stan.objのパスの取得
target_stanfit <- make_DataPath(output_path, "basic_RL", "fit01", stanfit_pattern)

# Rhatの確認
check_Rhat(target_stanfit, save_path)



