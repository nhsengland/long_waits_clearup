# this sets your udal ID up automatically
uid = paste0(rstudioapi::systemUsername(), '@udal.nhs.uk')

# establish connection to UDAL
con_udal <- DBI::dbConnect(drv = odbc::odbc(),
                           driver = "ODBC Driver 17 for SQL Server",
                           server = "udalsyndataprod.sql.azuresynapse.net",
                           database = "UDAL_Warehouse",
                           UID = uid,
                           authentication = "ActiveDirectoryInteractive")
