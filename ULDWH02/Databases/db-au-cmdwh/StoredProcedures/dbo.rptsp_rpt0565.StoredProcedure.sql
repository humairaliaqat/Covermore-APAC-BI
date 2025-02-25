USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0565]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0565]	
					@ParentCompany varchar(200) = null, 	--optional 1 or more Parent Companies (use comma separator)
					@Company varchar(200) = null ,      	--optional 1 or more Companies (use comma separator)
					@SubCompany varchar(200) = null,    	--optional 1 or more Sub Companies (use comma separator)
					@AssessmentStatus varchar(200) = null,	--optional 1 or more Assessment Status (use comma separator)
					@DateRange varchar(30),
					@StartDate date = null,
					@EndDate date = null,
					@DateReference varchar(30)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0565
--  Author:         Saurabh Date
--  Date Created:   20150923
--  Description:    This stored procedure returns EMC Case register details
--  Parameters:     @DateRange: Value is valid date range
--                  @StartDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--		    @DateReference: Enter reference date as "Create Date" or "Assessment Date"
--		    @ParentCompany: It is an optional input, Enter Parent company name/names
--		    @Company: It is an optional input, Enter Company name/names
--		    @SubCompany: It is an optional input, Enter Sub Company name/names
--		    @AssessmentStatus: It is an optional input, Enter Assessment Status
--   
--  Change History: 20150923 - SD - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
declare @DateReference varchar(30)
declare @ParentCompany varchar(200)
declare @Company varchar(200)
declare @SubCompany varchar(200)
declare @AssessmentStatus varchar(200)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null, @DateReference='Create Date', @ParentCompany='CoverMore', @Company='Cover-More', @SubCompany= null, @AssessmentStatus=null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @WhereParentCompany varchar(500)
declare @WhereCompany varchar(500)
declare @WhereSubCompany varchar(500)
declare @WhereAssessmentStatus varchar(max)
declare @WhereDateReference varchar(500)
declare @SQL varchar(max)


/* get reporting dates */
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @DateRange;


/* Process @ParentCompany parameter */
if @ParentCompany is null or @ParentCompany = '' or @ParentCompany = 'All'
	select @WhereParentCompany = ''
else
	select @WhereParentCompany = ' and ec.ParentCompanyName in (''' + replace(@ParentCompany,',',''',''') + ''')'

/* Process @Company parameter */
if @Company is null or @Company = '' or @Company = 'All'
	select @WhereCompany = ''
else
	select @WhereCompany = ' and ec.CompanyName in (''' + replace(@Company,',',''',''') + ''')'

/* Process @SubCompany parameter */
if @SubCompany is null or @SubCompany = '' or @SubCompany = 'All'
	select @WhereSubCompany = ''
else
	select @WhereSubCompany = ' and ec.SubCompanyName in (''' + replace(@SubCompany,',',''',''') + ''')'

/* Process @AssessmentStatus parameter */
if @AssessmentStatus is null or @AssessmentStatus = '' or @AssessmentStatus = 'All'
	select @WhereAssessmentStatus = ''
else
	select @WhereAssessmentStatus = ' and (case
						when ea.AssessedDate is null then ''Not Assessed''
						when ea.ApprovalStatus = ''Policy Denied'' then  ''Policy Denied''
						when ea.AgeApprovalStatus = ''Denied'' then  ''Policy Denied''
						when ea.ApprovalStatus = ''NotCovered'' then ''All EMC Denied''
						when ea.MedicalDeniedCount = 0 then ''All EMC Approved''
						when ea.MedicalDeniedCount > 0 and ea.MedicalApprovedCount > 0 then ''Approved & Denied''
						when ea.MedicalApprovedCount = 0 then ''All EMC Denied''
						else ''Not Defined''
  					  end) in (''' + replace(@AssessmentStatus,',',''',''') + ''')'

/* Process @DateReference parameter */
if @DateReference = 'Assessment Date'
	select @WhereDateReference = ' and (AssessedDateOnly between ''' + LEFT(CONVERT(VARCHAR,@rptStartDate, 120), 10) + ''' and ''' + LEFT(CONVERT(VARCHAR,@rptEndDate, 120), 10) + ''')'
else if @DateReference = 'Create Date'
	select @WhereDateReference = ' and (CreateDateOnly between ''' + LEFT(CONVERT(VARCHAR,@rptStartDate, 120), 10) +  ''' and ''' + LEFT(CONVERT(VARCHAR,@rptEndDate, 120), 10) + ''')'


select @SQL='SELECT	
		distinct
  		ec.ParentCompanyName [Parent Company],
		ec.CompanyName [Company],
		ec.SubCompanyName [Sub Company],
  		ea.ApplicationID [Case No],
  		po.AlphaCode [Alpha],
  		ea.ApplicationType [Application Type],
  		ea.ReceiveDate [Receive Date],
  		ea.AssessedDate [Assessed Date],
  		case
			when ea.AgeApprovalStatus = ''Approved'' then ''Yes''
			else ''No''
  		end [Age Approved],
  		case
			when ea.AssessedDate is null then ''Not Assessed''
			when ea.ApprovalStatus = ''Policy Denied'' then  ''Policy Denied''
			when ea.AgeApprovalStatus = ''Denied'' then  ''Policy Denied''
			when ea.ApprovalStatus = ''NotCovered'' then ''All EMC Denied''
			when ea.MedicalDeniedCount = 0 then ''All EMC Approved''
			when ea.MedicalDeniedCount > 0 and ea.MedicalApprovedCount > 0 then ''Approved & Denied''
			when ea.MedicalApprovedCount = 0 then ''All EMC Denied''
			else ''Not Defined''
  		end [Assessment Status],
  		ea.FileLocation [File Location],
  		eap.Title,
  		eap.FirstName,
  		eap.Surname,
  		eap.AgeOfDeparture [Age],
  		ea.Destination [Country],
  		ea.AreaName [Area Name],
  		ea.DepartureDate [Departure Date],
  		ea.ReturnDate [Return Date], 
  		(SELECT -- Calculating Medical risk for each case
			sum(ea1.MedicalRisk)
   		 FROM
			emcApplications ea1
   		 WHERE
			ea1.ApplicationID=ea.ApplicationID  
   		 GROUP BY
			ea1.ApplicationID) [Medical Risk],
  		(SELECT -- Calculating Payment for each case
    			sum(case
	    			when ep.TransactionStatus = ''Success'' then ep.EMCPremium
	    			else 0
			    end
			    )
   		 FROM
			emcPayment ep RIGHT OUTER JOIN emcApplications ea2 
				ON (ea2.ApplicationKey=ep.ApplicationKey)
   		 WHERE
			ea2.ApplicationID=ea.ApplicationID 
   		 GROUP BY
			ea2.ApplicationID) [Payment],
   		case 
			when ConditionStatus=''Approved'' then Condition
   		end [Approved Condition],
   		case
			when ConditionStatus=''Approved'' then MedicalScore
		end [Approved Score],
   		case 
			when ConditionStatus=''Denied'' then Condition
   		end [Denied Condition],
   		case
			when ConditionStatus=''Denied'' then MedicalScore
   		end [Denied Score],
		convert(datetime,'''
		+ LEFT(CONVERT(VARCHAR,@rptStartDate, 120), 10) + ''') [rptStartDate],
		convert(datetime,''' +
		LEFT(CONVERT(VARCHAR,@rptEndDate, 120), 10) + ''') [rptEndDate]
             FROM
   		emcApplicants eap INNER JOIN emcApplications ea 
			ON (ea.ApplicationKey=eap.ApplicationKey)
   		LEFT OUTER JOIN emcCompanies ec
			ON (ea.CompanyKey = ec.CompanyKey)
   		LEFT OUTER JOIN emcMedical em
			ON (ea.ApplicationKey=em.ApplicationKey)
   		LEFT OUTER JOIN penOutlet po
			ON (po.OutletAlphaKey=ea.OutletAlphaKey)
  
             WHERE
   		isnull(po.OutletStatus, ''Current'') = ''Current''
		' + @WhereDateReference + @WhereParentCompany + @WhereCompany +  @WhereSubCompany + @WhereAssessmentStatus

execute(@SQL)






GO
