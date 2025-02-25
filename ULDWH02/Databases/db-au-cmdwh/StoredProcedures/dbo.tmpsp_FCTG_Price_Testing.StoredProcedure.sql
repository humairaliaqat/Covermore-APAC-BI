USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[tmpsp_FCTG_Price_Testing]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmpsp_FCTG_Price_Testing]	@DateRange varchar(30),
												@StartDate date,
												@EndDate date
as 


/****************************************************************************************************/
--  Name:           dbo.tmpsp_FCTG_Price_Testing
--  Author:         Linus Tor
--  Date Created:   20161011
--  Description:    This stored procedure return policy count and sales for trial and control alphas
--					Used for testing promo code effectiveness (TestPol10, TestPol15)
--  Parameters:     @DateRange: required. standard date range
--					@StartDate: optional. only required if DateRange = _User Defined
--					@EndDate: optional. only required if DateRange = _User Defined
--
--  Change History: 
--                  20161011 - LT - Created
--
/****************************************************************************************************/

set nocount on

--Uncomment to debug
/*
Declare
    @DateRange varchar(30),
    @StartDate date,
    @EndDate date
Select 
    @DateRange = 'Month-To-Date',
    @StartDate = null,
	@EndDate = null
*/

declare
    @rptStartDate datetime,
    @rptEndDate datetime

if @DateRange = '_User Defined'
    select
        @rptStartDate = @StartDate,
        @rptEndDate = @EndDate
else
    select
        @rptStartDate = StartDate,
        @rptEndDate = EndDate
    from
        vDateRange
    where
        DateRange = @DateRange


--store trial and control alphas
if object_id('tempdb..#x') is not null drop table #x
create table #x
(
	AlphaCode varchar(50) null,
	AlphaType varchar(50) null,
	[Order] varchar(5) null
)

insert #x values('FLN1395','ControlGroup02','9199')
insert #x values('FLV0883','ControlGroup02','9199')
insert #x values('FLQ0187','ControlGroup02','9199')
insert #x values('FLQ0181','ControlGroup02','9199')
insert #x values('FLQ1757','ControlGroup02','9199')
insert #x values('FLQ1791','ControlGroup02','9199')
insert #x values('FLQ0180','ControlGroup02','9199')
insert #x values('FLQ0250','ControlGroup02','9199')
insert #x values('FLQ1731','ControlGroup02','9199')
insert #x values('FLW0110','ControlGroup02','9199')
insert #x values('FLV0868','ControlGroup02','9199')
insert #x values('FLV0961','ControlGroup02','9199')
insert #x values('FLN0051','ControlGroup02','9199')
insert #x values('FLV0254','ControlGroup02','9199')
insert #x values('FLV0964','ControlGroup02','9199')
insert #x values('FLV0700','ControlGroup02','9199')
insert #x values('FLQ1962','ControlGroup02','9199')
insert #x values('FLV0550','ControlGroup02','9199')
insert #x values('FLV0020','ControlGroup02','9199')
insert #x values('FLN1574','ControlGroup02','9199')
insert #x values('FLN1496','ControlGroup02','9199')
insert #x values('FLV0360','ControlGroup02','9199')
insert #x values('FLW0355','ControlGroup02','9199')
insert #x values('FLQ0720','ControlGroup02','9199')
insert #x values('FLS0522','ControlGroup02','9199')
insert #x values('FLV0887','ControlGroup02','9199')
insert #x values('FLW0903','ControlGroup02','9199')
insert #x values('FLN1814','ControlGroup02','9199')
insert #x values('FLW0300','ControlGroup02','9199')
insert #x values('FLQ0820','ControlGroup02','9199')
insert #x values('FLQ1787','ControlGroup02','9199')
insert #x values('FLW0410','ControlGroup02','9199')
insert #x values('FLS0450','ControlGroup02','9199')
insert #x values('FLW0904','ControlGroup02','9199')
insert #x values('FLQ0187','ControlGroup03','9299')
insert #x values('FLQ0181','ControlGroup03','9299')
insert #x values('FLW0966','ControlGroup03','9299')
insert #x values('FLQ1791','ControlGroup03','9299')
insert #x values('FLN1463','ControlGroup03','9299')
insert #x values('FLW0550','ControlGroup03','9299')
insert #x values('FLN1415','ControlGroup03','9299')
insert #x values('FLQ0450','ControlGroup03','9299')
insert #x values('FLA0400','ControlGroup03','9299')
insert #x values('FLV0868','ControlGroup03','9299')
insert #x values('FLV0961','ControlGroup03','9299')
insert #x values('FLN1492','ControlGroup03','9299')
insert #x values('FLN1447','ControlGroup03','9299')
insert #x values('FLV0020','ControlGroup03','9299')
insert #x values('FLN1574','ControlGroup03','9299')
insert #x values('FLW0022','ControlGroup03','9299')
insert #x values('FLW0355','ControlGroup03','9299')
insert #x values('FLQ0720','ControlGroup03','9299')
insert #x values('FLW0902','ControlGroup03','9299')
insert #x values('FLN1527','ControlGroup03','9299')
insert #x values('FLS0522','ControlGroup03','9299')
insert #x values('FLW0903','ControlGroup03','9299')
insert #x values('FLN1814','ControlGroup03','9299')
insert #x values('FLV1074','ControlGroup03','9299')
insert #x values('FLV0962','ControlGroup03','9299')
insert #x values('FLS0450','ControlGroup03','9299')
insert #x values('FLN1547','ControlGroup03','9299')
insert #x values('FLW0904','ControlGroup03','9299')
insert #x values('FLN1480','ControlGroup03','9299')
insert #x values('FLV0125','ControlGroup04','9399')
insert #x values('FLQ0187','ControlGroup04','9399')
insert #x values('FLW0966','ControlGroup04','9399')
insert #x values('FLQ1791','ControlGroup04','9399')
insert #x values('FLQ0250','ControlGroup04','9399')
insert #x values('FLW0550','ControlGroup04','9399')
insert #x values('FLN1415','ControlGroup04','9399')
insert #x values('FLN0105','ControlGroup04','9399')
insert #x values('FLN0125','ControlGroup04','9399')
insert #x values('FLQ1774','ControlGroup04','9399')
insert #x values('FLN1755','ControlGroup04','9399')
insert #x values('FLV0858','ControlGroup04','9399')
insert #x values('FLO0150','ControlGroup04','9399')
insert #x values('FLN1447','ControlGroup04','9399')
insert #x values('FLV0020','ControlGroup04','9399')
insert #x values('FLW0022','ControlGroup04','9399')
insert #x values('FLW0125','ControlGroup04','9399')
insert #x values('FLV0409','ControlGroup04','9399')
insert #x values('FLV0958','ControlGroup04','9399')
insert #x values('FLQ0720','ControlGroup04','9399')
insert #x values('FLN1150','ControlGroup04','9399')
insert #x values('FLW0902','ControlGroup04','9399')
insert #x values('FLN1527','ControlGroup04','9399')
insert #x values('FLS0522','ControlGroup04','9399')
insert #x values('FLN0655','ControlGroup04','9399')
insert #x values('FLN1205','ControlGroup04','9399')
insert #x values('FLN0660','ControlGroup04','9399')
insert #x values('FLN1547','ControlGroup04','9399')
insert #x values('FLN1480','ControlGroup04','9399')
insert #x values('FLQ0187','ControlGroup05','9499')
insert #x values('FLW0966','ControlGroup05','9499')
insert #x values('FLQ0190','ControlGroup05','9499')
insert #x values('FLN1100','ControlGroup05','9499')
insert #x values('FLW0550','ControlGroup05','9499')
insert #x values('FLN1417','ControlGroup05','9499')
insert #x values('FLN1488','ControlGroup05','9499')
insert #x values('FLQ1774','ControlGroup05','9499')
insert #x values('FLN1696','ControlGroup05','9499')
insert #x values('FLN1492','ControlGroup05','9499')
insert #x values('FLN1447','ControlGroup05','9499')
insert #x values('FLV1065','ControlGroup05','9499')
insert #x values('FLV0957','ControlGroup05','9499')
insert #x values('FLN1773','ControlGroup05','9499')
insert #x values('FLV0020','ControlGroup05','9499')
insert #x values('FLN1722','ControlGroup05','9499')
insert #x values('FLN0415','ControlGroup05','9499')
insert #x values('FLW0902','ControlGroup05','9499')
insert #x values('FLS0300','ControlGroup05','9499')
insert #x values('FLS0522','ControlGroup05','9499')
insert #x values('FLS0450','ControlGroup05','9499')
insert #x values('FLN0655','ControlGroup05','9499')
insert #x values('FLV0580','ControlGroup05','9499')
insert #x values('FLN1547','ControlGroup05','9499')
insert #x values('FLQ1766','ControlGroup05','9499')
insert #x values('FLN1480','ControlGroup05','9499')
insert #x values('FLN0025','ControlGroup06','9599')
insert #x values('FLQ0054','ControlGroup06','9599')
insert #x values('FLN0030','ControlGroup06','9599')
insert #x values('FLV0950','ControlGroup06','9599')
insert #x values('FLQ0187','ControlGroup06','9599')
insert #x values('FLN1415','ControlGroup06','9599')
insert #x values('FLV0868','ControlGroup06','9599')
insert #x values('FLN1755','ControlGroup06','9599')
insert #x values('FLV0858','ControlGroup06','9599')
insert #x values('FLQ1847','ControlGroup06','9599')
insert #x values('FLN1560','ControlGroup06','9599')
insert #x values('FLN1447','ControlGroup06','9599')
insert #x values('FLQ1995','ControlGroup06','9599')
insert #x values('FLQ0875','ControlGroup06','9599')
insert #x values('FLW0983','ControlGroup06','9599')
insert #x values('FLN1574','ControlGroup06','9599')
insert #x values('FLV0257','ControlGroup06','9599')
insert #x values('FLV0360','ControlGroup06','9599')
insert #x values('FLA0457','ControlGroup06','9599')
insert #x values('FLV0958','ControlGroup06','9599')
insert #x values('FLW0355','ControlGroup06','9599')
insert #x values('FLS0494','ControlGroup06','9599')
insert #x values('FLN1150','ControlGroup06','9599')
insert #x values('FLQ1787','ControlGroup06','9599')
insert #x values('FLW0410','ControlGroup06','9599')
insert #x values('FLN0655','ControlGroup06','9599')
insert #x values('FLN1205','ControlGroup06','9599')
insert #x values('FLN1416','ControlGroup06','9599')
insert #x values('FLW0600','ControlGroup06','9599')
insert #x values('FLQ0187','ControlGroup07','9699')
insert #x values('FLQ1791','ControlGroup07','9699')
insert #x values('FLN1463','ControlGroup07','9699')
insert #x values('FLW0550','ControlGroup07','9699')
insert #x values('FLN1415','ControlGroup07','9699')
insert #x values('FLQ0450','ControlGroup07','9699')
insert #x values('FLV0868','ControlGroup07','9699')
insert #x values('FLV0961','ControlGroup07','9699')
insert #x values('FLV0030','ControlGroup07','9699')
insert #x values('FLN0051','ControlGroup07','9699')
insert #x values('FLN1492','ControlGroup07','9699')
insert #x values('FLW1019','ControlGroup07','9699')
insert #x values('FLV0020','ControlGroup07','9699')
insert #x values('FLN1574','ControlGroup07','9699')
insert #x values('FLW0022','ControlGroup07','9699')
insert #x values('FLW0355','ControlGroup07','9699')
insert #x values('FLQ0720','ControlGroup07','9699')
insert #x values('FLN1527','ControlGroup07','9699')
insert #x values('FLS0522','ControlGroup07','9699')
insert #x values('FLW0903','ControlGroup07','9699')
insert #x values('FLN1814','ControlGroup07','9699')
insert #x values('FLV1074','ControlGroup07','9699')
insert #x values('FLV0962','ControlGroup07','9699')
insert #x values('FLW0590','ControlGroup07','9699')
insert #x values('FLW0904','ControlGroup07','9699')
insert #x values('FLN1480','ControlGroup07','9699')
insert #x values('FLN0030','ControlGroup08','9799')
insert #x values('FLV0029','ControlGroup08','9799')
insert #x values('FLN1395','ControlGroup08','9799')
insert #x values('FLN1445','ControlGroup08','9799')
insert #x values('FLQ0187','ControlGroup08','9799')
insert #x values('FLQ1757','ControlGroup08','9799')
insert #x values('FLQ0180','ControlGroup08','9799')
insert #x values('FLQ1731','ControlGroup08','9799')
insert #x values('FLW0110','ControlGroup08','9799')
insert #x values('FLN0125','ControlGroup08','9799')
insert #x values('FLV0961','ControlGroup08','9799')
insert #x values('FLQ1993','ControlGroup08','9799')
insert #x values('FLV1127','ControlGroup08','9799')
insert #x values('FLN0051','ControlGroup08','9799')
insert #x values('FLQ1959','ControlGroup08','9799')
insert #x values('FLS0566','ControlGroup08','9799')
insert #x values('FLV0700','ControlGroup08','9799')
insert #x values('FLQ1962','ControlGroup08','9799')
insert #x values('FLV0020','ControlGroup08','9799')
insert #x values('FLV0360','ControlGroup08','9799')
insert #x values('FLQ0720','ControlGroup08','9799')
insert #x values('FLN1150','ControlGroup08','9799')
insert #x values('FLN1326','ControlGroup08','9799')
insert #x values('FLQ0820','ControlGroup08','9799')
insert #x values('FLQ1787','ControlGroup08','9799')
insert #x values('FLW0410','ControlGroup08','9799')
insert #x values('FLA0453','ControlGroup08','9799')
insert #x values('FLQ0187','ControlGroup09','9899')
insert #x values('FLQ0181','ControlGroup09','9899')
insert #x values('FLW0966','ControlGroup09','9899')
insert #x values('FLQ0180','ControlGroup09','9899')
insert #x values('FLQ0250','ControlGroup09','9899')
insert #x values('FLN1463','ControlGroup09','9899')
insert #x values('FLQ0450','ControlGroup09','9899')
insert #x values('FLN0105','ControlGroup09','9899')
insert #x values('FLV0868','ControlGroup09','9899')
insert #x values('FLQ1774','ControlGroup09','9899')
insert #x values('FLN1492','ControlGroup09','9899')
insert #x values('FLW1019','ControlGroup09','9899')
insert #x values('FLV0020','ControlGroup09','9899')
insert #x values('FLQ1800','ControlGroup09','9899')
insert #x values('FLN0415','ControlGroup09','9899')
insert #x values('FLQ0720','ControlGroup09','9899')
insert #x values('FLA0450','ControlGroup09','9899')
insert #x values('FLN1150','ControlGroup09','9899')
insert #x values('FLW0135','ControlGroup09','9899')
insert #x values('FLW0902','ControlGroup09','9899')
insert #x values('FLW0903','ControlGroup09','9899')
insert #x values('FLS0450','ControlGroup09','9899')
insert #x values('FLN1547','ControlGroup09','9899')
insert #x values('FLQ1766','ControlGroup09','9899')
insert #x values('FLW0904','ControlGroup09','9899')
insert #x values('FLQ0187','ControlGroup10','9999')
insert #x values('FLQ0190','ControlGroup10','9999')
insert #x values('FLW0550','ControlGroup10','9999')
insert #x values('FLN1415','ControlGroup10','9999')
insert #x values('FLQ0450','ControlGroup10','9999')
insert #x values('FLN1755','ControlGroup10','9999')
insert #x values('FLV0858','ControlGroup10','9999')
insert #x values('FLN0051','ControlGroup10','9999')
insert #x values('FLV0964','ControlGroup10','9999')
insert #x values('FLN1492','ControlGroup10','9999')
insert #x values('FLN1773','ControlGroup10','9999')
insert #x values('FLV0020','ControlGroup10','9999')
insert #x values('FLN1574','ControlGroup10','9999')
insert #x values('FLQ1730','ControlGroup10','9999')
insert #x values('FLV0919','ControlGroup10','9999')
insert #x values('FLN0415','ControlGroup10','9999')
insert #x values('FLN1527','ControlGroup10','9999')
insert #x values('FLS0522','ControlGroup10','9999')
insert #x values('FLW0903','ControlGroup10','9999')
insert #x values('FLN1814','ControlGroup10','9999')
insert #x values('FLQ0820','ControlGroup10','9999')
insert #x values('FLV0892','ControlGroup10','9999')
insert #x values('FLS0450','ControlGroup10','9999')
insert #x values('FLN0655','ControlGroup10','9999')
insert #x values('FLN1205','ControlGroup10','9999')
insert #x values('FLN1547','ControlGroup10','9999')
insert #x values('FLN1480','ControlGroup10','9999')
insert #x values('FLN1319','TrialGroup02','9198')
insert #x values('FLN1317','TrialGroup03','9298')
insert #x values('FLW0350','TrialGroup04','9398')
insert #x values('FLW1019','TrialGroup05','9498')
insert #x values('FLV0640','TrialGroup06','9598')
insert #x values('FLN1468','TrialGroup07','9698')
insert #x values('FLN0599','TrialGroup08','9798')
insert #x values('FLQ1746','TrialGroup09','9898')
insert #x values('FLV1014','TrialGroup10','9998')



--get trial and control alpha current year metrics
if object_id('tempdb..#cy_control') is not null drop table #cy_control
select
	o.AlphaCode,  
	o.OutletName,
	sum(pts.InternationalPolicyCount) as PolicyCountINT,
	sum(pts.DomesticPolicyCount) as PolicyCountDOM,
	sum(case when p.AreaType = 'International' then pts.GrossPremium else 0 end) as SellPriceINT,
	sum(case when p.AreaType = 'Domestic' then pts.GrossPremium else 0 end) as SellPriceDOM,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.InternationalPolicyCount else 0 end) as PolicyCountPromoINT,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.DomesticPolicyCount else 0 end) as PolicyCountPromoDOM
into #cy_control
from
	penPolicy p
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(
		select top 1 PromoCode
		from penPolicyTransactionPromo
		where 
			PolicyTransactionKey = pts.PolicyTransactionKey and
			PromoCode in ('TestPol10','TestPol15')
	) promo
where
	o.CountryKey = 'AU' and
	o.SuperGroupName = 'Flight Centre' and
	o.EGMNation = 'Flight Centre Brand' and
	pts.PostingDate between @rptStartDate and @rptEndDate
group by
	o.AlphaCode,
	o.OutletName

--get trial and control alpha prior year metrics
if object_id('tempdb..#py_control') is not null drop table #py_control
select
	o.AlphaCode,  
	o.OutletName,
	sum(pts.InternationalPolicyCount) as PolicyCountINT,
	sum(pts.DomesticPolicyCount) as PolicyCountDOM,
	sum(case when p.AreaType = 'International' then pts.GrossPremium else 0 end) as SellPriceINT,
	sum(case when p.AreaType = 'Domestic' then pts.GrossPremium else 0 end) as SellPriceDOM,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.InternationalPolicyCount else 0 end) as PolicyCountPromoINT,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.DomesticPolicyCount else 0 end) as PolicyCountPromoDOM
into #py_control
from
	penPolicy p
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(
		select top 1 PromoCode
		from penPolicyTransactionPromo
		where 
			PolicyTransactionKey = pts.PolicyTransactionKey and
			PromoCode in ('TestPol10','TestPol15')
	) promo
where
	o.CountryKey = 'AU' and
	o.SuperGroupName = 'Flight Centre' and
	o.EGMNation = 'Flight Centre Brand' and
	pts.YAGOPostingDate between @rptStartDate and @rptEndDate
group by
	o.AlphaCode,
	o.OutletName


--get nation current year metrics
if object_id('tempdb..#cy_all') is not null drop table #cy_all
select
	o.FCNation,
	sum(pts.InternationalPolicyCount) as PolicyCountINT,
	sum(pts.DomesticPolicyCount) as PolicyCountDOM,
	sum(case when p.AreaType = 'International' then pts.GrossPremium else 0 end) as SellPriceINT,
	sum(case when p.AreaType = 'Domestic' then pts.GrossPremium else 0 end) as SellPriceDOM,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.InternationalPolicyCount else 0 end) as PolicyCountPromoINT,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.DomesticPolicyCount else 0 end) as PolicyCountPromoDOM
into #cy_all
from
	penPolicy p
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(
		select top 1 PromoCode
		from penPolicyTransactionPromo
		where 
			PolicyTransactionKey = pts.PolicyTransactionKey and
			PromoCode in ('TestPol10','TestPol15')
	) promo
where
	o.CountryKey = 'AU' and
	o.SuperGroupName = 'Flight Centre' and
	o.FCNation in ('Escape Travel','Heartland','IntrepidMAS','SANT','Travel Associates','VIC Mania','WA','NSW/ACT','7th Wonder') and
	pts.PostingDate between @rptStartDate and @rptEndDate
group by
	o.FCNation


--get nation prior year metrics
if object_id('tempdb..#py_all') is not null drop table #py_all
select
	o.FCNation,
	sum(pts.InternationalPolicyCount) as PolicyCountINT,
	sum(pts.DomesticPolicyCount) as PolicyCountDOM,
	sum(case when p.AreaType = 'International' then pts.GrossPremium else 0 end) as SellPriceINT,
	sum(case when p.AreaType = 'Domestic' then pts.GrossPremium else 0 end) as SellPriceDOM,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.InternationalPolicyCount else 0 end) as PolicyCountPromoINT,
	sum(case when isnull(promo.PromoCode,'') > '' then pts.DomesticPolicyCount else 0 end) as PolicyCountPromoDOM
into #py_all
from
	penPolicy p
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(
		select top 1 PromoCode
		from penPolicyTransactionPromo
		where 
			PolicyTransactionKey = pts.PolicyTransactionKey and
			PromoCode in ('TestPol10','TestPol15')
	) promo
where
	o.CountryKey = 'AU' and
	o.SuperGroupName = 'Flight Centre' and
	o.FCNation in ('Escape Travel','Heartland','IntrepidMAS','SANT','Travel Associates','VIC Mania','WA','NSW/ACT','7th Wonder') and
	pts.YAGOPostingDate between @rptStartDate and @rptEndDate
group by
	o.FCNation



--combine trial and control alpha output data set
if object_id('tempdb..#controltmp') is not null drop table #controltmp
select
	convert(varchar(50),x.AlphaCode) as AlphaCode,
	convert(varchar(100),x.AlphaType) as AlphaType,
	convert(int,x.[Order]) as [Order],
	convert(varchar(200),o.OutletName) as OutletName,
	cy.PolicyCountDOM,
	cy.PolicyCountINT,
	cy.PolicyCountPromoDOM,
	cy.PolicyCountPromoINT,
	cy.SellPriceDOM,
	cy.SellPriceINT,
	py.PolicyCountDOM as PolicyCountDOMPY,
	py.PolicyCountINT as PolicyCountINTPY,
	py.PolicyCountPromoDOM as PolicyCountPromoDOMPY,
	py.PolicyCountPromoINT as PolicyCountPromoINTPY,
	py.SellPriceDOM as SellPriceDOMPY,
	py.SellPriceINT as SellPriceINTPY
into #controltmp
from
	#x x
	cross apply
	(
		select top 1 OutletName
		from penOutlet
		where OutletStatus = 'Current' and AlphaCode = x.AlphaCode
	) o
	outer apply
	(
		select top 1
			PolicyCountINT,
			PolicyCountDOM,
			SellPriceINT,
			SellPriceDOM,
			PolicyCountPromoINT,
			PolicyCountPromoDOM
		from #cy_control
		where AlphaCode = x.AlphaCode
	) cy
	outer apply
	(
		select top 1
			PolicyCountINT,
			PolicyCountDOM,
			SellPriceINT,
			SellPriceDOM,
			PolicyCountPromoINT,
			PolicyCountPromoDOM
		from #py_control
		where AlphaCode = x.AlphaCode
	) py


--insert Trial alpha metrics
if object_id('tempdb..#control') is not null drop table #control
select
	a.AlphaCode,
	a.AlphaType,
	a.[Order],
	a.OutletName,
	a.PolicyCountDOM as PolicyCountDOM,
	a.PolicyCountINT as PolicyCountINT,
	a.PolicyCountPromoDOM as PolicyCountPromoDOM,
	a.PolicyCountPromoINT as PolicyCountPromoINT,
	a.SellPriceDOM as SellPriceDOM,
	a.SellPriceINT as SellPriceINT,
	a.PolicyCountDOMPY as PolicyCountDOMPY,
	a.PolicyCountINTPY as PolicyCountINTPY,
	a.PolicyCountPromoDOMPY as PolicyCountPromoDOMPY,
	a.PolicyCountPromoINTPY as PolicyCountPromoINTPY,
	a.SellPriceDOMPY as SellPriceDOMPY,
	a.SellPriceINTPY as SellPriceINTPY
into #control
from #controltmp a
where a.AlphaType like 'Trial%'

--insert control alpha metrics
insert #control
select 
	'' as AlphaCode,
	b.AlphaType,
	b.[Order],
	'' as [OutletName],
	sum(b.PolicyCountDOM) as PolicyCountDOM,
	sum(b.PolicyCountINT) as PolicyCountINT,
	sum(b.PolicyCountPromoDOM) as PolicyCountPromoDOM,
	sum(b.PolicyCountPromoINT) as PolicyCountPromoINT,
	sum(b.SellPriceDOM) as SellPriceDOM,
	sum(b.SellPriceINT) as SellPriceINT,
	sum(b.PolicyCountDOMPY) as PolicyCountDOMPY,
	sum(b.PolicyCountINTPY) as PolicyCountINTPY,
	sum(b.PolicyCountPromoDOMPY) as PolicyCountPromoPY,
	sum(b.PolicyCountPromoINTPY) as PolicyCountPromoPY,
	sum(b.SellPriceDOMPY) as SellPriceDOMPY,
	sum(b.SellPriceINTPY) as SellPriceINTPY
from
	#controltmp b
where
	b.AlphaType like 'Control%'
group by
	b.AlphaType,
	b.[Order]	

--insert total trail metrics
insert #control
select 
	'' as AlphaCode,
	'Total Trial group' as AlphaType,
	'10000' as [Order],
	'' as [OutletName],
	sum(a.PolicyCountDOM) as PolicyCountDOM,
	sum(a.PolicyCountINT) as PolicyCountINT,
	sum(a.PolicyCountPromoDOM) as PolicyCountPromoDOM,
	sum(a.PolicyCountPromoINT) as PolicyCountPromoINT,
	sum(a.SellPriceDOM) as SellPriceDOM,
	sum(a.SellPriceINT) as SellPriceINT,
	sum(a.PolicyCountDOMPY) as PolicyCountDOMPY,
	sum(a.PolicyCountINTPY) as PolicyCountINTPY,
	sum(a.PolicyCountPromoDOMPY) as PolicyCountPromoPY,
	sum(a.PolicyCountPromoINTPY) as PolicyCountPromoPY,
	sum(a.SellPriceDOMPY) as SellPriceDOMPY,
	sum(a.SellPriceINTPY) as SellPriceINTPY
from
	#control a
where
	AlphaType like 'Trial%'


--insert total control metrics
insert #control
select 
	'' as AlphaCode,
	'Total all control groups' as AlphaType,
	'10001' as [Order],
	'' as [OutletName],
	sum(b.PolicyCountDOM) as PolicyCountDOM,
	sum(b.PolicyCountINT) as PolicyCountINT,
	sum(b.PolicyCountPromoDOM) as PolicyCountPromoDOM,
	sum(b.PolicyCountPromoINT) as PolicyCountPromoINT,
	sum(b.SellPriceDOM) as SellPriceDOM,
	sum(b.SellPriceINT) as SellPriceINT,
	sum(b.PolicyCountDOMPY) as PolicyCountDOMPY,
	sum(b.PolicyCountINTPY) as PolicyCountINTPY,
	sum(b.PolicyCountPromoDOMPY) as PolicyCountPromoPY,
	sum(b.PolicyCountPromoINTPY) as PolicyCountPromoPY,
	sum(b.SellPriceDOMPY) as SellPriceDOMPY,
	sum(b.SellPriceINTPY) as SellPriceINTPY
from
	#control a
	outer apply
	(
		select distinct
			AlphaCode,
			PolicyCountDOM,
			PolicyCountINT,
			PolicyCountPromoDOM,
			PolicyCountPromoINT,
			SellPriceDOM,
			SellPriceINT,
			PolicyCountDOMPY,
			PolicyCountINTPY,
			PolicyCountPromoDOMPY,
			PolicyCountPromoINTPY,
			SellPriceDOMPY,
			SellPriceINTPY			
		from
			#control
		where 
			AlphaType like 'Control%'
	) b


--insert total nation metrics	
insert #control
select
	a.AlphaCode,
	a.AlphaType,
	a.[Order],
	a.OutletName,
	sum(a.PolicyCountDOM) as PolicyCountDOM,
	sum(a.PolicyCountINT) as PolicyCountINT,
	sum(a.PolicyCountPromoDOM) as PolicyCountPromoDOM,
	sum(a.PolicyCountPromoINT) as PolicyCountPromoINT,
	sum(a.SellPriceDOM) as SellPriceDOM,
	sum(a.SellPriceINT) as SellPriceINT,
	sum(a.PolicyCountDOMPY) as PolicyCountDOMPY,
	sum(a.PolicyCountINTPY) as PolicyCountINTPY,
	sum(a.PolicyCountPromoDOMPY) as PolicyCountPromoDOMPY,
	sum(a.PolicyCountPromoINTPY) as PolicyCountPromoINTPY,
	sum(a.SellPriceDOMPY) as SellPriceDOMPY,
	sum(a.SellPriceINTPY) as SellPriceINTPY
from
(
	select
		'' as AlphaCode,
		FCNation as AlphaType,
		20000 as [Order],
		'' as [OutletName],
		PolicyCountDOM,
		PolicyCountINT,
		PolicyCountPromoDOM,
		PolicyCountPromoINT,
		SellPriceDOM,
		SellPriceINT,
		0 as PolicyCountDOMPY,
		0 as PolicyCountINTPY,
		0 as PolicyCountPromoDOMPY,
		0 as PolicyCountPromoINTPY,
		0 as SellPriceDOMPY,
		0 as SellPriceINTPY	
	from 
		#cy_all

	union all

	select
		'' as AlphaCode,
		FCNation as AlphaType,
		20000 as [Order],
		'' as [OutletName],
		0 as PolicyCountDOM,
		0 as PolicyCountINT,
		0 as PolicyCountPromoDOM,
		0 as PolicyCountPromoINT,
		0 as SellPriceDOM,
		0 as SellPriceINT,
		PolicyCountDOM,
		PolicyCountINT,
		PolicyCountPromoDOM,
		PolicyCountPromoINT,
		SellPriceDOM,
		SellPriceINT	
	from 
		#py_all
) a
group by
	a.AlphaCode,
	a.AlphaType,
	a.[Order],
	a.OutletName
order by a.AlphaCode


--final output for Crystal Reports
select 
	a.AlphaCode,
	a.AlphaType,
	a.[Order],
	a.OutletName,
	a.PolicyCountDOM as PolicyCountDOM,
	a.PolicyCountINT as PolicyCountINT,
	a.PolicyCountPromoDOM as PolicyCountPromoDOM,
	a.PolicyCountPromoINT as PolicyCountPromoINT,
	a.SellPriceDOM as SellPriceDOM,
	a.SellPriceINT as SellPriceINT,
	a.PolicyCountDOMPY as PolicyCountDOMPY,
	a.PolicyCountINTPY as PolicyCountINTPY,
	a.PolicyCountPromoDOMPY as PolicyCountPromoDOMPY,
	a.PolicyCountPromoINTPY as PolicyCountPromoINTPY,
	a.SellPriceDOMPY as SellPriceDOMPY,
	a.SellPriceINTPY as SellPriceINTPY,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from 
	#control a
order by [Order], AlphaCode



drop table #control
drop table #cy_control
drop table #py_control
drop table #cy_all
drop table #py_all
GO
