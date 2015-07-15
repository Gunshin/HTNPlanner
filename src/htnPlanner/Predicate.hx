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
	var parameters:Map<String, Parameter> = new StringMap<Parameter>();
	
	public function new(predicateValue_:String) 
	{
		ParseValue(predicateValue_);
	}
	
	public function Construct():String
	{
		var constructedValue:String = name;
		
		for (i in templateValue)
		{
			constructedValue += " " + parameters.get(i).GetValue();
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
			parameters.set(i.a, new Parameter(i.a, i.b, null));
		}
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetParameter(name_:String):Parameter
	{
		return parameters.get(name_);
	}
	
}