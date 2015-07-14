package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	
	var parameters:Array<Parameter> = null;
	var precondition:Tree = null;
	var effect:Tree = null;

	public function new(scope_:String) 
	{
		
	}
	
	public function SetParameter(name_:String, value_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param == null)
		{
			throw "param is invalid";
		}
		
		param.value = value_;
	}
	
	function GetParameter(name_:String):Parameter
	{
		for (i in parameters)
		{
			if (Utilities.Compare(name_, i.name) == 0)
			{
				return i;
			}
		}
		
		return null;
	}
	
}