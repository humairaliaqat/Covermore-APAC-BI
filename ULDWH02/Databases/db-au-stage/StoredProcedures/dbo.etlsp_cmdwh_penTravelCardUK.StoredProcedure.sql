USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penTravelCardUK]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penTravelCardUK]
as
begin


/************************************************************************************************************************************
Author:         LinUK Tor
Date:           2017-0719
Description:	Import UK_PenguinJob.dbo.tblTravelCard and UK_PenguinJob.dbo.tblTravelCard_Log to db-au-cmdwh
Change History:
                20170719 - LT - Procedure created
*************************************************************************************************************************************/

    set nocount on


    /*************************************************************/
    --select data into temporary table
    /*************************************************************/
    if object_id('etl_penTravelCardUK') is not null 
        drop table etl_penTravelCardUK
        
    select
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        left(dk.PrefixKey + convert(varchar,t.AccessTransactionReference collate database_default), 41) collate database_default as TravelCardKey,
		t.AccessTransactionReference,
		t.DistributorCode,
		t.BranchName,
		t.AccessCustomerId,
		t.EmailAddress,				
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(convert(datetime,right(t.[AccountCreationDate],4) + substring(t.[AccountCreationDate],4,2) + left(t.[AccountCreationDate],2),120), TimeZone)) as AccountCreationDate,
		convert(datetime,right(t.[AccountCreationDate],4) + substring(t.[AccountCreationDate],4,2) + left(t.[AccountCreationDate],2),120) as AccountCreationDateUTC,		
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(case when t.AccountStatusChangeDate = '' then null else t.AccountStatusChangeDate end, TimeZone)) as AccountStatusChangeDate,
		convert(datetime, case when t.AccountStatusChangeDate = '' then null else t.AccountStatusChangeDate end) as AccountStatusChangeDateUTC,
		t.CardholderFullName,
		t.CardNumber,
		convert(datetime,case when t.DateOfBirth > '' then t.DateOfBirth else null end) as DateOfBirth,
		t.TransactionGroup,
		t.TransactionGroupDesc,
		t.TransactionCode,
		t.TransactionCodeDesc,
		t.ProgramAccountType,
		t.ProgramName,				
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(convert(datetime,left(t.CustomerPostingDateTime,10) + ' ' + replace(right(t.CustomerPostingDateTime,8),'.',':')), TimeZone)) as CustomerPostingDateTime,
		convert(datetime,left(t.CustomerPostingDateTime,10) + ' ' + replace(right(t.CustomerPostingDateTime,8),'.',':')) as CustomerPostingDateTimeUTC,				
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(t.TransactionLocalDateTime, TimeZone)) as TransactionLocalDateTime,
		convert(datetime, t.TransactionLocalDateTime) as TransactionLocalDateTimeUTC,
		t.TransactionBINCurrency,
		t.TransactionBINCurrencyAmount,
		t.TransactionCurrency,
		t.TransactionAmount,
		t.PurseCurrency,
		t.PurseAmount,
		t.TransactionCountry,
		t.TransactionDesc,
		t.MerchantId,
		t.MerchantName,
		t.MerchantAddressCity,
		t.MerchantAddressPostcode,
		t.MerchantAddressRegion,
		t.MerchantAddressCountryCode,
		t.MerchantCategoryCode,
		t.CrossBorderIndicator,
		t.POSEntryMode,
		t.DomainCode,
		t.CompanyCode,	
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(t.CreateDateTime, TimeZone)) as CreateDateTime,
		convert(datetime, t.CreateDateTime) as CreateDateTimeUTC,		
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(t.ModifiedDateTime, TimeZone)) as ModifiedDateTime,
		convert(datetime, t.ModifiedDateTime) as ModifiedDateTimeUTC
    into etl_penTravelCardUK
    from
        penguin_tblTravelCard_UKcm t
		inner join [db-au-cmdwh].dbo.penDomain d on 
			t.DomainCode = d.CountryKey collate database_default and
			t.CompanyCode = d.CompanyKey collate database_default
        cross apply dbo.fn_GetDomainKeys(d.DomainID, 'CM', 'UK') dk


        
    /*************************************************************/
    --delete existing travelcard data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penTravelCard') is null
    begin
		create table [db-au-cmdwh].dbo.penTravelCard
		(
			[CountryKey] [varchar](2) NOT NULL,
			[CompanyKey] [varchar](5) NOT NULL,
			[DomainKey] [varchar](41) NULL,
			[TravelCardKey] [varchar](50) NOT NULL,
			[AccessTransactionReference] [varchar](50) NOT NULL,
			[DistributorCode] [varchar](17) NOT NULL,
			[BranchName] [varchar](20) NULL,
			[AccessCustomerId] [numeric](38, 0) NOT NULL,
			[EmailAddress] [varchar](50) NOT NULL,
			[AccountCreationDate] datetime NULL,
			[AccountCreationDateUTC] datetime NULL,
			[AccountStatusChangeDate] datetime NULL,
			[AccountStatusChangeDateUTC]datetime NULL,
			[CardholderFullName] [varchar](35) NOT NULL,
			[CardNumber] [varchar](16) NOT NULL,
			[DateOfBirth] datetime NULL,
			[TransactionGroup] [varchar](3) NULL,
			[TransactionGroupDesc] [varchar](40) NULL,
			[TransactionCode] [real] NULL,
			[TransactionCodeDesc] [varchar](40) NULL,
			[ProgramAccountType] [varchar](3) NULL,
			[ProgramName] [varchar](40) NULL,
			[CustomerPostingDateTime] datetime NULL,
			[CustomerPostingDateTimeUTC] datetime NULL,
			[TransactionLocalDateTime] datetime NOT NULL,
			[TransactionLocalDateTimeUTC] datetime NOT NULL,
			[TransactionBINCurrency] [varchar](3) NULL,
			[TransactionBINCurrencyAmount] [numeric](38, 2) NULL,
			[TransactionCurrency] [varchar](3) NULL,
			[TransactionAmount] [real] NULL,
			[PurseCurrency] [varchar](3) NULL,
			[PurseAmount] [numeric](15, 2) NULL,
			[TransactionCountry] [varchar](3) NULL,
			[TransactionDesc] [varchar](40) NULL,
			[MerchantId] [varchar](15) NULL,
			[MerchantName] [varchar](25) NULL,
			[MerchantAddressCity] [varchar](15) NULL,
			[MerchantAddressPostcode] [varchar](10) NULL,
			[MerchantAddressRegion] [varchar](3) NULL,
			[MerchantAddressCountryCode] [varchar](3) NULL,
			[MerchantCategoryCode] [numeric](38, 0) NULL,
			[CrossBorderIndicator] [varchar](1) NULL,
			[POSEntryMode] [varchar](2) NULL,
			[DomainCode] [varchar](2) NULL,
			[CompanyCode] [varchar](5) NULL,
			[CreateDateTime] [datetime] NOT NULL,
			[CreateDateTimeUTC] [datetime] NOT NULL,
			[ModifiedDateTime] [datetime] NOT NULL,
			[ModifiedDateTimeUTC] [datetime] NOT NULL
		)

        create clustered index idx_penTravelCard_TravelCardKey on [db-au-cmdwh].dbo.penTravelCard(TravelCardKey)
        create index idx_penTravelCard_CountryKey on [db-au-cmdwh].dbo.penTravelCard(CountryKey)
        create index idx_penTravelCard_CompanyKey on [db-au-cmdwh].dbo.penTravelCard(CompanyKey)
		create index idx_penTravelCard_ModifiedDateTime on [db-au-cmdwh].dbo.penTravelCard(ModifiedDateTime)

    end
    else
    begin

        delete a
        from 
            [db-au-cmdwh].dbo.penTravelCard a
            inner join etl_penTravelCardUK b on
                a.TravelCardKey = b.TravelCardKey
                
    end


    /*************************************************************/
    -- Load penTravelCard data
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penTravelCard with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        TravelCardKey,
		AccessTransactionReference,
		DistributorCode,
		BranchName,
		AccessCustomerId,
		EmailAddress,		
		AccountCreationDate,
		AccountCreationDateUTC,		
		AccountStatusChangeDate,
		AccountStatusChangeDateUTC,
		CardholderFullName,
		CardNumber,
		DateOfBirth,
		TransactionGroup,
		TransactionGroupDesc,
		TransactionCode,
		TransactionCodeDesc,
		ProgramAccountType,
		ProgramName,		
		CustomerPostingDateTime,
		CustomerPostingDateTimeUTC,		
		TransactionLocalDateTime,
		TransactionLocalDateTimeUTC,
		TransactionBINCurrency,
		TransactionBINCurrencyAmount,
		TransactionCurrency,
		TransactionAmount,
		PurseCurrency,
		PurseAmount,
		TransactionCountry,
		TransactionDesc,
		MerchantId,
		MerchantName,
		MerchantAddressCity,
		MerchantAddressPostcode,
		MerchantAddressRegion,
		MerchantAddressCountryCode,
		MerchantCategoryCode,
		CrossBorderIndicator,
		POSEntryMode,
		DomainCode,
		CompanyCode,		
		CreateDateTime,
		CreateDateTimeUTC,		
		ModifiedDateTime,
		ModifiedDateTimeUTC
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        TravelCardKey,
		AccessTransactionReference,
		DistributorCode,
		BranchName,
		AccessCustomerId,
		EmailAddress,		
		AccountCreationDate,
		AccountCreationDateUTC,		
		AccountStatusChangeDate,
		AccountStatusChangeDateUTC,
		CardholderFullName,
		CardNumber,
		DateOfBirth,
		TransactionGroup,
		TransactionGroupDesc,
		TransactionCode,
		TransactionCodeDesc,
		ProgramAccountType,
		ProgramName,		
		CustomerPostingDateTime,
		CustomerPostingDateTimeUTC,		
		TransactionLocalDateTime,
		TransactionLocalDateTimeUTC,
		TransactionBINCurrency,
		TransactionBINCurrencyAmount,
		TransactionCurrency,
		TransactionAmount,
		PurseCurrency,
		PurseAmount,
		TransactionCountry,
		TransactionDesc,
		MerchantId,
		MerchantName,
		MerchantAddressCity,
		MerchantAddressPostcode,
		MerchantAddressRegion,
		MerchantAddressCountryCode,
		MerchantCategoryCode,
		CrossBorderIndicator,
		POSEntryMode,
		DomainCode,
		CompanyCode,		
		CreateDateTime,
		CreateDateTimeUTC,		
		ModifiedDateTime,
		ModifiedDateTimeUTC
    from
        etl_penTravelCardUK



    /*************************************************************/
    --select data into temporary table
    /*************************************************************/
    if object_id('etl_penTravelCardLogUK') is not null 
        drop table etl_penTravelCardLogUK
        
    select
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        left(dk.PrefixKey + convert(varchar,tl.TransactionReferenceNumber collate database_default), 41) collate database_default as TravelCardKey,
		tl.TransactionReferenceNumber,
		tl.RecordSequenceNumber,
		tl.TransactionGroupDescription,
		tl.CardNumber,
		tl.CardholderFullName,
		tl.ProgrammeIDAccountType,
		tl.ProgramName,				
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(convert(datetime,left(tl.CustomerPostingDate,10) + ' ' + replace(right(tl.CustomerPostingDate,8),'.',':')), TimeZone)) as CustomerPostingDate,
		convert(datetime,left(tl.CustomerPostingDate,10) + ' ' + replace(right(tl.CustomerPostingDate,8),'.',':')) as CustomerPostingDateUTC,		
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(convert(datetime,right(tl.[LocalDateTime],4) + substring(tl.[LocalDateTime],4,2) + left(tl.[LocalDateTime],2),120), TimeZone)) as LocalDateTime,
		convert(datetime,right(tl.[LocalDateTime],4) + substring(tl.[LocalDateTime],4,2) + left(tl.[LocalDateTime],2),120) as LocalDateTimeUTC,
		tl.TransactionBINCurrency,
		tl.TransactionBINCurrencyAmount,
		tl.TransactionLocalCurrency,
		tl.TransactionAmountLocal,
		tl.PurseCurrency,
		tl.PurseAmount,
		tl.TransactionCountry,
		tl.TransactionDescription,
		tl.MerchantTerminalId,
		tl.MerchantID,
		tl.MerchantName,
		tl.MerchantAddressCity,
		tl.MerchantAddressPostalCode,
		tl.MerchantAddressRegion,
		tl.MerchantAddressCountryCode,
		tl.MerchantCategoryCode,
		tl.Prel,
		tl.BranchName,
		tl.CrossBorderIndicator,
		tl.POSEntryMode,
		tl.IPSAccountNumber,
		tl.CardholderEmail,		
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(convert(datetime,right(tl.[AccountCreationDate],4) + substring(tl.[AccountCreationDate],4,2) + left(tl.[AccountCreationDate],2),120), TimeZone)) as AccountCreationDate,
		convert(datetime,right(tl.[AccountCreationDate],4) + substring(tl.[AccountCreationDate],4,2) + left(tl.[AccountCreationDate],2),120) as AccountCreationDateUTC,
		convert(datetime,case when tl.DOB = '' then null else tl.DOB end) as DOB,
		tl.TransactionGroup,
		tl.TransactionCode,		
		convert(datetime, dbo.xfn_ConvertUTCtoLocal(case when tl.AccountStatusChangeDate = '' then null else tl.AccountStatusChangeDate end, TimeZone)) as AccountStatusChangeDate,
		convert(datetime, case when tl.AccountStatusChangeDate = '' then null else tl.AccountStatusChangeDate end) as AccountStatusChangeDateUTC,
		tl.TransactionCodeDescription,
		tl.[Status],
		tl.Comment
    into etl_penTravelCardLogUK
    from
		penguin_tblTravelCard_UKcm t
        inner join penguin_tblTravelCard_log_UKcm tl on 
			t.AccessTransactionReference = tl.TransactionReferenceNumber
		inner join [db-au-cmdwh].dbo.penDomain d on 
			t.DomainCode = d.CountryKey collate database_default and
			t.CompanyCode = d.CompanyKey collate database_default
        cross apply dbo.fn_GetDomainKeys(d.DomainID, 'CM', 'UK') dk

       
    /*************************************************************/
    --delete existing travelcardlog data or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.penTravelCardLog') is null
    begin
		create table [db-au-cmdwh].dbo.penTravelCardLog
		(
			[CountryKey] [varchar](2) NOT NULL,
			[CompanyKey] [varchar](5) NOT NULL,
			[DomainKey] [varchar](41) NULL,
			[TravelCardKey] [varchar](50) NOT NULL,
			[TransactionReferenceNumber] [varchar](50) NOT NULL,
			[RecordSequenceNumber] [varchar](8) NULL,
			[TransactionGroupDescription] [varchar](40) NULL,
			[CardNumber] [varchar](16) NULL,
			[CardholderFullName] [varchar](35) NULL,
			[ProgrammeIDAccountType] [varchar](3) NULL,
			[ProgramName] [varchar](40) NULL,
			[CustomerPostingDate] datetime NULL,
			[CustomerPostingDateUTC] datetime NULL,
			[LocalDateTime] datetime NULL,
			[LocalDateTimeUTC] datetime NULL,
			[TransactionBINCurrency] [varchar](15) NULL,
			[TransactionBINCurrencyAmount] [real] NULL,
			[TransactionLocalCurrency] [varchar](15) NULL,
			[TransactionAmountLocal] [real] NULL,
			[PurseCurrency] [varchar](3) NULL,
			[PurseAmount] [real] NULL,
			[TransactionCountry] [varchar](3) NULL,
			[TransactionDescription] [varchar](40) NULL,
			[MerchantTerminalId] [varchar](10) NULL,
			[MerchantID] [varchar](15) NULL,
			[MerchantName] [varchar](25) NULL,
			[MerchantAddressCity] [varchar](15) NULL,
			[MerchantAddressPostalCode] [varchar](10) NULL,
			[MerchantAddressRegion] [varchar](3) NULL,
			[MerchantAddressCountryCode] [varchar](3) NULL,
			[MerchantCategoryCode] [real] NULL,
			[Prel] [varchar](17) NULL,
			[BranchName] [varchar](20) NULL,
			[CrossBorderIndicator] [varchar](1) NULL,
			[POSEntryMode] [varchar](2) NULL,
			[IPSAccountNumber] [varchar](12) NULL,
			[CardholderEmail] [varchar](50) NULL,
			[AccountCreationDate] datetime NULL,
			[AccountCreationDateUTC] datetime NULL,
			[DOB] datetime NULL,
			[TransactionGroup] [varchar](3) NULL,
			[TransactionCode] [real] NULL,
			[AccountStatusChangeDate] datetime NULL,
			[AccountStatusChangeDateUTC] datetime NULL,
			[TransactionCodeDescription] [varchar](40) NULL,
			[Status] [varchar](20) NULL,
			[Comment] [varchar](max) NULL
		)

        create clustered index idx_penTravelCardLog_TravelCardKey on [db-au-cmdwh].dbo.penTravelCardLog(TravelCardKey)
        create index idx_penTravelCardLog_CountryKey on [db-au-cmdwh].dbo.penTravelCardLog(CountryKey)
        create index idx_penTravelCardLog_CompanyKey on [db-au-cmdwh].dbo.penTravelCardLog(CompanyKey)		

    end
    else
    begin

        delete a
        from 
            [db-au-cmdwh].dbo.penTravelCardLog a
            inner join etl_penTravelCardLogUK b on
                a.TravelCardKey = b.TravelCardKey
                
    end


    /*************************************************************/
    -- Load penTravelCard data
    /*************************************************************/
    insert into [db-au-cmdwh].dbo.penTravelCardLog with (tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        TravelCardKey,
		TransactionReferenceNumber,
		RecordSequenceNumber,
		TransactionGroupDescription,
		CardNumber,
		CardholderFullName,
		ProgrammeIDAccountType,
		ProgramName,		
		CustomerPostingDate,
		CustomerPostingDateUTC,
		LocalDateTime,
		LocalDateTimeUTC,
		TransactionBINCurrency,
		TransactionBINCurrencyAmount,
		TransactionLocalCurrency,
		TransactionAmountLocal,
		PurseCurrency,
		PurseAmount,
		TransactionCountry,
		TransactionDescription,
		MerchantTerminalId,
		MerchantID,
		MerchantName,
		MerchantAddressCity,
		MerchantAddressPostalCode,
		MerchantAddressRegion,
		MerchantAddressCountryCode,
		MerchantCategoryCode,
		Prel,
		BranchName,
		CrossBorderIndicator,
		POSEntryMode,
		IPSAccountNumber,
		CardholderEmail,		
		AccountCreationDate,
		AccountCreationDateUTC,
		DOB,
		TransactionGroup,
		TransactionCode,		
		AccountStatusChangeDate,
		AccountStatusChangeDateUTC,
		TransactionCodeDescription,
		[Status],
		Comment
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        TravelCardKey,
		TransactionReferenceNumber,
		RecordSequenceNumber,
		TransactionGroupDescription,
		CardNumber,
		CardholderFullName,
		ProgrammeIDAccountType,
		ProgramName,		
		CustomerPostingDate,
		CustomerPostingDate,
		LocalDateTime,
		LocalDateTime,
		TransactionBINCurrency,
		TransactionBINCurrencyAmount,
		TransactionLocalCurrency,
		TransactionAmountLocal,
		PurseCurrency,
		PurseAmount,
		TransactionCountry,
		TransactionDescription,
		MerchantTerminalId,
		MerchantID,
		MerchantName,
		MerchantAddressCity,
		MerchantAddressPostalCode,
		MerchantAddressRegion,
		MerchantAddressCountryCode,
		MerchantCategoryCode,
		Prel,
		BranchName,
		CrossBorderIndicator,
		POSEntryMode,
		IPSAccountNumber,
		CardholderEmail,		
		AccountCreationDate,
		AccountCreationDate,
		DOB,
		TransactionGroup,
		TransactionCode,		
		AccountStatusChangeDate,
		AccountStatusChangeDate,
		TransactionCodeDescription,
		[Status],
		Comment
    from
        etl_penTravelCardLogUK



end
GO
