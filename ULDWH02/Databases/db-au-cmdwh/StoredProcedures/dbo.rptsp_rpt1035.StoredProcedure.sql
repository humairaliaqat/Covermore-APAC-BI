USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1035]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptsp_rpt1035]  @Country  varchar(10)
	
	                   
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


/****************************************************************************************************/
-- Name  :      dbo.rptsp_rpt1035
-- Author:		Sri Sailesh Pandravada
-- Create date: 2018-12-19
-- Description:	Report for Banned and Disqualified person from ASIC who are actively selling policies 
--              via various Outlets.  
-- Parameters:  @Country: Valid Domain Name
-- Change History: 20181219 - Sri - Created
/****************************************************************************************************/
    -- Insert statements for procedure here

/*Uncomment to debug*/
--Declare
--	@Country varchar(10)


--Select
--	@country = 'AU'




select 
	Blk.FullnameASIC BD_PER_NAME,
	Blk.[BanType]  BD_PER_TYPE,
	Blk.[BanDocumentNumber]	BD_PER_DOC_NUM,
	convert(date,Blk.BanStartDate) BD_PER_START_DT,
	convert(date,Blk.BanEndDate) BD_PER_END_DT,
 	Blk.[LocalAddress]  BD_PER_ADD_LOCAL,
	Blk.[State] BD_PER_ADD_STATE,
	Blk.[PostCode] BD_PER_ADD_PCODE,
	Blk.[Country] BD_PER_ADD_COUNTRY,
	Blk.[Comments] BD_PER_COMMENTS,
	case 
	      when Blk.BanEndDate < getdate() then 'N'
		  Else 'Y'
	End as CurrentlyServingBan,
	Pu.FirstName ConsultantFirstName,
	Pu.LastName  ConsultantLastName,
	pu.Status ConsultantStatus,
	pu.FirstSellDate ConsultantFirstSellDate,
	pu.LastSellDate  ConsultantLastSellDate,
	Pu.ASICCheck ConsultantAsicCheck,
	Po.OutletName,
	Po.AlphaCode,
	CONCAT(Po.ContactFirstName,' ',Po.ContactLastName) OutletManagerName,
	Po.ContactEmail OutletContactEmail,
	Po.ContactPhone OutletContactPhone
from
	[dbo].[usrASICBlacklist] Blk 
    inner join penuser Pu  on
	           Blk.FirstName  =  Pu.FirstName  and
		       Blk.LastName   =  pu.LastName  
    inner join Penoutlet Po on pu.OutletAlphaKey = Po.OutletAlphaKey 
Where  
	 Pu.CountryKey = @Country        and 
     Pu.Status     = 'Active'        and 
	 Pu.ConsultantType = 'External'  and
	 Po.TradingStatus  = 'Stocked'   and
	 Po.OutletStatus = 'Current'     and
	 Pu.UserStatus = 'Current' 
	
END

GO
