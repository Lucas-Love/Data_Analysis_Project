import os
import pandas as pd
import numpy as np
from sqlalchemy import create_engine


'''
定义一个变量dir，赋值为一个字符串，表示一个文件夹的路径
定义一个空列表data_list，用于存储数据
使用os.listdir(dir)方法遍历文件夹中的所有文件名，赋值给path变量
使用os.path.join(dir, path)方法拼接文件夹路径和文件名，得到完整的文件路径，赋值给path变量
使用pd.read_csv(path)方法读取文件中的数据，返回一个DataFrame对象，赋值给data变量
使用data[[‘user_id’, ‘register_time’, ‘pvp_battle_count’, ‘pvp_lanch_count’, ‘pvp_win_count’, ‘pve_battle_count’, ‘pve_lanch_count’, ‘pve_win_count’, ‘avg_online_minutes’, ‘pay_price’, ‘pay_count’]]方法选择DataFrame中的指定列，返回一个新的DataFrame对象，赋值给data变量
使用data_list.append(data)方法将data变量添加到data_list列表中
使用pd.concat(data_list)方法将data_list列表中的所有DataFrame对象合并为一个大的DataFrame对象，赋值给data变量
'''
#合并处理#--------------------------------------------------------------------------------------
#合并数据文件，并筛选出有用字段可以极大的节省内存和提高效率
dir=r'D:\Data Analysis Project\野蛮玩家数据分析\原始数据\data'
data_list=[]
for path in os.listdir(dir):
    path=os.path.join(dir,path)
    data=pd.read_csv(path)#是dataframe类型
    data=data[['user_id','register_time','pvp_battle_count',
               'pvp_lanch_count','pvp_win_count','pve_battle_count',
               'pve_lanch_count','pve_win_count','avg_online_minutes',
               'pay_price','pay_count']]#强制进行series类型变成dataframe类型，提取有用字段列
    data_list.append(data)#将dataframe，放入列表当中
data=pd.concat(data_list)#详细见data_analysis中list_dataframe
#输出处理：--------------------------------------------------------------------------------------

#重复值处理：
#print(data[data.duplicated()])#此处标记重复行，重复的为true，返回行，drop_duplicates()

#缺失值处理：
#print(data[data.isnull().any()])针对列

#数据保存----------------------------------------------------------------------------------------
engine = create_engine('mysql://root:123456@localhost:3306/test?charset=utf8')#pip install mysqlclient
#'数据库类型://用户名称：用户密码@主机地址：端口号/数据库名字？编码'
data.to_sql('merge_data',con=engine,index=False,if_exists='replace')