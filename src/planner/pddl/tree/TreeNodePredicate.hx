package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.Predicate;
import planner.pddl.RawTreeNode;
import planner.pddl.State;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodePredicate extends TreeNode
{
	
	var predicate:Predicate = null;
	var paramNames:Array<String> = new Array<String>();

	public function new(predicate_:Predicate, params_:Array<RawTreeNode>) 
	{
		super();
		
		predicate = predicate_;
		
		for (param in params_)
		{
			paramNames.push(param.value);
		}
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		var predicateValue:String = predicate.Construct(data_, paramNames);
		return state_.Exists(predicateValue);
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return predicate.Construct(data_, paramNames);
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		var predicateValue:String = predicate.Construct(data_, paramNames);
		return state_.Exists(predicateValue);
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		return predicate.Construct(data_, paramNames);
	}
	
	override public function GetRawName():String
	{
		return predicate.GetName();
	}
	
	override public function GetRawTreeString():String
	{
		var returnee:String = predicate.ConstructRaw(paramNames);
		return returnee;
	}
	
	override public function toString():String
	{
		return GetRawTreeString();
	}
}