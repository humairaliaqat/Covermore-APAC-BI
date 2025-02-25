USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0828]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0828]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0828
--	Author:			Linus Tor
--	Date Created:	20161028
--	Description:	This stored procedure returns helloworld outlet sales and salesforce call details
--	Parameters:		@DateRange: standard date range or _User Defined
--					@StartDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--					@EndDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--	
--	Change History:	20161028 - LT - Created
--	
/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/


--insert sales data from helloworld
if object_id('tempdb..#x') is not null drop table #x
create table #x
(
	AlphaCode varchar(50) null,
	FY15NonPreferred money null,
	FY15Preferred money null,
	FY16NonPreferred money null,
	FY16Preferred money null
)

insert #x values('HAN0173',363647.47,0,347095.97,14117.97)
insert #x values('HAQ0047',323103.65,69333.32,179262.83,55998.89)
insert #x values('HAV0079',224336.51,2327.64,249528.88,35602.24)
insert #x values('HFT0002',212068.01,43469.82,148714.1,86122.78)
insert #x values('HAW0061',205134.26,208.88,61067.75,1560.9)
insert #x values('HFN0077',187492.64,0,176647.62,0)
insert #x values('HAW0002',179547.93,69186.6,177794.57,46803.24)
insert #x values('HFV0060',179353.6,1272.64,113214.55,29826.99)
insert #x values('HFW0039',176211.55,0,148867.72,0)
insert #x values('TIW1030',175624.52,4312.09,111589.24,5271.2)
insert #x values('HAN0054',169771.45,0,182895.79,1752.91)
insert #x values('HAN0087',169203.36,404,96520.5,1011.78)
insert #x values('HAQ0066',165755.81,0,165734.99,0)
insert #x values('HFS0016',163248.86,78560.59,235262.85,77522.55)
insert #x values('HFV0028',162521.86,0,158401.4,0)
insert #x values('HFQ0053',151147.31,1304.9,123770.05,621.87)
insert #x values('HFV0030',147505.48,0,165231.51,0)
insert #x values('HFQ0057',142034.25,0,136711.13,0)
insert #x values('HAN0063',136298.68,21680.36,0,0)
insert #x values('HFV0036',134343.02,0,145041.09,0)
insert #x values('HFN0012',133254.12,0,146928.61,0)
insert #x values('HAV0048',132849.72,13583.68,140357.76,18293.17)
insert #x values('HFV0014',131193.63,0,130522.05,0)
insert #x values('HFQ0025',130132.4,0,141668.98,663.55)
insert #x values('HFQ0027',129784,9.9475983006414E-14,135371.11,0)
insert #x values('HAQ0019',126871.36,10868.96,75077.09,54333.35)
insert #x values('HFN0018',120720.87,659,90331.6,41442.21)
insert #x values('HFV0029',120680.08,175,159980.74,-175)
insert #x values('HAV0031',119115.32,15790.1,132047.33,16070.93)
insert #x values('HFS0008',118952.91,2199.38,18067.76,113594.12)
insert #x values('HAN0175',118509.03,0,96638.01,6015.24)
insert #x values('HAN0075',117694.64,6986.69,93577.26,17070.57)
insert #x values('HAN0039',116845.02,232,151863.03,0)
insert #x values('HFN0074',116793.05,0,129354.32,0)
insert #x values('HAN0162',114924.38,18016.33,79684.56,28821.43)
insert #x values('HAQ0002',114892.58,286647.15,196834.36,600882.97)
insert #x values('HFN0078',114185.2,0,97105.83,0)
insert #x values('HFN0023',112476.07,0,99360.63,0)
insert #x values('HFQ0055',111360.01,802.11,103186.39,2012.45)
insert #x values('HAV0005',111352.38,4587,107296.01,4956.88)
insert #x values('HFV0046',110969.58,0,122215.72,0)
insert #x values('HFN0112',110440.75,0,104535.26,0)
insert #x values('HFQ0032',109953.04,0,97479.19,0)
insert #x values('HAW0027',107755.17,700,80851.47,1682.04)
insert #x values('HAN0158',107393.98,52200.8,99404.17,62484.59)
insert #x values('HFN0010',104723.99,11079.93,89927.79,27061.63)
insert #x values('HFN0087',104070.18,0,95062.01,0)
insert #x values('HAV0043',104063.65,4387.97,122933.98,8241.8)
insert #x values('HFW0036',103796.69,24520.61,85620.9500000001,39962.77)
insert #x values('HFN0082',102983.68,0,93495.75,0)
insert #x values('HAQ0041',102295.88,4335.96,105951.82,4474.43)
insert #x values('HFN0020',102152.26,0,90793.03,0)
insert #x values('HFV0066',100672.27,1041,115161.43,8300)
insert #x values('HAQ0071',99222.77,0,104913.21,0)
insert #x values('HFT0003',98518.38,6661.44,36306.71,60849.47)
insert #x values('HFQ0031',98500.59,0,92821.03,0)
insert #x values('HFV0067',97908.12,8374,81143.77,10106.98)
insert #x values('HAN0128',97288.16,0,72672.97,0)
insert #x values('HFS0017',96643.94,0,106094.82,2587.63)
insert #x values('HFV0013',96346.67,0,71045.45,7729.63)
insert #x values('HAV0041',96145,0,108068.04,0)
insert #x values('HFQ0018',95411.06,0,114697.56,0)
insert #x values('HFV0015',95335.55,1417.11,88994.12,6647.57)
insert #x values('HFW0013',93949.1,61.82,93513.41,0)
insert #x values('HAN0118',93859.38,1245.9,87456.71,3809.09)
insert #x values('HAS0030',92830.33,0,81250.12,0)
insert #x values('HAN0053',91576.68,31853.45,110536.93,36427.75)
insert #x values('HAN0130',91042.98,0,93885.9,55)
insert #x values('HFS0018',91027.97,7878.63,110951.37,23088.97)
insert #x values('HAS0010',90370.61,0,108474.55,200.89)
insert #x values('HFV0057',89974.93,668.32,87220.88,119.18)
insert #x values('HFS0012',88836.87,0,141693.18,0)
insert #x values('HFV0064',88254.28,567,84410.88,5136.15)
insert #x values('HFN0113',87647.82,0,72406.08,10620)
insert #x values('HAN0081',86632.07,9017.75,54453.63,22964.24)
insert #x values('HAQ0013',86455.54,55581.85,60710.33,86874.98)
insert #x values('HFV0012',85426.26,20452.51,69530.09,30609.48)
insert #x values('HFQ0049',85418.34,0,51602.84,9098.01)
insert #x values('HAV0023',84371.37,148818.52,46006.71,169988.74)
insert #x values('HFW0009',83981.98,38.18,61083.67,8456.3)
insert #x values('HFN0096',83804.07,2008.99,101802.03,8727.54)
insert #x values('HAN0115',82075.38,0,99292.02,0)
insert #x values('HFW0021',81631.35,26949.48,79197.9,40652.93)
insert #x values('HFN0032',81387.6,0,109949.28,0)
insert #x values('HFS0001',81211.15,0,81440.85,0)
insert #x values('HAV0088',81035.86,5314.64,77523.49,10729.66)
insert #x values('HAN0151',80321.66,0,81512.37,11583.67)
insert #x values('HFQ0052',79864.02,429,85240.65,7988.64)
insert #x values('HFQ0012',78813.3,0,74325.85,4290.73)
insert #x values('HFN0084',76869.45,4606.73,49418.65,47633.01)
insert #x values('HFN0007',76442.6,2123,79079.31,28778.41)
insert #x values('HAV0044',76157.45,4500.6,62164.77,2933.23)
insert #x values('HAV0056',76058.44,121635.34,151958.69,59614.81)
insert #x values('HAQ0033',75762.17,0,63366.52,0)
insert #x values('HAN0002',75293.54,0,92183.72,5804)
insert #x values('HFV0022',75224.42,47561.02,54847.1,69463.5)
insert #x values('TIS1008',75089.67,30894.21,51802.17,43021.63)
insert #x values('HAN0144',74455.24,0,78270.16,319.36)
insert #x values('HFN0080',74247.45,0,56819.52,0)
insert #x values('HFQ0015',74034.51,0,40162.47,3632)
insert #x values('HAQ0080',73498.84,5560,48492.1,16759.76)
insert #x values('HFQ0029',73065.58,15142.38,58926.79,21689.12)
insert #x values('HFV0069',73065.31,2709,91197.71,0)
insert #x values('HFQ0054',72956.64,13568,55649.66,3097)
insert #x values('HAQ0079',72059.84,5711.27,32062.51,36940.2)
insert #x values('HFV0065',71615.55,0,64218.32,4976)
insert #x values('HFQ0006',71454.6,20225.41,67961.24,29520.02)
insert #x values('HFN0076',69743.56,0,59633.21,0)
insert #x values('HFV0020',69586.65,2963.37,68168.32,16790.1)
insert #x values('No alpha code',69376.47,252.73,70706.13,0)
insert #x values('AEQ1592',69209.61,8488.45,47852.35,8342.64)
insert #x values('AESP100',69086.4,367538.99,32598.13,467178.42)
insert #x values('HAN0065',68935.18,0,77854.08,0)
insert #x values('HFQ0038',68617.11,30295.08,54040.31,36713.3)
insert #x values('HAV0011',68369.1,35090.77,51758.67,33036.48)
insert #x values('HFW0028',67394.39,3951.56,71729.52,4587.02)
insert #x values('HAQ0035',67204.97,12452.15,63774.02,8163.72)
insert #x values('HAN0154',66881.47,13982.12,39846.88,28739.45)
insert #x values('HAN0020',66879.23,52698.29,15406.59,64539.22)
insert #x values('HAN0040',66551.64,49352.07,90133.91,39157.97)
insert #x values('HFA0001',66437.46,6814.45,48353.14,4874.6)
insert #x values('HAN0116',64656.68,0,69460.24,0)
insert #x values('HAQ0040',64603.86,12085.04,41867.89,11872.6)
insert #x values('HAN0147',64059.91,0,67796.04,0)
insert #x values('HFV0011',63365.42,0,65121.81,0)
insert #x values('HFN0073',62729.6,0,55809.46,10533.47)
insert #x values('HFW0020',62729.35,2171,59439,2322.36)
insert #x values('HFV0059',62250.88,8845,45819.72,12443.97)
insert #x values('HFN0102',61748.84,4900.2,67664.56,15053.43)
insert #x values('HFQ0041',61747.93,0,59284.73,2219.75)
insert #x values('AAWI001',61653.06,0,61734.29,0)
insert #x values('HAW0056',61555.67,0,48890.86,0)
insert #x values('HAQ0043',61140.65,2552.93,62734.92,201.82)
insert #x values('HFW0029',60751.71,4075.08,73229.76,13660.45)
insert #x values('HFV0053',60634.76,3416,67907.28,3705.09)
insert #x values('HAQ0006',60486.78,8608.16,67365.07,15129.76)
insert #x values('HAN0148',60305.11,5182.61,33967.95,0)
insert #x values('HAV0082',60232.17,10467.01,43096.04,10898.98)
insert #x values('HFQ0036',60083.57,16909.83,47905.12,38054.86)
insert #x values('HAW0025',59037.23,0,49935.38,5074.82)
insert #x values('HAQ0005',58940.39,9624.39,44566.56,7523.2)
insert #x values('HFV0051',58122.29,1596.42,56672.73,0)
insert #x values('HAQ0007',57986.41,1053,51851.42,5411)
insert #x values('HAV0085',57882.31,11049.22,49093.93,7414.34)
insert #x values('HAN0122',57005.38,2145.72,34240.55,2765.52)
insert #x values('HAN0069',56821.29,0,57480.32,0)
insert #x values('HFW0014',56727.32,3366.33,49989.66,9238.92)
insert #x values('HFA0004',56698.19,2700.23,58843.72,909.54)
insert #x values('HAV0045',56477.75,74325.82,45560.86,70642.79)
insert #x values('HAQ0010',56322.2,0,63600.25,0)
insert #x values('HFN0057',56239.98,0,88316.57,0)
insert #x values('HFV0019',56128.1,4526.24,45847.07,13085.62)
insert #x values('HFQ0040',56032.73,0,61813.71,0)
insert #x values('HAQ0037',56019.33,14516.9,73432.7899999999,13253.68)
insert #x values('HAV0052',55881.78,0,49104.85,0)
insert #x values('HAN0129',55538.09,0,51139.96,4147.2)
insert #x values('HAV0091',55359.24,0,58145.04,0)
insert #x values('HAW0012',55321.73,4385.86,37269.36,18911.47)
insert #x values('HAW0057',55277.85,0,37472.48,625.08)
insert #x values('HFQ0013',55002.32,0,39604.05,1944.73)
insert #x values('No alpha code',54687.25,280.91,48595.08,9076.26)
insert #x values('HFS0007',54532.63,582,52137.01,11754.92)
insert #x values('HFW0023',54393.2,0,51521.07,0)
insert #x values('HAV0078',54337.6,0,49106.91,0)
insert #x values('HAN0023',54087.51,11899.96,55992.88,14000.97)
insert #x values('HAS0028',54002.48,0,60634.96,0)
insert #x values('HFN0045',53852.27,0,78114.75,0)
insert #x values('HFQ0039',53575.84,32189.61,70559.08,26464.06)
insert #x values('HAN0134',53475.47,506.82,40695.1,12431.52)
insert #x values('HAQ0015',53413.12,49428.39,29750.07,55176.5)
insert #x values('HFQ0048',53169.46,6030.36,42709.18,13144.81)
insert #x values('HFQ0002',52164.4899999999,4098,25670.16,74868.27)
insert #x values('HAN0031',52123.7,8218,63863.22,10736.46)
insert #x values('HFW0019',51486.94,0,67817.86,543)
insert #x values('HFN0026',51442,11229.09,41253.89,22360.13)
insert #x values('HAV0071',51087.15,0,25420.22,282)
insert #x values('HFN0105',50686.65,10610.61,45596.56,18012.86)
insert #x values('HAW0051',50672.73,4954.4,53307.9899999999,7159.63)
insert #x values('HFQ0056',50501.74,18333.84,60937.02,28842.84)
insert #x values('HFN0053',50470.6,0,37039.24,0)
insert #x values('HFQ0003',50467.83,109520.52,66374.07,106232.3)
insert #x values('HAW0008',50330.14,0,32438.96,0)
insert #x values('HFW0007',50062.26,0,55170.79,0)
insert #x values('HFN0041',49852.41,8366.33,14644.41,53916.58)
insert #x values('HFV0072',49669.09,2117.73,33920.91,15472.9)
insert #x values('HAS0012',49317.19,52085.58,84717.83,52026.51)
insert #x values('HAV0004',49137.07,32900.18,48695.26,19786.97)
insert #x values('HAS0033',48699.77,0,44981.13,1890.4)
insert #x values('HAW0006',48504.47,9583.82,45040.36,15832.14)
insert #x values('HAV0081',48455.33,12195.09,52183,29167.56)
insert #x values('HFT0001',48385.61,27692.72,6409.09,83589.29)
insert #x values('HFQ0014',48366.28,1997,29127.72,4760.17)
insert #x values('HAQ0020',48174.57,52985.88,46394.72,76439.41)
insert #x values('HAN0055',48080.17,36656.27,72195.5,15623.28)
insert #x values('HAN0159',47649.66,0,35548.61,141.91)
insert #x values('HAV0099',47407.57,0,40378.94,521.46)
insert #x values('HFN0063',47207.37,38351.15,33794.2,38205.5)
insert #x values('HFV0033',47147.49,1619.44,57342.83,1971.91)
insert #x values('HFW0026',46849,0,46617.65,1658)
insert #x values('HAN0004',46662.06,11726.41,39296.89,9522.66)
insert #x values('HFV0062',45684.81,0,48161.44,2337)
insert #x values('HAQ0077',45129.47,502.73,40425.03,0)
insert #x values('HFN0037',45122,1137.82,27353.52,4067.73)
insert #x values('HFT0004',44845.74,0,31617.3,0)
insert #x values('HAV0046',44610.72,8401.44,45211.07,9295.88)
insert #x values('HAN0133',44069.76,0,34903.94,5085.76)
insert #x values('HAN0105',44022.4,0,41261.31,0)
insert #x values('HAV0090',43963.56,5964,13773.91,58495.88)
insert #x values('HAQ0069',43747.5,4136.12,45416.04,2052.72)
insert #x values('HAV0022',43738.85,18461.67,33506.56,24090.55)
insert #x values('HFV0073',43437.98,0,45786.53,0)
insert #x values('HFW0004',43362.71,0,37329.36,251.82)
insert #x values('HFV0026',43287.15,3524.31,40376.45,11594.06)
insert #x values('HWN2300',42825.09,0,50526.57,0)
insert #x values('HFV0075',42734.03,11355,20413.89,38558.73)
insert #x values('HAN0046',42668.42,5354,34321.63,18925.38)
insert #x values('HFV0038',42487.52,68979.47,32125.85,92580.81)
insert #x values('HWV1810',42424.8,32455.09,43175.71,39742.11)
insert #x values('HAQ0011',41597.74,64549.42,35741.42,80772.76)
insert #x values('HFW0006',41407.9,779.91,38333.45,0)
insert #x values('HAQ0038',41044.16,4546.11,62310.47,1823.77)
insert #x values('HFW0025',40752.78,0,35472.68,92.7)
insert #x values('HFQ0043',40745.62,0,45745.71,0)
insert #x values('HAS0023',40205.56,0,33287.93,0)
insert #x values('HAQ0039',40147.95,8330.17,34308.96,11546.31)
insert #x values('HAQ0004',39897.14,8660.09,39945.03,14619.83)
insert #x values('HFV0050',39690.63,49230.42,34112.44,49143.22)
insert #x values('HAV0015',39626.65,1724.8,37847.79,23339.04)
insert #x values('HFN0047',39324.21,0,34439.64,0)
insert #x values('HFS0006',39255.93,4478.31,16439.35,18573.37)
insert #x values('HAN0051',38738.79,2046.48,35353.84,543)
insert #x values('HAN0024',37628.14,7245.45,35223.82,27045.75)
insert #x values('HAV0020',37181.81,11748.31,23114.59,18370.72)
insert #x values('HFV0016',36825.5,6509.38,13117.34,18427.36)
insert #x values('HAW0023',36728.2,4503.99,29610.93,3914.91)
insert #x values('HAV0030',36437.28,32381.42,34789.74,37595.05)
insert #x values('HFV0070',36202.9,16103.59,26383.04,11140.32)
insert #x values('HFS0019',36031.37,866,48643.28,3103.73)
insert #x values('HFS0020',35443.11,0,34328.94,0)
insert #x values('HAV0068',34871.87,0,31015.74,0)
insert #x values('HFN0024',34861.52,0,33247.45,0)
insert #x values('HAV0026',34535.96,19680.8,35503.88,16897.72)
insert #x values('HAN0135',34393.33,1471,24248.76,2183)
insert #x values('HFV0017',34291.71,0,25335.04,4591.41)
insert #x values('HFV0047',33771.41,0,47155,0)
insert #x values('HAS0035',33753.56,237,41089.07,4145.64)
insert #x values('HFN0008',33587.56,0,30481.65,0)
insert #x values('HAS0011',33485.67,117620.33,62948.4,81015.2600000001)
insert #x values('HAN0153',33386.35,681,10936.69,11508.65)
insert #x values('HFQ0008',32776.89,48821.46,22382.39,61377.6)
insert #x values('HAN0152',32553.37,5128.82,33686.09,2548.71)
insert #x values('HFN0083',32467.55,0,50964.42,1646.1)
insert #x values('HAV0064',32250.65,0,27989,0)
insert #x values('HFV0043',32125.61,35229.76,17112.79,48613.84)
insert #x values('HAS0007',31865.84,170872.63,18182.02,206391.81)
insert #x values('HFQ0028',31406.39,53603.3,7806.64,72722.07)
insert #x values('HAN0100',31388.27,890.91,19675,22122.91)
insert #x values('HFQ0011',31118.58,21673.75,16679.02,46819.38)
insert #x values('HFW0005',31085.86,0,35188.57,774)
insert #x values('HAS0004',30849.52,473776.85,8997.09,442595.61)
insert #x values('HAN0167',30718.74,0,19869.38,0)
insert #x values('HAQ0078',30480.77,2648.06,29145.51,6855.67)
insert #x values('HAS0021',30075.14,0,43417.24,4693.85)
insert #x values('HFW0035',29994.56,3701.28,27470.28,4620.95)
insert #x values('HAQ0021',29248.92,6521.26,15234.43,8829.46)
insert #x values('HAV0019',29085.2,56311.8,25112.22,45693.82)
insert #x values('HAN0140',28885.69,0,20933.35,2855.75)
insert #x values('HFV0005',28869.11,15614.37,50756.52,9515.48)
insert #x values('HFV0021',28817.55,19371.07,32366.73,24561.02)
insert #x values('HAV0053',28770.91,38878.77,10799.6,67293.42)
insert #x values('HAW0067',28628.24,530,10187.64,11033.55)
insert #x values('HFW0022',28512.37,0,35317.63,2345.79)
insert #x values('HFN0061',28167.21,42509.86,13205.74,60678.03)
insert #x values('HAQ0045',28010.33,2629.79,34216.33,5102.59)
insert #x values('HFV0037',27564.51,48428.4,24406.12,133758.2)
insert #x values('HAQ0012',27554.07,0,12598.02,0)
insert #x values('HAW0048',27500.12,0,17573.94,0)
insert #x values('HFN0058',27314.31,89930.36,75735.13,35674.39)
insert #x values('HAN0090',27283.37,30843.54,8189.59,40643.06)
insert #x values('HFS0014',27178.58,0,14736.45,10191.42)
insert #x values('HAN0117',27034.01,0,37227.8,1764)
insert #x values('HAV0013',26840.13,13371.81,19029.6,26022.9)
insert #x values('HFS0011',26534.73,39045.44,2235.03,53757.8)
insert #x values('HFS0013',26021.31,46809.51,7330.02,69446.84)
insert #x values('HAW0042',25256.81,14808.76,27520.5,30660.16)
insert #x values('HFN0081',24698.54,16.36,22415.64,753.73)
insert #x values('HFV0031',24436.71,60707.24,14229.14,75174.98)
insert #x values('HAQ0022',24345.62,65635.46,16402.76,57446.39)
insert #x values('HFN0004',24343.91,17667.29,23507.56,20645.37)
insert #x values('HFV0032',24153.14,0,103211.99,0)
insert #x values('HAS0005',24086.17,179723.48,9423.99,202464.76)
insert #x values('HFQ0017',23334.18,30818.56,31363.64,42373.61)
insert #x values('HFN0016',23225.44,11587.43,33021.52,9519.22)
insert #x values('HFV0008',23018.57,29439.1,17747.26,37421.11)
insert #x values('HFQ0019',22882.18,58763.96,5216.98,84197.58)
insert #x values('HFQ0010',22597.29,12015.42,0,38493.19)
insert #x values('HFN0052',21893.8,78132.74,475.94,97563.5)
insert #x values('HFQ0037',21350.39,39264.72,18785.67,53425.09)
insert #x values('HFV0001',20810.26,115459.91,13297.71,92531.87)
insert #x values('HFN0009',20808.3,0,35102.95,3392.76)
insert #x values('HAS0002',20717.56,166188.16,22945.99,227522.85)
insert #x values('HAQ0017',20681.09,88807.43,18249.75,70632.07)
insert #x values('HAN0017',20636.31,312,22404.88,118)
insert #x values('HFQ0045',20291.41,82821.27,13858.52,62681.66)
insert #x values('HAQ0030',20121.57,75626.37,12150.99,87326.38)
insert #x values('HFN0014',19895.48,31804.73,7181.2,54296.47)
insert #x values('HAN0123',19868.29,0,9212.5,0)
insert #x values('HAQ0074',18747.84,974,11327.56,4808.64)
insert #x values('HAV0047',18686.31,13848.57,17436.79,15312.23)
insert #x values('HFN0085',18639.69,0,24364.47,0)
insert #x values('HAS0018',18541.49,113159.34,7121.87,217598.61)
insert #x values('HAV0032',17970.26,31864.79,4290.63,28730.27)
insert #x values('HFV0018',17417.3,3699.27,13113.37,12203.33)
insert #x values('HFV0042',17362.91,70213.47,8005.9,64734.89)
insert #x values('HAQ0055',17126.76,68352.08,-118.72,114974.68)
insert #x values('HFW0001',16688.91,29401.51,20342.64,26515.3)
insert #x values('HAN0042',16666.47,4233.95,23880.31,2242.23)
insert #x values('HAN0050',16510.77,0,9994.29,0)
insert #x values('HAN0013',16143.16,97058.21,15673.88,99782.21)
insert #x values('HAV0033',15838.52,2904.27,11662.45,10647.44)
insert #x values('HFQ0058',15183.4,3139.56,647.43,15821.73)
insert #x values('HFN0072',14236.61,16896.92,339,34643.66)
insert #x values('HAQ0067',14058.06,0,6184.49,0)
insert #x values('HAN0030',13876.83,20202.29,6052.66,15237.73)
insert #x values('HFN0067',13602.56,71713.28,14539.34,65097.58)
insert #x values('HAN0150',13145.82,2338.16,15979.76,940.47)
insert #x values('HAN0037',13092.55,51399.34,18490.56,34629.09)
insert #x values('HAW0055',13069.36,0,19110.03,0)
insert #x values('HFS0009',12464.31,131769.1,6498.91,126426.65)
insert #x values('HAS0020',12327.86,2659.26,11188.71,3615.71)
insert #x values('HFW0012',12077.6,62888.03,959.8,75072.53)
insert #x values('HAV0014',11886.02,44780.96,5416.72,54591.79)
insert #x values('HAV0067',11470.18,0,24699.33,0)
insert #x values('HAW0040',11255.75,0,15863.2,0)
insert #x values('HFV0048',10772.75,0,11187.56,0)
insert #x values('HFW0010',10454.57,0,12811.61,0)
insert #x values('HAS0003',10031.41,197663.99,12482.66,237226.83)
insert #x values('HAS0006',10018.64,192418.99,12125.77,208713.03)
insert #x values('HFQ0016',9791.25,214,13346.31,523)
insert #x values('HFV0025',9776.75,57424.45,7247.65,79527)
insert #x values('HFV0009',9272.37,64977.06,6899.04,79048.15)
insert #x values('HAQ0034',9240.08,0,18091.44,0)
insert #x values('HAW0029',8842.37,31070.88,11944.4,33356.26)
insert #x values('HAV0040',8822.8,68346.08,9881.28,45233.5)
insert #x values('HAQ0075',8695.17,0,6487,0)
insert #x values('HFV0034',8408.99,69964.98,1301,107321.18)
insert #x values('HWW0219',8236.18,22452.81,4970.56,15900.29)
insert #x values('HFV0055',8121.22,12419.97,7873.6,17191.83)
insert #x values('HAQ0009',7793.03,61711.7,4729.5,68498.12)
insert #x values('HAS0008',7568.4,368226.53,13795.61,433962.03)
insert #x values('HAN0021',7442.52,35501.92,2596.48,20503.49)
insert #x values('HAN0099',7231.88,8878.48,0,14540.06)
insert #x values('HFV0010',7012.39,58717.74,769.3,66053.19)
insert #x values('HAN0015',6916.94,76734.19,1687,95733.53)
insert #x values('HAW0011',6880.46,0,3494.16,0)
insert #x values('HAQ0036',6818.13,32191.27,9742.94,23844.51)
insert #x values('HFN0059',6468.25,63357.9,0,62870.96)
insert #x values('HAQ0053',6288.56,366749.42,7267.62,435682.09)
insert #x values('HFQ0072',6208.73,57688.44,7708.33,98015.51)
insert #x values('HAN0097',6107.39,0,7277.76,0)
insert #x values('HFV0082',6017,3949,54663.95,13475.28)
insert #x values('HFN0005',5571.61,51222.43,3499.58,41177.75)
insert #x values('HAW0047',5450.86,1443,8939.38,79.09)
insert #x values('HAV0021',5363,0,7200,0)
insert #x values('HFQ0026',5167.58,37570.39,25341.56,36544.53)
insert #x values('HFN0043',5111.38,30055.26,6894.73,31264.54)
insert #x values('HAS0019',5019.8,105564.53,0,160391.88)
insert #x values('HFV0007',4548.8,53766.91,4375.99,76219.59)
insert #x values('HAQ0023',4455.81,12579.92,967,27169.44)
insert #x values('HAQ0029',3766,63290.83,2915.9,63227.9)
insert #x values('HAQ0068',3456.85,0,2687,0)
insert #x values('HFQ0009',3330.09,254370.98,1975.54,285832.6)
insert #x values('HAQ0014',3297.25,5451,14638.69,8520.19)
insert #x values('HFQ0042',3142.95,42164.33,0,38104.16)
insert #x values('HFN0028',2991.75,53886.33,0,40274.01)
insert #x values('HFQ0024',2977.49,75380.05,1066,92619.27)
insert #x values('HFW0011',2671.36,38410.69,0,39875.22)
insert #x values('HFV0056',2607.1,45104.64,5316.11,28534.83)
insert #x values('HFV0045',2404,19169.59,0,22646.6)
insert #x values('HAV0027',2376.87,88956.51,1088,84595.19)
insert #x values('HFV0041',2227.05,86514.9,0,77271.18)
insert #x values('HFQ0070',2143.46,7048.89,25471.59,22430.39)
insert #x values('HFN0033',2096.32,72649.44,1136.36,90067.72)
insert #x values('HAN0003',2088.16,0,2090,0)
insert #x values('HFN0103',2037.25,0,35543.5,0)
insert #x values('HAN0124',2007.67,44,0,318)
insert #x values('HAQ0024',2001.14,11326.18,2967.09,12128.82)
insert #x values('HFQ0033',1777.98,75166.59,4078.72,89764.45)
insert #x values('HAW0053',1738,0,5429,0)
insert #x values('HAV0087',1728,28903.86,11286.58,67756.43)
insert #x values('HAN0052',1470,29725.2,179,48098.76)
insert #x values('HFV0004',1303.1,93962.79,2007.35,80260.71)
insert #x values('HFQ0023',1288.63,82433.99,2475,77075.08)
insert #x values('HAV0025',908.64,31742.3,176,44145.73)
insert #x values('HFW0038',747,68119.75,668.9,50589.47)
insert #x values('HWN5858',730.9,121868.03,0,148280.78)
insert #x values('HFV0035',694.85,36335.38,463,40027.36)
insert #x values('HFV0006',689.91,59307.43,6614.69,48755.97)
insert #x values('HFN0027',665.18,102054.33,0,94783.32)
insert #x values('HAN0085',620,22523.85,766,17186.18)
insert #x values('HFV0058',580,48733.8,0,59059.77)
insert #x values('HAV0012',416,175351.32,1724,150070.61)
insert #x values('HAN0083',185.11,33089.07,0,37999)
insert #x values('HAN0171',148,126616.51,300,75246.5)
insert #x values('HAV0024',0,73885.61,0,51506.05)
insert #x values('HFW0003',0,76901.07,0,97161.22)
insert #x values('HFN0117',0,89318.4,5495.4,91674.6)
insert #x values('HFN0017',0,57429.11,0,48831.47)
insert #x values('HAN0068',0,54789.96,0,58063.22)
insert #x values('HFV0044',0,32902.32,37648.8,39239.24)
insert #x values('HAN0056',0,51596.87,0,60331.01)
insert #x values('HAQ0054',-365.09,278769.82,614.48,237618.33)
insert #x values('HFN0031',-436.34,41172.31,0,30902.53)
insert #x values('HLV0017',0,27318.55,0,16970.01)
insert #x values('HLQ0001',0,17134.78,0,18878.66)
insert #x values('HAV0105',0,43439.16,0,47956.55)
insert #x values('HAW0024',0,12695.86,0,14107.96)
insert #x values('TIV1251',0,9801.38,0,13371.35)
insert #x values('HAV0107',0,0,954.84,0)
insert #x values('HAW0026',0,27681.84,0,30551.68)
insert #x values('HFN0030',0,116105.06,0,111500.34)
insert #x values('HFV0074',0,7451.72,0,25369.62)
insert #x values('HFS0010',0,103692.35,0,106667.47)
insert #x values('HFN0054',0,117408.61,0,87031.69)
insert #x values('HFW0034',0,0,123213.38,1319.18)
insert #x values('HFA0002',0,80651.04,0,75004.9)
insert #x values('HFN0029',0,75224.04,0,74400.5)
insert #x values('HFN0021',0,60512.06,0,64900.24)
insert #x values('HFN0003',0,38554.38,0,31568.36)
insert #x values('HFN0116',0,89238.27,9034.34,52697.55)
insert #x values('HAQ0051',0,79001.89,0,87922.9200000001)
insert #x values('HAQ0032',0,90731.19,0,85761.37)
insert #x values('HFN0015',0,52941.25,320,45032.73)
insert #x values('HFQ0035',0,33631.28,0,35002.81)
insert #x values('HAN0089',0,24669.22,0,55464.31)
insert #x values('HFN0114',0,51522.46,5100,27556.9)
insert #x values('HFV0024',0,65301.78,0,101283.85)
insert #x values('HFN0060',0,82531.9,0,101829.48)
insert #x values('HFV0049',0,57632.83,0,49321.19)
insert #x values('HAN0067',0,83627.53,0,95425.73)
insert #x values('HFQ0021',0,28318.6,0,47157.14)
insert #x values('HFV0040',0,36155.21,0,52564.62)
insert #x values('HFN0040',0,87643.42,0,100637.67)
insert #x values('HFV0002',0,50455.48,0,46575.86)
insert #x values('HFN0013',0,38534.43,0,49453.96)
insert #x values('HFV0083',0,0,1411.08,18612.31)
insert #x values('HFN0022',0,136493.97,0,134250.04)
insert #x values('HFN0038',0,55604.82,15328.18,75131.61)
insert #x values('HFN0048',0,1275.31,0,15784.31)
insert #x values('HFN0025',0,64538.41,0,72955.21)
insert #x values('HFN0046',0,71353.51,0,77336.33)
insert #x values('HFN0019',0,104390.43,0,96427.42)
insert #x values('HFQ0044',0,26806.4,0,36116.09)
insert #x values('HFN0056',0,172678.97,0,126402.05)
insert #x values('HAQ0001',0,53787.08,0,43605.65)
insert #x values('HAN0044',0,67757.73,0,89278.69)
insert #x values('HAV0017',0,130280.65,10495.51,140236.15)
insert #x values('HAW0007',0,15620.05,0,37703.73)
insert #x values('HAV0003',0,71158.08,719,58671.58)
insert #x values('HAV0006',0,72485.62,15847.29,96117.51)
insert #x values('HAW0039',0,9624.17,0,10593.5)
insert #x values('HAN0001',0,60629.61,0,82689.3)
insert #x values('HAN0080',0,41002.6,0,33506.02)
insert #x values('HAN0035',0,79779.58,0,83924.27)
insert #x values('HAN0066',0,46405.64,0,54228.03)
insert #x values('HWW0280',0,1725.95,0,0)
insert #x values('HAQ0016',0,11065.68,500,10704.6)


declare @rptStartDate datetime
declare @rptEndDate datetime
declare @StartDateCQ datetime
declare @EndDateCQ datetime
declare @StartDateCY datetime
declare @EndDateCY datetime
declare @StartDatePY datetime
declare @EndDatePY datetime

/* get reporting dates */
if @DateRange = '_User Defined'
begin
    select 
        @rptStartDate = convert(smalldatetime,@StartDate),
        @rptEndDate = convert(smalldatetime,@EndDate)
end            
else
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


/* get Quarter dates */
select @StartDateCQ = dateadd(d,-90,@rptEndDate), @EndDateCQ = @rptEndDate

/* get fiscal year-to-date */
select @StartDateCY = StartDate, @EndDateCY = EndDate
from
	vDateRange
where
	DateRange = 'Fiscal Year-To-Date'

select @StartDatePY = dateadd(year,-1,@StartDateCY),
	   @EndDatePY = dateadd(year,-1,@EndDateCY)
		

select
	a.AgencyID,
	lo.[State],
	lo.SubGroupName,
	x.AlphaCode,
	a.OutletName,
	a.Quadrant,
	x.FY15NonPreferred,
	x.FY15Preferred,
	x.FY16NonPreferred,
	x.FY16Preferred,
	sc.LastCallDate,
	sc.CallComment,
	TotalSalesCall.TotalSalesCalls,
	isnull(ytdsales.SellPrice,0) as SellPrice,
	isnull(ytdsalespy.SellPricePY,0) as SellPricePY,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	@StartDateCQ as StartDateCQ,
	@EndDateCQ as EndDateCQ	
from
	#x x
	outer apply
	(
		select top 1 AgencyID, OutletName, Quadrant
		from sfAccount
		where
			AgencyID = 'AU.CMA.' + x.AlphaCode and
			left(AgencyID,2) = 'AU'
	) a
	cross apply
	(
		select top 1 LatestOutletKey
		from penOutlet
		where 
			'AU.CMA.' + AlphaCode = a.AgencyID and
			OutletStatus = 'Current' and
			CountryKey = 'AU'
	) o
	cross apply
	(
		select top 1 
			LatestOutletKey, 
			AlphaCode, 
			case when StateSalesArea like 'New%' then 'NSW'
				 when StateSalesArea like 'Queen%' then 'QLD'
				 when StateSalesArea like 'South%' then 'SA'
				 when StateSalesArea like 'Australian%' then 'ACT'
				 when StateSalesArea like 'Vic%' then 'VIC'
				 when StateSalesArea like 'Tasm%' then 'TAS'
				 when StateSalesArea like 'Western%' then 'WA'
				 when StateSalesArea like 'North%' then 'NT'
			end as [State], 
			case when SubGroupName like '%helloworld franchise%' then 'Branded'
				 else 'Associate'
			end as SubGroupName
		from penOutlet
		where OutletKey = o.LatestOutletKey and OutletStatus = 'Current'
	) lo
	cross apply
	(
		select top 1
			CallStartTime as LastCallDate,
			CallComment
		from
			sfAgencyCall
		where
			AgencyID = a.AgencyID
		order by
			CallStartTime desc
	) sc
	cross apply
	(
		select count(distinct CallID) as TotalSalesCalls
		from
			sfAgencyCall
		where
			AgencyID = a.AgencyID and
			(
				CallCategory in ('Activity - AL Meetings','Activity - AM Call','Activity - In-store visit','Activity - Meetings','Activity - One on One','Activity - TL/ATL','Training - AM/PM Session','Activity - AM/PM Training','Training - Cluster Session (F2F)') or
				(
					(CallCategory = 'Core' and CallSubCategory = 'Agency Visit') or
					(CallCategory = 'Focus' and CallSubCategory in ('Agency Visit','One on One')) or
					(CallCategory = 'Sales Call' and CallSubCategory in ('Agency Visit', 'One on One')) or
					(CallCategory = 'X - Head Office Hours (Do Not Use)' and CallSubCategory in ('Group Training', 'SWOT Meeting')) or
					(CallCategory = 'X - Sales Call (Do Not Use)' and CallSubCategory in ('Agency Visit', 'One on One', 'Training'))
				) 
			) and
			CallStartTime >= @StartDateCQ and
			CallStartTime < dateadd(d,1,@EndDateCQ)
	) TotalSalesCall
	outer apply
	(
		select sum(GrossPremium) as SellPrice
		from
			penOutlet oo
			inner join penPolicyTransSummary pt on oo.OutletAlphaKey = pt.OutletAlphaKey and oo.OutletStatus = 'Current'
		where
			oo.AlphaCode = x.AlphaCode and
			oo.CountryKey = 'AU' and
			pt.PostingDate >= @StartDateCY and
			pt.PostingDate <= @EndDateCY and
			oo.LatestOutletKey = lo.LatestOutletKey
	) ytdsales
	outer apply
	(
		select sum(GrossPremium) as SellPricePY
		from
			penOutlet oo
			inner join penPolicyTransSummary pt on oo.OutletAlphaKey = pt.OutletAlphaKey and oo.OutletStatus = 'Current'
		where
			oo.AlphaCode = x.AlphaCode and
			oo.CountryKey = 'AU' and
			pt.PostingDate >= @StartDatePY and
			pt.PostingDate <= @EndDatePY and
			oo.LatestOutletKey = lo.LatestOutletKey
	) ytdsalespy	
GO
