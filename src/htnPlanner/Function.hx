package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Function
{
	//this class is primarily here incase i want to do type checking on parameters and such
	
	
	var name:String = null;
	
	public function new(functionValue_:String) 
	{
		ParseValue(functionValue_);
	}
	
	public function Construct(parameterMap_:Map<String, Parameter>, templateValue_:Array<String>):String
	{
		var constructedValue:String = name;
		
		for (i in templateValue_)
		{
			// if the first character is not a '?', then this value is not a parameter name. Therefor just add the value if it isnt.
			if (Utilities.Compare(i.charAt(0), "?") == 0)
			{
				constructedValue += " " + parameterMap_.get(i).GetValue();
			}
			else
			{
				constructedValue += " " + i;
			}
		}
		
		return constructedValue;
	}
	
	function ParseValue(string_:String)
	{
		var split:Array<String> = string_.split(" ");
		
		if (split.length > 1)
		{
			var pairs:Array<Pair> = Utilities.GenerateValueTypeMap(split.slice(1)); // this gives the parameters, not sure if i want to do anything with it yet
		}
		
		name = split[0];
	}
	
	public function GetName():String
	{
		return name;
	}
}