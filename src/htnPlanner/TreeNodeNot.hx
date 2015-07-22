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
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		return !children[0].Evaluate(parameters_, state_, domain_);
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		
		var value:String = children[0].Execute(parameters_, state_, domain_);
		
		if (value != null)
		{
			state_.RemoveRelation(value);
		}
		
		return null;
	}
	
}