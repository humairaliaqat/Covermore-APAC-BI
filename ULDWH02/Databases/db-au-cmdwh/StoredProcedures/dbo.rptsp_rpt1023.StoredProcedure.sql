USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1023]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1023]
    @ReportingMonth varchar(30) = 'Current Month',
    @ReportingYear int = 0

as
begin

    --20181015, LL, create

    set nocount on

    declare
        @refdate date,
        @start date,
        @cbupgrade decimal(16,2),
        @bwupgrade decimal(16,2)

    if @ReportingMonth = 'Current Month'
        set @refdate = eomonth(getdate())

    else if @ReportingMonth = 'Last Month'
        set @refdate = eomonth(dateadd(month, -1, getdate()))

    else
        set @refdate = eomonth(convert(date, convert(varchar, @ReportingYear) + '-' + @ReportingMonth + '-01'))

    set @start = dateadd(month, -1, dateadd(day, 1, @refdate))


    select 
        @cbupgrade = 
            sum
            (
                case 
                    when o.SubGroupName in ('CBA NAC Activation') then pp.[Premium]
                    else 0
                end
            ),
        @bwupgrade = 
            sum
            (
                case 
                    when o.SubGroupName in ('Bankwest NAC Activation') then pp.[Premium]
                    else 0
                end
            )
    from
        penPolicyTransSummary pt
        inner join vPenguinPolicyPremiums pp on
            pp.PolicyTransactionKey = pt.PolicyTransactionKey
        inner join penOutlet o on
            o.OutletAlphaKey = pt.OutletAlphaKey
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        o.GroupCode in ('CB', 'BW') and
        o.SubGroupName in ('Bankwest NAC Activation', 'CBA NAC Activation') and
        pt.PostingDate >= dateadd(month, -1, @start) and
        pt.PostingDate <  dateadd(month, -1, dateadd(day, 1, @refdate))

    ;with cte_latest as
    (
        select 
            [Bank],
            [CC Type],
            [CC Group],
            max([Reference Date]) [Reference Date]
        from
            usrCardVolume
        where
            [Reference Date] < dateadd(day, 1, @refdate)
        group by
            [Bank],
            [CC Type],
            [CC Group]
    )
    select 
        @refdate [Input Date],
        @cbupgrade CBAUpgradePremium,
        @bwupgrade BWUpgradePremium,
        t.[Bank],
        t.[CC Type],
        t.[CC Group],
        t.[Reference Date],
        isnull(r.[Card Volume], 0) [Card Volume],
        isnull(r.[ITI], 0) [ITI],
        isnull(r.[EW], 0) [EW],
        isnull(r.[PS], 0) [PS],
        isnull(r.[GP], 0) [GP],
        isnull(r.[TA], 0) [TA],
        isnull(r.[STA], 0) [STA],
        isnull(r.[IFI], 0) [IFI],
        isnull(r.[UT], 0) [UT],
        isnull(r.[NAC Other], 0) [NAC Other],
        isnull(r.[Card Volume], 0) *
        (
            isnull(r.[ITI], 0) +
            isnull(r.[EW], 0) +
            isnull(r.[PS], 0) +
            isnull(r.[GP], 0) +
            isnull(r.[TA], 0) +
            isnull(r.[STA], 0) +
            isnull(r.[IFI], 0) +
            isnull(r.[UT], 0) +
            isnull(r.[NAC Other], 0)
        ) / 12 [Total]
    from
        cte_latest t
        inner join usrCardVolume r on
            r.[Bank] = t.[Bank] and
            r.[CC Type] = t.[CC Type] and
            r.[CC Group] = t.[CC Group] and
            r.[Reference Date] = t.[Reference Date]

end
GO
