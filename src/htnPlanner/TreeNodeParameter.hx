package htnPlanner;

/**
 * ...
 * @author 
 */
class TreeNodeParameter extends TreeNode
{
	
	var paramName:String = null;
	
	public function new(paramName_:String) 
	{
		super();
		
		paramName = paramName_;
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return Std.string(state_.GetFunction(parameters_.get(paramName).GetValue()));
	}
	
}