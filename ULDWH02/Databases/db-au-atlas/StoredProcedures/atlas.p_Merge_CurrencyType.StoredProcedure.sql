USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[p_Merge_CurrencyType]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [atlas].[p_Merge_CurrencyType]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LastDateTime DATETIME

	SELECT @LastDateTime = LastDateTime FROM atlas.JobConfig WHERE EntityName = 'atlas.[CurrencyType]';

	MERGE atlas.[CurrencyType] DST
	USING ( 
			SELECT
				[Id], 
				[IsDeleted], 
				[CreatedById], 
				[CreatedDate], 
				[LastModifiedDate], 
				[LastModifiedById], 
				[LastReferencedDate], 
				[LastViewedDate], 
				[SystemModstamp], 
				[IsActive], 
				[IsCorporate], 
				[IsoCode], 
				[ConversionRate], 
				[DecimalPlaces]
			FROM RDSLnk.STG_RDS.[dbo].[STG_CurrencyType]
			WHERE [SystemModstamp] > ISNULL(@LastDateTime, '1900-01-01')
		) SRC
	ON DST.Id = SRC.Id

	WHEN NOT MATCHED THEN
	INSERT (
		[Id], 
		[IsDeleted], 
		[CreatedById], 
		[CreatedDate], 
		[LastModifiedDate], 
		[LastModifiedById], 
		[LastReferencedDate], 
		[LastViewedDate], 
		[SystemModstamp], 
		[IsActive], 
		[IsCorporate], 
		[IsoCode], 
		[ConversionRate], 
		[DecimalPlaces]
	)
	VALUES (
		SRC.[Id], 
		SRC.[IsDeleted], 
		SRC.[CreatedById], 
		SRC.[CreatedDate], 
		SRC.[LastModifiedDate], 
		SRC.[LastModifiedById], 
		SRC.[LastReferencedDate], 
		SRC.[LastViewedDate], 
		SRC.[SystemModstamp], 
		SRC.[IsActive], 
		SRC.[IsCorporate], 
		SRC.[IsoCode], 
		SRC.[ConversionRate], 
		SRC.[DecimalPlaces]
	)

	WHEN MATCHED AND (
		ISNULL(DST.[IsDeleted], '1') <>  ISNULL(SRC.[IsDeleted], '1') OR
		ISNULL(DST.[CreatedById], 'NULL') <>  ISNULL(SRC.[CreatedById], 'NULL') OR
		ISNULL(DST.[CreatedDate], '1900-01-01') <>  ISNULL(SRC.[CreatedDate], '1900-01-01') OR
		ISNULL(DST.[LastModifiedDate], '1900-01-01') <>  ISNULL(SRC.[LastModifiedDate], '1900-01-01') OR
		ISNULL(DST.[LastModifiedById], 'NULL') <>  ISNULL(SRC.[LastModifiedById], 'NULL') OR
		ISNULL(DST.[LastReferencedDate], '1900-01-01') <>  ISNULL(SRC.[LastReferencedDate], '1900-01-01') OR
		ISNULL(DST.[LastViewedDate], '1900-01-01') <>  ISNULL(SRC.[LastViewedDate], '1900-01-01') OR
		ISNULL(DST.[SystemModstamp], '1900-01-01') <>  ISNULL(SRC.[SystemModstamp], '1900-01-01') OR
		ISNULL(DST.[IsActive], '1') <>  ISNULL(SRC.[IsActive], '1') OR
		ISNULL(DST.[IsCorporate], '1') <>  ISNULL(SRC.[IsCorporate], '1') OR
		ISNULL(DST.[IsoCode], 'NULL') <>  ISNULL(SRC.[IsoCode], 'NULL') OR
		ISNULL(DST.[ConversionRate], '1') <>  ISNULL(SRC.[ConversionRate], '1') OR
		ISNULL(DST.[DecimalPlaces], '1') <>  ISNULL(SRC.[DecimalPlaces], '1')
	) THEN 
	UPDATE SET
		DST.[IsDeleted] = SRC.[IsDeleted],
		DST.[CreatedById] = SRC.[CreatedById], 
		DST.[CreatedDate] = SRC.[CreatedDate], 
		DST.[LastModifiedDate] = SRC.[LastModifiedDate], 
		DST.[LastModifiedById] = SRC.[LastModifiedById], 
		DST.[LastReferencedDate] = SRC.[LastReferencedDate], 
		DST.[LastViewedDate] = SRC.[LastViewedDate], 
		DST.[SystemModstamp] = SRC.[SystemModstamp], 
		DST.[IsActive] = SRC.[IsActive], 
		DST.[IsCorporate] = SRC.[IsCorporate], 
		DST.[IsoCode] = SRC.[IsoCode], 
		DST.[ConversionRate] = SRC.[ConversionRate], 
		DST.[DecimalPlaces] = SRC.[DecimalPlaces];
END;
GO
