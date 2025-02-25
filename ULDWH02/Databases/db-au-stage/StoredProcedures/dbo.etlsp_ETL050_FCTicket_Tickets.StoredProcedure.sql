USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL050_FCTicket_Tickets]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL050_FCTicket_Tickets]
as
begin


-- 20180326 RL: change data souce for fltTickets.Domain from TicketData.System_Name to BusinessUnitData.Country
-- 20180501 RL: Fixing the bug implimented on 20180326
-- 20190403 LT: New data file contains decimals for	[TotalDuration] and [DurationAtDestination] columns. Converted to integer before loading these columns

    set nocount on

    declare 
        @sql varchar(max),
        @filename varchar(max),
        @filedate date


    if object_id('[db-au-cmdwh].dbo.fltTickets') is null
    begin

        create table [db-au-cmdwh].dbo.fltTickets
        (
			[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
			[Domain] [varchar](5) NULL,
			[DocumentNumber] [varchar](100) NULL,
			[PNRNumber] [varchar](50) NULL,
			[T3Code] [varchar](50) NULL,
			[AlphaCode] [nvarchar](50) NULL,
			[OutletKey] [varchar](50) NULL,
			[IssueDate] [date] NULL,
			[RefundedDate] [date] NULL,
			[DocumentType] [varchar](50) NULL,
			[TicketType] [varchar](50) NULL,
			[JourneyType] [varchar](50) NULL,
			[TravelType] [varchar](50) NULL,
			[AdultChildIndicator] [varchar](50) NULL,
			[FirstFlightDate] [date] NULL,
			[TotalDuration] [int] NULL,
			[DurationAtDestination] [int] NULL,
			[IATANumber] [varchar](50) NULL,
			[IATACode] [varchar](50) NULL,
			[AirlineCode] [varchar](50) NULL,
			[PrimaryClass] [varchar](50) NULL,
			[MultiClassIndicator] [bit] NULL,
			[RoutingDescription] [varchar](8000) NULL,
			[NumberOfSectors] [int] NULL,
			[OriginAirportCode] [varchar](50) NULL,
			[OriginAirportCityName] [varchar](100) NULL,
			[OriginAirportCountryName] [varchar](100) NULL,
			[DestinationAirportCode] [varchar](50) NULL,
			[DestinationAirportCityName] [varchar](100) NULL,
			[DestinationAirportCountryName] [varchar](100) NULL,
			[BookingBusinessUnitID] [bigint] NULL,
			[BillingBusinessUnitID] [bigint] NULL,
			[BillingConsultantID] [bigint] NULL,
			[BookingConsultantID] [bigint] NULL,
			[SystemName] [varchar](50) NULL,
			[FileDate] [date] NULL,
			[LastUpdate] [date] NULL
        )

        create unique clustered index idx_fltTickets_BIRowID on [db-au-cmdwh].dbo.fltTickets (BIRowID)
        create nonclustered index idx_fltTickets_DocumentNo on [db-au-cmdwh].dbo.fltTickets (DocumentNumber,PNRNumber)
        create nonclustered index idx_fltTickets_IssueDate on [db-au-cmdwh].dbo.fltTickets (IssueDate)
        create nonclustered index idx_fltTickets_LastUpdate on [db-au-cmdwh].dbo.fltTickets (LastUpdate,OutletKey)

    end


    if object_id('tempdb..#filelist') is not null
        drop table #filelist

    create table #filelist
    (
        filenames varchar(max)
    )

    declare
        c_files cursor local for
            select 
                FileNames,
                try_convert(date, right(left(filenames, charindex('.', filenames) - 1), 8)) FileDate
            from
                #filelist
            where
                filenames is not null and
                filenames <> 'File Not Found'
            order by
                convert(date, right(left(filenames, charindex('.', filenames) - 1), 8)) desc
    
    truncate table #filelist

    insert into #filelist (filenames)
    exec xp_cmdshell 'dir "E:\ETL\Data\Flight Centre\Process\FLT_*TICKET*.csv" /b'

    insert into #filelist (filenames)
    exec xp_cmdshell 'dir "E:\ETL\Data\Flight Centre\Process\FLT_*TICKET*.txt" /b'

select * from #filelist

    --iterate csv files

    open c_files

    fetch next from c_files into @filename, @filedate

    while @@fetch_status = 0
    begin

        print @filename
        print @filedate

        if object_id('[db-au-stage].[dbo].[etl_fltTicket]') is not null
            drop table [db-au-stage].[dbo].[etl_fltTicket]

        create table [db-au-stage].[dbo].[etl_fltTicket]
        (
	        [Local_Issue_Date] [varchar](100),
	        [PNR_Number] [varchar](100),
	        [Document_Number] [varchar](100),
	        [Refunded_Date] [varchar](100),
	        [Document_Type] [varchar](100),
	        [TicketType] [varchar](100),
	        [Adult_Child_Indicator] [varchar](100),
	        [Number_of_Nights_at_Total_Journey] [varchar](100),
	        [Number_of_Nights_at_Destination] [varchar](100),
	        [Issuing_IATA_Number] [varchar](100),
	        [Issuing_IATA_Code] [varchar](100),
	        [Local_First_Flight_Date] [varchar](100),
	        [Journey_Type] [varchar](100),
	        [Travel_Type] [varchar](100),
	        [Airline_Code] [varchar](100),
	        [Primary_Class] [varchar](100),
	        [Multi_Class_Indicator] [varchar](100),
	        [Routing_Description] [varchar](max),
	        [Origin_Airport_Code] [varchar](100),
	        [Destination_Airport_Code] [varchar](100),
	        [Number_of_Sectors] [varchar](100),
	        [T3_Code] [varchar](100),
	        [DimBookingCurrentBusinessUnitId] [varchar](100),
	        [DimBillingBusinessUnitId] [varchar](100),
	        [DimBillingConsultantId] [varchar](100),
	        [DimBookingConsultantId] [varchar](100),
	        [System_Name] [varchar](100) null
        )

        exec xp_cmdshell 'del "E:\ETL\Data\Flight Centre\Process\LOAD_TICKET.csv"'

        set @sql = 'exec xp_cmdshell ''copy "E:\ETL\Data\Flight Centre\Process\' + @filename + '" "E:\ETL\Data\Flight Centre\Process\LOAD_TICKET.csv"'''
        print @sql
        exec (@sql)

        bulk insert [db-au-stage].[dbo].[etl_fltTicket]
        from 'E:\ETL\Data\Flight Centre\Process\LOAD_TICKET.csv'
        with
        (
            tablock,
            batchsize = 50000,
            codepage = '1252',
            fieldterminator = '","',
            rowterminator = '\n',
            firstrow = 2
        ) 
		
		;WITH cte AS (
		  SELECT Local_Issue_Date,
		PNR_Number,
		Document_Number,
		Refunded_Date,
		Document_Type,
		TicketType,
		Adult_Child_Indicator,
		Number_of_Nights_at_Total_Journey,
		Number_of_Nights_at_Destination,
		Issuing_IATA_Number,
		Issuing_IATA_Code,
		Local_First_Flight_Date,
		Journey_Type,
		Travel_Type,
		Airline_Code,
		Primary_Class,
		Multi_Class_Indicator,
		left(Routing_Description,8000) as Routing_Description,
		Origin_Airport_Code,
		Destination_Airport_Code,
		Number_of_Sectors,
		T3_Code,
		DimBookingCurrentBusinessUnitId,
		DimBillingBusinessUnitId,
		DimBillingConsultantId,
		DimBookingConsultantId,
		System_Name, 
			 row_number() OVER(PARTITION BY PNR_Number, Document_Number order by Local_Issue_Date) AS [rn]
		  FROM [db-au-stage].[dbo].[etl_fltTicket]
		)
		DELETE cte WHERE [rn] > 1


        if object_id('tempdb..#fltTickets') is not null
            drop table #fltTickets

        ;with 
        cte_unquoted as
        (
            select 
                replace(Local_Issue_Date, '"', '') Local_Issue_Date,
                replace(PNR_Number, '"', '') PNR_Number,
                replace(Document_Number, '"', '') Document_Number,
                replace(Refunded_Date, '"', '') Refunded_Date,
                replace(Document_Type, '"', '') Document_Type,
                replace(TicketType, '"', '') TicketType,
                replace(Adult_Child_Indicator, '"', '') Adult_Child_Indicator,
                replace(Number_of_Nights_at_Total_Journey, '"', '') Number_of_Nights_at_Total_Journey,
                replace(Number_of_Nights_at_Destination, '"', '') Number_of_Nights_at_Destination,
                replace(Issuing_IATA_Number, '"', '') Issuing_IATA_Number,
                replace(Issuing_IATA_Code, '"', '') Issuing_IATA_Code,
                replace(Local_First_Flight_Date, '"', '') Local_First_Flight_Date,
                replace(Journey_Type, '"', '') Journey_Type,
                replace(Travel_Type, '"', '') Travel_Type,
                replace(Airline_Code, '"', '') Airline_Code,
                replace(Primary_Class, '"', '') Primary_Class,
                replace(Multi_Class_Indicator, '"', '') Multi_Class_Indicator,
                replace(Routing_Description, '"', '') Routing_Description,
                replace(Origin_Airport_Code, '"', '') Origin_Airport_Code,
                replace(Destination_Airport_Code, '"', '') Destination_Airport_Code,
                replace(Number_of_Sectors, '"', '') Number_of_Sectors,
                replace(T3_Code, '"', '') T3_Code,
                replace(DimBookingCurrentBusinessUnitId, '"', '') DimBookingCurrentBusinessUnitId,
                replace(DimBillingBusinessUnitId, '"', '') DimBillingBusinessUnitId,
                replace(DimBillingConsultantId, '"', '') DimBillingConsultantId,
                replace(DimBookingConsultantId, '"', '') DimBookingConsultantId,
                replace(System_Name, '"', '') System_Name
            from
                [db-au-stage].[dbo].[etl_fltTicket]
        ),
        cte_formatted as
        (
            select 
                try_convert(date, Local_Issue_Date) Local_Issue_Date,
                PNR_Number,
                Document_Number,
                case
                    when Refunded_Date = '' then null
                    else try_convert(date, Refunded_Date) 
                end Refunded_Date,
                Document_Type,
                TicketType,
                Adult_Child_Indicator,
                Number_of_Nights_at_Total_Journey,
                Number_of_Nights_at_Destination,
                Issuing_IATA_Number,
                Issuing_IATA_Code,
                case
                    when Local_First_Flight_Date = '' then null
                    else try_convert(date, Local_First_Flight_Date)
                end Local_First_Flight_Date,
                Journey_Type,
                Travel_Type,
                Airline_Code,
                Primary_Class,
                case
                    when Multi_Class_Indicator = 'True' then 1
                    else 0
                end Multi_Class_Indicator,
                left(Routing_Description,8000) as Routing_Description,
                Origin_Airport_Code,
                Destination_Airport_Code,
                Number_of_Sectors,
                T3_Code,
                DimBookingCurrentBusinessUnitId,
                DimBillingBusinessUnitId,
                DimBillingConsultantId,
                DimBookingConsultantId,
                System_Name
            from
                cte_unquoted
        ),
        cte_out as
        (
            select 
                bu.CountryKey as Domain,
                Local_Issue_Date,
                PNR_Number,
                Document_Number,
                Refunded_Date,
                Document_Type,
                TicketType,
                Adult_Child_Indicator,
                Number_of_Nights_at_Total_Journey,
                Number_of_Nights_at_Destination,
                Issuing_IATA_Number,
                Issuing_IATA_Code,
                Local_First_Flight_Date,
                Journey_Type,
                Travel_Type,
                Airline_Code,
                Primary_Class,
                Multi_Class_Indicator,
                left(Routing_Description,8000) as Routing_Description,
                Origin_Airport_Code,
                org.Airport_City_Name Origin_Airport_City_Name,
                org.Airport_Country_Name Origin_Airport_Country_Name,
                Destination_Airport_Code,
                dst.Airport_City_Name Destination_Airport_City_Name,
                dst.Airport_Country_Name Destination_Airport_Country_Name,
                Number_of_Sectors,
                T3_Code,
                bu.AlphaCode,
                bu.OutletKey,
                DimBookingCurrentBusinessUnitId,
                DimBillingBusinessUnitId,
                DimBillingConsultantId,
                DimBookingConsultantId,
                System_Name
            from
                cte_formatted t
                outer apply
                (
                    select top 1 
                        org.Airport_City_Name,
                        org.Airport_Country_Name
                    from
                        [db-au-cmdwh]..usrAirportCountry org
                    where
                        org.Airport_Code = t.Origin_Airport_Code
                ) org
                outer apply
                (
                    select top 1 
                        dst.Airport_City_Name,
                        dst.Airport_Country_Name
                    from
                        [db-au-cmdwh]..usrAirportCountry dst
                    where
                        dst.Airport_Code = t.Destination_Airport_Code
                ) dst
                outer apply
                (
                    select top 1 
                        bu.AlphaCode,
                        bu.OutletKey,
						po.CountryKey
                    from
                        [db-au-cmdwh]..fltBusinessUnits bu
						LEFT JOIN [db-au-cmdwh]..penOutlet po ON po.OutletKey = bu.OutletKey AND po.OutletStatus = 'Current'
                    where
                        bu.BusinessUnitID = t.DimBookingCurrentBusinessUnitId
                ) bu
        )
        select 
            *
        into #fltTickets
        from
            cte_out


        create index idx on #fltTickets (Document_Number,PNR_Number)

        merge into [db-au-cmdwh].dbo.fltTickets t
        using #fltTickets s on
            s.Document_Number = t.DocumentNumber and
            s.PNR_Number = t.PNRNumber

        when matched and (t.FileDate is null or t.FileDate < @filedate) then
            update
            set
	            [T3Code] = s.T3_Code,
                [AlphaCode] = s.AlphaCode,
                [OutletKey] = s.OutletKey,
	            [IssueDate] = s.Local_Issue_Date,
	            [RefundedDate] = s.Refunded_Date,
	            [DocumentType] = s.Document_Type,
	            [TicketType] = s.TicketType,
	            [JourneyType] = s.Journey_Type,
	            [TravelType] = s.Travel_Type,
	            [AdultChildIndicator] = s.Adult_Child_Indicator,
	            [FirstFlightDate] = s.Local_First_Flight_Date,
	            [TotalDuration] = convert(int,left(Number_of_Nights_at_Total_Journey,charindex('.',Number_of_nights_at_Total_Journey)-1)),
	            [DurationAtDestination] = convert(int,left(Number_of_Nights_at_Destination,charindex('.',Number_of_nights_at_Destination)-1)),
	            [IATANumber] = s.Issuing_IATA_Number,
	            [IATACode] = s.Issuing_IATA_Code,
	            [AirlineCode] = s.Airline_Code,
	            [PrimaryClass] = s.Primary_Class,
	            [MultiClassIndicator] = s.Multi_Class_Indicator,
	            [RoutingDescription] = s.Routing_Description,
	            [NumberOfSectors] = s.Number_Of_Sectors,
	            [OriginAirportCode] = s.Origin_Airport_Code,
	            [OriginAirportCityName] = s.Origin_Airport_City_Name,
	            [OriginAirportCountryName] = s.Origin_Airport_Country_Name,
	            [DestinationAirportCode] = s.Destination_Airport_Code,
	            [DestinationAirportCityName] = s.Destination_Airport_City_Name,
	            [DestinationAirportCountryName] = s.Destination_Airport_Country_Name,
	            [BookingBusinessUnitID] = s.DimBookingCurrentBusinessUnitId,
	            [BillingBusinessUnitID] = s.DimBillingBusinessUnitId,
	            [BillingConsultantID] = s.DimBillingConsultantId,
	            [BookingConsultantID] = s.DimBookingConsultantId,
	            [SystemName] = s.System_Name,
                [FileDate] = @filedate,
                [LastUpdate] = getdate()

        when not matched by target then
            insert
            (
                [Domain],
	            [DocumentNumber],
	            [PNRNumber],
	            [T3Code],
                [AlphaCode],
                [OutletKey],
	            [IssueDate],
	            [RefundedDate],
	            [DocumentType],
	            [TicketType],
	            [JourneyType],
	            [TravelType],
	            [AdultChildIndicator],
	            [FirstFlightDate],
	            [TotalDuration],
	            [DurationAtDestination],
	            [IATANumber],
	            [IATACode],
	            [AirlineCode],
	            [PrimaryClass],
	            [MultiClassIndicator],
	            [RoutingDescription],
	            [NumberOfSectors],
	            [OriginAirportCode],
	            [OriginAirportCityName],
	            [OriginAirportCountryName],
	            [DestinationAirportCode],
	            [DestinationAirportCityName],
	            [DestinationAirportCountryName],
	            [BookingBusinessUnitID],
	            [BillingBusinessUnitID],
	            [BillingConsultantID],
	            [BookingConsultantID],
	            [SystemName],
                [FileDate],
                [LastUpdate]
            )
            values
            (
                s.Domain,
                s.Document_Number,
                s.PNR_Number,
                s.T3_Code,
                s.AlphaCode,
                s.OutletKey,
                s.Local_Issue_Date,
                s.Refunded_Date,
                s.Document_Type,
                s.TicketType,
                s.Journey_Type,
                s.Travel_Type,
                s.Adult_Child_Indicator,
                s.Local_First_Flight_Date,
	            convert(int,left(Number_of_Nights_at_Total_Journey,charindex('.',Number_of_nights_at_Total_Journey)-1)),
	            convert(int,left(Number_of_Nights_at_Destination,charindex('.',Number_of_nights_at_Destination)-1)),
                s.Issuing_IATA_Number,
                s.Issuing_IATA_Code,
                s.Airline_Code,
                s.Primary_Class,
                s.Multi_Class_Indicator,
                s.Routing_Description,
                s.Number_of_Sectors,
                s.Origin_Airport_Code,
                s.Origin_Airport_City_Name,
                s.Origin_Airport_Country_Name,
                s.Destination_Airport_Code,
                s.Destination_Airport_City_Name,
                s.Destination_Airport_Country_Name,
                s.DimBookingCurrentBusinessUnitId,
                s.DimBillingBusinessUnitId,
                s.DimBillingConsultantId,
                s.DimBookingConsultantId,
                s.System_Name,
                @filedate,
                getdate()
            )
        ;


        set @sql = 'exec xp_cmdshell ''move /Y "E:\ETL\Data\Flight Centre\Process\' + @filename + '" "E:\ETL\Data\Flight Centre\Archive"'''
        print @sql
        exec (@sql)

        update t
        set
            AlphaCode = bu.AlphaCode,
            OutletKey = bu.OutletKey
        from
            [db-au-cmdwh].dbo.fltTickets t
            cross apply
            (
                select top 1 
                    bu.AlphaCode,
                    bu.OutletKey
                from
                    [db-au-cmdwh]..fltBusinessUnits bu
                where
                    bu.BusinessUnitID = t.BookingBusinessUnitID
            ) bu
        where
            t.OutletKey is null and
            LastUpdate < convert(date, getdate())

        fetch next from c_files into @filename, @filedate

    end

    close c_files
    deallocate c_files

end
GO
