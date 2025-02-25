USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCommission]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_GetCommission] (@CountryKey varchar(2), @AgencyCode varchar(10))  
RETURNS float AS  
BEGIN 

--uncomment to debug
/*
declare @CountryKey varchar(2)
declare @AgencyCode varchar(7)
select @CountryKey = 'AU', @AgencyCode = 'FLV0928'
*/

DECLARE @age_table varchar(50)
SELECT @age_table = AgeLoadingTable 
FROM [db-au-cmdwh].dbo.Agency
where AgencyCode = @AgencyCode and CountryKey = @CountryKey

DECLARE @result float

IF (@age_table = 'tblAgeLoading_a')
BEGIN
	SELECT @result = (SELECT TOP 1 c.COMM --, t.PlanId, t.AgeBracket, b.PlanCode 
	FROM 
		[db-au-cmdwh].dbo.StockedProduct c 
		INNER JOIN [db-au-cmdwh].dbo.AgeLoading t ON 
			c.CountryKey = t.CountryKey and
			c.AGELOADINGID = t.AgeLoadingId
		INNER JOIN [db-au-cmdwh].dbo.b2bsetupplan b ON 
			t.CountryKey = b.CountryKey and
			t.PlanId = b.PlanID
	WHERE 
		c.AgencyCode = @AgencyCode and 
		c.CountryKey = @CountryKey and 
		b.PlanCode LIKE 'P%'
	ORDER BY t.PlanID)
END

return @result

END



GO
