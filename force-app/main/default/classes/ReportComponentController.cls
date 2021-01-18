public with sharing class ReportComponentController 
{
    @AuraEnabled
    public static String getReportMetadata ( Id reportId, string recordId, Boolean showDetails)
    {
        //reportId ='00O5w000009hZ35EAE';
        system.debug('ReportId: ' + reportId);
        system.debug('RecordId: ' + recordId);
        system.debug('showDetails: ' + showDetails);

        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
 
        Reports.ReportResults results;
        // Override filter and run report
        if (reportMd.getReportFilters().size() > 0 )
        {
            Reports.ReportFilter filter = reportMd.getReportFilters()[0];
            filter.setValue(recordId);
            results = Reports.ReportManager.runReport(reportId, reportMd, showDetails);
            /*
            Reports.ReportFactWithSummaries factSum = 
                (Reports.ReportFactWithSummaries)results.getFactMap().get('T!T');
            System.debug('Value for recordId: ' + factSum.getAggregates()[0].getLabel());
            */
        }
        else 
        {
            results = Reports.ReportManager.runReport( reportId, showDetails );
        }
        
        return JSON.serializePretty(results);



    }
}