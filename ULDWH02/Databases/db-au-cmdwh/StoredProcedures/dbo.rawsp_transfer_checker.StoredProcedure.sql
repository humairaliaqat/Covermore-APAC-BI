USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_transfer_checker]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_transfer_checker]
    @ExtractID int
  
as
begin  

/****************************************************************************************************/
--  Name:           rawsp_transfer_checker
--  Author:         Leonardus S
--  Date Created:   20131227
--  Description:    This stored procedure check the data extract transfer status by checking the backup folder
--  Parameters:    
--                  @ExtractID: get backup folder to check by usrRawExtract.ID
--  
--  Change History: 20131227 - LS - Created
--                  20161205 - LL - set success, just in case of major hicups on the server and everything set to fail
--
/****************************************************************************************************/
--uncomment to debug
--declare 
--    @ExtractID int
--select 
--    @ExtractID = 70 

    set nocount on 

    declare 
        @localsql varchar(max),
        @backuppath varchar(max),
        @logtable varchar(64)
    
    begin try
    
        if object_id('tempdb..#diroutput') is not null
            drop table #diroutput
            
        if object_id('tempdb..#logged') is not null
            drop table #logged

        if object_id('tempdb..##transferstatus') is not null
            drop table ##transferstatus

        create table #diroutput
        (
            files varchar(1024)
        )

        create table #logged
        (
            files varchar(64)
        )

        select 
            @backuppath = BackupPath,
            @logtable = LogTable
        from 
            usrRawExtract 
        where 
            ID = @ExtractID and
            logOutput = 1 and
            verifyBackup = 1
            
        if @backuppath is not null and @logtable is not null
        begin

            set @localsql = 'exec xp_cmdshell ''dir ' + @backuppath + ' /b /s'''
            
            --print @localsql
            insert into #diroutput
            exec (@localsql)
            
            update #diroutput
            set
                files = replace(files, @backuppath, '')
            
            set @localsql =
                '
                select distinct
                    xOutputFileNamex
                from 
                    [' + @logtable + ']'
            
            insert into #logged
            exec (@localsql)
            
            select 
                l.files [FileName],
                case
                    when t.files is null then 'Transfer Failed'
                    else 'Transferred'
                end TransferStatus
            into ##transferstatus
            from
                #logged l
                left join #diroutput t on
                    t.files like '%' + l.files
                    
            /* reset status */
            set @localsql =
                '
                update [' + @logtable + ']
                set
                    xFailx = 0
                '
            exec (@localsql)

            /* mark transfer as failed */
            set @localsql =
                '
                update [' + @logtable + ']
                set
                    xFailx = 1
                where
                    xOutputFileNamex in
                    (
                        select 
                            [FileName]
                        from
                            ##transferstatus
                        where
                            TransferStatus = ''Transfer Failed''
                    )
                '
            exec (@localsql)
            
            select
                [FileName],
                TransferStatus
            from 
                ##transferstatus
            order by 1 desc
            
        end
                

    end try

    /* catch exceptions */
    begin catch

        exec syssp_genericerrorhandler 'Transfer check failed'

    end catch

    /* cleanup */
    if object_id('tempdb..#diroutput') is not null
        drop table #diroutput
  
    if object_id('tempdb..#logged') is not null
        drop table #logged
            
    if object_id('tempdb..##transferstatus') is not null
        drop table ##transferstatus
        
end
GO
