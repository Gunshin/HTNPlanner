package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.tree.TreeNode;

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
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		return !children[0].HeuristicEvaluate(data_, heuristic_data_, state_, domain_) || children[1].HeuristicEvaluate(data_, heuristic_data_, state_, domain_);
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		throw "this TreeNodeImply should not be used within action effect!";
	}
	
	override public function GetRawName():String
	{
		return "imply";
	}

}