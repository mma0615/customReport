/********* 
 * Make sure reports with and without grouping are created
 */
@isTest
private class ReportComponentControllerTest {
    
    @isTest(seeAllData=true) static void getReportMetadata_validIDWParms()
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
    
    @isTest(seeAllData=true) static void getReportMetadata_validIDNoParms()
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

    @isTest static void getReportMetadata_invalidID()
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
}