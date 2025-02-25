USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_HLORisk]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_HLORisk]
    @ReportingPeriod varchar(255),
    @Group varchar(255),
    @State varchar(255)

as
begin

--debug
--declare
--    @ReportingPeriod varchar(255),
--    @Group varchar(255),
--    @State varchar(255)

--select
--    @ReportingPeriod = '2015-01',
--    @Group = 'helloworld franchise',
--    @State = 'All'

    set nocount on

    declare 
        @date date,
        @rowcount bigint,
        @MedianLeadTime int,
        @MedianDuration int,
        @MedianAge int,
        @MedianCanx bigint

    set @date =
        dateadd(
            month,
            -6,
            convert(
                date,
                replace(
                    replace(
                        @ReportingPeriod, 
                        '[Date].[Fiscal Date Hierarchy].[Fiscal Year Month].&[', 
                        ''
                    ),
                    ']',
                    ''
                ) + '-01'
            )
        ) 
    
    select 
        GroupName,
        LeadTime, 
        Duration, 
        CancellationCover,
        Age,
        EMCPolicy
    from 
        [db-au-workspace]..vHLORisk
    where 
        IssueDate >= @date and
        IssueDate <  dateadd(month, 1, @date) and
        (
            @State = 'All' or
            StateSalesArea = @State
        ) and
        GroupName = @Group
        
end
GO
