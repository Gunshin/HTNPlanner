package planner.pddl.heuristic;

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
	
	/**
	 * Since we only ever add, and do not remove, to a heuristic state, we can just build a map of predicates to add.
	 * It helps with being a map when we are doin the plan extraction.
	 */
	public var predicates:Map<String, Bool> = new Map<String, Bool>();
	
	public function new()
	{
		
	}
}
