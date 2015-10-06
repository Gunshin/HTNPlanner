package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMinus extends TreeNodeInt
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
		return Std.string(GetValueFromChild(0, data_, state_, domain_) - GetValueFromChild(1, data_, state_, domain_));
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		var a_bounds:Pair<Int, Int> = HeuristicGetValueFromChild(0, data_, heuristic_data_, state_, domain_);
		var b_bounds:Pair<Int, Int> = HeuristicGetValueFromChild(0, data_, heuristic_data_, state_, domain_);
		
		// The largest possible range subtraction is to do
		// a.min - b.max
		// a.max - b.min
		return Std.string(new Pair(a_bounds.a - b_bounds.b, a_bounds.b + b_bounds.a));
	}
	
	override public function GetRawName():String
	{
		return "-";
	}
}