# 特定の条件に当てはまるファイル (.csvなど) のパスを作成する関数
## 取り出したいファイル（群）があるフォルダまでのパスを dir_listでリストで渡す
## ディレクトリの特徴を、dir_patternで指定
## ファイルの特徴を、file_patternで指定

make_filepath <- function(dir_list, dir_pattern, file_pattern) {
  
  target_path <- here(dir_list)
  
  #print(paste0("--- target path : ", target_path))
  
  all_dir <- dir(target_path, recursive = TRUE)
  
  # dir_patternに応じて、ディレクトリを絞る
  if (is.character(dir_pattern) == TRUE) {
    
    target_dir <- all_dir[stringr::str_detect(all_dir, pattern = dir_pattern)]
    
  } else {
    
    print("dir_pattern was not specified.")
    target_dir <- all_dir
    
  }
  
  #print("--- target dirs")
  #print(target_dir)
  
  # file_patternに応じて、ファイルの種類を絞る
  if (is.character(file_pattern) == TRUE) {
    
    target_file <- target_dir[stringr::str_detect(target_dir, pattern = file_pattern)]
    
  } else {
    
    print("file_pattern was not specified.")
    target_file <- target_dir
    
  }
  
  #print("--- target files")
  #print(target_file)
  
  target_file_path <- here(target_path, target_file)
  
  #print("--- target file path")
  #print(target_file_path)
  
  return(target_file_path)
  
}
