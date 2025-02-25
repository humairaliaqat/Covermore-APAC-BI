USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_201_Funder]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_201_Funder] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Org => Funder

	-- 1. update PrimaryIndustry field in pnpFunder because it was not migrated
	update f
	set PrimaryIndustry = o.Industry
	from 
		[db-au-dtc]..pnpFunder f 
		join [db-au-stage]..dtc_cli_org_lookup lu on convert(varchar, lu.kfunderid) = f.FunderID
		join [db-au-stage]..dtc_cli_base_org bo on bo.pene_id = lu.uniquefunderid
		join [db-au-stage]..dtc_cli_org o on o.org_id = bo.org_id 
	where 
		f.PrimaryIndustry is null 
		and o.Industry is not null 

	-- 2. transform
	if object_id('tempdb..#src') is not null drop table #src
	select * into #src 
	from (
		select 
			1 IsCurrent,
			'1900-01-01' StartDate,
			'9999-12-31' EndDate,
			'CLI_ORG_' + o.Org_ID FunderID,
			case when o.DisplayOrgName is not null and o.DisplayOrgName <> o.OrgName then o.OrgName + ' (' + o.DisplayOrgName + ')' else o.OrgName end Funder,
			o.DisplayOrgName DisplayName,
			'other' Type,
			null Type2,
			'EAP' Class,
			'Insured' BillType,
			'Monthly' StatementCycle,
			'Australian GST' TaxSched,
			'GST' TaxSchedShort,
			null TaxSchedNotes,
			case 
				when o.InActive = -1 then 'Inactive' 
				else 'Active' 
			end FunderState,
			'Accounts Payable' BillTo,
			o.Address1 AddressLine1,
			o.Address2 AddressLine2,
			o.City,
			o.[State],
			null StateShort,
			convert(nvarchar(30), o.Country) Country,
			null CountryShort,
			null Country2CharCode,
			o.Zip Postcode,
			replace(o.PriPhone, ' ','') Phone1,
			replace(o.AltPhone, ' ','') Phone2,
			o.FaxPhone Fax,
			o.[URL],
			o.Comments Notes,
			(select * from [db-au-stage]..dtc_cli_org i where i.Org_ID = o.Org_ID for json path, without_array_wrapper) NotesLong,
			o.AddDate CreatedDatetime,
			o.ChangeDate UpdatedDatetime,
			o.AddUser CreatedBy,
			o.ChangeUser UpdatedBy,
			r.resource_desc AccountManager,
			o.WDADebtorCode DebtorCode  
		from 
			[db-au-stage]..dtc_cli_org o 
			left join [db-au-stage]..dtc_cli_base_org bo on bo.org_id = o.org_id 
			left join [db-au-stage]..dtc_cli_org_lookup ol on ol.uniquefunderid = bo.pene_id 
			left join [db-au-stage]..dtc_cli_PaResrce r on o.AcctMgr = r.resource_code 
		where 
			ol.kfunderid is null	-- exclude the ones that have already been imported
	) a

	-- data cleansing
	update #src
	set Country = 'Australia'
	where Country IS NULL
	and [State] in ('NSW','QLD','VIC','ACT','SA' ,'NT' ,'TAS','WA')

	update #src
	SET [state] = null, Country = 'Singapore'
	WHERE [State] IN ('SG','SIN','SNG')

	update #src
	SET [state] = null, Country = 'New Zealand'
	WHERE [State] IN ('NZ')

	update #src
	SET [state] = null, Country = 'Hong Kong'
	WHERE [State] IN ('HKG','HK')

	update #src
	SET [state] = null, Country = 'Indonesia'
	WHERE [State] IN ('JAKARTA','IN','IND')

	update #src
	SET [state] = null, Country = 'Spain'
	WHERE [State] IN ('ESP')

	update #src
	SET [state] = null, Country = 'China'
	WHERE [State] IN ('CHN')

	update #src
	SET [state] = null, Country = 'Canada'
	WHERE [State] IN ('CAN')

	update #src
	SET [state] = null, Country = 'HUNGARY'
	WHERE [State] IN ('HUNGARY')

	update #src
	SET [state] = null, Country = 'Malaysia'
	WHERE [State] IN ('MAL')

	update #src
	SET [state] = null, Country = 'Japan'
	WHERE [State] IN ('JAP')

	update #src
	SET [state] = null, Country = 'United Kingdom'
	WHERE [State] IN ('TN2','KENT ','KENT TN2','MILTON KEYNES','UK')
	OR [Country] IN ('UK','England')

	update #src
	SET [state] = null, Country = 'Papua New Guinea'
	WHERE [State] IN ('PNG')

	update #src
	SET [state] = null, Country = 'Philippines'
	WHERE [State] IN ('PHILIPPINES','PHP')

	update #src
	SET [state] = null, Country = 'Thailand'
	WHERE [State] IN ('THA')

	update #src
	SET [state] = null, Country = 'Paraguay'
	WHERE [State] IN ('PAR')

	update #src
	SET [state] = null, Country = 'United States'
	WHERE Country = 'USA'

	update #src
	SET [state] = NULL, Country = NULL
	WHERE [State] IN ('N/A','NA','NCD','EAO','EAP','IL','ISA','ONLINE ASSISTANCE','.')
	OR [State] = ''
	OR ([State] IS NULL and Country = 'Australia')

	update #src
	SET [state] = null
	WHERE Country <> 'Australia' 
	AND [State] IS NULL

	update #src
	set [state] = CASE WHEN Country = 'Australia' THEN 
			CASE [state]
				WHEN 'NSW' THEN 'New South Wales'
				WHEN 'HRN' THEN 'New South Wales'
				WHEN '2010' THEN 'New South Wales'
				WHEN 'SYDNEY' THEN 'New South Wales'
				WHEN 'QLD' THEN 'Queensland'
				WHEN 'QLD4003' THEN 'Queensland'
				WHEN 'QLF' THEN 'Queensland'
				WHEN 'VIC' THEN 'Victoria'
				WHEN 'VICVIC' THEN 'Victoria'
				WHEN 'ACT' THEN 'ACT'
				WHEN 'SA'  THEN 'South Australia'
				WHEN 'NT'  THEN 'Northern Territory'
				WHEN 'TN2'  THEN 'Northern Territory'
				WHEN 'TAS' THEN 'Tasmania'
				WHEN 'WA'  THEN 'Western Australia'
				WHEN 'WAP'  THEN 'Western Australia'
			ELSE [state] END
		ELSE [state] END

	-- 3. load 
	merge [db-au-dtc]..pnpFunder as tgt
	using #src
		on #src.FunderID = tgt.FunderID 
	when not matched by target then 
		insert (
			IsCurrent,
			StartDate,
			EndDate,
			FunderID,
			Funder,
			DisplayName,
			Type,
			Type2,
			Class,
			BillType,
			StatementCycle,
			TaxSched,
			TaxSchedShort,
			TaxSchedNotes,
			FunderState,
			BillTo,
			AddressLine1,
			AddressLine2,
			City,
			State,
			StateShort,
			Country,
			CountryShort,
			Country2CharCode,
			Postcode,
			Phone1,
			Phone2,
			Fax,
			URL,
			Notes,
			NotesLong,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			AccountManager,
			DebtorCode
		)
		values (
			#src.IsCurrent,
			#src.StartDate,
			#src.EndDate,
			#src.FunderID,
			#src.Funder,
			#src.DisplayName,
			#src.Type,
			#src.Type2,
			#src.Class,
			#src.BillType,
			#src.StatementCycle,
			#src.TaxSched,
			#src.TaxSchedShort,
			#src.TaxSchedNotes,
			#src.FunderState,
			#src.BillTo,
			#src.AddressLine1,
			#src.AddressLine2,
			#src.City,
			#src.State,
			#src.StateShort,
			#src.Country,
			#src.CountryShort,
			#src.Country2CharCode,
			#src.Postcode,
			#src.Phone1,
			#src.Phone2,
			#src.Fax,
			#src.URL,
			#src.Notes,
			#src.NotesLong,
			#src.CreatedDatetime,
			#src.UpdatedDatetime,
			#src.CreatedBy,
			#src.UpdatedBy,
			#src.AccountManager,
			#src.DebtorCode 
		)
	when matched then update set 
		tgt.IsCurrent = #src.IsCurrent,
		tgt.StartDate = #src.StartDate,
		tgt.EndDate = #src.EndDate,
		tgt.Funder = #src.Funder,
		tgt.DisplayName = #src.DisplayName,
		tgt.Type = #src.Type,
		tgt.Type2 = #src.Type2,
		tgt.Class = #src.Class,
		tgt.BillType = #src.BillType,
		tgt.StatementCycle = #src.StatementCycle,
		tgt.TaxSched = #src.TaxSched,
		tgt.TaxSchedShort = #src.TaxSchedShort,
		tgt.TaxSchedNotes = #src.TaxSchedNotes,
		tgt.FunderState = #src.FunderState,
		tgt.BillTo = #src.BillTo,
		tgt.AddressLine1 = #src.AddressLine1,
		tgt.AddressLine2 = #src.AddressLine2,
		tgt.City = #src.City,
		tgt.State = #src.State,
		tgt.StateShort = #src.StateShort,
		tgt.Country = #src.Country,
		tgt.CountryShort = #src.CountryShort,
		tgt.Country2CharCode = #src.Country2CharCode,
		tgt.Postcode = #src.Postcode,
		tgt.Phone1 = #src.Phone1,
		tgt.Phone2 = #src.Phone2,
		tgt.Fax = #src.Fax,
		tgt.URL = #src.URL,
		tgt.Notes = #src.Notes,
		tgt.NotesLong = #src.NotesLong,
		tgt.CreatedDatetime = #src.CreatedDatetime,
		tgt.UpdatedDatetime = #src.UpdatedDatetime,
		tgt.CreatedBy = #src.CreatedBy,
		tgt.UpdatedBy = #src.UpdatedBy,
		tgt.AccountManager = #src.AccountManager,
		tgt.DebtorCode = #src.DebtorCode 
	;


	-- update account manager 
	update f 
	set AccountManager = r.resource_desc 
	from 
		[db-au-stage]..dtc_cli_org o 
		left join [db-au-stage]..dtc_cli_base_org bo on bo.org_id = o.org_id 
		left join [db-au-stage]..dtc_cli_org_lookup lu on lu.uniquefunderid = bo.Pene_id 
		join [db-au-stage]..dtc_cli_PaResrce r on r.resource_code = o.AcctMgr 
		join [db-au-dtc]..pnpFunder f on f.FunderID = coalesce(convert(varchar, lu.kfunderid), 'CLI_ORG_' + o.Org_ID)
	where 
		f.AccountManager is null

	-- update debtor code 
	update f 
	set DebtorCode = o.WDADebtorCode 
	from 
		[db-au-stage]..dtc_cli_org o 
		join [db-au-dtc]..pnpFunder f on f.FunderID = 'CLI_ORG_' + o.Org_ID
	where 
		f.DebtorCode is null 

END

GO
