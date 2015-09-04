package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.State;
import planner.pddl.tree.TreeNode;

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
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		return !children[0].Evaluate(data_, state_, domain_);
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		
		var value:String = children[0].Execute(data_, state_, domain_);
		
		if (value != null)
		{
			state_.RemoveRelation(value);
		}
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "not";
	}
}