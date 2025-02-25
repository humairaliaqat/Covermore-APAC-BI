USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_ContentVersion]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [atlas].[p_Merge_ContentVersion] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[ContentVersion]';

	MERGE atlas.[ContentVersion] DST
	USING (
		SELECT stgc.[Id], 
				stgc.[IsDeleted], 
				stgc.[Currency_ISOCode], 
				stgc.[CreatedById], 
				stgc.[CreatedDate], 
				stgc.[LastModifiedDate], 
				stgc.[LastModifiedById], 
				stgc.[LastReferencedDate], 
				stgc.[LastViewedDate], 
				stgc.[SystemModstamp], 
				stgc.[Checksum], 
				stgc.[ContentDocumentId], 
				stgc.[ContentLocation], 
				stgc.[ContentModifiedById], 
				stgc.[ContentModifiedDate], 
				stgc.[ContentSize], 
				stgc.[ContentUrl], 
				stgc.[Description], 
				stgc.[FileExtension], 
				stgc.[FileRedaction_Created_By_File_Redactor_c], 
				stgc.[FileType], 
				stgc.[IsLatest], 
				stgc.[IsMajorVersion], 
				stgc.[TagCsv], 
				stgc.[TextPreview], 
				stgc.[Title], 
				stgc.[VersionData], 
				stgc.[VersionNumber]
		FROM RDSLnk.STG_RDS.[dbo].[STG_ContentVersion] stgc
			INNER JOIN atlas.[ContentDocument] c
				ON stgc.ContentDocumentId = c.Id
			WHERE stgc.[SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
		) SRC
	ON DST.Id = SRC.Id

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
			[Checksum], 
			[ContentDocumentId], 
			[ContentLocation], 
			[ContentModifiedById], 
			[ContentModifiedDate], 
			[ContentSize], 
			[ContentUrl], 
			[Description], 
			[FileExtension], 
			[FileRedaction_Created_By_File_Redactor_c], 
			[FileType], 
			[IsLatest], 
			[IsMajorVersion], 
			[TagCsv], 
			[TextPreview], 
			[Title], 
			[VersionData], 
			[VersionNumber])
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
			SRC.[Checksum], 
			SRC.[ContentDocumentId], 
			SRC.[ContentLocation], 
			SRC.[ContentModifiedById], 
			SRC.[ContentModifiedDate], 
			SRC.[ContentSize], 
			SRC.[ContentUrl], 
			SRC.[Description], 
			SRC.[FileExtension], 
			SRC.[FileRedaction_Created_By_File_Redactor_c], 
			SRC.[FileType], 
			SRC.[IsLatest], 
			SRC.[IsMajorVersion], 
			SRC.[TagCsv], 
			SRC.[TextPreview], 
			SRC.[Title], 
			SRC.[VersionData], 
			SRC.[VersionNumber])
	WHEN MATCHED AND (
		ISNULL(	SRC.[IsDeleted] 	, '1')	<>	ISNULL(	DST.[IsDeleted] 	, '1')	OR
		ISNULL(	SRC.[Currency_ISOCode] 	,'NULL')	<>	ISNULL(	DST.[Currency_ISOCode] 	,'NULL')	OR
		ISNULL(	SRC.[CreatedById] 	,'NULL')	<>	ISNULL(	DST.[CreatedById] 	,'NULL')	OR
		ISNULL(	SRC.[CreatedDate] 	,'1900-01-01')	<>	ISNULL(	DST.[CreatedDate] 	,'1900-01-01')	OR
		ISNULL(	SRC.[LastModifiedDate] 	,'1900-01-01')	<>	ISNULL(	DST.[LastModifiedDate] 	,'1900-01-01')	OR
		ISNULL(	SRC.[LastModifiedById] 	,'NULL')	<>	ISNULL(	DST.[LastModifiedById] 	,'NULL')	OR
		ISNULL(	SRC.[LastReferencedDate] 	,'1900-01-01')	<>	ISNULL(	DST.[LastReferencedDate] 	,'1900-01-01')	OR
		ISNULL(	SRC.[LastViewedDate] 	,'1900-01-01')	<>	ISNULL(	DST.[LastViewedDate] 	,'1900-01-01')	OR
		ISNULL(	SRC.[SystemModstamp] 	,'1900-01-01')	<>	ISNULL(	DST.[SystemModstamp] 	,'1900-01-01')	OR
		ISNULL(	SRC.[Checksum] 	,'NULL')	<>	ISNULL(	DST.[Checksum] 	,'NULL')	OR
		ISNULL(	SRC.[ContentDocumentId] 	,'NULL')	<>	ISNULL(	DST.[ContentDocumentId] 	,'NULL')	OR
		ISNULL(	SRC.[ContentLocation] 	,'NULL')	<>	ISNULL(	DST.[ContentLocation] 	,'NULL')	OR
		ISNULL(	SRC.[ContentModifiedById] 	,'NULL')	<>	ISNULL(	DST.[ContentModifiedById] 	,'NULL')	OR
		ISNULL(	SRC.[ContentModifiedDate] 	,'1900-01-01')	<>	ISNULL(	DST.[ContentModifiedDate] 	,'1900-01-01')	OR
		ISNULL(	SRC.[ContentSize] 	,0)	<>	ISNULL(	DST.[ContentSize] 	,0)	OR
		ISNULL(	SRC.[ContentUrl] 	,'NULL')	<>	ISNULL(	DST.[ContentUrl] 	,'NULL')	OR
		ISNULL(	SRC.[Description] 	,'NULL')	<>	ISNULL(	DST.[Description] 	,'NULL')	OR
		ISNULL(	SRC.[FileExtension] 	,'NULL')	<>	ISNULL(	DST.[FileExtension] 	,'NULL')	OR
		ISNULL(	SRC.[FileRedaction_Created_By_File_Redactor_c] 	,'NULL')	<>	ISNULL(	DST.[FileRedaction_Created_By_File_Redactor_c] 	,'NULL')	OR
		ISNULL(	SRC.[FileType] 	,'NULL')	<>	ISNULL(	DST.[FileType] 	,'NULL')	OR
		ISNULL(	SRC.[IsLatest] 	,'1')	<>	ISNULL(	DST.[IsLatest] 	,'1')	OR
		ISNULL(	SRC.[IsMajorVersion] 	,'1')	<>	ISNULL(	DST.[IsMajorVersion] 	,'1')	OR
		ISNULL(	SRC.[TagCsv] 	,'NULL')	<>	ISNULL(	DST.[TagCsv] 	,'NULL')	OR
		ISNULL(	SRC.[TextPreview] 	,'NULL')	<>	ISNULL(	DST.[TextPreview] 	,'NULL')	OR
		ISNULL(	SRC.[Title] 	,'NULL')	<>	ISNULL(	DST.[Title] 	,'NULL')	OR
		ISNULL(	SRC.[VersionData] 	,'NULL')	<>	ISNULL(	DST.[VersionData] 	,'NULL')	OR
		ISNULL(	SRC.[VersionNumber]	,'NULL')	<>	ISNULL(	DST.[VersionNumber]	,'NULL'))
	THEN UPDATE
		SET DST.[IsDeleted] 	=	SRC.[IsDeleted] 	,
			DST.[Currency_ISOCode] 	=	SRC.[Currency_ISOCode] 	,
			DST.[CreatedById] 	=	SRC.[CreatedById] 	,
			DST.[CreatedDate] 	=	SRC.[CreatedDate] 	,
			DST.[LastModifiedDate] 	=	SRC.[LastModifiedDate] 	,
			DST.[LastModifiedById] 	=	SRC.[LastModifiedById] 	,
			DST.[LastReferencedDate] 	=	SRC.[LastReferencedDate] 	,
			DST.[LastViewedDate] 	=	SRC.[LastViewedDate] 	,
			DST.[SystemModstamp] 	=	SRC.[SystemModstamp] 	,
			DST.[Checksum] 	=	SRC.[Checksum] 	,
			DST.[ContentDocumentId] 	=	SRC.[ContentDocumentId] 	,
			DST.[ContentLocation] 	=	SRC.[ContentLocation] 	,
			DST.[ContentModifiedById] 	=	SRC.[ContentModifiedById] 	,
			DST.[ContentModifiedDate] 	=	SRC.[ContentModifiedDate] 	,
			DST.[ContentSize] 	=	SRC.[ContentSize] 	,
			DST.[ContentUrl] 	=	SRC.[ContentUrl] 	,
			DST.[Description] 	=	SRC.[Description] 	,
			DST.[FileExtension] 	=	SRC.[FileExtension] 	,
			DST.[FileRedaction_Created_By_File_Redactor_c] 	=	SRC.[FileRedaction_Created_By_File_Redactor_c] 	,
			DST.[FileType] 	=	SRC.[FileType] 	,
			DST.[IsLatest] 	=	SRC.[IsLatest] 	,
			DST.[IsMajorVersion] 	=	SRC.[IsMajorVersion] 	,
			DST.[TagCsv] 	=	SRC.[TagCsv] 	,
			DST.[TextPreview] 	=	SRC.[TextPreview] 	,
			DST.[Title] 	=	SRC.[Title] 	,
			DST.[VersionData] 	=	SRC.[VersionData] 	,
			DST.[VersionNumber]	=	SRC.[VersionNumber];
END;
GO
