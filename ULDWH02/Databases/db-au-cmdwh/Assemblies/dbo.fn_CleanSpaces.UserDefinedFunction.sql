USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CleanSpaces]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_CleanSpaces] 
(
    @s varchar(max)
) 
returns varchar(max)
with schemabinding
begin

    if @s is null
        return ''

    set @s = replace(@s, char(10), ' ')
    set @s = replace(@s, char(13), ' ')
    set @s = replace(@s, char(9), ' ')

    while @s like '%  %'
        set @s = replace(@s, '  ', ' ')

    set @s = ltrim(rtrim(@s))

    return @s

end
GO
