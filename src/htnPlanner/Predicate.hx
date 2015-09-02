package htnPlanner;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Predicate
{
	//this value is used since the paramters are not guaranteed to be in order due to maps storing values alphabetically
	//var templateValue:Array<String> = new Array<String>();

	// predicates are usually defined by a keyword followed by the parameters eg. "at ?x - locatable ?l - location"
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
				constructedValue += " " + data_.GetParameterMap().get(i).GetValue();
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
		var pairs:Array<Pair> = Utilities.GenerateValueTypeMap(node_.children);
		
		name = node_.value;
	}
	
	public function GetName():String
	{
		return name;
	}
}