USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmOnlineClaimEvent_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_clmOnlineClaimEvent_20210906]  
as  
begin  
/*  
    20160620, LL, create  
*/  
  
    set nocount on  
  
    exec etlsp_StagingIndex_Claim  
  
    declare  
        @batchid int,  
        @start date,  
        @end date,  
        @name varchar(50),  
        @sourcecount int,  
        @insertcount int,  
        @updatecount int  
  
    declare @mergeoutput table (MergeAction varchar(20))  
  
    exec syssp_getrunningbatch  
        @SubjectArea = 'Claim ODS',  
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
  
    if object_id('[db-au-cmdwh].dbo.clmOnlineClaimEvent') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmOnlineClaimEvent  
        (  
            BIRowID bigint identity(1,1) not null,  
            CountryKey varchar(2) not null,  
            ClaimKey varchar(40),  
            OnlineClaimKey varchar(40) not null,  
            ClaimNo int,  
            OnlineClaimID int not null,  
            EventDateTime datetime,  
            EventCountry nvarchar(50),  
            EventLocation nvarchar(200),  
            PerilCode varchar(5),  
            PerilDescription varchar(65),  
            Detail nvarchar(max),  
            AdditionalDetail nvarchar(max),  
            IllnessPreviousOccurence bit,  
            IllnessOtherTraveller bit,  
            LossHasHCInsurance bit,  
            LossHCClaimable bit,  
            LossHCInsurer nvarchar(max),  
            LossConfirmInsurer bit,  
            LossWithTransportProvider bit,  
            LossConfirmProvider bit,  
            LossType varchar(max),  
            LossWithOthers bit,  
            LossOtherFirstName varchar(max),  
            LossOtherSurname varchar(max),  
            LossOtherTelephone varchar(max),  
            LossOtherEmail varchar(max),  
            LossAuthorityNotified bit,  
            LossAuthorityReference varchar(max),  
            LossAuthorityExplanation varchar(max),  
            CanxUnforseenReason varchar(max),  
            CanxOutOfControlReason varchar(max),  
            DelayPlannedDepartDate datetime,  
            DelayActualDepartDate datetime,  
            DelayDueToWeather bit,  
            LuggageFlightArriveDate datetime,  
            LuggageReceivedDate datetime,  
            LuggageCount int,  
            LuggageDelayedCount int,  
            LuggageReturned bit,  
            VehicleExcess money,  
            VehiclePerilType varchar(max),  
            VehicleOnUnsealedSurface bit,  
            VehicleCost money  
        )  
  
        create clustered index idx_clmOnlineClaimEvent_BIRowID on [db-au-cmdwh].dbo.clmOnlineClaimEvent(BIRowID)  
        create nonclustered index idx_clmOnlineClaimEvent_ClaimKey on [db-au-cmdwh].dbo.clmOnlineClaimEvent(ClaimKey) include(BIRowID,Detail,AdditionalDetail,EventLocation,LossAuthorityNotified)  
        create nonclustered index idx_clmOnlineClaimEvent_ClaimNo on [db-au-cmdwh].dbo.clmOnlineClaimEvent(ClaimNo) include(BIRowID)  
        create nonclustered index idx_clmOnlineClaimEvent_OnlineClaimKey on [db-au-cmdwh].dbo.clmOnlineClaimEvent(OnlineClaimKey)  
        create nonclustered index idx_clmOnlineClaimEvent_EventDate on [db-au-cmdwh].dbo.clmOnlineClaimEvent(EventDateTime)  
  
    end  
  
--select   
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',  
--    COLUMN_NAME + ','  
--from  
--    tempdb.INFORMATION_SCHEMA.COLUMNS  
--where  
--    TABLE_NAME like '#onlineclaimsevent%'  
  
    if object_id('tempdb..#onlineclaimsevent') is not null  
        drop table #onlineclaimsevent  
  
    --events  
    select --top 1000  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, oc.OnlineClaimID) OnlineClaimKey,  
        oc.ClaimId ClaimNo,  
        oc.OnlineClaimID,  
        dbo.xfn_ConvertUTCtoLocal(oce.DateTimeIncident, dk.TimeZone) EventDateTime,  
        oce.Country EventCountry,  
        oce.Location EventLocation,  
        p.KLPERCODE PerilCode,  
        p.KLPERDESC PerilDescription,  
        --DetailDescription RawDetail,  
        coalesce  
        (  
            inj.value('Detail[1]', 'nvarchar(max)'),  
            loss.value('Detail[1]', 'nvarchar(max)'),  
            canx.value('EventDetails[1]', 'nvarchar(max)'),  
            oth.value('Detail[1]', 'nvarchar(max)'),  
            ccd.value('OtherDetails[1]', 'nvarchar(max)'),  
            dlug.value('OtherDetails[1]', 'nvarchar(max)'),  
            ccvd.value('Detail[1]', 'nvarchar(max)'),  
            ''  
        ) Detail,  
        coalesce  
        (  
            inj.value('OtherDetails[1]', 'nvarchar(max)'),  
            loss.value('OtherDetails[1]', 'nvarchar(max)'),  
            canx.value('OtherDetails[1]', 'nvarchar(max)'),  
            oth.value('OtherDetails[1]', 'nvarchar(max)'),  
            ccvd.value('OtherDetails[1]', 'nvarchar(max)'),  
            ''  
        ) AdditionalDetail,  
        isnull(try_convert(bit, inj.value('HavePreviousOccurrences[1]', 'varchar(max)')), 0) IllnessPreviousOccurence,  
        isnull(try_convert(bit, inj.value('OtherTraveller[1]', 'varchar(max)')), 0) IllnessOtherTraveller,  
        isnull(try_convert(bit, loss.value('Insured[1]', 'varchar(max)')), 0) LossHasHCInsurance,  
        isnull(try_convert(bit, loss.value('CanClaim[1]', 'varchar(max)')), 0) LossHCClaimable,  
        loss.value('Insurer[1]', 'nvarchar(max)') LossHCInsurer,  
        isnull(try_convert(bit, loss.value('ConfirmInsurer[1]', 'varchar(max)')), 0) LossConfirmInsurer,  
        isnull(try_convert(bit, loss.value('IsInCare[1]', 'varchar(max)')), 0) LossWithTransportProvider,  
        isnull(try_convert(bit, loss.value('ConfirmProvider[1]', 'varchar(max)')), 0) LossConfirmProvider,  
        loss.value('ClaimType[1]', 'varchar(max)') LossType,  
        isnull(try_convert(bit, loss.value('WithOthers[1]', 'varchar(max)')), 0) LossWithOthers,  
        loss.value('OtherFirstName[1]', 'varchar(max)') LossOtherFirstName,  
        loss.value('OtherSurname[1]', 'varchar(max)') LossOtherSurname,  
        loss.value('OtherTel[1]', 'varchar(max)') LossOtherTelephone,  
        loss.value('OtherEmail[1]', 'varchar(max)') LossOtherEmail,  
        isnull(try_convert(bit, loss.value('IsAuthNotified[1]', 'varchar(max)')), 0) LossAuthorityNotified,  
        loss.value('RefNumber[1]', 'varchar(max)') LossAuthorityReference,  
        loss.value('Explanation[1]', 'varchar(max)') LossAuthorityExplanation,  
        canx.value('Unforseen[1]', 'varchar(max)') CanxUnforseenReason,  
        canx.value('OutControl[1]', 'varchar(max)') CanxOutOfControlReason,  
        try_convert(datetime, ccd.value('Depart[1]', 'varchar(max)')) DelayPlannedDepartDate,  
        try_convert(datetime, ccd.value('ActDepart[1]', 'varchar(max)')) DelayActualDepartDate,  
        isnull(try_convert(bit, ccd.value('IsWeather[1]', 'varchar(max)')), 0) DelayDueToWeather,  
        try_convert(datetime, dlug.value('FlightArrive[1]', 'varchar(max)')) LuggageFlightArriveDate,  
        try_convert(datetime, dlug.value('LugReceived[1]', 'varchar(max)')) LuggageReceivedDate,  
        try_convert(int, dlug.value('NumLug[1]', 'varchar(max)')) LuggageCount,  
        try_convert(int, dlug.value('NumDelayLug[1]', 'varchar(max)')) LuggageDelayedCount,  
        isnull(try_convert(bit, dlug.value('LugNeverReturned[1]', 'varchar(max)')), 0) LuggageReturned,  
        try_convert(money, ccvd.value('Excess[1]', 'varchar(max)')) VehicleExcess,  
        ccvd.value('ClaimType[1]', 'varchar(max)') VehiclePerilType,  
        isnull(try_convert(bit, ccvd.value('IsUnealed[1]', 'varchar(max)')), 0) VehicleOnUnsealedSurface,  
        try_convert(money, ccvd.value('Cost[1]', 'varchar(max)')) VehicleCost  
    into #onlineclaimsevent  
    from  
        claims_tblOnlineClaims_au oc   
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'AU') dk  
        inner join claims_tblOnlineClaimEventCauses_au oce on  
            oce.EventCauseId = oc.ClaimCauseId  
        left join claims_KLPERILCODES_au p on  
            p.KLPER_ID = oce.KLPER_ID  
        cross apply  
        (  
            select  
                try_convert(xml, oce.DetailDescription) EventXML  
        ) ex  
        outer apply EventXML.nodes('/ClaimCauseIllHealth') as inj(inj)  
        outer apply EventXML.nodes('/ClaimCauseLoss') as loss(loss)  
        outer apply EventXML.nodes('/ClaimCauseCancel') as canx(canx)  
        outer apply EventXML.nodes('/ClaimCauseOther') as oth(oth)  
        outer apply EventXML.nodes('/ClaimCauseTransDelay') as ccd(ccd)  
        outer apply EventXML.nodes('/ClaimCauseLugDelay') as dlug(dlug)  
        outer apply EventXML.nodes('/ClaimCauseVehicleDamage') as ccvd(ccvd)  
  
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        delete   
        from  
            [db-au-cmdwh].dbo.clmOnlineClaimEvent  
        where  
            OnlineClaimKey in  
            (  
                select  
                    OnlineClaimKey  
                from  
                    #onlineclaimsevent  
            )  
  
        insert into [db-au-cmdwh].dbo.clmOnlineClaimEvent with (tablock)  
        (  
            CountryKey,  
            ClaimKey,  
            OnlineClaimKey,  
            ClaimNo,  
            OnlineClaimID,  
            EventDateTime,  
            EventCountry,  
            EventLocation,  
            PerilCode,  
            PerilDescription,  
            Detail,  
            AdditionalDetail,  
            IllnessPreviousOccurence,  
            IllnessOtherTraveller,  
            LossHasHCInsurance,  
            LossHCClaimable,  
            LossHCInsurer,  
            LossConfirmInsurer,  
            LossWithTransportProvider,  
            LossConfirmProvider,  
            LossType,  
            LossWithOthers,  
            LossOtherFirstName,  
            LossOtherSurname,  
            LossOtherTelephone,  
            LossOtherEmail,  
            LossAuthorityNotified,  
            LossAuthorityReference,  
            LossAuthorityExplanation,  
            CanxUnforseenReason,  
            CanxOutOfControlReason,  
            DelayPlannedDepartDate,  
            DelayActualDepartDate,  
            DelayDueToWeather,  
            LuggageFlightArriveDate,  
            LuggageReceivedDate,  
            LuggageCount,  
            LuggageDelayedCount,  
            LuggageReturned,  
            VehicleExcess,  
            VehiclePerilType,  
            VehicleOnUnsealedSurface,  
            VehicleCost          
        )  
        select  
            CountryKey,  
            ClaimKey,  
            OnlineClaimKey,  
            ClaimNo,  
            OnlineClaimID,  
            EventDateTime,  
            EventCountry,  
            EventLocation,  
            PerilCode,  
            PerilDescription,  
            Detail,  
            AdditionalDetail,  
            IllnessPreviousOccurence,  
            IllnessOtherTraveller,  
            LossHasHCInsurance,  
            LossHCClaimable,  
            LossHCInsurer,  
            LossConfirmInsurer,  
            LossWithTransportProvider,  
            LossConfirmProvider,  
            LossType,  
            LossWithOthers,  
            LossOtherFirstName,  
            LossOtherSurname,  
            LossOtherTelephone,  
            LossOtherEmail,  
            LossAuthorityNotified,  
            LossAuthorityReference,  
            LossAuthorityExplanation,  
            CanxUnforseenReason,  
            CanxOutOfControlReason,  
            DelayPlannedDepartDate,  
            DelayActualDepartDate,  
            DelayDueToWeather,  
            LuggageFlightArriveDate,  
            LuggageReceivedDate,  
            LuggageCount,  
            LuggageDelayedCount,  
            LuggageReturned,  
            VehicleExcess,  
            VehiclePerilType,  
            VehicleOnUnsealedSurface,  
            VehicleCost          
        from  
            #onlineclaimsevent  
  
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
            @SourceInfo = 'clmOnlineClaimEvent data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
  
GO
