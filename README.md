# Rproject_template_jp



<div style="text-align: right;">
  2021/04/07 本間祥吾
  </div>



このリポジトリは、北海道大学行動科学研究室、竹澤ゼミで使用する研究プロジェクトのフォルダテンプレートです。

実験、シミュレーション、データの分析を行うことを想定したフォルダ構成です。

既にいくつかのサンプルコードを用意しており、以下のプロセスを実行することができます。

- シミュレーションによるダミーデータの発生
- Rによるデータの分析 & 可視化
- stanによるモデルのフィッティング



## フォルダの構成



```
Rproject_template_jp
├ README.md
├ Rproject_template_jp.Rproj
│
├ Analysis_Script
│  ├ _functions ...
│  ├ _functions_Model-BasedAnalysis ...
│  ├ Models_Stan
│     ├ basic_RL.stan
│  ├ Rproject_template.Rmd
│  ├ Run_check_rhat.R
│  ├ Run_csv_generator.R
│  ├ Run_mcmc_sampling.R
│  ├ Run_posterior_traceplot_generator.R
│  
├ Data
│  ├ DummyData_RL
│  ├ Models_Results
│     ├ basic_RL
│
├ Document
├ Experiment
├ Output
├ Simulation_Code
│  ├ generate_DummyData_RL.R
│  
```



## フォルダの詳細



### 











