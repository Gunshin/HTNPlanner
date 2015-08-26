package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeFunction extends TreeNode
{
	var func:Function = null;
	var paramNames:Array<String> = new Array<String>();

	public function new(func_:Function, params_:Array<RawTreeNode>) 
	{
		super();
		func = func_;
		
		for (param in params_)
		{
			paramNames.push(param.value);
		}
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