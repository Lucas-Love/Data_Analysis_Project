-- 合并后数据表
SELECT * FROM `merge_data`

-- 修改字段类型
alter table merge_data modify register_time timestamp(0);
alter table merge_data modify avg_online_minutes float(10,2);
alter table merge_data modify pay_price float(10,2);

-- 用户总量
select count(1) as all_record,count(distinct user_id) as user_id
from merge_data

-- 付费用户总量和非付费用户总量
select sum(case when pay_price>0 then 1 else 0 end) as '付费用户',
	   sum(case when pay_price>0 then 0 else 1 end) as '非付费用户'
from merge_data

-- 每日新用户数
select cast(register_time as date) as day,
	   count(1) as DNU
from merge_data
group by day
order by day;

-- 每小时登陆新用户数
select hour(cast(register_time as datetime)) as hour,
	   count(1) as '每小时登录的新用户数'
from merge_data
group by hour
order by hour;

-- 不同用户的在线时长
select sum(avg_online_minutes)/count(user_id) as '所有用户的平均在线时长',
			 sum(case when pay_count>0 then avg_online_minutes else 0 end)/sum(if(pay_count>0,1,0)) as '付费用户平均在线时长',
			 sum(case when pay_count>0 then 0 else avg_online_minutes end)/sum(if(pay_count=0,1,0))as '非付费用户平均在线时长'
from merge_data;

-- 活跃付费用户数
select count(1) as 'APA'
from merge_data
where pay_count>0 and avg_online_minutes>0;

-- 平均每个用户收入（只包含活跃用户）
select sum(pay_price)/sum(case when avg_online_minutes>0 then 1 else 0 end) as 'ARPU'
from merge_data;

-- 平均付费用户收入
select sum(pay_price)/sum(case when pay_price>0 then 1 else 0 end) as 'ARPPU'
from merge_data;

-- 付费比率（活跃付费用户数/活跃用户数）
select sum(case when avg_online_minutes>0 and pay_count>0 then 1 else 0 end)/sum(if(avg_online_minutes>0,1,0)) as '付费比率'
from merge_data;

-- 付费用户消费数据分析
select  count(1) as 付费用户数, 
        sum(pay_price) as 付费总额, 
        avg(pay_price) as 平均每人付费,  
        sum(pay_count) as 付费总次数,  
        avg(pay_count) as 平均每人付费次数,  
        sum(pay_price) / sum(pay_count) as 平均每次付费
from merge_data
where pay_price > 0;

-- 不同用户pvp和pve胜率
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

-- 不同用户游戏场次
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


