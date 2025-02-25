USE [db-au-actuary]
GO
/****** Object:  UserDefinedFunction [ws].[fn_parsecomment]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [ws].[fn_parsecomment]
(
    @Comment varchar(max)
)
returns @out table
(
    depart_date_old date,
    depart_date_new date,
    return_date_old date,
    return_date_new date
)
as
begin

    declare 
        @depart_date_old date,
        @depart_date_new date,
        @return_date_old date,
        @return_date_new date

    set @Comment = ltrim(rtrim(@Comment))

    --Depart date was 03/08/2017, now 03/08/2018
    if @Comment like 'Depart date%'
    begin

        set @depart_date_old = 
            case
                when charindex(', now', @Comment) > 0 then try_convert(date, right(left(@Comment, charindex(', now', @Comment) - 1), 10), 103)
                else null
            end
        
        set @depart_date_new = 
            case
                when charindex(', now', @Comment) > 0 then try_convert(date, substring(@Comment, charindex(', now', @Comment) + 6, 10), 103)
                else null
            end

    end

    --Return date was 23/08/2018, now 26/08/2018
    else if @Comment like 'Return date%'
    begin

        set @return_date_old = 
            case
                when charindex(', now', @Comment) > 0 then try_convert(date, right(left(@Comment, charindex(', now', @Comment) - 1), 10), 103)
                else null
            end
        
        set @return_date_new = 
            case
                when charindex(', now', @Comment) > 0 then try_convert(date, substring(@Comment, charindex(', now', @Comment) + 6, 10), 103)
                else null
            end

    end    

    insert into @out
    (
        depart_date_old,
        depart_date_new,
        return_date_old,
        return_date_new
    )
    select     
        @depart_date_old,
        @depart_date_new,
        @return_date_old,
        @return_date_new

    return

end
GO
