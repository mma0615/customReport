({
    doInit : function(component, event, helper) {
		var factMap = component.get("v.factMap");
		if( factMap ){
			var groupingKey = component.get("v.groupingKey");
            component.set("v.dataTotals", factMap[groupingKey+"!T"].aggregates)
            console.log('***dataTotals: ' + JSON.stringify( component.get("v.dataTotals")));
		}
	},
})
