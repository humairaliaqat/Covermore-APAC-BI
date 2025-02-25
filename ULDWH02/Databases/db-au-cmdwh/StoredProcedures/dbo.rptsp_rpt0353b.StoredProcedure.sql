USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0353b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0353b]
as

SET NOCOUNT ON									


/****************************************************************************************************/
--  Name:           rptsp_rpt0353b
--  Author:         Linus Tor
--  Date Created:   20150522
--  Description:    This stored procedure returns APOTC policy import with 'Cancel' status.
--
--  Parameters:     
--   
--  Change History: 20150522 - LT - Created
--					20160301 - PZ - Added Policy Feeder payment reference number extraction
--                  20160319 - LS - INC6017, tripstart > 548 + getdate = Not fixable
--					20170919 - LT - Added YesterdayDate and CreateDateOnly columns to result set.
--					20181026 - SD - Restricted data to remove CBA exceptions and data will be shown only from 01/01/2015 onwards
--                  20190814 - LL - REQ-2069 exclude CBA (job code doesn't contain CBA, filter out business unit too)
--                  
/****************************************************************************************************/


if object_id('tempdb..#policyimport') is not null
    drop table #policyimport

select
    ppi.ID,
    ppi.DataImportKey,
    ppi.Status,
	ppi.Status as PolicyImportStatus,
	ppi.PolicyStatus,
	ppi.PolicyID,
	ppi.RowID,      
	ppi.RowIDPolicyNumber,
	ppi.BusinessUnit,
	ppi.PolicyNumber,
	ppi.AdjustedTotal as SellPrice,
	ppi.PolicyXML,
	ppi.Comment
into #policyimport
from
	penPolicyImport ppi with(nolock)
where
	ppi.CreateDateTime >= dateadd(year, -2, getdate()) and
    (
        ppi.BusinessUnit is null or
        ppi.BusinessUnit not like 'CBA%'
    ) and
    ppi.Status = 'CANCEL' 

if object_id('tempdb..#lasterror') is not null
    drop table #lasterror

select 
    DataID,
    max(JobErrorKey) JobErrorKey
into #lasterror
from
    penJobError with(nolock)
where
    DataID in
    (
        select 
            ID
        from
            #policyimport
    )
group by
    DataID

      
;with cte_policy as
(
	SELECT							--get AP OTC errors. AP OTC errors do not have retry like other data loader jobs
	  pje.CountryKey,
	  pje.CompanyKey,
	  pje.ID as JobErrorID,
	  pje.Description as JobErrorDescription,
	  pje.CreateDateTime,
	  pje.ErrorSource,
	  pje.SourceData,
	  pj.JobName,
	  pj.JobCode,
	  pj.JobType,
	  pj.JobDesc,
	  ppi.PolicyImportStatus,
	  ppi.PolicyStatus,
	  ppi.PolicyID,
	  ppi.RowID,      
	  ppi.RowIDPolicyNumber,
	  ppi.BusinessUnit,
	  ppi.PolicyNumber,
	  ppi.SellPrice,
	  ppi.PolicyXML,
	  ppi.Comment
	FROM
	  penDataImport pdi 
      INNER JOIN #policyimport ppi ON (pdi.DataImportKey=ppi.DataImportKey)
      inner join #lasterror le on le.DataID = ppi.ID
	   INNER JOIN penJobError pje ON pje.JobErrorKey = le.JobErrorKey
	   INNER JOIN penJob pj ON (pje.JobKey=pj.JobKey)  
	WHERE
	  (
	   pje.CountryKey  = 'AU'
	   AND
	   pj.JobCode  =  'AP_AU_TIP'
	  )
	  --Added on 26102018 BY SD, to restrict data
	  and pj.JobCode  not like 'CBA%'
)


select distinct
	a.CountryKey,
	a.CompanyKey,
	a.JobErrorID,
	a.JobErrorDescription,
	a.CreateDateTime,
	a.ErrorSource,
	a.SourceData,
	a.JobCode,
	a.JobType,
	a.JobDesc,
	a.PolicyImportStatus,
	a.BusinessUnit,
	a.PolicyNumber,
	case when a.SellPrice is null and a.PolicyXML is null and a.SourceData like '{%' then		--get SellPrice from JSON string
			(select top 1 StringValue from dbo.fn_parseJSON(convert(nvarchar(max),a.SourceData)) where [Name] = 'TotalGrossPremium')
		 when a.SellPrice is null and a.PolicyXML is not null then								--get SellPrice from PolicyXML
			dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'TotalGrossPremium')
		 else a.SellPrice																		--get SellPrice as stored in PolicyImport
	end as SellPrice,
	case when a.JobCode = 'AP_AU_TIP' then 
			dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'PaymentReferenceNo')				
		 else
			case
				when a.ErrorSource = 'Policy Feeder' then 
					(select top 1 StringValue from dbo.fn_parseJSON(convert(nvarchar(max),a.SourceData)) where [Name] = 'ReferenceNumber') 
				else 
					dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'ReceiptNumber')
			end
	end as PaymentReference,		
	case when a.ErrorSource = 'Policy Feeder' and a.SourceData not like '{%' then 'Error'
		 when a.ErrorSource = 'Policy Import' and a.SourceData not like '<%' then 'Error'
		 when a.JobCode = 'AP_AU_TIP' then dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'PaymentMethod')
		 when a.JobCode <> 'AP_AU_TIP' and a.ErrorSource = 'Policy Feeder' then 
			case when (select top 1 StringValue from dbo.fn_parseJSON(convert(nvarchar(max),a.SourceData)) where [Name] = 'ReferenceNumber') is null then 'Cash'
				 else 'CreditCard'
			end
		when a.JobCode <> 'AP_AU_TIP' and a.ErrorSource = 'Policy Import' then
			case when dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'ReceiptNumber') is null then 'Cash'
				 else 'CreditCard'
			end
		 else 'Error'
	end as PaymentMethod,
	dbo.xfn_ConvertUTCToLocal(convert(datetime,dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'TripStart')),t.TimeZoneCode) as TripStart,
	dbo.xfn_ConvertUTCToLocal(convert(datetime,dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'TripEnd')),t.TimeZoneCode) as TripEnd,
	case when a.PolicyXML is not null then
			dbo.fn_GetXMLElement(convert(nvarchar(max),a.PolicyXML),'AlphaCode')
		 when a.PolicyXML is null and a.SourceData like '{%' then
			(select top 1 StringValue from dbo.fn_parseJSON(convert(nvarchar(max),a.SourceData)) where [Name] = 'Code')
	end as AlphaCode,
	a.Comment,
	case 
		when charindex('AgeBand is missing', JobErrorDescription) > 0 then 'No'
		when charindex('Policy traveller addons count does not match',JobErrorDescription) > 0 then 'No'
		when charindex('Error in getting outletproductplan', JobErrorDescription) > 0 then 'No'
		when charindex('Ratecard cannot be found', JobErrorDescription) > 0 then 'No'
		when charindex('AddOn is not available in this plan', JobErrorDescription) > 0 then 'No'
		when charindex('AddOnValue is not available in Penguin', JobErrorDescription) > 0 then 'No'
		when charindex('Duration cannot be found', JobErrorDescription) > 0 then 'No'
		when charindex('The element ''AddressDetails'' in namespace', JobErrorDescription) > 0 then 'Yes'
		when charindex('Cancellation pricing is mismatched', JobErrorDescription) > 0 then 'Yes'
		when charindex('Payment amount and Policy amount does not match', JobErrorDescription) > 0 then 'Yes'
		when charindex('Failed to evaluate pricing', JobErrorDescription) > 0 then 'Yes'
		when charindex('Plan is type add-on only but policy to be imported has no add-on', JobErrorDescription) > 0 then 'Yes'
		when charindex('Adult Count', JobErrorDescription) > 0 then 'Yes'
		when charindex('Cancelation value doesn''t match', JobErrorDescription) > 0 then 'Yes'
		when charindex('The element ''TripDetails'' in namespace', JobErrorDescription) > 0 then 'Yes' 
		when charindex('Tax is not defined in system', JobErrorDescription) > 0 then 'Yes' 
		when charindex('has invalid child element', JobErrorDescription) > 0 then 'Yes' 
		when charindex('Error converting value {null} to type ''System.DateTime''', JobErrorDescription) > 0 then 'Yes' 
		when charindex('Error in downloading json', JobErrorDescription) > 0 then 'Yes'
		when charindex('Child Count: <> , Min Children Allowed', JobErrorDescription) > 0 then 'Yes'
		when charindex('TripEnd date cannot be before TripStart Date', JobErrorDescription) > 0 then 'Yes'
		when charindex('Policy xml is empty', JobErrorDescription) > 0 then 'Yes'
		when charindex('FieldBase', JobErrorDescription) > 0 then 'Yes'
        when charindex('TripStart date cannot be more than 548 days in advance of today date', JobErrorDescription) > 0 then 'No'
		else 'Yes'
	end Fixable,
	convert(varchar(10),dateadd(d,-1,getdate()),120) as YesterdayDate,
	convert(varchar(10),a.CreateDateTime,120) as CreateDateOnly
from
	cte_Policy a
	outer apply
	(
		select top 1 TimeZoneCode
		from [db-au-cmdwh].dbo.penDomain
		where
			CountryKey = a.CountryKey and
			CompanyKey = a.CompanyKey
	) t
GO
