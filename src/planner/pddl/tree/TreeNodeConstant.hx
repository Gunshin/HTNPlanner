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
class TreeNodeConstant extends TreeNode
{

	var constant_value:String = null;
	
	public function new(value_:String) 
	{
		super();
		constant_value = value_;
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{		
		throw "this TreeNodeConstant should not be used within action precondition!";
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{		
		return constant_value;
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		throw "this TreeNodeConstant should not be used within action precondition!";
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		return constant_value;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		return [this];
	}	
	
	override public function GetRawName():String
	{
		return "constant";
	}
	
	override public function Clone():TreeNode 
	{
		return new TreeNodeConstant(constant_value);
	}

}