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
	
	var name:String = null;
	var param_names:Array<String> = new Array<String>();

	public function new(name_:String, params_:Array<String>) 
	{
		super();
		
		name = name_;
		
		param_names = params_;
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		return state_.Exists(Construct(data_));
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return Construct(data_);
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		//Utilities.Log("TreeNodePredicate.HeuristicEvaluate: " + Construct(data_) + " : " + state_.Exists(Construct(data_)) + "\n");
		return state_.Exists(Construct(data_));
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		return Construct(data_);
	}
	
	override public function GetRawName():String
	{
		return name;
	}
	
	override public function GetRawTreeString():String
	{
		var returnee:String = ConstructRaw(param_names);
		return returnee;
	}
	
	override public function toString():String
	{
		return GetRawTreeString();
	}
	
	public function Construct(data_:ActionData):String
	{
		var constructedValue:String = name;
		for (i in param_names)
		{
			// if the first character is not a '?', then this value is not a parameter name. Therefor just add the value if it isnt.
			if (Utilities.Compare(i.charAt(0), "?") == 0)
			{
				constructedValue += " " + data_.GetParameter(i).GetValue();
			}
			else
			{
				constructedValue += " " + i;
			}
		}
		
		return constructedValue;
	}
	
	public function ConstructRaw(templateValue_:Array<String>):String
	{
		var constructedValue:String = name;
		
		for (i in templateValue_)
		{
			constructedValue += " " + i;
		}
		
		return constructedValue;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var params:Array<String> = new Array<String>();
		for (param in param_names)
		{
			params.push(action_data_.GetParameter(param).GetValue());
		}
		
		return [new TreeNodePredicate(name, params)];
	}
}