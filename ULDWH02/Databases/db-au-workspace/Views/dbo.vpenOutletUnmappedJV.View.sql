USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vpenOutletUnmappedJV]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-workspace]
--GO

--/****** Object:  View [dbo].[vpenOutletUnmappedJV]    Script Date: 26/07/2017 1:32:21 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO








CREATE view [dbo].[vpenOutletUnmappedJV]
as

--20160121 - RL - add more SuperGrouName mapping
--20150424 - LT - changed SuperGroupName for TCIS to Helloworld from Independents

select 
    *
from
    (
        select 
            OutletAlphaKey,
            o.CountryKey,
            o.DomainID,
            case
                when SuperGroupName = 'AirNZ' then 'Air New Zealand'
                when SuperGroupName = 'Stella' then 'Helloworld'
                when SuperGroupName = 'Brokers' then 'Independents'
                when SuperGroupName = 'TCIS' then 'Helloworld'
                when SuperGroupName = 'Cover-More Indies' then 'Independents'
                when SuperGroupName = 'Direct Sales' then 'Cover-More Websales'
				when SuperGroupName = 'Air NZ' then 'Air New Zealand'				--RL
                when SuperGroupName = 'Travel Managers' then 'Independents'			--RL
                when SuperGroupName = 'Direct' then 'Cover-More Websales'			--RL
                else SuperGroupName
            end SuperGroupName,
            GroupCode,
            GroupName,
            SubGroupCode,
            SubGroupName,
            o.AlphaCode,
            OutletName,
            jv.DistributionType,
            jv.JVCode,
            o.Channel,
            o.CommencementDate,
            o.TradingStatus,
            cc.LastModify
        from
            [db-au-cmdwh]..penOutlet o
            inner join [db-au-cmdwh]..vpenOutletJV jv on
                jv.OutletKey = o.OutletKey
            outer apply
            (
                select top 1 
                    CommentDate LastModify
                from
                    [db-au-cmdwh]..penAutoComment ac
                where
                    ac.OutletKey = o.OutletKey
                order by 
                    1 desc
            ) cc
        where
            OutletStatus = 'Current' and
            (
                jv.MappedFlag = 0 or
                jv.JVCode = 'Unknown' 
            ) and
            TradingStatus <> 'Closed' and
            (
                CommencementDate is not null or
                LastModify is not null
            )
    ) o
    outer apply
    (
        select 
            min(IssueDate) FirstSell,
            max(IssueDate) LastSell
        from
            [db-au-cmdwh]..penPolicyTransSummary pt with(index(idx_penPolicyTransSummary_OutletAlphaKey))
        where
            pt.OutletAlphaKey = o.OutletAlphaKey
    ) p


GO
