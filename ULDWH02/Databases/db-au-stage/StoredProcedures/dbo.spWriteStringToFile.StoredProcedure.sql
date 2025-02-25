USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[spWriteStringToFile]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spWriteStringToFile]
(
    @String varchar(max),
    @Path varchar(255),
    @Filename varchar(100)
)
as
begin

    declare  
        @objfilesystem int,
        @objtextstream int,
        @objerrorobject int,
        @strerrormessage varchar(1000),
        @command varchar(1000),
        @hr int,
        @fileandpath varchar(80)

    set nocount on

    set @strerrormessage = 'opening the file system object'
    set @fileandpath = @path + '\' + @filename
    
    execute @hr = sp_oacreate 
        'scripting.filesystemobject', 
        @objfilesystem out
    
    if @hr=0 
        select 
            @objerrorobject = @objfilesystem, 
            @strerrormessage = 'creating file "' + @fileandpath + '"'

    if @hr=0 
        execute @hr = sp_oamethod
            @objfilesystem, 
            'createtextfile', 
            @objtextstream out, 
            @fileandpath,
            2,
            true

    if @hr=0 
        select 
            @objerrorobject = @objtextstream,
            @strerrormessage = 'writing to the file "' + @fileandpath + '"'
    
    if @hr=0 
        execute @hr = sp_oamethod  
            @objtextstream, 
            'write', 
            null, 
            @string

    if @hr=0 
        select 
            @objerrorobject = @objtextstream, 
            @strerrormessage = 'closing the file "' + @fileandpath + '"'

    if @hr=0 
        execute @hr = sp_oamethod  
            @objtextstream, 
            'close'

    if @hr<>0
    begin

        declare 
            @source varchar(255),
            @description varchar(255),
            @helpfile varchar(255),
            @helpid int
		
        execute sp_oageterrorinfo  
            @objerrorobject,
            @source output,
            @description output,
            @helpfile output,
            @helpid output

        set @strerrormessage = 
            'error whilst ' + 
            coalesce(@strerrormessage, 'doing something') + ', ' + 
            coalesce(@description, '')

        raiserror (@strerrormessage,16,1)

    end

    execute sp_oadestroy @objtextstream
    execute sp_oadestroy @objfilesystem

end
GO
