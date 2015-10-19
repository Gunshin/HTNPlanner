package planner.pddl.tree;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntLessThanOrEqual extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new() 
	{
		super();
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		return valueA_ <= valueB_;
	}
	
	override public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool 
	{
		// for less or equal to than, we are searching to see if the smallest value of a
		// is less or equal to the largest value of b
		return valueA_.a <= valueB_.b;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntLessThanOrEqual = new TreeNodeIntLessThanOrEqual();
		
		for (child in children)
		{
			concrete.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]); // again, children only return copies of themselves
		}
		
		return [concrete];
	}
	
	override public function GetRawName():String
	{
		return "<=";
	}
}