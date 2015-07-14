package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	var name:String = null;
	var parameters:Array<Parameter> = new Array<Parameter>();
	var precondition:Tree = null;
	var effect:Tree = null;

	public function new(name_:String)
	{
		name = name_;
	}
	
	public function AddParameter(name_:String, type_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param != null)
		{
			throw "param already exists";
		}
		
		parameters.push(new Parameter(name_, type_, null));
	}
	
	public function SetParameter(name_:String, value_:String, type_:String)
	{
		var param:Parameter = GetParameter(name_);
		if (param == null)
		{
			throw "param is invalid";
		}
		
		param.SetValue(value_, type_);
	}
	
	function GetParameter(name_:String):Parameter
	{
		for (i in parameters)
		{
			if (Utilities.Compare(name_, i.GetName()) == 0)
			{
				return i;
			}
		}
		
		return null;
	}
	
}