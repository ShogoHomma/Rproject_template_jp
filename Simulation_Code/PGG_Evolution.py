# -*- coding: utf-8 -*-

import csv, datetime, sys, os, random, shutil, copy
import numpy as np
import pandas as pd

#%%

"""
Set Simulation Parameters
"""

Generation = 50 #世代数
N_pop = 100 #集団全体の人数
N_sub_pop = 4 #１グループあたりの人数
N_group = int(N_pop/N_sub_pop) # グループの数
Cost = 1 #協力にかかるコスト
Benefit = 2 #協力することで集団が得られる利益
Mutation_rate = 0.01 #突然変異が起こる確率
Init_rate_C = 0.9 #初期状態の協力者の割合


# --- set parameters as a dictionary --- #

p_dict = {
    "Generation"    : Generation,
    "N_pop"         : N_pop,
    "N_sub_pop"     : N_sub_pop,
    "N_group"       : N_group,
    "Cost"          : Cost,
    "Benefit"       : Benefit,
    "Mutation_rate" : Mutation_rate,
    "Init_rate_C"   : Init_rate_C
}


#%%

"""
Define Classes & Methods
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
        file_agent_name : str
            agentごとのシミュレーションの結果を保存するcsvファイルの名前
        file_generation_name : str
            generationごとのシミュレーションの結果を保存するcsvファイルの名前
        header_agent : list of str
            出力csvファイルのヘッダー (file_agent_name)
        header_generation : list of str
            出力csvファイルのヘッダー (file_generation_name)
        self.output_agent : numpy array (dtype = object)
            agentごとのシミュレーション結果を一時的に保存しておく
        self.output_generation : numpy array (dtype = float64)
            generationごとのシミュレーション結果を一時的に保存しておく
        time_stamp_now : 
            今の時間を記録しておく変数
        self.time_stamp_list : list of object
            記録した時間を保存しておくリスト
        time_stamp_check : list of integer
            どのタイミングで時間を記録するのかを示すリスト
        """
    
        self.dir_path = dir_path
        self.dir_name = None
        self.file_agent_name = None
        self.file_generation_name = None
        
        # header of name for output csv file
        self.header_agent = ['Generation', 'ID', 'group', 'gene_CD', 'payoff', 'offspring']
        self.header_generation = ['Generation', 'freq_C', 'freq_D']
        
        # list for output
        self.output_agent = np.empty((Generation*N_pop, len(self.header_agent)), dtype='object')
        self.output_generation = np.empty((Generation, len(self.header_generation)))
        
        # variables for writing elapsed time
        self.time_stamp_now = datetime.datetime.now()
        self.time_stamp_list = np.empty((11), dtype = 'object')
        self.time_stamp_list[0] = self.time_stamp_now
        
        self.time_stamp_check = np.linspace(0, Generation-1, num = 11, dtype = 'int') # どのタイミングで時間を記録するかのリスト, 0を含めて11分割する
        
        # --- create directory name --- #

        head_chr = "PGG_Evo"
        GeneN = "GeneN" + f"{Generation:0=3d}"
        PopN = "PopN" + f"{N_pop:0=4d}"
        SubN = "subN" + f"{N_sub_pop}"
        cost = "C" + f"{Cost}"
        bene = "B" + f"{Benefit}"
        InitC = "InitC" + f"{Init_rate_C}"
        
        time_stamp_now_chr = f"{self.time_stamp_now:%Y%m%d%H%M%S}"
        
        dir_name_list = [head_chr, GeneN, PopN, SubN, cost, bene, InitC, time_stamp_now_chr]
        self.dir_name = self.dir_path + "_".join(dir_name_list)
        self.param_info_path = self.dir_name + "/_Parameters_info.txt"
        
        # 保存用のディレクトリを作成する
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
        """
        agentごとの情報を保存するcsv: PGG_agent.csv
        """
        self.file_agent_name = f"./{self.dir_name}/PGG_agent.csv"
        
        if os.path.exists(self.file_agent_name):
            print("the same name file exists! stop process.")
            sys.exit()
        else:
            print(f"make new file: {self.file_agent_name}")
            pd.DataFrame(columns = self.header_agent).to_csv(self.file_agent_name, index = False)
        
        
        """
        Generationごとの情報を保存するcsv: PGG_generation.csv
        """
        self.file_generation_name = f"./{self.dir_name}/PGG_generation.csv"
        
        if os.path.exists(self.file_generation_name):
            print("the same name file exists! stop process.")
            sys.exit()
        else:
            print(f"make new file: {self.file_generation_name}")
            pd.DataFrame(columns = self.header_generation).to_csv(self.file_generation_name, index = False)
        
        """
        シミュレーションのファイル（このファイル）のコピー
        """
        print(f"copy {__file__} ...")
        shutil.copyfile(__file__, f"./{self.dir_name}/{os.path.basename(__file__)}")
        
        
    def writeElapsedTime(self, generation_i):
        """
        全体（世代）の10%が終わるごとに、経過時間を記録する
        """
        
        for check_i in range(1, 11):
            
            if generation_i == self.time_stamp_check[check_i]: # generation_iが、self.time_stamp_checkにあれば、記録を開始する
                
                self.time_stamp_now = datetime.datetime.now()
                self.time_stamp_list[check_i] = self.time_stamp_now
                elapsed_time = self.time_stamp_list[check_i] - self.time_stamp_list[check_i-1]

                with open(self.param_info_path, mode='a') as f:
                    
                    print(f'generation_i: {generation_i}, end time: {self.time_stamp_now}, elapsed time: {elapsed_time}')
                    f.write(f'generation_i: {generation_i}, end time: {self.time_stamp_now}, elapsed time: {elapsed_time}\n')
        
            else:
                #print("No record.")
                pass
            
            
    def recordData_agent(self, agent, generation_i, new_agent):
        """
        self.output_agentにデータを一時的に保存する
        """
        
        new_agent_ID = [new_agent[pop_i].ID for pop_i in range(N_pop)]
        
        for pop_i in range(N_pop):
            
            offspring = sum(new_a_i == pop_i for new_a_i in new_agent_ID) # 子孫の数を数える 
            output = [generation_i, pop_i, agent[pop_i].group, agent[pop_i].gene_CD, agent[pop_i].payoff, offspring]
            self.output_agent[generation_i * N_pop + pop_i, :] = copy.deepcopy(output)
    
    
    def recordData_generation(self, agent, generation_i):
        """
        self.output_generationにデータを一時的に保存する
        """
        
        # CとDをカウント (合計がポピュレーションサイズになってるはず)
        gene_list = [agent[pop_i].gene_CD for pop_i in range(N_pop)]
        
        freq_C = gene_list.count('C')
        freq_D = gene_list.count('D')
        
        # outputとして保存する
        output = [generation_i, freq_C, freq_D]
        self.output_generation[generation_i, :] = copy.deepcopy(output)
    
            
    def writeCSV_agent(self):
        """
        PGG_agent.csvファイルにデータを出力する
        """
        
        f = open(self.file_agent_name, "a")
        target_csv = csv.writer(f, lineterminator="\n")
    
        # 事前に保存しているself.output_agentから一行ずつ書き出す
        for data_row_i in self.output_agent:
            
            target_csv.writerow(data_row_i)
            
        f.close()
        
        
    def writeCSV_generation(self):
        """
        PGG_generation.csvファイルにデータを出力する
        """
        
        f = open(self.file_generation_name, "a")
        target_csv = csv.writer(f, lineterminator="\n")
        
        # 事前に保存しているself.output_generationから一行ずつ書き出す
        for data_row_i in self.output_generation:
            
            target_csv.writerow(data_row_i)
            
        f.close()


#%%

class Agent:
    
    """
    エージェントのclass
    """
    def __init__(self, ID):
        
        """
        Attributes
        -----------
        ID : integer
            エージェントのID番号
        group : integer
            所属するグループ番号
        gene_CD : string 'C' or 'D'
            遺伝子（戦略）
        payoff : float
            獲得した利得
        fitness : float
            適応度
        """
        
        self.ID = ID
        self.group = None
        self.gene_CD = None
        self.payoff = None
        self.fitness = None
    
    def initialize(self, ID):
        """
        インスタンスを初期化するメソッド
        """
        
        self.ID = ID
        self.group = None
        self.payoff = None
        self.fitness = None
    
    def setGene(self, gene_CD):
        """
        遺伝子（戦略）を割り当てるメソッド
        """
        
        if gene_CD == 1:
            self.gene_CD = 'C' # Cooperator
        elif gene_CD == 0:
            self.gene_CD = 'D' # Defector
        else:
            print("Error. See setGene().")
            sys.exit()
    
    def setGroup(self, group_ID):
        """
        集団番号を割り当てるメソッド
        """
        
        self.group = group_ID
        
    

#%%
## 各種関数

def initializeAgent(agent):
    """
    全てのAgentのインスタンスを初期化する
    """
    for pop_i in range(N_pop):
        
        agent[pop_i].initialize(ID = pop_i)
        

def assignGene(agent):
    """
    全てのエージェントに初期遺伝子を割り当てる
    """
    init_C = np.random.binomial(n = 1, p = Init_rate_C, size = N_pop)
    for pop_i in range(N_pop):
    
        agent[pop_i].setGene(init_C[pop_i])

    
def assignGroup(agent):
    """
    全てのエージェントにグループを割り当てる
    """
    group_name = sum([[i]*N_sub_pop for i in range(0, N_group)], []) # sum(list, [])でlistを平坦化する: https://note.nkmk.me/python-list-flatten/
    #random.shuffle(group_name)
    for pop_i in range(N_pop):
    
        agent[pop_i].setGroup(group_name[pop_i])
   

def publicGoodsGame(agent):
    """
    公共財ゲームを1回行い、payoffを計算する
    """
    
    #agent.sort(key=lambda x:x.group) # group番号順で並び替え
    """
    for pop_i in range(N_pop):
        
        print(f"group: {agent[pop_i].group}, ID: {agent[pop_i].ID}, gene: {agent[pop_i].gene_CD}")
    """
    
    for pop_i in range(0, N_pop, N_sub_pop):
        
        strategy_group = [agent[pop_i + pop_sub_i].gene_CD for pop_sub_i in range(N_sub_pop)] # グループの戦略リスト
        #print(strategy_group)
        n_C_group = strategy_group.count('C') # グループ内の、Cの人数を数える
        #print(n_C_group)
        
        # 各エージェントの利得を計算する
        group_return = Benefit * n_C_group / N_sub_pop # 集団への貢献を人数で割ったもの
        for pop_i_sub in range(N_sub_pop):
            
            if agent[pop_i + pop_i_sub].gene_CD == 'C':
                
                agent[pop_i + pop_i_sub].payoff = group_return - Cost
            
            elif agent[pop_i + pop_i_sub].gene_CD == 'D':
                
                agent[pop_i + pop_i_sub].payoff = group_return
            
            else:
                
                print("Error. See publicGoodsGame().")
                sys.exit()


def naturalSelection(agent):
    """
    適応度に比例して、自然淘汰が起きる
    """
    
    # 適応度を正の値にするため、全エージェントの中での最小利得分、下駄をはかせる
    payoff_list = [agent[pop_i].payoff for pop_i in range(N_pop)]
    min_payoff = min(payoff_list)
    
    if min_payoff <= 0: # 0以下があるなら
        base_fit = abs(min_payoff) + 0.1
    else:
        base_fit = 0
        
    for pop_i in range(N_pop):
        agent[pop_i].fitness = agent[pop_i].payoff + base_fit
    
    # 淘汰
    fitness_list = [agent[pop_i].fitness for pop_i in range(N_pop)] 
    new_population = random.choices(list(range(0, N_pop)), k = N_pop, weights = fitness_list) # fitnessの重みに応じて、IDが選ばれる
    
    new_agent = [None] * N_pop
    for i, agent_i in enumerate(new_population):
        
        #print(f"i: {i}, agent_i: {agent_i}")
        new_agent[i] = copy.deepcopy(agent[agent_i])

    return new_agent


def mutation(agent):
    """
    突然変異が起きる
    """
    
    mutation_list = np.random.binomial(n=1, p = Mutation_rate, size = N_pop) 
        
    for pop_i in range(N_pop):
        
        if mutation_list[pop_i] == 1: # 1なら突然変異が起こる
            #print(f"-- pop {pop_i}: ID {agent[pop_i].ID}, {agent[pop_i].gene_CD}, Mutation happend! --")
            if agent[pop_i].gene_CD == 'C':
                
                agent[pop_i].gene_CD = 'D'
                
            elif agent[pop_i].gene_CD == 'D':
                
                agent[pop_i].gene_CD = 'C'
                
            else:
                print("Error. See mutation().")
                sys.exit()
            
        else:
            #print(f"pop {pop_i}: ID {agent[pop_i].ID}, {agent[pop_i].gene_CD}, Mutation not happened.")
            pass
        
    
    
#%%

"""
Run PGG Simulation
"""

# 保存先のパスを指定
save_data_path = "../Data/PGG_Evo/" # Simulation_Codeディレクトリから見たパス

# SaveDataのインスタンスを作成
save_data = SaveData(save_data_path) 
save_data.writeParametersInfo(p_dict) # シミュレーションのパラメータの情報を.txtで書き出す
save_data.createFile() # 保存用のcsvファイルを作成

# Agentのインスタンス配列の作成
agent = [Agent(ID = pop_i) for pop_i in range(N_pop)]

assignGene(agent) # 初期遺伝子の割り当て

for generation_i in range(Generation):
    
    initializeAgent(agent) # Agentの初期化
    assignGroup(agent) # Groupを割り当てる　
    
    publicGoodsGame(agent) # PGG
    
    new_agent = naturalSelection(agent) # 自然淘汰
    
    # --- ここで記録する--- # 
    save_data.recordData_generation(agent, generation_i)
    save_data.recordData_agent(agent, generation_i, new_agent)
    # --- ---- --- --- --- --- --- # 
    
    mutation(new_agent) # 突然変異
    
    agent = copy.deepcopy(new_agent) # 次世代のポピュレーション
    random.shuffle(agent) # agentをシャッフルする
    
    save_data.writeElapsedTime(generation_i) # 終了時間と経過時間を書き出す
    
# csvに書き出す
save_data.writeCSV_generation()
save_data.writeCSV_agent()
    
        
