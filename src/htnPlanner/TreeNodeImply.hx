package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeImply extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{		
		return !children[0].Evaluate(parameters_, state_, domain_) || children[1].Evaluate(parameters_, state_, domain_);
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{		
		throw "this TreeNodeImply should not be used within action effect!";
		return null;
	}
	
}