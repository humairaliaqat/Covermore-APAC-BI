USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_isLeapYear]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_isLeapYear]
(
            @Year SMALLINT
)
RETURNS BIT
AS
BEGIN
            RETURN      CASE DATEPART(DAY, DATEADD(YEAR, @Year - 1904, '19040229'))
                                     WHEN 29 THEN 1
                                     ELSE 0
                         END
END
GO
