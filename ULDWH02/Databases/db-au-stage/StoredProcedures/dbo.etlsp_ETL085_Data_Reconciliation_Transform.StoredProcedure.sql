USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL085_Data_Reconciliation_Transform]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Vincent Lam      
-- Create date: 2017-06-28      
-- Description: Transform the data after stage      
-- =============================================      
CREATE PROCEDURE [dbo].[etlsp_ETL085_Data_Reconciliation_Transform]       
 -- Add the parameters for the stored procedure here      
 @SubjectArea varchar(50) = 'Penguin',       
 @Target varchar(200)      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
 -- 1. pivot into | Date | Country | Identifier | Source | ODS | Star | etc.      
      
 if object_id('tempdb..##dr_pivot') is not null drop table ##dr_pivot      
      
    if @SubjectArea = 'Penguin'      
 begin      
      
  create table ##dr_pivot (      
   [Date] date,      
   CountryCode varchar(10),      
   Identifier varchar(50),       
   [Source] money,      
   ODS money,      
   Star money,  
   [Subject] varchar(30)      
  )      
        
  if @Target = 'PolicyID'       
   insert into ##dr_pivot      
   select *,'PolicyID'  
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     count(distinct PolicyKey) as PolicyID      
    from       
     ##dr_raw      
    where       
     TransactionType = 'Base'      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(PolicyID)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'PolicyTransactionID'        
   insert into ##dr_pivot      
   select *,'PolicyTransactionID'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     count(distinct PolicyTransactionKey) as PolicyTransactionKey      
    from       
     ##dr_raw      
    where       
     TransactionType = 'Base'      
     and TransactionStatus = 'Active'      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(PolicyTransactionKey)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'PolicyCount'        
  begin    
   insert into ##dr_pivot      
   select *,'PolicyCount'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(      
      case       
       when TransactionType = 'Base' and TransactionStatus = 'Active' then 1       
       when TransactionType = 'Base' and TransactionStatus like 'Cancelled%' then -1       
       else 0       
      end      
     ) as PolicyCount      
    from       
     ##dr_raw      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(PolicyCount)       
    for Src in (Source, ODS, Star)      
   ) p      
      
  delete p from [db-au-cmdwh]..Policy_count p join ##dr_pivot d  ---newly added for tableau recon report    
  on p.date = d.date and p.CountryCode = d.CountryCode and p.Subject = d.Subject  
      
  insert into [db-au-cmdwh]..Policy_count ---newly added for tableau recon report    
  select * from ##dr_pivot    
      
  end     
    
  if @Target = 'GrossPremium'    
  begin      
   insert into ##dr_pivot      
   select *,'GrossPremium'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(isnull(GrossPremium, 0)) as GrossPremium      
    from       
     ##dr_raw      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(GrossPremium)       
    for Src in (Source, ODS, Star)      
   ) p  
     
   delete p from [db-au-cmdwh]..Policy_count p join ##dr_pivot d  ---newly added for tableau recon report    
  on p.date = d.date and p.CountryCode = d.CountryCode  and p.Subject = d.Subject  
      
  insert into [db-au-cmdwh]..Policy_count ---newly added for tableau recon report    
  select * from ##dr_pivot        
   end   
      
  if @Target = 'Commission + Gross Admin Fee'        
   insert into ##dr_pivot      
   select *,'Commission + Gross Admin Fee'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(isnull(CommissionAndAdminFee, 0)) as CommissionAndAdminFee      
    from       
     ##dr_raw      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(CommissionAndAdminFee)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'AddOnPremium'        
   insert into ##dr_pivot      
   select *,'AddOnPremium'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(isnull(AddOnPremium, 0)) as AddOnPremium      
    from       
     ##dr_raw      
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(AddOnPremium)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'PrimaryCountry'        
   insert into ##dr_pivot      
   select *,'PrimaryCountry'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(f.PrimaryCountry) as PrimaryCountry      
    from       
     ##dr_raw d      
     outer apply (      
      select       
       case       
        when (PrimaryCountry is null or ltrim(rtrim(PrimaryCountry)) = '') then 1      
        else 0      
       end as PrimaryCountry      
      from ##dr_raw       
      where       
       convert(char(10), TransactionDateTimeLocal, 126) = convert(char(10), d.TransactionDateTimeLocal, 126)       
       and CountryCode = d.CountryCode       
       and OutletAlphaKey = d.OutletAlphaKey       
       and PolicyKey = d.PolicyKey       
       and PolicyTransactionKey = d.PolicyTransactionKey       
       and Src = d.Src       
     ) f      
    where      
     TransactionType = 'Base'       
     and TransactionStatus = 'Active'       
     and not (      
      ( ProductCode = 'CMB' and CountryCode = 'AU' )       
      or ( ProductCode = 'CMB' and CountryCode = 'NZ' )       
      or ( ProductCode = 'CMB' and CountryCode = 'UK' )       
      or ( ProductCode = 'ANB' and CountryCode = 'NZ' )       
      or ( ProductCode = 'TMB' and CountryCode = 'UK' )       
     )       
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(PrimaryCountry)      
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'Area'        
   insert into ##dr_pivot      
   select *,'Area'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(f.Area) as Area      
    from       
     ##dr_raw d      
     outer apply (      
      select              case       
        when (Area is null or ltrim(rtrim(Area)) = '') then 1       
        else 0       
       end as Area       
      from ##dr_raw       
      where       
       convert(char(10), TransactionDateTimeLocal, 126) = convert(char(10), d.TransactionDateTimeLocal, 126)       
       and CountryCode = d.CountryCode       
       and OutletAlphaKey = d.OutletAlphaKey       
       and PolicyKey = d.PolicyKey       
       and PolicyTransactionKey = d.PolicyTransactionKey       
       and Src = d.Src       
     ) f       
    where      
     TransactionType = 'Base'       
     and TransactionStatus = 'Active'       
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(Area)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'ProductCode'        
   insert into ##dr_pivot      
   select *,'ProductCode'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(f.ProductCode) as ProductCode      
    from       
     ##dr_raw d       
     outer apply (      
      select       
       case       
        when (ProductCode is null or ltrim(rtrim(ProductCode)) = '') then 1       
        else 0       
       end as ProductCode       
      from ##dr_raw       
      where       
       convert(char(10), TransactionDateTimeLocal, 126) = convert(char(10), d.TransactionDateTimeLocal, 126)       
       and CountryCode = d.CountryCode       
       and OutletAlphaKey = d.OutletAlphaKey       
       and PolicyKey = d.PolicyKey       
       and PolicyTransactionKey = d.PolicyTransactionKey       
       and Src = d.Src       
     ) f       
    where      
     TransactionType = 'Base'       
     and TransactionStatus = 'Active'       
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(ProductCode)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'PrimaryTraveller'       
   insert into ##dr_pivot      
   select *,'PrimaryTraveller'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(f.PrimaryTraveller) as PrimaryTraveller      
    from       
     ##dr_raw d       
     outer apply (      
      select       
       case       
        when (PrimaryTravellerCount is null or PrimaryTravellerCount != 1) then 1       
        else 0       
       end as PrimaryTraveller       
      from ##dr_raw       
      where       
       convert(char(10), TransactionDateTimeLocal, 126) = convert(char(10), d.TransactionDateTimeLocal, 126)       
       and CountryCode = d.CountryCode       
       and OutletAlphaKey = d.OutletAlphaKey       
       and PolicyKey = d.PolicyKey       
       and PolicyTransactionKey = d.PolicyTransactionKey       
       and Src = d.Src       
     ) f      
    where      
     TransactionType = 'Base'       
     and TransactionStatus = 'Active'       
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(PrimaryTraveller)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
  if @Target = 'TotalTravellers'      
   insert into ##dr_pivot      
   select *,'TotalTravellers'      
   from (      
    select       
     convert(char(10), TransactionDateTimeLocal, 126) as [Date],       
     CountryCode,       
     OutletAlphaKey as Identifier,       
     Src,      
     sum(isnull(TotalTravellerCount, 0)) as TotalTravellerCount      
    from       
     ##dr_raw      
    where      
     TransactionType = 'Base'    
     and TransactionStatus = 'Active'       
    group by       
     convert(char(10), TransactionDateTimeLocal, 126),       
     CountryCode,       
     OutletAlphaKey,       
     Src      
   ) s      
   pivot (      
    sum(TotalTravellerCount)       
    for Src in (Source, ODS, Star)      
   ) p      
      
      
 end -- Penguin      
      
END 
GO
