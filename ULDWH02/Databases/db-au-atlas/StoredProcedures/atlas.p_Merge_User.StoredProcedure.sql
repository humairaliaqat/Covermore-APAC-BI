USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_User]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [atlas].[p_Merge_User]
AS
BEGIN 
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[User]';

	MERGE atlas.[User] DST
	USING (
			SELECT 
				[Id], 
				[IsDeleted], 
				[Currency_ISOCode], 
				[CreatedById], 
				[CreatedDate], 
				[LastModifiedDate], 
				[LastModifiedById], 
				[LastReferencedDate], 
				[LastViewedDate], 
				[SystemModstamp], 
				[IsActive], 
				[Alias], 
				[CompanyName], 
				[ContactId], 
				[AccountId], 
				[Department], 
				[Division], 
				[DisableDate], 
				[EnableDate], 
				[SenderEmail], 
				[SenderName], 
				[Extension], 
				[ManagerId], 
				[MobilePhone], 
				[Name], 
				[CommunityNickname], 
				[PasswordResetAttempt], 
				[PasswordResetLockoutDate], 
				[Phone], 
				[PortalRole], 
				[ProfileId], 
				[UserRoleId], 
				[FederationIdentifier], 
				[Title], 
				[Username]
			FROM RDSLnk.STG_RDS.[dbo].[STG_User] stgc
			WHERE stgc.[SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
		) SRC
	ON DST.id = SRC.Id

	WHEN NOT MATCHED THEN
	 INSERT (
		[Id], 
		[IsDeleted], 
		[Currency_ISOCode], 
		[CreatedById], 
		[CreatedDate], 
		[LastModifiedDate], 
		[LastModifiedById], 
		[LastReferencedDate], 
		[LastViewedDate], 
		[SystemModstamp], 
		[IsActive], 
		[Atlas], 
		[CompanyName], 
		[ContactId], 
		[AccountId], 
		[Department], 
		[Division], 
		[DisableDate], 
		[EnableDate], 
		[SenderEmail], 
		[SenderName], 
		[Extension], 
		[ManagerId], 
		[MobilePhone], 
		[Name], 
		[CommunityNickname], 
		[PasswordResetAttempt], 
		[PasswordResetLockoutDate], 
		[Phone], 
		[PortalRole], 
		[ProfileId], 
		[UserRoleId], 
		[FederationIdentifier], 
		[Title], 
		[Username]
		)
		VALUES (
		SRC.[Id], 
		SRC.[IsDeleted], 
		SRC.[Currency_ISOCode], 
		SRC.[CreatedById], 
		SRC.[CreatedDate], 
		SRC.[LastModifiedDate], 
		SRC.[LastModifiedById], 
		SRC.[LastReferencedDate], 
		SRC.[LastViewedDate], 
		SRC.[SystemModstamp], 
		SRC.[IsActive], 
		SRC.[Alias], 
		SRC.[CompanyName], 
		SRC.[ContactId], 
		SRC.[AccountId], 
		SRC.[Department], 
		SRC.[Division], 
		SRC.[DisableDate], 
		SRC.[EnableDate], 
		SRC.[SenderEmail], 
		SRC.[SenderName], 
		SRC.[Extension], 
		SRC.[ManagerId], 
		SRC.[MobilePhone], 
		SRC.[Name], 
		SRC.[CommunityNickname], 
		SRC.[PasswordResetAttempt], 
		SRC.[PasswordResetLockoutDate], 
		SRC.[Phone], 
		SRC.[PortalRole], 
		SRC.[ProfileId], 
		SRC.[UserRoleId], 
		SRC.[FederationIdentifier], 
		SRC.[Title], 
		SRC.[Username]
		)
 
	 WHEN MATCHED AND (
		ISNULL(DST.[IsDeleted], '1') <> ISNULL(SRC.[IsDeleted], '1') OR
		ISNULL(DST.[Currency_ISOCode], 'NULL') <> ISNULL(SRC.[Currency_ISOCode], 'NULL') OR
		ISNULL(DST.[CreatedById], 'NULL') <> ISNULL(SRC.[CreatedById], 'NULL')  OR
		ISNULL(DST.[CreatedDate], '1900-01-01') <> ISNULL(SRC.[CreatedDate], '1900-01-01')  OR
		ISNULL(DST.[LastModifiedDate], '1900-01-01') <> ISNULL(SRC.[LastModifiedDate], '1900-01-01') OR
		ISNULL(DST.[LastModifiedById], 'NULL') <> ISNULL(SRC.[LastModifiedById], 'NULL') OR
		ISNULL(DST.[LastReferencedDate], '1900-01-01') <> ISNULL(SRC.[LastReferencedDate], '1900-01-01') OR
		ISNULL(DST.[LastViewedDate], '1900-01-01') <> ISNULL(SRC.[LastViewedDate], '1900-01-01') OR
		ISNULL(DST.[SystemModstamp], '1900-01-01') <> ISNULL(SRC.[SystemModstamp], '1900-01-01') OR
		ISNULL(DST.[IsActive], '1') <> ISNULL(SRC.[IsActive], '1') OR
		ISNULL(DST.[Atlas], 'NULL') <> ISNULL(SRC.[Alias], 'NULL') OR
		ISNULL(DST.[CompanyName], 'NULL') <> ISNULL(SRC.[CompanyName], 'NULL') OR
		ISNULL(DST.[ContactId], 'NULL') <> ISNULL(SRC.[ContactId], 'NULL') OR
		ISNULL(DST.[AccountId], 'NULL') <> ISNULL(SRC.[AccountId], 'NULL') OR
		ISNULL(DST.[Department], 'NULL') <> ISNULL(SRC.[Department], 'NULL') OR
		ISNULL(DST.[Division], 'NULL') <> ISNULL(SRC.[Division], 'NULL') OR
		ISNULL(DST.[DisableDate], '1900-01-01') <> ISNULL(SRC.[DisableDate], '1900-01-01') OR
		ISNULL(DST.[EnableDate], '1900-01-01') <> ISNULL(SRC.[EnableDate], '1900-01-01') OR
		ISNULL(DST.[SenderEmail], 'NULL') <> ISNULL(SRC.[SenderEmail], 'NULL') OR
		ISNULL(DST.[SenderName], 'NULL') <> ISNULL(SRC.[SenderName], 'NULL') OR
		ISNULL(DST.[Extension], 'NULL') <> ISNULL(SRC.[Extension], 'NULL') OR 
		ISNULL(DST.[ManagerId], 'NULL') <> ISNULL(SRC.[ManagerId], 'NULL') OR  
		ISNULL(DST.[MobilePhone], 'NULL') <> ISNULL(SRC.[MobilePhone], 'NULL') OR 
		ISNULL(DST.[Name], 'NULL') <> ISNULL(SRC.[Name], 'NULL') OR 
		ISNULL(DST.[CommunityNickname], 'NULL') <> ISNULL(SRC.[CommunityNickname], 'NULL') OR 
		ISNULL(DST.[PasswordResetAttempt], 1) <> ISNULL(SRC.[PasswordResetAttempt], 1) OR  
		ISNULL(DST.[PasswordResetLockoutDate], '1900-01-01') <> ISNULL(SRC.[PasswordResetLockoutDate], '1900-01-01') OR
		ISNULL(DST.[Phone], 'NULL') <> ISNULL(SRC.[Phone], 'NULL') OR 
		ISNULL(DST.[PortalRole], 'NULL') <> ISNULL(SRC.[PortalRole], 'NULL') OR 
		ISNULL(DST.[ProfileId], 'NULL') <> ISNULL(SRC.[ProfileId], 'NULL') OR  
		ISNULL(DST.[UserRoleId], 'NULL') <> ISNULL(SRC.[UserRoleId], 'NULL') OR  
		ISNULL(DST.[FederationIdentifier], 'NULL') <> ISNULL(SRC.[FederationIdentifier], 'NULL') OR  
		ISNULL(DST.[Title], 'NULL') <> ISNULL(SRC.[Title], 'NULL') OR  
		ISNULL(DST.[Username], 'NULL') <> ISNULL(SRC.[Username], 'NULL')
	 ) THEN UPDATE
	 SET 
		DST.[Id] = SRC.[Id], 
		DST.[IsDeleted] = SRC.[IsDeleted], 
		DST.[Currency_ISOCode] = SRC.[Currency_ISOCode], 
		DST.[CreatedById] = SRC.[CreatedById], 
		DST.[CreatedDate] = SRC.[CreatedDate], 
		DST.[LastModifiedDate] = SRC.[LastModifiedDate], 
		DST.[LastModifiedById] = SRC.[LastModifiedById], 
		DST.[LastReferencedDate] = SRC.[LastReferencedDate], 
		DST.[LastViewedDate] = SRC.[LastViewedDate], 
		DST.[SystemModstamp] = SRC.[SystemModstamp], 
		DST.[IsActive] = SRC.[IsActive], 
		DST.[Atlas] = SRC.[Alias], 
		DST.[CompanyName] = SRC.[CompanyName], 
		DST.[ContactId] = SRC.[ContactId], 
		DST.[AccountId] = SRC.[AccountId], 
		DST.[Department] = SRC.[Department], 
		DST.[Division] = SRC.[Division], 
		DST.[DisableDate] = SRC.[DisableDate], 
		DST.[EnableDate] = SRC.[EnableDate], 
		DST.[SenderEmail] = SRC.[SenderEmail], 
		DST.[SenderName] = SRC.[SenderName], 
		DST.[Extension] = SRC.[Extension], 
		DST.[ManagerId] = SRC.[ManagerId], 
		DST.[MobilePhone] = SRC.[MobilePhone], 
		DST.[Name] = SRC.[Name], 
		DST.[CommunityNickname] = SRC.[CommunityNickname], 
		DST.[PasswordResetAttempt] = SRC.[PasswordResetAttempt], 
		DST.[PasswordResetLockoutDate] = SRC.[PasswordResetLockoutDate], 
		DST.[Phone] = SRC.[Phone], 
		DST.[PortalRole] = SRC.[PortalRole], 
		DST.[ProfileId] = SRC.[ProfileId], 
		DST.[UserRoleId] = SRC.[UserRoleId], 
		DST.[FederationIdentifier] = SRC.[FederationIdentifier], 
		DST.[Title] = SRC.[Title], 
		DST.[Username] = SRC.[Username];
END;
GO
