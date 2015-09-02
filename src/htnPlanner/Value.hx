package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Value
{
	var name:String = null;	
	
	var value:String = null;
	
	public function new(name_:String)
	{
		name = name_;
	}
	
	public function GetPossibleValues():Array<String> { throw "must override this function"; }
	
	public function SetValue(value_:String)
	{
		value = value_;
	}
	
	public function GetValue():String
	{
		return value;
	}
	
	public function GetName():String
	{
		return name;
	}
	
}