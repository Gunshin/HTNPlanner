package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class BasicOperand
{
	var name:String;
	
	var paramTypes:Array<String>;
	
	var func:Array<String> -> State -> String;

	public function new(name_:String, paramTypes_:Array<String>, func_:Array<String> -> State -> String) 
	{
		name = name_;
		paramTypes = paramTypes_;
		func = func_;
	}
	
	public function Execute(params_:Array<String>, state_:State):String
	{
		return func(params_, state_);
	}
	
	public function GetName():String
	{
		return name;
	}
	
}