USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmClaimTeam_test]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   procedure [dbo].[etlsp_cmdwh_clmClaimTeam_test]
as
begin

    --begin transaction

    --begin try


		execute
		(
			'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\Claim\ClaimTeam.xlsx" e:\etl\Snowy\CHG0036692\claim_team_test.xlsx'''
		)  at [BHDWH03]

		waitfor delay '00:00:07'

        truncate table [db-au-cmdwh].[dbo].[usrLDAPTeamTest]

        insert into [db-au-cmdwh].[dbo].[usrLDAPTeamTest]
        (
            UserID,
            TeamLeaderID,
			isActive,
			UserName,
			TeamMember,
			Email,
			TLUserName,
			TeamLeader
        )
        select
            r.UserID,
            rtl.UserID,
			t.isActive,
			t.[User Name],
			t.[Team Member],
			t.Email,
			t.[TL User Name],
			t.[Team Leader]
        from
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=\\bhdwh03\etl\Snowy\CHG0036692\claim_team_test.xlsx',
                '
                select
                    *
                from
                    [ClaimTeam$]
                '
            ) t
            outer apply
            (
                select top 1
                    u.UserID
                from
                    [db-au-cmdwh]..usrLDAP u
                where
                    u.UserName = ltrim(rtrim(t.[User Name]))
            ) r
            outer apply
            (
                select top 1
                    u.UserID
                from
                    [db-au-cmdwh]..usrLDAP u
                where
                    u.UserName = ltrim(rtrim(t.[TL User Name]))
            ) rtl
        where
            [ID] is not null

    --end try

    --begin catch

    --    if @@trancount > 0
    --        rollback transaction 

    --end catch

    --if @@trancount > 0
    --    commit transaction 

end


GO
