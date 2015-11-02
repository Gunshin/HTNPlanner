package planner.pddl.tree;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntLessThan extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new() 
	{
		super();
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		return valueA_ < valueB_;
	}
	
	override public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool 
	{
		// for less than, we are searching to see if the smallest value of a
		// is less than the largest value of b
		return valueA_.a < valueB_.b;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntLessThan = new TreeNodeIntLessThan();
		
		for (child in children)
		{
			concrete.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]); // again, children only return copies of themselves
		}
		
		return [concrete];
	}
	
	override public function GetHeuristicBounds(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Pair<Int, Int> 
	{
		var a:Pair<Int, Int> = HeuristicGetValueFromChild(0, data_, heuristic_data_, state_, domain_);
		var b:Pair<Int, Int> = HeuristicGetValueFromChild(1, data_, heuristic_data_, state_, domain_);
		
		// the left side will always have the lowest plausible/viable value for this node to be satisfied,
		// but in the case it is not satisfied, it could either be a.b or b.b with the highest value eg.
		// {12, 15} < {8, 10} the left hand side must be lower than the right hand side,
		// so it makes no sense to return the right hand side as the lower bound
		
		// b.b recieves a -1 because our a.a value is meant to be lower than b.b, not lower than or equal to
		return new Pair(a.a, cast(Math.max(a.b, b.b - 1), Int));
	}
	
	override public function GetRawName():String
	{
		return "<";
	}
}