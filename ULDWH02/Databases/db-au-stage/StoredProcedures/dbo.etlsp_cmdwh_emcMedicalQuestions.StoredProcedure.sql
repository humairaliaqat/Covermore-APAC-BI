USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcMedicalQuestions]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_emcMedicalQuestions]
as
begin
/*
    20140317, LS,   TFS 9410, UK data
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcMedicalQuestions') is null
    begin

        create table [db-au-cmdwh].dbo.emcMedicalQuestions
        (
            CountryKey varchar(2) not null,
            MedicalKey varchar(15) not null,
            MedicalID int not null,
            QuestionID int not null,
            Question varchar(200) null,
            Answer varchar(100) null
        )

        create clustered index idx_emcMedicalQuestions_MedicalKey on [db-au-cmdwh].dbo.emcMedicalQuestions(MedicalKey)
        create index idx_emcMedicalQuestions_QuestionID on [db-au-cmdwh].dbo.emcMedicalQuestions(QuestionID, CountryKey)
        create index idx_emcMedicalQuestions_MedicalID on [db-au-cmdwh].dbo.emcMedicalQuestions(MedicalID, CountryKey)

    end

    if object_id('etl_emcMedicalQuestions') is not null
        drop table etl_emcMedicalQuestions

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), MedicalID) MedicalKey,
        mcq.MedicalID,
        mcq.Counter QuestionID,
        mcq.Question,
        mcq.Answer
    into etl_emcMedicalQuestions
    from
        emc_EMC_tblMedicalConditionQuestionAnswer_AU mcq
        inner join emc_EMC_Medical_AU m on
            m.Counter = mcq.MedicalID
        outer apply dbo.fn_GetEMCDomainKeys(m.ClientID, 'AU') dk

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), MedicalID) MedicalKey,
        mcq.MedicalID,
        mcq.Counter QuestionID,
        mcq.Question,
        mcq.Answer
    from
        emc_UKEMC_tblMedicalConditionQuestionAnswer_UK mcq
        inner join emc_UKEMC_Medical_UK m on
            m.Counter = mcq.MedicalID
        outer apply dbo.fn_GetEMCDomainKeys(m.ClientID, 'UK') dk


    delete emq
    from
        [db-au-cmdwh].dbo.emcMedicalQuestions emq
        inner join etl_emcMedicalQuestions t on
            t.MedicalKey = emq.MedicalKey


    insert into [db-au-cmdwh].dbo.emcMedicalQuestions
    (
        CountryKey,
        MedicalKey,
        MedicalID,
        QuestionID,
        Question,
        Answer
    )
    select
        CountryKey,
        MedicalKey,
        MedicalID,
        QuestionID,
        Question,
        Answer
    from
        etl_emcMedicalQuestions

end
GO
