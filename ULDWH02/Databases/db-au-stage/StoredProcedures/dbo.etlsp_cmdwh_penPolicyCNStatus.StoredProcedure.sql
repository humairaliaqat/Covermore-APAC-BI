USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyCNStatus]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[etlsp_cmdwh_penPolicyCNStatus]
AS
BEGIN
 
  set nocount on

  /* staging index */
  exec etlsp_StagingIndex_Penguin

  /*************************************Start of tblPolicyCredtiNote*************************************/
  IF OBJECT_ID('etl_penPolicyCNStatus') IS NOT NULL
    DROP TABLE etl_penPolicyCNStatus

  SELECT
    CountryKey,
    CompanyKey,
    DomainKey,
	a.CNStatusID,
	a.CNStatus

  INTO etl_penPolicyCNStatus
  FROM [db-au-stage].[dbo].[penguin_tblPolicyCNStatus_aucm] a
  CROSS APPLY dbo.fn_GetDomainKeys(a.CNStatusID, 'CM', 'AU') dk


  
  IF OBJECT_ID('[db-au-cmdwh].[dbo].[penPolicyCNStatus]') IS NULL
  BEGIN

    CREATE TABLE [db-au-cmdwh].[dbo].[penPolicyCNStatus] (
        [CountryKey] [varchar](2) NOT NULL,
	    [CompanyKey] [varchar](5) NOT NULL,
	    [DomainKey] [varchar](41) NOT NULL,
	    [CNStatusID] [int] NOT NULL,
		[CNStatus] varchar (200)	  
    )

    CREATE CLUSTERED INDEX idx_penPolicyCNStatus_StatusId ON [db-au-cmdwh].dbo.penPolicyCNStatus (CNStatusID)

  END
  ELSE
  BEGIN

    DELETE a
      FROM [db-au-cmdwh].dbo.penPolicyCNStatus a
      INNER JOIN etl_penPolicyCNStatus b
        ON a.CNStatusID = b.CNStatusID

  END

  INSERT [db-au-cmdwh].dbo.penPolicyCNStatus WITH (TABLOCKX) 
		(
		[CountryKey],
	    [CompanyKey],
	    [DomainKey],
	    [CNStatusID],
		[CNStatus]
		)
    SELECT
        [CountryKey],
	    [CompanyKey],
	    [DomainKey],
	    [CNStatusID],
		[CNStatus]
    FROM etl_penPolicyCNStatus
	
END
GO
