USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_write_error_log]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_write_error_log]
as

declare @ErrorMessage nvarchar(4000);
declare @ErrorSeverity int;
declare @ErrorState int

insert into dbo.etl_error_log
select
  getdate(),
  ERROR_NUMBER(),
  ERROR_SEVERITY(),
  ERROR_STATE(),
  ERROR_PROCEDURE(),
  ERROR_LINE(),
  ERROR_MESSAGE()


SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
RAISERROR (@ErrorMessage, -- Message text.
           @ErrorSeverity, -- Severity.
           @ErrorState -- State.
           );
GO
