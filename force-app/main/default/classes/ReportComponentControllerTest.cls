/********* 
 * Make sure reports with and without grouping are created
 */
@isTest
private class ReportComponentControllerTest {
    
    @isTest(seeAllData=true) static void testReportMetadata_validIDWParms()
    {
        List<Report> reportList = [ SELECT Id, Name FROM Report];
        for (report rptObj : reportList)
        {
            // Get the report metadata
        	Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(rptObj.Id);
        	Reports.ReportMetadata reportMd = describe.getReportMetadata();
 
        	Reports.ReportResults results;
        	// Override filter and run report
        	if (reportMd.getReportFilters().size() > 0 )
            {
                Test.startTest();
            	String reportJSON = ReportComponentController.getReportMetadata(rptObj.Id, null, true);
        		Test.stopTest();

        		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(reportJSON);
        		Map<String, Object> reportMetadata = (Map<String, Object>)m.get('reportMetadata');
        		System.assertEquals( rptObj.Name, reportMetadata.get('name'), 'The correct report should be returned' );
                
                return;
            }
        }        
    }
    
    @isTest(seeAllData=true) static void testReportMetadata_validIDNoParms()
    {
        List<Report> reportList = [ SELECT Id, Name FROM Report];
        for (report rptObj : reportList)
        {
            // Get the report metadata
        	Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(rptObj.Id);
        	Reports.ReportMetadata reportMd = describe.getReportMetadata();
 
        	Reports.ReportResults results;
        	// Override filter and run report
        	if (reportMd.getReportFilters().size() == 0 )
            {
                Test.startTest();
            	String reportJSON = ReportComponentController.getReportMetadata(rptObj.Id, null, true);
        		Test.stopTest();

        		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(reportJSON);
        		Map<String, Object> reportMetadata = (Map<String, Object>)m.get('reportMetadata');
        		System.assertEquals( rptObj.Name, reportMetadata.get('name'), 'The correct report should be returned' );
                
                return;
            }
        }        
    }

    @isTest static void testReportMetadata_invalidID()
    {
        Id bogusId = '00Q000000000000';
        NoDataFoundException expectedEx;
        String reportJSON;
        try
        {
            Test.startTest();
            reportJSON = ReportComponentController.getReportMetadata(bogusId, null, true);
            Test.stopTest();
        } 
        catch( NoDataFoundException ex )
        {
            expectedEx = ex;
        }

        System.assertEquals( null, reportJSON, 'No report json should be returned' );
        System.assertNotEquals( null, expectedEx, 'An exception should been thronw to be handled by the front-end' );
    }
    
    @isTest(seeAllData=true) static void testTabularReportVFPage()
    {
        Report reportObj = [ SELECT Id, Name FROM Report where Format='Tabular' limit 1];

        ApexPages.currentPage().getParameters().put('reportId', reportObj.Id);
        ApexPages.currentPage().getParameters().put('recordId', null);
        ApexPages.currentPage().getParameters().put('showDetails', 'true');
        
        ReportComponentController vfP = new ReportComponentController();
        
    }
    
    @isTest(seeAllData=true) static void testSummaryReportVFPage()
    {
        Report reportObj = [ SELECT Id, Name FROM Report where Format='Summary' limit 1];

        ApexPages.currentPage().getParameters().put('reportId', reportObj.Id);
        ApexPages.currentPage().getParameters().put('recordId', null);
        ApexPages.currentPage().getParameters().put('showDetails', 'true');
        
        ReportComponentController vfP = new ReportComponentController();
        
    }
}