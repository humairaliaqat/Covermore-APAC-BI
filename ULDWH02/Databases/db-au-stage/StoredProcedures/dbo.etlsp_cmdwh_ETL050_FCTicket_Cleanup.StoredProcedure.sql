USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ETL050_FCTicket_Cleanup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_ETL050_FCTicket_Cleanup]
as
begin

    set nocount on

    exec xp_cmdshell 'move "E:\ETL\Data\Flight Centre\Process\FLT*.*" "E:\ETL\Data\Flight Centre\Ignored\"'

end

GO
