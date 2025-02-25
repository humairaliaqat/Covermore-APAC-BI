USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_livecarebaseemotion]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_livecarebaseemotion]
as
begin

    declare @nowutc datetime
    set 
        @nowutc = [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time')

    if object_id('tempdb..#livecarebase') is not null
        drop table #livecarebase

    select 
        --*
        Emotion,
        case
            when datediff(hour, LocalEmotionDate, getdate()) < 1 then 'Less than 1 hour'
            when datediff(hour, LocalEmotionDate, getdate()) < 24 then 'Less than 24 hours'
            else 'More than 24 hours'
        end Age,
        count(CaseNo) CaseCount
    from
        openquery
        (
            [db-au-penguinsharp.aust.covermore.com.au],
            '
            select 
                c.CASE_NO CaseNo,
                c.CLI_CODE ClientCode,
                le.Emotion,
                le.EmotionDate,
                pe.PreviousEmotion
            from
                CAREBASE.dbo.CMN_MAIN c with(nolock)
                cross apply
                (
                    select top 1 
                        e.EM_DESC Emotion,
                        ce.EM_DATE EmotionDate
                    from
                        CAREBASE.dbo.CST_EMOTION ce with(nolock)
                        inner join CAREBASE.dbo.EMOTIONS e with(nolock) on
                            e.EM_ID = ce.EM_ID
                    where
                        ce.CASE_NO = c.CASE_NO
                    order by
                        ce.EM_DATE desc
                ) le
                outer apply
                (
                    select top 1 
                        e.EM_DESC PreviousEmotion
                    from
                        CAREBASE.dbo.CST_EMOTION ce with(nolock)
                        inner join CAREBASE.dbo.EMOTIONS e with(nolock) on
                            e.EM_ID = ce.EM_ID
                    where
                        ce.CASE_NO = c.CASE_NO and
                        ce.EM_DATE < le.EmotionDate
                    order by
                        ce.EM_DATE desc
                ) pe
            where
                c.STATUS = ''O'' and
                le.Emotion in
                (
                    ''DISSATISFACTION - REVIEW IN ONE HOUR'',
                    ''DISSATISFACTION - REVIEW IN PROGRESS'',
                    ''COMPLAINT - UNRESOLVED'',
                    ''COMPLAINT - UNABLE TO RESOLVE''
                ) and
                pe.PreviousEmotion = ''SATISFIED''
            '
        ) t
        cross apply
        (
            select
                [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(t.EmotionDate, 'AUS Eastern Standard Time') LocalEmotionDate
        ) lt
        inner join cbClient cl on
            cl.ClientCode = t.ClientCode collate database_default
    where
        cl.CountryKey = 'AU' and
        datediff(hour, LocalEmotionDate, getdate()) >= 1
    group by
        Emotion,
        case
            when datediff(hour, LocalEmotionDate, getdate()) < 1 then 'Less than 1 hour'
            when datediff(hour, LocalEmotionDate, getdate()) < 24 then 'Less than 24 hours'
            else 'More than 24 hours'
        end 

end

GO
