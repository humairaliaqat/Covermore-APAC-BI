USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpCompletedDocumentAnswer]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Vincent Lam
-- create date:		2017-08-02
-- Description:		Transformation - pnpCompletedDocumentAnswer
-- Change History:	20180821 - YY - Change to update pnpCase.Location with non-blank location address
--					20180821 - YY - Get most recent CompletedDocumentRevisionID and Non-Blank Answertext 
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpCompletedDocumentAnswer]
AS
BEGIN


    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    --declare @mergeoutput table (MergeAction varchar(20))

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

    if object_id('[db-au-dtc].dbo.pnpCompletedDocumentAnswer') is null
    begin
        create table [db-au-dtc].[dbo].[pnpCompletedDocumentAnswer](
            CompletedDocumentAnswerSK int identity(1,1) primary key,
            CompletedDocumentRevisionSK int,
            BookItemSK int,
            CompletedDocumentRevisionBodyID int,
            CompletedDocumentRevisionID int,
            DocumentBodyPartID int,
            BookItemID int,
            QuestionID int,
            Question nvarchar(4000),
            QuestionClassID int,
            QuestionClass nvarchar(30),
            QuestionClassLevel int,
            IsNumberQuestion varchar(5),
            QuestionCreatedDatetime datetime2,
            QuestionUpdatedDatetime datetime2,
            QuestionCreateUserID int,
            QuestionUpdateUserID int,
            QuestionTypeID int,
            QuestionType nvarchar(30),
            QuestionTypeAssess varchar(5),
            QuestionFormatID int,
            QuestionFormat nvarchar(30),
            QuestionInline varchar(5),
            QuestionListGroupID int,
            QuestionListGroup nvarchar(4000),
            QuestionListGroupIsSharedList varchar(5),
            QuestionListGroupDefaultSort varchar(5),
            QuestionListGroupColumns int,
            QuestionListGroupIsScoreList varchar(5),
            QuestionListGroupCreatedDatetime datetime2,
            QuestionListGroupUpdatedDatetime datetime2,
            QuestionListGroupCreateUserID int,
            QuestionListGroupUpdateUserID int,
            QuestionUseOther varchar(5),
            QuestionCommentTypeID int,
            QuestionCommentType nvarchar(30),
            QuestionComment nvarchar(4000),
            QuestionAnswerRequiredTypeID int,
            QuestionAnswerRequiredType nvarchar(30),
            QuestionAbbreviation nvarchar(4000),
            QuestionHelpText nvarchar(4000),
            QuestionDefault nvarchar(4000),
            QuestionDecimalPlaces int,
            QuestionLowerLimit numeric(10,2),
            QuestionUpperLimit numeric(10,2),
            QuestionShowCB varchar(5),
            QuestionShared varchar(5),
            QuestionScored varchar(5),
            QuestionDataQuerySpecKeyID int,
            QuestionDataQueryApplicName nvarchar(4000),
            QuestionDataQueryEntityType nvarchar(35),
            QuestionDataQueryTableKey nvarchar(4000),
            QuestionDataQueryEntityName nvarchar(4000),
            QuestionDataQueryID int,
            QuestionDataQueryCategory nvarchar(4000),
            QuestionDataQueryName nvarchar(4000),
            QuestionDataQueryView nvarchar(4000),
            QuestionDataQueryDateComPopID int,
            QuestionDataQueryIsDataList varchar(5),
            QuestionDataQueryTextForPreview nvarchar(4000),
            QuestionDataQueryTableName nvarchar(4000),
            QuestionDataQueryFieldName nvarchar(4000),
            QuestionLowerEndPointText nvarchar(4000),
            QuestionUpperEndPointText nvarchar(4000),
            QuestionHideNA varchar(5),
            AnswerID int,
            CompletedOther nvarchar(4000),
            CompletedText ntext,
            IsAnswered varchar(5),
            ParentAnswerID int,
            ParentQuestionID int,
            IsValidated varchar(5),
            AnswerYN varchar(5),
            AnswerDate date,
            AnswerNumber numeric(10,2),
            AnswerText ntext,
            UserID varchar(50),
            UserSK int,
            SiteID varchar(50),
            SiteSK int,
            ServiceID varchar(50),
            ServiceSK int,
            DocumentMasterSK int,
            DocumentMasterID int,
            DocumentSection1 nvarchar(4000),
            index idx_pnpCompletedDocumentAnswer_CompletedDocumentRevisionSK nonclustered (CompletedDocumentRevisionSK),
            index idx_pnpCompletedDocumentAnswer_BookItemSK nonclustered (BookItemSK),
            index idx_pnpCompletedDocumentAnswer_CompletedDocumentRevisionBodyID nonclustered (CompletedDocumentRevisionBodyID),
            index idx_pnpCompletedDocumentAnswer_CompletedDocumentRevisionID nonclustered (CompletedDocumentRevisionID),
            index idx_pnpCompletedDocumentAnswer_DocumentBodyPartID nonclustered (DocumentBodyPartID),
            index idx_pnpCompletedDocumentAnswer_BookItemID nonclustered (BookItemID),
            index idx_pnpCompletedDocumentAnswer_QuestionID nonclustered (QuestionID),
            index idx_pnpCompletedDocumentAnswer_AnswerID nonclustered (AnswerID),
            index idx_pnpCompletedDocumentAnswer_ParentAnswerID nonclustered (ParentAnswerID),
            index idx_pnpCompletedDocumentAnswer_ParentQuestionID nonclustered (ParentQuestionID),
            index idx_pnpCompletedDocumentAnswer_UserID nonclustered (UserID),
            index idx_pnpCompletedDocumentAnswer_UserSK nonclustered (UserSK),
            index idx_pnpCompletedDocumentAnswer_SiteID nonclustered (SiteID),
            index idx_pnpCompletedDocumentAnswer_SiteSK nonclustered (SiteSK),
            index idx_pnpCompletedDocumentAnswer_ServiceID nonclustered (ServiceID),
            index idx_pnpCompletedDocumentAnswer_ServiceSK nonclustered (ServiceSK),
            index idx_pnpCompletedDocumentAnswer_Question nonclustered (Question)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null
            drop table #src

        select
            cdrsk.CompletedDocumentRevisionSK,
            bi.BookItemSK,
            cdrb.kcomdocrevbodyid as CompletedDocumentRevisionBodyID,
            cdrb.kcomdocrevid as CompletedDocumentRevisionID,
            cdrb.kpartidbody as DocumentBodyPartID,
            cdrb.kbookitemid as BookItemID,
            p.kpartid as QuestionID,
            convert(nvarchar(4000), p.partname) as Question,
            p.kdocpartclassid as QuestionClassID,
            dpc.docpartclass as QuestionClass,
            dpc.docpartlevel as QuestionClassLevel,
            p.numberpart as IsNumberQuestion,
            p.slogin as QuestionCreatedDatetime,
            p.slogmod as QuestionUpdatedDatetime,
            p.kuseridlogin as QuestionCreateUserID,
            p.kuseridlogmod as QuestionUpdateUserID,
            pq.kpartquestypeid as QuestionTypeID,
            pqt.partquestype as QuestionType,
            pqt.partquesassess as QuestionTypeAssess,
            pq.kpartquesformatid as QuestionFormatID,
            pqf.partquesformat as QuestionFormat,
            pq.quesinline as QuestionInline,
            pq.kqueslistgroupid as QuestionListGroupID,
            qlg.queslistgroup as QuestionListGroup,
            qlg.sharelist as QuestionListGroupIsSharedList,
            qlg.defaultsort as QuestionListGroupDefaultSort,
            qlg.cbcol as QuestionListGroupColumns,
            qlg.isassesslist as QuestionListGroupIsScoreList,
            qlg.slogin as QuestionListGroupCreatedDatetime,
            qlg.slogmod as QuestionListGroupUpdatedDatetime,
            qlg.kuseridlogin as QuestionListGroupCreateUserID,
            qlg.kuseridlogmod as QuestionListGroupUpdateUserID,
            pq.quesuseother as QuestionUseOther,
            pq.kpartquescommtypeid as QuestionCommentTypeID,
            pqct.partquescommtype as QuestionCommentType,
            pq.quescommtext as QuestionComment,
            pq.kpartquesansid as QuestionAnswerRequiredTypeID,
            pqa.partquesans as QuestionAnswerRequiredType,
            pq.abbrev as QuestionAbbreviation,
            pq.queshelptext as QuestionHelpText,
            pq.quesdefault as QuestionDefault,
            pq.decplaces as QuestionDecimalPlaces,
            pq.limitlower as QuestionLowerLimit,
            pq.limitupper as QuestionUpperLimit,
            pq.showcb as QuestionShowCB,
            pq.shareques as QuestionShared,
            pq.isassess as QuestionScored,
            pq.kdocdataqueryspeckeyid as QuestionDataQuerySpecKeyID,
            ddqa.applicname as QuestionDataQueryApplicName,
            et.entityname as QuestionDataQueryEntityType,
            ddqk.docdataquerytablekeyname as QuestionDataQueryTableKey,
            ddqk.docdataquerykeyentitydesc as QuestionDataQueryEntityName,
            pq.kdocdataqueryid as QuestionDataQueryID,
            ddq.dataquerycat as QuestionDataQueryCategory,
            ddq.dataqueryname as QuestionDataQueryName,
            ddq.dataqueryview as QuestionDataQueryView,
            ddq.kdocdataquerydatecompopid as QuestionDataQueryDateComPopID,
            ddq.isdatalist as QuestionDataQueryIsDataList,
            ddq.textforpreview as QuestionDataQueryTextForPreview,
            ddq.snamtable as QuestionDataQueryTableName,
            ddq.snamefield as QuestionDataQueryFieldName,
            pq.lowerendpointtext as QuestionLowerEndPointText,
            pq.upperendpointtext as QuestionUpperEndPointText,
            pq.hidena as QuestionHideNA,
            ca.kcomanswerid as AnswerID,
            ca.comother as CompletedOther,
            ca.comtext as CompletedText,
            ca.isanswered as IsAnswered,
            ca.kcomansweridkey as ParentAnswerID,
            ca.kcompositepartid as ParentQuestionID,
            ca.isvalidated as IsValidated,
            coalesce(ayn.answer, alist.answer, auser.answer, asite.answer, aservice.answer) as AnswerYN,
            adate.answer as AnswerDate,
            coalesce(anumber.answer, qlist.assessval) as AnswerNumber,
            --20180607, LL, move udf to update statement
            coalesce(amemo.answer, qlist.queslist) as AnswerText,
            --[db-au-stage].dbo.udf_StripHTML(coalesce(amemo.answer, qlist.queslist)) as AnswerText,
            convert(varchar(50), auser.kuserid) as UserID,
            usr.UserSK,
            convert(varchar(50), asite.ksiteid) as SiteID,
            st.SiteSK,
            convert(varchar(50), aservice.kagserid) as ServiceID,
            sr.ServiceSK,
            dmsk.DocumentMasterSK,
            dm.kdocmastid as DocumentMasterID,
            sec1.partname as DocumentSection1
        into #src
        from
            penelope_dtcomanswer_audtc ca
            join penelope_dtcomdocrevbody_audtc cdrb on cdrb.kcomdocrevbodyid = ca.kcomdocrevbodyid
            join penelope_dtcomdocrev_audtc cdr on cdr.kcomdocrevid = cdrb.kcomdocrevid
            join penelope_dtcomdoc_audtc cd on cd.kcomdocid = cdr.kcomdocid
            join penelope_drdoc_audtc d on d.kdocid = cd.kdocid
            join penelope_drdocmast_audtc dm on dm.kdocmastid = d.kdocmastid
            left join penelope_drpartques_audtc pq on pq.kpartid = ca.kpartidques
            left join penelope_drpart_audtc p on p.kpartid = pq.kpartid
            left join penelope_ssdocpartclass_audtc dpc on dpc.kdocpartclassid = p.kdocpartclassid
            left join penelope_drqueslistgroup_audtc qlg on qlg.kqueslistgroupid = pq.kqueslistgroupid
            left join penelope_sspartquesformat_audtc pqf on pqf.kpartquesformatid = pq.kpartquesformatid
            left join penelope_sspartquestype_audtc pqt on pqt.kpartquestypeid = pq.kpartquestypeid
            left join penelope_sspartquescommtype_audtc pqct on pqct.kpartquescommtypeid = pq.kpartquescommtypeid
            left join penelope_sspartquesans_audtc pqa on pqa.kpartquesansid = pq.kpartquesansid
            left join penelope_ssdocdataqueryspeckey_audtc ddqsk on ddqsk.kdocdataqueryspeckeyid = pq.kdocdataqueryspeckeyid
            left join penelope_ssdocdataqueryapplic_audtc ddqa on ddqa.kdocdataqueryapplicid = ddqsk.kdocdataqueryapplicid
            left join penelope_ssentitytype_audtc et on et.kentitytypeid = ddqa.kentitytypeidbookitem
            left join penelope_ssdocdataquerykey_audtc ddqk on ddqk.kdocdataquerykeyid = ddqsk.kdocdataquerykeyid
            left join penelope_sadocdataquery_audtc ddq on ddq.kdocdataqueryid = pq.kdocdataqueryid
            left join penelope_dtansweryn_audtc ayn on ayn.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswerdate_audtc adate on adate.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswernumber_audtc anumber on anumber.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswermemo_audtc amemo on amemo.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswerlist_audtc alist on alist.kcomanswerid = ca.kcomanswerid and alist.answer = '1'
            left join penelope_drqueslist_audtc qlist on qlist.kqueslistid = alist.kqueslistid
            left join penelope_dtansweruser_audtc auser on auser.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswersite_audtc asite on asite.kcomanswerid = ca.kcomanswerid
            left join penelope_dtanswerser_audtc aservice on aservice.kcomanswerid = ca.kcomanswerid and aservice.answer = '1'
            outer apply (select top 1 CompletedDocumentRevisionSK from [db-au-dtc]..pnpCompletedDocumentRevision where CompletedDocumentRevisionID = cdrb.kcomdocrevid) cdrsk
            outer apply (select top 1 BookItemSK from [db-au-dtc]..pnpBookItem where BookItemID = cdrb.kbookitemid) bi
            outer apply (select top 1 UserSK from [db-au-dtc]..pnpUser where UserID = convert(varchar(50), auser.kuserid)) usr
            outer apply (select top 1 SiteSK from [db-au-dtc]..pnpSite where SiteID = convert(varchar(50), asite.ksiteid)) st
            outer apply (select top 1 ServiceSK from [db-au-dtc]..pnpService where ServiceID = convert(varchar(50), aservice.kagserid)) sr
            outer apply (select top 1 DocumentMasterSK from [db-au-dtc]..pnpDocumentMaster where DocumentMasterID = dm.kdocmastid) dmsk
            left join (
            select
                ap.kpartiditem,
                sec1.partname,
                pbb.kdocid
            from
                penelope_addpart_audtc ap
                join penelope_drpart_audtc sec1 on sec1.kpartid = ap.kpartid
                join penelope_drpartblock_audtc pb on ap.kpartid = pb.kpartid
                join penelope_drpartblockbody_audtc pbb on pb.kpartidbelongbody = pbb.kpartid
            ) sec1
                on p.kpartid = sec1.kpartiditem and sec1.kdocid = cd.kdocid


        update #src
        set
            AnswerText = [db-au-stage].dbo.xfn_StripHTML(AnswerText)


        select @sourcecount = count(*) from #src

        delete
        from
            [db-au-dtc].dbo.pnpCompletedDocumentAnswer
        where
            CompletedDocumentRevisionBodyID in
            (
                select
                    CompletedDocumentRevisionBodyID
                from #src
            )


        select @updatecount = @@rowcount
        set @insertcount = @sourcecount

        insert into [db-au-dtc].dbo.pnpCompletedDocumentAnswer
        (
            CompletedDocumentRevisionSK,
            BookItemSK,
            CompletedDocumentRevisionBodyID,
            CompletedDocumentRevisionID,
            DocumentBodyPartID,
            BookItemID,
            QuestionID,
            Question,
            QuestionClassID,
            QuestionClass,
            QuestionClassLevel,
            IsNumberQuestion,
            QuestionCreatedDatetime,
            QuestionUpdatedDatetime,
            QuestionCreateUserID,
            QuestionUpdateUserID,
            QuestionTypeID,
            QuestionType,
            QuestionTypeAssess,
            QuestionFormatID,
            QuestionFormat,
            QuestionInline,
            QuestionListGroupID,
            QuestionListGroup,
            QuestionListGroupIsSharedList,
            QuestionListGroupDefaultSort,
            QuestionListGroupColumns,
            QuestionListGroupIsScoreList,
            QuestionListGroupCreatedDatetime,
            QuestionListGroupUpdatedDatetime,
            QuestionListGroupCreateUserID,
            QuestionListGroupUpdateUserID,
            QuestionUseOther,
            QuestionCommentTypeID,
            QuestionCommentType,
            QuestionComment,
            QuestionAnswerRequiredTypeID,
            QuestionAnswerRequiredType,
            QuestionAbbreviation,
            QuestionHelpText,
            QuestionDefault,
            QuestionDecimalPlaces,
            QuestionLowerLimit,
            QuestionUpperLimit,
            QuestionShowCB,
            QuestionShared,
            QuestionScored,
            QuestionDataQuerySpecKeyID,
            QuestionDataQueryApplicName,
            QuestionDataQueryEntityType,
            QuestionDataQueryTableKey,
            QuestionDataQueryEntityName,
            QuestionDataQueryID,
            QuestionDataQueryCategory,
            QuestionDataQueryName,
            QuestionDataQueryView,
            QuestionDataQueryDateComPopID,
            QuestionDataQueryIsDataList,
            QuestionDataQueryTextForPreview,
            QuestionDataQueryTableName,
            QuestionDataQueryFieldName,
            QuestionLowerEndPointText,
            QuestionUpperEndPointText,
            QuestionHideNA,
            AnswerID,
            CompletedOther,
            CompletedText,
            IsAnswered,
            ParentAnswerID,
            ParentQuestionID,
            IsValidated,
            AnswerYN,
            AnswerDate,
            AnswerNumber,
            AnswerText,
            UserID,
            UserSK,
            SiteID,
            SiteSK,
            ServiceID,
            ServiceSK,
            DocumentMasterSK,
            DocumentMasterID,
            DocumentSection1
        )
        select
            CompletedDocumentRevisionSK,
            BookItemSK,
            CompletedDocumentRevisionBodyID,
            CompletedDocumentRevisionID,
            DocumentBodyPartID,
            BookItemID,
            QuestionID,
            Question,
            QuestionClassID,
            QuestionClass,
            QuestionClassLevel,
            IsNumberQuestion,
            QuestionCreatedDatetime,
            QuestionUpdatedDatetime,
            QuestionCreateUserID,
            QuestionUpdateUserID,
            QuestionTypeID,
            QuestionType,
            QuestionTypeAssess,
            QuestionFormatID,
            QuestionFormat,
            QuestionInline,
            QuestionListGroupID,
            QuestionListGroup,
            QuestionListGroupIsSharedList,
            QuestionListGroupDefaultSort,
            QuestionListGroupColumns,
            QuestionListGroupIsScoreList,
            QuestionListGroupCreatedDatetime,
            QuestionListGroupUpdatedDatetime,
            QuestionListGroupCreateUserID,
            QuestionListGroupUpdateUserID,
            QuestionUseOther,
            QuestionCommentTypeID,
            QuestionCommentType,
            QuestionComment,
            QuestionAnswerRequiredTypeID,
            QuestionAnswerRequiredType,
            QuestionAbbreviation,
            QuestionHelpText,
            QuestionDefault,
            QuestionDecimalPlaces,
            QuestionLowerLimit,
            QuestionUpperLimit,
            QuestionShowCB,
            QuestionShared,
            QuestionScored,
            QuestionDataQuerySpecKeyID,
            QuestionDataQueryApplicName,
            QuestionDataQueryEntityType,
            QuestionDataQueryTableKey,
            QuestionDataQueryEntityName,
            QuestionDataQueryID,
            QuestionDataQueryCategory,
            QuestionDataQueryName,
            QuestionDataQueryView,
            QuestionDataQueryDateComPopID,
            QuestionDataQueryIsDataList,
            QuestionDataQueryTextForPreview,
            QuestionDataQueryTableName,
            QuestionDataQueryFieldName,
            QuestionLowerEndPointText,
            QuestionUpperEndPointText,
            QuestionHideNA,
            AnswerID,
            CompletedOther,
            CompletedText,
            IsAnswered,
            ParentAnswerID,
            ParentQuestionID,
            IsValidated,
            AnswerYN,
            AnswerDate,
            AnswerNumber,
            AnswerText,
            UserID,
            UserSK,
            SiteID,
            SiteSK,
            ServiceID,
            ServiceSK,
            DocumentMasterSK,
            DocumentMasterID,
            DocumentSection1
        from
            #src


        --updated funder's documents
        if object_id('tempdb..#funder') is not null
            drop table #funder

        select distinct
            cd.RelatedFunderSK
        into #funder
        from
            #src cda
            inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on
                cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
            inner join [db-au-dtc]..pnpCompletedDocument cd on
                cdr.CompletedDocumentSK = cd.CompletedDocumentSK
        where
            Question in ('Primary Industry', 'Account Manager')


        --update funder details
        update f
        set
            f.AccountManager = isnull(r.AccountManager, f.AccountManager),
            f.PrimaryIndustry = isnull(r.PrimaryIndustry, f.PrimaryIndustry)
        from
            [db-au-dtc]..pnpFunder f
            cross apply
            (
                select top 1
                    cdr.CompletedDocumentRevisionSK
                from
                    [db-au-dtc]..pnpCompletedDocument cd
                    inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on
                        cdr.CompletedDocumentSK = cd.CompletedDocumentSK
                    inner join [db-au-dtc]..pnpDocument d on
                        d.DocumentSK = cd.DocumentSK
                    inner join [db-au-dtc]..pnpDocumentMaster dm on
                        dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    cd.RelatedFunderSK = f.FunderSk and
                    dm.Code = 'FUNDTLS'
                order by
                    cdr.UpdatedDatetime desc
            ) cdr
            outer apply
            (
                select
                    max
                    (
                        case
                            when cda.Question = 'Account Manager' then ltrim(rtrim(u.FirstName)) + ' ' + ltrim(rtrim(u.LastName))
                            else null
                        end
                    ) AccountManager,
                    max
                    (
                        case
                            when cda.Question = 'Primary Industry' then convert(nvarchar(100), cda.AnswerText)
                            else null
                        end
                    ) PrimaryIndustry
                from
                    [db-au-dtc]..pnpCompletedDocumentAnswer cda
                    left join [db-au-dtc]..pnpUser u on
                        u.UserSK = cda.UserSK
                where
                    cda.CompletedDocumentRevisionSK = cdr.CompletedDocumentRevisionSK and
                    cda.Question in ('Primary Industry', 'Account Manager')
            ) r
        where
            f.FunderSk in
            (
                select
                    RelatedFunderSK
                from
                    #funder
            )


        --updated service file's documents
        if object_id('tempdb..#sf') is not null
            drop table #sf

        select distinct
            cd.RelatedServiceFileSK
        into #sf
        from
            #src cda
            inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on
                cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
            inner join [db-au-dtc]..pnpCompletedDocument cd on
                cdr.CompletedDocumentSK = cd.CompletedDocumentSK

        --update sf details
        update sf
        set
            sf.CounsellingType = isnull(r.CounsellingType, sf.CounsellingType)
        from
            [db-au-dtc]..pnpServiceFile sf
            cross apply
            (
                select top 1
                    cdr.CompletedDocumentRevisionSK
                from
                    [db-au-dtc]..pnpCompletedDocument cd
                    inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on
                        cdr.CompletedDocumentSK = cd.CompletedDocumentSK
                where
                    cd.RelatedServiceFileSK = sf.ServiceFileSK and
                    cd.Title = '[CSO] EAP Intake Document'
                order by
                    cdr.UpdatedDatetime desc
            ) cdr
            cross apply
            (
                select
                    max(convert(nvarchar(4000), cda.AnswerText)) CounsellingType
                from
                    [db-au-dtc]..pnpCompletedDocumentAnswer cda
                where
                    cda.CompletedDocumentRevisionSK = cdr.CompletedDocumentRevisionSK and
                    cda.Question = 'What type of appointments was requested'
            ) r
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )

        -- update pnpServiceFile.CPFStatus
        update sf
        set
            sf.CPFStatus =
            case
                when s.DisplayName <> 'employeeAssist' then 'Not Required'
                --when cpf.CPFStatus is not null then cpf.CPFStatus
                when
                    exists
                    (
                        select
                            null
                        from
                            [db-au-dtc]..pnpCompletedDocument d
                            inner join [db-au-dtc]..pnpCompletedDocumentRevision dr on
                                dr.CompletedDocumentSK = d.CompletedDocumentSK
                            inner join [db-au-dtc]..pnpCompletedDocumentAnswer qa on
                                qa.CompletedDocumentRevisionSK = dr.CompletedDocumentRevisionSK
                        where
                            d.RelatedServiceFileSK = sf.ServiceFileSK and
                            d.Title = '[DTC] Agreement to Undertake Support & Privacy Notice' and
                            d.CompletedDocumentRevisionState in ('Finished', 'Locked')
                    ) and
                    exists
                    (
                        select
                            null
                        from
                            [db-au-dtc]..pnpServiceFileMember sfm
                            left join [db-au-dtc]..pnpIndividual i on
                                i.IndividualSK = sfm.IndividualSK
                        where
                            sfm.ServiceFileMemberSK = sf.PresentingServiceFileMemberSK and
                            rtrim(isnull(sfm.PresentingIssue1, '')) not in ('', '[Please select]') and
                            rtrim(isnull(i.State, '')) not in ('', '[Please select]')
                    )
                then 'Complete'
                else 'Incomplete'
            end
        from
            [db-au-dtc]..pnpServiceFile sf
            left join [db-au-dtc]..pnpService s on s.ServiceSK = sf.ServiceSK
            outer apply
            (
                select top 1
                    CPFStatus
                from
                    [db-au-dtc]..usrCPFStatus
                where
                    ServiceFileSK = sf.ServiceFileSK
            ) cpf
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            ) and
            cpf.CPFStatus is null


        -- update pnpServiceFile.RelatedWorkImpact, pnpServiceFile.WorkImpactNature
        ; with sf as (
            select *
            from (
                select
                    RelatedServiceFileID,
                    Question,
                    Answer
                from (
                    select
                        cd.RelatedServiceFileID,
                        case
                            when cda.Question = 'Related Work Impact' then 'Related'
                            when cda.Question = 'Nature of Work Impact' then 'Nature'
                        end as Question,
                        convert(varchar, cda.AnswerText) as Answer,
                        row_number() over(partition by cd.RelatedServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                    from
                        [db-au-dtc]..pnpCompletedDocumentAnswer cda
                        join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                        join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    where
                        cda.Question in ('Nature of Work Impact','Related Work Impact')
                        and cd.Title = '[Associate] employeeAssist Dataform'
                ) x
                where
                    rn = 1
            ) x
            pivot (
                max(Answer)
                for Question IN ([Related], [Nature])
            ) p
        ),
        lng as (
            select *
            from (
                select
                    ServiceFileID,
                    Question,
                    Answer
                from (
                    select
                        se.ServiceFileID,
                        case
                            when cda.Question = 'Related Work Impact' then 'Related'
                            when cda.Question = 'Nature of Work Impact' then 'Nature'
                        end as Question,
                        convert(varchar, cda.AnswerText) as Answer,
                        row_number() over(partition by se.ServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                    from
                        [db-au-dtc]..pnpCompletedDocumentAnswer cda
                        inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                        inner join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                        inner join [db-au-dtc]..pnpServiceEvent se on se.ServiceEventID = cd.RelatedEventID
                    where
                        cda.Question in ('Nature of Work Impact','Related Work Impact')
                        and cd.Title = '[Clinical] EAP 1st Session (Long)'
                ) x
                where
                    rn = 1
            ) x
            pivot (
                max(Answer)
                for Question IN ([Related], [Nature])
            ) p
        ),
        sht as (
            select *
            from (
                select
                    ServiceFileID,
                    Question,
                    Answer
                from (
                    select
                        se.ServiceFileID,
                        case
                            when cda.Question = 'Related Work Impact' then 'Related'
                            when cda.Question = 'Nature of Work Impact' then 'Nature'
                        end as Question,
                        convert(varchar, cda.AnswerText) as Answer,
                        row_number() over(partition by se.ServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                    from
                        [db-au-dtc]..pnpCompletedDocumentAnswer cda
                        join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                        join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                        join [db-au-dtc]..pnpServiceEvent se on se.ServiceEventID = cd.RelatedEventID
                    where
                        cda.Question in ('Nature of Work Impact','Related Work Impact')
                        and cd.Title = '[Clinical] EAP 1st Session (Short)'
                ) x
                where
                    rn = 1
            ) x
            pivot (
                MAX(Answer)
                for Question IN ([Related], [Nature])
            ) p
        ),
        src as (
            select
                coalesce(sf.RelatedServiceFileID, lng.ServiceFileID, sht.ServiceFileID) ServiceFileID,
                case
                    when sf.Related is not null then sf.Related
                    when lng.Related is not null then lng.Related
                    else sht.Related
                end Related,
                case
                    when sf.Related is not null then sf.Nature
                    when lng.Related is not null then lng.Nature
                    else sht.Nature
                end Nature
            from
                sf
                full outer join lng on sf.RelatedServiceFileID = lng.ServiceFileID
                full outer join sht on sht.ServiceFileID = coalesce(sf.RelatedServiceFileID, lng.ServiceFileID)
        )
        update sf
        set
            RelatedWorkImpact = src.Related,
            WorkImpactNature = src.Nature
        from
            [db-au-dtc]..pnpServiceFile sf
            join src on convert(varchar, src.ServiceFileID) = sf.ServiceFileID
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )

        -- update pnpServiceFile.ReferralSource, pnpServiceFile.SelfReferralSource
        ; with t1 as (
            select *
            from (
                select
                    RelatedServiceFileID,
                    Doc1,
                    field,
                    AnswerText
                from (
                    select
                        cd.RelatedServiceFileID,
                        '[DTC] Agreement to Undertake Support & Privacy Notice' Doc1,
                        case
                            when Question = 'How did you hear about EAP?' then 'ReferralSource1'
                            when Question = 'If ''self'' please provide more detail' then 'SelfReferralSource1'
                        end field,
                        convert(varchar(100), AnswerText) AnswerText,
                        row_number() over(partition by cd.RelatedServiceFileID, Question order by cdr.CompletedDocumentRevisionID desc) rn
                    from
                        [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                        join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                        join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                        join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                        join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                    where
                        dm.Title = '[DTC] Agreement to Undertake Support & Privacy Notice'
                        and Question in ('How did you hear about EAP?', 'If ''self'' please provide more detail')
                ) x
                where
                    rn = 1
            ) a
            pivot (
                max(AnswerText)
                for field in (ReferralSource1, SelfReferralSource1)
            ) pvt
        ),
        t2 as (
            select *
            from (
                select
                    RelatedServiceFileID,
                    Doc2,
                    field,
                    AnswerText
                from (
                    select
                        cd.RelatedServiceFileID,
                        '[Associate] employeeAssist Dataform' Doc2,
                        case
                            when Question = 'Referral and EAP Information Source' then 'ReferralSource2'
                            when Question = 'If self, what source?' then 'SelfReferralSource2'
                        end field,
                        convert(varchar(100), AnswerText) AnswerText,
                        row_number() over(partition by cd.RelatedServiceFileID, Question order by cdr.CompletedDocumentRevisionID desc) rn
                    from
                        [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                        join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                        join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                        join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                        join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                    where
                        dm.Title = '[Associate] employeeAssist Dataform'
                        and Question in ('Referral and EAP Information Source', 'If self, what source?')
                ) x
                where
                    rn = 1
            ) a
            pivot (
                max(AnswerText)
                for field in (ReferralSource2, SelfReferralSource2)
            ) pvt
        ),
        src as (
            select
                coalesce(t1.RelatedServiceFileID, t2.RelatedServiceFileID) ServiceFileID,
                t1.Doc1,
                t1.ReferralSource1,
                t1.SelfReferralSource1,
                t2.Doc2,
                t2.ReferralSource2,
                t2.SelfReferralSource2
            from
                t1 full outer join t2 on t1.RelatedServiceFileID = t2.RelatedServiceFileID
        )
        update sf
        set
            ReferralSource = case when src.Doc1 is not null then src.ReferralSource1 else src.ReferralSource2 end,
            SelfReferralSource = case when src.Doc1 is not null then src.SelfReferralSource1 else src.SelfReferralSource2 end
        from [db-au-dtc]..pnpServiceFile sf
            join src on convert(varchar, src.ServiceFileID) = sf.ServiceFileID
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )


        -- update pnpServiceFile.EmploymentPeriod
        ; with t1 as (
            select
                RelatedServiceFileID,
                EmploymentPeriod
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar(100), AnswerText) EmploymentPeriod,
                    row_number() over(partition by cd.RelatedServiceFileID order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                    join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    dm.Title = '[DTC] Agreement to Undertake Support & Privacy Notice'
                    and Question = 'How many years have you been employed at the organisation offering EAP?'
            ) x
            where
                rn = 1
        ),
        t2 as (
            select
                RelatedServiceFileID,
                EmploymentPeriod
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar(100), AnswerText) EmploymentPeriod,
                    row_number() over(partition by cd.RelatedServiceFileID order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                    join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    dm.Title = '[Associate] employeeAssist Dataform'
                    and Question = 'Years Employed at Organisation offering EAP'
            ) x
            where
                rn = 1
        ),
        t3 as (
            select
                RelatedServiceFileID,
                EmploymentPeriod
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar(100), AnswerText) EmploymentPeriod,
                    row_number() over(partition by cd.RelatedServiceFileID order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                    join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    dm.Title = '[Clinical] Well Check Interview'
                    and Question = 'Length of service in this role'
            ) x
            where
                rn = 1
        ),
        src as (
            select
                coalesce(t1.RelatedServiceFileID, t2.RelatedServiceFileID, t3.RelatedServiceFileID) ServiceFileID,
                coalesce(t1.EmploymentPeriod, t2.EmploymentPeriod, t3.EmploymentPeriod) EmploymentPeriod
            from
                t1 full outer join t2 on t2.RelatedServiceFileID = t1.RelatedServiceFileID
                full outer join t3 on t3.RelatedServiceFileID = coalesce(t1.RelatedServiceFileID, t2.RelatedServiceFileID)
        )
        update sf
        set
            EmploymentPeriod = src.EmploymentPeriod
        from
            [db-au-dtc]..pnpServiceFile sf
            join src on convert(varchar, src.ServiceFileID) = sf.ServiceFileID
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )


        -- update pnpServiceFile.WorkPlaceDiversityGroup
        ; with t1 as (
            select
                RelatedServiceFileID,
                WorkPlaceDiversityGroup
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar(100), AnswerText) WorkPlaceDiversityGroup,
                    row_number() over(partition by cd.RelatedServiceFileID order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                    join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    dm.Title = '[DTC] Agreement to Undertake Support & Privacy Notice'
                    and Question = 'Do you belong to any of the work place diversity groups?'
            ) x
            where
                rn = 1
        ),
        t2 as (
            select
                RelatedServiceFileID,
                WorkPlaceDiversityGroup
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar, AnswerText) WorkPlaceDiversityGroup,
                    row_number() over(partition by cd.RelatedServiceFileID order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..[pnpCompletedDocumentAnswer] cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpDocument d on d.DocumentSK = cd.DocumentSK
                    join [db-au-dtc]..pnpDocumentMaster dm on dm.DocumentMasterSK = d.DocumentMasterSK
                where
                    dm.Title = '[Associate] employeeAssist Dataform'
                    and Question = 'Work Place Diversity Group'
            ) x
            where
                rn = 1
        ),
        src as (
            select
                coalesce(t1.RelatedServiceFileID, t2.RelatedServiceFileID) ServiceFileID,
                coalesce(t1.WorkPlaceDiversityGroup, t2.WorkPlaceDiversityGroup) WorkPlaceDiversityGroup
            from
                t1 full outer join t2 on t2.RelatedServiceFileID = t1.RelatedServiceFileID
        )

        update sf
        set
            WorkPlaceDiversityGroup = src.WorkPlaceDiversityGroup
        from
            [db-au-dtc]..pnpServiceFile sf
            join src on convert(varchar, src.ServiceFileID) = sf.ServiceFileID
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )


        -- update pnpServiceFile.CaseManagement
        ; with sf as (
            select
                RelatedServiceFileID,
                Answer
            from (
                select
                    cd.RelatedServiceFileID,
                    convert(varchar, cda.AnswerText) as Answer,
                    row_number() over(partition by cd.RelatedServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..pnpCompletedDocumentAnswer cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                where
                    cda.Question = 'Case Management'
                    and cd.Title = '[Associate] employeeAssist Dataform'
            ) x
            where
                rn = 1
        ),
        lng as (
            select
                ServiceFileID,
                Answer
            from (
                select
                    se.ServiceFileID,
                    convert(varchar, cda.AnswerText) as Answer,
                    row_number() over(partition by se.ServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..pnpCompletedDocumentAnswer cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpServiceEvent se on se.ServiceEventID = cd.RelatedEventID
                where
                    cda.Question = 'Case Management'
                    and cd.Title = '[Clinical] EAP 1st Session (Long)'
            ) x
            where
                rn = 1
        ),
        sht as (
            select
                ServiceFileID,
                Answer
            from (
                select
                    se.ServiceFileID,
                    convert(varchar, cda.AnswerText) as Answer,
                    row_number() over(partition by se.ServiceFileID, cda.Question order by cdr.CompletedDocumentRevisionID desc) rn
                from
                    [db-au-dtc]..pnpCompletedDocumentAnswer cda
                    join [db-au-dtc]..pnpCompletedDocumentRevision cdr on cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = cdr.CompletedDocumentSK
                    join [db-au-dtc]..pnpServiceEvent se on se.ServiceEventID = cd.RelatedEventID
                where
                    cda.Question = 'Case Management'
                    and cd.Title = '[Clinical] EAP 1st Session (Short)'
            ) x
            where
                rn = 1
        ),
        src as (
            select
                coalesce(sf.RelatedServiceFileID, lng.ServiceFileID, sht.ServiceFileID) ServiceFileID,
                coalesce(sf.Answer, lng.Answer, sht.Answer) CaseManagement
            from
                sf
                full outer join lng on sf.RelatedServiceFileID = lng.ServiceFileID
                full outer join sht on sht.ServiceFileID = coalesce(sf.RelatedServiceFileID, lng.ServiceFileID)
        )
        update sf
        set
            CaseManagement = src.CaseManagement
        from
            [db-au-dtc]..pnpServiceFile sf
            join src on convert(varchar, src.ServiceFileID) = sf.ServiceFileID
        where
            sf.ServiceFileSK in
            (
                select
                    RelatedServiceFileSK
                from
                    #sf
            )


        -- update pnpCase.Location
        ; with a as (
            select *
            from (
                select
                    RelatedCaseSK,
                    Question,
                    AnswerText
                from (
                    select
                        RelatedCaseSK,
                        Question,
                        convert(varchar(300), AnswerText) AnswerText,
						-- Get most recent CompletedDocumentRevisionID and Non-Blank Answertext - 20180821 - YY 
                        --row_number() over(partition by RelatedCaseSK, Question order by r.CompletedDocumentRevisionID desc) rn
						row_number() over(partition by RelatedCaseSK, Question order by r.CompletedDocumentRevisionID desc, convert(varchar(max),answertext) desc) rn
                    from
                        [db-au-dtc]..pnpCompletedDocumentAnswer a
                        join [db-au-dtc]..pnpCompletedDocumentRevision r on r.CompletedDocumentRevisionSK = a.CompletedDocumentRevisionSK
                        join [db-au-dtc]..pnpCompletedDocument cd on cd.CompletedDocumentSK = r.CompletedDocumentSK
                        join [db-au-dtc]..pnpCase c on c.CaseSK = cd.RelatedCaseSK
                    where
                        AnswerText is not null
                        and (
                            (DocumentSection1 = 'Single support location' and Question = 'Location Address')
                            or (DocumentSection1 = 'SCOPING- INCIDENT LOCATION' and Question = 'Incident Location Address')
                        )
                ) a
                where
                        rn = 1
            ) s
            pivot (
                max(AnswerText)
                for Question in ([Location Address], [Incident Location Address])
            ) p
        )
        update c
		-- Update [Location] with Non-Blank Location Address - 20180821 - YY
        --set [Location] = coalesce(a.[Location Address], a.[Incident Location Address])
		set [Location] = coalesce(nullif(a.[Location Address], ''), a.[Incident Location Address])
        from
            [db-au-dtc]..pnpCase c
            join a on c.CaseSK = a.RelatedCaseSK
        where
            c.CaseSK in
            (
                select
                    cd.RelatedCaseSK
                from
                    #src cda
                    inner join [db-au-dtc]..pnpCompletedDocumentRevision cdr on
                        cdr.CompletedDocumentRevisionSK = cda.CompletedDocumentRevisionSK
                    inner join [db-au-dtc]..pnpCompletedDocument cd on
                        cdr.CompletedDocumentSK = cd.CompletedDocumentSK
            )


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
