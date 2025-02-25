USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwPackageExecution]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwPackageExecution]

@packageid				int,
@PackageSubGroupID		int,
@packageexecute			int output

as

declare @packagerun		int

IF (select PackageForceLoad from [db-au-stage].dbo.ETL_trwPackageStatus where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID) = 'Y'
BEGIN
	SET @packagerun = 1
	SET @packageexecute = @packagerun
	--SET @startdate = (select DeltaLoadStartDate from [db-au-stage].dbo.ETL_trwPackageStatus where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID)
	--SET @enddate = (select DeltaLoadToDate from [db-au-stage].dbo.ETL_trwPackageStatus where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID)
	--RETURN
END
ELSE IF ((select isnull(PackageLoadType, '') + '' + isnull(convert(varchar, datediff(dd, convert(date, CurrentRunEndDate), convert(date, getdate()))), '') + '' + isnull(CurrentRunStatus, '')
	from [db-au-stage].dbo.ETL_trwPackageStatus
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID) <> 'F0SUCCEED')
	AND
	((select isnull(PackageLoadType, '') + '' + isnull(convert(varchar, datediff(dd, convert(date, CurrentRunEndDate), convert(date, getdate()))), '') + '' + isnull(CurrentRunStatus, '')
	from [db-au-stage].dbo.ETL_trwPackageStatus
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID) <> 'D0SUCCEED')	
BEGIN 
	SET @packagerun = 1
	SET @packageexecute = @packagerun

	--SET @startdate = (select DeltaLoadStartDate from [db-au-stage].dbo.ETL_trwPackageStatus where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID)
	--SET @enddate = (select DeltaLoadToDate from [db-au-stage].dbo.ETL_trwPackageStatus where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID)
	--RETURN
END
ELSE
BEGIN
	SET @packagerun = 0
	SET @packageexecute = @packagerun	
END
RETURN

--DECLARE @packageexecuteyn		int

--exec sp_ETLPackageExecution 1, 6, @packageexecute = @packageexecuteyn OUTPUT--, @startdate = @startdate output, @enddate = @enddate output

--select @packageexecuteyn as packageexecuteyn--, @startdate, @enddate
GO
