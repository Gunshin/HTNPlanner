package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.State;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntAssign extends TreeNodeInt
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		var functionOneID:String = children[0].Execute(data_, state_, domain_);
		
		state_.SetFunction(functionOneID, GetValueFromChild(1, data_, state_, domain_));
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "=";
	}

}