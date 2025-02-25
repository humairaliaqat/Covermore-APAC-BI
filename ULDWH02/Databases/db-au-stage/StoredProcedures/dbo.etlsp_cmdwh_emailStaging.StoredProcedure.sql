USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emailStaging]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_emailStaging]
    @Mailbox nvarchar(max)

as
begin

    if object_id('[db-au-stage].dbo.stage_email_folder') is null
    begin

        create table [db-au-stage].dbo.stage_email_folder
        (
            mailbox nvarchar(450) null,
            id nvarchar(450) null,
            name nvarchar(max) null,
            parentid nvarchar(max) null
        )

        create nonclustered index idx_folder_mailbox on [db-au-stage].dbo.stage_email_folder(mailbox)

    end
    else
    begin

        delete 
            [db-au-stage].dbo.stage_email_folder
        where
            mailbox = @Mailbox

    end

    if object_id('[db-au-stage].dbo.stage_email_object') is null
    begin

        create table [db-au-stage].dbo.stage_email_object
        (
            mailbox nvarchar(450) null,
            id nvarchar(450) null,
            emailsubject nvarchar(max) null,
            conversationid nvarchar(max) null,
            conversationtopic nvarchar(max) null,
            categories nvarchar(max) null,
            datetimecreated datetime null,
            datetimereceived datetime null,
            datetimesent datetime null,
            sender nvarchar(max) null,
            replyto nvarchar(max) null,
            displayto nvarchar(max) null,
            displaycc nvarchar(max) null,
            hasattachment bit null,
            importance nvarchar(max) null,
            inreplyto nvarchar(max) null,
            isresend bit null,
            lastmodifiedname nvarchar(max) null,
            lastmodifiedtime datetime null,
            parentfolderid nvarchar(450) null,
            size bigint null,
            isread bit null,
            receivedby nvarchar(max) null,
            internetheaders nvarchar(max) null,
            internetid nvarchar(max) null,
            body nvarchar(max) null
        ) 

        create nonclustered index idx_email_mailbox on [db-au-stage].dbo.stage_email_object(mailbox)

    end
    else
    begin

        delete [db-au-stage].dbo.stage_email_object
        where
            mailbox = @Mailbox

    end

end
GO
