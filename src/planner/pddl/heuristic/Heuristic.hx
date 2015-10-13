package planner.pddl.heuristic;

import planner.pddl.ActionData;
import planner.pddl.Pair;
import planner.pddl.Predicate;
import planner.pddl.StateHeuristic;

import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;
import planner.pddl.tree.TreeNodePredicate;

/**
 * ...
 * @author Michael Stephens
 */
class Heuristic
{	
	var domain:Domain = null;
	var problem:Problem = null;

	public function new(domain_:Domain, problem_:Problem) 
	{
		domain = domain_;
		problem = problem_;
	}
	
	/**
	 * 
	 * I need to add in numeric goals exactly as i did predicates
	 * when attempting to fulfill the goals, i need to select actions in the previous layer until it is satisfied,
	 * eg. i could end up having 5 actions in the previous layer that contribute to the numeric. I need to add all
	 * actions to the goal. I cannot use the same action multiple times. same parameter set though?
	 * 
	 * 
	 * @param	initial_state_
	 * @return
	 */
	public function RunHeuristic(initial_state_:State):Int
	{
		// should do this check to make sure we dont attempt to generate a heuristic on a satisfied state
		if (problem.EvaluateGoal(initial_state_))
		{
			return 0;
		}
		
		
		//trace("init: " + initial_state_.toString());
		var heuristic_state:StateHeuristic = new StateHeuristic();
		initial_state_.CopyTo(heuristic_state);
		var current_node:HeuristicNode = new HeuristicNode(heuristic_state, Planner.GetAllActionsForState(heuristic_state, domain), new HeuristicData());
		var state_list:Array<HeuristicNode> = new Array<HeuristicNode>();
		state_list.push(current_node);
		
		// first generate the full graph to ensure we can fulfill the goal
		var depth:Int = 0;
		
		while (!problem.HeuristicEvaluateGoal(current_node.state))
		{
			var successor_state:StateHeuristic = ApplyActions(current_node);
			current_node = new HeuristicNode(successor_state, Planner.GetAllActionsForState(successor_state, domain), new HeuristicData());
			state_list.push(current_node);
			
			depth++;
			
			if (depth > 20)
			{
				var total_action_count:Int = 0;
				
				for (state in state_list)
				{
					total_action_count += state.actions_applied_to_state.length;
				}
				trace("returning with no heuristic found: " + (total_action_count * 20));
				return total_action_count * 20;
			}
		}
		
		// now lets extract the relaxed plan
		var concrete_actions:Map<PlannerActionNode, Bool> = new Map<PlannerActionNode, Bool>();
		var concrete_actions_count:Int = 0;
		
		// first we need to grab all of the individual goal nodes
		var goal_nodes:Array<TreeNode> = GetGoalNodes(problem.GetGoalTree().GetBaseNode());
		
		// next lets set the goal nodes into the respective layers, so that we can traverse backwards
		// through the layers and check against anything enabled by such layer
		var goal_node_layers:Array<Array<TreeNode>> = new Array<Array<TreeNode>>();
		for (index in 0...state_list.length)
		{
			goal_node_layers[index] = new Array<TreeNode>();
		}
		
		for (goal_node in goal_nodes)
		{
			AddGoalNodeToLayers(goal_node, state_list, goal_node_layers, state_list.length - 1);
		}
		
		// now that things have been set into layers, the idea is that we traverse backwards through the layers findiong actions that provide the effects needed
		// in the next goal_node_layers.
		var index:Int = state_list.length - 1;
		while(index > 0)// we only go down to 1, as layer 0 are the initial predicates provided to start the heuristic with, and have already been fulfilled
		{
			if (goal_node_layers[index].length > 0)// just to guarantee that we only do this action expansion on a layer that needs something satisfied
			{
				var goal_node_checking_state:StateHeuristic = new StateHeuristic();
				var s_h_n:HeuristicNode = state_list[index - 1]; // index - 1 since we need to use actions from the previous layer
				for (action_node in s_h_n.actions_applied_to_state)
				{
					if (!concrete_actions.exists(action_node))// only run on this action if it has not been added to the list
					{
						var heuristic_data_for_looking:HeuristicData = new HeuristicData();
						action_node.Set();
						action_node.action.HeuristicExecute(heuristic_data_for_looking, s_h_n.state, domain);
						
						//need to apply the predicates to the state
						for (i in heuristic_data_for_looking.predicates.keys())
						{
							goal_node_checking_state.AddRelation(i);
						}
						
						var goal_nodes_to_remove:Array<TreeNode> = new Array<TreeNode>();
						// now lets check to see if any of the predicates we are looking for were satisfied
						for (goal_node in goal_node_layers[index])
						{
							if (goal_node.HeuristicEvaluate(null, null, goal_node_checking_state, domain))
							{
								// we found a successful satisfaction due to this action
								goal_nodes_to_remove.push(goal_node); //lets add it to a list for safe removal
								
								//lets find any and all preconditions of this action that need satisfying and add them to the goal list
								var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(action_node.action.GetPreconditionTree().GetBaseNode());
								for (node in action_precondition_nodes_to_add)
								{
									if (domain.PredicatExists(node.GetRawName()))
									{
										var pred_node:TreeNodePredicate = cast(node, TreeNodePredicate);
										var concrete_node:TreeNode = pred_node.BuildConcretePredicate(action_node.action.GetData());
										AddGoalNodeToLayers(concrete_node, state_list, goal_node_layers, index - 1);
									}
								}
								
								// lets also record this action node
								concrete_actions.set(action_node, true);
								concrete_actions_count++;
							}
						}
						
						// safely remove the goal nodes so we do not attempt them again
						for (goal_node in goal_nodes_to_remove)
						{
							goal_node_layers[index].remove(goal_node);
						}
					}
				}
			}
			
			index--;
		}
		//trace(concrete_actions_count);
		return concrete_actions_count;
	}
	
	/**
	 * This function takes a the specified goal_node_ and adds it to the layers_ list at the lowest layer it can.
	 * 
	 * It does this by looking through the state_list_ and determining the earliest it was satisfied, and placing it in the corresponding
	 * layers_ list.
	 * @param	goal_node_
	 * @param	state_list_
	 * @param	layers_
	 * @param	start_index_
	 */
	function AddGoalNodeToLayers(goal_node_:TreeNode, state_list_:Array<HeuristicNode>, layers_:Array<Array<TreeNode>>, start_index_:Int)
	{
		var earliest_index:Int = start_index_;
		for (index in start_index_...0)
		{
			var s_h_n:HeuristicNode = state_list_[index];
			if (goal_node_.HeuristicEvaluate(null, null, s_h_n.state, domain))
			{
				earliest_index = index;
			}
			else // since we have hit the point that the goal is no longer satisfied, exit the for loop
			{
				break;
			}
		}
		
		layers_[earliest_index].push(goal_node_);
	}
	
	function GetGoalNodes(node_:TreeNode):Array<TreeNode>
	{
		var goal_nodes:Array<TreeNode> = new Array<TreeNode>();
		Tree.RecursiveExplore(node_, function(node_)
		{
			if (domain.PredicatExists(node_.GetRawName()))
			{
				goal_nodes.push(node_);
				return true;
			}
			
			return false;
		});
		
		return goal_nodes;
	}
	
	/**
	 * Each HeuristicNode contains both the state, and the actions to be applied to that state.
	 * @param	current_node_
	 * @return Successor state
	 */
	function ApplyActions(current_node_:HeuristicNode):StateHeuristic
	{
		var new_state:StateHeuristic = new StateHeuristic();
		current_node_.state.CopyTo(new_state);
		
		//trace("action count: " + actions_.length);
		for (actionNode in current_node_.actions_applied_to_state)
		{
			actionNode.Set();
			//trace(actionNode.params + "\n" + actionNode.valuesType);
			actionNode.action.HeuristicExecute(current_node_.heuristic_data, new_state, domain);
		}
		
		for (i in current_node_.heuristic_data.function_changes)
		{
			new_state.SetFunctionBounds(i.name, i.bounds);
		}
		
		for (i in current_node_.heuristic_data.predicates.keys())
		{
			new_state.AddRelation(i);
		}
		
		return new_state;
	}

}