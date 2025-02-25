USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL085_Data_Reconciliation_Stage_Source]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [etlsp_ETL085_Data_Reconciliation_Stage] 'Penguin','AU',0,'2023-01-01','2023-03-28'

-- =============================================      
-- Author:  Vincent Lam      
-- Create date: 2017-06-27      
-- Description: Stage data from different sources for comparison.      
-- =============================================      
CREATE PROCEDURE [dbo].[etlsp_ETL085_Data_Reconciliation_Stage_Source]       
 -- Add the parameters for the stored procedure here      
 @SubjectArea varchar(50) = 'Penguin',       
 @Server varchar(10),       
 @FromSnapshot tinyint = 1,       
 @PeriodStart date,      
 @PeriodEnd date       
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
 declare       
  @LinkedServer varchar(50),      
  @SQLtemp varchar(max),      
  @SQL varchar(max),      
  @Countries varchar(1000) = null      
      
 if @Server = 'AU' set @Countries = 'not in (''UK'', ''US'')'      
 if @Server = 'UK' set @Countries = '= ''UK'''      
 if @Server = 'US' set @Countries = '= ''US'''      
      
 if @FromSnapshot = 1       
  set @LinkedServer = 'BHDWH03\SNAPSHOT'      
 else       
  if @SubjectArea = 'Penguin'       
   begin      
    --if @Server = 'AU' set @LinkedServer = 'ULSQLAGR03'  
    if @Server = 'AU' set @LinkedServer = 'DB-AU-PENGUINSHARP.AUST.COVERMORE.COM.AU'      
    if @Server = 'UK' set @LinkedServer = 'SQLIREPRODAGL01'      
    if @Server = 'US' set @LinkedServer = 'AZUSSQL02'      
   end      
      
 -- load data into temp table      
 if object_id('tempdb..##dr_raw') is not null drop table ##dr_raw      
      
 if @SubjectArea = 'Penguin'       
 begin      
      
  create table ##dr_raw (      
   Src varchar(30),       
   CountryCode varchar(10),       
   OutletAlphaKey varchar(50),       
   PolicyKey nvarchar(50),       
   PolicyTransactionKey nvarchar(50),       
   TransactionDateTimeLocal datetime2,       
   TransactionDateTimeUTC datetime2,       
   TimeZoneCode varchar(50),       
   TransactionType nvarchar(50),       
   TransactionStatus nvarchar(50),       
   GrossPremium money,      
   CommissionAndAdminFee money,      
   AddOnPremium money,      
   PrimaryCountry nvarchar(max),       
   ProductCode nvarchar(50),       
   Area nvarchar(100),       
   PrimaryTravellerCount int,       
   TotalTravellerCount int      
  )      
      
  -- Source      
  set @SQLtemp =       
  'insert into ##dr_raw (      
   Src, CountryCode, OutletAlphaKey, PolicyKey, PolicyTransactionKey,       
   TransactionDateTimeLocal, TransactionDateTimeUTC, TimeZoneCode,       
   TransactionType, TransactionStatus,       
   GrossPremium, CommissionAndAdminFee, AddOnPremium,       
   PrimaryCountry, ProductCode, Area,       
   PrimaryTravellerCount, TotalTravellerCount       
  )      
  select * from openquery([@LinkedServer],       
  ''select       
   ''''Source'''', d.countrycode, d.countrycode + ''''-'''' + ''''CM'''' + convert(varchar(10), d.domainid) + ''''-'''' + p.alphacode,       
   d.countrycode + ''''-'''' + ''''CM'''' + convert(varchar(10), d.domainid) + ''''-'''' + convert(varchar(20), p.PolicyID),       
   d.countrycode + ''''-'''' + ''''CM'''' + convert(varchar(10), d.domainid) + ''''-'''' + convert(varchar(20), pt.ID),      
   convert(datetime2, null), convert(datetime2, pt.TransactionDateTime), d.TimeZoneCode,       
   pttype.Type, pts.StatusDescription,       
   pt.GrossPremium,       
   ( isnull(ptt.CommissionAndAdminFee, 0) + isnull(pta.CommissionAndAdminFee, 0) + isnull(pa.CommissionAndAdminFee, 0) + isnull(pe.CommissionAndAdminFee, 0) ),       
   ( isnull(pta.GrossPremium, 0) + isnull(pa.GrossPremium, 0) + isnull(pe.GrossPremium, 0) ),       
   p.PrimaryCountry, prd.ProductCode, p.Area,       
   t.PrimaryTravellerCount, tt.TotalTravellerCount      
  from       
   [@Server_PenguinSharp_Active].dbo.tblPolicyTransaction pt       
   left join [@Server_PenguinSharp_Active].dbo.tblPolicy p on p.PolicyId = pt.PolicyID       
   left join [@Server_PenguinSharp_Active].dbo.tblDomain d on d.DomainId = p.DomainId       
   left join [@Server_PenguinSharp_Active].dbo.tblPolicyDetails pd on pd.PolicyID = pt.PolicyID       
   left join [@Server_PenguinSharp_Active].dbo.tblProduct prd on prd.ProductID = pd.ProductID       
   left join [@Server_PenguinSharp_Active].dbo.tblPolicyTransactionType pttype on pttype.ID = pt.TransactionType       
   left join [@Server_PenguinSharp_Active].dbo.tblPolicyTransactionStatus pts on pts.ID = pt.TransactionStatus       
   outer apply (      
    select      
     sum(isnull(pp.GrossPremium, 0)) as GrossPremium,       
     sum(isnull(pp.Commission, 0) + isnull(pp.GrossAdminFee, 0)) as CommissionAndAdminFee       
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyPrice pp       
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyTravellerTransaction ptt on ptt.ID = pp.ComponentID and pp.GroupID = 2       
    where      
     ptt.PolicyTransactionID = pt.ID       
     and pp.IsPOSDiscount = 1       
   ) ptt -- QuotePlanCustomer      
   outer apply (      
    select       
     sum(isnull(pp.GrossPremium, 0)) as GrossPremium,       
     sum(isnull(pp.Commission, 0) + isnull(pp.GrossAdminFee, 0)) as CommissionAndAdminFee       
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyPrice pp       
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyTravellerAddOn pta on pta.ID = pp.ComponentID and pp.GroupID = 3      
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyTravellerTransaction ptt on ptt.ID = pta.PolicyTravellerTransactionID       
    where      
     ptt.PolicyTransactionID = pt.ID       
     and pp.IsPOSDiscount = 1       
   ) pta -- QuoteCustomerAddOn      
   outer apply (      
    select       
     sum(isnull(pp.GrossPremium, 0)) as GrossPremium,       
     sum(isnull(pp.Commission, 0) + isnull(pp.GrossAdminFee, 0)) as CommissionAndAdminFee       
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyPrice pp       
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyAddOn pa on pa.ID = pp.ComponentID and pp.GroupID = 4       
    where      
     pa.PolicyTransactionID = pt.ID       
     and pp.IsPOSDiscount = 1       
   ) pa -- QuotePlanAddOn      
   outer apply (      
    select       
     sum(isnull(pp.GrossPremium, 0)) as GrossPremium,       
     sum(isnull(pp.Commission, 0) + isnull(pp.GrossAdminFee, 0)) as CommissionAndAdminFee       
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyPrice pp       
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyEMC pe on pe.ID = pp.ComponentID and pp.GroupID = 5       
     inner join [@Server_PenguinSharp_Active].dbo.tblPolicyTravellerTransaction ptt on ptt.ID = pe.PolicyTravellerTransactionID      
    where      
     ptt.PolicyTransactionID = pt.ID       
     and pp.IsPOSDiscount = 1       
   ) pe -- QuoteEMC      
   outer apply (      
    select       
     count(*) as PrimaryTravellerCount      
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyTraveller       
    where      
     PolicyID = pt.PolicyID      
     and IsPrimary = 1       
   ) t      
   outer apply (      
    select       
     count(*) as TotalTravellerCount      
    from       
     [@Server_PenguinSharp_Active].dbo.tblPolicyTraveller       
    where      
     PolicyID = pt.PolicyID      
   ) tt      
  where       
   pt.TransactionDateTime between dateadd(day, -1, ''''@PeriodStart'''') and dateadd(day, 1, ''''@PeriodEnd'''')      
   and p.alphacode not like ''''%TEST%''''      
  '')'      
           
  set @SQL = replace(replace(replace(replace(@SQLtemp, '@LinkedServer', @LinkedServer), '@Server', @Server), '@PeriodStart', @PeriodStart), '@PeriodEnd', @PeriodEnd)      
  exec(@SQL)      
      
  -- TIP      
  if @Server = 'AU'       
   begin       
    set @SQL = replace(replace(replace(replace(replace(@SQLtemp, '''CM''', '''TIP'''), '@LinkedServer', @LinkedServer), '@Server', (@Server + '_TIP')), '@PeriodStart', @PeriodStart), '@PeriodEnd', @PeriodEnd)      
    exec(@SQL)      
   end      
        
      
  ---- ODS      
  --set @SQL =       
  --'      
  --insert into ##dr_raw (      
  -- Src, CountryCode, OutletAlphaKey, PolicyKey, PolicyTransactionKey,       
  -- TransactionDateTimeLocal, TransactionDateTimeUTC, TimeZoneCode,       
  -- TransactionType, TransactionStatus,       
  -- GrossPremium, CommissionAndAdminFee, AddOnPremium,       
  -- PrimaryCountry, ProductCode, Area,       
  -- PrimaryTravellerCount, TotalTravellerCount      
  --)      
  --select      
  -- ''ODS'', pt.CountryKey, pt.OutletAlphaKey, p.PolicyKey, pt.PolicyTransactionKey,       
  -- pt.PostingTime, null, d.TimeZoneCode,       
  -- pt.TransactionType, pt.TransactionStatus,       
  -- pt.GrossPremium, (isnull(pt.Commission, 0) + isnull(pt.GrossAdminFee, 0)), ap.AddOnPremium,       
  -- p.PrimaryCountry, p.ProductCode, p.Area,       
  -- tvlr.PrimaryTravellerCount, pt.TravellersCount       
  --from       
  -- [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)       
  -- left join [db-au-cmdwh]..penPolicy p with(nolock) on p.PolicyKey = pt.PolicyKey       
  -- left join [db-au-cmdwh]..penDomain d on d.DomainKey = p.DomainKey       
  -- --outer apply (      
  -- -- select sum(isnull(Commission, 0) + isnull(GrossAdminFee, 0)) as CommissionAndAdminFee      
  -- -- from [db-au-cmdwh]..penPolicyPrice with(nolock)       
  -- -- where PolicyTransactionID = pt.PolicyTransactionID and CompanyKey = pt.CompanyKey and CountryKey = pt.CountryKey and IsPOSDiscount = 1       
  -- --) pp      
  -- outer apply (      
  --  select sum(GrossPremium) as AddOnPremium      
  --  from [db-au-cmdwh]..penPolicyTransAddOn with(nolock)       
  --  where PolicyTransactionKey = pt.PolicyTransactionKey      
  -- ) ap      
  -- outer apply (      
  --  select count(*) as PrimaryTravellerCount      
  --  from [db-au-cmdwh]..penPolicyTraveller with(nolock)       
  --  where PolicyKey = p.PolicyKey and CountryKey = p.CountryKey and isPrimary = 1       
  -- ) tvlr      
  -- --outer apply (      
  -- -- select count(*) as TotalTravellerCount      
  -- -- from [db-au-cmdwh]..penPolicyTraveller with(nolock)       
  -- -- where PolicyKey = p.PolicyKey and CountryKey = p.CountryKey      
  -- --) ttltvlr      
  --where       
  -- pt.PostingTime between dateadd(day, -1, ''@PeriodStart'') and dateadd(day, 1, ''@PeriodEnd'')       
  -- and pt.OutletAlphaKey not like ''%TEST%''      
  -- and pt.CountryKey ' + @Countries      
      
  --set @SQL = replace(replace(@SQL, '@PeriodStart', @PeriodStart), '@PeriodEnd', @PeriodEnd)      
  --exec(@SQL)      
      
        
  ---- Star      
  --set @SQL =       
  --'      
  --insert into ##dr_raw (      
  -- Src, CountryCode, OutletAlphaKey, PolicyKey, PolicyTransactionKey,       
  -- TransactionDateTimeLocal, TransactionDateTimeUTC, TimeZoneCode,       
  -- TransactionType, TransactionStatus,       
  -- GrossPremium, CommissionAndAdminFee, AddOnPremium,       
  -- PrimaryCountry, ProductCode, Area,       
  -- PrimaryTravellerCount, TotalTravellerCount      
  --)      
  --select      
  -- ''Star'', d.CountryCode, o.OutletAlphaKey, p.PolicyKey, pt.PolicyTransactionKey,       
  -- pt.PostingDate, null, d.TimeZoneCode,       
  -- pt.TransactionType, pt.TransactionStatus,       
  -- pt.SellPrice, (isnull(Commission, 0) + isnull(AdminFee, 0)), null,       
  -- case when pt.DestinationSK = -1 then null else dest.Destination end, pd.ProductCode, case when pt.AreaSK = -1 then null else a.AreaName end,       
  -- t.PrimaryTravellerCount, tt.TotalTravellerCount      
  --from       
  -- [db-au-star]..[factPolicyTransaction] pt with(nolock)       
  -- left join [db-au-star]..dimPolicy p with(nolock) on pt.PolicySK = p.PolicySK       
  -- left join [db-au-star]..dimDomain d on pt.DomainSK = d.DomainSK       
  -- left join [db-au-star]..dimOutlet o on pt.OutletSK = o.OutletSK       
  -- left join [db-au-star]..dimProduct pd with(nolock) on pd.ProductSK = pt.ProductSK       
  -- left join [db-au-star]..dimDestination dest on dest.DestinationSK = pt.DestinationSK       
  -- left join [db-au-star]..dimArea a on a.AreaSK = pt.AreaSK       
  -- outer apply (      
  --  select count(*) as PrimaryTravellerCount      
  --  from [db-au-star]..dimTraveller with(nolock)       
  --  where PolicyKey = p.PolicyKey and isPrimary = 1       
  -- ) t      
  -- outer apply (      
  --  select count(*) as TotalTravellerCount      
  --  from [db-au-star]..dimTraveller with(nolock)       
  --  where PolicyKey = p.PolicyKey      
  -- ) tt      
  --where       
  -- pt.PostingDate between dateadd(day, -1, ''@PeriodStart'') and dateadd(day, 1, ''@PeriodEnd'')       
  -- and o.OutletAlphaKey not like ''%TEST%''       
  -- and p.PolicyKey not like ''%TG%''       
  -- and d.CountryCode ' + @Countries      
      
  --set @SQL = replace(replace(@SQL, '@PeriodStart', @PeriodStart), '@PeriodEnd', @PeriodEnd)      
  --exec(@SQL)      
      
      
  -- update TransactionDateTimeLocal and TransactionDateTimeUTC      
  update ##dr_raw      
  set TransactionDateTimeLocal = [db-au-stage].[dbo].[xfn_ConvertUTCtoLocal](TransactionDateTimeUTC, TimeZoneCode)      
  where TransactionDateTimeLocal is null and TransactionDateTimeUTC is not null and TimeZoneCode is not null      
         
  update ##dr_raw      
  set TransactionDateTimeUTC = [db-au-stage].[dbo].[xfn_ConvertLocaltoUTC](TransactionDateTimeLocal, TimeZoneCode)      
  where TransactionDateTimeUTC is null and TransactionDateTimeLocal is not null and TimeZoneCode is not null      
      
 end -- Penguin      
      
END 
GO
