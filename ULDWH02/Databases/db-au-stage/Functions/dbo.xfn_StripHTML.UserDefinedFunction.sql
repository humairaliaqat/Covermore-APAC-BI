USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[xfn_StripHTML]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[xfn_StripHTML](@HTMLString [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [StripHTML].[UserDefinedFunctions].[CleanHTML]
GO
