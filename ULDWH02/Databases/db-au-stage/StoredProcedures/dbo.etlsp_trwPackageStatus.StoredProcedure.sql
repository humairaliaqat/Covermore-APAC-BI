USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwPackageStatus]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwPackageStatus]

@packagerunlevel		nvarchar(20),
@packageid				int,
@PackageSubGroupID		int,
@LastRunStatus			nvarchar(50)

as

declare @duration			nvarchar(20)
declare @LastRunDescription	nvarchar(2000)



IF @packagerunlevel = 'BEGIN'

BEGIN
	update [db-au-stage].dbo.ETL_trwPackageStatus set LastRunStartDate = CurrentRunStartDate, LastRunEndDate = CurrentRunEndDate, LastRunStatus = CurrentRunStatus, LastRunDescription = CurrentRunDescription
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID

	set @LastRunDescription	= 'Package is Running.'

	update [db-au-stage].dbo.ETL_trwPackageStatus set CurrentRunStartDate = getdate(), CurrentRunEndDate = Null, CurrentRunStatus = @LastRunStatus, CurrentRunDescription = @LastRunDescription
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID

END

ELSE IF @packagerunlevel = 'END'

BEGIN
	update [db-au-stage].dbo.ETL_trwPackageStatus set CurrentRunEndDate = getdate(), CurrentRunStatus = @LastRunStatus, CurrentRunDescription = @LastRunDescription
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID

	select @duration = convert(varchar, CurrentRunEndDate - CurrentRunStartDate, 114) from [db-au-stage].dbo.ETL_trwPackageStatus
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID

	if @LastRunStatus = 'SUCCEED'
	BEGIN
		set @LastRunDescription	= 'Package Executed successfully. Duration:- ' + @duration
	END
	else if @LastRunStatus = 'FAILED'
	BEGIN
		set @LastRunDescription	= 'Package Failed, for more details check the table "ETL_Error_Log". Duration:- ' + @duration
	END

	update [db-au-stage].dbo.ETL_trwPackageStatus set CurrentRunEndDate = getdate(), CurrentRunStatus = @LastRunStatus, CurrentRunDescription = @LastRunDescription
	where PackageID = @packageid and PackageSubGroupID = @PackageSubGroupID
END

--exec etlsp_dimETLPackageStatus 'END', 1, 1, 'SUCCEED'
GO
