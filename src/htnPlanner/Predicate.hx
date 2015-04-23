package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Predicate
{
	var name:String;
	
	var paramTypes:Array<String>;
	
	var func:Array<String> -> State -> Bool;

	public function new(name_:String, paramTypes_:Array<String>, func_:Array<String> -> State -> Bool) 
	{
		name = name_;
		paramTypes = paramTypes_;
		func = func_;
	}
	
	public function Execute(params_:Array<String>, state_:State):Bool
	{
		return func(params_, state_);
	}
	
	public function GetName():String
	{
		return name;
	}
	
}