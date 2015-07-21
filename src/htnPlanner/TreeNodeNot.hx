package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeNot extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		
		return !children[0].Execute(parameters_, state_, domain_);
		
	}
	
}