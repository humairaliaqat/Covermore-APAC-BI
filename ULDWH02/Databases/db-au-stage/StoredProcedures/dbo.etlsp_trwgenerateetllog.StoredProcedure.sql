USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwgenerateetllog]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwgenerateetllog]

@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@src_rec_cnt		int,
@Error_Code			NVARCHAR(100),
@Error_Description	NVARCHAR(2000),
@SubSource			NVARCHAR(100),
@TaskName			NVARCHAR(100),
@category			NVARCHAR(100),
@batch_status		NVARCHAR(100),
@subject_area		NVARCHAR(100),
@dml				NVARCHAR(10),
@ins_rec_cnt		int,
@upd_rec_cnt		int,
@packageexeid		int,
@packageexesubid	int,
@packageexecute		nvarchar(1) output,
@packageexecute_SD	DATETIME output,
@packageexecute_ED	DATETIME output

as

DECLARE @Insert_Date		DATETIME
DECLARE @maxBatch_ID		int
DECLARE @query				nvarchar(4000)
DECLARE @max_logid			int
DECLARE @ParmDefinition		nvarchar(500)
DECLARE @PackageLoadType	nvarchar(1)
DECLARE @startdate			datetime
DECLARE @enddate			datetime

IF @category = 'Batch_Run_Status' and @dml = 'Insert'
BEGIN

	SET @Insert_Date = getdate()
	SET @subject_area = 'Trawelltag - ' + '' + @subject_area

	insert into [DB-AU-LOG].dbo.Batch_Run_Status (Batch_Date, Batch_Start_Time, Batch_Status, Batch_End_Time, Subject_Area, Batch_To_Date)
	SELECT convert(date, @Insert_Date), @Insert_Date, @batch_status, null, @subject_area, null

END

ELSE IF @category = 'Batch_Run_Status' and @dml = 'Update'
BEGIN

	SET @Insert_Date = getdate()
	SET @subject_area = 'Trawelltag - ' + '' + @subject_area

	select @maxBatch_ID = max(Batch_ID)
	from [DB-AU-LOG].dbo.Batch_Run_Status
	where Subject_Area = @subject_area and Batch_Status = 'Running' and Batch_Date = convert(date, getdate())

	update [DB-AU-LOG].dbo.Batch_Run_Status set Batch_End_Time = @Insert_Date, Batch_To_Date = convert(date, @Insert_Date), Batch_Status = 'Success'
	where Batch_ID = @maxBatch_ID

END

ELSE IF @category = 'Package_Run_Details' and @dml = 'Insert'
BEGIN
	
	SET @Insert_Date = getdate()
	SET @subject_area = 'Trawelltag - ' + '' + @subject_area

	select @maxBatch_ID = max(Batch_ID)
	from [DB-AU-LOG].dbo.Batch_Run_Status
	where Subject_Area = @subject_area and Batch_Status = 'Running' and Batch_Date = convert(date, getdate())


	insert into [DB-AU-LOG].dbo.Package_Run_Details (Batch_ID, Package_ID, Package_Name, Package_Start_Time, Src_Record_Count, Insert_Record_Count, Update_Record_Count, User_Name, Package_End_Time,
										Package_Status)
	SELECT isnull(@maxBatch_ID, 0), @Package_ID, @Package_Name, @Insert_Date, @ins_rec_cnt, @ins_rec_cnt, @upd_rec_cnt, @user_name, NULL, 'Running'

	select @PackageLoadType = PackageLoadType, @startdate = DeltaLoadStartDate, @enddate = DeltaLoadToDate
	from [db-au-stage].dbo.ETL_trwPackageStatus with (nolock)
	where PackageID = @packageexeid and PackageSubGroupID = @packageexesubid

	IF @subject_area like '%Replica%'
	BEGIN
		SET @Package_Name = REPLACE(@Package_Name, 'db', 'trw')
		SET @Package_Name = '[dbo].[ETL_' + @Package_Name + ']'

		if @PackageLoadType = 'F'
		BEGIN
			SET @query = 'TRUNCATE TABLE ' + @Package_Name
		END
		ELSE
		BEGIN
			SET @query = 'TRUNCATE TABLE ' + @Package_Name
			--SET @query = 'DELETE FROM ' + @Package_Name + ' WHERE CreatedDateTime >= ''' + convert(varchar, @startdate, 120) + ''' and CreatedDateTime < ''' + convert(varchar, @enddate, 120) + ''''
			--print @query
		END
	
		--SELECT @query
		Execute(@query)

		SET @packageexecute = @PackageLoadType
		SET @packageexecute_SD = @startdate
		SET @packageexecute_ED = @enddate
	END
END

ELSE IF @category = 'Package_Run_Details' and @dml = 'Update'
BEGIN

	SET @Insert_Date = getdate()
	SET @subject_area = 'Trawelltag - ' + '' + @subject_area

	select @maxBatch_ID = max(Batch_ID)
	from [DB-AU-LOG].dbo.Batch_Run_Status
	where Subject_Area = @subject_area and Batch_Status = 'Running' and Batch_Date = convert(date, getdate())

	IF @subject_area like '%Replica%'
	BEGIN
		SET @ins_rec_cnt = @src_rec_cnt
	END

	update [DB-AU-LOG].dbo.Package_Run_Details set Src_Record_Count = @src_rec_cnt, User_Name = @user_name, Package_End_Time = getdate(), Package_Status = 'Success',
		Insert_Record_Count = isnull(@ins_rec_cnt, 0), Update_Record_Count = isnull(@upd_rec_cnt, 0)

	where Batch_ID = @maxBatch_ID and Package_Name = @Package_Name

END

ELSE IF @category = 'Package_Error_Log'
BEGIN
	
	SET @Insert_Date = getdate()
	SET @subject_area = 'Trawelltag - ' + '' + @subject_area

	select @maxBatch_ID = max(Batch_ID)
	from [DB-AU-LOG].dbo.Batch_Run_Status
	where Subject_Area = @subject_area and Batch_Status = 'Running' and Batch_Date = convert(date, getdate())

	insert into [DB-AU-LOG].dbo.Package_Error_Log (Batch_ID, Package_ID, Source_Table, Record, Target_Table, Target_Field, Error_Code, Error_Description, Insert_Date)
	SELECT isnull(@maxBatch_ID, 0), @Package_ID, @Package_Name, @subject_area, @SubSource, @TaskName, @Error_Code, @Error_Description, @Insert_Date

	update [DB-AU-LOG].dbo.Batch_Run_Status set Batch_End_Time = @Insert_Date, Batch_To_Date = convert(date, @Insert_Date), Batch_Status = 'Failed'
	where Batch_ID = @maxBatch_ID

END

RETURN
GO
