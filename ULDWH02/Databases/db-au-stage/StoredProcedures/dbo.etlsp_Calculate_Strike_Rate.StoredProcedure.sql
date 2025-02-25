USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Calculate_Strike_Rate]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
      
CREATE           
procedure [dbo].[etlsp_Calculate_Strike_Rate]          
    @period varchar(max),      
    @StartDate varchar(10) = null,      
    @EndDate varchar(10) = null      
as          
begin          
      
set nocount on          
          
    declare @rptStartDate smalldatetime      
    declare @rptEndDate smalldatetime      
  --exec [etlsp_Calculate_Strike_Rate] '_User Defined','2023-04-01','2023-04-14'    
    /* get reporting dates */      
    if @Period = '_User Defined'      
        select       
            @rptStartDate = convert(smalldatetime,@StartDate),       
            @rptEndDate = convert(smalldatetime,@EndDate)      
      
    else      
        select       
            @rptStartDate = StartDate,       
            @rptEndDate = EndDate      
        from       
            [db-au-cmdwh]..vDateRange      
        where       
            DateRange = 'Current Month'      
                      
    if object_id('tempdb..#Num_Travellers') is not null          
        drop table tempdb..#Num_Travellers          
      
 select penOutlet.GroupName,OutletName,penOutlet.AlphaCode,penUser.FirstName,penUser.LastName,sum(TravellersCount ) 'Number Of Travellers'      
    into #Num_Travellers      
 from [db-au-cmdwh]..penUser RIGHT OUTER JOIN (       
  Select      
        penPolicyTransSummary.CountryKey + '-' +       
        penPolicyTransSummary.CompanyKey + convert(varchar, penPolicyTransSummary.DomainID) + '-' +       
        convert(varchar, penPolicyTransSummary.CRMUserID) as CRMUserKey,      
        penPolicyTransSummary.*      
        from      
        [db-au-cmdwh]..penPolicyTransSummary      
          )  penPolicyTransSummary_DT ON (penUser.UserKey=penPolicyTransSummary_DT.UserKey and penUser.UserStatus = 'Current')      
           INNER JOIN [db-au-cmdwh]..penPolicy ON (penPolicy.PolicyKey=penPolicyTransSummary_DT.PolicyKey)      
           INNER JOIN [db-au-cmdwh]..penOutlet ON (penOutlet.OutletAlphaKey=penPolicyTransSummary_DT.OutletAlphaKey)      
           INNER JOIN [db-au-cmdwh]..Calendar ON ((      
            'Posting Date' = 'Issue Date' and      
            penPolicyTransSummary_DT.IssueDate = Calendar.Date      
        ) or      
        (      
            'Posting Date' = 'Posting Date' and      
            penPolicyTransSummary_DT.PostingDate = Calendar.Date      
        ))      
           --INNER JOIN [db-au-cmdwh]..vDateRange ON (Calendar.Date between vDateRange.StartDate and vDateRange.EndDate)      
           INNER JOIN [db-au-cmdwh]..vPenguinPolicyPremiums ON (vPenguinPolicyPremiums.PolicyTransactionKey=penPolicyTransSummary_DT.PolicyTransactionKey)      
        WHERE      
          (      
           penOutlet.CountryKey  =  'NZ'      
           AND      
           penOutlet.GroupCode  =  'FL'      
           AND      
           (      
            Calendar.Date between @rptStartDate and @rptEndDate      
            --vDateRange.DateRange  =  @period      
            AND      
            penOutlet.OutletName  NOT LIKE  '%test%'      
            AND      
            penOutlet.OutletName  NOT LIKE  '%training%'      
            AND      
            penOutlet.OutletName  NOT LIKE  '%delete%'      
           )      
           AND      
           ( penOutlet.OutletStatus = 'Current'  )      
          )      
        Group By penOutlet.GroupName,penOutlet.OutletName,penOutlet.AlphaCode,penUser.FirstName,penUser.LastName      
         
--    if object_id('[db-au-cmdwh]..[Tickets_Issued_Consultant]') is not null          
--        drop table [db-au-cmdwh]..[Tickets_Issued_Consultant]          
          
-- CREATE TABLE [db-au-cmdwh].[dbo].[Tickets_Issued_Consultant](      
-- [Date of Issue] [datetime] NULL,      
-- [Booking Business Unit Name] [nvarchar](255) NULL,      
-- [Booking Consultant] [nvarchar](255) NULL,      
-- [No of Tickets Issued] [float] NULL,      
-- [Number Of Travellers] [int] NULL,      
-- [Strike Rate] [float] NULL      
--)      
    
    delete from [db-au-cmdwh]..[Tickets_Issued_Consultant]    
    where [Date of Issue] in (select [Date of Issue] from [db-au-stage]..Tickets_Issued_Consultant)    
    
    insert into [db-au-cmdwh]..[Tickets_Issued_Consultant] ([Date of Issue],[Booking Business Unit Name],[Booking Consultant],[No of Tickets Issued],[Number Of Travellers],[Strike Rate])      
    select TIC.*,NT.[Number Of Travellers],([Number Of Travellers]/[No of Tickets Issued])*100 'Strike Rate'       
    from [db-au-stage]..Tickets_Issued_Consultant TIC left outer join #Num_Travellers NT      
    on lower(TIC.[Booking Consultant]) = lower(NT.FirstName) + ' ' + lower(NT.LastName) and lower(TIC.[Booking Business Unit Name]) = lower(NT.OutletName)      
    where TIC.[Date of Issue] is not null      
      
--    if object_id('[db-au-cmdwh]..[Tickets_Issued_Shop]') is not null          
--        drop table [db-au-cmdwh]..[Tickets_Issued_Shop]          
      
--    CREATE TABLE [db-au-cmdwh].[dbo].[Tickets_Issued_Shop](      
-- [Date of Issue] [datetime] NULL,      
-- [Booking Business Unit Name] [nvarchar](255) NULL,      
-- [No of Tickets Issued] [float] NULL,      
-- [Number Of Travellers] [int] NULL,      
-- [Strike Rate] [float] NULL      
--)    
      
delete from [db-au-cmdwh]..[Tickets_Issued_Shop]    
    where [Date of Issue] in (select [Date of Issue] from [db-au-stage]..[Tickets_Issued_Shop])    
    
    insert into [db-au-cmdwh]..[Tickets_Issued_Shop] ([Date of Issue],[Booking Business Unit Name],[No of Tickets Issued],[Number Of Travellers],[Strike Rate])      
    select M.[Date of Issue],M.[Booking Business Unit Name],M.[No of Tickets Issued],M.[Number Of Travellers],(M.[Number Of Travellers]/M.[No of Tickets Issued])*100 from       
    (select TIS.[Date of Issue],TIS.[Booking Business Unit Name],TIS.[No of Tickets Issued],sum(NT.[Number Of Travellers]) 'Number Of Travellers'      
    from [db-au-stage]..Tickets_Issued_Shop TIS left outer join #Num_Travellers NT      
    on lower(TIS.Alpha) = lower(NT.AlphaCode)      
    where TIS.[Date of Issue] is not null      
    group by [Date of Issue],[Booking Business Unit Name],[No of Tickets Issued]) M      
      
select [Date of Issue],[Booking Business Unit Name],[No of Tickets Issued],[Number Of Travellers],round([Strike Rate],2) 'Strike Rate' from [db-au-cmdwh]..Tickets_Issued_Shop order by  round([Strike Rate],2) desc    
      
select [Date of Issue],[Booking Business Unit Name],[Booking Consultant],[No of Tickets Issued],[Number Of Travellers],round([Strike Rate],2) 'Strike Rate' from [db-au-cmdwh]..[Tickets_Issued_Consultant]    order by round([Strike Rate],2) desc  
      
end          
GO
