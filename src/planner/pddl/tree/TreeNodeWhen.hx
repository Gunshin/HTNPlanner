package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author 
 */
class TreeNodeWhen extends TreeNode
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
		if (children[0].Evaluate(data_, state_, domain_))
		{
			children[1].Execute(data_, state_, domain_);
		}
		
		return null;
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		if (children[0].HeuristicEvaluate(data_, heuristic_data_, state_, domain_))
		{
			children[1].HeuristicExecute(data_, heuristic_data_, state_, domain_);
		}
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "when";
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeWhen = new TreeNodeWhen();
		
		for (child in children)
		{
			concrete.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]); // again, children only return copies of themselves
		}
		
		return [concrete];
	}
	
	override public function Clone():TreeNode 
	{
		var clone:TreeNodeWhen = new TreeNodeWhen();
		
		for (child in children)
		{
			clone.AddChild(child.Clone());
		}
		
		return clone;
	}
	
}