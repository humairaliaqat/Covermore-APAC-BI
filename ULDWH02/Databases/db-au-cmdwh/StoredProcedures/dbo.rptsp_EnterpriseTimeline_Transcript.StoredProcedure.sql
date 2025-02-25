USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_EnterpriseTimeline_Transcript]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_EnterpriseTimeline_Transcript]
    @DataType varchar(50),
    @DataSubType varchar(50) = '',
    @Reference varchar(100),
    @LogUser varchar(max) = ''

as
begin

    set nocount on

    if object_id('entActionLog') is null
    begin
        
        create table entActionLog
        (
            BIRowID bigint not null identity(1,1),
            LogTime datetime,
            UserName varchar(max),
            Calls varchar(max),
            Reference varchar(max)
        )

        create unique clustered index cidx on entActionLog (BIRowID)

    end

    insert into entActionLog
    (
        LogTime,
        UserName,
        Calls,
        Reference
    )
    select
        getdate(),
        @LogUser,
        @DataType,
        @Reference


--declare
--    @DataType varchar(50) = 'EMC Assessment',
--    @DataSubType varchar(50) = 'Live Chat',
--    @Reference varchar(100) = 'AU-10554355'

    declare @transcript nvarchar(max) = ''

    if @DataType = 'Call Comment'
        select 
            @transcript =
            'Call date: ' + convert(varchar(20), CallDate, 113) + char(10) +
            'Reason: ' + CallReason + char(10) +
            'Comment: ' + char(10) +
            CallComment
        from
            penPolicyAdminCallComment
        where
            CallCommentKey = @Reference

    if @DataType = 'Claim Event'
        select 
            @transcript =
            'Event date: ' + isnull(convert(varchar(20), EventDate, 106), '') + char(10) + 
            'Location:' + char(10) + EventLocation + char(10) + char(10) +
            'Description:' + char(10) + EventDescription
        from
            clmClaimFlags cl
            cross apply
            (
                select 
                    min(EventDate) EventDate
                from
                    clmEvent ce
                where
                    ce.ClaimKey = cl.ClaimKey
            ) ce
        where
            ClaimKey = @Reference

    if @DataType = 'Make a call' and @Reference not like '[0-9]%' and len(@Reference) <= 10
        select
            @transcript =
            (
                select 
                    convert(varchar(20), EventTime, 113) + ' ' + 
                    isnull(Author, '') + char(9) + 
                    '(' + isnull(EventType, '') + ') ' +
                    replace(isnull(EventText, ''), '\n', char(10)) + char(10)
                from
                    lcLiveChatEvents
                where
                    ChatID = @Reference
                order by
                    EventTime
                for xml path('')
            )

    if @DataType = 'Make a call' and @Reference like '[0-9]%' and len(@Reference) > 5
    begin

        declare @sql varchar(max)
        declare @output table (string varchar(max))

        set @sql = 'exec xp_cmdshell "dir /b \\ulbi02\cisco\' + @Reference + '.wav"'

        insert into @output
        exec (@sql)

        set @transcript = 'https://bi.covermore.com/EnterpriseView/audio.html?' + @Reference

        if
            not exists
            (
                select 
                    null
                from 
                    @output
                where
                    string = @Reference + '.wav'
            )
        begin

            set @sql = 'exec xp_cmdshell "E:\ETL\Tool\CISCO\CISCODownloader.exe ' + @Reference + '"'

            insert into @output
            exec (@sql)

            --begin try


                ----set @sql = 'exec xp_cmdshell "e:\etl\ciscodownloader.exe ' + @Reference + '"'
                --set @sql = 'exec xp_cmdshell "copy \\ulbi02\cisco\empty.txt \\ulbi02\cisco\' + @Reference + '.part"'

                --insert into @output
                --exec (@sql)

                --declare @i int

                --set @i = 1

                --while @i < 6
                --begin

                --    delete from @output

                --    set @sql = 'exec xp_cmdshell "dir /b \\ulbi02\cisco\' + @Reference + '.part"'

                --    insert into @output
                --    exec (@sql)

                --    if
                --        exists
                --        (
                --            select 
                --                null
                --            from 
                --                @output
                --            where
                --                string = @Reference + '.part'
                --        )
                --    begin

                --        waitfor delay '00:00:05' 
                --        set @i = @i + 1

                --    end

                --    else
                --        set @i = 6

                --end

                --set @sql = 'exec xp_cmdshell "dir /b \\ulbi01\cisco\' + @Reference + '.wav"'

                --insert into @output
                --exec (@sql)

                --if
                --    not exists
                --    (
                --        select 
                --            null
                --        from 
                --            @output
                --        where
                --            string = @Reference + '.wav'
                --    )
                --    set @transcript = 'audio file is not available'


            --end try

            --begin catch

            --    set @transcript = 'audio file is not available'

            --end catch

        end


    end

    if @DataType = 'EMC Assessment'
        select
            @transcript =
            (
                select 
                    AlphaCode + ' ' + OutletName + char(10) +
                    ContactStreet + ' ' + ContactSuburb + ' ' + ContactState
                from
                    emcApplications ea
                    left join penOutlet o on
                        o.OutletAlphaKey = ea.OutletAlphaKey and
                        o.OutletStatus = 'Current'
                where
                    ApplicationKey = @Reference
            ) + char(10) + char(10) +
            (
                select 
                    'Condition: ' + m.Condition + ' (' + m.ConditionStatus collate database_default + ')' + char(10) +
                    --'Score: ' + convert(varchar, m.MedicalScore) + char(10) +
                    'Answers: ' + char(10) +
                    (
                        select
                            mq.Question + ' ' +
                            mq.Answer + char(10)
                        from
                            emcMedicalQuestions mq
                        where
                            mq.MedicalKey = m.MedicalKey
                        order by 
                            mq.QuestionID
                        for xml path('')
                    ) + char(10)
                from
                    emcMedical m
                where
                    ApplicationKey = @Reference
                order by
                    m.Condition
                for xml path('')
            )    

    if @DataType like 'MA %'
        select 
            @transcript =
            'Date: ' + convert(varchar(20), NoteTime, 113) + ' ' + char(10) +
            'Type: ' + NoteType + char(10) +
            'Notes: ' + char(10) +
            Notes
        from
            cbNote
        where
            NoteKey = @Reference


    --print @transcript

    select 
        left(isnull(@transcript, ''), 4000) Transcript
--'
--Where does it come from?
--Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.
--' Transcript



end
GO
