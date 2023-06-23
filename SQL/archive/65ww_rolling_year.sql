DECLARE @MaxDate AS DATE	
SET @MaxDate = (SELECT MAX(DerWeekEnding) FROM NHSE_PSDM_COVID19.[wl].[WLMDS_Open_ASI_Combined])									

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
	,'RTT_65ww_at_date' AS MetricName	
	,COUNT(DISTINCT(CAST([Der_Record_ID] as varchar))) AS MetricValue
	,CASE WHEN [DerWeekEnding]  = @MaxDate THEN 1 ELSE 0 END AS [Latest_date]

FROM NHSE_PSDM_COVID19.wl.WLMDS_Open_ASI_Combined AS WL									
	LEFT OUTER Join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] AS Ref on WL.DerProviderCode = Ref.Organisation_Code									
	--Left outer Join [NHSE_Reference].[dbo].[tbl_Ref_ClinCode_OPCS] on [OPCS_L4_Code] = [Proposed_Procedure_Opcs_Code]									
	Left outer Join [NHSE_Reference].[dbo].[RTT_TFC_Mappings] AS TFC on cast(WL.[ACTIVITY_TREATMENT_FUNCTION_CODE] as varchar) = cast(TFC.[National_TFC_code] as varchar)

WHERE 
	1=1
	AND Referral_To_Treatment_Period_Start_Date IS NOT NULL									
	AND Referral_To_Treatment_Period_End_Date IS NULL									
	AND Ref.Region_Code = 'Y59'	
	AND DerWeekEnding BETWEEN DATEADD(WEEK,-52,@MaxDate) AND @MaxDate
	AND Waiting_List_Type in ('IRTT','ORTT')	
	AND derProviderCode in ('RPC','RHM','RWF','RYR','RTH','RHW','RXQ','RXC','RTP','RPA','RN5','RHU','RN7','R1F','RVV','RDU','RTK','RA2')									
	AND DATEDIFF(DAY, Referral_To_Treatment_Period_Start_Date, DerWeekEnding) > 455	

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
	,CASE WHEN [DerWeekEnding]  = @MaxDate THEN 1 ELSE 0 END
/*	
UNION ALL

SELECT	
	[DerWeekEnding] AS Activity_Date	
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
	,'risk_cohort_at_date' AS MetricName	
	,COUNT(DISTINCT(CAST([Der_Record_ID] as varchar))) AS MetricValue
	,1 AS [Latest_date]

FROM NHSE_PSDM_COVID19.wl.WLMDS_Open_ASI_Combined AS WL									
	LEFT OUTER Join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] AS Ref on WL.DerProviderCode = Ref.Organisation_Code									
	--Left outer Join [NHSE_Reference].[dbo].[tbl_Ref_ClinCode_OPCS] on [OPCS_L4_Code] = [Proposed_Procedure_Opcs_Code]									
	Left outer Join [NHSE_Reference].[dbo].[RTT_TFC_Mappings] AS TFC on cast(WL.[ACTIVITY_TREATMENT_FUNCTION_CODE] as varchar) = cast(TFC.[National_TFC_code] as varchar)

WHERE 
	1=1
	AND Referral_To_Treatment_Period_Start_Date IS NOT NULL									
	AND Referral_To_Treatment_Period_End_Date IS NULL									
	AND Ref.Region_Code = 'Y59'	
	AND DerWeekEnding = @MaxDate
	AND Waiting_List_Type in ('IRTT','ORTT')	
	AND derProviderCode in ('RPC','RHM','RWF','RYR','RTH','RHW','RXQ','RXC','RTP','RPA','RN5','RHU','RN7','R1F','RVV','RDU','RTK','RA2')									
	AND DATEDIFF(DAY, Referral_To_Treatment_Period_Start_Date, '2024-03-31') > 455	

GROUP BY 
	[DerWeekEnding]
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

		*/