package planner.pddl;

class FunctionChange
{
	public var name:String = null;
	public var bounds:Pair<Int, Int> = null;
	
	public function new(name_:String, bounds_:Pair<Int, Int>)
	{
		name = name_;
		bounds = bounds_;
	}
}

/**
 * ...
 * @author Michael Stephens
 */
class HeuristicData
{
	public var function_changes:Array<FunctionChange> = new Array<FunctionChange>();
	
	public function new()
	{
		
	}
}
