package planner.pddl.heuristic;
import planner.pddl.planner.PlannerActionNode;
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
	
	public function toString():String
	{
		return "{\"state\":" + state.toString() + ", \"actions_applied_to_state\":" + actions_applied_to_state.toString() + ", \"heuristic_data\":" + heuristic_data.toString() + "}";
	}
	
}