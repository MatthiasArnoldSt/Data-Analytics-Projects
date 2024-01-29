
--/*Viewing the data*/

Select *
From ProjectGE15..aggData
order by 2 

--/*Swapping the percentage value of Bumiputera Sabah, Bumiputera Sarawak and Orang Asli to correct the database mistake for Sabah Parliamentary Constituency*/

Update aggData
Set BUMIPUTERA_SABAH_p = ORANG_ASLI_p,
	ORANG_ASLI_p = BUMIPUTERA_SARAWAK_p,
	BUMIPUTERA_SARAWAK_p = BUMIPUTERA_SABAH_p
where 
	state = 'Sabah';

Select *
From ProjectGE15..aggData
order by 2 


--/*Swapping the percentage value of Bumiputera Sabah, Bumiputera Sarawak and Orang Asli to correct the database mistake for Sarawak Parliamentary Constituency*/

Update aggData
Set BUMIPUTERA_SARAWAK_p = BUMIPUTERA_SABAH_p,
	BUMIPUTERA_SABAH_p = ORANG_ASLI_p,
	ORANG_ASLI_p = BUMIPUTERA_SARAWAK_p
where 
	state = 'Sarawak';

Select *
From ProjectGE15..aggData
order by 2 

/*Viewing Sarawak Constituencies only*/
Select *
From ProjectGE15..aggData
where state = 'Sarawak'
order by 2;

/*(1)Summary Statistics*/
--a)Calculating the total votes received, average winning majority, highest vote received from a constituency, and 
--the average percentage of youth voters 18-29 y/o from their winning constituencies for a particular party 

Select 
	SUM(CONVERT(INT,GPS_VOTE)) as Total_Vote, 
	AVG(CONVERT(INT,WINNING_MAJORITY)) as Majority_Average, 
	MAX(CONVERT(INT,GPS_VOTE)) as Highest_Vote, 
	AVG(([18-20_p])+([21-29_p])) as Average_YoungVoters_Percentage
From 
	ProjectGE15..aggData
where 
	WINNING_COALITION = 'GPS';

--b)Calculating income median average, expenditure average and poverty incidence average
--of voters from constituencies won by each specific party

Select
	WINNING_COALITION,
	COUNT(PARLIAMENTARY_NAME) as Constituency_won,
	AVG(CONVERT(INT,income_median)) as Average_IncomeMedian,
	AVG(CONVERT(INT,expenditure_avg)) as Average_MeanExpenditure,
	AVG(CONVERT(INT,poverty_incidence)) as Average_PovertyIncidence
From 
	ProjectGE15..aggData
where 
	state = 'Sarawak'
group by 
	WINNING_COALITION;


/*(2)Data Distribution*/
--a)Determining the distribution of labour unemployment rate for constituencies won by each parties

select
	WINNING_COALITION,
	Unemployment_Rate_Group,
	Count(*) as Count,
	100.0 * Count(*)/Sum(Count(*)) over (partition by WINNING_COALITION) as Percentage
from (
	select WINNING_COALITION,
		case 
			when labour_unemployment_rate >= 0 and labour_unemployment_rate < 1 then '0-0.99%'
			when labour_unemployment_rate >= 1 and labour_unemployment_rate < 2 then '1-1.99%'
			when labour_unemployment_rate >= 2 and labour_unemployment_rate < 3 then '2-2.99%'
			when labour_unemployment_rate >= 3 and labour_unemployment_rate < 4 then '3-3.99%'
			when labour_unemployment_rate >= 4 and labour_unemployment_rate < 5 then '4-4.99%'
			when labour_unemployment_rate >= 5 and labour_unemployment_rate < 6 then '5-5.99%'
		end as Unemployment_Rate_Group
	from aggData
	where state = 'Sarawak'
	) as Subquery
	group by WINNING_COALITION, Unemployment_Rate_Group;


/*(3) Data Quality Checking*/
--a) Checking for missing values in PN_VOTE column

select count(*) as Missing_Values_Count
from ProjectGE15..aggData
where PN_VOTE is null and state = 'Sarawak';

--b) Calculating the average and standard deviation to identify outliers in income_avg column
select 
	avg(income_avg) as Average_Income,
		stdev(income_avg) as Income_Standard_Deviation
from
	ProjectGE15..aggData 
where 
	state = 'Sarawak';

--c) Calculating the percentage of missing values in each column
select	
	sme_small,
	count(*) as Total_Count,
	sum(case when sme_small is null then 1 else 0 end) as Missing_Values_Count,
	100.0 * sum(case when sme_small is null then 1 else 0 end) / count(*) as Missing_Values_Percentage
From 
	ProjectGE15..aggData
group 
	by sme_small;
	
/*(4)Segmentation Analysis*/
--a) Calculating the average income, average incidence poverty rate, average gini and total population
--for each state

select
	state,
	AVG(income_avg) as Average_Income,
	AVG(poverty_incidence) as Average_PovertyRate,
	AVG(gini) as Gini_Coefficient,
	SUM(population_total) as state_population
from 
	ProjectGE15..aggData
group by 
	state  
order by 
	Average_Income desc;

--b) Calculating the number of Malay-majority, Chinese-majority and Bumiputera-Majority constituency in Sarawak

select	
	PARLIAMENTARY_NAME,
		case when MALAY_p >= 50 then 'Malay-Majority'
			 when CHINESE_p >= 50 then 'Chinese-Majority'
			 when BUMIPUTERA_SARAWAK_p >=50 then 'Bumiputera Sarawak-Majority' 
			 else 'Highly Diverse' end as Majority_Type,
		MALAY_p,
		CHINESE_p,
		BUMIPUTERA_SARAWAK_p
from
	ProjectGE15..aggData
where
	state = 'Sarawak';


select
	PARLIAMENTARY_NAME,
	MALAY_p,
	CHINESE_p,
	BUMIPUTERA_SARAWAK_p,
	count(case when MALAY_p >= 50 then 1 end) as 'Malay-Majority Constituency',
	count(case when CHINESE_p >= 50 then 1 end) as 'Chinese-Majority Constituency',
	count(case when BUMIPUTERA_SARAWAK_p >= 50 then 1 end) as 'Bumiputera Sarawak-Majority Constituency'
from 
	ProjectGE15..aggData
where 
	state ='Sarawak'
group by
	PARLIAMENTARY_NAME,
	MALAY_p,
	CHINESE_p,
	BUMIPUTERA_SARAWAK_p;

--c) Calculating the total number of voters by race in Sarawak

select
	sum(TOTAL_ELECTORS * MALAY_p / 100) as Total_Malay_Voters,
	sum(TOTAL_ELECTORS * CHINESE_p / 100) as Total_Chinese_Voters,
	sum(TOTAL_ELECTORS * BUMIPUTERA_SARAWAK_p / 100) as Total_Bumiputera_Sarawak_Voters
from
	ProjectGE15..aggData
where
	state = 'Sarawak';

