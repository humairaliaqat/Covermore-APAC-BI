USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyImportUK]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyImportUK]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20140117
Prerequisite:   Requires Penguin Data Loader UK ETL successfully run.
Description:
Change History:
                20140117 - LT - Procedure created for Penguin Data Loader UK
                20140620 - LS - TFS 12623, bring in Policy Renewal data
                20140805 - LT - TFS 13021, changed PolicyNumber from bigint to varchar(50)
                20150408 - LS - TFS 15452, add Comment
				20150529 - LT - Added QuoteID and DomainID columns to penPolicyRenewalBatch
				20180613 - LT - added Agent column to penPolicyImport
*************************************************************************************************************************************/

    set nocount on

    /*************************************************************/
    --select data into temporary table
    /*************************************************************/
    if object_id('etl_penPolicyImportUK') is not null
        drop table etl_penPolicyImportUK


    select
        i.CountryKey,
        i.CompanyKey,
        i.DomainKey,
        left(PrefixKey + convert(varchar,d.ID),41) collate database_default as PolicyImportKey,
        left(PrefixKey + convert(varchar,d.DataImportID),41) collate database_default as DataImportKey,
        d.ID,
        d.DataImportID,
        d.PolicyXML,
        dbo.xfn_ConvertUTCtoLocal(d.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(d.UpdateDateTime, TimeZone) as UpdateDateTime,
        d.Status,
        d.PolicyStatus,
        d.PolicyID,
        d.RowID,
        d.PolicyNumber,
        d.ParentID,
        d.BusinessUnit,
        d.UnAdjustedTotal,
        d.AdjustedTotal,
        d.PenguinUnAdjustedTotal,
        convert(varchar,d.RowID) + '-' + convert(varchar,isnull(d.PolicyNumber,0)) as RowIDPolicyNumber,
        Comment,
		Agent
    into etl_penPolicyImportUK
    from
        penguin_tblPolicyImport_ukcm d
        inner join [db-au-cmdwh].dbo.penDataImport i on
            d.DataImportID = i.ID and
            i.CountryKey = 'UK' and
			i.DomainKey not like '__-__-'
        inner join penguin_tblJob_ukcm j on
            i.JobID = j.JobID
        cross apply dbo.fn_GetDomainKeys(j.DomainID, 'CM', 'UK') dk

    /*************************************************************/
    --delete existing job data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penPolicyImport') is null
    begin

        create table [db-au-cmdwh].dbo.penPolicyImport
        (
            CountryKey varchar(2) null,
            CompanyKey varchar(3) null,
            DomainKey varchar(41) null,
            PolicyImportKey varchar(41) null,
            DataImportKey varchar(41) null,
            ID int null,
            DataImportID int null,
            PolicyXML XML null,
            CreateDateTime datetime null,
            UpdateDateTime datetime null,
            [Status] varchar(15) null,
            PolicyStatus varchar(15) null,
            PolicyID int null,
            RowID int null,
            PolicyNumber varchar(50) null,
            ParentID int null,
            BusinessUnit nvarchar(50) null,
            UnAdjustedTotal money null,
            AdjustedTotal money null,
            PenguinUnAdjustedTotal money null,
            RowIDPolicyNumber varchar(100) null,
            Comment nvarchar(1000) null,
			Agent nvarchar(2000) null
        )

        create clustered index idx_penPolicyImport_PolicyImportKey on [db-au-cmdwh].dbo.penPolicyImport(PolicyImportKey)
        create index idx_penPolicyImport_CountryKey on [db-au-cmdwh].dbo.penPolicyImport(CountryKey)
        create index idx_penPolicyImport_CompanyKey on [db-au-cmdwh].dbo.penPolicyImport(CompanyKey)
        create index idx_penPolicyImport_DataImportKey on [db-au-cmdwh].dbo.penPolicyImport(DataImportKey)
        create index idx_penPolicyImport_PolicyNumber on [db-au-cmdwh].dbo.penPolicyImport(PolicyNumber)
        create index idx_penPolicyImport_RowIDPolicyNumber on [db-au-cmdwh].dbo.penPolicyImport(RowIDPolicyNumber)
		create index idx_penPolicyImport_RowID on [db-au-cmdwh].dbo.penPolicyImport(RowID)
        create index idx_penPolicyImport_ID on [db-au-cmdwh].dbo.penPolicyImport(ID)
        create nonclustered index idx_penPolicyImport_Status ON [db-au-cmdwh].dbo.penPolicyImport([Status])
							include([ID],[PolicyXML],[PolicyStatus],[PolicyID],[RowID],[PolicyNumber],[BusinessUnit],[AdjustedTotal],[RowIDPolicyNumber])


    end
    else
    begin

        delete [db-au-cmdwh].dbo.penPolicyImport
        from [db-au-cmdwh].dbo.penPolicyImport a
            inner join etl_penPolicyImportUK b on
                a.PolicyImportKey = b.PolicyImportKey
    end


    /*************************************************************/
    -- Transfer data from etl_penDataImport to [db-au-cmdwh].dbo.penDataImport
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penPolicyImport with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        PolicyImportKey,
        DataImportKey,
        ID,
        DataImportID,
        PolicyXML,
        CreateDateTime,
        UpdateDateTime,
        [Status],
        PolicyStatus,
        PolicyID,
        RowID,
        PolicyNumber,
        ParentID,
        BusinessUnit,
        UnAdjustedTotal,
        AdjustedTotal,
        PenguinUnAdjustedTotal,
        RowIDPolicyNumber,
        Comment,
		Agent
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PolicyImportKey,
        DataImportKey,
        ID,
        DataImportID,
        PolicyXML,
        CreateDateTime,
        UpdateDateTime,
        [Status],
        PolicyStatus,
        PolicyID,
        RowID,
        PolicyNumber,
        ParentID,
        BusinessUnit,
        UnAdjustedTotal,
        AdjustedTotal,
        PenguinUnAdjustedTotal,
        RowIDPolicyNumber,
        Comment,
		Agent
    from
        etl_penPolicyImportUK


    /* policy renewal */
    if object_id('etl_penPolicyRenewalBatchUK') is not null
        drop table etl_penPolicyRenewalBatchUK

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, prb.PolicyRenewalBatchId) PolicyRenewalBatchKey,
        PrefixKey + convert(varchar, prbt.PolicyRenewalBatchTransactionId) BatchTransactionKey,
        PrefixKey + convert(varchar, prbt.PolicyId) PolicyKey,
        PrefixKey + convert(varchar, prbt.QuoteId) QuoteCountryKey,
        prb.JobID,
        prb.PolicyRenewalBatchId BatchID,
        prbt.PolicyRenewalBatchTransactionId BatchTransactionID,
        prb.Status BatchStatus,
        prbt.Status BatchTransactionStatus,
        prbt.PolicyIssued IsPolicyIssued,
        dbo.xfn_ConvertUTCtoLocal(prb.CreateDateTime, dk.TimeZone) BatchCreateDate,
        dbo.xfn_ConvertUTCtoLocal(prb.UpdateDateTime, dk.TimeZone) BatchUpdateDate,
        dbo.xfn_ConvertUTCtoLocal(prbt.CreateDateTime, dk.TimeZone) BatchTransactionCreateDate,
        dbo.xfn_ConvertUTCtoLocal(prbt.UpdateDateTime, dk.TimeZone) BatchTransactionUpdateDate,
		prbt.QuoteId,
		j.DomainID
    into etl_penPolicyRenewalBatchUK
    from
        penguin_tblPolicyRenewalBatch_ukcm prb
        inner join penguin_tblPolicyRenewalBatchTransaction_ukcm prbt on
            prbt.PolicyRenewalBatchId = prb.PolicyRenewalBatchId
        inner join penguin_tblJob_ukcm j on
            j.JobID = prb.JobId
        cross apply dbo.fn_GetDomainKeys(j.DomainID, 'CM', 'UK') dk


    /*************************************************************/
    --delete existing batch data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penPolicyRenewalBatch') is null
    begin

        create table [db-au-cmdwh].dbo.penPolicyRenewalBatch
        (
            BIRowID bigint not null identity (1,1),
            CountryKey varchar(2) null,
            CompanyKey varchar(3) null,
            DomainKey varchar(41) null,
            PolicyRenewalBatchKey varchar(41) null,
            BatchTransactionKey varchar(41) null,
            PolicyKey varchar(41) null,
            QuoteCountryKey varchar(41) null,
            JobID int null,
            BatchID int null,
            BatchTransactionID int null,
            BatchStatus varchar(50) null,
            BatchTransactionStatus varchar(50) null,
            IsPolicyIssued bit null,
            BatchCreateDate datetime null,
            BatchUpdateDate datetime null,
            BatchTransactionCreateDate datetime null,
            BatchTransactionUpdateDate datetime null,
			QuoteID int null,
			DomainID int null
        )

        create clustered index idx_penPolicyRenewalBatch_BIRowID on [db-au-cmdwh].dbo.penPolicyRenewalBatch(BIRowID)
        create nonclustered index idx_penPolicyRenewalBatch_CountryKey on [db-au-cmdwh].dbo.penPolicyRenewalBatch(CountryKey)
        create nonclustered index idx_penPolicyRenewalBatch_BatchCreateDate on [db-au-cmdwh].dbo.penPolicyRenewalBatch(BatchCreateDate) include(PolicyKey,QuoteCountryKey,CountryKey,BatchStatus,BatchTransactionStatus,IsPolicyIssued)
		create nonclustered index idx_penPolicyRenewalBatch_QuoteID on [db-au-cmdwh].dbo.penPolicyRenewalBatch(QuoteID)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penPolicyRenewalBatch a
            inner join etl_penPolicyRenewalBatchUK b on
                a.BatchTransactionKey = b.BatchTransactionKey

    end


    /*************************************************************/
    -- Transfer data
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penPolicyRenewalBatch with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        PolicyRenewalBatchKey,
        BatchTransactionKey,
        PolicyKey,
        QuoteCountryKey,
        JobID,
        BatchID,
        BatchTransactionID,
        BatchStatus,
        BatchTransactionStatus,
        IsPolicyIssued,
        BatchCreateDate,
        BatchUpdateDate,
        BatchTransactionCreateDate,
        BatchTransactionUpdateDate,
		QuoteID,
		DomainID
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PolicyRenewalBatchKey,
        BatchTransactionKey,
        PolicyKey,
        QuoteCountryKey,
        JobID,
        BatchID,
        BatchTransactionID,
        BatchStatus,
        BatchTransactionStatus,
        IsPolicyIssued,
        BatchCreateDate,
        BatchUpdateDate,
        BatchTransactionCreateDate,
        BatchTransactionUpdateDate,
		QuoteID,
		DomainID
    from
        etl_penPolicyRenewalBatchUK

end
GO
