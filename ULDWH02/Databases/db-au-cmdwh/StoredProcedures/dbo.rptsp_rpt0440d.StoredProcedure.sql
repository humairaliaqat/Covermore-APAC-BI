USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0440d]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0440d]	
    @Country varchar(3),
    @PolicyNumber varchar(20)
    
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0440d
--  Author:         Linus Tor
--  Date Created:   20130716
--  Description:    This stored procedure returns all related policies (if any). It will be called from a Webi report
--  Parameters:     @Country: Country is AU, NZ, or UK
--                  @PolicyNumber: valid policy number
--   
--  Change History: 20130716 - LT - Created
--                  20130731 - LS - optimize join
--                                  bug fix, int overflow for cancelled policies
--
--
--	test cases
--	56688655: 1N, 1E, 1 Addon
--	56908166: 1N, 1RN (Cancelled Policy)
--	56968057: 1N, 1E, 1RE, 1E, 1RE, 1E
/****************************************************************************************************/								   

--uncomment to debug
/*
declare @Country varchar(3)
declare @PolicyNumber varchar(20)
select @Country = 'AU', @PolicyNumber = '56968057'
*/

    set nocount on

    if object_id('tempdb..#policy') is not null 
        drop table #policy

    --1st level depth
    select 
        PolicyNo
    into #policy
    from
        Policy
    where
        CountryKey = @Country and
        (
            PolicyNo = @PolicyNumber or
            OldPolicyNo = @PolicyNumber
        )
        
    union

    select 
        OldPolicyNo
    from
        Policy
    where
        CountryKey = @Country and
        (
            PolicyNo = @PolicyNumber or
            OldPolicyNo = @PolicyNumber
        ) and
        OldPolicyNo <> 0


    --2nd level depth
    insert into #policy
    select 
        p.PolicyNo
    from
        Policy p
        inner join #policy t on
            p.PolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country
    
    union
    
    select
        p.PolicyNo
    from
        Policy p
        inner join #policy t on
            p.OldPolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.PolicyNo <> 0
    
    union
    
    select 
        p.OldPolicyNo
    from
        Policy p
        inner join #policy t on
            p.PolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.OldPolicyNo <> 0
    
    union
    
    select top 100
        p.OldPolicyNo
    from
        Policy p
        inner join #policy t on
            p.OldPolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.OldPolicyNo <> 0
    
    --3rd level depth
    insert into #policy
    select 
        p.PolicyNo
    from
        Policy p
        inner join #policy t on
            p.PolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country
    
    union
    
    select
        p.PolicyNo
    from
        Policy p
        inner join #policy t on
            p.OldPolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.PolicyNo <> 0
    
    union
    
    select 
        p.OldPolicyNo
    from
        Policy p
        inner join #policy t on
            p.PolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.OldPolicyNo <> 0
    
    union
    
    select top 100
        p.OldPolicyNo
    from
        Policy p
        inner join #policy t on
            p.OldPolicyNo = t.PolicyNo
    where
        p.CountryKey = @Country and
        p.OldPolicyNo <> 0
            
    select distinct
	    CountryKey Country,
	    p.PolicyNo PolicyNumber,
	    CreateTime IssuedDate,
	    case 
            when PolicyType = 'N' then 'Original Policy'
            when PolicyType = 'E' then 'Extended'
            when PolicyType = 'R' then 'Refunded'
            when PolicyType = 'A' then 'Addon'
	    end PolicyType
    from
        #policy t
        inner join Policy p on
            p.PolicyNo = t.PolicyNo
    where
        CountryKey = @Country
        
end

GO
