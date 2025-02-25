USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_cleanemail]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_cleanemail](@Input varchar(max))
returns varchar(max)
as
begin
    
    declare @output varchar(max)

    set @output = lower(@Input)

    if charindex('<', @output) > 0 
    begin

        if charindex('>', @output, charindex('<', @output) + 1) > 0 
            set @output = substring(@output, charindex('<', @output), charindex('>', @output, charindex('<', @output) + 1) - charindex('<', @output) + 1)
    
        else
            set @output = substring(@output, charindex('<', @output), len(@output) - charindex('<', @output) + 1)

    end

    while patindex('%[^0-9^a-z @._%+-]%', @output) > 0
        set @output = stuff(@output, patindex('%[^0-9^a-z @._%+-]%', @output), 1, ' ')

    --set @output = replace(@Input, char(9), ' ')
    --set @output = replace(@output, char(10), ' ')
    --set @output = replace(@output, char(13), ' ')
    set @output = replace(@output, ' ', '')

    return @output

end
GO
