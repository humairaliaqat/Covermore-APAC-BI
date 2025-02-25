USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[xfn_ConvertUTCtoLocal]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[xfn_ConvertUTCtoLocal](@DateTime [datetime], @LocalTimeZoneId [nvarchar](100))
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [CoverMore.PenguinSharpDataBaseClr].[UserDefinedFunctions].[UtcToLocalTimeZone]
GO
