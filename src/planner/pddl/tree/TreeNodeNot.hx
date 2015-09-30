package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
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
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		return !children[0].HeuristicEvaluate(data_, heuristic_data_, state_, domain_);
	}
	
	/**
	 * since we are doing delete list heuristic, we do not want to actually do any removing from the state
	 * we do however, need to call execute on its child so that the tree properly does its thing. I do not believe
	 * that any children of this node can affect the state, so im am just guaranteeing i dont miss anything.
	 * @param	data_
	 * @param	state_
	 * @param	domain_
	 * @return
	 */
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		children[0].HeuristicExecute(data_, heuristic_data_, state_, domain_);
		return null;
	}
	
	override public function GetRawName():String
	{
		return "not";
	}
}