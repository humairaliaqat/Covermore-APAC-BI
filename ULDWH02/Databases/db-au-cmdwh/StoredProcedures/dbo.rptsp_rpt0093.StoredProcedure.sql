USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0093]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0093]	@Country varchar(2)
as

SET NOCOUNT ON

/****************************************************************************************************/

--  Name:           rptsp_rpt0093
--  Author:         Saurabh Date
--  Date Created:   20150811	
--  Description:    This stored procedure returns list of Outlets for selected country parameter
--
--  Parameters:		@Country: AU, NZ, SG, MY, ID, CN, UK, IN
--					
--  Change History: TFS #18465 - RPT0093 - Agency List with Last Policy Issued
                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
select @Country = 'AU'
*/	

select 
	AlphaCode, 
	OutletName, 
	BDMName, 
	StateSalesArea, 
	GroupCode, 
	FSRType, 
	AgreementDate, 
	LegalEntityName, 
	ASICNumber, 
	ASICCheckDate,
  	ABN,
 	ContactStreet,
	ContactSuburb,
  	ContactState,
  	ContactPostCode,
  	ContactTitle,
  	ContactFirstName,
  	ContactInitial,
  	ContactLastName,
  	ContactPhone,
  	ContactEmail,
  	TradingStatus,
  	PP.[Last Issue Date]  
 from 
	penOutlet po
	left outer hash join
		(
			select											-- Fetch last issue date for each outlet from penPolicy table
				OutletAlphaKey,
				max(issueDate) as [Last Issue Date] 
			from 
				penPolicy 
			group by 
				OutletAlphaKey
		) PP ON
 			PO.OutletAlphaKey=PP.OutletAlphaKey
where
	po.CountryKey = @Country and
	po.OutletStatus = 'Current'

GO
