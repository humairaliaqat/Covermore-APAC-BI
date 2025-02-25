USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_ContentDocument]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [atlas].[p_Merge_ContentDocument] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[ContentDocument]';

	MERGE atlas.ContentDocument DST
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
			[ArchivedById], 
			[ArchivedDate], 
			[ContentModifiedDate], 
			[ContentSize], 
			[Description], 
			[FileExtension], 
			[FileType], 
			[LatestPublishedVersionId], 
			[Title]
		FROM RDSLnk.STG_RDS.[dbo].[STG_ContentDocument]
		WHERE [SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
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
			[ArchivedById], 
			[ArchivedDate], 
			[ContentModifiedDate], 
			[ContentSize], 
			[Description], 
			[FileExtension], 
			[FileType], 
			[LatestPublishedVersionId], 
			[Title]
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
			SRC.[ArchivedById], 
			SRC.[ArchivedDate], 
			SRC.[ContentModifiedDate], 
			SRC.[ContentSize], 
			SRC.[Description], 
			SRC.[FileExtension], 
			SRC.[FileType], 
			SRC.[LatestPublishedVersionId], 
			SRC.[Title]
		)
	WHEN MATCHED AND (
		ISNULL(DST.[IsDeleted], '1') <> ISNULL(SRC.[IsDeleted], '1') OR
		ISNULL(DST.[Currency_ISOCode], 'NULL') <> ISNULL(SRC.[Currency_ISOCode], 'NULL') OR 
		ISNULL(DST.[CreatedById], 'NULL') <> ISNULL(SRC.[CreatedById], 'NULL') OR 
		ISNULL(DST.[CreatedDate], '1900-01-01') <> ISNULL(SRC.[CreatedDate], '1900-01-01') OR  
		ISNULL(DST.[LastModifiedDate], '1900-01-01') <> ISNULL(SRC.[LastModifiedDate], '1900-01-01') OR   
		ISNULL(DST.[LastModifiedById], 'NULL') <> ISNULL(SRC.[LastModifiedById], 'NULL') OR  
		ISNULL(DST.[LastReferencedDate], '1900-01-01') <> ISNULL(SRC.[LastReferencedDate], '1900-01-01') OR    
		ISNULL(DST.[LastViewedDate], '1900-01-01') <> ISNULL(SRC.[LastViewedDate], '1900-01-01') OR    
		ISNULL(DST.[SystemModstamp], '1900-01-01') <> ISNULL(SRC.[SystemModstamp], '1900-01-01') OR    
		ISNULL(DST.[ArchivedById], 'NULL') <> ISNULL(SRC.[ArchivedById], 'NULL') OR   
		ISNULL(DST.[ArchivedDate], '1900-01-01') <> ISNULL(SRC.[ArchivedDate], '1900-01-01') OR     
		ISNULL(DST.[ContentModifiedDate], '1900-01-01') <> ISNULL(SRC.[ContentModifiedDate], '1900-01-01') OR     
		ISNULL(DST.[ContentSize], 0) <> ISNULL(SRC.[ContentSize], 0) OR
		ISNULL(DST.[Description], 'NULL') <> ISNULL(SRC.[Description], 'NULL') OR    
		ISNULL(DST.[FileExtension], 'NULL') <> ISNULL(SRC.[FileExtension], 'NULL') OR    
		ISNULL(DST.[FileType], 'NULL') <> ISNULL(SRC.[FileType], 'NULL') OR    
		ISNULL(DST.[LatestPublishedVersionId], 'NULL') <> ISNULL(SRC.[LatestPublishedVersionId], 'NULL') OR    
		ISNULL(DST.[Title], 'NULL') <> ISNULL(SRC.[Title], 'NULL') 
		) 
		THEN UPDATE SET
			DST.[IsDeleted] = SRC.[IsDeleted],
			DST.[Currency_ISOCode] = SRC.[Currency_ISOCode],
			DST.[CreatedById] = SRC.[CreatedById],
			DST.[CreatedDate] = SRC.[CreatedDate],
			DST.[LastModifiedDate]= SRC.[LastModifiedDate],
			DST.[LastModifiedById] = SRC.[LastModifiedById],
			DST.[LastReferencedDate] = SRC.[LastReferencedDate],
			DST.[LastViewedDate] = SRC.[LastViewedDate],
			DST.[SystemModstamp]= SRC.[SystemModstamp],
			DST.[ArchivedById] = SRC.[ArchivedById],
			DST.[ArchivedDate] = SRC.[ArchivedDate],
			DST.[ContentModifiedDate] = SRC.[ContentModifiedDate],
			DST.[ContentSize]= SRC.[ContentSize],
			DST.[Description] = SRC.[Description],
			DST.[FileExtension] = SRC.[FileExtension],
			DST.[FileType] = SRC.[FileType],
			DST.[LatestPublishedVersionId] = SRC.[LatestPublishedVersionId],
			DST.[Title] = SRC.[Title];
END;
GO
