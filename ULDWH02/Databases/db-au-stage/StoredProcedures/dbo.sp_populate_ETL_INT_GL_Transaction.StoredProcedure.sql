USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[sp_populate_ETL_INT_GL_Transaction]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_populate_ETL_INT_GL_Transaction] @BUName varchar ( 50 ) , 
                                                       @Scenario_GL_Code char ( 1 )
AS
BEGIN

    SET NOCOUNT ON

    DECLARE
       @vc_sql_from_cols varchar ( max ) , 
       @vc_sql_to_cols varchar ( max ) , 
       @vc_sql varchar ( max )

    TRUNCATE TABLE ETL_INT_GL_Transaction

    SET @vc_sql_from_cols = ''
    SET @vc_sql_to_cols = ''
    
    SELECT
           @vc_sql_to_cols = @vc_sql_to_cols + 
						  CASE                      
						  WHEN S_Head = 'CHANNEL'	    THEN ', Channel_Code'
						  WHEN S_Head = 'DEPT'		    THEN ', Department_Code'
						  WHEN S_Head = 'PRODUCT'	    THEN ', Product_Code'
						  WHEN S_Head = 'BDM'		    THEN ', BDM_Code'
						  WHEN S_Head = 'BUSINESS'	    THEN ', Business_Code'
						  WHEN S_Head = 'PROJECT CODES'   THEN ', Project_Code'
						  WHEN S_Head = 'STATE'		    THEN ', State_Code'
						  WHEN S_Head = 'CLIENT'	 	    THEN ', Client_Code'
						  WHEN S_Head = 'SOURCE'		    THEN ', Source_Code'
						  WHEN S_Head = 'JV'		    THEN ', Joint_Venture_Code'
						  WHEN S_Head = 'CASE NUMBER'	    THEN ', Case_Number'
						  END , 
           @vc_sql_from_cols = @vc_sql_from_cols + ', Ledger_Analysis_T' + CAST ( Entry_Number - 1 AS char (2) )
      FROM
           ( 
             SELECT
                    Subject_Header AS S_Head , 
                    MIN ( Entry_Number )AS Entry_Number
               FROM SUN_ANL_ENT_DEFN
               WHERE SUN_ANL_ENT_DEFN.Subject_Header IN
                     ( 'BDM' , 'BUSINESS' , 'CHANNEL' , 'CLIENT' , 'DEPT' ,
				    'JV' , 'PRODUCT' , 'PROJECT CODES' , 'STATE' , 'SOURCE' ,
				    'CASE NUMBER'
                     )
               AND	SUN_ANL_ENT_DEFN.Analysis_Business_Unit_Code = @BUName
               GROUP BY
                        Subject_Header
           ) AS SUN_Entity_Definition


    SET @vc_sql =
			 'INSERT INTO ETL_INT_GL_Transaction
					   (
					   Scenario_GL_Code , 
					   Account_Code , 
					   Business_Unit_Code , 
					   Period , 
					   Transaction_Date , 
					   Entry_Date , 
					   Due_Date , 
					   Posting_Date , 
					   Originated_Date , 
					   After_Posting_Date , 
					   Base_Rate , 
					   Conversion_Rate , 
					   Reversal_Indicator , 
					   Journal_Number , 
					   Journal_Line , 
					   Journal_Type , 
					   Journal_Source , 
					   General_Ledger_Amount , 
					   Report_Amount , 
					   Other_Amount , 
					   Debit_Credit_Indicator , 
					   Allocation_Marker , 
					   Txn_Reference , 
					   Txn_Description
					   ' + @vc_sql_to_cols + '
					   )
			 SELECT
					    Scenario_GL_Code , 
					    Account_Code , 
					    Business_Unit_Code , 
					    Period , 
					    Transaction_Date , 
					    Entry_Date , 
					    Due_Date , 
					    Posting_Date , 
					    Originated_Date , 
					    After_Posting_Date , 
					    Base_Rate , 
					    Conversion_Rate , 
					    Reversal , 
					    Journal_Number , 
					    Journal_Line , 
					    Journal_Type , 
					    Journal_Source , 
					    General_Ledger_Amount , 
					    Report_Amount , 
					    Other_Amount , 
					    Debit_Credit_Indicator , 
					    Allocation_Marker , 
					    Treference , 
					    Description
					    ' + @vc_sql_from_cols + ' 
			 FROM	    SUN_' + @Scenario_GL_Code + '_SALFLDG(NOLOCK)
			 WHERE	    Business_Unit_Code=''' + @BUName + ''''
			 
    EXEC (@vc_sql)

    SET NOCOUNT OFF

END


GO
