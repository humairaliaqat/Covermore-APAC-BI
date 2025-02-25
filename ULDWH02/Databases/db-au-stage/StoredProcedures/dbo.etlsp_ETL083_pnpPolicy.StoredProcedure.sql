USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpPolicy]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpPolicy
-- =============================================
create PROCEDURE [dbo].[etlsp_ETL083_pnpPolicy]
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

    if object_id('[db-au-dtc].dbo.pnpPolicy') is null
    begin
        create table [db-au-dtc].[dbo].[pnpPolicy](
            PolicySK int identity(1,1) primary key,
            FunderSK int,
            PublicPolicyPayableToSiteSK int,
            PayableToSiteSK int,
            PolicyID varchar(50),
            FunderID varchar(50),
            PublicPolicyID varchar(50),
            Class nvarchar(25),
            PublicPolicyFunderID int,
            PublicPolicyName nvarchar(50),
            PublicPolicyNumber nvarchar(25),
            PublicPolicyCategory nvarchar(25),
            PublicPolicyStatus varchar(5),
            PublicPolicyNoShow numeric(6,4),
            PublicPolicyStart datetime2,
            PublicPolicyEnd datetime2,
            PublicPolicyNote nvarchar(4000),
            PublicPolicyCreatedDateTime datetime2,
            PublicPolicyUpdatedDateTime datetime2,
            PublicPolicyType nvarchar(25),
            PublicPolicyDisableFFS varchar(5),
            PublicPolicyPayableToSiteID varchar(50),
            [Type] nvarchar(25),
            PolicyNumber nvarchar(20),
            [Name] nvarchar(25),
            [Status] varchar(20),
            PolicyCon varchar(5),
            Comments nvarchar(4000),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            [Sign] varchar(5),
            Accept varchar(5),
            FunderContactID int,
            Disableffs varchar(5),
            SignDatetime datetime2,
            DisableFeeOvr varchar(5),
            Disabless varchar(5),
            Inclusive varchar(5),
            Corp varchar(5),
            BlueBookID int,
            PriceLevelID int,
            SearchDepartmentTreeForBillTo varchar(5),
            PayableToSiteID varchar(50),
            InvoiceCurrencyCode nvarchar(10),
            InvoiceCurrencyCountry nvarchar(30),
            InvoiceCurrencySign nvarchar(10),
            index idx_pnpPolicy_FunderSK nonclustered (FunderSK),
            index idx_pnpPolicy_PolicyID nonclustered (PolicyID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            f.FunderSK,
            pppts.PublicPolicyPayableToSiteSK,
            pts.PayableToSiteSK,
            convert(varchar, p.kpolicyid) as PolicyID,
            convert(varchar, p.kfunderid) as FunderID,
            convert(varchar, p.kpublicpolicyid) as PublicPolicyID,
            pc.policyclass as Class,
            pp.kfunderid as PublicPolicyFunderID,
            pp.pubpolname as PublicPolicyName,
            pp.pubpolno as PublicPolicyNumber,
            ppc.pubpolcat as PublicPolicyCategory,
            pp.pubpolstatus as PublicPolicyStatus,
            pp.pubpolnoshow as PublicPolicyNoShow,
            pp.pubpolstart as PublicPolicyStart,
            pp.pubpolend as PublicPolicyEnd,
            pp.pubpolnote as PublicPolicyNote,
            --[db-au-stage].dbo.udf_StripHTML(pp.pubpolnote) as PublicPolicyNote,
            pp.slogin as PublicPolicyCreatedDateTime,
            pp.slogmod as PublicPolicyUpdatedDateTime,
            ppt.policytype as PublicPolicyType,
            pp.poldisableffs as PublicPolicyDisableFFS,
            convert(varchar, pp.payabletositeid) as PublicPolicyPayableToSiteID,
            pt.policytype as [Type],
            p.policyno as PolicyNumber,
            p.policyname as Name,
            case when p.policystatus = '1' then 'Active' when p.policystatus = '0' then 'Inactive' end as [Status],
            p.policycon as PolicyCon,
            p.policycomments as Comments,
            --[db-au-stage].dbo.udf_StripHTML(p.policycomments) as Comments,
            p.slogin as CreatedDatetime,
            p.slogmod as UpdatedDatetime,
            p.sloginby as CreatedBy,
            p.slogmodby as UpdatedBy,
            p.polsign as [Sign],
            p.polaccept as Accept,
            p.kpolicycontactid as FunderContactID,
            p.poldisableffs as Disableffs,
            p.polsigndate as SignDatetime,
            p.poldisablefeeovr as DisableFeeOvr,
            p.poldisabless as Disabless,
            p.policyinclusive as Inclusive,
            p.policycorp as Corp,
            p.kbluebookidpolcontact as BlueBookID,
            p.kpricelevelid as PriceLevelID,
            p.searchdepttreeforbillto as SearchDepartmentTreeForBillTo,
            convert(varchar, p.payabletositeid) as PayableToSiteID,
            ic.currencycode as InvoiceCurrencyCode,
            ic.country as InvoiceCurrencyCountry,
            ic.currencysign as InvoiceCurrencySign
        into #src
        from
            penelope_frpolicy_audtc p
            left join penelope_frpublicpolicy_audtc pp on p.kpublicpolicyid = pp.kpublicpolicyid
            left join penelope_lupubpolcat_audtc ppc on pp.lupubpolcatid = ppc.lupubpolcatid
            left join penelope_sapolicytype_audtc ppt on ppt.kpolicytypeid = pp.kpolicytypeid
            left join penelope_sspolicyclass_audtc pc on pc.kpolicyclassid = p.kpolicyclassid
            left join penelope_sapolicytype_audtc pt on pt.kpolicytypeid = p.kpolicytypeid
            left join penelope_sainvoicecurrencysign_audtc ic on ic.kinvoicecurrencysignid = p.kinvoicecurrencysignid
            outer apply (
                select top 1 FunderSK
                from [db-au-dtc].dbo.pnpFunder
                where FunderID = convert(varchar, p.kfunderid) and IsCurrent = 1
            ) f
            outer apply (
                select top 1 SiteSK PublicPolicyPayableToSiteSK
                from [db-au-dtc]..pnpSite
                where SiteID = convert(varchar, pp.payabletositeid)
            ) pppts
            outer apply (
                select top 1 SiteSK PayableToSiteSK
                from [db-au-dtc]..pnpSite
                where SiteID = convert(varchar, p.payabletositeid)
            ) pts

        --20180607, LL, move udf to update statement
        update #src
        set
            PublicPolicyNote = [db-au-stage].dbo.xfn_StripHTML(PublicPolicyNote),
            Comments = [db-au-stage].dbo.xfn_StripHTML(Comments)

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpPolicy as tgt
        using #src
            on #src.PolicyID = tgt.PolicyID
        when matched then
            update set
                tgt.FunderSK = #src.FunderSK,
                tgt.PublicPolicyPayableToSiteSK = #src.PublicPolicyPayableToSiteSK,
                tgt.PayableToSiteSK = #src.PayableToSiteSK,
                tgt.FunderID = #src.FunderID,
                tgt.PublicPolicyID = #src.PublicPolicyID,
                tgt.Class = #src.Class,
                tgt.PublicPolicyFunderID = #src.PublicPolicyFunderID,
                tgt.PublicPolicyName = #src.PublicPolicyName,
                tgt.PublicPolicyNumber = #src.PublicPolicyNumber,
                tgt.PublicPolicyCategory = #src.PublicPolicyCategory,
                tgt.PublicPolicyStatus = #src.PublicPolicyStatus,
                tgt.PublicPolicyNoShow = #src.PublicPolicyNoShow,
                tgt.PublicPolicyStart = #src.PublicPolicyStart,
                tgt.PublicPolicyEnd = #src.PublicPolicyEnd,
                tgt.PublicPolicyNote = #src.PublicPolicyNote,
                tgt.PublicPolicyCreatedDateTime = #src.PublicPolicyCreatedDateTime,
                tgt.PublicPolicyUpdatedDateTime = #src.PublicPolicyUpdatedDateTime,
                tgt.PublicPolicyType = #src.PublicPolicyType,
                tgt.PublicPolicyDisableFFS = #src.PublicPolicyDisableFFS,
                tgt.PublicPolicyPayableToSiteID = #src.PublicPolicyPayableToSiteID,
                tgt.[Type] = #src.[Type],
                tgt.PolicyNumber = #src.PolicyNumber,
                tgt.[Name] = #src.[Name],
                tgt.[Status] = #src.[Status],
                tgt.PolicyCon = #src.PolicyCon,
                tgt.Comments = #src.Comments,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdatedBy = #src.UpdatedBy,
                tgt.[Sign] = #src.[Sign],
                tgt.Accept = #src.Accept,
                tgt.FunderContactID = #src.FunderContactID,
                tgt.Disableffs = #src.Disableffs,
                tgt.SignDatetime = #src.SignDatetime,
                tgt.DisableFeeOvr = #src.DisableFeeOvr,
                tgt.Disabless = #src.Disabless,
                tgt.Inclusive = #src.Inclusive,
                tgt.Corp = #src.Corp,
                tgt.BlueBookID = #src.BlueBookID,
                tgt.PriceLevelID = #src.PriceLevelID,
                tgt.SearchDepartmentTreeForBillTo = #src.SearchDepartmentTreeForBillTo,
                tgt.PayableToSiteID = #src.PayableToSiteID,
                tgt.InvoiceCurrencyCode = #src.InvoiceCurrencyCode,
                tgt.InvoiceCurrencyCountry = #src.InvoiceCurrencyCountry,
                tgt.InvoiceCurrencySign = #src.InvoiceCurrencySign
        when not matched by target then
            insert (
                FunderSK,
                PublicPolicyPayableToSiteSK,
                PayableToSiteSK,
                PolicyID,
                FunderID,
                PublicPolicyID,
                Class,
                PublicPolicyFunderID,
                PublicPolicyName,
                PublicPolicyNumber,
                PublicPolicyCategory,
                PublicPolicyStatus,
                PublicPolicyNoShow,
                PublicPolicyStart,
                PublicPolicyEnd,
                PublicPolicyNote,
                PublicPolicyCreatedDateTime,
                PublicPolicyUpdatedDateTime,
                PublicPolicyType,
                PublicPolicyDisableFFS,
                PublicPolicyPayableToSiteID,
                [Type],
                PolicyNumber,
                [Name],
                [Status],
                PolicyCon,
                Comments,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
                [Sign],
                Accept,
                FunderContactID,
                Disableffs,
                SignDatetime,
                DisableFeeOvr,
                Disabless,
                Inclusive,
                Corp,
                BlueBookID,
                PriceLevelID,
                SearchDepartmentTreeForBillTo,
                PayableToSiteID,
                InvoiceCurrencyCode,
                InvoiceCurrencyCountry,
                InvoiceCurrencySign
            )
            values (
                #src.FunderSK,
                #src.PublicPolicyPayableToSiteSK,
                #src.PayableToSiteSK,
                #src.PolicyID,
                #src.FunderID,
                #src.PublicPolicyID,
                #src.Class,
                #src.PublicPolicyFunderID,
                #src.PublicPolicyName,
                #src.PublicPolicyNumber,
                #src.PublicPolicyCategory,
                #src.PublicPolicyStatus,
                #src.PublicPolicyNoShow,
                #src.PublicPolicyStart,
                #src.PublicPolicyEnd,
                #src.PublicPolicyNote,
                #src.PublicPolicyCreatedDateTime,
                #src.PublicPolicyUpdatedDateTime,
                #src.PublicPolicyType,
                #src.PublicPolicyDisableFFS,
                #src.PublicPolicyPayableToSiteID,
                #src.[Type],
                #src.PolicyNumber,
                #src.[Name],
                #src.[Status],
                #src.PolicyCon,
                #src.Comments,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreatedBy,
                #src.UpdatedBy,
                #src.[Sign],
                #src.Accept,
                #src.FunderContactID,
                #src.Disableffs,
                #src.SignDatetime,
                #src.DisableFeeOvr,
                #src.Disabless,
                #src.Inclusive,
                #src.Corp,
                #src.BlueBookID,
                #src.PriceLevelID,
                #src.SearchDepartmentTreeForBillTo,
                #src.PayableToSiteID,
                #src.InvoiceCurrencyCode,
                #src.InvoiceCurrencyCountry,
                #src.InvoiceCurrencySign
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
