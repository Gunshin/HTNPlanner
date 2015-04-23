package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Variable
{

	@:protected
	var name:String;
	
	@:protected
	var type:String;
	
	@:protected
	var value:String;
	
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
	
	public function SetValue(value_:String)
	{
		value = value_;
	}
	
}