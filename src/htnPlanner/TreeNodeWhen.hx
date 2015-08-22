package htnPlanner;

/**
 * ...
 * @author 
 */
class TreeNodeWhen extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		if (children[0].Evaluate(parameters_, state_, domain_))
		{
			children[1].Execute(parameters_, state_, domain_);
		}
		
		return null;
	}
	
}