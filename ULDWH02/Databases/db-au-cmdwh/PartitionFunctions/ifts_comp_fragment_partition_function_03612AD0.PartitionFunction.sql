USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_03612AD0]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_03612AD0](varbinary(128)) AS RANGE LEFT FOR VALUES (0x0036003600390036003100320036, 0x006E006E0034003200360030003400390032)
GO
