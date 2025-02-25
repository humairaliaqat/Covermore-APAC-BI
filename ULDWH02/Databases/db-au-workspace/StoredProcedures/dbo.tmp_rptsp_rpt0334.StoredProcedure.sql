USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0334]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[tmp_rptsp_rpt0334]	@AssessedStartDate datetime,
										@AssessedEndDate datetime,
										@DepartStartDate datetime,
										@DepartEndDate datetime,
										@ReturnStartDate datetime,
										@ReturnEndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0334
--  Author:         Linus Tor
--  Date Created:   20120620
--  Description:    This stored procedure returns EMC assessment details as per specified parameter values
--  Parameters:     @AssessedStartDate: valid datetime
--					@AssessedEndDate: valid datetime
--					@DepartStartDate: null or valid datetime
--					@DepartEndDate: null or valid datetime
--					@ReturnStartDate: null or valid datetime
--					@ReturnEndDate: null or valid datetime
--
--  Change History: 20120620 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @AssessedStartDate datetime
declare @AssessedEndDate datetime
declare @DepartStartDate datetime
declare @DepartEndDate datetime
declare @ReturnStartDate datetime
declare @ReturnEndDate datetime
select @AssessedStartDate = '2013-05-01', @AssessedEndDate = '2013-05-20', @DepartStartDate = null, @DepartEndDate = null, @ReturnStartDate = null, @ReturnEndDate = null
*/

declare @WhereAssessedStartDate datetime
declare @WhereAssessedEndDate datetime
declare @WhereDepartStartDate datetime
declare @WhereDepartEndDate datetime
declare @WhereReturnStartDate datetime
declare @WhereReturnEndDate datetime
declare @SQL nvarchar(max)


if @DepartStartDate is null or @DepartEndDate is null select @WhereDepartStartDate = '1900-01-01', @WhereDepartEndDate = '9999-12-31'
else select @WhereDepartStartDate = @DepartStartDate, @WhereDepartEndDate = @DepartEndDate

if @ReturnStartDate is null or @ReturnStartDate is null select @WhereReturnStartDate = '1900-01-01', @WhereReturnEndDate = '9999-12-31'
else select @WhereReturnStartDate = @ReturnStartDate, @WhereReturnEndDate = @ReturnEndDate
		
if @AssessedStartDate is null			--if assessed date is null, it defaults to Last Month
	select	@WhereAssessedStartDate = StartDate,
			@WhereAssessedEndDate = EndDate
	from   [db-au-cmdwh].dbo.vDateRange	  
	where DateRange = 'Last Month'
else
	select @WhereAssessedStartDate = convert(datetime,convert(varchar(10),@AssessedStartDate,120)), @WhereAssessedEndDate = convert(datetime,convert(varchar(10),@AssessedEndDate,120))


if object_id('tempdb..##rpt0334') is not null drop table ##rpt0334

select @SQL = 'OPEN SYMMETRIC KEY EMCSymmetricKey
DECRYPTION BY CERTIFICATE EMCCertificate;

    
select distinct
	e.ApplicationID as AssessmentNo,
	ltrim(rtrim(c.ParentCompanyName)) as Company,
	e.AssessedDate as AssessedDate,	
	case when e.AreaName is null then e.Destination
	     else e.AreaName
	end as Area,
	e.DepartureDate as DepartureDate,
	e.ReturnDate as ReturnDate,
	e.ApplicationStatus,
	e.ApprovalStatus,
	m.Condition,
	m.ConditionStatus as DeniedAccepted,
	n.Title as ClientTitle,
	n.Firstname as ClientFirstName,
	n.Surname as ClientSurname,
	datediff(year,convert(datetime,DecryptByKey(n.DOB)),e.CreateDate) as Age,
    convert(varchar(255),DecryptByKey(n.Street)) as ClientStreet,
    convert(varchar,DecryptByKey(n.Suburb)) as ClientSuburb,
    convert(varchar,DecryptByKey(n.State)) as ClientState,
    convert(varchar,DecryptByKey(n.PostCode)) as ClientPostCode,	   	
	c.CompanyName as [Group],
	e.ProductType as CardType,
	isnull(pay.EMCPremium,0) as AmountPaid,
	pay.ReceiptNo as ReceiptNumber,
	m.MedicalScore,
	m.GroupScore,
	e.MedicalRisk,
	convert(datetime,''' + convert(varchar(10),@WhereAssessedStartDate,120) + ''') as AssessedStartDate,
	convert(datetime,''' + convert(varchar(10),@WhereAssessedEndDate,120) + ''') as AssessedEndDate,
	convert(datetime,''' + convert(varchar(10),@WhereDepartStartDate,120) + ''') as DepartStartDate,
	convert(datetime,''' + convert(varchar(10),@WhereDepartEndDate,120) + ''') as DepartEndDate,
	convert(datetime,''' + convert(varchar(10),@WhereReturnStartDate,120) + ''') as ReturnStartDate,
	convert(datetime,''' + convert(varchar(10),@WhereReturnEndDate,120) + ''') as ReturnEndDate 
	into ##rpt0334
from 
	[db-au-cmdwh].dbo.emcApplications e
	join [db-au-cmdwh].dbo.emcApplicants n on e.ApplicationKey = n.ApplicationKey
	left join [db-au-cmdwh].dbo.emcMedical m on e.ApplicationKey = m.ApplicationKey
	join [db-au-cmdwh].dbo.emcCompanies c on e.CompanyKey = c.CompanyKey
	left join [db-au-cmdwh].dbo.emcPayment pay on e.ApplicationKey = pay.ApplicationKey
where
	ltrim(rtrim(c.ParentCompanyName)) = ''Zurich'' and
	convert(datetime,convert(varchar(10),e.AssessedDate,120)) between ''' + convert(varchar(10),@WhereAssessedStartDate,120) + ''' and ''' + convert(varchar(10),@WhereAssessedEndDate,120) + ''' and
	e.DepartureDate between ''' + convert(varchar(10),@WhereDepartStartDate,120) + ''' and ''' + convert(varchar(10),@WhereDepartEndDate,120) + ''' and 
	e.ReturnDate between ''' + convert(varchar(10),@WhereReturnStartDate,120) + ''' and ''' + convert(varchar(10),@WhereReturnEndDate,120) + ''' and
	m.ConditionStatus in (''Approved'', ''Denied'') 

CLOSE SYMMETRIC KEY EMCSymmetricKey'

exec(@SQL)

select distinct
	a.AssessmentNo,
	a.Company,
	a.AssessedDate,
	isNull(a.Area,'') as Area,
	a.DepartureDate,
	a.ReturnDate,
	a.ApplicationStatus,
	a.ApprovalStatus,
	a.ClientTitle,
	a.ClientFirstName,
	a.ClientSurname,
	a.Age,
	a.ClientStreet,
	a.ClientSuburb,
	a.ClientPostCode,
	a.[Group],
	a.CardType,
	a.AmountPaid,
	a.ReceiptNumber,
	a.MedicalScore,
	a.GroupScore,
	a.MedicalRisk,
	a.AssessedStartDate,
	a.AssessedEndDate,
	a.DepartStartDate,
	a.DepartEndDate,
	a.ReturnStartDate,
	a.ReturnEndDate,
	case when a.DeniedAccepted = 'Approved' then a.Condition else '' end as ConditionAccepted,
	case when a.DeniedAccepted = 'Denied' then a.Condition else '' end as ConditionDenied
/*	
	(select condition + ', '
	 from ##rpt0334 r
	 where r.assessmentno = a.assessmentno and deniedaccepted = 'Approved'
	 for xml path('')
	) as ConditionAccepted,				--concat accepted conditions into 1 column
	(select condition + ', '
	 from ##rpt0334 r
	 where r.assessmentno = a.assessmentno and deniedaccepted = 'Denied'
	 for xml path('')					--concat denied conditions into 1 column
	) as ConditionDenied	*/
from
	##rpt0334 a	

drop table ##rpt0334	


GO
