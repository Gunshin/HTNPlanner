package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Precondition
{
	
	var tree:Tree = null;
	public function new(treeNode_:Tree) 
	{
		tree = treeNode_;
	}
	
	public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{		
		return tree.Evaluate(parameters_, state_, domain_);
	}

}