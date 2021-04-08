# 一つ or 複数のデータファイル (.csvなど) のパスを作成する関数
## Dir：プロジェクトディレクトリの直下にある、焦点のディレクトリ
## Dir_sub：もう1つ下のディレクトリ

#library(here)

make_DataPath <- function(Dir, Dir_sub, dir_pattern, csv_pattern) {
  
  target_path <- here(Dir, Dir_sub)
  target_dir <- dir(target_path, recursive = TRUE)[stringr::str_detect(dir(target_path, recursive = TRUE), pattern = dir_pattern)]
  target_csvs <- here(target_path, target_dir[stringr::str_detect(target_dir, pattern = csv_pattern)])
  
  return(target_csvs)
  
}
