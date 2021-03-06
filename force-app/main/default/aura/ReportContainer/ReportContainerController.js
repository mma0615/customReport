({
    getReport : function(component, event, helper) {
        //hide report and show spinner while we process
        debugger;
        var loadingSpinner = component.find('loading');
        $A.util.removeClass(loadingSpinner, 'slds-hide');
        var reportContainer = component.find('report');
        $A.util.addClass(reportContainer, 'slds-hide');
        var reportError = component.find('report-error');
        $A.util.addClass(reportError, 'slds-hide');

        //get report data from Apex controller using report ID provided
        var action = component.get('c.getReportMetadata');
        action.setParams({ 
            reportId: component.get("v.reportIdAttribute"),
            recordId: component.get("v.recordId"),
            showDetails: component.get("v.showDetails")
        });

        //handle response from Apex controller
        action.setCallback(this, function(response){
            // transform into JSON object
            var returnValue = JSON.parse(response.getReturnValue());
            console.log('response.getReturnValue(): ' + response.getReturnValue());
            var groupingLabels = {};
            
            if( returnValue && returnValue.reportExtendedMetadata ){
                // categorize groupings into levels so we can access them as we go down grouping level
                var columnInfo = returnValue.reportExtendedMetadata.groupingColumnInfo;
                //console.log('columnInfo: ' + JSON.stringify(columnInfo));
                for( var property in columnInfo ){
                    if( columnInfo.hasOwnProperty(property) ){
                        var level = columnInfo[property].groupingLevel;
                        var label = columnInfo[property].label;
                        //console.log('level: ' + level);
                        //console.log('label: ' + label);
                        groupingLabels[level] = label;
                    }
                }
                // set lightning attributes so we have access to variables in the view
                component.set("v.groupingLevelToLabel", groupingLabels);
                console.log('groupingLabels: ' + JSON.stringify(groupingLabels));
                component.set("v.reportData", returnValue);
                component.set("v.factMap", returnValue.factMap);
                //console.log('returnValue.factMap: ' + JSON.stringify(returnValue.factMap));

                //set column headers, this assumes that they are returned in order
                var tableHeaders = [];
                for( var i = 0; i < returnValue.reportMetadata.detailColumns.length; i++ ){
                    var fieldAPIName = returnValue.reportMetadata.detailColumns[i];
                    var fieldLabel = returnValue.reportExtendedMetadata.detailColumnInfo[fieldAPIName].label;
                    tableHeaders.push(fieldLabel)
                }
                component.set("v.columnLabels", tableHeaders);
                console.log('tableHeaders: ' + tableHeaders);
                
                //hide spinner, reveal data
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportContainer, 'slds-hide');
            }
            else {
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportError, 'slds-hide');
            }
        })
        $A.enqueueAction(action);
    },

    saveToPDF: function(component, event, helper) {
        
        // Show spinner once button is pressed
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');

        // Build url for Visualforce page
        var vfURL = '/apex/customReportPDF?reportId=' + component.get("v.reportIdAttribute") + 
        '&recordId=' + component.get("v.recordId") +
        '&showDetails=' + component.get("v.showDetails");
        console.log("vfURL: ", vfURL);
          
        window.open(vfURL, '_blank');

        /*
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfURL
        });
        urlEvent.fire();
        */

    }
    

    
})