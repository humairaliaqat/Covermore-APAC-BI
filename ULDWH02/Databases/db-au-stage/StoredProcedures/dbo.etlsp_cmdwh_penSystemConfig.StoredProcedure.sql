USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penSystemConfig]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penSystemConfig]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20160321 - LT - Penguin 18.0, added US penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin


	if object_id('[db-au-stage].dbo.etl_penSystemConfig') is not null drop table [db-au-stage].dbo.etl_penSystemConfig
   select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar, a.SystemConfigID), 41) as SystemConfigKey,
        a.DomainID,
        a.SystemConfigID,
        a.ConfigKey,
        a.ConfigValue,
        a.ConfigDesc,
        a.[Status],
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) UpdateDateTime,
        a.CreateDateTime CreateDateTimeUTC,
        a.UpdateDateTime UpdateDateTimeUTC
	into [db-au-stage].dbo.etl_penSystemConfig        
    from
        penguin_tblSystemConfig_aucm a
        cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'AU')

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar, a.SystemConfigID), 41) as SystemConfigKey,
        a.DomainID,
        a.SystemConfigID,
        a.ConfigKey,
        a.ConfigValue,
        a.ConfigDesc,
        a.[Status],
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) UpdateDateTime,
        a.CreateDateTime CreateDateTimeUTC,
        a.UpdateDateTime UpdateDateTimeUTC
    from
        penguin_tblSystemConfig_autp a
        cross apply dbo.fn_GetDomainKeys(a.DomainID, 'TIP', 'AU')
    
    union all
    
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar, a.SystemConfigID), 41) as SystemConfigKey,
        a.DomainID,
        a.SystemConfigID,
        a.ConfigKey,
        a.ConfigValue,
        a.ConfigDesc,
        a.[Status],
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) UpdateDateTime,
        a.CreateDateTime CreateDateTimeUTC,
        a.UpdateDateTime UpdateDateTimeUTC
    from
        penguin_tblSystemConfig_ukcm a
        cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'UK')
        
    union all
    
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        left(PrefixKey + convert(varchar, a.SystemConfigID), 41) as SystemConfigKey,
        a.DomainID,
        a.SystemConfigID,
        a.ConfigKey,
        a.ConfigValue,
        a.ConfigDesc,
        a.[Status],
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) UpdateDateTime,
        a.CreateDateTime CreateDateTimeUTC,
        a.UpdateDateTime UpdateDateTimeUTC
    from
        penguin_tblSystemConfig_uscm a
        cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'US')
		
		        
    if object_id('[db-au-cmdwh].dbo.penSystemConfig') is null
    begin

        create table [db-au-cmdwh].dbo.penSystemConfig
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            DomainKey varchar(41) null,
            SystemConfigKey varchar(41) null,
            DomainID int null,
            SystemConfigID int null,
            ConfigKey varchar(50) null,
            ConfigValue varchar(max) null,
            ConfigDesc varchar(500) null,
            [Status] varchar(15) null,
            CreateDateTime datetime null,
            UpdateDateTime datetime null,
            CreateDateTimeUTC datetime null,
            UpdateDateTimeUTC datetime null
        )

        create clustered index idx_penSystemConfig_SystemConfigKey on [db-au-cmdwh].dbo.penSystemConfig(SystemConfigKey)
        create index idx_penSystemConfig_CountryKey on [db-au-cmdwh].dbo.penSystemConfig(CountryKey)
        create index idx_penSystemConfig_DomainKey on [db-au-cmdwh].dbo.penSystemConfig(DomainKey)
        create index idx_penSystemConfig_DomainID on [db-au-cmdwh].dbo.penSystemConfig(DomainID)

    end
    else
    begin
        delete [db-au-cmdwh].dbo.penSystemConfig
		from [db-au-cmdwh].dbo.penSystemConfig a
			join [db-au-stage].dbo.etl_penSystemConfig b on
				a.SystemConfigKey = b.SystemConfigKey
	end				

    insert [db-au-cmdwh].dbo.penSystemConfig with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        SystemConfigKey,
        DomainID,
        SystemConfigID,
        ConfigKey,
        ConfigValue,
        ConfigDesc,
        [Status],
        CreateDateTime,
        UpdateDateTime,
        CreateDateTimeUTC,
        UpdateDateTimeUTC
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        SystemConfigKey,
        DomainID,
        SystemConfigID,
        ConfigKey,
        ConfigValue,
        ConfigDesc,
        [Status],
        CreateDateTime,
        UpdateDateTime,
        CreateDateTimeUTC,
        UpdateDateTimeUTC
	from
		etl_penSystemConfig            
 
    
end

GO
