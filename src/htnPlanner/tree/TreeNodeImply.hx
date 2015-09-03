package htnPlanner.tree;
import htnPlanner.tree.TreeNode;

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
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{		
		return !children[0].Evaluate(data_, state_, domain_) || children[1].Evaluate(data_, state_, domain_);
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{		
		throw "this TreeNodeImply should not be used within action effect!";
		return null;
	}
	
	override public function GetRawName():String
	{
		return "imply";
	}

}