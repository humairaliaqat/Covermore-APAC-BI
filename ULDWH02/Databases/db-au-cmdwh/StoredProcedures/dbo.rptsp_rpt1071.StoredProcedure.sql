USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1071]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/  
--  Name   : rptsp_rpt1071  
--  Description  : Customer Service Reports Monthly - JV and Talk Time     
--  Author   : Yi Yang  
--  Date Created : 20190708  
--  Parameters  : @ReportingPeriod, @StartDate, @EndDate  
--  Change History :   
--     : 20190708 - New Report  
/****************************************************************************************************/  
  
CREATE PROCEDURE [dbo].[rptsp_rpt1071]  
  @ReportingPeriod VARCHAR(30)  
, @StartDate DATETIME  
, @EndDate DATETIME  
AS  
  
begin  
    set nocount on  
  
IF OBJECT_ID('tempdb..#temp_call', 'U') IS NOT NULL   
  DROP TABLE #temp_call;  
  
  
---- uncomments to debug  
--DECLARE @ReportingPeriod VARCHAR(30)  
--, @StartDate DATETIME  
--, @EndDate DATETIME  
--SELECT @ReportingPeriod =  '_User Defined'  
--, @StartDate = '2019-06-01' --dateadd(day, 1, EOMONTH(DATEADD(day, -1, convert(date, GETDATE())), -2))    
--, @EndDate = '2019-06-30'   --DATEADD(day, -1, convert(date, GETDATE()))           
-- uncomments to debug  
   
 --get reporting dates  
DECLARE @rptStartDate DATETIME, @rptEndDate DATETIME  
IF @ReportingPeriod = '_User Defined'  
 SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate  
ELSE  
    SELECT @rptStartDate = StartDate, @rptEndDate = EndDate  
    FROM [db-au-cmdwh].dbo.vDateRange  
    where DateRange = @ReportingPeriod  
  
  
select   
 tc.[SessionID]  
 ,tc.[AgentName]  
 ,tc.[Team]  
 ,tc.[ApplicationName]  
 ,tc.[Company]  
 ,tc.[CSQName]  
 ,tc.[CallDate]  
 ,tc.[CallStartDateTime]  
 ,tc.[CallEndDateTime]  
 ,tc.[ContactDisposition]  
 ,tc.[OriginatorNumber]  
 ,tc.[DestinationNumber]  
 ,tc.GatewayNumber  
 ,tc.[DialedNumber]  
 ,tc.[CallsPresented]  
 ,tc.[QueueHandled]  
 ,tc.[QueueAbandoned]  
 ,tc.[RingTime]  
 ,tc.[TalkTime]  
 ,tc.[HoldTime]  
 ,tc.[WorkTime]  
 ,tc.[WrapUpTime]  
 ,tc.[QueueTime]  
 ,tc.[MetServiceLevel]  
 ,tc.[Transfer]  
 ,tc.[Redirect]  
 ,tc.[Conference]  
 ,tc.[RNA]  
 ,tc.[ContactType]  
  
 ,case    
  when tc.ApplicationName  = 'AUCustomerServiceAHM' then 'AHM'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' then 'Australia Post'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' then 'Cover-More'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' then 'Medibank'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' then 'Hello World'  
  when tc.ApplicationName  = 'AUCustomerServiceIAL' then 'IAL'  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' then 'Ticketek'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' then 'Virgin'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' then 'Princess'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' then 'CBA'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' then 'BW'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' then 'Coles'  
  when tc.ApplicationName = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') then 'P&O'  
  when tc.ApplicationName = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') then 'HIF'  
  when tc.ApplicationName = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') then 'Aunt Betty'  
  when tc.ApplicationName = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') then 'You Go'  
  when tc.ApplicationName = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') then 'Westfund'  
  WHEN tc.ApplicationName  in ( 'AUCustomerServiceWebjet' ,'NZCustomerServiceWebjet') THEN 'WebJet' 
  else null  
 end as Partner  
 ,case    
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Enquiries' then 'AHM Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Claims_Exist' then 'AHM Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_EMC' then 'AHM EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Claims_New' then 'AHM Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Sales' then 'AHM Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Sales' then 'AP Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Claims_New' then 'AP Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Claims_Exist' then 'AP Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_EMC' then 'AP EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Enquiries' then 'AP Enquiries'  
  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Complex_Enquiries' then 'CM Complex Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Sales' then 'CM Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Simple_Enquiries' then 'CM Simple Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Claims_Exist' then 'CM Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Claims_New' then 'CM Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_EMC' then 'CM EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Enquiries' then 'CM Enquiries'  
  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Enquiries' then 'MB Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Claims_Exist' then 'MB Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_EMC' then 'MB EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Claims_New' then 'MB Claims New'  
  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Enquiries' then 'HW Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_EMC' then 'HW EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Claims_Exist' then 'HW Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Claims_New' then 'HW Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Sales' then 'HW Sales'  
    
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Enquiries' then 'IAL Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Claims_New' then 'IAL Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Claims_Exist' then 'IAL Claims Exist'  
  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Enquiries' then 'VA Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Claims_Exist' then 'VA Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Claims_New' then 'VA Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Sales' then 'VA Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Enquiries' then 'Ticketek Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Claims_New' then 'Ticketek Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Claims_Exist' then 'Ticketek Claims Exist'  
    
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_Sales' then 'Princess Sales'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'Princess Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_EMC' then 'Princess EMC'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'Princess Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'Princess Claims New'  
  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_Enquiries' then 'CBA Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_EMC' then 'CBA EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_New_Claim' then 'CBA Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_Existing_Claim' then 'CBA Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_120CM_Sales' then 'CBA Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_Enquiries' then 'BW Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_New_Claim' then 'BW New Claim'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_Existing_Claim' then 'BW Existing Claim'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_120CM_Sales' then 'BW Sales'  
    
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'Coles Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'Coles Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'Coles Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_EMC' then 'Coles EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_Sales' then 'Coles Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_120_World_Event' then 'Coles Claims World Event'  
  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_Sales' then 'P&O Sales'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'P&O Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'P&O Claims New'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_EMC' then 'P&O EMC'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'P&O Claims Exist'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115')and CSQName = 'AU_CS_LOWVOL_Sales' then 'HIF Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'HIF Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'HIF Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_EMC' then 'HIF EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'HIF Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_120CM_World_Event' then 'HIF World Event'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_Sales' then 'You Go Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'You Go Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'You Go Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_EMC' then 'You Go EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'You Go Claims Exist'  
  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'Aunt Betty Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'Aunt Betty Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'Aunt Betty Claims Exist'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_EMC' then 'Aunt Betty EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_Sales' then 'Aunt Betty Sales'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125')and CSQName = 'AU_CS_LOWVOL_Sales' then 'Westfund Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'Westfund Enquiries'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'Westfund Claims New'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_EMC' then 'Westfund EMC'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'Westfund Claims Exist'  
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050) AND   CSQName IN ('AU_CS_120CM_World_Event','AU_CS_7030_World_Event') THEN 'WebJet World Event'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,1888082) AND   CSQName IN ('AU_CS_7030_Claims_Exist') THEN 'WebJet Claim Exist'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,1888081) AND   CSQName IN ('AU_CS_7030_Claims_New') THEN 'WebJet Claim New'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,5772,1888083,5427,5107) AND   CSQName IN ('AU_CS_7030_Enquiries') THEN 'WebJet Enquiries'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (1888083,1888084,5050) AND   CSQName IN ('AU_CS_7030_Sales') THEN 'WebJet Sales'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (1888081,1888082,1888084,1888083,5050) AND   CSQName IN ('Unknown') THEN 'WebJet Unknown'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Claims') THEN 'WebJet Claims'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Enquiries') THEN 'WebJet Enquiries'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('AU_CS_7030_Claims_New') THEN 'WebJet Claim New'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Sales') THEN 'WebJet Sales'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('Unknown') THEN 'WebJet Unknown'

  else   
   'Other'   
 end as QueueName  
  
  ,case    
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceAHM' and CSQName = 'AU_CS_7030_Sales' then 'Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceAP' and CSQName = 'AU_CS_120_Enquiries' then 'CSR'  
  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Complex_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Simple_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCM' and CSQName = 'AU_CS_120CM_Enquiries' then 'CSR'  
  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceMB' and CSQName = 'AU_CS_7030_Claims_New' then 'CSR'  
  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceHW' and CSQName = 'AU_CS_120_Sales' then 'Sales'  
    
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceIAL' and CSQName = 'AU_CS_120_Claims_Exist' then 'CLO'  
  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Claims_Exist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceVA' and CSQName = 'AU_CS_7030_Sales' then 'Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Claims_New' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceTKT' and CSQName = 'AU_CS_120_Claims_Exist' then 'CLO'  
    
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServicePrincess' and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_New_Claim' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_CBA_Existing_Claim' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceCBA' and CSQName = 'AU_CS_120CM_Sales' then 'Sales'  
  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_New_Claim' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_BW_Existing_Claim' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceBankwest' and CSQName = 'AU_CS_120CM_Sales' then 'Sales'  
    
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceColes' and tc.GatewayNumber <> '5091' and CSQName = 'AU_CS_120_World_Event' then 'CSR'  
  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServicePO' and tc.GatewayNumber in ('1888060', '1888062', '1888063', '1888064', '1888065','1888066') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115')and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115') and CSQName = 'AU_CS_120CM_World_Event' then 'CSR'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1163', '1164', '1165', '1166', '1167', '1168') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888100', '1888101', '1888102', '1888103') and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
      
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125')and CSQName = 'AU_CS_LOWVOL_Sales' then 'Sales'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_Enquiries' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_ClaimsNew' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_EMC' then 'CSR'  
  when tc.ApplicationName  = 'AUCustomerServiceLowVolume01' and tc.GatewayNumber in ('1888120', '1888122', '1888121', '1888124', '1888123', '1888125') and CSQName = 'AU_CS_LOWVOL_ClaimsExist' then 'CLO'  
 
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050) AND   CSQName IN ('AU_CS_120CM_World_Event','AU_CS_7030_World_Event') THEN 'CSR'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,1888082) AND   CSQName IN ('AU_CS_7030_Claims_Exist') THEN 'CLO'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,1888081) AND   CSQName IN ('AU_CS_7030_Claims_New') THEN 'CSR'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (5050,5772,1888083,5427,5107) AND   CSQName IN ('AU_CS_7030_Enquiries') THEN 'CSR'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (1888083,1888084,5050) AND   CSQName IN ('AU_CS_7030_Sales') THEN 'Sales'
  WHEN   tc.ApplicationName ='AUCustomerServiceWebjet' AND   tc.GatewayNumber in (1888081,1888082,1888084,1888083,5050) AND   CSQName IN ('Unknown') THEN 'WebJet Unknown'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Claims') THEN 'CLO'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Enquiries') THEN 'CSR'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('AU_CS_7030_Claims_New') THEN 'CSR'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('NZ_CS_Sales') THEN 'Sales'
  WHEN   tc.ApplicationName ='NZCustomerServiceWebjet' AND   tc.GatewayNumber in (8610) AND   CSQName IN ('Unknown') THEN 'WebJet Unknown'    
  else   
   'Other'   
 end as TeamName  
  
 ,@rptStartDate AS ReportStartDate  
 ,@rptEndDate AS ReportEndDate  
 ,GETDATE() AS ReportingDate  
into   
 #temp_call  
from   
 [db-au-cmdwh].[dbo].vTelephonyData as tc with (NOLOCK)  
  
where    
 (tc.ApplicationName in   
  ('AUCustomerServiceAHM', 'AUCustomerServiceAP' ,  
  'AUCustomerServiceCM', 'AUCustomerServiceHW',   
  'AUCustomerServiceIAL', 'AUCustomerServiceMB',  
   'AUCustomerServiceTKT', 'AUCustomerServiceVA',  
   'AUCustomerServicePO', 'AUCustomerServicePrincess',    
   'AUCustomerServiceCBA', 'AUCustomerServiceBankwest',   
   'AUCustomerServiceColes','AUCustomerServiceWebjet','NZCustomerServiceWebjet')  
 or   
  (tc.ApplicationName = 'AUCustomerServiceLowVolume01' and   
   (tc.GatewayNumber in ('1888110', '1888111', '1888112', '1888113', '1888114', '1888115',   
       '1163', '1164', '1165', '1166', '1167', '1168',  
       '1888100', '1888101', '1888102', '1888103',  
       '1888120', '1888122', '1888121', '1888124', '1888123', '1888125') )  
 )  
 )  
 and  
 (convert(date, tc.CallDate) >= @rptStartDate and convert(date, tc.CallDate) <= @rptEndDate)   
 and   
 tc.ContactType in ('Incoming', 'Redirect in', 'Transfer in')  
 and tc.CSQName <> 'Unknown'  
  
order by tc.CallDate   
  
-- remove the calls where handled but no talk time  
  
delete from   
 #temp_call  
where   
 TalkTime = 0   
 and ContactDisposition = 'Handled'   
 and QueueAbandoned = 0  
  
-- Generate output columns for reporting  
select   
 tc1.[SessionID]  
 ,tc1.[AgentName]  
 ,tc1.[Team]  
 ,tc1.[ApplicationName]  
 ,tc1.[Company]  
 ,tc1.[CSQName]  
 ,tc1.[CallDate]  
 ,tc1.[CallStartDateTime]  
 ,tc1.[CallEndDateTime]  
 ,tc1.[ContactDisposition]  
 ,tc1.[OriginatorNumber]  
 ,tc1.[DestinationNumber]  
 ,tc1.GatewayNumber  
 ,tc1.[DialedNumber]  
 ,tc1.[CallsPresented]  
 ,tc1.[QueueHandled]  
 ,tc1.[QueueAbandoned]  
 ,tc1.[RingTime]  
 ,tc1.[TalkTime]  
 ,tc1.[HoldTime]  
 ,tc1.[WorkTime]  
 ,tc1.[WrapUpTime]  
 ,tc1.[QueueTime]  
 ,tc1.[MetServiceLevel]  
 ,tc1.[Transfer]  
 ,tc1.[Redirect]  
 ,tc1.[Conference]  
 ,tc1.[RNA]  
 ,tc1.[ContactType]  
 ,tc1.Partner  
 ,tc1.QueueName  
 ,tc1.TeamName  
 ,tc1.ReportStartDate  
 ,tc1.ReportEndDate  
 ,tc1.ReportingDate  
from   
 #temp_call as tc1   
end  
  
GO
