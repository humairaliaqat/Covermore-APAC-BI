USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_205_IndividualContact]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_205_IndividualContact] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Must come after the Individual and ServiceFile
		/*
		Penelope contact types
		contacttype			contactclass
		Collateral Email	E-mail address
		Collateral Phone 1	Phone with Ext.
		Collateral Phone 2	Phone with Ext.
		Home Phone			Phone Number
		Personal Email		E-mail address
		Personal Mobile		Phone Number
		Website				URL
		Work Email			E-mail address
		Work Fax			Phone Number
		Work Mobile			Phone Number
		Work Phone			Phone with Ext.


		[pnpIndividualContact]
		IndividualContactSK
		IsCurrent
		StartDate
		EndDate
		IndividualID
		ContactTypeID
		ContactType
		ContactClass
		Contact
		ContactExt
		UseContact
		CommInstructions
		*/


		-- 1. transform 
		if object_id('tempdb..#src') is not null drop table #src
		select * into #src 
		from (
			select 
				1 IsCurrent,
				'1900-01-01' StartDate,
				'9999-12-31' EndDate,
				'CLI_PER_' + p.Per_ID IndividualID,
				replace(cast(p.PriPhone as varchar(max)), ' ', '') [Home Phone],
				replace(cast(p.CellPhone as varchar(max)),' ','') [Work Mobile], 
				case 
					when replace(cast(p.AltPhone as varchar(max)),' ','') like '04%' then null 
					else replace(cast(p.AltPhone as varchar(max)),' ','') 
				end [Work Phone],
				cast(p.EmailAddress as varchar(max)) [Work Email],
				case 
					when P.EmailAddress is not null then 'Work Email'
					when P.CellPhone is not null then 'Work Mobile'
					when P.AltPhone is not null and replace(cast(p.AltPhone as varchar(max)),' ','') like '04%' then 'Work Mobile' 
					when P.AltPhone is not null then 'Work Phone' 
					when P.PriPhone is not null then 'Home Phone'
					else null
				end as PrimaryContact
			from 
				[db-au-stage]..dtc_cli_person p
				left join [db-au-stage]..dtc_cli_base_person bp on bp.Per_id = p.Per_ID 
				left join [db-au-stage]..dtc_cli_person_lookup pl on pl.uniqueindid = bp.pene_id
			where 
				pl.kindid is null 	-- exclude the ones that have already been imported
		) a 
		unpivot (
			Contact for ContactType IN ([Home Phone],[Work Mobile],[Work Email],[Work Phone])
		) t


		-- find all personal emails
		declare @PersonalEmails varchar(4000) = '|@live.|'
		set @PersonalEmails = @PersonalEmails + '@hotmail.|'
		set @PersonalEmails = @PersonalEmails + '@outlook.|' 
		set @PersonalEmails = @PersonalEmails + '@gmail.|' 
		set @PersonalEmails = @PersonalEmails + '@aol.|' 
		set @PersonalEmails = @PersonalEmails + '@zoho.|' 
		set @PersonalEmails = @PersonalEmails + '@126.|' 
		set @PersonalEmails = @PersonalEmails + '@163.|' 
		set @PersonalEmails = @PersonalEmails + '@yahoo.|' 
		set @PersonalEmails = @PersonalEmails + '@7mail.|' 
		set @PersonalEmails = @PersonalEmails + '@y7mail.|' 
		set @PersonalEmails = @PersonalEmails + '@yahooy7mail.|' 
		set @PersonalEmails = @PersonalEmails + '@yahoomail.|' 
		set @PersonalEmails = @PersonalEmails + '@ymail.|' 
		set @PersonalEmails = @PersonalEmails + '@icloud.|' 
		set @PersonalEmails = @PersonalEmails + '@mail.|' 
		set @PersonalEmails = @PersonalEmails + '@email.|' 
		set @PersonalEmails = @PersonalEmails + '@fastmail.|' 
		set @PersonalEmails = @PersonalEmails + '@21cmail.|' 
		set @PersonalEmails = @PersonalEmails + '@aussiemail.|' 

		update #src 
		set ContactType = 'Personal Email' 
		where 
			ContactType = 'Work Email' 
			and @PersonalEmails like 
				'%|' + left(right(lower(Contact), (len(Contact) - charindex('@', Contact) + 1)), charindex('.', right(lower(Contact), (len(Contact) - charindex('@', Contact) + 1)))) + '|%' 


		-- find all personal mobiles
		drop index if exists dtc_cli_job.idx_dtc_cli_job_Per_ID_OpenDate_desc_BookingPhNo
		create index idx_dtc_cli_job_Per_ID_OpenDate_desc_BookingPhNo 
			on [db-au-stage]..dtc_cli_job (Per_ID, OpenDate desc) include (BookingPhNo, SendEmail)

		update c 
		set 
			ContactType = 'Personal Mobile'	
		from 
			#src c
			cross apply (
				select top 1 replace(cast(j.BookingPhNo as varchar(max)),' ','') BookingPhNo
				from [db-au-stage]..dtc_cli_job j
				where j.Per_id = right(c.IndividualID, len(c.IndividualID) - 8) 
					and J.SendEmail = -1
				order by openDate desc
			) x
		where 
			c.ContactType = 'Work Mobile'
			and c.Contact = x.BookingPhNo


		-- cleansing 
		delete
		from #src 
		where IsNull(ltrim(rtrim(Contact)),'') = ''

		update #src 
		set Contact = replace(replace(replace(replace(replace(replace(Contact, '(', ''),')',''),' ',''),'-',''),'0011','+'),'+61','0')
		where 
			(ContactType like '%phone%' or ContactType like '%mobile%')
			and (
				Contact like '%(%'
				or Contact like '%)%'
				or Contact like '% %'
				or Contact like '%-%'
				or Contact like '0011%'
				or Contact like '+61%'
			)
	
		update #src 
		set Contact = replace(replace(Contact, char(10),''), char(13),'')

		update #src 
		set Contact = '1300130664'
		where 
			ContactType like '%phone%'
			and Contact like '0_1300%'
	
		--update #src  
		--set 
		--	Contact = left(Contact, charindex('x', Contact) - 1), 
		--	Extension = right(Contact, len(Contact) - charindex('x', Contact))
		--where 
		--	ContactType like '%phone%'
		--	and Contact like '%x%'

		--delete #src 
		--where 
		--	ContactType like '%mobile%'
		--	and len(Contact) > 10

		update #src
		set Contact = replace(Contact, ' ', '') 
		where 
			ContactType not like '%mobile%'
			and ContactType not like '%phone%'
			and Contact like '% %'	
			and len(Contact) - len(replace(Contact, '@', '')) = 1
	
		update #src 
		set Contact = rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(contact, '. ',';'),' or ',';'),' and ',';'),' & ',';'),' - ',';'),'/',';'),' : ',';'),'"',''),'''',''),',',''),' ;',';'),'; ',';')))
		where 
			ContactType not like '%mobile%'
			and ContactType not like '%phone%'
			and Contact like '% %'	
			and len(Contact) - len(replace(Contact, '@', '')) > 1

		update #src 
		set Contact = replace(Contact, ' ', ';')
		where 
			ContactType not like '%mobile%'
			and ContactType not like '%phone%'
			and Contact like '% %'	
			and len(Contact) - len(replace(Contact, '@', '')) > 1
			and len(Contact) - len(replace(Contact, '@', '')) - 1 = len(Contact) - len(replace(Contact, ' ', ''))
	
		update #src
		set Contact = left(Contact, charindex(' ', Contact) - 1)
		where 
			ContactType not like '%mobile%'
			and ContactType not like '%phone%'
			and Contact like '% %'	
			and len(Contact) - len(replace(Contact, '@', '')) > 1 
			and Contact like '%[A-Za-z0-9] [A-Za-z0-9]%'
	
		select DISTINCT ContactType
		from #src

		-- 2. load  
		merge [db-au-dtc].dbo.pnpIndividualContact as tgt
		using #src
			on #src.IndividualID = tgt.IndividualID and #src.ContactType = tgt.ContactType 
		when not matched by target then 
			insert (
				IsCurrent, StartDate, EndDate, IndividualID, ContactType, Contact
			)
			values (
				#src.IsCurrent, #src.StartDate, #src.EndDate, #src.IndividualID, #src.ContactType, #src.Contact
			)
		when matched then 
			update set 
				tgt.IsCurrent = #src.IsCurrent, 
				tgt.StartDate = #src.StartDate, 
				tgt.EndDate = #src.EndDate, 
				tgt.Contact = #src.Contact


		-- update primary ContactType and ContactClass in pnpIndividual 
		;with pc as (
			select 
				c.IndividualID, 
				c.ContactType, 
				ct.ContactClass
			from (
				select 
					IndividualID, 
					ContactType, 
					row_number() over(partition by IndividualID order by case when PrimaryContact = ContactType then 1 else 0 end desc) rn 
				from 
					#src 	
				) c 
				left join (
					SELECT 'Collateral Email' ContactType, 'E-mail address' ContactClass
					UNION ALL SELECT 'Collateral Phone 1' ContactType, 'Phone with Ext.' ContactClass
					UNION ALL SELECT 'Collateral Phone 2' ContactType, 'Phone with Ext.' ContactClass
					UNION ALL SELECT 'Home Phone' ContactType, 'Phone Number' ContactClass
					UNION ALL SELECT 'Personal Email' ContactType, 'E-mail address' ContactClass
					UNION ALL SELECT 'Personal Mobile' ContactType, 'Phone Number' ContactClass
					UNION ALL SELECT 'Website' ContactType, 'URL' ContactClass
					UNION ALL SELECT 'Work Email' ContactType, 'E-mail address' ContactClass
					UNION ALL SELECT 'Work Fax' ContactType, 'Phone Number' ContactClass
					UNION ALL SELECT 'Work Mobile' ContactType, 'Phone Number' ContactClass
					UNION ALL SELECT 'Work Phone' ContactType, 'Phone with Ext.' ContactClass
					--select 
					--	ct.contacttype ContactType,
					--	cc.contactclass ContactClass
					--from 
					--	[db-au-stage]..penelope_sacontacttype_audtc ct 
					--	left join [db-au-stage]..penelope_sscontactclass_audtc cc on cc.kcontactclassid = ct.kcontactclassid
				) ct 
					on c.ContactType = ct.ContactType 
			where 
				c.rn = 1
		)
		update i 
			set 
				ContactType = pc.ContactType, 
				ContactClass = pc.ContactClass 
		from 
			[db-au-dtc]..pnpIndividual i
			join pc on pc.IndividualID = i.IndividualID 



END

GO
