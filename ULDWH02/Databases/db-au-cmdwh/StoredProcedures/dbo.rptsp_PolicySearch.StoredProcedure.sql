USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_PolicySearch]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_PolicySearch]
    @Country varchar(2),
    @PolicyNo varchar(max) = null,
    @Surname varchar(max) = null,
    @FirstName varchar(max) = null,
    @DOB varchar(max) = null
    
as
begin

    select top 50
        PolicyNumber,
        ptv.*
    from
        penPolicyTransSummary pt
        cross apply
        (
            select top 10 
                FirstName,
                LastName,
                DOB,
                Suburb,
                State,
                isPrimary
            from
                penPolicyTraveller ptv
            where
                ptv.PolicyKey = pt.PolicyKey
        ) ptv
    where
        pt.CountryKey = @Country
    order by
        IssueDate desc

end
GO
