USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_54FCD850]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_54FCD850](varbinary(128)) AS RANGE LEFT FOR VALUES (0x00360031003400330030003400360033003400300034, 0x006B006100740065, 0x006E006E00360031003400310030003600390034003000380034)
GO
