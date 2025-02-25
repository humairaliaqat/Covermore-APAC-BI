USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Load_Ticking_Data]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     
procedure [dbo].[etlsp_Load_Ticking_Data]    
        
as    
begin    

    set nocount on  

if object_id('Tickets_Issued_Shop') is not null  
    drop table Tickets_Issued_Shop  
  
select   
        [Date of Issue],
        Alpha,
        [Booking Business Unit Name],
        [No of Tickets Issued]
into Tickets_Issued_Shop
from   
    openrowset  
    (  
        'Microsoft.ACE.OLEDB.12.0',  
        'Excel 12.0 Xml;HDR=YES;Database=E:\Siddhesh\Ticketing_Data.xlsx',  
        '  
        select   
            *  
        from   
            [Tickets Issued by Shop$]  
        '  
    )  
  

if object_id('Tickets_Issued_Consultant') is not null  
    drop table Tickets_Issued_Consultant  
  
select   
        [Date of Issue],
        [Booking Business Unit Name],
        [Booking Consultant],
        [No of Tickets Issued]
into Tickets_Issued_Consultant
from   
    openrowset  
    (  
        'Microsoft.ACE.OLEDB.12.0',  
        'Excel 12.0 Xml;HDR=YES;Database=E:\Siddhesh\Ticketing_Data.xlsx',  
        '  
        select   
            *  
        from   
            [Tickets Issued by Consultant$]  
        '  
            )  


end    
    
GO
