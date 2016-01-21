package planner.pddl.heuristic;
import planner.pddl.Pair;
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
	
	/**
	 * an array of pairs so i can link actions to changes for use with rate of change of functions
	 */
	public var heuristic_data:Array<Pair<PlannerActionNode, HeuristicData>> = null;

	public function new(state_:StateHeuristic, actions_applied_to_state_:Array<PlannerActionNode>) 
	{
		state = state_;
		actions_applied_to_state = actions_applied_to_state_;
		heuristic_data = new Array<Pair<PlannerActionNode, HeuristicData>>();
		
		for (action in actions_applied_to_state)
		{
			heuristic_data.push(new Pair(action, new HeuristicData()));
		}
	}
	
	public function toString():String
	{
		return "{\"state\":" + state.toString() + ", \"actions_applied_to_state\":" + actions_applied_to_state.toString() + ", \"heuristic_data\":" + heuristic_data.toString() + "}";
	}
	
}