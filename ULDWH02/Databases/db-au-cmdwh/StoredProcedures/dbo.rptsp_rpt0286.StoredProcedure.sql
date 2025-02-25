USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0286]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0286]
    @Country varchar(2),
    @AgencyGroup varchar(2) = null,
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
                  
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0286
--  Author:         Leonardus Setyabudi
--  Date Created:   20120201
--  Description:    This stored procedure returns policies with return date in specified range
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20120201 - LS - Created
--                  20120307 - LS - Add Agency Code & Agency Group Name for grouping
--                  20120528 - LS - call rptsp_rpt0285
--                  20140630 - LS - TFS 12691 & 12581
--                                  refactoring
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @Country = 'AU',
    @AgencyGroup = 'TI',
    @ReportingPeriod = 'Current Fiscal Month', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    exec rptsp_rpt0285
        @Country = @Country,
        @AgencyGroup  = @AgencyGroup,
        @ProductCode = 'CMB',
        @ReportingPeriod = @ReportingPeriod,
        @StartDate = @StartDate,
        @EndDate = @EndDate

end

GO
