USE [db-au-workspace]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_5C492627]    Script Date: 24/02/2025 5:22:15 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_5C492627](varbinary(128)) AS RANGE LEFT FOR VALUES (0x006B006C0069006100760069006E)
GO
