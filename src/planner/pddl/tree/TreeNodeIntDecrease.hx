package planner.pddl.tree;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData.FunctionChange;
import planner.pddl.Pair;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntDecrease extends TreeNodeInt
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
		state_.SetFunction(functionOneID, GetValueFromChild(0, data_, state_, domain_) - GetValueFromChild(1, data_, state_, domain_));
		
		return null;
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		var functionOneID:String = children[0].HeuristicExecute(data_, heuristic_data_, state_, domain_);
		
		var a:Pair<Int, Int> = HeuristicGetValueFromChild(0, data_, heuristic_data_, state_, domain_);
		var b:Pair<Int, Int> = HeuristicGetValueFromChild(1, data_, heuristic_data_, state_, domain_);
		
		heuristic_data_.function_changes.push(new FunctionChange(functionOneID, new Pair(a.a - b.b, a.b - b.a)));
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "decrease";
	}
}