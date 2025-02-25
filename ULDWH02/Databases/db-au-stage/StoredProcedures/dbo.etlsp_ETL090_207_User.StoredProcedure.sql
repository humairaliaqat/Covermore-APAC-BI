USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_207_User]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- Modifications: 
--	20180226 - Brought in ResourceType from Star Projects
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_207_User] 
AS
BEGIN

	SET NOCOUNT ON;

	-- paresrce => User

	/*
	stage tables:
		[db-au-stage]..dtc_cli_PaResrce 
		[db-au-stage]..dtc_cli_PaResCls 
		[db-au-stage]..dtc_cli_PaStaff 
		[db-au-stage]..dtc_cli_Worker 
		[db-au-stage]..dtc_cli_Worker_Lookup 

	pnpUser:
		UserSK
		IsCurrent							1
		StartDate							'1900-01-01'	
		EndDate								'9999-12-31'
		BookItemSK
		ReportToUserSK						[final step update]
		UserID								'CLI_USR_' + resource_code
		ReportToUserID						'CLI_USR_' + manager_staff_code
		WorkerID							'CLI_USR_' + resource_code
		FirstName							resource_desc *
		LastName							resource_desc *
		Title								
		Extention
		Phone1
		Phone2
		Email								email_addr
		UserGroup							
		UserGroupLevel						
		LoginName							
		Password
		AddressLine1
		AddressLine2
		AddressCity
		State
		StateShort
		Country
		CountryShort
		Language1
		Language2
		Language3
		AddressPostcode
		Status
		Notes
		RegistrationNumber
		FullTimeEquivalent
		MaxCaseLoad
		MaxIndividualLoad
		CreatedDatetime
		UpdatedDatetime
		CreatedBy
		UpdatedBy
		userfahcsiano
		Qualification
		WorkerAccept
		WorkerCreatedDatetime
		WorkerUpdatedDatetime
		SocialSecurityNumber
		EmployerIdentificationNumber
		NationalProviderID
		ProviderSpecialtyTaxonomyCode
		DVQualified
		WorkerIDRendering
		krenderingproviderid
		kreferringphysicianid
		kbluebookidrefphys
		MedicarePI
		ClienteleResourceCode 				resource_code
	*/

	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 
	select * into #src 
	from (
		select 
			1 IsCurrent,
			'1900-01-01' StartDate,
			'9999-12-31' EndDate,
			coalesce(convert(varchar, wl.kuserid), 'CLI_USR_' + r.resource_code) UserID,
			coalesce(convert(varchar, ml.kuserid), 'CLI_USR_' + r.manager_staff_code) ReportToUserID,
			'CLI_USR_' + r.resource_code WorkerID,
			case 
				when r.department_code <> 'ASS' then left(r.resource_desc, charindex(' ', r.resource_desc)) 
				else r.resource_desc 
			end FirstName,
			case 
				when r.department_code <> 'ASS' 
					then substring(r.resource_desc, charindex(' ', r.resource_desc) + 1, len(r.resource_desc) - (charindex(' ', r.resource_desc) - 1)) 
				else 'ASSOCIATE' 
			end LastName,
			s.email_addr Email,
			'English' Language1,
			'1' Status,
			r.resource_code ClienteleResourceCode,
			r.section_code SectionCode,
			CASE r.department_code
				WHEN 'CASB' THEN 'Casual'
				WHEN 'ASS' THEN 'Associate'
				WHEN 'SES' THEN 'Contractor'
				WHEN 'GEN' THEN 'Internal'
				WHEN 'STAFF' THEN 'Staff'
				WHEN 'CASC' THEN 'Casual'
			END as Department_code
		from 
			[db-au-stage].dbo.dtc_cli_PaResrce r 
			left join [db-au-stage].dbo.dtc_cli_PaResCls rc on rc.resource_class_code = r.resource_class_code 
			left join [db-au-stage].dbo.dtc_cli_PaStaff s on s.resource_code = r.resource_code
			left join [db-au-stage].dbo.dtc_cli_Worker w on w.userdefinedtext1 = r.resource_code 
			left join [db-au-stage].dbo.dtc_cli_Worker_Lookup wl on wl.uniqueworkerid = w.uniqueworkerid 
			left join [db-au-stage].dbo.dtc_cli_Worker m on m.userdefinedtext1 = r.manager_staff_code 
			left join [db-au-stage].dbo.dtc_cli_Worker_Lookup ml on ml.uniqueworkerid = m.uniqueworkerid 
	) a 
	
	-- 2. load
	merge [db-au-dtc]..pnpUser as tgt
	using #src
		on #src.UserID = tgt.UserID and tgt.IsCurrent = 1 
	when not matched by target then 
		insert (
			IsCurrent,
			StartDate,
			EndDate,
			UserID,
			ReportToUserID,
			WorkerID,
			FirstName,
			LastName,
			Email,
			Language1,
			Status,
			ClienteleResourceCode,
			SectionCode,
			ResourceType
		)
		values (
			#src.IsCurrent,
			#src.StartDate,
			#src.EndDate,
			#src.UserID,
			#src.ReportToUserID,
			#src.WorkerID,
			#src.FirstName,
			#src.LastName,
			#src.Email,
			#src.Language1,
			#src.Status,
			#src.ClienteleResourceCode,
			#src.SectionCode,
			#src.Department_code
		)
	when matched then update set 
		tgt.ReportToUserID = #src.ReportToUserID,
		tgt.WorkerID = #src.WorkerID,
		tgt.FirstName = coalesce(tgt.FirstName, #src.FirstName),
		tgt.LastName = coalesce(tgt.LastName, #src.LastName),
		tgt.Email = coalesce(tgt.Email, #src.Email),
		tgt.Language1 = coalesce(tgt.Language1, #src.Language1),
		tgt.Status = coalesce(tgt.Status, #src.Status),
		tgt.ClienteleResourceCode = coalesce(tgt.ClienteleResourceCode, #src.ClienteleResourceCode),
		tgt.SectionCode = coalesce(tgt.SectionCode, #src.SectionCode),
		tgt.ResourceType = coalesce(tgt.ResourceType, #src.Department_code)
	;

END

GO
