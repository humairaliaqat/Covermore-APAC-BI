USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0355]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0355]	@AssessmentNo int,
										@CustomerName varchar(200),
										@Amount varchar(10),
										@TransactionPeriod varchar(30),
										@TransStartDate varchar(10),
										@TransEndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0355
--  Author:         Linus Tor
--  Date Created:   20120917
--  Description:    This stored procedure returns EMC assessment details as per specified parameter values
--  Parameters:     @AssessmentNo: valid assessment number or null for all
--					@CustomerName: wildcard text or null for all
--					@Amount: 45.00 or 75.00
--					@TransactionPeriod: standard date range or _User Defined
--					@TransStartDate: if _User Defined enter start date. Format: YYYY-MM-DD eg 2012-01-01
--					@TransEndDate: if _User Defined enter end date. Format: YYYY-MM-DD eg 2012-01-01
--
--  Change History: 20120917 - LT - Created
--
/****************************************************************************************************/




--uncomment to debug
/*
declare @AssessmentNo int
declare @CustomerName varchar(200)
declare @Amount varchar(10)
declare @TransactionPeriod varchar(30)
declare @TransStartDate varchar(10)
declare @TransEndDate varchar(10)
select @AssessmentNo = null, @CustomerName = null, @Amount = null, @TransactionPeriod = 'Year-To-Date', @TransStartDate = null, @TransEndDate = null
*/

declare @WhereAssessmentNo varchar(100)
declare @WhereCustomerName varchar(200)
declare @WhereAmount varchar(100)
declare @WhereTransStartDate datetime
declare @WhereTransEndDate datetime
declare @SQL nvarchar(max)
declare @SessionID varchar(36)
declare @rptStartDate datetime
declare @rptEndDate datetime

if @AssessmentNo is null or @AssessmentNo = 0 select @WhereAssessmentNo = '= e.ApplicationID'
else select @WhereAssessmentNo = '= ''' + convert(varchar,@AssessmentNo) + ''''

if @CustomerName is null or @CustomerName = '%' or @CustomerName = '' select @WhereCustomerName = 'like ''%'''
else select @WhereCustomerName = 'like ''%' + @CustomerName + '%'''

if @Amount is null or @Amount = '' or @Amount = '0' select @WhereAmount ='= pay.EMCPremium'
else select @WhereAmount = '= ' + @Amount

/* get reporting dates */
if @TransactionPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@TransStartDate), @rptEndDate = convert(smalldatetime,@TransEndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @TransactionPeriod


select @SQL = 'OPEN SYMMETRIC KEY EMCSymmetricKey
DECRYPTION BY CERTIFICATE EMCCertificate;
     
select distinct
	e.ApplicationID as AssessmentNo,
	ltrim(rtrim(c.ParentCompanyName)) as Company,
	e.AssessedDate as AssessedDate,	
	n.Firstname as ClientFirstName,
	n.Surname as ClientSurname,
	pay.EMCPremium as AmountPaid,
	pay.GST,
	pay.ReceiptNo as ReceiptNumber, convert(datetime,''' + convert(varchar(10),@rptStartDate,120) + ''') as rptStartDate,
	convert(datetime,''' + convert(varchar(10),@rptEndDate,120) + ''') as rptEndDate	
from 
	emcApplications e
	join emcApplicants n on e.ApplicationKey = n.ApplicationKey
	join emcCompanies c on e.CompanyKey = c.CompanyKey
	join emcPayment pay on e.ApplicationKey = pay.ApplicationKey
where
	ltrim(rtrim(c.ParentCompanyName)) = ''Zurich'' and
	e.ApplicationID ' + @WhereAssessmentNo + ' and
	pay.EMCPremium ' + @WhereAmount + ' and 
	n.FirstName + ''-'' + n.Surname ' + @WhereCustomerName + ' and
	convert(datetime,convert(varchar(10),e.AssessedDate,120)) between ''' + convert(varchar(10),@rptStartDate,120) + ''' and ''' + convert(varchar(10),@rptEndDate,120) + ''' 

CLOSE SYMMETRIC KEY EMCSymmetricKey'

exec(@SQL)
GO
