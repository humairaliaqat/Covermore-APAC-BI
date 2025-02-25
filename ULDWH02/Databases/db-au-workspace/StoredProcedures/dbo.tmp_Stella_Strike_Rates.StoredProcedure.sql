USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_Stella_Strike_Rates]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_Stella_Strike_Rates] @StartDate varchar(10), @EndDate varchar(10)
as

SET NOCOUNT ON
--this is a temporary stored procedure for a one-off report for CM and Stella to determine strike rate trends between 30/06/2008 and 26/12/2010

declare @rptStartDate datetime
declare @rptEnddate datetime
select @rptStartDate = convert(datetime,@StartDate), @rptEndDate = convert(datetime,@EndDate)


--create temp table and insert Stella BSP data (supplied by Stella)
if object_id('tempdb..#tmp_stella_bsp') is not null drop table #tmp_stella_bsp
create table #tmp_stella_bsp
(
	[Week] int null,
	ATAC int null,
	BestFlights int null,
	CAN int null,
	HWT int null,
	TSAXFull int null,
	TSAXAssociate int null,
	TSAXCorporate int null,
	GrandTotal int null
)

insert into #tmp_stella_bsp values(827,452,1797,3676,3776,4960,542,3187,18390)
insert into #tmp_stella_bsp values(828,469,1640,3204,3165,4555,467,2956,16456)
insert into #tmp_stella_bsp values(829,509,1657,3041,3105,4453,330,2643,15738)
insert into #tmp_stella_bsp values(830,400,1591,2883,3089,4295,432,2607,15297)
insert into #tmp_stella_bsp values(831,579,1683,3809,3863,4986,474,3063,18457)
insert into #tmp_stella_bsp values(832,605,1565,3018,3170,4485,526,3271,16640)
insert into #tmp_stella_bsp values(833,513,1555,3502,3025,4302,405,3209,16511)
insert into #tmp_stella_bsp values(834,593,1521,4103,3334,4895,483,3282,18211)
insert into #tmp_stella_bsp values(835,534,1680,4119,3487,4535,441,3285,18081)
insert into #tmp_stella_bsp values(836,518,1629,3312,2822,4169,496,3416,16362)
insert into #tmp_stella_bsp values(837,520,1683,3280,3101,4174,454,3101,16313)
insert into #tmp_stella_bsp values(838,590,1274,3154,2874,4267,452,3227,15838)
insert into #tmp_stella_bsp values(839,611,1373,2840,2929,3778,460,3017,15008)
insert into #tmp_stella_bsp values(840,635,1458,3831,3159,4075,450,2992,16600)
insert into #tmp_stella_bsp values(841,491,1424,3159,2698,3586,360,2561,14279)
insert into #tmp_stella_bsp values(842,541,1423,3361,3002,4128,440,3146,16041)
insert into #tmp_stella_bsp values(843,509,1267,2851,2677,3914,383,2638,14239)
insert into #tmp_stella_bsp values(844,562,1200,2918,2762,3864,423,2875,14604)
insert into #tmp_stella_bsp values(845,426,920,2426,2580,3321,381,2433,12487)
insert into #tmp_stella_bsp values(846,474,1239,2748,2723,3721,265,2657,13827)
insert into #tmp_stella_bsp values(847,597,1913,3057,3808,4994,470,3071,17910)
insert into #tmp_stella_bsp values(848,439,995,3008,2699,3353,298,2368,13160)
insert into #tmp_stella_bsp values(849,346,717,2608,2447,3138,303,1992,11551)
insert into #tmp_stella_bsp values(850,534,821,2892,3028,3400,223,2092,12990)
insert into #tmp_stella_bsp values(851,490,840,2617,3326,3722,337,2321,13653)
insert into #tmp_stella_bsp values(852,276,758,1721,1556,2311,168,1169,7959)
insert into #tmp_stella_bsp values(901,211,855,1463,1471,1817,127,749,6693)
insert into #tmp_stella_bsp values(902,382,1037,2088,2671,3099,249,1717,11243)
insert into #tmp_stella_bsp values(903,464,1209,2930,3199,3980,338,2170,14290)
insert into #tmp_stella_bsp values(904,575,1109,3183,3195,4502,307,2431,15302)
insert into #tmp_stella_bsp values(905,425,933,2924,3380,3906,334,2227,14129)
insert into #tmp_stella_bsp values(906,465,1023,2925,3299,4434,366,2615,15127)
insert into #tmp_stella_bsp values(907,539,1377,3087,3699,5016,388,2714,16820)
insert into #tmp_stella_bsp values(908,638,1417,4637,4526,5987,548,3692,21445)
insert into #tmp_stella_bsp values(909,760,1371,5313,5920,6132,611,3109,23216)
insert into #tmp_stella_bsp values(910,612,1024,4451,3593,2565,55,2298,14598)
insert into #tmp_stella_bsp values(911,543,1178,3804,3275,4657,355,2863,16675)
insert into #tmp_stella_bsp values(912,682,1509,4744,4051,5359,404,3009,19758)
insert into #tmp_stella_bsp values(913,522,1327,4908,4194,5207,399,2955,19512)
insert into #tmp_stella_bsp values(914,738,2331,5913,4676,6318,474,3305,23755)
insert into #tmp_stella_bsp values(915,993,2557,7200,6556,9221,791,4069,31387)
insert into #tmp_stella_bsp values(916,834,1796,6639,5525,7008,538,3252,25592)
insert into #tmp_stella_bsp values(917,676,1110,5446,3909,5142,409,2866,19558)
insert into #tmp_stella_bsp values(918,521,1077,4354,3427,4420,352,2914,17065)
insert into #tmp_stella_bsp values(919,492,1005,3831,2964,4584,428,2619,15923)
insert into #tmp_stella_bsp values(920,663,1148,4764,3686,5391,474,3372,19498)
insert into #tmp_stella_bsp values(921,628,1165,4539,3651,4800,468,2936,18187)
insert into #tmp_stella_bsp values(922,614,1038,6070,4413,5750,520,3297,21702)
insert into #tmp_stella_bsp values(923,524,912,4310,3316,4761,457,2906,17186)
insert into #tmp_stella_bsp values(924,421,1459,3625,3245,4492,580,2744,16566)
insert into #tmp_stella_bsp values(925,623,1602,4720,4266,5881,371,3101,20564)
insert into #tmp_stella_bsp values(926,668,1617,5701,4526,6461,446,3425,22844)
insert into #tmp_stella_bsp values(927,478,1246,4260,3493,5006,358,2645,17486)
insert into #tmp_stella_bsp values(928,493,956,4126,3160,4504,345,2567,16151)
insert into #tmp_stella_bsp values(929,507,881,4540,3317,4273,345,2432,16295)
insert into #tmp_stella_bsp values(930,431,951,4819,3201,4206,373,2503,16484)
insert into #tmp_stella_bsp values(931,609,979,4668,3496,4549,424,2850,17575)
insert into #tmp_stella_bsp values(932,510,1003,3999,3245,4353,384,2696,16190)
insert into #tmp_stella_bsp values(933,595,1218,5023,3589,4926,460,3058,18869)
insert into #tmp_stella_bsp values(934,480,874,3961,3309,4497,264,2864,16249)
insert into #tmp_stella_bsp values(935,633,818,5136,3612,5277,379,3586,19441)
insert into #tmp_stella_bsp values(936,510,908,4364,3159,4132,361,3126,16560)
insert into #tmp_stella_bsp values(937,488,740,3866,2875,3848,361,3107,15285)
insert into #tmp_stella_bsp values(938,505,907,4030,3174,4177,405,2797,15995)
insert into #tmp_stella_bsp values(939,517,820,3854,2974,4065,384,2837,15451)
insert into #tmp_stella_bsp values(940,520,998,4499,3401,4756,371,3018,17563)
insert into #tmp_stella_bsp values(941,488,682,3388,2375,3828,327,2631,13719)
insert into #tmp_stella_bsp values(942,485,974,4078,2949,4395,351,2954,16186)
insert into #tmp_stella_bsp values(943,438,976,3523,2996,4386,416,2902,15637)
insert into #tmp_stella_bsp values(944,686,1192,4965,4103,5325,389,3664,20324)
insert into #tmp_stella_bsp values(945,446,888,3690,3184,4466,347,2828,15849)
insert into #tmp_stella_bsp values(946,515,984,4347,4132,5222,415,3223,18838)
insert into #tmp_stella_bsp values(947,626,1084,4146,3792,5039,374,2832,17893)
insert into #tmp_stella_bsp values(948,706,1084,4241,4748,5540,497,3090,19906)
insert into #tmp_stella_bsp values(949,840,982,4087,4343,5272,407,3015,18946)
insert into #tmp_stella_bsp values(950,535,791,3445,3458,4384,331,2445,15389)
insert into #tmp_stella_bsp values(951,600,962,3739,3797,4780,362,2839,17079)
insert into #tmp_stella_bsp values(952,493,729,3539,3032,3826,295,2196,14110)
insert into #tmp_stella_bsp values(1001,244,807,1826,1899,2286,129,872,8063)
insert into #tmp_stella_bsp values(1002,618,1213,3553,3764,4233,338,2294,16013)
insert into #tmp_stella_bsp values(1003,672,1229,3825,3886,4596,366,2725,17299)
insert into #tmp_stella_bsp values(1004,654,1363,4522,4234,5131,470,3199,19573)
insert into #tmp_stella_bsp values(1005,677,1465,4270,4442,5131,498,2957,19440)
insert into #tmp_stella_bsp values(1006,600,1282,3991,4641,5141,543,3143,19341)
insert into #tmp_stella_bsp values(1007,764,1430,4639,5027,5827,548,3534,21769)
insert into #tmp_stella_bsp values(1008,895,1331,4863,4954,6479,650,3841,23013)
insert into #tmp_stella_bsp values(1009,855,1648,6013,5971,7136,663,4341,26627)
insert into #tmp_stella_bsp values(1010,840,1532,5982,5194,6238,513,3879,24178)
insert into #tmp_stella_bsp values(1011,722,1523,5293,4699,5783,527,3771,22318)
insert into #tmp_stella_bsp values(1012,796,1413,5119,4722,5806,574,4033,22463)
insert into #tmp_stella_bsp values(1013,763,1303,5341,4579,5937,634,3668,22225)
insert into #tmp_stella_bsp values(1014,916,1566,5994,5460,6609,772,4328,25645)
insert into #tmp_stella_bsp values(1015,666,1218,3933,3064,4296,395,2994,16566)
insert into #tmp_stella_bsp values(1016,665,1320,4921,3663,4797,476,3851,19693)
insert into #tmp_stella_bsp values(1017,839,1315,5496,4053,5304,574,4230,21811)
insert into #tmp_stella_bsp values(1018,598,1308,5330,3480,4439,507,3354,19016)
insert into #tmp_stella_bsp values(1019,705,1517,5451,3622,5122,500,3732,20649)
insert into #tmp_stella_bsp values(1020,707,1240,5160,3789,5223,587,4103,20809)
insert into #tmp_stella_bsp values(1021,671,1384,4821,3599,4975,546,3663,19659)
insert into #tmp_stella_bsp values(1022,725,1423,5519,4226,5456,594,4051,21994)
insert into #tmp_stella_bsp values(1023,599,1177,5314,3520,5216,631,3711,20168)
insert into #tmp_stella_bsp values(1024,582,1070,4933,3086,5183,425,3703,18982)
insert into #tmp_stella_bsp values(1025,590,1481,4087,3045,4040,434,2983,16660)
insert into #tmp_stella_bsp values(1026,516,1122,4883,3276,4354,442,3542,18135)
insert into #tmp_stella_bsp values(1027,492,1643,5140,3534,5100,461,3590,19960)
insert into #tmp_stella_bsp values(1028,618,1133,4222,2800,4414,425,2874,16486)
insert into #tmp_stella_bsp values(1029,661,1455,4878,3089,4594,428,3319,18424)
insert into #tmp_stella_bsp values(1030,866,1092,4696,3233,4614,588,3247,18336)
insert into #tmp_stella_bsp values(1031,665,1198,5373,3456,4640,421,3650,19403)
insert into #tmp_stella_bsp values(1032,505,1215,4566,2860,4430,353,3126,17055)
insert into #tmp_stella_bsp values(1033,508,1253,4762,3146,4743,370,3292,18074)
insert into #tmp_stella_bsp values(1034,586,1117,4850,2839,4583,428,3556,17959)
insert into #tmp_stella_bsp values(1035,608,1320,5267,3188,4868,522,3653,19426)
insert into #tmp_stella_bsp values(1036,688,1078,5697,3181,4817,570,3524,19555)
insert into #tmp_stella_bsp values(1037,498,1299,4508,2614,4352,468,3522,17261)
insert into #tmp_stella_bsp values(1038,615,1292,4714,2884,4793,456,3525,18279)
insert into #tmp_stella_bsp values(1039,518,1083,4197,2619,4135,324,3422,16298)
insert into #tmp_stella_bsp values(1040,538,1270,4794,3120,4695,402,3477,18296)
insert into #tmp_stella_bsp values(1041,528,1249,4064,3045,4532,380,3324,17122)
insert into #tmp_stella_bsp values(1042,536,1260,4634,3534,5023,441,3961,19389)
insert into #tmp_stella_bsp values(1043,639,1556,4679,4120,5506,535,3682,20717)
insert into #tmp_stella_bsp values(1044,730,2196,5013,5067,7059,518,3974,24557)
insert into #tmp_stella_bsp values(1045,522,1336,4148,3530,4969,438,3295,18238)
insert into #tmp_stella_bsp values(1046,631,1484,4734,3714,5280,483,3442,19768)
insert into #tmp_stella_bsp values(1047,835,1943,4846,4940,6675,498,3691,23428)
insert into #tmp_stella_bsp values(1048,805,1259,4737,4039,5724,497,3325,20386)
insert into #tmp_stella_bsp values(1049,735,1513,4820,4733,5907,534,3313,21555)
insert into #tmp_stella_bsp values(1050,417,1153,3749,3095,4090,269,2705,15478)
insert into #tmp_stella_bsp values(1051,404,1074,3805,3124,4156,397,2510,15470)
insert into #tmp_stella_bsp values(1052,548,976,3855,2964,4144,364,3107,15958)
insert into #tmp_stella_bsp values(1101,135,1214,1856,1141,1624,153,905,7028)
insert into #tmp_stella_bsp values(1102,340,929,2891,2333,3099,349,2070,12011)
insert into #tmp_stella_bsp values(1103,658,1896,4666,4513,5463,475,3419,21090)




--get Stella test agencies. this will be used to exclude test/training policies
if object_id('tempdb..#tmp_Stella_Test_Agencies') is not null drop table #tmp_Stella_Test_Agencies
select AgencyCode, AgencyName
into #tmp_Stella_Test_Agencies 
from [db-au-cmdwh].dbo.Agency 
where AgencyGroupCode in ('HW','TI','TT') and 
	(AgencyName like '%test%' or AgencyName like '%train%') and 
	AgencyName <> 'Great Trains of Europe Tours'



if object_id('tempdb..#tmp_Strike_Rate_Raw') is not null drop table #tmp_Strike_Rate_Raw
select
  case when a.AgencyGroupCode = 'HW' then 'HW'
       when a.AgencyGroupCode = 'TT' and a.AgencySubGroupCode = 'AC' then 'ATAC'
       when a.AgencyGroupCode = 'TT' and a.AgencySubGroupCode = 'BE' then 'BEST FLIGHTS'
       when a.AgencyGroupCode = 'TT' and a.AgencysubGroupCode in ('ET','GC','TT') then 'CAN'
       when a.AgencyGroupCode = 'TT' then 'CAN'
       when a.AgencyGroupCode = 'TI' and a.AgencySubGroupCode in ('BB','CJ') then 'TSAX ASSOCIATE'
       when a.AgencyGroupCode = 'TI' and a.SalesSegment like '%FULL%' then 'TSAX FULL'
       when a.AgencyGroupCode = 'TI' and a.SalesSegment like '%ASSOCIATE%' then 'TSAX ASSOCIATE'
       when a.AgencyGroupCode = 'TI' and a.SalesSegment like '%CORPORATE%' then 'TSAX CORPORATE'
       else 'UNKNOWN'
  end as StellaGroup,       
  a.AgencyGroupCode,
  a.AgencySubGroupCode,
  a.SalesSegment,
  a.AgencyCode,
  a.AgencyName,
  p.PolicyType,
  p.OldPolicyType,
  p.PlanCode,
  p.NumberOfPersons as NumberOfTravellers,
  p.CreateDate
into #tmp_Strike_Rate_Raw  
from
  [db-au-cmdwh].dbo.Policy p
  join [db-au-cmdwh].dbo.Agency a on
	p.AgencyKey = a.AgencyKey and
	p.CountryKey = a.CountryKey
where
  p.CountryKey = 'AU' and
  p.PlanCode not like '%D%' and
  a.AgencyGroupCode in ('HW','TI','TT') and
  convert(varchar(10),p.CreateDate,120) between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) and
  a.AgencyCode not in (select AgencyCode from #tmp_Stella_Test_Agencies)



select
  a.StellaGroup,
  sum(case when a.PolicyType = 'N' then a.NumberOfTravellers
       when a.PolicyType = 'R' and a.OldPolicyType = 'N' then a.NumberOfTravellers * -1
       else 0
  end) as NumberOfTravellers,  
  c.[Week] as [Week],
  c.StartDate,
  c.EndDate,
  c.[Year],
  c.[Month],
  c.WeekNum
into #tmp_Strike_Rate_Baseline  
from
  #tmp_Strike_Rate_Raw a
  join [db-au-cmdwh].dbo.usrStellaCalendar c on
	a.CreateDate between c.StartDate and c.Enddate  
group by
  a.StellaGroup,
  c.[Week],
  c.[StartDate],
  c.[EndDate],
  c.[Year],
  c.[Month],
  c.[WeekNum]

if object_id('tempdb..#tmp_Strike_Rate_Main') is not null drop table #tmp_Strike_Rate_Main
select
    a.[Year],
  	a.[Week],
  	a.[WeekNum],
  	b.ATAC as Stella_ATAC,
  	sum(case when a.StellaGroup = 'ATAC' then a.NumberOfTravellers else 0 end) as CM_ATAC,
  	b.BESTFLIGHTS as Stella_BESTFLIGHTS,
  	sum(case when a.StellaGroup = 'BEST FLIGHTS' then a.NumberOfTravellers else 0 end) as CM_BESTFLIGHTS,
  	b.CAN as Stella_CAN,
  	sum(case when a.StellaGroup = 'CAN' then a.NumberOfTravellers else 0 end) as CM_CAN,
  	b.HWT as Stella_HWT,
  	sum(case when a.StellaGroup = 'HW' then a.NumberOfTravellers else 0 end) as CM_HWT,
  	b.TSAXFULL as Stella_TSAXFULL,
  	sum(case when a.StellaGroup = 'TSAX FULL' then a.NumberOfTravellers else 0 end) as CM_TSAXFULL,
  	b.TSAXAssociate as Stella_TSAXAssociate,
  	sum(case when a.StellaGroup = 'TSAX ASSOCIATE' then a.NumberOfTravellers else 0 end) as CM_TSAXASSOCIATE,
  	b.TSAXCorporate as Stella_TSAXCorporate,
  	sum(case when a.StellaGroup = 'TSAX CORPORATE' then a.NumberOfTravellers else 0 end) as CM_TSAXCORPORATE
into #tmp_Strike_Rate_Main
from
	#tmp_Strike_Rate_Baseline a 
	join #tmp_stella_bsp b on
		a.[Week] = b.[Week]
group by
  a.[Year],
  a.[Week],
  a.[WeekNum],
  b.ATAC,
  b.BESTFLIGHTS,
  b.CAN,
  b.HWT,
  b.TSAXFULL,
  b.TSAXAssociate,
  b.TSAXCorporate
order by
  a.[Year],
  a.[Week]    	


if object_id('tempdb..#tmp_strike_rate_main2') is not null drop table #tmp_strike_rate_main2
select
	a.[Year],
	a.[Week],
	a.[WeekNum],
	a.Stella_ATAC,
	a.CM_ATAC,
	(select top 1 Stella_ATAC from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_ATAC,
	(select top 1 CM_ATAC from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_ATAC,
	a.Stella_BestFlights,
	a.CM_BestFlights,
	(select top 1 Stella_BestFlights from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_BestFlights,
	(select top 1 CM_BestFlights from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_BestFlights,	
	a.Stella_CAN,
	a.CM_CAN,
	(select top 1 Stella_CAN from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_CAN,
	(select top 1 CM_CAN from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_CAN,	
	a.Stella_HWT,
	a.CM_HWT,
	(select top 1 Stella_HWT from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_HWT,
	(select top 1 CM_HWT from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_HWT,	
	a.Stella_TSAXFull,
	a.CM_TSAXFull,
	(select top 1 Stella_TSAXFull from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_TSAXFull,
	(select top 1 CM_TSAXFull from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_TSAXFull,	
	a.Stella_TSAXAssociate,
	a.CM_TSAXAssociate,
	(select top 1 Stella_TSAXAssociate from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_TSAXAssociate,
	(select top 1 CM_TSAXAssociate from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_TSAXAssociate,	
	a.Stella_TSAXCorporate,
	a.CM_TSAXCorporate,
	(select top 1 Stella_TSAXCorporate from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYStella_TSAXCorporate,
	(select top 1 CM_TSAXCorporate from #tmp_Strike_Rate_Main where [Year] = a.[Year] - 1 and right(cast([Week] as varchar),2) = right(cast(a.[Week] as varchar),2)) as LYCM_TSAXCorporate
into #tmp_strike_rate_main2	
from
	#tmp_Strike_Rate_Main a


select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'ATAC' as StellaGroup,
  a.Stella_ATAC as StellaTickets,
  a.CM_ATAC as CMTravellers,
  a.LYStella_ATAC as StellaTicketsLY,
  a.LYCM_ATAC as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 

union all

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'Best Flights' as StellaGroup,
  a.Stella_BestFlights as StellaTickets,
  a.CM_BestFlights as CMTravellers,
  a.LYStella_BestFlights as StellaTicketsLY,
  a.LYCM_BestFlights as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  
union all     

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'CAN' as StellaGroup,
  a.Stella_CAN as StellaTickets,
  a.CM_CAN as CMTravellers,
  a.LYStella_CAN as StellaTicketsLY,
  a.LYCM_CAN as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  
union all

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'HWT' as StellaGroup,
  a.Stella_HWT as StellaTickets,
  a.CM_HWT as CMTravellers,
  a.LYStella_HWT as StellaTicketsLY,
  a.LYCM_HWT as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  
union all

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'TSAX Full' as StellaGroup,
  a.Stella_TSAXFull as StellaTickets,
  a.CM_TSAXFull as CMTravellers,
  a.LYStella_TSAXFull as StellaTicketsLY,
  a.LYCM_TSAXFull as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  
union all

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'TSAX Associate' as StellaGroup,
  a.Stella_TSAXAssociate as StellaTickets,
  a.CM_TSAXAssociate as CMTravellers,
  a.LYStella_TSAXAssociate as StellaTicketsLY,
  a.LYCM_TSAXAssociate as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  
union all

select
  a.[Year],
  a.[Week],
  a.[WeekNum],
  'TSAX Corporate' as StellaGroup,
  a.Stella_TSAXCorporate as StellaTickets,
  a.CM_TSAXCorporate as CMTravellers,
  a.LYStella_TSAXCorporate as StellaTicketsLY,
  a.LYCM_TSAXCorporate as CMTravellersLY
from
  #tmp_Strike_Rate_Main2 a 
  

drop table #tmp_Stella_BSP
drop table #tmp_Strike_Rate_raw
drop table #tmp_Strike_Rate_Baseline
drop table #tmp_Strike_Rate_Main
drop table #tmp_strike_rate_main2
GO
