DECLARE @MaxDate AS DATE	
SET @MaxDate = (SELECT MAX(DerWeekEnding) FROM [Reporting].[MESH_WLMDS_Open_ASI_Combined])									

SELECT	
	[DerWeekEnding] AS Activity_Date	
	,Ref.Organisation_Code
	,Ref.Organisation_Name									
	,Ref.[STP_Name]	
	,[ACTIVITY_TREATMENT_FUNCTION_CODE]
	,CASE									
		WHEN [Weekly_Mapped_RTT_TFC_Descriptor] IS NULL THEN 'Other'									
		ELSE [Weekly_Mapped_RTT_TFC_Descriptor] 									
		END AS [RTT_TFC_Descriptor]
	,CASE									
		WHEN Waiting_List_Type ='IRTT' THEN 'DTA_Wait'									
		WHEN Waiting_List_Type ='ORTT' THEN 'OP_Wait'									
		ELSE 'CHECK'									
		END AS [Wait_Type]
	,SUM(CASE WHEN DATEDIFF(DAY, Referral_To_Treatment_Period_Start_Date, DerWeekEnding) > 455 THEN 1 ELSE 0 END) AS long_waits
	,SUM(CASE WHEN [Der_Record_ID] IS NOT NULL THEN 1 ELSE 0 END) AS total_ptl

FROM [Reporting].[MESH_WLMDS_Open_ASI_Combined] AS WL																								
LEFT OUTER JOIN [Reporting].[Ref_ODS_Provider_Hierarchies] AS Ref on DerProviderCode = Ref.Organisation_Code
LEFT OUTER JOIN [Internal_RTT].[RTT_TFC_Mappings] AS TFC on cast([ACTIVITY_TREATMENT_FUNCTION_CODE] as varchar) = cast([National_TFC_code] as varchar)	

WHERE 
	1=1
	AND Referral_To_Treatment_Period_Start_Date IS NOT NULL									
	AND Referral_To_Treatment_Period_End_Date IS NULL									
	AND Ref.Region_Code = 'Y59'	
	AND DerWeekEnding BETWEEN DATEADD(WEEK,-52,@MaxDate) AND @MaxDate
	AND Waiting_List_Type in ('IRTT','ORTT')	
	AND derProviderCode in ('RPC','RHM','RWF','RYR','RTH','RHW','RXQ','RXC','RTP','RPA','RN5','RHU','RN7','R1F','RVV','RDU','RTK','RA2')									


GROUP BY 
	[DerWeekEnding] 
	,Ref.Organisation_Code
	,Ref.Organisation_Name									
	,Ref.[STP_Name]	
	,[ACTIVITY_TREATMENT_FUNCTION_CODE]
	,CASE									
		WHEN [Weekly_Mapped_RTT_TFC_Descriptor] IS NULL THEN 'Other'									
		ELSE [Weekly_Mapped_RTT_TFC_Descriptor] 									
		END 
	,CASE									
		WHEN Waiting_List_Type ='IRTT' THEN 'DTA_Wait'									
		WHEN Waiting_List_Type ='ORTT' THEN 'OP_Wait'									
		ELSE 'CHECK'									
		END