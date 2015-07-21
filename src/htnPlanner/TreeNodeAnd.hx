package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeAnd extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		
		for (i in children)
		{
			
			if (!i.Execute(parameters_, state_, domain_))
			{
				return false;
			}
			
		}
		
		return true;
		
	}
	
}