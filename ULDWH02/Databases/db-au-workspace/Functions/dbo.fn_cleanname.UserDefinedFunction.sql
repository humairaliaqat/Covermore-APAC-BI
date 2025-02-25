USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_cleanname]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create function [dbo].[fn_cleanname](@Input varchar(max))
returns varchar(max)
as
begin
    
    declare @output varchar(max)

    set @output = lower(@Input)

    while patindex('%[^a-z ]%', @output) > 0
        set @output = stuff(@output, patindex('%[^a-z ]%', @output), 1, ' ')

    --set @output = replace(@Input, char(9), ' ')
    --set @output = replace(@output, char(10), ' ')
    --set @output = replace(@output, char(13), ' ')
    set @output = replace(@output, ' ', '')

    return @output

end
GO
