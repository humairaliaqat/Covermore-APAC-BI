USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAssistanceFee]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_penAssistanceFee]
as
begin
/*
20160321 - LT - Created. Penguin 18.0
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penAssistanceFee') is not null
        drop table etl_penAssistanceFee

   select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.AssistanceFeeID) AssistanceFeeKey,
		PrefixKey + convert(varchar,a.JointVentureId) JointVentureKey,
        a.AssistanceFeeId,
		a.JointVentureId,
        a.DomainID,
        a.Value,
		a.EffectiveFrom,
        a.CRMUserID,
        a.IsPolicyCount,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) as UpdateDateTime,
        a.[Status],
		a.CreateDateTime as CreateDateTimeUTC,
		a.UpdateDateTime as UpdateDateTimeUTC
    into etl_penAssistanceFee
    from
        penguin_tblAssistanceFee_aucm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'AU') dk

    union all

   select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.AssistanceFeeID) AssistanceFeeKey,
		PrefixKey + convert(varchar,a.JointVentureId) JointVentureKey,
        a.AssistanceFeeId,
		a.JointVentureId,
        a.DomainID,
        a.Value,
		a.EffectiveFrom,
        a.CRMUserID,
        a.IsPolicyCount,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) as UpdateDateTime,
        a.[Status],
		a.CreateDateTime as CreateDateTimeUTC,
		a.UpdateDateTime as UpdateDateTimeUTC
    from
        penguin_tblAssistanceFee_autp a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'TIP', 'AU') dk

    union all

   select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.AssistanceFeeID) AssistanceFeeKey,
		PrefixKey + convert(varchar,a.JointVentureId) JointVentureKey,
        a.AssistanceFeeId,
		a.JointVentureId,
        a.DomainID,
        a.Value,
		a.EffectiveFrom,
        a.CRMUserID,
        a.IsPolicyCount,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) as UpdateDateTime,
        a.[Status],
		a.CreateDateTime as CreateDateTimeUTC,
		a.UpdateDateTime as UpdateDateTimeUTC    
    from
        penguin_tblAssistanceFee_ukcm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'UK') dk

    union all

   select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.AssistanceFeeID) AssistanceFeeKey,
		PrefixKey + convert(varchar,a.JointVentureId) JointVentureKey,
        a.AssistanceFeeId,
		a.JointVentureId,
        a.DomainID,
        a.Value,
		a.EffectiveFrom,
        a.CRMUserID,
        a.IsPolicyCount,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, TimeZone) as CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, TimeZone) as UpdateDateTime,
        a.[Status],
		a.CreateDateTime as CreateDateTimeUTC,
		a.UpdateDateTime as UpdateDateTimeUTC    
    from
        penguin_tblAssistanceFee_ukcm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penAssistanceFee') is null
    begin

        create table [db-au-cmdwh].dbo.penAssistanceFee
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
			[DomainKey] varchar(41) null,
            [AssistanceFeeKey] varchar(41) null,
			[JointVentureKey] varchar(41) null,
            [AssistanceFeeID] int null,
            [JointVentureID] int null,
            [Value] numeric(18,4) null,
            [EffectiveFrom] datetime null,
            [CRMUserID] int null,
            [IsPolicyCount] bit null,
			[CreateDateTime] datetime null,
			[UpdateDateTime] datetime null,
			[Status] nvarchar(15) null,
			[CreateDateTimeUTC] datetime null,
			[UpdateDateTimeUTC] datetime null
        )

        create clustered index idx_penAssistanceFee_AssistanceFeeKey on [db-au-cmdwh].dbo.penAssistanceFee(AssistanceFeeKey)
        create nonclustered index idx_penAssistanceFee_CountryKey on [db-au-cmdwh].dbo.penAssistanceFee(CountryKey,CompanyKey,AssistanceFeeID)
		create nonclustered index idx_penAssistanceFee_JointVentureKey on [db-au-cmdwh].dbo.penAssistanceFee(JointVentureKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penAssistanceFee a
            inner join etl_penAssistanceFee b on
                a.AssistanceFeeKey = b.AssistanceFeeKey

    end

    insert [db-au-cmdwh].dbo.penAssistanceFee with(tablockx)
    (
        [CountryKey],
        [CompanyKey],
		[DomainKey],
        [AssistanceFeeKey],
		[JointVentureKey],
        [AssistanceFeeID],
        [JointVentureID],
        [Value],
        [EffectiveFrom],
        [CRMUserID],
        [IsPolicyCount],
		[CreateDateTime],
		[UpdateDateTime],
		[Status],
		[CreateDateTimeUTC],
		[UpdateDateTimeUTC]
    )
    select
        [CountryKey],
        [CompanyKey],
		[DomainKey],
        [AssistanceFeeKey],
		[JointVentureKey],
        [AssistanceFeeID],
        [JointVentureID],
        [Value],
        [EffectiveFrom],
        [CRMUserID],
        [IsPolicyCount],
		[CreateDateTime],
		[UpdateDateTime],
		[Status],
		[CreateDateTimeUTC],
		[UpdateDateTimeUTC]
    from
        etl_penAssistanceFee

end


GO
