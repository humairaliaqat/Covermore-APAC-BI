USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[spTransformGLCOA]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spTransformGLCOA]
as
begin

	if object_id('[db-au-workspace]..usrCOA') is not null
		drop table [db-au-workspace]..usrCOA

	select 
		*
	into [db-au-workspace]..usrCOA
	from 
		openrowset
		(
			'Microsoft.ACE.OLEDB.12.0',
			'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
			'
			select 
				*
			from 
				[User COA$]
			'
		)

	alter table [db-au-workspace]..usrCOA add ID int not null identity(1,1)

	if object_id('[db-au-workspace]..usrGLAccounts') is not null
		drop table [db-au-workspace]..usrGLAccounts

	;with cte_parentchild as
	(
		select
			1 Account_Level,
			convert(varchar(255), '') Parent_Account_Code,
			convert(varchar(255), replace([Level 1 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 1]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 1 Category]) Account_Category, 
			convert(varchar(255), [Level 1 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 1 Code], ' ', ' '),
			[Level 1],
			[Level 1 Category], 
			[Level 1 Operator]

		union all
    
		select
			2 Account_Level,
			convert(varchar(255), replace([Level 1 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 2 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 2]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 2 Category]) Account_Category, 
			convert(varchar(255), [Level 2 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 1 Code], ' ', ' '),
			replace([Level 2 Code], ' ', ' '),
			[Level 2],
			[Level 2 Category], 
			[Level 2 Operator]    

		union all

		select
			3 Account_Level,
			convert(varchar(255), replace([Level 2 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 3 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 3]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 3 Category]) Account_Category, 
			convert(varchar(255), [Level 3 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 2 Code], ' ', ' '),
			replace([Level 3 Code], ' ', ' '),
			[Level 3],
			[Level 3 Category], 
			[Level 3 Operator]    

		union all

		select
			4 Account_Level,
			convert(varchar(255), replace([Level 3 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 4 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 4]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 4 Category]) Account_Category, 
			convert(varchar(255), [Level 4 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 3 Code], ' ', ' '),
			replace([Level 4 Code], ' ', ' '),
			[Level 4],
			[Level 4 Category], 
			[Level 4 Operator]    

		union all

		select
			5 Account_Level,
			convert(varchar(255), replace([Level 4 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 5 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 5]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 5 Category]) Account_Category, 
			convert(varchar(255), [Level 5 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 4 Code], ' ', ' '),
			replace([Level 5 Code], ' ', ' '),
			[Level 5],
			[Level 5 Category], 
			[Level 5 Operator]
        
		union all

		select
			6 Account_Level,
			convert(varchar(255), replace([Level 5 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 6 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 6]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 6 Category]) Account_Category, 
			convert(varchar(255), [Level 6 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 5 Code], ' ', ' '),
			replace([Level 6 Code], ' ', ' '),
			[Level 6],
			[Level 6 Category], 
			[Level 6 Operator]

		union all

		select
			7 Account_Level,
			convert(varchar(255), replace([Level 6 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 7 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 7]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 7 Category]) Account_Category, 
			convert(varchar(255), [Level 7 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 6 Code], ' ', ' '),
			replace([Level 7 Code], ' ', ' '),
			[Level 7],
			[Level 7 Category], 
			[Level 7 Operator]

		union all

		select
			8 Account_Level,
			convert(varchar(255), replace([Level 7 Code], ' ', ' ')) Parent_Account_Code,
			convert(varchar(255), replace([Level 8 Code], ' ', ' ')) Child_Account_Code,
			convert(varchar(255), [Level 8]) Child_Account_Desc,
			'A' Account_Hierarchy_Type,
			convert(varchar(255), [Level 8 Category]) Account_Category, 
			convert(varchar(255), [Level 8 Operator]) Account_Operator,
			min(ID) Account_Order
		from
			[db-au-workspace]..usrCOA
		group by
			replace([Level 7 Code], ' ', ' '),
			replace([Level 8 Code], ' ', ' '),
			[Level 8],
			[Level 8 Category], 
			[Level 8 Operator]
	)
	select 
		--Account_Level, 
		Parent_Account_Code,
		Child_Account_Code,
		Child_Account_Desc,
		Account_Category,
		Account_Hierarchy_Type,
		Account_Operator,
		row_number() over (order by Account_Level, Account_Order) Account_Order
	into [db-au-workspace]..usrGLAccounts
	from
		cte_parentchild
	where
		Child_Account_Code is not null
	order by
		Account_Level,
		Account_Order

end
GO
