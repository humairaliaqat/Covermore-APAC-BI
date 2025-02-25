USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0426]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0426]
    @CaseNo nvarchar(20),
    @ShowDeletedNotes varchar(3),
    @ShowAmendedNotes varchar(3)

as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0426
--  Author:         Linus Tor
--  Date Created:   20130415
--  Description:    This stored procedure returns carebase case and associated audit notes.
--  Parameters:     @CaseNo: valid case number
--                  @ShowDeletedNotes: value is Yes or No
--                  @ShowAmendedNotes: value is Yes or No
--
--  Change History: 20130415 - LT - Created
--                  20130910 - LS - refactor, default to AUS timezone
--                  20140715 - LS - TFS12109, unicode
--
/****************************************************************************************************/
--uncomment to debug
--declare
--    @CaseNo varchar(20),
--    @ShowDeletedNotes varchar(3),
--    @ShowAmendedNotes varchar(3)
--select
--    @CaseNo = 1304211697,
--    @ShowDeletedNotes = 'Yes',
--    @ShowAmendedNotes = 'Yes'

    set nocount on

    declare @WhereAuditAction varchar(200)
    declare @SQL varchar(8000)

    if (@ShowDeletedNotes = 'Yes' or @ShowDeletedNotes is null or @ShowDeletedNotes = '') and
       (@ShowAmendedNotes = 'Yes' or @ShowAmendedNotes is null or @ShowAmendedNotes = '') 
        select 
            @WhereAuditAction = 'a.AuditAction in (''D'',''U'')'
    else if @ShowDeletedNotes = 'No' and @ShowAmendedNotes = 'No' select @WhereAuditAction = 'a.AuditAction  in (''Z'')'        --dummy
    else if @ShowDeletedNotes = 'Yes' and @ShowAmendedNotes = 'No' select @WhereAuditAction = 'a.AuditAction in (''D'')'
    else if @ShowDeletedNotes = 'No' and @ShowAmendedNotes = 'Yes' select @WhereAuditAction = 'a.AuditAction in (''U'')'

    select @SQL =
        '
        select
            c.CaseNo,
            c.FirstName as ClientFirstName,
            c.Surname as ClientSurname,
            a.NoteComponent,
            a.NoteID,
            a.NoteUserID,
            a.NoteUserName,
            a.NoteCreateDate,
            a.NoteCreateTime,
            a.NoteType,
            a.AuditAction,
            convert(nvarchar(max),a.NoteDescription) as NoteDescription,
            a.AuditID
        from
            [db-au-cmdwh].dbo.cbCase c
            outer apply
            (
                select
                    ''Case Note'' as NoteComponent,
                    n.CaseKey,
                    n.NoteID,
                    n.UserID as NoteUserID,
                    n.UserName as NoteUserName,
                    n.CreateDate as NoteCreateDate,
                    n.CreateTime as NoteCreateTime,
                    n.NoteType,
                    null as AuditAction,
                    n.IsIncluded,
                    n.IsMBFSent,
                    n.NoteCode,
                    convert(nvarchar(max),n.Notes) as NoteDescription,
                    null as AuditID
                from
                    [db-au-cmdwh].dbo.cbNote n
                where
                    n.CaseKey = c.CaseKey

                union all

                select
                    ''Audit Note'' as NoteComponent,
                    an.CaseKey,
                    an.NoteID,
                    an.UserID as NoteUserID,
                    an.AuditUserName as NoteUserName,
                    an.AuditDate as NoteCreateDate,
                    an.AuditDateTime as NoteCreateTime,
                    an.NoteType,
                    an.AuditAction,
                    an.IsIncluded,
                    an.MBFSent as isMBFSent,
                    null as NoteCode,
                    an.Note as NoteDescription,
                    an.AuditID
                from
                    [db-au-cmdwh].dbo.cbAuditNote an
                where
                    an.CaseKey = c.CaseKey
            ) a
        where
            c.CaseNo = ''' + @CaseNo + ''' and
            (a.AuditAction is null or ' + @WhereAuditAction + ')
        '

    exec(@SQL)

end
GO
