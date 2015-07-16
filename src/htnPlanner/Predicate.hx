package htnPlanner;
import haxe.ds.StringMap;

/**
 * ...
 * @author Michael Stephens
 */
class Predicate
{
	//this value is used since the paramters are not guaranteed to be in order due to maps storing values alphabetically
	var templateValue:Array<String> = new Array<String>();

	// predicates are usually defined by a keyword followed by the parameters eg. "at ?x - locatable ?l - location"
	var name:String = null;
	
	public function new(predicateValue_:String) 
	{
		ParseValue(predicateValue_);
	}
	
	public function Construct(parameterMap_:Map<String, Parameter>):String
	{
		var constructedValue:String = name;
		
		for (i in templateValue)
		{
			constructedValue += " " + parameterMap_.get(i).GetValue();
		}
		
		return constructedValue;
	}
	
	function ParseValue(string_:String)
	{
		var split:Array<String> = string_.split(" ");
		var pairs:Array<Pair> = Utilities.GenerateValueTypeMap(split.slice(1));
		
		name = split[0];
		
		for (i in pairs)
		{
			templateValue.push(i.a);
		}
	}
	
	public function GetName():String
	{
		return name;
	}
}