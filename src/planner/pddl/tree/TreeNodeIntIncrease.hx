package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.tree.TreeNodeInt;
import planner.pddl.heuristic.HeuristicData.FunctionChange;
/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntIncrease extends TreeNodeInt
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
		state_.SetFunction(functionOneID, GetValueFromChild(0, data_, state_, domain_) + GetValueFromChild(1, data_, state_, domain_));
		
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
		#if debugging_heuristic
		Utilities.Logln("TreeNodeIntIncrease: id: " + functionOneID + " a: " + a + " _ b: " + b);
		#end
		heuristic_data_.function_changes.push(new FunctionChange(functionOneID, new Pair(a.a + b.a, a.b + b.b)));
		
		return null;
	}
	
	override public function GetRawName():String
	{
		return "increase";
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntIncrease = new TreeNodeIntIncrease();
		
		for (child in children)
		{
			concrete.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]); // again, children only return copies of themselves
		}
		
		return [concrete];
	}
	
	override public function Clone():TreeNode 
	{
		var clone:TreeNodeIntIncrease = new TreeNodeIntIncrease();
		
		for (child in children)
		{
			clone.AddChild(child.Clone());
		}
		
		return clone;
	}
	
}