/*********************
*   ReportComponentController
*   @author:        Minh H Ma
*   @date:          01/26/2021
*   descrtiption:   This controller is to run either Tabular or Summary report that can be output
*                   to PDF using VF page or embeded to lighting page.
*
*                   Parameters:
*                   reportId: 
                        reportId w filter:  00O5w000009hZ35EAE
                        all ReportId: 		00O5w000009hbc7EAA
*                   recordId: can be any salesforce record Id. MUST be the 1st custom report filter
*                   showDetails: true / false to show detail line
*
*                   apex/customReportPDF?reportId=00O5w000009hZ35EAE&recordId=0015w000029ZbtSAAS
*
*   Update History:
*   01/26/2021  Intial Version
*********************/
public with sharing class ReportComponentController 
{
    public string reportName {get; set;}
    public list<string> reportHeaders {get; set;}
    public List<list<string> > recordList {get; set;}

    Reports.ReportResults rptResults {get; set;}    
    map<string,Reports.ReportFact> factMap  {get; set;}
    boolean includeDetails {get; set;}
    boolean includeSubTotals {get; set;}   
    integer numberOfGroupingCols {get; set;}
    integer numberOfColumns {get; set;}

    public ReportComponentController() 
    {
        // https://curious-bear-mff7sb-dev-ed--c.visualforce.com/apex/customReportPDF?reportId=00O5w000009hZ35EAE&recordId=0015w000029ZbtSAAS
        Id reportId = ApexPages.currentPage().getParameters().get('reportId');
        string recordId = ApexPages.currentPage().getParameters().get('recordId');
        String showDetails = String.valueOf(ApexPages.currentPage().getParameters().get('showDetails'));
        String showSubTotals = String.valueOf(ApexPages.currentPage().getParameters().get('showSubTotals'));
        includeDetails = false;
        if (showDetails == 'true')
            includeDetails = true;

        includeSubTotals = false;
        if (showSubTotals == 'true')
            includeSubTotals = true;

        rptResults = runSelectedReport(reportId, recordId, includeDetails);
        populatingReport();
    }

    @AuraEnabled
    public static String getReportMetadata (Id reportId, string recordId, Boolean showDetails)
    {
        Reports.ReportResults results = runSelectedReport(reportId, recordId, showDetails);
        return JSON.serializePretty(results);
    }

    public static Reports.ReportResults runSelectedReport(Id reportId, string recordId, Boolean showDetails)
    {
        //reportId ='00O5w000009hZ35EAE';
        system.debug('ReportId: ' + reportId);
        system.debug('RecordId: ' + recordId);
        system.debug('showDetails: ' + showDetails);

        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();

        /****
        // get ReportFilters
        List<Reports.ReportFilter> rptFilters = reportMd.getReportFilters();
		system.debug('rptFilters: ' + rptFilters);
        for (Reports.ReportFilter filter : rptFilters)
        {
            system.debug('filter: ' + filter);
        }
        */
 
        Reports.ReportResults results;

        // Override filter and run report
        if (reportMd.getReportFilters().size() > 0 &&
           recordId != null)
        {
            Reports.ReportFilter filter = reportMd.getReportFilters()[0];
            filter.setValue(recordId);
            results = Reports.ReportManager.runReport(reportId, reportMd, showDetails);
        }
        else 
        {
            results = Reports.ReportManager.runReport( reportId, showDetails );
        }
        system.debug('Number Of columns: ' + results.getReportMetadata().getDetailColumns().size() );
        system.debug('getGroupingsDown: ' + results.getGroupingsDown() );
        system.debug('factMap: ' + results.getFactMap());

        return results;
    }

    private void populatingReport()
    {
        recordList = new List<list<string> >();

        // Report Name
        reportName = rptResults.getReportMetadata().getname();
        system.debug('reportName: ' + reportName);

        // Group Level to Label
        map<integer, string> groupLevelToLabel = new map<integer, string>();
        Map<String,Reports.GroupingColumn> groupingCols = rptResults.getReportExtendedMetadata().getGroupingColumnInfo();
        for(string nameStr : groupingCols.keyset() )
        {
	        Reports.GroupingColumn groupingCol = groupingCols.get(nameStr);
	        groupLevelToLabel.put(groupingCol.getGroupingLevel(), groupingCol.getLabel());
        }
        numberOfGroupingCols = groupLevelToLabel.size();
        system.debug('groupLevelToLabel: ' + groupLevelToLabel);
        
        // Number of columns
        numberOfColumns = rptResults.getReportMetadata().getDetailColumns().size();
        system.debug('numberOfColumns: ' + numberOfColumns);

        // Headers
        reportHeaders = new List<string>();
        // Grouping headers
        for(integer groupLevel : groupLevelToLabel.keyset() )
        {
            reportHeaders.Add(groupLevelToLabel.get(groupLevel));
        }
        // Report headers
        for (string header : rptResults.getReportMetadata().getDetailColumns() )
        {  
            reportHeaders.add(rptResults.getReportExtendedMetadata().getDetailColumnInfo().get(header).getlabel());
        }
        system.debug('reportHeaders: ' + reportHeaders);

        // factMap
        factMap = rptResults.getFactMap();
        system.debug('factMap: ' + factMap);

        map<string, string> reportFields = new map<string, string>();

        // Groupings
        List<Reports.GroupingValue> groupings = rptResults.getGroupingsDown().getGroupings();
        system.debug('groupings: ' + groupings);
        if (groupings.size() > 0)
            // Summary Report
            handleSummaryReport(groupings);
        else if (includeDetails) {
            handleTabularReport();
        }
    }

    private void handleTabularReport()
    {
        Reports.ReportFact rptFact = factMap.get('T!T');
        handleReportDetail(rptFact);
    }

    private void handleSummaryReport(List<Reports.GroupingValue> groupings)
    {
        for (Reports.GroupingValue grp : groupings)
        {
            list<string> fieldList;
            //system.debug('value: ' + grp.getValue() + '     label: ' + grp.getLabel() + '     key: ' + grp.getKey());
            
            string valueStr = string.valueOf(grp.getValue()) ;
            string Label = grp.getLabel();
            string keyStr = grp.getKey();
            integer colCnt = 0;
            integer cnt = keyStr.countMatches('_');

            // Add a blank line at star of grouping
            if (cnt > 0)
            {   
                fieldList = new list<string>();
                fieldList = addBlankfield(fieldList, numberOfGroupingCols + numberOfColumns);
                recordList.Add(fieldList);
                system.debug('***fieldList: ' +  fieldList);
            }

            fieldList = new list<string>();
            for (Integer i = 0; i < cnt; i++) 
            {
                fieldList.Add('');
                colCnt += 1;
            }
            fieldList.Add(Label);
            colCnt += 1;
            
            fieldList = addBlankfield(fieldList, numberOfGroupingCols - colCnt);
                
            Reports.ReportFact rptFact = factMap.get(keyStr + '!T');
            list<Reports.SummaryValue> sumValues = rptFact.getAggregates();

            fieldList = addBlankfield(fieldList, numberOfColumns - sumValues.size());
            for (Reports.SummaryValue sumValue : sumValues)
            {
                if (includeSubTotals)
                    fieldList.Add(sumValue.getLabel());
                else {
                    fieldList.Add('');
                }
            }
            recordList.Add(fieldList);
            system.debug('fieldList: ' +  fieldList);
            
            if (includeDetails)
            {
                handleReportDetail(rptFact);
            }
            
            if (grp.getGroupings() != null)
            {
                handleSummaryReport(grp.getGroupings());
            }
        }
    }

    private void handleReportDetail(Reports.ReportFact rptFact)
    {
        Reports.ReportFactWithDetails rptFactwDtl = (Reports.ReportFactWithDetails)rptFact;
        List<Reports.ReportDetailRow> detailRows =  rptFactwDtl.getRows();
        if (detailRows.size() > 0)
        {
            for (Reports.ReportDetailRow detailRow : detailRows)
            {
                list<string> fieldList = new list<string>();
                fieldList = addBlankfield(fieldList, numberOfGroupingCols);
                        
                List<Reports.ReportDataCell> dataCells = detailRow.getDataCells();
                if (dataCells.size() > 0)
                {
                    for (Reports.ReportDataCell dataCell : dataCells)
                    {
                        fieldList.Add(dataCell.getLabel());
                    }
                }
                recordList.Add(fieldList);
                system.debug('fieldList: ' +  fieldList);
            }
        }
        //system.debug('rptFactwDtl: ' +  rptFactwDtl.getRows());
    }

    private static list<string> addBlankfield(list<string> fieldList, Integer cnt)
    {
        for (Integer i = 0; i < cnt; i++) 
        {
            fieldList.Add('');
        }
        return fieldList;
    }

}