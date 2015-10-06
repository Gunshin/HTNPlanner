package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.Pair;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author 
 */
class TreeNodeValue extends TreeNode
{
	
	var valueName:String = null;
	
	public function new(valueName_:String) 
	{
		super();
		
		valueName = valueName_;
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		throw "This function should not be getting called.";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return data_.GetValue(valueName).GetValue();
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		var pos_values:Array<String> = data_.GetValue(valueName).GetPossibleValues(state_, domain_);
		return Std.string(new Pair<Int, Int>(Std.parseInt(pos_values[0]), Std.parseInt(pos_values[pos_values.length - 1])));
	}
	
	override public function GetRawName():String
	{
		return valueName;
	}
	
	override public function GetRawTreeString():String
	{
		return valueName;
	}
	
}