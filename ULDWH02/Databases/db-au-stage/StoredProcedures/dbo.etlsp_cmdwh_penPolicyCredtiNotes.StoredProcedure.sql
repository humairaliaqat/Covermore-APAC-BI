USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyCredtiNotes]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[etlsp_cmdwh_penPolicyCredtiNotes]
AS
BEGIN
 
  set nocount on

  /* staging index */
  exec etlsp_StagingIndex_Penguin

  /*************************************Start of tblPolicyCredtiNote*************************************/
  ------ 30/07/21 - VS - Adding CNStatusID into ETL 

  IF OBJECT_ID('etl_penPolicyCreditNote') IS NOT NULL
    DROP TABLE etl_penPolicyCreditNote

  SELECT
    CountryKey,
    CompanyKey,
    DomainKey,
    PrefixKey + CONVERT(varchar, a.[ID]) CreditNotePolicyKey,
    a.[ID],
    a.[CreditNoteNumber],
    a.[OriginalPolicyId],
    a.[Amount],
    a.[RedeemPolicyId],
    a.[RedeemAmount],
    a.[Status],
    a.[DomainId],
    a.[CreateDateTime],
    a.[UpdateDateTime],
	a.Commission,
	a.RedeemedCommission,
	a.Comments, 
	a.CNStatusID

  INTO etl_penPolicyCreditNote
  FROM [db-au-stage].[dbo].[penguin_tblPolicyCreditNote_aucm] a
  CROSS APPLY dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'AU') dk

 UNION ALL
 
 SELECT
    CountryKey,
    CompanyKey,
    DomainKey,
    PrefixKey + CONVERT(varchar, a.[ID]) CreditNotePolicyKey,
    a.[ID],
    a.[CreditNoteNumber],
    a.[OriginalPolicyId],
    a.[Amount],
    a.[RedeemPolicyId],
    a.[RedeemAmount],
    a.[Status],
    a.[DomainId],
    a.[CreateDateTime],
    a.[UpdateDateTime],
	a.Commission,
	a.RedeemedCommission,
	a.Comments,
	a.CNStatusID
  FROM [db-au-stage].[dbo].[penguin_tblPolicyCreditNote_autp] a
  CROSS APPLY dbo.fn_GetDomainKeys(a.DomainId, 'TIP', 'AU') dk

  
  IF OBJECT_ID('[db-au-cmdwh].[dbo].[penPolicyCreditNote]') IS NULL
  BEGIN

    CREATE TABLE [db-au-cmdwh].[dbo].[penPolicyCreditNote] (
        [CountryKey] [varchar](2) NOT NULL,
	    [CompanyKey] [varchar](5) NOT NULL,
	    [DomainKey] [varchar](41) NOT NULL,
	    [CreditNotePolicyKey] [varchar](71) NOT NULL,
	    [ID] [int] NOT NULL,
	    [CreditNoteNumber] [nvarchar](15) NOT NULL,
	    [OriginalPolicyId] [int] NOT NULL,
	    [Amount] [money] NOT NULL,
	    [RedeemPolicyId] [int] NULL,
	    [RedeemAmount] [money] NULL,
	    [Status] [varchar](15) NOT NULL,
	    [DomainId] [int] NOT NULL,
	    [CreateDateTime] [datetime] NOT NULL,
	    [UpdateDateTime] [datetime] NOT NULL,
		[Commission] [money] NULL,
		[RedeemedCommission] [money] NULL,
		[Comments] [nvarchar] (max), 
		[CNStatusID]  [int] NULL
    )

    CREATE CLUSTERED INDEX idx_penPolicyCreditNote_CreditNotePolicyKey ON [db-au-cmdwh].dbo.penPolicyCreditNote (CreditNotePolicyKey,UpdateDateTime)

  END
  ELSE
  BEGIN

    DELETE a
      FROM [db-au-cmdwh].dbo.penPolicyCreditNote a
      INNER JOIN etl_penPolicyCreditNote b
        ON a.CreditNotePolicyKey = b.CreditNotePolicyKey

  END

  INSERT [db-au-cmdwh].dbo.penPolicyCreditNote WITH (TABLOCKX) ([CountryKey],
	    [CompanyKey],
	    [DomainKey],
	    [CreditNotePolicyKey],
	    [ID],
	    [CreditNoteNumber],
	    [OriginalPolicyId],
	    [Amount],
	    [RedeemPolicyId],
	    [RedeemAmount],
	    [Status],
	    [DomainId],
	    [CreateDateTime],
	    [UpdateDateTime],
		[Commission],
		[RedeemedCommission],
		[Comments], 
		[CNSTATUSID])
    SELECT
        [CountryKey],
	    [CompanyKey],
	    [DomainKey],
	    [CreditNotePolicyKey],
	    [ID],
	    [CreditNoteNumber],
	    [OriginalPolicyId],
	    [Amount],
	    [RedeemPolicyId],
	    [RedeemAmount],
	    [Status],
	    [DomainId],
	    [CreateDateTime],
	    [UpdateDateTime],
		[Commission],
		[RedeemedCommission],
		[Comments],
		[CNStatusID]
    FROM etl_penPolicyCreditNote
	
END

GO
