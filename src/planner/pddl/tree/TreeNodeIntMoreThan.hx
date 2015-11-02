package planner.pddl.tree;
import planner.pddl.tree.TreeNodeInt;
import planner.pddl.heuristic.HeuristicData;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMoreThan extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new() 
	{
		super();
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		return valueA_ > valueB_;
	}
	
	override public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool 
	{
		// for more than, we are searching to see if the largest value
		// of a, is bigger than the smallest value of b
		return valueA_.b > valueB_.a;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntMoreThan = new TreeNodeIntMoreThan();
		
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
		return new Pair(cast(Math.min(a.a, b.a + 1), Int), a.b);
	}
	
	override public function GetRawName():String
	{
		return ">";
	}
	
}