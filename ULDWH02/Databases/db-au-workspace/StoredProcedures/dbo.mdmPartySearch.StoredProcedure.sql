USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[mdmPartySearch]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[mdmPartySearch]
    @SearchString varchar(1024)

as
begin
    
    declare @parsed varchar(1024)

    set @parsed = ''

    if rtrim(@SearchString) = '' 
        set @parsed = '1 and 0'

    --set @SearchString = '"' + @SearchString + '"'
    

    select 
        @parsed = @parsed +
        Item + 
        case
            when ItemNumber = max(ItemNumber) over () then ''
            else ' and '
        end
    from
        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SearchString, ' ')
    where
        rtrim(Item) <> ''

    select top 6 *
    from
        mdmParty
    where
        contains(AllText, @parsed) or
        PartyID in
        (
            select 
                PartyID
            from
                mdmPolicy
            where
                contains(PolicyNumber, @parsed)
        ) or
        PartyID in
        (
            select 
                PartyID
            from
                mdmClaim
            where
                contains(ClaimKey, @parsed)
        ) 

end
GO
