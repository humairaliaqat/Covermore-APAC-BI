USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_StagingIndex_e5_v4]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_StagingIndex_e5_v4]
as
begin
/*
20130813 - LS - start optimising e5
20190726 - LT - e5 v4 upgrade
*/

    set nocount on

    if not exists(select name from sys.indexes where  name = 'e5_WorkProperty_v4')
        create nonclustered index e5_WorkProperty_v4 on e5_WorkProperty_v4(Work_Id,Property_Id) include(PropertyValue)

    if not exists(select name from sys.indexes where  name = 'e5_WorkClass_v4')
        create nonclustered index e5_WorkClass_v4 on e5_WorkClass_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_Category1_v4')
        create nonclustered index e5_Category1_v4 on e5_Category1_v4(Id) include(Name,Code)

    if not exists(select name from sys.indexes where  name = 'e5_Category2_v4')
        create nonclustered index e5_Category2_v4 on e5_Category2_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_Category3_v4')
        create nonclustered index e5_Category3_v4 on e5_Category3_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_Status_v4')
        create nonclustered index e5_Status_v4 on e5_Status_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_WorkProperty_v4')
        create nonclustered index e5_WorkProperty_v4 on e5_WorkProperty_v4(Work_Id,Property_Id) include(PropertyValue)

    if not exists(select name from sys.indexes where  name = 'e5_WorkActivityProperty_v4')
        create nonclustered index e5_WorkActivityProperty_v4 on e5_WorkActivityProperty_v4(Work_Id,WorkActivity_Id,Property_Id) include(PropertyValue)

    if not exists(select name from sys.indexes where  name = 'e5_Work_v4')
        create nonclustered index e5_Work_v4 on e5_Work_v4(Id) include(Category1_Id)

    if not exists(select name from sys.indexes where  name = 'e5_ListItem_v4')
        create nonclustered index e5_ListItem_v4 on e5_ListItem_v4(Id) include(Code,Name)

    if not exists(select name from sys.indexes where  name = 'e5_CategoryActivity_v4')
        create nonclustered index e5_CategoryActivity_v4 on e5_CategoryActivity_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_Event_v4')
        create nonclustered index e5_Event_v4 on e5_Event_v4(Id) include(Name)

    if not exists(select name from sys.indexes where  name = 'e5_Property_v4')
        create nonclustered index e5_Property_v4 on e5_Property_v4(PropertyLabel,Id)

end
GO
