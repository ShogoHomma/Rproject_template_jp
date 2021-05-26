# -*- coding: utf-8 -*-

#%%

import csv, datetime, sys, os, random, itertools, math, shutil
import numpy as np
import pandas as pd

#%%

"""
Set Simulation Parameters
"""

# パラメータの配列をセット
alpha = [0.1, 0.3, 0.5, 0.7, 0.9]
beta = [0.5, 1.0, 1.5, 2.0, 2.5]

PopSize = len(list(itertools.product(alpha, beta))) # 直積から計算


# 課題パラメータをセット

Trial_N = 50
Op1_p = 0.6 # 選択肢1の報酬確率
Op2_p = 0.4 # 選択肢2（0）の報酬確率


# --- set parameters as a dictionary --- #

p_dict = {
    "PopSize": PopSize,
    "Trial_N": Trial_N,
    "alpha"  : alpha,
    "beta"   : beta,
    "Op1_p"  : Op1_p,
    "Op2_p"  : Op2_p
}


#%%

"""
Define Classes
"""

# in order to learn how to write docstring, 
# see https://qiita.com/simonritchie/items/49e0813508cad4876b5a

class SaveData:
    """
    データの保存、書き込みを行うためのclass
    """

    def __init__(self, dir_path):
        
        """
        Attributes
        -----------
        path : str
            シミュレーションの結果を保存するディレクトリの作成先
        dir_name : str
            シミュレーションの結果を保存するディレクトリの名前（自動作成）
        file_trial_name : str
            シミュレーションの結果を保存するcsvファイルの名前
        header_trial : list of str
            出力csvファイルのヘッダー
        time_stamp_now : 
            今の時間を記録しておく変数
        self.time_stamp_list : list of object
            記録した時間を保存しておくリスト
        time_stamp_check : list of integer
            どのタイミングで時間を記録するのかを示すリスト
        """
    
        self.dir_path = dir_path
        self.dir_name = None
        self.file_trial_name = None
        
        # header of name for output csv file
        self.header_trial = ['ID', 'alpha', 'beta', 'trial', 'Q1', 'Q2', 
                           'Prob', 'Choice', 'Reward', 'Op1_p', 'Op2_p']
        
        self.time_stamp_now = datetime.datetime.now()
        self.time_stamp_list = np.empty((11), dtype = 'object')
        self.time_stamp_list[0] = self.time_stamp_now
        
        self.time_stamp_check = np.linspace(0, PopSize-1, num = 11, dtype = 'int') # どのタイミングで時間を記録するかのリスト, 0を含めて11分割する
        
        
        # --- create directory name --- #

        head_chr = "DummyData_RL"
        n_trial_N = "trialN" + f"{Trial_N}"
        n_Op1_p = "1Op" + f"{Op1_p}"
        n_Op2_p = "2Op" + f"{Op2_p}"
        n_alpha = "alpha" + f"{alpha[0]}" + "-" + f"{alpha[len(alpha)-1]}"
        n_beta = "beta" + f"{beta[0]}" + "-" + f"{beta[len(beta)-1]}"
        time_stamp_now_chr = f"{self.time_stamp_now:%Y%m%d%H%M%S}"
        
        dir_name_list = [head_chr, n_trial_N, n_Op1_p, n_Op2_p, n_alpha, n_beta, time_stamp_now_chr]
        self.dir_name = self.dir_path + "_".join(dir_name_list)
        self.param_info_path = self.dir_name + "/_Parameters_info.txt"
        
        # ディレクトリを作成する
        if os.path.exists(self.dir_name):
            pass
        else:
            print(f"make new directory: {self.dir_name}")
            os.makedirs(self.dir_name)


    def writeParametersInfo(self, p_dict):
        """
        使用したパラメータの情報をtxtファイルとして保存する
        """

        with open(self.param_info_path, mode='w') as f:

            for key, value in p_dict.items():

                f.write(f'{key}: {value}\n')
            
            f.write(f'\n\nstart: {self.time_stamp_now}\n\n')
    

    def createFile(self):
        """
        csvと、ファイルのコピーを生成する
        """
        
        # データ保存用のcsvファイルの生成
        self.file_trial_name = f"./{self.dir_name}/RL_trial.csv"
        
        if os.path.exists(self.file_trial_name):
            print("the same name file exists! stop process.")
            sys.exit()
        else:
            print(f"make new file: {self.file_trial_name}")
            pd.DataFrame(columns = self.header_trial).to_csv(self.file_trial_name, index = False)
        
        # シミュレーションのファイル（このファイル）のコピー
        print(f"copy {__file__} ...")
        shutil.copyfile(__file__, f"./{self.dir_name}/{os.path.basename(__file__)}")
        
        
    def writeElapsedTime(self, pop_i):
        """
        全体（エージェント）の10%が終わるごとに、経過時間を記録する
        """
        
        for check_i in range(1, 11):
            
            if pop_i == self.time_stamp_check[check_i]: # pop_iが、self.time_stamp_checkにあれば、記録を開始する
                
                self.time_stamp_now = datetime.datetime.now()
                self.time_stamp_list[check_i] = self.time_stamp_now
                elapsed_time = self.time_stamp_list[check_i] - self.time_stamp_list[check_i-1]

                with open(self.param_info_path, mode='a') as f:
                    
                    print(f'pop_i: {pop_i}, end time: {self.time_stamp_now}, elapsed time: {elapsed_time}')
                    f.write(f'pop_i: {pop_i}, end time: {self.time_stamp_now}, elapsed time: {elapsed_time}\n')
        
            else:
                #print("No record.")
                pass
            
        
        
    def writeCSV_trial(self, agent):
        """
        csvファイルにデータを出力する
        """
        
        f = open(self.file_trial_name, "a")
        target_csv = csv.writer(f, lineterminator="\n")
        
        # trial_N * PopSizeぶんのデータを csvに書き出す
        for pop_i in range(PopSize):
            
            for trial_i in range(Trial_N):
                
                output = [agent[pop_i].ID, agent[pop_i].alpha, agent[pop_i].beta, trial_i, 
                        agent[pop_i].Q[trial_i, 1], agent[pop_i].Q[trial_i, 0], agent[pop_i].Prob[trial_i],
                        agent[pop_i].Choice[trial_i], agent[pop_i].Reward[trial_i], 
                        Op1_p, Op2_p]
            
                target_csv.writerow(output)
            
        f.close()
        
        

# %%

class Agent:
    
    """
    エージェントのclass
    """

    def __init__(self, ID, Trial_N):
        
        """
       Attributes
        -----------
        ID : integer
            エージェントのID番号
        Q : np matrix
            Qvalueを入れる行列
        delta : np vector
            RPEを入れるベクトル
        Choice : np vector of integer
            選択結果を入れるベクトル
        Reward : np vector
            得られた報酬を入れるベクトル
        Prob : np vector
            選択確率を入れるベクトル
        alpha : double
            学習率パラメータの値
        beta : double
            逆温度パラメータの値
        """
        
        self.ID     = ID
        self.Q      = np.zeros((Trial_N + 1, 2))
        self.delta  = np.zeros(Trial_N)
        self.Choice = np.empty(Trial_N, dtype = "int")
        self.Reward = np.empty(Trial_N)
        self.Prob   = np.empty(Trial_N)
        self.alpha  = 0
        self.beta   = 0
    
    
    def initialize(self, ID, Trial_N):
        
        """
        インスタンスを初期化するメソッド（冗長？）
        """

        self.ID     = ID
        self.Q      = np.zeros((Trial_N + 1, 2))
        self.delta  = np.zeros(Trial_N)
        self.Choice = np.empty(Trial_N, dtype = "int")
        self.Reward = np.empty(Trial_N)
        self.Prob   = np.empty(Trial_N)
        self.alpha  = 0
        self.beta   = 0 


    def setParameters(self, alpha, beta):
        """
        エージェントにパラメータを割り当てるメソッド
        """

        self.alpha = alpha
        self.beta  = beta
        
        
    def selectOption(self, trial_i):
        """
        選択確率を計算し、選択を行うメソッド
        """

        self.Prob[trial_i] = 1/(1+ math.exp(- self.beta * (self.Q[trial_i, 1] - self.Q[trial_i, 0])))
        
        self.Choice[trial_i] = np.random.choice([1,0], p = [self.Prob[trial_i], 1.0 - self.Prob[trial_i]])

    
    def getReward(self, trial_i):
        """
        報酬を獲得するメソッド
        """

        if self.Choice[trial_i] == 1:

            reward_trial = np.random.choice([1,0], p = [Op1_p, 1.0 - Op1_p])

        elif self.Choice[trial_i] == 0:

            reward_trial = np.random.choice([1,0], p = [Op2_p, 1.0 - Op2_p])
        
        else:
            print("Error. See method getReward()")
            sys.exit() 
        
        self.Reward[trial_i] = reward_trial

        
    def updateQValue(self, trial_i):
        """
        報酬に応じて、Q値を更新するメソッド
        """

        # RPEを計算
        self.delta[trial_i] = self.Reward[trial_i] - self.Q[trial_i, self.Choice[trial_i]]

        # Qvalueを更新
        self.Q[trial_i + 1, self.Choice[trial_i]] = self.Q[trial_i, self.Choice[trial_i]] + self.alpha * self.delta[trial_i]
        self.Q[trial_i + 1, 1 - self.Choice[trial_i]] = self.Q[trial_i, 1 - self.Choice[trial_i]]


#%%
        
def initializeAgent(agent):
    """
    全てのAgentのインスタンスを初期化する
    """

    for pop_i in range(PopSize):
        
        agent[pop_i].initialize(ID = pop_i, Trial_N = Trial_N)

        
def assignParameters(agent):
    """
    全てのAgentにパラメータを割り当てる
    """
    
    para_list = list(itertools.product(alpha, beta)) # 直積のリストを作成
    
    for pop_i in range(PopSize):
        
        agent[pop_i].setParameters(alpha = para_list[pop_i][0], beta = para_list[pop_i][1])
        


# %%

"""
Run QLearning Simulation
"""

# 保存先のパスを指定
save_data_path = "../Data/DummyData_RL/" # Simulation_Codeディレクトリから見たパス

# SaveDataのインスタンスを作成
save_data = SaveData(save_data_path)
save_data.writeParametersInfo(p_dict)
save_data.createFile()

# Agentのインスタンス配列を作成
agent = [Agent(ID = pop_i, Trial_N = Trial_N) for pop_i in range(PopSize)]

initializeAgent(agent) # インスタンスの初期化（冗長かも）
assignParameters(agent) # パラメータのセット

for pop_i in range(PopSize):
    
    for trial_i in range(Trial_N):
        
        agent[pop_i].selectOption(trial_i)
        agent[pop_i].getReward(trial_i)
        agent[pop_i].updateQValue(trial_i)
    
    save_data.writeElapsedTime(pop_i) # 終了時間と経過時間を書き出す

save_data.writeCSV_trial(agent) # csvに書き出す

