USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vClaimantMain]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vClaimantMain]
as

/* 
	This view is to filter for the main claimant only.
	If the claim has no primary claimant, then the first registered claimant is used as the Primary Claimant
	
*/
select
    a.CountryKey,
    a.ClaimKey,
    case 
        when a.NameKey is null then 
            (
                select top 1 
                    NameKey 
                from 
                    clmName 
                where 
                    ClaimKey = a.ClaimKey 
                order by 
                    NameID
            )
        else a.NameKey
    end as NameKey
from
(
    select
        c.CountryKey,
        c.ClaimKey,
        (
            select top 1 
                NameKey 
            from 
                clmName 
            where 
                ClaimKey = c.ClaimKey and 
                isPrimary = 1 
            order by 
                NameID
        ) as NameKey
    from
        clmClaim c
) a
--select 
--    c.ClaimKey,
--    pn.NameKey
--from
--    clmClaim c
--    outer apply
--    (
--        select top 1
--            n.NameKey
--        from
--            clmName n
--        where
--            n.ClaimKey = c.ClaimKey
--        order by
--            n.isPrimary desc,
--            n.NameID
--    ) pn

GO
