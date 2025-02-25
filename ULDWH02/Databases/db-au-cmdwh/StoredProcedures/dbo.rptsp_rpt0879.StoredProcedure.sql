USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0879]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0879]
    @Distributor varchar(5),
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null

as

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0879
--  Author:         Leonardus Li
--  Date Created:   20171001
--  Description:    This stored procedure returns travel card transaction details
--  Change History: 20171001 - LL - Created
--					20171016 - LT - Changed date reference to ModifiedDateTime to cater for 
--									data load failure, and ensuring all records are picked up
/****************************************************************************************************/


begin

    set nocount on

    if @ReportingPeriod <> '_User Defined'  
        select   
            @StartDate = StartDate,   
            @EndDate = EndDate  
        from   
            [db-au-cmdwh].dbo.vDateRange  
        where   
            DateRange = @ReportingPeriod

    select
        t.DistributorCode,
        t.BranchName,
        t.EmailAddress,
        t.AccountCreationDate,
        t.CardHolderFullName,
        t.CardNumber,
        t.TransactionGroup,
        t.TransactionGroupDesc,
        t.TransactionCode,
        t.ProgramName,
        t.CustomerPostingDateTime,
        t.TransactionLocalDateTime,
        t.TransactionBINCurrency,
        t.TransactionBINCurrencyAmount,
        t.PurseCurrency,
        t.PurseAmount,
        t.TransactionCountry,
        t.TransactionDesc,
        tl.TransactionReferenceNumber,
        tl.RecordSequenceNumber,
        tl.Prel,
        IPSAccountNumber,
        @StartDate StartDate,
        @EndDate EndDate,
		t.ModifiedDateTime as PostingDate
    from
        penTravelCard t
        inner join penTravelCardLog tl on 
            t.TravelCardKey = tl.TravelCardKey
    where
        (
            @Distributor = 'ALL' or
            t.DistributorCode = @Distributor
        ) and
        t.ModifiedDateTime >= @StartDate and
        t.ModifiedDateTime <  dateadd(day, 1, @EndDate)

end
GO
