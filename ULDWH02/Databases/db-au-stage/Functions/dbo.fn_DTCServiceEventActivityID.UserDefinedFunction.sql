USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DTCServiceEventActivityID]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dane Murray
-- Create date: 22/02/2018
-- Description:	Return the Service EventActivityID based upon the trx_ctrl_num (or TimesheetControlID)
-- =============================================
CREATE FUNCTION [dbo].[fn_DTCServiceEventActivityID] 
(
	-- Add the parameters for the function here
	@trx_ctrl_num varchar(50)
)
RETURNS varchar(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ServiceEventActivityID varchar(50)

	-- Add the T-SQL statements to compute the return value here
	SELECT @ServiceEventActivityID = 
			case 
				when @trx_ctrl_num like 'S%A%U%' then 
					case 
						when substring(@trx_ctrl_num, charindex('A', @trx_ctrl_num) + 1, charindex('U', @trx_ctrl_num) - charindex('A', @trx_ctrl_num) -2) = '-1' 
							then 'DUMMY_FOR_INDIRECT_EVENT_' + substring(@trx_ctrl_num, 2, charindex('-', @trx_ctrl_num) - 2) 
						else substring(@trx_ctrl_num, charindex('A', @trx_ctrl_num) + 1, charindex('U', @trx_ctrl_num) - charindex('A', @trx_ctrl_num) -2)
					end 
				when @trx_ctrl_num like 'S%A%L%' then
					case
						when substring(@trx_ctrl_num, charindex('A', @trx_ctrl_num) + 1, charindex('L', @trx_ctrl_num) - charindex('A', @trx_ctrl_num) -2) = '-1' 
							then 'DUMMY_FOR_INDIRECT_EVENT_' + substring(@trx_ctrl_num, 2, charindex('-', @trx_ctrl_num) - 2) 
						else substring(@trx_ctrl_num, charindex('A', @trx_ctrl_num) + 1, charindex('L', @trx_ctrl_num) - charindex('A', @trx_ctrl_num) -2)
					end
				else 'CLI_TSH_' + @trx_ctrl_num 
			end

	-- Return the result of the function
	RETURN @ServiceEventActivityID

END
GO
