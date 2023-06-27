# 1.数据集说明：
---
这是一份手游《野蛮时代》的用户数据，其中有两个数据文件`tap_fun_test.csv`和`tap_fun_train.csv`两份数据文件，两个文件数据无交集，总记录数为3116941条，共包含字段109个，包含`user_id,register_id,avg_online_minutes`等一些重要的后期统计字段和一些游戏中的材料数据字段,在原始数据文件中还有对于数据字段的解释。

# 2.数据选取：
---
通过观察初步对于助于用户分析的字段进行选取，通过excel中的`vlookup`函数，进行数据字段的查取：
![vlookup查取字段](https://img-blog.csdnimg.cn/a2d9f438ec8046f9b9ea2663bca32272.png#pic_center)

# 3.数据处理：
---
  ###### 1、在本阶段利用python进行两份数据文件的合并，并且根据数据选取阶段的数据字段进行整体数据的筛选和清洗工作
     `数据合并：合并数据文件，并筛选出有用字段可以极大的节省内存和提高效率`
```
dir=r'D:\Data Analysis Project\野蛮玩家数据分析\原始数据\data'
data_list=[]
for path in os.listdir(dir):
    path=os.path.join(dir,path)
    data=pd.read_csv(path)
    data=data[['user_id','register_time','pvp_battle_count',
            'pvp_lanch_count','pvp_win_count','pve_battle_count',
            'pve_lanch_count','pve_win_count','avg_online_minutes',
            'pay_price','pay_count']]
    data_list.append(data)
data=pd.concat(data_list)
```
`数据清洗:对于数据进行去重、去除缺失值、处理异常值等操作`

本数据没有重复值和缺失值，常见的去重操作和过滤缺失值操作如下：
```
print(data[data.duplicated()])
data[drop_duplicates()] #去重
print(data[data.isnull().any()]) #过滤缺失值
```
###### 2、将合并后，清洗过的数据写入mysql数据库：
```
engine = create_engine('mysql://root:123456@localhost:3306/test?charset=utf8')
data.to_sql('merge_data',con=engine,index=False,if_exists='replace')
```
###### 3、对数据库中的字段格式进行调整：

原始字段类型如下：

![原始字段类型](https://img-blog.csdnimg.cn/368338c7dbce44b19dcf3985ac567068.png#pic_center)

通过观察可知：register_time改为时间格式更好，avg_online_minutes和pay_price的精度太高，不利于分析和可视化
利用语句进行值字段类型的修改：

![字段类型的修改](https://img-blog.csdnimg.cn/245f78471aa147479c48a4ac104756ad.png#pic_center)
修改后数据展示如下图：

![修改后数据](https://img-blog.csdnimg.cn/17bbf7968920401fafabb0c4562d0310.png#pic_center)
# 4、数据分析查询以及可视化操作：
---
###### 用户总量：
`用户的user_id的个数与总数据行数一致说明user_id无重复，后续操作可以不用在user_id前加distinct`
```
select count(1) as all_record,count(distinct user_id) as user_id
from merge_data
```
###### 付费用户和非付费用户数量：
`PU(Paying Users):付费用户总量`
```
select sum(case when pay_price>0 then 1 else 0 end) as '付费用户',
	   sum(case when pay_price>0 then 0 else 1 end) as '非付费用户'
from merge_data
```
![不同用户数量](https://img-blog.csdnimg.cn/529a8733a9f04cf5bb8b474a93ef1717.png#pic_center)
付费用户共60988人，占比2%
![可视化](https://img-blog.csdnimg.cn/d65d304c080b4b5096a2b05a59b9bf91.png#pic_center)

###### 每日新用户数量：
`DNU(Daily New Users):每日游戏中新登入用户量，即每日新用户数`
```
select cast(register_time as date) as day,
	   count(1) as DNU
from merge_data
group by day
order by day;
```
![每日新用户数sql](https://img-blog.csdnimg.cn/9423f8509abf4e97bdd995358df0b363.png#pic_center)

下图反映DNU概况，可清楚的看到新用户的两个注册登入高峰期，应该是游戏做了一些引流活动，吸引了大量新用户，可见则两次活动影响效果很好，可为后续活动借鉴，但是游戏的整体新用户登入数量随时间呈下降趋势，虽然是游戏发展的必然规律，但是也应做好防范，及时做好游戏引流活动
![可视化](https://img-blog.csdnimg.cn/3ec0c765570c45bebd239740277127f5.png#pic_center)
###### 每小时登录新用户数：
```
select hour(cast(register_time as datetime)) as hour,
	   count(1) as '每小时登录的新用户数'
from merge_data
group by hour
order by hour;
```

![sql](https://img-blog.csdnimg.cn/7c67c5db6ff34d008c4bb9507fe941f2.png#pic_center)
每小时新用户的注册情况如下图，可以看到21时是用户注册的高峰期，除此之外0时新用户注册的数量也很多，着重在这两个小时进行活动引流可以获得更好的效果
![可视化](https://img-blog.csdnimg.cn/24a249abf630446797a51acd4f6f5b53.png#pic_center)

###### 付费用户和非付费用户的在线时长：
```
select sum(avg_online_minutes)/count(user_id) as '所有用户的平均在线时长',
			 sum(case when pay_count>0 then avg_online_minutes else 0 end)/sum(if(pay_count>0,1,0)) as '付费用户平均在线时长',
			 sum(case when pay_count>0 then 0 else avg_online_minutes end)/sum(if(pay_count=0,1,0))as '非付费用户平均在线时长'
from merge_data;
```
![sql](https://img-blog.csdnimg.cn/c4392abc62c54158a45c4920b29814fd.png#pic_center)
从平均在线时间来看，付费用户的平均在线时间高达2.3个小时，远高于整体玩家的平均在线时间
![可视化](https://img-blog.csdnimg.cn/8bf0611de57047fca73aaf1b792eb9a1.png#pic_center)
###### 活跃付费用户数：
`APA(Active Payment Account):活跃付费用户数`
```
select count(1) as 'APA'
from merge_data
where pay_count>0 and avg_online_minutes>0;
```
![sql](https://img-blog.csdnimg.cn/b179a76ea7d843f4be334c5e4a4e3681.png#pic_center)


###### 平均每个用户收入（只包含活跃用户）：
`ARPU(Average Revenue Per User):平均每用户收入`
```
select sum(pay_price)/sum(case when avg_online_minutes>0 then 1 else 0 end) as 'ARPU'
from merge_data;
```
![sql](https://img-blog.csdnimg.cn/46225c17ddef48d5a875f9bbc3309660.png#pic_center)

###### 平均付费用户收入：
`ARPPU(Average Revenue Per Paying User):平均每付费用户收入`
```
select sum(pay_price)/sum(case when pay_price>0 then 1 else 0 end) as 'ARPPU'
from merge_data;
```
![sql](https://img-blog.csdnimg.cn/b728b5974e12499db4aa9fc57108b6ce.png#pic_center)

###### 付费比率（活跃付费用户数/活跃用户数）：
`AU(Active Users):活跃用户数`
`PUR(Pay User Rate):付费比率，通过APA/AU计算`
```
select sum(case when avg_online_minutes>0 and pay_count>0 then 1 else 0 end)/sum(if(avg_online_minutes>0,1,0)) as '付费比率'
from merge_data;
```
![sql](https://img-blog.csdnimg.cn/78e609e437c94aa7a66a179fe6864ddf.png#pic_center)

###### 付费用户消费数据分析：
```
select  count(1) as 付费用户数, 
        sum(pay_price) as 付费总额, 
        avg(pay_price) as 平均每人付费,  
        sum(pay_count) as 付费总次数,  
        avg(pay_count) as 平均每人付费次数,  
        sum(pay_price) / sum(pay_count) as 平均每次付费
from merge_data
where pay_price > 0;
```
![sql](https://img-blog.csdnimg.cn/f03ca7d57c2247aa8def068318fb9202.png#pic_center)
从上方统计结果可以知道，这6万多的付费用户一共消费了178万元，平均每人消费29元，平均每用户收入0.58元，平均每付费用户收入29.19元，付费比率为2%，这个付费比率较低,可以通过一些首充活动提高新用户的付费意愿，通过充值优惠等活动提高老用户的付费意愿

###### 不同用户pvp和pve胜率：
```
select  'PVP' as '游戏类型',
        sum(pvp_win_count)/sum(pvp_battle_count) as '平均用户胜率',
	sum(case when pay_count>0 then pvp_win_count else 0 end)/sum(case when pay_count>0 then pvp_battle_count else 0 end) as '付费用户平均胜率',
	sum(case when pay_count=0 then pvp_win_count else 0 end)/sum(case when pay_count=0 then pvp_battle_count else 0 end) as '非付费用户平均胜率'
from merge_data
union all
select  'PVE' as '游戏类型',
	sum(pve_win_count)/sum(pve_battle_count) as 平均用户胜率,
	sum(case when pay_count>0 then pve_win_count else 0 end)/sum(case when pay_count>0 then pve_battle_count else 0 end) as 付费用户平均胜率,
	sum(case when pay_count=0 then pve_win_count else 0 end)/sum(case when pay_count=0 then pve_battle_count else 0 end) as 非付费用户平均胜率
from merge_data;
```
![sql](https://img-blog.csdnimg.cn/552ca1aec86e418da0fde7a76e8bff9f.png#pic_center)
![可视化](https://img-blog.csdnimg.cn/79443d47ec31463caa318d78e2cc103a.png#pic_center)


###### 不同用户pvp和pve胜率：
```
select 'PVP' as `游戏类型`,
       avg(pvp_battle_count) as `平均场次`,
       sum(case when pay_price > 0 then pvp_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费用户平均场次`,
       sum(case when pay_price = 0 then pvp_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) as `非付费用户平均场次`
from merge_data
union all
select 'PVE' as `游戏类型`,
       avg(pve_battle_count) as `平均场次`,
       sum(case when pay_price > 0 then pve_battle_count else 0 end) / sum(case when pay_price > 0 then 1 else 0 end) as `付费用户平均场次`,
       sum(case when pay_price = 0 then pve_battle_count else 0 end) / sum(case when pay_price = 0 then 1 else 0 end) as `非付费用户平均场次`
from merge_data
```
![sql](https://img-blog.csdnimg.cn/dc4f2c239de845329b862afb7b61eb11.png#pic_center)
![堆积柱形图](https://img-blog.csdnimg.cn/d6a29e52c11242268669b4b9ca2cd39a.png#pic_center)
![簇状柱形图](https://img-blog.csdnimg.cn/918e81aa12af4040a7d085fe775cc73b.png#pic_center)

从游戏的胜率和场次来看，氪金确实可以变得更强，付费用户的平均胜率为71.13%，远高于非付费用户的平均游戏胜率38.03%，当然也是因为付费用户的平均游戏场次远多于非付费用户，毕竟更多的游戏场次也可以获得更多的游戏资源，从游戏模式来看，PVE的平均胜率高达90.1%，说明难度还是比较低的，用户的游戏体验也是比较好的，也适合新用户快速适应游戏。

   

