package planner.pddl.heuristic;
import planner.pddl.StateHeuristic;

/**
 * ...
 * @author Michael Stephens
 */
class HeuristicNode
{
	public var state:StateHeuristic = null;
	
	public var actions_applied_to_state:Array<PlannerActionNode> = null;
	
	public var heuristic_data:HeuristicData = null;

	public function new(state_:StateHeuristic, actions_applied_to_state_:Array<PlannerActionNode>, heuristic_data_:HeuristicData) 
	{
		state = state_;
		actions_applied_to_state = actions_applied_to_state_;
		heuristic_data = heuristic_data_;
	}
	
}