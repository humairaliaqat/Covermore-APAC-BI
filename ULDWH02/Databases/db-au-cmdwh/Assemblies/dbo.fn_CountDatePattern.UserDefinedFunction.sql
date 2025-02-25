USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CountDatePattern]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_CountDatePattern] (@String varchar(max))
returns int
as
begin

--declare @string varchar(max) =
--'Ta called to add accompanying child and she is unable to reissue policy as date needs to be backdated..
--***TOOK AUTH FROM TL CLAIRE CAMENZULI AND ADDED THE CHILD****
--Accompanying child added Brodie Godsall Burton DOB 23/01/2006'

    declare 
        @i int = 0,
        @l int

    set @l = patindex('%[0-9]/%[0-9]/[0-9][0-9]%', @string)

    while @l > 0
    begin

        set @i = @i + 1

        set @string = substring(@string, @l + 6, len(@string) - @l)

        set @l = patindex('%[0-9]/%[0-9]/[0-9][0-9]%', @string)

    end

    --print @i

    return @i

end
GO
