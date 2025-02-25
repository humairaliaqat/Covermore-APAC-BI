USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0640]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[rptsp_rpt0640] 
	@UptoDate datetime
as 
BEGIN
	SET NOCOUNT ON
										
/****************************************************************************************************/
--  Name:           rptsp_rpt0640
--  Author:         Dane Murray
--  Date Created:   20150625
--  Description:    This stored procedure generates a summary of the Global Sim offered and accepted by Alpha.
--					The results are used in a Crystal report RPT0640 - "Global Sim Offered"
--
--
--  Parameters:     @@UptoDate: Format YYYY-MM-DD eg 2015-05-31
--   
--  Change History: 20150625 - DM - Created
--                  
/****************************************************************************************************/
	DECLARE @StartDate date

	set @StartDate = DATEADD(year,DATEDIFF(month,'19010701',@UptoDate)/12,'19010701')

	declare @Category table (
		AlphaCode varchar(20),
		Category varchar(30)
	)

	insert into @Category
	SELECT 'CMFL000', 'Telephone Sales'
	UNION ALL
	SELECT 'CMN0521', 'Telephone Sales'

	 select  DATEADD(month, DATEDIFF(month, 0, GlobalSIMEmailDate), 0) as GlobalSIMEmailDate, isNull(C.Category,'Other') as AlphaCategory, 
	 SUM(GlobalSimOfferAccepted) as GlobalSimOfferAccepted, COUNT(*) as policyCount
	 from vpenGlobalSIMEmailAndAcceptance A
	 left Join @Category C ON A.AlphaCode = C.AlphaCode
	 where CAST(GlobalSIMEmailDate as date) between @StartDate AND @UptoDate
	 GROUP BY DATEADD(month, DATEDIFF(month, 0, GlobalSIMEmailDate), 0) , isNull(C.Category,'Other')
END
GO
