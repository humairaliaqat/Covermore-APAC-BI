USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDataUpdateFromDocuments]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dane Murray
-- Create date: 2018-01-19
-- Description:	Generic procedure to update DWH with information based within Documents.
--	#1: Adjust pnpServiceEventActivity for Contact Fee override dates
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDataUpdateFromDocuments] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare
		@batchid int,
		@start date,
		@end date,
		@name varchar(100),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

	begin transaction
    begin try

		--#1 Update the Schedule Start and End Dates based upon an override in the document in Penelope saved against the Group Event - used only in Contract Fees.
		UPDATE sea
			SET ScheduleStartDate = CAST(pvt.[Contract Fee Start Date] as date),
				ScheduleEndDate = CAST(pvt.[Contract Fee End Date] as date)
		output 'update' into @mergeoutput
		--select *
		from [db-au-dtc].dbo.pnpServiceEventActivity sea
		JOIN [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK
		JOIN (select	cd.RelatedGroupEventID,
						cda.Question, 
						CASE cda.QuestionType 
							WHEN 'Date' THEN cast(cda.AnswerDate as varchar(20))
							WHEN 'Yes/No' THEN CAST(cda.AnswerYN as varchar(1))
						END as QuestionAnswer,
						cd.CompletedDocumentID
				from [db-au-dtc].dbo.pnpCompletedDocument cd
				JOIN [db-au-dtc].dbo.pnpCompletedDocumentAnswer cda ON cd.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
				WHERE cd.RelatedGroupEventID IS NOT NULL) src
				pivot(
					max(QuestionAnswer)
					for [Question] IN ([Contract Fee Start Date],[Contract Fee End Date],[Manual Accrual])
				) pvt on pvt.RelatedGroupEventID = se.WorkshopSessionID
		WHERE (IsNull(ScheduleStartDate,'19000101') <> IsNull(CAST(pvt.[Contract Fee Start Date] as date),'19000101') 
			OR IsNull(ScheduleEndDate,  '19000101') <> IsNull(CAST(pvt.[Contract Fee End Date]   as date),'19000101'))

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

	end try

	begin catch

		if @@trancount > 0
			rollback transaction

		exec syssp_genericerrorhandler
			@SourceInfo = 'data refresh failed',
			@LogToTable = 1,
			@ErrorCode = '-100',
			@BatchID = @batchid,
			@PackageID = @name

	end catch

	if @@trancount > 0
		commit transaction

Finish:	

END
GO
