USE [db-au-actuary]
GO
/****** Object:  UserDefinedFunction [ws].[getGLMMapping]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [ws].[getGLMMapping]
(
    @FactorName varchar(255),
    @OriginalValue varchar(500)
)
returns varchar(500)
as
begin

    declare @MappedValue varchar(500)
    
    select 
        @MappedValue = [Mapped Value]
    from
        ws.GLMMapping
    where
        [Factor Name] = @FactorName and
        [Original Value] = @OriginalValue

    return @MappedValue

end
GO
