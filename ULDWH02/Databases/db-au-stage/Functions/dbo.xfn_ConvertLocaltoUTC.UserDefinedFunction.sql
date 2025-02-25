USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[xfn_ConvertLocaltoUTC]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[xfn_ConvertLocaltoUTC](@DateTime [datetime], @LocalTimeZoneId [nvarchar](100))
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [CoverMore.PenguinSharpDataBaseClr].[UserDefinedFunctions].[LocalToUtcTimeZone]
GO
