USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entMergeCustomer]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entMergeCustomer]
    @CIDs varchar(max),
    @Batch bit = 0,
    @MergeOnly bit = 0,
    @Debug bit = 0

as
begin

    set nocount on

    declare 
        @SQL varchar(max),
        @ids varchar(max),
        @xml xml

    if object_id('tempdb..#parsed') is not null
        drop table #parsed

    select --top 10
        *,
        Item [urn:rowid]
    into #parsed
    from
        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@CIDs, ',')
    where
        Item <> ''

    --select *
    --from
    --    [db_au_mdmenterprise]..C_PARTY p
    --where
    --    ROWID_OBJECT in
    --    (    
    --        select
    --            Item
    --        from
    --            #parsed
    --    )

    if @MergeOnly = 0
    begin

        --set records to be un-consolidated
        update p
        set
            CONSOLIDATION_IND = 4
        from
            [db_au_mdmenterprise]..C_PARTY p
        where
            ROWID_OBJECT in
            (    
                select
                    Item
                from
                    #parsed
            )

        ;with xmlnamespaces ('.' as [urn])
        select 
            @xml = 
            (
                select
                    [urn:rowid]
                from
                    #parsed
                for xml path ('urn:recordKeyList'), root('a')
            )


        set @ids = convert(varchar(max), @xml)
        set @ids = substring(@ids, 18, len(@ids) - 18 - 3)

        if @Debug = 1
            print @ids

        --merge ids
        set @SQL =
            '
            E:\ETL\Tool\wget64.exe
                --method POST
                --tries=1
                --read-timeout=900
                --header "accept-encoding: gzip,deflate"
                --header "content-type: text/xml;charset=UTF-8"
                --header "soapaction: ''''"
                --header "host: mdmservices.covermore.com"
                --header "connection: Keep-Alive"
                --header "cache-control: no-cache"
                --body-data 
                "
                <soapenv:Envelope xmlns:soapenv=''http://schemas.xmlsoap.org/soap/envelope/'' xmlns:urn=''urn:siperian.api''>
                    <soapenv:Header/>
                    <soapenv:Body>
                        <urn:multiMerge>
                            <urn:username>admin</urn:username>
                            <urn:password>
                                <urn:password>admin</urn:password>
                                <urn:encrypted>false</urn:encrypted>
                            </urn:password>
                            <urn:orsId>uldwh02.aust.covermore.com.au-db_au_mdmenterprise</urn:orsId>
                            <urn:record>
                                <urn:siperianObjectUid>BASE_OBJECT.C_PARTY</urn:siperianObjectUid>
                            </urn:record>' +
            @ids +
            '
                            <urn:taskId>1</urn:taskId>
                        </urn:multiMerge>
                    </soapenv:Body>
                </soapenv:Envelope>
                " 
                http://mdmservices.covermore.com/SifService 
            '

        set @SQL = 'exec xp_cmdshell ''' + replace(replace(replace(@SQL, '''', ''''''), char(10), ''), char(13), '') + ''''

        if @Debug = 1
            print @SQL

        exec(@SQL)

    end

    if @Batch = 0
    begin

        --match records
        set @SQL = 
            '
            E:\ETL\Tool\wget64.exe 
                --method POST
                --tries=1
                --read-timeout=7200
                --header "accept-encoding: gzip,deflate"
                --header "content-type: text/xml;charset=UTF-8"
                --header "soapaction: ''''"
                --header "host: mdmservices.covermore.com"
                --header "connection: Keep-Alive"
                --header "cache-control: no-cache"
                --body-data 
                "
                <soapenv:Envelope xmlns:soapenv=''http://schemas.xmlsoap.org/soap/envelope/'' xmlns:urn=''urn:siperian.api''>
                    <soapenv:Header/>
                    <soapenv:Body><urn:executeBatchGroup>
                        <urn:username>admin</urn:username>
                        <urn:password>
                            <urn:password>admin</urn:password>
                            <urn:encrypted>false</urn:encrypted>
                        </urn:password>
                        <urn:orsId>uldwh02.aust.covermore.com.au-db_au_mdmenterprise</urn:orsId>
                        <urn:batchGroupUid>Child Match Batch</urn:batchGroupUid>
                        <urn:resume>No</urn:resume>
                    </urn:executeBatchGroup>
                </soapenv:Body></soapenv:Envelope>
                " 
                http://mdmservices.covermore.com/SifService 
            '

        set @SQL = 'exec xp_cmdshell ''' + replace(replace(replace(@SQL, '''', ''''''), char(10), ''), char(13), '') + ''''

        exec(@SQL)

		--wait until finish
		set @SQL = 
		'
		E:\ETL\Tool\wget64.exe 
			--quiet 
			--output-document=E:\ETL\Data\MDM.txt
			--method POST 
			--header "accept-encoding: gzip,deflate" 
			--header "soapaction: ''''" 
			--header "content-type: text/xml;charset=UTF-8" 
			--header "host: mdmservices.covermore.com" 
			--header "cache-control: no-cache" 
			--body-data 
			"
			<soapenv:Envelope xmlns:soapenv=''http://schemas.xmlsoap.org/soap/envelope/'' xmlns:urn=''urn:siperian.api''>
				<soapenv:Header/>
				<soapenv:Body>
					<urn:getBatchGroupStatus>
						<urn:username>admin</urn:username>
						<urn:password>
							<urn:password>admin</urn:password>
							<urn:encrypted>false</urn:encrypted>
						</urn:password>
						<urn:orsId>uldwh02.aust.covermore.com.au-db_au_mdmenterprise</urn:orsId>
						<urn:batchGroupUid>Child Match Batch</urn:batchGroupUid>
					</urn:getBatchGroupStatus>
				</soapenv:Body>
			</soapenv:Envelope>
			"
			http://mdmservices.covermore.com/SifService
		'

		set @SQL = 'exec xp_cmdshell ''' + replace(replace(replace(@SQL, '''', ''''''), char(10), ''), char(13), '') + ''''

        if @Debug = 1
		    print @SQL

		exec (@SQL)

		while 
		not exists
		(
			select
				BulkColumn
			from
				openrowset
				(
					bulk 'E:\ETL\Data\MDM.txt',
					single_clob
				) t
			where
				BulkColumn like '%<runStatus>1</runStatus>%' or
                BulkColumn like '%<runStatus>3</runStatus>%'
		)
		begin
    
			raiserror('waiting match and merge', 1, 1) with nowait

			waitfor delay '00:10:00'
			exec (@SQL)

		end


    end

end
GO
