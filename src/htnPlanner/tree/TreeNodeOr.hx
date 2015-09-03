package htnPlanner.tree;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeOr extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		for (i in children)
		{
			if (i.Evaluate(data_, state_, domain_))
			{
				return true;
			}
		}
		return false;
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		throw "cannot use an 'or' within an effect execution (makes no sense)";
	}
	
	override public function GetRawName():String
	{
		return "or";
	}
}