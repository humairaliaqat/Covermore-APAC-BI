USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetPolicyStampDutyRate]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_GetPolicyStampDutyRate]
(
    @PolicyTransactionKey varchar(41)
)
returns decimal(18, 5)
as
begin

    declare @rate decimal(18, 5)

    select 
        @rate = sd.Rate
    from
        penPolicyTransSummary pt
        inner join penPolicy p on
            p.PolicyKey = pt.PolicyKey
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = p.PolicyKey and
            ptv.isPrimary = 1
        left join penOutlet o on
            o.OutletAlphaKey = p.OutletAlphaKey and
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1 
                Rate
            from
                usrStampDuty sd
            where
                sd.Country = pt.CountryKey and
                sd.AreaType = p.AreaType and
                sd.State = isnull(ptv.State, o.StateSalesArea) and
                sd.StartDate <= pt.IssueDate and
                (
                    sd.EndDate is null or
                    sd.EndDate >= pt.IssueDate
                )
            order by
                isnull(sd.EndDate, getdate()) desc
        ) sd
    where
        pt.PolicyTransactionKey = @PolicyTransactionKey

    set @rate = isnull(@rate, 0)

    return @rate
    
end

GO
