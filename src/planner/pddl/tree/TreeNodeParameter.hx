package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNode;

/**
 * Pretty sure this was the hacked in class to get the integer-ranges working the first time. I do not think it is used anymore,
 * however, if i wanted to be consistent, i should use this for all parameter points on relations and functions
 * 
 * ...
 * @author Michael Stephens
 */
class TreeNodeParameter extends TreeNode
{
	
	var paramName:String = null;
	
	public function new(paramName_:String) 
	{
		super();
		
		paramName = paramName_;
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return Std.string(state_.GetFunction(data_.GetParameter(paramName).GetValue()));
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		return Std.string(state_.GetFunctionBounds(data_.GetParameter(paramName).GetValue()));
	}
	
	override public function GetRawName():String
	{
		return paramName;
	}
	
	override public function GetRawTreeString():String
	{
		return paramName;
	}
}