package planner.pddl.heuristic;

import planner.pddl.planner.PlannerActionNode;

/**
 * ...
 * @author ...
 */
class HeuristicResult
{
	public var ordered_list:Array<PlannerActionNode> = null;
	
	public var length:Int = 0;
	
	public function new(ordered_list_:Array<PlannerActionNode>, length_:Int)
	{
		ordered_list = ordered_list_;
		length = length_;
	}
}