USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CleanAlphaNumeric]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_CleanAlphaNumeric] 
(
    @s varchar(max),
    @alphamode bit,
    @uppercase bit 
) 
returns varchar(max)
with schemabinding
begin

    if @s is null
        return ''

    set @s = ltrim(rtrim(@s))
    
    while @s like '%  %'
        set @s = replace(@s, '  ', ' ')

    declare @s2 varchar(1024)
    set @s2 = ''

    declare @l int
    set @l = len(@s)
   
    declare @p int
    set @p = 1
   
    while @p <= @l 
    begin

        declare @c varchar
        set @c = substring(@s, @p, 1)
    
        if 
            lower(@c) between 'a' and 'z' or
            @c = ' ' or
            (
                @alphamode = 0 and
                @c between '0' and '9'
            )
            set @s2 = @s2 + @c

        else 
        if @c in ('-', '/')
            set @s2 = @s2 + ' '

        set @p = @p + 1
    
    end

    while @s2 like '%  %'
        set @s2 = replace(@s2, '  ', ' ')
        
    set @s2 = ltrim(rtrim(@s2))

    if len(@s2) = 0
        return ''

    if @uppercase = 1
        set @s2 = upper(@s2)

    else
        set @s2 = lower(@s2)

    return @s2

end
GO
