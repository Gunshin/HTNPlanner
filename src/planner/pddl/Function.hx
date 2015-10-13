package planner.pddl;

/**
 * ...
 * @author Michael Stephens
 */
class Function
{
	//this class is primarily here incase i want to do type checking on parameters and such
	
	
	var name:String = null;
	
	public function new(node_:RawTreeNode) 
	{
		ParseValue(node_);
	}
	
	public function Construct(data_:ActionData, templateValue_:Array<String>):String
	{
		var constructedValue:String = name;
		
		for (i in templateValue_)
		{
			// if the first character is not a '?', then this value is not a parameter name. Therefor just add the value if it isnt.
			if (Utilities.Compare(i.charAt(0), "?") == 0)
			{
				constructedValue += " " + data_.GetParameter(i).GetValue();
			}
			else
			{
				constructedValue += " " + i;
			}
		}
		
		return constructedValue;
	}
	
	function ParseValue(node_:RawTreeNode)
	{		
		if (node_.children.length > 0)
		{
			var pairs:Array<Pair<String, String>> = Utilities.GenerateValueTypeMap(node_.children); // this gives the parameters, not sure if i want to do anything with it yet
		}
		
		name = node_.value;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function ConstructRaw(templateValue_:Array<String>):String
	{
		var constructedValue:String = name;
		
		for (i in templateValue_)
		{
			constructedValue += " " + i;
		}
		
		return constructedValue;
	}
}