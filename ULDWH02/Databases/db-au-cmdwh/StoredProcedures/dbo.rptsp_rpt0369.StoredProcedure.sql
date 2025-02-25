USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0369]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0369]	@Country varchar(3),
										@Company varchar(5)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0369
--	Author:			Linus Tor
--	Date Created:	20121016
--	Description:	This stored procedure returns consultant list where accreditation date is in 
--					the last 24 hours
--
--	Parameters:		@Country: value is AU, NZ, UK or %
--					@Company: value is CM, TIP, or %
--	
--	Change History:	20121016 - LT - Created
--                  20130211 - LS - Case 18211, add consultant's email
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(3)
declare @Company varchar(5)
select @Country = 'AU', @Company = '%'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

if datepart(dw,getdate()) = 2
	select @rptStartDate = dateadd(d,-3,convert(datetime,convert(varchar(14),dateadd(hour,-24,getdate()),120)+'00:00')),
		   @rptEndDate = convert(datetime,convert(varchar(14),getdate(),120)+'00:00')
else 
	select @rptStartDate = convert(datetime,convert(varchar(14),dateadd(hour,-24,getdate()),120)+'00:00'),
		   @rptEndDate = convert(datetime,convert(varchar(14),getdate(),120)+'00:00')
		   
--select @rptStartDate = '2012-10-01', @rptEndDate = '2012-10-17'
		   
select
	u.CountryKey,
	u.CompanyKey,
	o.AlphaCode,
	o.OutletName,
	o.LegalEntityName,
	o.ASICNumber,	
	o.ABN,
	o.ContactStreet,
	o.ContactSuburb,
	o.ContactState,
	o.ContactPostCode,
	o.ContactEmail,
	o.ContactPhone,
	u.UserStartDate,
	u.FirstName,
	u.LastName,
	u.[Login],
	u.AgreementDate,
	u.AccreditationNumber,
	u.AccreditationDate,
	u.[Status],
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	u.ASICCheck,
	u.Email
from 
	[db-au-cmdwh].dbo.penUser u
	join [db-au-cmdwh].dbo.penOutlet o on
		u.OutletKey = o.OutletKey and
		u.UserStatus = 'Current' and
		o.OutletStatus = 'Current'
where
	u.CountryKey like @Country and
	u.CompanyKey like @Company and	
	u.AccreditationDate is not null and 
	u.ASICCheck = 'Pass' and
	convert(datetime,convert(varchar(14),u.AccreditationDate,120)+'00:00') between @rptStartDate and @rptEndDate
	
GO
