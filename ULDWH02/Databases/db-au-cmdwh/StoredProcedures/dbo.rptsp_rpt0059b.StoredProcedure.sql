USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0059b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0059b]
    @CaseNo nvarchar(20)

as
begin
--20140715 - LS - TFS12109, unicode

    set nocount on

    select
        p.CaseNo CASE_NO,
        p.PlanDetail [PLAN],
        convert(varchar(10), p.TodoDate, 103) TODO_Date,
        convert(varchar(10), p.TodoTime, 108) TODO_TIME,
        p.CompletedBy COMP_AC,
        p.CompletionDate COMP_DATE,
        p.TodoDate
    from
        cbPlan p
    where
        p.CaseNo = @CaseNo and
        p.CompletionDate is null

end
GO
