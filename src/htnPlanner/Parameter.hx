package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Parameter
{
	var nameType:Pair = null;
	var value:String = null;

	public function new(name_:String, type_:String, value_:String) 
	{
		nameType = new Pair(name_, type_);
		value = value_;
	}
	
	public function GetName():String
	{
		return nameType.a;
	}
	
	public function GetType():String
	{
		return nameType.b;
	}
	
	public function GetValue():String
	{
		return value;
	}
	
	public function SetValue(value_:String, type_:String, domain:Domain)
	{
		if (domain.ResolveInheritance(type_, nameType.b))
		{
			value = value_;
		}
		else
		{
			//dont really need to throw here
			throw "tried to set parameter with type: " + type_ + " when expecting: " + nameType.b;
		}
	}
	
}