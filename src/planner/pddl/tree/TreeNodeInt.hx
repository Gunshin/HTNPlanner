package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.State;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeInt extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		return ComparisonEvaluate(GetValueFromChild(0, data_, state_, domain_), GetValueFromChild(1, data_, state_, domain_));
	}
	
	public function GetValueFromChild(childIndex_:Int, data_:ActionData, state_:State, domain_:Domain):Int
	{
		var childOneExecute:String = children[childIndex_].Execute(data_, state_, domain_);
		
		var value:Null<Int> = Std.parseInt(childOneExecute); // if it is an int, great! it might be a function though
		
		if (value == null)
		{
			value = state_.GetFunction(childOneExecute);
		}
		
		return value;
	}
	
	public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool { throw "must override this function"; }	
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String { throw "must override this function"; }
	
}