USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbMedicalCoding]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-07-05
-- Description:	Process Medical Coding related tables
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_cmdwh_cbMedicalCoding] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-cmdwh]..cbMedicalCoding') is null 
		create table [db-au-cmdwh]..cbMedicalCoding (
			BIRowID bigint not null identity(1,1), 
			CaseKey nvarchar(20) not null, 
			CreatedByKey nvarchar(35), 
			MedicalCodingID int, 
			CaseNo nvarchar(15), 
			RawOutput xml, 
			CreatedBy nvarchar(30), 
			CreatedTimeUTC datetime2, 
			CreatedTimeLocal datetime2, 
			index idx_cbMedicalCoding_BIRowID clustered (BIRowID), 
			index idx_cbMedicalCoding_CaseKey nonclustered (CaseKey), 
			index idx_cbMedicalCoding_MedicalCodingID nonclustered (MedicalCodingID), 
			index idx_cbMedicalCoding_CaseNo nonclustered (CaseNo), 
			index idx_cbMedicalCoding_CreatedTimeUTC nonclustered (CreatedTimeUTC), 
			index idx_cbMedicalCoding_CreatedTimeLocal nonclustered (CreatedTimeLocal) 
		)

	if object_id('[db-au-cmdwh]..cbMedicalCodingType') is null 
		create table [db-au-cmdwh]..cbMedicalCodingType (
			BIRowID bigint not null identity(1,1), 
			Tag varchar(100), 
			[Type] nvarchar(300), 
			index idx_cbMedicalCodingType_BIRowID clustered (BIRowID), 
			index idx_cbMedicalCodingType_Tag nonclustered (Tag)
		)


	if object_id('tempdb..#carebase_MedicalCoding_aucm') is not null
		drop table #carebase_MedicalCoding_aucm

    select *
	into #carebase_MedicalCoding_aucm
	from [db-au-stage]..carebase_MedicalCoding_aucm

	alter table #carebase_MedicalCoding_aucm
	alter column [RawOutput] xml


	-- process [db-au-cmdwh]..cbMedicalCodingType 
	merge [db-au-cmdwh]..cbMedicalCodingType tgt 
	using (
		select 
			a.Tag collate Latin1_General_CI_AS Tag,
			case 
				when a.Tag = 'ACHI' then 'Procedures' 
				else t.[Type]
			end collate Latin1_General_CI_AS [Type]
		from (
			select 
				Id, 
				T2.n.value('local-name(.)', 'varchar(4000)') Tag, 
				T2.n.value('(./VALUE/text())[1]', 'varchar(4000)') Code
			from 
				#carebase_MedicalCoding_aucm
				cross apply [RawOutput].nodes('CRS/ENCOUNTER/CLAIM/child::node()') as T2(n) 
		  ) a left join [db-au-stage]..[carebase_MedicalCodingCodes_aucm] c on c.MedicalCodingId = a.Id and c.Code = a.Code 
			left join [db-au-stage]..[carebase_MedicalCodingCodeTypes_aucm] t on t.id = c.codetypeid
		where 
			a.Tag not in ('RCS', 'ECCSRND', 'ECCSRAW', 'PCCL') 
		group by 
			a.Tag, 
			case 
				when a.Tag = 'ACHI' then 'Procedures' 
				else t.[Type] 
			end  
	) src 
		on tgt.Tag = src.Tag and tgt.[Type] = src.[Type] 
	when not matched by target then 
		insert (Tag, [Type])
		values (src.Tag, src.[Type]);

	
	-- process [db-au-cmdwh]..cbMedicalCoding
	merge [db-au-cmdwh]..cbMedicalCoding tgt
	using (
		select 
			left('AU-' + c.CASE_NO, 20) CaseKey, 
			left('AU-' + c.CreatedBy, 35) CreatedByKey, 
			c.Id MedicalCodingID, 
			c.Case_No CaseNo, 
			c.RawOutput, 
			c.CreatedBy, 
			c.CreatedTime CreatedTimeUTC,
			[db-au-stage].dbo.xfn_ConvertUTCtoLocal(c.CreatedTime, 'AUS Eastern Standard Time') CreatedTimeLocal 
		from 
			#carebase_MedicalCoding_aucm c
	) src 
		on tgt.MedicalCodingID = src.MedicalCodingID 
	when not matched by target then 
		insert (
			CaseKey, 
			CreatedByKey,  
			MedicalCodingID, 
			CaseNo, 
			RawOutput, 
			CreatedBy, 
			CreatedTimeUTC, 
			CreatedTimeLocal
		)
		values (
			src.CaseKey, 
			src.CreatedByKey,  
			src.MedicalCodingID, 
			src.CaseNo, 
			src.RawOutput, 
			src.CreatedBy, 
			src.CreatedTimeUTC, 
			src.CreatedTimeLocal
		);


END
GO
