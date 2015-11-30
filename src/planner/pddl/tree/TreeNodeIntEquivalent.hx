package planner.pddl.tree;
import planner.pddl.Pair;
import planner.pddl.tree.TreeNodeInt;
import planner.pddl.heuristic.HeuristicData;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntEquivalent extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new() 
	{
		super();
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		return valueA_ == valueB_;
	}
	
	override public function HeuristicComparisonEvaluate(valueA_:Pair<Int, Int>, valueB_:Pair<Int, Int>):Bool 
	{
		// search for overlap
		// since the pairs will always be well formed, eg. .a <= .b
		// the following is enough to determine overlap
		return valueA_.a <= valueB_.b && valueB_.a <= valueA_.b;
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		var concrete:TreeNodeIntEquivalent = new TreeNodeIntEquivalent();
		
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
		
		return new Pair(cast(Math.min(a.a, b.a), Int), cast(Math.max(a.b, b.b), Int));
	}
	
	override public function GetRawName():String
	{
		return "==";
	}
	
	override public function Clone():TreeNode 
	{
		var clone:TreeNodeIntEquivalent = new TreeNodeIntEquivalent();
		
		for (child in children)
		{
			clone.AddChild(child.Clone());
		}
		
		return clone;
	}
}