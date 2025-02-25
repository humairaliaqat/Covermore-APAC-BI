USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[GetPolicyDetailsByDateRange]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[GetPolicyDetailsByDateRange]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
 --  declare 
 --@StartDate DATE='2025-01-16',
 --   @EndDate DATE='2025-01-25'

    ;WITH cte_a AS (
        SELECT PolicyNo
        FROM [db-au-cmdwh]..clmClaim c WITH (NOLOCK)
        WHERE CONVERT(VARCHAR(20), CreateDate, 23) BETWEEN @StartDate AND @EndDate
        AND StatusDesc = 'Finalised'
		
		 UNION all
        
        SELECT PolicyNumber AS 'PolicyNo'
        FROM [db-au-cmdwh]..e5Work_v3 c WITH (NOLOCK)
        WHERE CONVERT(VARCHAR(20), CreationDate, 23) BETWEEN @StartDate AND @EndDate
        AND StatusName = 'Complete'
    )
--	select count(*) from cte_a

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
    FROM  cte_a c WITH (NOLOCK)
	JOIN [db-au-cmdwh]..penPolicy  p WITH (NOLOCK) ON c.PolicyNo = p.PolicyNumber
	JOIN [db-au-cmdwh]..penPolicyTraveller pt WITH (NOLOCK) ON pt.PolicyKey = p.PolicyKey
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
   
    ORDER BY PolicyNumber DESC




		---EXEC dbo.GetPolicyDetailsByDateRange @StartDate = '2025-01-16', @EndDate = '2025-01-31';
END





GO
