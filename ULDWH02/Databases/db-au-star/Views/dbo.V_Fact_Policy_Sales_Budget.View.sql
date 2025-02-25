USE [db-au-star]
GO
/****** Object:  View [dbo].[V_Fact_Policy_Sales_Budget]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[V_Fact_Policy_Sales_Budget]
(
	Age_Band_SK,
	Date_SK,
	Outlet_SK,
	Business_Unit_SK,
	Currency_SK,
	Cancellation_Cover_SK,
	Consultant_SK,
	Excess_SK,
	Product_SK,
	Travel_Destination_SK,
	Trip_Duration_SK,
	Number_of_Policies,
	Number_of_Quotes,
	Premium_Amount,
	Commission_Amount,
	Premium_SD_Amount,
	Premium_GST_Amount,
	Commission_SD_Amount,
	Commission_GST_Amount,
	Gross_Premium_Budget_Amount
 )
AS
SELECT
  Fact_Policy_Sales.Age_Band_SK,
  Fact_Policy_Sales.Date_SK,
  Fact_Policy_Sales.Outlet_SK,
  Fact_Policy_Sales.Business_Unit_SK,
  Fact_Policy_Sales.Currency_SK,
  Fact_Policy_Sales.Cancellation_Cover_SK,
  Fact_Policy_Sales.Consultant_SK,
  Fact_Policy_Sales.Excess_SK,
  Fact_Policy_Sales.Product_SK,
  Fact_Policy_Sales.Travel_Destination_SK,
  Fact_Policy_Sales.Trip_Duration_SK,
  Fact_Policy_Sales.Number_of_Policies,
  Fact_Policy_Sales.Number_of_Quotes,
  Fact_Policy_Sales.Premium_Amount,
  Fact_Policy_Sales.Commission_Amount,
  Fact_Policy_Sales.Premium_SD_Amount,
  Fact_Policy_Sales.Premium_GST_Amount,
  Fact_Policy_Sales.Commission_SD_Amount,
  Fact_Policy_Sales.Commission_GST_Amount,
  0 AS Gross_Premium_Budget_Amount

FROM
  Fact_Policy_Sales INNER JOIN Dim_Date ON (Dim_Date.Date_SK=Fact_Policy_Sales.Date_SK)   
  WHERE Dim_Date.Date < convert(varchar(10),GETDATE(), 112) and Fact_Policy_Sales.Domain_ID=7

UNION ALL

SELECT 
	-1 AS Age_Band_SK,
	Fact_Policy_Budget.Date_SK,
	Fact_Policy_Budget.Outlet_SK,
	Fact_Policy_Budget.Business_Unit_SK,
	Fact_Policy_Budget.Currency_SK,
	-1 AS Cancellation_Cover_SK,
	-1 AS Consultant_SK,
	-1 AS Excess_SK,
	-1 AS Product_SK,
	-1 AS Travel_Destination_SK,
	-1 AS Trip_Duration_SK,
	0 AS Number_of_Policies,
	0 AS Number_of_Quotes,
	0 AS Premium_Amount,
	0 AS Commission_Amount,
	0 AS Premium_SD_Amount, 
	0 AS Premium_GST_Amount,
	0 AS Commission_SD_Amount,
	0 AS Commission_GST_Amount,
	Fact_Policy_Budget.Gross_Premium_Budget_Amount
  
FROM
	Fact_Policy_Budget





GO
