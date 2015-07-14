package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Predicate
{

	// predicates are usually defined by a keyword followed by the parameters eg. "at ?x - locatable ?l - location"
	public var firstPartOfValue:String = null;
	public var parameters:Array<Parameter> = new Array<Parameter>();
	
	public function new(predicateValue_:String) 
	{
		ParseValue(predicateValue_);
	}
	
	public function Construct():String
	{
		var constructedValue:String = firstPartOfValue;
		
		for (i in parameters)
		{
			constructedValue += " " + i.GetValue();
		}
		
		return constructedValue;
	}
	
	function ParseValue(string_:String)
	{
		var split:Array<String> = string_.split(" ");
		var map:Map<String, String> = Utilities.GenerateValueTypeMap(split.slice(1));
		
		firstPartOfValue = split[0];
		
		for (i in map.keys)
		{
			parameters.push(new Parameter(i, map.get(i), null));
		}
		
		
	}
	
}