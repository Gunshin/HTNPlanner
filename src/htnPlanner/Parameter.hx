package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Parameter
{
	var name:String = null;
	var type:String = null;
	var value:String = null;

	public function new(name_:String, type_:String, value_:String) 
	{
		name = name_;
		type = type_;
		value = value_;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetType():String
	{
		return type;
	}
	
	public function GetValue():String
	{
		return value;
	}
	
	public function SetValue(value_:String, type_:String)
	{
		if (Utilities.Compare(type_, type) == 0)
		{
			value = value_;
		}
	}
	
}