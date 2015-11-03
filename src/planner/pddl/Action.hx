package planner.pddl;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.tree.Tree;

/**
 * ...
 * @author Michael Stephens
 */
class Action
{
	var name:String = null;
	
	var data:ActionData = new ActionData();
	
	var precondition:Tree = null;
	var effect:Tree = null;
	

	public function new(name_:String)
	{
		name = name_;
	}
	
	public function SetPreconditionTree(tree_:Tree)
	{
		precondition = tree_;
	}
	
	public function SetEffectTree(tree_:Tree)
	{
		effect = tree_;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function Evaluate(state_:State, domain_:Domain):Bool
	{
		return precondition.Evaluate(data, state_, domain_);
	}
	
	public function Execute(state_:State, domain_:Domain):State
	{
		var cloned:State = state_.Clone();
		effect.Execute(data, cloned, domain_);
		return cloned;
	}
	
	public function HeuristicEvaluate(heuristic_data:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool
	{
		return precondition.HeuristicEvaluate(data, heuristic_data, state_, domain_);
	}
	
	/**
	 * We do not want to needlessly clone the state when we are using the same one constantly
	 * @param	state_
	 * @param	domain_
	 */
	public function HeuristicExecute(heuristic_data:HeuristicData, state_:StateHeuristic, domain_:Domain)
	{
		effect.HeuristicExecute(data, heuristic_data, state_, domain_);
	}
	
	public function toString():String
	{
		return "{\"name\":\"" + name + "\", \"action_data\":" + data + "}";
	}
	
	public function GetData():ActionData
	{
		return data;
	}
	
	public function GetEffectTree():Tree
	{
		return effect;
	}
	
	public function GetPreconditionTree():Tree
	{
		return precondition;
	}
	
}