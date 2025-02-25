USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_EmailMessage]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [atlas].[p_Merge_EmailMessage] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[EmailMessage]';

	MERGE atlas.EmailMessage DST
	USING (
		SELECT 	sem.[Id], 
			sem.[CreatedById], 
			sem.[CreatedDate], 
			sem.[LastModifiedDate], 
			sem.[LastModifiedById], 
			sem.[SystemModstamp], 
			sem.[Headers],
			sem.[HtmlBody], 
			sem.[ParentId], 
			sem.[RedactedInformation_c], 
			sem.[TextBody],

			sem.[IsDeleted], 
			sem.[Currency_ISOCode], 
			sem.[LastReferencedDate], 
			sem.[LastViewedDate], 
			sem.[ActivityId], 
			sem.[BccAddress], 
			sem.[CcAddress], 
			sem.[FirstOpenedDate], 
			sem.[FromAddress], 
			sem.[FromName], 
			sem.[HasAttachment], 
			sem.[Incoming], 
			sem.[IsBounced], 
			sem.[IsClientManaged], 
			sem.[IsExternallyVisible], 
			sem.[IsOpened], 
			sem.[IsPrivateDraft], 
			sem.[IsTracked], 
			sem.[LastOpenedDate], 
			sem.[MessageDate], 
			sem.[MessageIdentifier], 
			sem.[RelatedToId], 
			sem.[ReplyToEmailMessageId], 
			sem.[ShowOnTimeline_c], 
			sem.[Status], 
			sem.[Subject], 
			sem.[ThreadIdentifier], 
			sem.[ToAddress], 
			sem.[ValidatedFromAddress], 
			sem.[EmailTemplateId]
		 FROM [RDSLnk].[STG_RDS].[dbo].[STG_EmailMessage] sem
			INNER JOIN atlas.[Case] c
				ON sem.ParentId = c.Id
		Where sem.[SystemModstamp]> ISNULL(@LastDateTime, '1900-01-01')
		) AS SRC
	ON DST.Id = SRC.Id

	WHEN NOT MATCHED THEN
	INSERT (
		[Id], 
		[CreatedById], 
		[CreatedDate], 
		[LastModifiedDate], 
		[LastModifiedById], 
		[SystemModstamp], 
		[Headers], 
		[HtmlBody], 
		[RedactedInformation_c], 
		[TextBody], 
		[ParentId],

		[IsDeleted], 
		[Currency_ISOCode], 
		[LastReferencedDate], 
		[LastViewedDate], 
		[ActivityId], 
		[BccAddress], 
		[CcAddress], 
		[FirstOpenedDate], 
		[FromAddress], 
		[FromName], 
		[HasAttachment], 
		[Incoming], 
		[IsBounced], 
		[IsClientManaged], 
		[IsExternallyVisible], 
		[IsOpened], 
		[IsPrivateDraft], 
		[IsTracked], 
		[LastOpenedDate], 
		[MessageDate], 
		[MessageIdentifier], 
		[RelatedToId], 
		[ReplyToEmailMessageId], 
		[ShowOnTimeline_c], 
		[Status], 
		[Subject], 
		[ThreadIdentifier], 
		[ToAddress], 
		[ValidatedFromAddress], 
		[EmailTemplateId]
	)
	VALUES (
		SRC.[Id], 
		SRC.[CreatedById], 
		SRC.[CreatedDate], 
		SRC.[LastModifiedDate], 
		SRC.[LastModifiedById], 
		SRC.[SystemModstamp], 
		SRC.[Headers], 
		SRC.[HtmlBody], 
		SRC.[RedactedInformation_c], 
		SRC.[TextBody], 
		SRC.[ParentId],

		SRC.[IsDeleted], 
		SRC.[Currency_ISOCode], 
		SRC.[LastReferencedDate], 
		SRC.[LastViewedDate], 
		SRC.[ActivityId], 
		SRC.[BccAddress], 
		SRC.[CcAddress], 
		SRC.[FirstOpenedDate], 
		SRC.[FromAddress], 
		SRC.[FromName], 
		SRC.[HasAttachment], 
		SRC.[Incoming], 
		SRC.[IsBounced], 
		SRC.[IsClientManaged], 
		SRC.[IsExternallyVisible], 
		SRC.[IsOpened], 
		SRC.[IsPrivateDraft], 
		SRC.[IsTracked], 
		SRC.[LastOpenedDate], 
		SRC.[MessageDate], 
		SRC.[MessageIdentifier], 
		SRC.[RelatedToId], 
		SRC.[ReplyToEmailMessageId], 
		SRC.[ShowOnTimeline_c], 
		SRC.[Status], 
		SRC.[Subject], 
		SRC.[ThreadIdentifier], 
		SRC.[ToAddress], 
		SRC.[ValidatedFromAddress], 
		SRC.[EmailTemplateId]
		)

	WHEN MATCHED AND (
		ISNULL(SRC.[CreatedById], '') <> ISNULL(DST.[CreatedById], '') OR
		ISNULL(SRC.[CreatedDate], '1900-01-01') <> ISNULL(DST.[CreatedDate] , '1900-01-01') OR
		ISNULL(SRC.[LastModifiedDate], '1900-01-01') <> ISNULL(DST.[LastModifiedDate], '1900-01-01') OR
		ISNULL(SRC.[LastModifiedById], '') <> ISNULL(DST.[LastModifiedById], '') OR
		ISNULL(SRC.[SystemModstamp], '1900-01-01') <> ISNULL(DST.[SystemModstamp], '1900-01-01') OR
		ISNULL(SRC.[Headers], '') <> ISNULL(DST.[Headers], '')  OR
		ISNULL(SRC.[HtmlBody], '') <> ISNULL(DST.[HtmlBody], '') OR
		ISNULL(SRC.[RedactedInformation_c], '') <> ISNULL(DST.[RedactedInformation_c], '') OR
		ISNULL(SRC.[TextBody], '') <> ISNULL(DST.[TextBody], '') OR
		ISNULL(SRC.[ParentId], '') <> ISNULL(DST.[ParentId], '') OR

		ISNULL(SRC.[IsDeleted], '0') <> ISNULL(DST.[IsDeleted], '0') OR
		ISNULL(SRC.[Currency_ISOCode], 'NULL') <> ISNULL(DST.[Currency_ISOCode], 'NULL') OR
		ISNULL(SRC.[LastReferencedDate], '1900-01-01') <> ISNULL(DST.[LastReferencedDate], '1900-01-01') OR
		ISNULL(SRC.[LastViewedDate], '1900-01-01') <> ISNULL(DST.[LastViewedDate], '1900-01-01') OR
		ISNULL(SRC.[ActivityId], 'NULL') <> ISNULL(DST.[ActivityId], 'NULL') OR
		ISNULL(SRC.[BccAddress], 'NULL') <> ISNULL(DST.[BccAddress], 'NULL') OR
		ISNULL(SRC.[CcAddress], 'NULL') <> ISNULL(DST.[CcAddress], 'NULL') OR
		ISNULL(SRC.[FirstOpenedDate], '1900-01-01') <> ISNULL(DST.[FirstOpenedDate], '1900-01-01') OR
		ISNULL(SRC.[FromAddress], 'NULL') <> ISNULL(DST.[FromAddress], 'NULL') OR
		ISNULL(SRC.[FromName], 'NULL') <> ISNULL(DST.[FromName], 'NULL') OR
		ISNULL(SRC.[HasAttachment], '0') <> ISNULL(DST.[HasAttachment], '0') OR
		ISNULL(SRC.[Incoming], '0') <> ISNULL(DST.[Incoming], '0') OR
		ISNULL(SRC.[IsBounced], '0') <> ISNULL(DST.[IsBounced], '0') OR
		ISNULL(SRC.[IsClientManaged], '0') <> ISNULL(DST.[IsClientManaged], '0') OR
		ISNULL(SRC.[IsExternallyVisible], '0') <> ISNULL(DST.[IsExternallyVisible], '0') OR
		ISNULL(SRC.[IsOpened], '0') <> ISNULL(DST.[IsOpened], '0') OR
		ISNULL(SRC.[IsPrivateDraft], '0') <> ISNULL(DST.[IsPrivateDraft], '0') OR
		ISNULL(SRC.[IsTracked], '0') <> ISNULL(DST.[IsTracked], '0') OR
		ISNULL(SRC.[LastOpenedDate], '1900-01-01') <> ISNULL(DST.[LastOpenedDate], '1900-01-01') OR
		ISNULL(SRC.[MessageDate], '1900-01-01') <> ISNULL(DST.[MessageDate], '1900-01-01') OR
		ISNULL(SRC.[MessageIdentifier], 'NULL') <> ISNULL(DST.[MessageIdentifier], 'NULL') OR
		ISNULL(SRC.[RelatedToId], 'NULL') <> ISNULL(DST.[RelatedToId], 'NULL') OR
		ISNULL(SRC.[ReplyToEmailMessageId], 'NULL') <> ISNULL(DST.[ReplyToEmailMessageId], 'NULL') OR
		ISNULL(SRC.[ShowOnTimeline_c], '0') <> ISNULL(DST.[ShowOnTimeline_c], '0') OR
		ISNULL(SRC.[Status], 'NULL') <> ISNULL(DST.[Status], 'NULL') OR
		ISNULL(SRC.[Subject], 'NULL') <> ISNULL(DST.[Subject], 'NULL') OR
		ISNULL(SRC.[ThreadIdentifier], 'NULL') <> ISNULL(DST.[ThreadIdentifier], 'NULL') OR
		ISNULL(SRC.[ToAddress], 'NULL') <> ISNULL(DST.[ToAddress], 'NULL') OR
		ISNULL(SRC.[ValidatedFromAddress], 'NULL') <> ISNULL(DST.[ValidatedFromAddress], 'NULL') OR
		ISNULL(SRC.[EmailTemplateId], 'NULL') <> ISNULL(DST.[EmailTemplateId], 'NULL')

		)
	THEN UPDATE
		SET DST.[CreatedById] = SRC.[CreatedById], 
			DST.[CreatedDate] = SRC.[CreatedDate], 
			DST.[LastModifiedDate] = SRC.[LastModifiedDate], 
			DST.[LastModifiedById] = SRC.[LastModifiedById], 
			DST.[SystemModstamp] = SRC.[SystemModstamp], 
			DST.[Headers] = SRC.[Headers], 
			DST.[HtmlBody] = SRC.[HtmlBody], 
			DST.[RedactedInformation_c] = SRC.[RedactedInformation_c], 
			DST.[TextBody] = SRC.[TextBody], 
			DST.[ParentId] = SRC.[ParentId],

			DST.[IsDeleted]= SRC.[IsDeleted],
			DST.[Currency_ISOCode] = SRC.[Currency_ISOCode], 
			DST.[LastReferencedDate] = SRC.[LastReferencedDate],
			DST.[LastViewedDate] = SRC.[LastViewedDate],
			DST.[ActivityId] = SRC.[ActivityId],
			DST.[BccAddress] = SRC.[BccAddress],
			DST.[CcAddress] = SRC.[CcAddress],
			DST.[FirstOpenedDate] = SRC.[FirstOpenedDate],
			DST.[FromAddress] = SRC.[FromAddress],
			DST.[FromName] = SRC.[FromName],
			DST.[HasAttachment] = SRC.[HasAttachment],
			DST.[Incoming] = SRC.[Incoming],
			DST.[IsBounced] = SRC.[IsBounced],
			DST.[IsClientManaged] = SRC.[IsClientManaged],
			DST.[IsExternallyVisible] = SRC.[IsExternallyVisible],
			DST.[IsOpened] = SRC.[IsOpened],
			DST.[IsPrivateDraft] = SRC.[IsPrivateDraft],
			DST.[IsTracked] = SRC.[IsTracked],
			DST.[LastOpenedDate] = SRC.[LastOpenedDate],
			DST.[MessageDate] = SRC.[MessageDate],
			DST.[MessageIdentifier] = SRC.[MessageIdentifier],
			DST.[RelatedToId] = SRC.[RelatedToId],
			DST.[ReplyToEmailMessageId] = SRC.[ReplyToEmailMessageId],
			DST.[ShowOnTimeline_c] = SRC.[ShowOnTimeline_c],
			DST.[Status] = SRC.[Status],
			DST.[Subject] = SRC.[Subject],
			DST.[ThreadIdentifier] = SRC.[ThreadIdentifier],
			DST.[ToAddress] = SRC.[ToAddress],
			DST.[ValidatedFromAddress] = SRC.[ValidatedFromAddress],
			DST.[EmailTemplateId] = SRC.[EmailTemplateId];
END;
GO
