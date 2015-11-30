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
		//trace((data_ != null) + " _ " + (state_ != null) + " _ " + (domain_ != null));
		//trace(valueName + " _ " + (data_.GetValue(valueName) != null));
		return data_.GetValue(valueName).GetValue();
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "This function should not be getting called.";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		//trace((data_ != null) + " _ " + (heuristic_data_ != null) + " _ " + (state_ != null) + " _ " + (domain_ != null));
		//trace(valueName + " _ " + (data_.GetValue(valueName) != null));
		var value:Int = Std.parseInt(data_.GetValue(valueName).GetValue());
		return new Pair<Int, Int>(value, value).ToPlainString();
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		// since at runtime, this value node will only have 1 value for its current action, we can replace the concrete version with
		// a raw value aswell
		var concrete:TreeNodeIntFunctionValue = new TreeNodeIntFunctionValue(action_data_.GetValue(valueName).GetValue());
		
		return [concrete];
	}
	
	override public function GetRawName():String
	{
		return valueName;
	}
	
	override public function GetRawTreeString():String
	{
		return valueName;
	}
	
	override public function Clone():TreeNode 
	{
		return new TreeNodeIntFunctionValue(valueName);
	}
	
}