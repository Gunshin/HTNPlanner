package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeIntMoreThanOrEqual extends TreeNodeInt
{
	// i decided to make this a class so it is clear where all of the evaluation and execution code is.
	// could have just made the comparisonEvaluate function anonymous and pass it to the super class.

	public function new(params_:Array<String>) 
	{
		super(params_);
	}
	
	override public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool
	{
		return valueA_ >= valueB_;
	}
	
}