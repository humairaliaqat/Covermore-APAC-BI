USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_ContentDocumentLink]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [atlas].[p_Merge_ContentDocumentLink]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[ContentDocumentLink]';

	MERGE atlas.ContentDocumentLink DST
	USING (
		SELECT	stgc.[Id], 
				stgc.[IsDeleted], 
				stgc.[Currency_ISOCode], 
				stgc.[CreatedById], 
				stgc.[CreatedDate], 
				stgc.[LastModifiedDate], 
				stgc.[LastModifiedById], 
				stgc.[LastReferencedDate], 
				stgc.[LastViewedDate], 
				stgc.[SystemModstamp], 
				stgc.[ContentDocumentId], 
				stgc.[LinkedEntityId], 
				stgc.[ShareType], 
				stgc.[Visibility]
		FROM RDSLnk.STG_RDS.[dbo].[STG_ContentDocumentLink] stgc
		WHERE stgc.[SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
			AND EXISTS (SELECT 1 FROM atlas.ContentDocument cd WHERE stgc.ContentDocumentId = cd.Id)
			AND 
			(
			 EXISTS (SELECT 1 FROM atlas.Document cd WHERE stgc.LinkedEntityId = cd.Id) OR
			 EXISTS (SELECT 1 FROM atlas.[Case] cd WHERE stgc.LinkedEntityId = cd.Id) OR
			 EXISTS (SELECT 1 FROM atlas.[CaseProvider] cd WHERE stgc.LinkedEntityId = cd.Id) OR
			 EXISTS (SELECT 1 FROM atlas.EstimateHeader cd WHERE stgc.LinkedEntityId = cd.Id) OR
			 EXISTS (SELECT 1 FROM atlas.Invoice cd WHERE stgc.LinkedEntityId = cd.Id) OR
			 EXISTS (SELECT 1 FROM atlas.Itinerary cd WHERE stgc.LinkedEntityId = cd.Id)
			)
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
			[ContentDocumentId], 
			[LinkedEntityId], 
			[ShareType], 
			[Visibility]
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
			SRC.[ContentDocumentId], 
			SRC.[LinkedEntityId], 
			SRC.[ShareType], 
			SRC.[Visibility]
		)
	WHEN MATCHED AND (
			ISNULL(SRC.[IsDeleted], '1') <> ISNULL(DST.[IsDeleted], '1') OR
			ISNULL(SRC.[Currency_ISOCode], 'NULL') <> ISNULL(DST.[Currency_ISOCode], 'NULL') OR
			ISNULL(SRC.[CreatedById], 'NULL') <> ISNULL(DST.[CreatedById], 'NULL') OR
			ISNULL(SRC.[CreatedDate], '1900-01-01') <> ISNULL(DST.[CreatedDate], '1900-01-01') OR
			ISNULL(SRC.[LastModifiedDate] , '1900-01-01') <> ISNULL(DST.[LastModifiedDate] , '1900-01-01') OR
			ISNULL(SRC.[LastModifiedById], 'NULL') <> ISNULL(DST.[LastModifiedById], 'NULL') OR
			ISNULL(SRC.[LastReferencedDate], '1900-01-01') <> ISNULL(DST.[LastReferencedDate], '1900-01-01') OR
			ISNULL(SRC.[LastViewedDate] , '1900-01-01') <> ISNULL(DST.[LastViewedDate] , '1900-01-01') OR
			ISNULL(SRC.[SystemModstamp], '1900-01-01') <> ISNULL(DST.[SystemModstamp], '1900-01-01') OR
			ISNULL(SRC.[ContentDocumentId], 'NULL') <> ISNULL(DST.[ContentDocumentId], 'NULL') OR
			ISNULL(SRC.[LinkedEntityId], 'NULL') <> ISNULL(DST.[LinkedEntityId], 'NULL') OR
			ISNULL(SRC.[ShareType] , 'NULL') <> ISNULL(DST.[ShareType] , 'NULL') OR
			ISNULL(SRC.[Visibility], 'NULL') <> ISNULL(DST.[Visibility], 'NULL')
		)
	THEN UPDATE
		SET DST.[IsDeleted] = SRC.[IsDeleted],
			DST.[Currency_ISOCode] = SRC.[Currency_ISOCode],
			DST.[CreatedById] = SRC.[CreatedById],
			DST.[CreatedDate] = SRC.[CreatedDate],
			DST.[LastModifiedDate] = SRC.[LastModifiedDate],
			DST.[LastModifiedById] = SRC.[LastModifiedById],
			DST.[LastReferencedDate]= SRC.[LastReferencedDate],
			DST.[LastViewedDate]= SRC.[LastViewedDate],
			DST.[SystemModstamp] = SRC.[SystemModstamp],
			DST.[ContentDocumentId]= SRC.[ContentDocumentId],
			DST.[LinkedEntityId]= SRC.[LinkedEntityId],
			DST.[ShareType] = SRC.[ShareType],
			DST.[Visibility] = SRC.[Visibility];
END;
GO
