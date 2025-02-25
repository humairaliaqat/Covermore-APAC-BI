USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_206_Site]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_206_Site] 
AS
BEGIN

	SET NOCOUNT ON;

	-- DTOffice => Site

	/*
	stage tables:
		[db-au-stage]..dtc_cli_DTOffice 
		[db-au-stage]..dtc_cli_DTOfficeRooms 

	pnpSite:	
		SiteSK
		SiteID					'CLI_OFF_' + DTOffice_ID
		SiteName				OfficeName	
		CreatedDatetime			AddDate
		UpdatedDatetime			ChangeDate
		AddressLine1			Address1
		AddressLine2			Address2
		City					City
		State					State
		StateShort				State
		Country					Country
		CountryShort			Country
		Postcode				Postcode
		Phone					PriPhone
		Fax						FaxPhone
		PlaceOfService			
		SendClaimToAddress		
		SendPaymentToAddress	
		Active					'1'
		ParentSiteID			
		sitefahcsiaoutlet		
		BankNumber				
		siteud1
		siteud2
		siteud3
		siteud4
		siteud5
		siteud6
		Region
		RegionCode
		County
		SiteGLCode
		LocSameAsAgency
		siteud7
	*/


	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 
	select * into #src 
	from (
		select 
			'CLI_OFF_' + o.DTOffice_ID SiteID,
			o.OfficeName SiteName,
			o.AddDate CreatedDatetime,
			o.ChangeDate UpdatedDatetime,
			o.Address1 AddressLine1,
			o.Address2 AddressLine2,
			o.City City,
			case o.State
				when 'ACT' then 'ACT' 
				when 'NSW' then 'New South Wales' 
				when 'NT' then 'Northern Territory' 
				when 'QLD' then 'Queensland' 
				when 'SA' then 'South Australia' 
				when 'TAS' then 'Tasmania' 
				when 'VIC' then 'Victoria' 
				when 'WA' then 'Western Australia' 
				when 'SNG' then '[Not Required]' 
				else 'New South Wales' 
			end State,
			case 
				when o.State = 'SNG' then '-' 
				when o.State is null then 'NSW'
				else o.State 
			end StateShort,
			case o.Country 
				when 'Singapore' then 'Singapore'
				else 'Australia' 
			end Country,
			case o.Country 
				when 'Singapore' then 'SNG'
				else 'AUS' 
			end CountryShort,
			o.Postcode Postcode,
			o.PriPhone Phone,
			o.FaxPhone Fax,
			'1' Active
		from 
			[db-au-stage]..dtc_cli_DTOffice o 
			left join [db-au-stage]..dtc_cli_DTOfficeRooms r on o.DTOffice_ID = r.DTOffice_ID 
			left join [db-au-stage]..dtc_cli_Temp_Offices t on t.DTOffice_ID = o.DTOffice_ID 
			left join [db-au-stage]..dtc_cli_Site s on s.uniquesiteid = t.pene_id 
			left join [db-au-stage]..dtc_cli_Site_Lookup sl on sl.uniquesiteid = s.uniquesiteid 
		where 
			sl.ksiteid is null	-- exclude the one migrated in custom migration 
			and o.DTOffice_ID not in (	-- exclude the ones created by users in Penelope 
				'A87B7E9FA9D04127ADA6CC34E3966AFD',	-- ksiteid 73
				'90416885533842A98B0C65C320E5344A',	-- 60
				'E35A4402E46D48DD8C3A77816F566A2E',	-- 61
				'825FC6CC93454B3F822AD745D7D639D7',	-- 120
				'2BABC8ECCC834CB592DDB4D1AD122E65',	-- 47
				'3B36E97ABE184D82AAA80CD328C796BE',	-- 78
				'3BE51AAB93B04EC4BC788B0BCE7FA52F',	-- 66
				'2590B529D46942C19BECBFF475C6AE19',	-- 67
				'572119ACBA39430391E90EE0BF880CCE',	-- 72
				'006D69241921485B92E93CE4EBBB676B',	-- 79
				'F7CF630ABD9A43F989F3C998FCB259DA',	-- 80
				'B2D1306DD72C4CF1A19F98D34A32748A',	-- 21
				'D63D35F6A2BC46818684DD7C7EBFE496',	-- 48
				'C536EB69CA5F4A1986EC4737A7A74932',	-- 19
				'9343C7D37EF1423FB8B0569FCD71C741',	-- 30
				'892E5B335F784B94868A64A6CEDEC32F',	-- 52
				'672F4881D5B548E49225EC27E8532E06',	-- 53
				'E1EB6F3630B647808EEC5C394E7EEF37',	-- 69
				'44633E5FD2CC41E3B82DB7BA42C34856',	-- 70
				'266AC68ED6664721BE4E610E45F228D5',	-- 81
				'A4E86F69113D4E6A89468DC9EEC463BF',	-- 50
				'CFCBE185A5B84F6BA45886448ECFEFD5',	-- 88
				'2D6EF89C7F764BF49B9B97C64C505CA8',	-- 54
				'B45409975402492F957119A87BAF5EF8',	-- 55
				'E6955AEE09D542E2BFA67BBEEB4156F5',	-- 56
				'9E571D140C9441F9A34E0DF47F3B8C08',	-- 126
				'9E112F6CC02F4000A3B6C54FA8A79000',	-- 74
				'52B4C1345D3F43B0B60D8CAC4272F66E',	-- 51
				'0877D7865A9C43F090054F69DC469C61',	-- 83
				'1113E831D3D74A72B6460D3FF64BA242',	-- 84
				'EA81A91BBD384A90A070262C37313CB2',	-- 85
				'22B9A8FD35D84ECFAAE3C1FA3DA4DF60',	-- 44
				'80AF2657C58D4B248CF602CA333B2ADC',	-- 62
				'C9E36EE38297435A9BCF8B3FBEA17278',	-- 57
				'C0F39CEAE376496791A2ABDF53C20CD5',	-- 86
				'EA28BF61CEA54E249CA6A0445C5CC624',	-- 63
				'48A331930594456AA695E5B31E2D808C',	-- 75
				'C5393A3392BE47719A8FC79F096F99AD',	-- 76
				'F1FE8663AE2C4A0AA3C032707EDBAD93',	-- 64
				'AB16F7F60DEE4DFA92E1186E96221CD4',	-- 87
				'D3AC751BB00C4A9A886906C38D726323',	-- 71
				'4D2D0E1F23E045178F00FAF39FA53C16',	-- 82
				'98CDA7DE0CE3457C9590495BD6CF1A55',	-- 89
				'A4E662C600A348AC81256AFA036FEBA9',	-- 24
				'E8BBF0F8F51340E696AE9F9959178A62',	-- 90
				'6BF739AFF177472EAAFC973CCACCB3C2',	-- 58
				'5B66577086F746ADBF0FE15A1950C49A',	-- 117
				'96FBCCCA1EE34CFABDB853255F80946F',	-- 123
				'FD2614F0DB7E462DA3858A79BE60CE99',	-- 65
				'C062CC49DA47436DB9A2E24EC34EF66A',	-- 20
				'2E92BF31CC5047618B9BB8F048C6D070',	-- 26
				'9A65723EA181431EBDDA882351ADAA58',	-- 59
				'CCB871B4EAE5415DAE0E00D542312846',	-- 77
				'A4D1CD1525D04151A56D9767481D14CC',	-- 25
				'AE11AB9CCDB249E7961FEA6D25838B1D',	-- 91
				'BF17221ABBDA4D48BD14DCBF2BF2AE3C',	-- 1
				'5CD2B82350C141D98E98038A91A1FD4E',	-- 23
				'52115C70B6F1422E8493F8697E68BE9E',	-- 49
				'2BF70C29E34C4D45BD33CDDB4C4BCAAC',	-- 46
				'E8043DF782ED417E80A0A93EF0DAC095',	-- 10
				'25B06804564E46CA94DB411C24CA45AD',	-- 92
				'1A83FDC133764667B928E0FFF6AE11BC'	-- 27
			)
	) a 

	alter table #src alter column Active tinyint NULL
	alter table #src alter column State varchar(100) null
	alter table #src alter column Country varchar(300) null
	alter table #src alter column CountryShort varchar(100) null


	-- add dummy sites for specific Clientele jobs
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N663401','NRL Clinical Management')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664697','Manly-Warringah Sea Eagles')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664702','Parramatta Eels')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_V664699','Melbourne Storm')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664700','Newcastle Knights')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664704','St George-Illawarra Dragons')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664703','Penrith Panthers')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664705','South Sydney Rabbitohs')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664695','Cronulla-Sutherland Sharks')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q664701','North Queensland Cowboys')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q665175','QRL Clinical Management')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664693','Canterbury-Bankstown Bulldogs')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q664696','Gold Coast Titans')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A664708','Canberra Raiders')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664707','Wests Tigers')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_N664706','Sydney Roosters')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q664692','Brisbane Broncos')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A392412','Leonora')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A392413','Curtin')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A671987','Canberra')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q716448','Cairns')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q721492','Thursday Island')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_Q738874','Coolangatta Airport')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A392416','Scherger')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_A392418','Ponteville')
	insert into #src (SiteID, SiteName) values ('DUMMY_FOR_JOB_W650307','Telfer')



	-- 2. load
	merge [db-au-dtc]..pnpSite as tgt
	using #src
		on #src.SiteID = tgt.SiteID 
	when not matched by target then 
		insert (
			SiteID,
			SiteName,
			CreatedDatetime,
			UpdatedDatetime,
			AddressLine1,
			AddressLine2,
			City,
			[State],
			StateShort,
			Country,
			CountryShort,
			Postcode,
			Phone,
			Fax,
			[Active]
		)
		values (
			#src.SiteID,
			#src.SiteName,
			#src.CreatedDatetime,
			#src.UpdatedDatetime,
			#src.AddressLine1,
			#src.AddressLine2,
			#src.City,
			#src.[State],
			#src.StateShort,
			#src.Country,
			#src.CountryShort,
			#src.Postcode,
			#src.Phone,
			#src.Fax,
			#src.[Active]
		)
	when matched then update set 
		tgt.SiteName = #src.SiteName,
		tgt.CreatedDatetime = #src.CreatedDatetime,
		tgt.UpdatedDatetime = #src.UpdatedDatetime,
		tgt.AddressLine1 = #src.AddressLine1,
		tgt.AddressLine2 = #src.AddressLine2,
		tgt.City = #src.City,
		tgt.[State] = #src.[State],
		tgt.StateShort = #src.StateShort,
		tgt.Country = #src.Country,
		tgt.CountryShort = #src.CountryShort,
		tgt.Postcode = #src.Postcode,
		tgt.Phone = #src.Phone,
		tgt.Fax = #src.Fax,
		tgt.[Active] = #src.[Active]
	;


	-- set parent site for dummies 
	update s set 
		ParentSiteID = 
		case 
			when s.SiteID in (
				'DUMMY_FOR_JOB_A392412',
				'DUMMY_FOR_JOB_A392413',
				'DUMMY_FOR_JOB_A671987',
				'DUMMY_FOR_JOB_Q716448',
				'DUMMY_FOR_JOB_Q721492',
				'DUMMY_FOR_JOB_Q738874',
				'DUMMY_FOR_JOB_A392416',
				'DUMMY_FOR_JOB_A392418'
			) then '94' 
			else cs.SiteID 
		end
	from 
		[db-au-dtc]..pnpSite s 
		outer apply (
			select top 1 
				 SiteID 
			from 
				[db-au-dtc]..pnpSite 
			where 
				SiteName = 'Customer Sites'
		) cs
	where 
		s.SiteID like 'DUMMY%'


	-- add sites for specific jobs to allow reporting on DIBP and Origin 
	
END

GO
