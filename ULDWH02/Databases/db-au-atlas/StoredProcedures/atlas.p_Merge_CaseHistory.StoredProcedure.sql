USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_CaseHistory]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [atlas].[p_Merge_CaseHistory]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[CaseHistory]';

	MERGE atlas.CaseHistory DST
	USING (
		SELECT 
			Id, 
			IsDeleted, 
			CreatedById, 
			CreatedDate, 
			CaseId, 
			Field, 
			NewValue, 
			OldValue
		FROM RDSLnk.STG_RDS.dbo.[STG_CaseHistory] s
		WHERE EXISTS (
					SELECT 1
					FROM atlas.[User] u
					WHERE s.CreatedById = u.Id
					)
			AND s.CreatedDate > ISNULL(@LastDateTime, '1900-01-01')
		) SRC
	ON DST.Id = SRC.Id

	WHEN NOT MATCHED THEN
	INSERT (
		Id, 
		IsDeleted, 
		CreatedById, 
		CreatedDate, 
		CaseId, 
		Field, 
		NewValue, 
		OldValue
		)
	VALUES (
		SRC.Id, 
		SRC.IsDeleted, 
		SRC.CreatedById, 
		SRC.CreatedDate, 
		SRC.CaseId, 
		SRC.Field, 
		SRC.NewValue, 
		SRC.OldValue
	)

	WHEN MATCHED AND (
		ISNULL(DST.IsDeleted, '0') <>  ISNULL(SRC.IsDeleted, '0') OR
		ISNULL(DST.CreatedById, '') <> ISNULL(SRC.CreatedById, '') OR
		ISNULL(DST.CreatedDate, '1900-01-01') <> ISNULL(SRC.CreatedDate, '1900-01-01') OR
		ISNULL(DST.CaseId, '') <> ISNULL(SRC.CaseId, '') OR 
		ISNULL(DST.Field, '') <> ISNULL(SRC.Field, '') OR
		ISNULL(DST.NewValue, '') <> ISNULL(SRC.NewValue, '') OR
		ISNULL(DST.OldValue, '') <> ISNULL(SRC.OldValue, '')
		) THEN 
	UPDATE SET 
		DST.IsDeleted = SRC.IsDeleted, 
		DST.CreatedById = SRC.CreatedById, 
		DST.CreatedDate = SRC.CreatedDate, 
		DST.CaseId = SRC.CaseId, 
		DST.Field = SRC.Field, 
		DST.NewValue = SRC.NewValue, 
		DST.OldValue = SRC.OldValue;
END
GO
