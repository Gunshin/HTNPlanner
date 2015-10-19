package planner.pddl.tree;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMoreThanOrEqual extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new() 
	{
		super();
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		//trace(valueA_ + " ____ " + valueB_);
		return valueA_ >= valueB_;
	}
	
	override public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool 
	{
		// for more than or equal to, we are searching to see if the largest value
		// of a, more than or equal to than the smallest value of b
		return valueA_.b >= valueB_.a;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntMoreThanOrEqual = new TreeNodeIntMoreThanOrEqual();
		
		for (child in children)
		{
			concrete.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]); // again, children only return copies of themselves
		}
		
		return [concrete];
	}
	
	override public function GetRawName():String
	{
		return ">=";
	}
}