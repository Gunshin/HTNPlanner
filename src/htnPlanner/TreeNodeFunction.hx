package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeFunction extends TreeNode
{
	var func:Function = null;
	var paramNames:Array<String> = null;

	public function new(func_:Function, paramNames_:Array<String>) 
	{
		super();
		func = func_;
		paramNames = paramNames_;
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		throw "Should not be evaluating functions. Use Execute instead which will pass back the variable name";
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return func.Construct(parameters_, paramNames);
	}
}