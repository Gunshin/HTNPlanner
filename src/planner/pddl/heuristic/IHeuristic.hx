package planner.pddl.heuristic;

/**
 * ...
 * @author ...
 */
interface IHeuristic
{
	
	public function RunHeuristic(initial_state_:State):HeuristicResult;
	
}