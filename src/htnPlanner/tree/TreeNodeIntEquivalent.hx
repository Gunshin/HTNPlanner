package htnPlanner.tree;
import htnPlanner.tree.TreeNodeInt;

/**
 * ...
 * @author 
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
	
}