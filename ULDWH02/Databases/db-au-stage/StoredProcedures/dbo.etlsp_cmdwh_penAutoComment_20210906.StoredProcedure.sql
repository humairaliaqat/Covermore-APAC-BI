USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAutoComment_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_penAutoComment_20210906]  
as  
begin  
/*  
20130617 - LS - TFS 7664/8556/8557, UK Penguin  
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.  
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
20140617 - LS - TFS 12416, schema and index cleanup  
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
20150410 - LS - F23793, trading history, preparation for trading status metrics  
20160321 - LT - Penguin 18.0, added US penguin instance  
*/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penAutoComment') is not null  
        drop table etl_penAutoComment  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, AutoCommentID) collate database_default AutoCommentKey,  
        PrefixKey + convert(varchar, OutletID) collate database_default OutletKey,  
        PrefixKey + convert(varchar, CSRID) CSRKey,  
        DomainID,  
        a.AutoCommentID,  
        a.OutletID,  
        a.CSRID,  
        a.AlphaCode,  
        a.AutoComments,  
        dbo.xfn_ConvertUTCtoLocal(a.CommentDate, TimeZone) CommentDate,  
        a.CommentDate CommentDateUTC  
    into etl_penAutoComment  
    from  
        penguin_tblAutoComments_aucm a  
        cross apply dbo.fn_GetOutletDomainKeys(a.OutletID, 'CM', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, AutoCommentID) collate database_default AutoCommentKey,  
        PrefixKey + convert(varchar, OutletID) collate database_default OutletKey,  
        PrefixKey + convert(varchar, CSRID) CSRKey,  
        DomainID,  
        a.AutoCommentID,  
        a.OutletID,  
        a.CSRID,  
        a.AlphaCode,  
        a.AutoComments,  
        dbo.xfn_ConvertUTCtoLocal(a.CommentDate, TimeZone) CommentDate,  
        a.CommentDate CommentDateUTC  
    from  
        penguin_tblAutoComments_autp a  
        cross apply dbo.fn_GetOutletDomainKeys(a.OutletID, 'TIP', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, AutoCommentID) collate database_default AutoCommentKey,  
        PrefixKey + convert(varchar, OutletID) collate database_default OutletKey,  
        PrefixKey + convert(varchar, CSRID) CSRKey,  
        DomainID,  
        a.AutoCommentID,  
        a.OutletID,  
        a.CSRID,  
        a.AlphaCode,  
        a.AutoComments,  
        dbo.xfn_ConvertUTCtoLocal(a.CommentDate, TimeZone) CommentDate,  
        a.CommentDate CommentDateUTC  
    from  
        penguin_tblAutoComments_ukcm a  
        cross apply dbo.fn_GetOutletDomainKeys(a.OutletID, 'CM', 'UK') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, AutoCommentID) collate database_default AutoCommentKey,  
        PrefixKey + convert(varchar, OutletID) collate database_default OutletKey,  
        PrefixKey + convert(varchar, CSRID) CSRKey,  
        DomainID,  
        a.AutoCommentID,  
        a.OutletID,  
        a.CSRID,  
        a.AlphaCode,  
        a.AutoComments,  
        dbo.xfn_ConvertUTCtoLocal(a.CommentDate, TimeZone) CommentDate,  
        a.CommentDate CommentDateUTC  
    from  
        penguin_tblAutoComments_uscm a  
        cross apply dbo.fn_GetOutletDomainKeys(a.OutletID, 'CM', 'US') dk  
  
  
    if object_id('[db-au-cmdwh].dbo.penAutoComment') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penAutoComment]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [AutoCommentKey] varchar(41) null,  
            [OutletKey] varchar(41) null,  
            [CSRKey] varchar(41) null,  
            [AutoCommentID] int null,  
            [OutletID] int null,  
            [CSRID] int null,  
         [AlphaCode] nvarchar(50) null,  
            [AutoComments] nvarchar(max) null,  
            [CommentDate] datetime null,  
            [DomainKey] varchar(41) null,  
            [DomainID] int null,  
            [CommentDateUTC] datetime null  
        )  
  
        create clustered index idx_penAutoComment_AutoCommentKey on [db-au-cmdwh].dbo.penAutoComment(AutoCommentKey)  
        create nonclustered index idx_penAutoComment_CountryKey on [db-au-cmdwh].dbo.penAutoComment(CountryKey)  
        create nonclustered index idx_penAutoComment_CSRKey on [db-au-cmdwh].dbo.penAutoComment(CSRKey)  
        create nonclustered index idx_penAutoComment_OutletKey on [db-au-cmdwh].dbo.penAutoComment(OutletKey)  
  
    end  
    else  
    begin  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penAutoComment a  
            inner join etl_penAutoComment b on  
                a.AutoCommentKey = b.AutoCommentKey  
  
    end  
  
  
    insert [db-au-cmdwh].dbo.penAutoComment with(tablockx)  
    (  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        AutoCommentKey,  
        OutletKey,  
        CSRKey,  
        DomainID,  
        AutoCommentID,  
        OutletID,  
        CSRID,  
        AlphaCode,  
        AutoComments,  
        CommentDate,  
        CommentDateUTC  
    )  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        AutoCommentKey,  
        OutletKey,  
        CSRKey,  
        DomainID,  
        AutoCommentID,  
        OutletID,  
        CSRID,  
        AlphaCode,  
        AutoComments,  
        CommentDate,  
        CommentDateUTC  
    from  
        etl_penAutoComment  
  
  
    -- trading status history  
    if object_id('[db-au-cmdwh].dbo.[penOutletTradingHistory]') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penOutletTradingHistory]  
        (  
            [BIRowID] bigint not null identity(1,1),  
            [OutletKey] varchar(41) null,  
            [StatusChangeDate] datetime null,  
            [OldTradingStatus] nvarchar(40) null,  
            [NewTradingStatus] nvarchar(40) null  
        )  
  
        create clustered index idx_penOutletTradingHistory_BIRowID on [db-au-cmdwh].dbo.penOutletTradingHistory(BIRowID)  
        create nonclustered index idx_penOutletTradingHistory_OutletKey on [db-au-cmdwh].dbo.penOutletTradingHistory(OutletKey,StatusChangeDate desc) include(OldTradingStatus,NewTradingStatus)  
        create nonclustered index idx_penOutletTradingHistory_StatusChangeDate on [db-au-cmdwh].dbo.penOutletTradingHistory(StatusChangeDate) include(OutletKey,OldTradingStatus,NewTradingStatus)  
  
        --initial seed  
  
        insert into [db-au-cmdwh].dbo.[penOutletTradingHistory] with(tablock)  
        (  
            OutletKey,  
            StatusChangeDate,  
            OldTradingStatus,  
            NewTradingStatus  
        )  
        select   
            OutletKey,  
            isnull(CommencementDate, OutletStartDate) StatusChangeDate,  
            null OldTradingStatus,  
            case  
                when exists   
                    (  
                        select null  
                        from  
                            [db-au-cmdwh]..penAutoComment ac  
                        where  
                            ac.OutletKey = o.OutletKey and  
                            AutoComments like '%Status changed from %'  
                    )  
                then  
                    'Prospect'  
                else TradingStatus  
            end NewTradingStatus  
        from  
            [db-au-cmdwh]..penOutlet o  
        where  
            OutletStartDate =   
            (  
                select  
                    min(OutletStartDate)  
                from  
                    [db-au-cmdwh]..penOutlet  r  
                where  
                    r.OutletKey = o.OutletKey  
            )  
  
        insert into [db-au-cmdwh].dbo.[penOutletTradingHistory] with(tablock)  
        (  
            OutletKey,  
            StatusChangeDate,  
            OldTradingStatus,  
            NewTradingStatus  
        )  
        select   
            OutletKey,  
            CommentDate StatusChangeDate,  
            rtrim(ltrim(substring(AutoComments, StartOfOldStatus + 6, StartOfNewStatus - StartOfOldStatus - 6))) OldTradingStatus,  
            rtrim(ltrim(substring(AutoComments, StartOfNewStatus + 4, EndOfNewStatus - StartOfNewStatus - 4))) NewTradingStatus  
        from  
            [db-au-cmdwh]..penAutoComment ac  
            cross apply  
            (  
                select  
                    charindex('Status changed from', AutoComments) StatusChanged  
            ) sc  
            cross apply  
            (  
                select  
                    charindex(' from ', AutoComments, StatusChanged + 1) StartOfOldStatus  
            ) sos  
            cross apply  
            (  
                select  
                    charindex(' to ', AutoComments, StatusChanged + 1) StartOfNewStatus  
            ) sns  
            cross apply  
            (  
                select  
                    charindex('.', AutoComments, StartOfNewStatus + 1) EndOfNewStatus  
            ) ens  
        where  
            StatusChanged > 0  
  
    end  
      
      
    if object_id('tempdb..#penOutletTradingHistory') is not null  
        drop table #penOutletTradingHistory  
          
    select   
        OutletKey,  
        CommentDate StatusChangeDate,  
        rtrim(ltrim(substring(AutoComments, StartOfOldStatus + 6, StartOfNewStatus - StartOfOldStatus - 6))) OldTradingStatus,  
        rtrim(ltrim(substring(AutoComments, StartOfNewStatus + 4, EndOfNewStatus - StartOfNewStatus - 4))) NewTradingStatus  
    into #penOutletTradingHistory  
    from  
        etl_penAutoComment ac  
        cross apply  
        (  
            select  
                charindex('Status changed from', AutoComments) StatusChanged  
        ) sc  
        cross apply  
        (  
            select  
                charindex(' from ', AutoComments, StatusChanged + 1) StartOfOldStatus  
        ) sos  
        cross apply  
        (  
            select  
                charindex(' to ', AutoComments, StatusChanged + 1) StartOfNewStatus  
        ) sns  
        cross apply  
        (  
            select  
                charindex('.', AutoComments, StartOfNewStatus + 1) EndOfNewStatus  
        ) ens  
    where  
        StatusChanged > 0  
          
    delete oth  
    from  
        #penOutletTradingHistory t  
        inner join [db-au-cmdwh].dbo.penOutletTradingHistory oth on  
            oth.OutletKey = t.OutletKey and  
            oth.StatusChangeDate = t.StatusChangeDate  
  
    insert into [db-au-cmdwh].dbo.[penOutletTradingHistory] with(tablock)  
    (  
        OutletKey,  
        StatusChangeDate,  
        OldTradingStatus,  
        NewTradingStatus  
    )  
    select  
        OutletKey,  
        StatusChangeDate,  
        OldTradingStatus,  
        NewTradingStatus  
    from  
        #penOutletTradingHistory  
          
           
end  
  
  
GO
