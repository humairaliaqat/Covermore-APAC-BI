USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_user_GetDateFormat]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_user_GetDateFormat]
(
    @Date Date
)
RETURNS DATETIME
AS
BEGIN

    declare @DateFormat  DateTime
	DECLARE @ErrorVar INT; 
   
   set @DateFormat =  convert(datetime,@Date)  
    
    SELECT @ErrorVar = @@ERROR
	IF @ErrorVar <> 0 
		BEGIN
			set @DateFormat =  convert(datetime,@Date,103)
		END 

    
    return @DateFormat

END
GO
