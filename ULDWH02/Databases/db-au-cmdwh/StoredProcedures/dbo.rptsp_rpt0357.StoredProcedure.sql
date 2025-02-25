USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0357]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0357]	@ClientID int
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0357
--	Author:			Linus Tor
--	Date Created:	20120119
--	Description:	This stored procedure selects all questions and answers for all conditions as part of
--					of the Healix Assessment as per ClientID parameter.
--					Based on EMC.dbo.EMC_CM013_HealixQuestionsAndAnswers
--	Parameters:		@ClientID: Value is any valid EMC ClientID.
--	
--	Change History:	20120917 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ClientID int
select @ClientID = 10485963
*/

select
    m.MedicalID,
	app.ApplicationID as ClientID,
	m.Condition,
	mq.Question,
	mq.Answer,
	app.AgeApprovalStatus as AgeApproval,
	app.AssessedDate
from
	emcApplications app
	join emcApplicants n on
		app.ApplicationKey = n.ApplicationKey		
	left join emcMedical m on
		app.ApplicationKey = m.ApplicationKey
	left join emcMedicalQuestions mq on m.MedicalKey = mq.MedicalKey
where
	app.ApplicationID = @ClientID
order by
    m.MedicalID
GO
