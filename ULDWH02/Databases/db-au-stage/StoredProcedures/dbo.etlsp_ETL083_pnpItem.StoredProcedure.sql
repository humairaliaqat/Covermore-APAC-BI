USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpItem]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpItem
-- Modification: 20180523 - DM - Adjusted to bring in Indirect Events codes as Cart Items
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpItem] 
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

	if object_id('[db-au-dtc].dbo.pnpItem') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpItem](
			ItemSK int identity(1,1) primary key,
			ItemID varchar(50),
			[Type] nvarchar(20),
			Name nvarchar(100),
			UnitOfMeasurementClass nvarchar(4000),
			UnitOfMeasurementIsTime varchar(5),
			UnitOfMeasurementIsSchedule nvarchar(30),
			UnitOfMeasurementIsName nvarchar(10),
			UnitOfMeasurementIsEquivalent numeric(10,2),
			ItemFee numeric(10,2),
			ProcedureCode nvarchar(50),
			Active varchar(5),
			Class nvarchar(25),
			itemuserdef1 int,
			itemuserdef2 int,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			NameShort nvarchar(10),
			ItemFeeLL numeric(10,2),
			ItemDisabless varchar(5),
			TaxSched nvarchar(30),
			TaxSchedShort nvarchar(4),
			TaxSchedNotes nvarchar(4000),
			Notes nvarchar(4000),
			modifier1 nvarchar(35),
			modifier2 nvarchar(35),
			modifier3 nvarchar(35),
			modifier4 nvarchar(35),
			ItemContact nvarchar(4000),
			--Stream nvarchar(50),
			index idx_pnpItem_ItemID nonclustered (ItemID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			convert(varchar, i.kitemid) as ItemID,
			it.itemtype as [Type],
			i.itemname as Name,
			uomc.uomclass as UnitOfMeasurementClass,
			uomc.istime as UnitOfMeasurementIsTime,
			uoms.uomschedule as UnitOfMeasurementIsSchedule,
			uom.uomname as UnitOfMeasurementIsName,
			uom.equiv as UnitOfMeasurementIsEquivalent,
			i.itemfee as ItemFee,
			i.procedurecode as ProcedureCode,
			i.nractive as Active,
			ic.itemclassname as Class,
			nru1.itemuserdef1 as itemuserdef1,
			nru2.itemuserdef2 as itemuserdef2,
			i.slogin as CreatedDatetime,
			i.slogmod as UpdatedDatetime,
			i.sloginby as CreatedBy,
			i.slogmodby as UpdatedBy,
			i.itemnameshort as NameShort,
			i.itemfeell as ItemFeeLL,
			i.itemdisabless as ItemDisabless,
			t.taxschedname as TaxSched,
			t.taxschedshort as TaxSchedShort,
			t.taxschednotes as TaxSchedNotes,
			i.nrnotes as Notes,
			i.modifier1 as modifier1,
			i.modifier2 as modifier2,
			i.modifier3 as modifier3,
			i.modifier4 as modifier4,
			ict.itemcontact as ItemContact
			--pg.proggroupname as Stream
		into #src
		from 
			penelope_nritem_audtc i
			left join penelope_ssitemtype_audtc it on it.kitemtypeid = i.kitemtypeid
			left join penelope_nruom_audtc uom on uom.kuomid = i.kuomid
			left join penelope_nruoms_audtc uoms on uoms.kuomsid = uom.kuomsid
			left join penelope_ssuomclass_audtc uomc on uomc.kuomclassid = uoms.kuomclassid
			left join penelope_nritemclass_audtc ic on ic.kitemclassid = i.kitemclassid
			left join penelope_lunruser1_audtc nru1 on nru1.lunruser1id = i.lunruser1id
			left join penelope_lunruser2_audtc nru2 on nru2.lunruser2id = i.lunruser2id
			left join penelope_brtaxsched_audtc t on t.ktaxschedid = i.ktaxschedid
			left join penelope_ssitemcontact_audtc ict on ict.kitemcontactid = i.kitemcontactid
			--left join [dbo].[penelope_anpitemgroup_audtc] ig on i.[kitemid] = ig.[kitemid]
			--left join [dbo].[penelope_prcaseprog_audtc] cp on ig.[kcaseprogid] = cp.[kcaseprogid]
			--left join [dbo].[penelope_saproggroup_audtc] pg on cp.[kproggroupid] = pg.[kproggroupid]
		union all
		select  itemID='INDIRECT_' + cast(luaindtypeid as varchar), 
				Type='Indirect', 
				Name=aindtype,
				UnitOfMeasureClass='Time - Hour',
				UnitOfMeasurementIsTime=1,
				UnitOfMeasurementIsSchedule='hours',
				UnitofMeasurementisName='60m',
				UnitOfMeasurementIsEquivalent=1,
				ItemFee=0,
				ProcedureCode = '',
				Active = valisactive,
				Class='Indirect',
				itemuserdef1=null,
				itemuserdef2=null,
				CreatedDatetime=slogin,
				UpdatedDatetime=slogmod,
				CreatedBy = null,
				UpdatedBy = null,
				NameShort = null,
				ItemFeeLL = 0,
				ItemDisabless = 1,
				TaxSched=null,
				TaxSchedShort=null,
				taxSchednotes=null,
				Notes=null,
				modifier1 = CASE aindtype 
						WHEN 'Administration' THEN 'Internal'
						WHEN 'Booking error' THEN 'Internal'
						WHEN 'Leave' THEN 'Leave'
						WHEN 'Live Chat' THEN 'Available'
						WHEN 'Meeting' THEN 'Internal'
						WHEN 'Supervision' THEN 'Internal'
						WHEN 'Training' THEN 'Internal'
						ELSE 'Other' 
					END,
				modifier2 = null,
				modifier3 = null,
				modifier4 = null,
				itemContact = 'Indirect'
		from penelope_luaindtype_audtc

		select @sourcecount = count(*) from #src


		merge [db-au-dtc].dbo.pnpItem as tgt
		using #src
			on #src.ItemID = tgt.ItemID
		when matched then 
			update set 
				tgt.[Type] = #src.[Type],
				tgt.Name = #src.Name,
				tgt.UnitOfMeasurementClass = #src.UnitOfMeasurementClass,
				tgt.UnitOfMeasurementIsTime = #src.UnitOfMeasurementIsTime,
				tgt.UnitOfMeasurementIsSchedule = #src.UnitOfMeasurementIsSchedule,
				tgt.UnitOfMeasurementIsName = #src.UnitOfMeasurementIsName,
				tgt.UnitOfMeasurementIsEquivalent = #src.UnitOfMeasurementIsEquivalent,
				tgt.ItemFee = #src.ItemFee,
				tgt.ProcedureCode = #src.ProcedureCode,
				tgt.Active = #src.Active,
				tgt.Class = #src.Class,
				tgt.itemuserdef1 = #src.itemuserdef1,
				tgt.itemuserdef2 = #src.itemuserdef2,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.NameShort = #src.NameShort,
				tgt.ItemFeeLL = #src.ItemFeeLL,
				tgt.ItemDisabless = #src.ItemDisabless,
				tgt.TaxSched = #src.TaxSched,
				tgt.TaxSchedShort = #src.TaxSchedShort,
				tgt.TaxSchedNotes = #src.TaxSchedNotes,
				tgt.Notes = #src.Notes,
				tgt.modifier1 = #src.modifier1,
				tgt.modifier2 = #src.modifier2,
				tgt.modifier3 = #src.modifier3,
				tgt.modifier4 = #src.modifier4,
				tgt.ItemContact = #src.ItemContact
				--tgt.Stream = #src.Stream
		when not matched by target then 
			insert (
				ItemID,
				[Type],
				Name,
				UnitOfMeasurementClass,
				UnitOfMeasurementIsTime,
				UnitOfMeasurementIsSchedule,
				UnitOfMeasurementIsName,
				UnitOfMeasurementIsEquivalent,
				ItemFee,
				ProcedureCode,
				Active,
				Class,
				itemuserdef1,
				itemuserdef2,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				NameShort,
				ItemFeeLL,
				ItemDisabless,
				TaxSched,
				TaxSchedShort,
				TaxSchedNotes,
				Notes,
				modifier1,
				modifier2,
				modifier3,
				modifier4,
				ItemContact
				--Stream
			)
			values (
				#src.ItemID,
				#src.[Type],
				#src.Name,
				#src.UnitOfMeasurementClass,
				#src.UnitOfMeasurementIsTime,
				#src.UnitOfMeasurementIsSchedule,
				#src.UnitOfMeasurementIsName,
				#src.UnitOfMeasurementIsEquivalent,
				#src.ItemFee,
				#src.ProcedureCode,
				#src.Active,
				#src.Class,
				#src.itemuserdef1,
				#src.itemuserdef2,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.NameShort,
				#src.ItemFeeLL,
				#src.ItemDisabless,
				#src.TaxSched,
				#src.TaxSchedShort,
				#src.TaxSchedNotes,
				#src.Notes,
				#src.modifier1,
				#src.modifier2,
				#src.modifier3,
				#src.modifier4,
				#src.ItemContact
				--#src.Stream
			)

		output $action into @mergeoutput;

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

END


GO
