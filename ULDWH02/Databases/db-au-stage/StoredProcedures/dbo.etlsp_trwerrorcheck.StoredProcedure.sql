USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwerrorcheck]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[etlsp_trwerrorcheck]

	@Category		varchar(100),
	@Table_Name		varchar(1000),
	@cnt_check_opt	int output

as 

declare	@cnt_check	int
declare @sql		nvarchar(4000)

--SET @Category = 'StarDimension'
--SET @Table_Name = 'dbPolicies'

SET @Table_Name = REPLACE(@Table_Name, ',', ''',''')
SET @Table_Name =  '''' + @Table_Name + ''''

SET @sql = 'select @cnt_check = count(1)
			from
			(
				select Package_ID, Package_Name, a.Package_Start_Time
				from [DB-AU-LOG].dbo.Package_Run_Details a
				inner join
						(
							select max(batch_id) LOGID, max(Batch_Start_Time) Package_Start_Time
							from [DB-AU-LOG].dbo.Batch_Run_Status with (nolock)
							where Subject_Area = ''' + @Category + ''' and Batch_Status = ''Running'' and batch_date = convert(date, getdate())
						) b
					on a.batch_id = b.LOGID and a.Package_Start_Time = b.Package_Start_Time
					) x
				inner join [DB-AU-LOG].dbo.Package_Error_Log y
				on x.Package_ID = y.Package_ID
					and x.Package_Name = y.source_table
				where y.Insert_Date >= x.Package_Start_Time'


exec sp_executesql @sql, N'@cnt_check int out', @cnt_check_opt out
GO
