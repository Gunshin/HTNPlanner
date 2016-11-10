package planner.pddl.heuristic;
import planner.pddl.Planner;

/**
 * ...
 * @author ...
 */
interface IHeuristic
{
	
	public function RunHeuristic(initial_state_:State, planner_:Planner):HeuristicResult;
	
}