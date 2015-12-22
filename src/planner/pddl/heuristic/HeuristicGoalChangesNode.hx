package planner.pddl.heuristic;

import de.polygonal.ds.Heapable;
import planner.pddl.Pair;
import planner.pddl.planner.PlannerActionNode;
import planner.pddl.StateHeuristic;

/**
 * ...
 * @author Michael Stephens
 */
class HeuristicGoalChangesNode implements Heapable<HeuristicGoalChangesNode>
{
	public var position:Int;

	public var action_node:PlannerActionNode = null;
	public var goal_node_change:Int = 0;
	
	public var before_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = null;
	public var after_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = null;
	public var goal_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = null;
	
	public var state_local_to_this_nodes_changes:StateHeuristic = null;
	
	public function new(action_node_:PlannerActionNode, 
						goal_node_change_:Int, 
						before_values_:Pair<Pair<Int, Int>, Pair<Int, Int>>, 
						after_values_:Pair<Pair<Int, Int>, Pair<Int, Int>>, 
						goal_values_:Pair<Pair<Int, Int>, Pair<Int, Int>>, 
						goal_node_checking_state_:StateHeuristic) 
	{
		action_node = action_node_;
		goal_node_change = goal_node_change_;
		
		before_values = before_values_;
		after_values = after_values_;
		goal_values = goal_values_;
		
		state_local_to_this_nodes_changes = goal_node_checking_state_;
	}
	
	public function compare(other:HeuristicGoalChangesNode):Int
	{
		return goal_node_change - other.goal_node_change;
	}
	
	public function toString():String
	{
		return action_node.GetActionTransform() + ":" + goal_node_change;
	}
	
}