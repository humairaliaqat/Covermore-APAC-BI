USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[GetPolicyDetailsByDateRange]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPolicyDetailsByDateRange]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    WITH cte_a AS (
        SELECT PolicyNo
        FROM [db-au-cmdwh]..clmClaim c WITH (NOLOCK)
        WHERE CONVERT(VARCHAR(20), CreateDate, 23) BETWEEN @StartDate AND @EndDate
        AND StatusDesc = 'Finalised'
        UNION
        SELECT PolicyNumber AS 'PolicyNo'
        FROM [db-au-cmdwh]..e5Work_v3 c WITH (NOLOCK)
        WHERE CONVERT(VARCHAR(20), CreationDate, 23) BETWEEN @StartDate AND @EndDate
        AND StatusName = 'Complete'
    )
    SELECT DISTINCT 
        p.PolicyKey,
        PolicyNumber,
        OutletName,
        FirstName,
        LastName,
        DATEDIFF(YEAR, DOB, GETDATE()) AS 'Age',
        Country,
        TripEnd,
        MarketingConsent,
        EmailAddress
    FROM [db-au-cmdwh]..penPolicyTraveller pt WITH (NOLOCK)
    JOIN [db-au-cmdwh]..penPolicy p WITH (NOLOCK) ON pt.PolicyKey = p.PolicyKey
    JOIN [db-au-cmdwh]..penOutlet o WITH (NOLOCK) ON p.OutletAlphaKey = o.OutletAlphaKey
    WHERE CONVERT(VARCHAR(20), TripEnd, 23) BETWEEN @StartDate AND @EndDate
    AND OutletName = 'Freely'
    AND OutletStatus = 'Current'
    AND pt.Country = 'Australia'
    AND isPrimary = 1
    AND (EmailAddress NOT LIKE '%covermore.com%'
         AND EmailAddress NOT LIKE '%freely.me%'
         AND EmailAddress NOT LIKE '%gofreely.com.au%'
         AND EmailAddress NOT LIKE '%gofreely.help%'
         AND EmailAddress NOT LIKE '%test%')
    AND EXISTS (
        SELECT PolicyNo
        FROM cte_a c WITH (NOLOCK)
        WHERE c.PolicyNo = p.PolicyNumber
    )
    ORDER BY PolicyNumber DESC
END
GO
