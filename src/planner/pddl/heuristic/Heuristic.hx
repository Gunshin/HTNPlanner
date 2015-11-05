package planner.pddl.heuristic;

import planner.pddl.ActionData;
import planner.pddl.Pair;
import planner.pddl.Predicate;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNodeForall;

import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;
import planner.pddl.tree.TreeNodePredicate;
import planner.pddl.tree.TreeNodeInt;

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
	 * loop through actions
	 * if action brings us closer to the bounds
	 * and the bounds are not already satisfied
	 * lower bound is closer to the upper bound
	 * or upper bound is closer to the lower bound
	 * add it to the list
	 * 
	 * (== (inventory_has_item logs) 15)
	 * find the first action that enables this condition as usual
	 * this works the same as standard predicates
	 * add any action that pushes the bounds towards this goal state
	 * treenodeint to return bounds?
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
		
		Utilities.WriteToFile("temp.json", "------------------\n", true);
		for (action in current_node.actions_applied_to_state)
		{
			Utilities.WriteToFile("temp.json", action.GetActionTransform()+"\n", true);
		}
		for (goal_node in GetGoalNodes(problem.GetGoalTree().GetBaseNode()))
		{
			Utilities.WriteToFile("temp.json", ""+goal_node.HeuristicEvaluate(null, null, current_node.state, domain)+"\n", true);
		}
		
		Utilities.WriteToFile("temp.json", ""+current_node.state.toString()+"\n", true);
		Utilities.WriteToFile("temp.json", "\n------------------------\n\n", true);
		
		// first generate the full graph to ensure we can fulfill the goal
		var depth:Int = 0;
		//trace("\n\n\n\n");
		
		while (!problem.HeuristicEvaluateGoal(current_node.state))
		{
			var successor_state:StateHeuristic = ApplyActions(current_node, domain);
			current_node = new HeuristicNode(successor_state, Planner.GetAllActionsForState(successor_state, domain), new HeuristicData());
			state_list.push(current_node);
			
			depth++;
			
			trace(depth + " ________ " + current_node.state.GetFunctionBounds("available timber location0"));
			
			Utilities.WriteToFile("temp.json", "------------------\n", true);
			for (action in current_node.actions_applied_to_state)
			{
				Utilities.WriteToFile("temp.json", action.GetActionTransform()+"\n", true);
			}
			for (goal_node in GetGoalNodes(problem.GetGoalTree().GetBaseNode()))
			{
				Utilities.WriteToFile("temp.json", ""+goal_node.HeuristicEvaluate(null, null, current_node.state, domain)+"\n", true);
			}
			
			Utilities.WriteToFile("temp.json", ""+current_node.state.toString()+"\n", true);
			Utilities.WriteToFile("temp.json", "\n------------------------\n\n", true);
			
			
			if (depth > 4)
			{
				var total_action_count:Int = 0;
				
				for (state in state_list)
				{
					total_action_count += state.actions_applied_to_state.length;
				}
				
				
				trace("returning with no heuristic found: " + (total_action_count * 20));
				throw "";
				return total_action_count * 20;
			}
		}
		
		//Utilities.WriteToFile("state_list.json", ""+state_list, false);
		
		//trace(depth);
		
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
			AddGoalNodeToLayers(goal_node, state_list, goal_node_layers);
		}
		
		
		// now that things have been set into layers, the idea is that we traverse backwards through the layers findiong actions that provide the effects needed
		// in the next goal_node_layers.
		var index:Int = state_list.length - 1;
		while(index > 0)// we only go down to 1, as layer 0 are the initial predicates provided to start the heuristic with, and have already been fulfilled
		{
			if (goal_node_layers[index].length > 0)// just to guarantee that we only do this action expansion on a layer that needs something satisfied
			{
				/*Utilities.WriteToFile("temp.json", "------------------", true);
				for (layer in goal_node_layers)
				{
					Utilities.WriteToFile("temp.json", "\n"+layer, true);
				}
				Utilities.WriteToFile("temp.json", "\n------------------------\n\n", true);*/
				
				var goal_node_checking_state:StateHeuristic = new StateHeuristic();
				var s_h_n:HeuristicNode = state_list[index - 1]; // index - 1 since we need to use actions from the previous layer
				for (action_node in s_h_n.actions_applied_to_state)
				{
					//grab the predicates that are needed
					var heuristic_data_for_looking:HeuristicData = new HeuristicData();
					action_node.Set();
					action_node.action.HeuristicExecute(heuristic_data_for_looking, s_h_n.state, domain);
					
					//need to apply the predicates to the state
					for (i in heuristic_data_for_looking.predicates.keys())
					{
						goal_node_checking_state.AddRelation(i);
					}
					
					var original_function_values:Map<String, Pair<Int, Int>> = new Map<String, Pair<Int, Int>>();
					
					//need to apply the functions to the state
					for (i in heuristic_data_for_looking.function_changes)
					{
						original_function_values.set(i.name, goal_node_checking_state.GetFunctionBounds(i.name));
						goal_node_checking_state.SetFunctionBounds(i.name, i.bounds);
					}
					
					if (!concrete_actions.exists(action_node))// only run on this action if it has not been added to the list
					{
						var goal_nodes_to_remove:Array<TreeNode> = new Array<TreeNode>();
						var satisfied_a_goal_node:Bool = false;
						// now lets check to see if any of the predicates we are looking for were satisfied
						for (goal_node in goal_node_layers[index])
						{
							if (goal_node.HeuristicEvaluate(null, null, goal_node_checking_state, domain))
							{
								// we found a successful satisfaction due to this action
								goal_nodes_to_remove.push(goal_node); //lets add it to a list for safe removal
								
								satisfied_a_goal_node = true;
							}
							else if (Std.is(goal_node, TreeNodeInt))
							{
								
								// check to see if the bounds are closer
								var tree_node_int_goal:TreeNodeInt = cast(goal_node, TreeNodeInt);
								var funcs:Array<String> = tree_node_int_goal.GetFunctionNames();
								
								var goal_node_bounds:Pair<Int, Int> = tree_node_int_goal.GetHeuristicBounds(action_node.action.GetData(), null, goal_node_checking_state, domain);
								
								var function_is_closer:Bool = false;
								
								for (func in funcs)
								{							// check if the new function upper bound is closer to the goal states lower bound than the original upper bound
									function_is_closer = 	((goal_node_bounds.a - original_function_values.get(func).b > goal_node_bounds.a - goal_node_checking_state.GetFunctionBounds(func).b) ||
									
															// check if the new function lower bound is closer to the goal states upper bound than the original lower bound
															(goal_node_bounds.b - original_function_values.get(func).a < goal_node_bounds.b - goal_node_checking_state.GetFunctionBounds(func).a)) ||
															function_is_closer;
									
								}
								
								if (function_is_closer)
								{
									
									goal_nodes_to_remove.push(goal_node); //lets add it to a list for safe removal
									
									satisfied_a_goal_node = true;
								}
								
							}
						}
						
						if (satisfied_a_goal_node)
						{
							//lets find any and all preconditions of this action that need satisfying and add them to the goal list
							var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(action_node.action.GetPreconditionTree().GetBaseNode());
							
							//Utilities.WriteToFile("temp.json", ""+action_node.GetActionTransform()+"\n"+ goal_nodes_to_remove + "\n", true);
							
							for (node in action_precondition_nodes_to_add)
							{
								// an array since a for loop can return many nodes when asked for a concrete version
								var concrete_nodes:Array<TreeNode> = node.GenerateConcrete(action_node.action.GetData(), s_h_n.state, domain);
								//Utilities.WriteToFile("temp.json", ""+concrete_nodes + "\n", true);
								for (node in concrete_nodes)
								{
									AddGoalNodeToLayers(node, state_list, goal_node_layers);
								}
							}
							//Utilities.WriteToFile("temp.json", "\n", true);
							// lets also record this action node
							concrete_actions.set(action_node, true);
							concrete_actions_count++;
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
		
		/*Utilities.WriteToFile("temp.json", "------------------", true);
		for (layer in goal_node_layers)
		{
			Utilities.WriteToFile("temp.json", "\n"+layer, true);
		}
		Utilities.WriteToFile("temp.json", "\n------------------------\n\n", true);*/
		
		trace(concrete_actions_count);
		//throw "";
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
	function AddGoalNodeToLayers(goal_node_:TreeNode, state_list_:Array<HeuristicNode>, layers_:Array<Array<TreeNode>>)
	{
		var earliest_index:Int = 0;
		for (index in 0...layers_.length)
		{
			var s_h_n:HeuristicNode = state_list_[index];
			if (goal_node_.HeuristicEvaluate(null, null, s_h_n.state, domain))
			{
				earliest_index = index;
				break;
			}
		}
		
		/*if (Utilities.Compare(goal_node_.toString(), "at_lander general waypoint0") == 0)
		{
			trace(earliest_index);
		}*/
		
		layers_[earliest_index].push(goal_node_);
	}
	
	function GetGoalNodes(node_:TreeNode):Array<TreeNode>
	{
		var goal_nodes:Array<TreeNode> = new Array<TreeNode>();
		Tree.RecursiveExplore(node_, function(node_)
		{
			if (Utilities.Compare(node_.GetRawName(), "not") == 0) // we want to ignore nots as i am not entirely sure how to handle them
			{
				return true;
			}
			
			else if (Utilities.Compare(node_.GetRawName(), "forall") == 0) // forall needs to be handled specifically as it owns its own tree and does different things
			{
				goal_nodes.push(node_);
				return true;
			}
			
			else if (Utilities.Compare(node_.GetRawName(), "imply") == 0) // imply is also a special case we need to handle
			{
				goal_nodes.push(node_);
				return true;
			}
			
			else if (Utilities.Compare(node_.GetRawName(), "or") == 0) // same again, only one of the children needs to be true, not all
			{
				goal_nodes.push(node_);
				return true;
			}
			else if (
			Utilities.Compare(node_.GetRawName(), "==") == 0 ||
			Utilities.Compare(node_.GetRawName(), "<") == 0 ||
			Utilities.Compare(node_.GetRawName(), "<=") == 0 ||
			Utilities.Compare(node_.GetRawName(), ">") == 0 ||
			Utilities.Compare(node_.GetRawName(), ">=") == 0
			) // same again, only one of the children needs to be true, not all
			{
				goal_nodes.push(node_);
				return true;
			}
			
			else if (domain.PredicateExists(node_.GetRawName())) // essentially all thats left to ignore is and's, meaning we need to catch predicates
			{
				goal_nodes.push(node_);
				return true;
			}
			
			// we do however, completely ignore TreeNodeInt branches currently, meaning the comparison operands are ignored. may need to change this,
			// although the numeric side of them are handled a different way with the heuristic
			
			return false;
		});
		
		//trace(goal_nodes);
		return goal_nodes;
	}
	
	/**
	 * Each HeuristicNode contains both the state, and the actions to be applied to that state.
	 * @param	current_node_
	 * @return Successor state
	 */
	static public function ApplyActions(current_node_:HeuristicNode, domain_:Domain):StateHeuristic
	{
		var new_state:StateHeuristic = new StateHeuristic();
		current_node_.state.CopyTo(new_state);
		
		//trace("action count: " + actions_.length);
		for (actionNode in current_node_.actions_applied_to_state)
		{
			actionNode.Set();
			//trace(actionNode.params + "\n" + actionNode.valuesType);
			actionNode.action.HeuristicExecute(current_node_.heuristic_data, new_state, domain_);
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