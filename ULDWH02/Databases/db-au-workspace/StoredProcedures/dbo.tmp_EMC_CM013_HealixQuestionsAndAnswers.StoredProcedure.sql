USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_EMC_CM013_HealixQuestionsAndAnswers]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[tmp_EMC_CM013_HealixQuestionsAndAnswers]	@ClientID int
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.EMC_CM013_HealixQuestionsAndAnswers
--	Author:			Linus Tor
--	Date Created:	20120119
--	Description:	This stored procedure selects all questions and answers for all conditions as part of
--					of the Healix Assessment as per ClientID parameter.
--	Parameters:		@ClientID: Value is any valid EMC ClientID.
--	
--	Change History:	20120119 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ClientID int
select @ClientID = 10485963
*/

select
	app.ClientID,
	app.AssessedDt as AssessedDate,
	app.AgeApproval,
	ltrim(rtrim(n.Title)) + ' ' + ltrim(rtrim(n.Firstname)) + ' ' + ltrim(rtrim(n.Surname)) as CustomerName,
	m.Condition,
	m.DeniedAccepted as ConditionOutcome,
	mqa.Question,
	mqa.Answer
from
	wills.emc.dbo.tblEMCApplications app
	join wills.emc.dbo.tblEMCNames n on
		app.ClientID = n.ClientID and
		n.ContType = 'C' --client		
	left join wills.emc.dbo.tblMedicalConditionsGroup mcg on
		app.ClientID = mcg.ClientID
	left join wills.emc.dbo.Medical m on
		mcg.[Counter] = m.MedicalConditionsGroupID
	left join wills.emc.dbo.tblMedicalConditionQuestionAnswer mqa on m.[Counter] = mqa.MedicalID
where
	app.ClientID = @ClientID		
GO
