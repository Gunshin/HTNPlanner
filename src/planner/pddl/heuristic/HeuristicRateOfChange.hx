package planner.pddl.heuristic;

import haxe.ds.HashMap;
import planner.pddl.Planner;
import planner.pddl.planner.PlannerActionNode;

import de.polygonal.ds.Heap;

import planner.pddl.heuristic.HeuristicGoalChangesNode;

import planner.pddl.ActionData;
import planner.pddl.Pair;
import planner.pddl.Predicate;
import planner.pddl.StateHeuristic;
import planner.pddl.tree.TreeNodeForall;
import planner.pddl.tree.TreeNodeIntFunctionValue;
import planner.pddl.tree.TreeNodeIntMinus;

import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;
import planner.pddl.tree.TreeNodePredicate;
import planner.pddl.tree.TreeNodeInt;

/**
 * ...
 * @author Michael Stephens
 */
class HeuristicRateOfChange implements IHeuristic
{	
	var domain:Domain = null;
	var problem:Problem = null;

	public function new(domain_:Domain, problem_:Problem) 
	{
		domain = domain_;
		problem = problem_;
	}
	
	
	/*
	 * 
	 * generate state levels
	 * 		map specific actions to specific functions <- sm cp
	 * 
	 * extract plan
	 * 		forall goal nodes, extract specific functions
	 * 		get specific actions from functions and find the satisfying actions <- md cp? 1.
	 * 			treat satisfying actions as being able to be done multiple times? <- sm cp
	 * 				Therefor select largest?
	 * 				what if largest produces a larger heuristic value due to difference in layer?
	 * 				spend a lot of computation working out the best set? 2.
	 * 			
	 * 		extract precondition nodes of satisfying actions as new goal nodes
	 * 
	 * 1.
	 * could i cache functions at the node? would prevent a need to recurse lookup
	 * each parent would cache its childs
	 * when made concrete, should we make these caches concrete too?
	 * 
	 * 2.
	 * ??
	 * 
	 * We should select the smallest action that can be repeated twice due to the fact that a larger version of the action will
	 * always require at least one more action to allow it become a larger version. We should automatically discount increasing 
	 * actions that are not increasing every layer. If there is an action in layer 1 that increases 'x' by 10, and an action in layer 3 
	 * that increases it by '30', we should ignore the 30 because we cannot tell just how much that action is going to require
	 * to satisfy as it was not satisfied by the second layer.
	 * 
	 * Some thought to be made on ratio of size between the same actions. Should we only use this designation if the size difference
	 * is 2 or less? what happens when it is more than that? perhaps some testing could be done to determine how worthwhile it is dependent on the ratio?
	 * 
	 * 
	 * 
	 * 
	 */
	
	
	/**
	 * @param	initial_state_
	 * @return
	 */
	public function RunHeuristic(initial_state_:State):HeuristicResult
	{
		// should do this check to make sure we dont attempt to generate a heuristic on a satisfied state
		if (problem.EvaluateGoal(initial_state_))
		{
			return new HeuristicResult(null, 0);
		}
		
		//trace("init: " + initial_state_.toString());
		var heuristic_state:StateHeuristic = new StateHeuristic();
		initial_state_.CopyTo(heuristic_state);
		
		var manager_rof:ManagerRateOfChange = new ManagerRateOfChange();
		var action_predicate_mapping:Map<String, Array<Array<PlannerActionNode>>> = new Map<String, Array<Array<PlannerActionNode>>>();
		
		var state_list:Array<HeuristicNode> = GenerateStateLevels(heuristic_state, action_predicate_mapping, manager_rof);
		
		if (state_list == null)
		{
			return new HeuristicResult(null, 99999999);
		}
		
		/*trace("passed");
		throw "";*/
		//Utilities.WriteToFile("state_list.json", ""+state_list, false);
		
		//trace(depth);
		
		// now lets extract the relaxed plan
		var concrete_actions:Map<PlannerActionNode, Bool> = new Map<PlannerActionNode, Bool>();
		var ordered_concrete_actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		// first we need to grab all of the individual goal nodes
		var goal_nodes:Array<TreeNode> = GetGoalNodes(problem.GetGoalTree().GetBaseNode());
		
		// next lets set the goal nodes into the respective layers, so that we can traverse backwards
		// through the layers and check against anything enabled by such layer
		var goal_node_layers:Array<Array<TreeNode>> = new Array<Array<TreeNode>>();
		for (state_list_index in 0...state_list.length)
		{
			goal_node_layers[state_list_index] = new Array<TreeNode>();
		}
		
		for (goal_node in goal_nodes)
		{
			AddGoalNodeToLayers(goal_node.Clone(), state_list, goal_node_layers);
		}
		
		
	//	extract plan
		var goal_node_index:Int = goal_node_layers.length - 1;
		while (goal_node_index > 0)
		{
			var s_h_n:HeuristicNode = state_list[goal_node_index - 1]; // index - 1 since we need to use actions from the previous layer
			
			var cloned_state_level:StateHeuristic = new StateHeuristic();
			s_h_n.state.CopyTo(cloned_state_level);
			
			#if debugging_heuristic
			Utilities.Log("------------------");
			for (layer in goal_node_layers)
			{
				Utilities.Log("\n"+layer);
			}
			Utilities.Log("\n------------------------\n\n");
			#end
	// 		forall goal nodes, extract specific functions
			for (goal_node in goal_node_layers[goal_node_index])
			{
				#if debugging_heuristic
				Utilities.Logln("Goal node: " + goal_node.GetRawTreeString());
				#end
				
				if (goal_node.HeuristicEvaluate(null, null, cloned_state_level, domain))
				{
					continue;
				}
				
				if (Std.is(goal_node, TreeNodeInt))
				{
					var tree_node_int_goal:TreeNodeInt = cast(goal_node, TreeNodeInt);
					var before_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, null, null, cloned_state_level, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, null, null, cloned_state_level, domain));
					
					var goal_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, null, null, state_list[goal_node_index].state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, null, null, state_list[goal_node_index].state, domain));
					
					var a_a:Int = goal_values.a.a - before_values.a.a;
					var a_b:Int = goal_values.a.b - before_values.a.b;
					
					var b_a:Int = goal_values.b.a - before_values.b.a;
					var b_b:Int = goal_values.b.b - before_values.b.b;
					
					var best_actions:Array<FunctionRateOfChange> = new Array<FunctionRateOfChange>();
					
					// this means that the left side needs to decrease, therefor ask for the best negative action of the functions the left side has
					if (a_a < 0 || a_b > 0)
					{
						var functions:Array<String> = ExtractFunctions(goal_node.GetChildren()[0], domain);
						var r_o_c:Array<FunctionRateOfChange> = manager_rof.GetBest(functions, goal_node_index);
						for (action in r_o_c)
						{
							best_actions.push(action);
						}
						
						#if debugging_heuristic
						Utilities.Logln("Generated functions: " + functions + "\n");
						for (func_name in functions)
						{
							for (obj in manager_rof.GetAllFromFunction(func_name))
							{
								Utilities.Logln("Action: " + obj.action.GetActionTransform() + " function: " + obj.function_name + " :: rate: " + obj.rate_of_change + " _ depth: " + obj.state_level);
							}
						}
						#end
					}
					
					// this means that the right side needs to decrease, therefor ask for the best negative action of the functions the right side has
					if (b_a < 0 || b_b > 0)
					{
						var functions:Array<String> = ExtractFunctions(goal_node.GetChildren()[1], domain);
						var r_o_c:Array<FunctionRateOfChange> = manager_rof.GetBest(functions, goal_node_index);
						for (action in r_o_c)
						{
							best_actions.push(action);
						}
						
						#if debugging_heuristic
						Utilities.Logln("Generated functions: " + functions + "\n");
						for (func_name in functions)
						{
							for (obj in manager_rof.GetAllFromFunction(func_name))
							{
								Utilities.Logln("Action: " + obj.action.GetActionTransform() + " function: " + obj.function_name + " :: rate: " + obj.rate_of_change + " _ depth: " + obj.state_level);
							}
						}
						#end
					}
					
					#if debugging_heuristic
					Utilities.Logln("before: " + before_values);
					Utilities.Logln("goal: " + goal_values);
					Utilities.Logln("a_a: " + a_a);
					Utilities.Logln("a_b: " + a_b);
					Utilities.Logln("b_a: " + b_a);
					Utilities.Logln("b_b: " + b_b);
					Utilities.Logln("tree: " + tree_node_int_goal.GetRawTreeString());
					#end
					
					
					
					#if debugging_heuristic
					for (best_action in best_actions)
					{
						Utilities.Logln("Best: " + best_action.action.GetActionTransform() + " :: rate: " + best_action.rate_of_change + " _ depth: " + best_action.state_level);
					}
					#end
					
					
					
					// final set of actions that could be done, with the amount of repetitions needed
					var valid_actions:Array<Pair<Int, FunctionRateOfChange>> = new Array<Pair<Int, FunctionRateOfChange>>();
					for (roc in best_actions)
					{
						var goal_node_checking_state:StateHeuristic = new StateHeuristic();
						//grab the predicates that are needed
						var heuristic_data_for_looking:HeuristicData = new HeuristicData();
						roc.action.Set();
						roc.action.action.HeuristicExecute(heuristic_data_for_looking, cloned_state_level, domain);
						//need to apply the predicates to the state
						for (i in heuristic_data_for_looking.predicates.keys())
						{
							goal_node_checking_state.AddRelation(i);
						}
						
						//need to apply the functions to the state
						for (i in heuristic_data_for_looking.function_changes)
						{
							goal_node_checking_state.SetFunctionBounds(i.name, i.bounds);
						}
						
						var after_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, null, null, goal_node_checking_state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, null, null, goal_node_checking_state, domain));
						
						var function_is_closer:Bool = Heuristic.IsFunctionCloser(before_values, after_values, goal_values);
						
						var iteration_counter:Int = 0;
						// only do something if this action appears to have moved the goal node closer
						if (function_is_closer)
						{
							do
							{
								iteration_counter++;
								
								// if this goal_node is now satisfied, break out of the do while
								if (goal_node.HeuristicEvaluate(null, null, goal_node_checking_state, domain))
								{
									valid_actions.push(new Pair(iteration_counter, roc));
									break;
								}
								
								roc.action.action.HeuristicExecute(heuristic_data_for_looking, goal_node_checking_state, domain);
								//need to apply the predicates to the state
								for (i in heuristic_data_for_looking.predicates.keys())
								{
									goal_node_checking_state.AddRelation(i);
								}
								//need to apply the functions to the state
								for (i in heuristic_data_for_looking.function_changes)
								{
									goal_node_checking_state.SetFunctionBounds(i.name, i.bounds);
								}
								//clear it so that there is not an enormous amount of aditional elements from previous iterations, that are essentially useless
								heuristic_data_for_looking.function_changes = [];
								
								// need to recheck after every execution incase it suddenly stops moving towards the goal
								after_values = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, null, null, goal_node_checking_state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, null, null, goal_node_checking_state, domain));
								
								function_is_closer = Heuristic.IsFunctionCloser(before_values, after_values, goal_values);
							}
							while (function_is_closer);
						}
						
						#if debugging_heuristic
						Utilities.Logln("Test: " + roc.action.GetActionTransform() + " closer: " + function_is_closer);
						#end
					}
					#if debugging_heuristic
					for (valid in valid_actions)
					{
						Utilities.Logln("Final: " + valid.b.action.GetActionTransform() + " :: rate: " + valid.b.rate_of_change + " _ depth: " + valid.b.state_level + " iteration: " + valid.a);
					}
					#end
					
					var best:Pair<Int, FunctionRateOfChange> = SelectBestAction(valid_actions);trace(best);
					best.b.action.Set();
					
					var final_data:HeuristicData = new HeuristicData();
					best.b.action.action.HeuristicExecute(final_data, cloned_state_level, domain);
					for (i in final_data.predicates.keys())
					{
						cloned_state_level.AddRelation(i);
					}
					
					for (iter in 0...best.a)
					{
						for (i in final_data.function_changes)
						{
							cloned_state_level.SetFunctionBounds(i.name, i.bounds);
						}
					}
					//best.b.action.action.HeuristicExecute(new HeuristicData(), cloned_state_level, domain);
					
					var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(best.b.action.action.GetPreconditionTree().GetBaseNode());
					
					#if debugging_heuristic
					Utilities.Log("Adding: " + best.b.action.GetActionTransform() + "\n");
					#end
					
					for (action_precondition_node in action_precondition_nodes_to_add)
					{
						// an array since a for loop can return many nodes when asked for a concrete version
						var concrete_nodes:Array<TreeNode> = action_precondition_node.GenerateConcrete(best.b.action.action.GetData(), s_h_n.state, domain);
						
						#if debugging_heuristic
						Utilities.Log("" + concrete_nodes + "\n\n");
						#end
						
						for (concrete_node in concrete_nodes)
						{
							AddGoalNodeToLayers(concrete_node.Clone(), state_list, goal_node_layers);
						}
					}
					
					#if debugging_heuristic
					Utilities.Logln("");
					#end
					
					// since we have determined it is closer, we should add this action to the list
					
					for (it in 0...best.a)
					{
						concrete_actions.set(best.b.action, true);
						ordered_concrete_actions.push(best.b.action);
					}
					
				}
				else
				{
					
					var actions:Array<Array<PlannerActionNode>> = GetActionPredicateMappingArray(action_predicate_mapping, goal_node.GetRawTreeString());
					var predicate_index:Int = goal_node_index - 1; // -1 because predicates will always only be satisfied in the previous layer
					for (action_node in actions[predicate_index])
					{
						#if debugging_heuristic
						Utilities.Logln("Specific action: " + action_node.GetActionTransform());
						#end
						
						var goal_node_checking_state:StateHeuristic = new StateHeuristic();
						//grab the predicates that are needed
						var heuristic_data_for_looking:HeuristicData = new HeuristicData();
						
						action_node.Set();
						action_node.action.HeuristicExecute(heuristic_data_for_looking, s_h_n.state, domain);
						
						//need to apply the predicates to the state
						for (i in heuristic_data_for_looking.predicates.keys())
						{
							goal_node_checking_state.AddRelation(i);
						}
						
						//need to apply the functions to the state
						for (i in heuristic_data_for_looking.function_changes)
						{
							goal_node_checking_state.SetFunctionBounds(i.name, i.bounds);
						}
						
						if (goal_node.HeuristicEvaluate(null, null, goal_node_checking_state, domain))
						{
							
							// lets also record this action node. cannot break out of goal_nodes loop because one action may affect multiple goal_nodes. especially fluent nodes
							if (!concrete_actions.exists(action_node))
							{
								//lets find any and all preconditions of this action that need satisfying and add them to the goal list
								var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(action_node.action.GetPreconditionTree().GetBaseNode());
								
								for (node in action_precondition_nodes_to_add)
								{
									// an array since a for loop can return many nodes when asked for a concrete version
									var concrete_nodes:Array<TreeNode> = node.GenerateConcrete(action_node.action.GetData(), s_h_n.state, domain);
									
									#if debugging_heuristic
									Utilities.Log("" + concrete_nodes + "\n");
									#end
									
									for (concrete_node in concrete_nodes)
									{
										AddGoalNodeToLayers(concrete_node.Clone(), state_list, goal_node_layers);
									}
								}
								
								#if debugging_heuristic
								Utilities.Log("\n");
								#end
								
								concrete_actions.set(action_node, true);
								ordered_concrete_actions.push(action_node);
							}
						}
					}
					
				}
			}
			
			goal_node_layers[goal_node_index] = null;
			goal_node_index--;
		}
	// 		get specific actions from functions and find the satisfying actions <- md cp? 1.
	// 			treat satisfying actions as being able to be done multiple times? <- sm cp
	// 				Therefor select largest?
	// 				what if largest produces a larger heuristic value due to difference in layer?
	// 				spend a lot of computation working out the best set? 2.
	// 			
	// 		extract precondition nodes of satisfying actions as new goal nodes
		
		
		#if debugging_heuristic
		Utilities.Log("------------------");
		for (action in ordered_concrete_actions)
		{
			Utilities.Log("\n"+action.GetActionTransform());
		}
		Utilities.Log("\n------------------------\n\n");
		
		//Utilities.Logln(action_function_mapping.toString());
		#end
		
		//trace("length: " + ordered_concrete_actions.length);
		//throw "";
		return new HeuristicResult(ordered_concrete_actions, ordered_concrete_actions.length);
	}
	
	function GenerateStateLevels(
		heuristic_initial_state_:StateHeuristic,
		action_predicate_mapping_:Map<String, Array<Array<PlannerActionNode>>>,
		manager_rof:ManagerRateOfChange
	)
	:Array<HeuristicNode>
	{
		var current_node:HeuristicNode = new HeuristicNode(heuristic_initial_state_, Planner.GetAllActionsForState(heuristic_initial_state_, domain));
		var state_list:Array<HeuristicNode> = new Array<HeuristicNode>();
		state_list.push(current_node);
		
		#if debugging_heuristic
		Utilities.Log("Heuristic.RunHeuristic: ------------------\n");
		for (action in current_node.actions_applied_to_state)
		{
			Utilities.Log("Heuristic.RunHeuristic: " + action.GetActionTransform() + "\n");
		}
		for (goal_node in GetGoalNodes(problem.GetGoalTree().GetBaseNode()))
		{
			Utilities.Log("Heuristic.RunHeuristic: " + goal_node.HeuristicEvaluate(null, null, current_node.state, domain)+"\n");
		}
		
		Utilities.Log("Heuristic.RunHeuristic: " + current_node.state.toString()+"\n");
		Utilities.Log("Heuristic.RunHeuristic: " + "\n------------------------\n\n");
		#end
		
		// first generate the full graph to ensure we can fulfill the goal
		var depth:Int = 0;
		//trace("\n\n\n\n");
		
		while (!problem.HeuristicEvaluateGoal(current_node.state))
		{
			var successor_state:StateHeuristic = ApplyActions(current_node, action_predicate_mapping_, manager_rof, depth, domain);
			current_node = new HeuristicNode(successor_state, GetAllActionsForState(successor_state, domain));
			state_list.push(current_node);
			depth++;
			
			#if debugging_heuristic
			Utilities.Log("Heuristic.RunHeuristic: " + "------------------\n");
			for (action in current_node.actions_applied_to_state)
			{
				Utilities.Log("Heuristic.RunHeuristic: " + action.GetActionTransform() + "\n");
			}
			for (goal_node in GetGoalNodes(problem.GetGoalTree().GetBaseNode()))
			{
				Utilities.Log("Heuristic.RunHeuristic: " + goal_node.GetRawTreeString() + " :: " +goal_node.HeuristicEvaluate(null, null, current_node.state, domain)+"\n");
			}
			
			Utilities.Log("Heuristic.RunHeuristic: " + current_node.state.toString()+"\n");
			Utilities.Log("Heuristic.RunHeuristic: " + "\n------------------------\n\n");
			#end
			
			if (depth > 20)
			{
				var total_action_count:Int = 0;
				
				for (state in state_list)
				{
					total_action_count += state.actions_applied_to_state.length;
				}
				
				return null;
			}
		}
		
		return state_list;
	}
	
	static function SelectBestAction(array_:Array<Pair<Int, FunctionRateOfChange>>):Pair<Int, FunctionRateOfChange>
	{
		var best:Pair<Int, FunctionRateOfChange> = null;
		
		for (obj in array_)
		{
			if (best == null || best.b.state_level > obj.b.state_level || (obj.b.state_level == best.b.state_level && obj.a > best.a))
			{
				best = obj;
			}
		}
		
		return best;
		
	}
	
	static public function ExtractFunctions(goal_node_:TreeNode, domain_:Domain):Array<String>
	{
		var mapped_funcs:Map<String, Bool> = new Map<String, Bool>();
		Tree.Recursive(goal_node_, 
			function(node_)
			{
				if (domain_.FunctionExists(node_.GetRawName()))
				{
					mapped_funcs.set(node_.GetRawTreeString(), true);
					return true;
				}
				return true;
			}
		);
		
		var returnee:Array<String> = new Array<String>();
		for (key in mapped_funcs.keys())
		{
			returnee.push(key);
		}
		
		return returnee;
	}
	
	static public function AddNegationToGoalNodesChild(goal_node_:TreeNode, amount_:Int, child_index_:Int)
	{
		var target_child:TreeNode = goal_node_.GetChildren()[child_index_];
		goal_node_.GetChildren().remove(target_child);
		
		var negation:TreeNodeIntMinus = new TreeNodeIntMinus();
		goal_node_.GetChildren().insert(child_index_, negation);

		negation.AddChild(target_child);
		negation.AddChild(new TreeNodeIntFunctionValue(Std.string(amount_)));
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
		var earliest_index:Int = GetEarliestIndexGoalNodeCanBeAddedTo(goal_node_, state_list_);
		
		#if debugging_heuristic
		Utilities.Logln("goal node added to: " + goal_node_.GetRawTreeString() + " :: " + earliest_index);
		#end
		
		layers_[earliest_index].push(goal_node_);
	}
	
	function GetEarliestIndexGoalNodeCanBeAddedTo(goal_node_:TreeNode, state_list_:Array<HeuristicNode>):Int
	{
		for (index in 0...state_list_.length)
		{
			var s_h_n:HeuristicNode = state_list_[index];
			if (goal_node_.HeuristicEvaluate(null, null, s_h_n.state, domain))
			{
				return index;
			}
		}
		
		throw "Error: no index found for goal node: " + goal_node_;
	}
	
	function GetGoalNodes(node_:TreeNode):Array<TreeNode>
	{
		var goal_nodes:Array<TreeNode> = new Array<TreeNode>();
		Tree.RecursiveExplore(node_, function(node_)
		{
			if (Utilities.Compare(node_.GetRawName(), "not") == 0) // we want to ignore nots as i am not entirely sure how to handle them
			{
				return false;
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
	static public function ApplyActions(
		current_node_:HeuristicNode,
		action_predicate_mapping_:Map<String, Array<Array<PlannerActionNode>>>,
		manager_rof:ManagerRateOfChange,
		depth_:Int,
		domain_:Domain
	):StateHeuristic
	{
		var converted_state:StateHeuristic = new StateHeuristic();
		current_node_.state.StateHeuristicCopyTo(converted_state);
		
		var new_state:StateHeuristic = new StateHeuristic();
		converted_state.StateHeuristicCopyTo(new_state);
		
		//trace("action count: " + actions_.length);
		for (data_node in current_node_.heuristic_data)
		{
			data_node.a.Set();
			data_node.a.action.HeuristicExecute(data_node.b, new_state, domain_);
		}
		
		for (data_node in current_node_.heuristic_data)
		{
			for (function_change in data_node.b.function_changes)
			{
				//Utilities.Log("Heuristic.ApplyActions: setting function: " + i.name + " ____ " + i.bounds + "\n");
				var original_function_bounds:Pair<Int, Int> = converted_state.GetFunctionBounds(function_change.name);
				if (!function_change.bounds.Equals(original_function_bounds))
				{
					var function_change_bounds:Int = function_change.bounds.a - original_function_bounds.a != 0 ?
							function_change.bounds.a - original_function_bounds.a :
							function_change.bounds.b - original_function_bounds.b;
					
					manager_rof.AddRateOfChange(new FunctionRateOfChange(function_change.name, function_change_bounds, depth_, data_node.a));
					
				}
				new_state.SetFunctionBounds(function_change.name, function_change.bounds);
			}
		}
		
		manager_rof.Calculate();
		
		for (data_node in current_node_.heuristic_data)
		{
			for (predicate_key in data_node.b.predicates.keys())
			{
				new_state.AddRelation(predicate_key);
				var mapping_array:Array<Array<PlannerActionNode>> = GetActionPredicateMappingArray(action_predicate_mapping_, predicate_key);
				if (mapping_array[depth_] == null)
				{
					mapping_array[depth_] = new Array<PlannerActionNode>();
				}
				
				mapping_array[depth_].push(data_node.a);
			}
		}
		
		return new_state;
	}
	
	static public function GetAllActionsForState(state_:StateHeuristic, domain_:Domain):Array<PlannerActionNode>
	{
		var actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		for (actionName in domain_.GetAllActionNames())
		{
			var action:Action = domain_.GetAction(actionName);
			var parameter_combinations:Array<Array<Pair<String, String>>> = Planner.GetAllPossibleParameterCombinations(action, state_, domain_);
			// has an extra array since these combinations are used per parameter combination
			var value_combinations:Array<Array<Array<Pair<String, String>>>> = GetAllPossibleMinMaxValueCombinations(action, parameter_combinations, state_, domain_, true);
			//Utilities.Log("Heuristic.GetAllActionsForState: " + action.GetName() + " :: " + value_combinations + "\n");
			for (param_index in 0...parameter_combinations.length)
			{
				var param_combination:Array<Pair<String, String>> = parameter_combinations[param_index];
				action.GetData().SetParameters(param_combination);
				if (value_combinations[param_index].length > 0)
				{
					
					for (val_combination in value_combinations[param_index])
					{
						action.GetData().SetValues(val_combination);
						//Utilities.Log("Heuristic.GetAllActionsForState: " + action.HeuristicEvaluate(null, state_, domain_) + " : " + action.GetPreconditionTree().GetBaseNode().GetRawTreeString() + "\n");
						if (action.HeuristicEvaluate(null, state_, domain_))
						{
							actions.push(new PlannerActionNode(action, param_combination, val_combination));
							//Utilities.Log("Heuristic.GetAllActionsForState: " + actions[actions.length - 1].GetActionTransform() + "\n");
						}
					}
				}
				else
				{
					/*Utilities.Log("Heuristic.GetAllActionsForState: " + action.HeuristicEvaluate(null, state_, domain_) + "\n");
					for (child in action.GetPreconditionTree().GetBaseNode().GetChildren())
					{
						Utilities.Log("Heuristic.GetAllActionsForState: ----------- " + child.GetRawTreeString() + " : " + child.HeuristicEvaluate(action.GetData(), null, state_, domain_) + "\n");
					}*/
					if (action.HeuristicEvaluate(null, state_, domain_))
					{
						actions.push(new PlannerActionNode(action, param_combination, null));
						//Utilities.Log("Heuristic.GetAllActionsForState: ADDING NON VALUE: " + actions[actions.length - 1].GetActionTransform() + "\n");
					}
				}
			}
		}
		
		//Utilities.Log(actions + "\n");
		return actions;
	}

	static public function GetAllPossibleMinMaxValueCombinations(
		action_:Action,
		parameter_combinations_:Array<Array<Pair<String, String>>>,
		state_:State,
		domain_:Domain,
		heuristic_version_:Bool
	)
	:Array<Array<Array<Pair<String, String>>>>
	{
		//Utilities.Log("Planner.GetAllPossibleValueCombinations: " + action_+"\n");
		var returnee:Array<Array<Array<Pair<String, String>>>> = new Array<Array<Array<Pair<String, String>>>>();
		
		for (combination in parameter_combinations_)
		{
			action_.GetData().SetParameters(combination);
			
			var value_ranges:Array<Array<Pair<String, String>>> = new Array<Array<Pair<String, String>>>();
			
			var actionValues:Array<Value> = action_.GetData().GetValues();
			if (actionValues.length > 0)
			{
				for (valueIndex in 0...actionValues.length)
				{
					var obj_array:Array<Pair<String, String>> = new Array<Pair<String, String>>();
					var possible_values:Array<String> = actionValues[valueIndex].GetPossibleValues(action_.GetData(), state_, domain_, heuristic_version_, true, 0.3);
					if (possible_values.length > 1)
					{
					//trace(possible_values);
					//throw "";
					}
					if (possible_values.length > 0)
					{
						obj_array.push(new Pair(actionValues[valueIndex].GetName(), possible_values[0]));
						
						// we dont want to add the same pair twice if the possible_values only contains one element
						if (possible_values.length > 1)
						{
							obj_array.push(new Pair(actionValues[valueIndex].GetName(), possible_values[possible_values.length - 1]));
						}
					}
					value_ranges.push(obj_array);
				}
				
				returnee.push(Planner.GenerateCombinations(value_ranges));
			}
			else
			{
				returnee.push(new Array<Array<Pair<String, String>>>()); // just push an empty array, since we want this to succeed
			}
		}
		return returnee;
	}
	
	
	/**
	 * Ease of use function
	 * @param	function_name_
	 * @return
	 */
	static function GetActionFunctionMapping(action_function_map_:Map<String, Map<String, Array<FunctionRateOfChange>>>, function_name_:String):Map<String, Array<FunctionRateOfChange>>
	{
		var functions_map:Map<String, Array<FunctionRateOfChange>> = action_function_map_.get(function_name_);
		
		if (functions_map == null)
		{
			functions_map = new Map<String, Array<FunctionRateOfChange>>();
			action_function_map_.set(function_name_, functions_map);
		}
		
		return functions_map;
	}
	
	/**
	 * Ease of use function
	 * @param	function_name_
	 * @return
	 */
	static function GetActionPredicateMappingArray(action_predicate_map_:Map<String, Array<Array<PlannerActionNode>>>, predicate_name_:String):Array<Array<PlannerActionNode>>
	{
		var array:Array<Array<PlannerActionNode>> = action_predicate_map_.get(predicate_name_);
		
		if (array == null)
		{
			array = new Array<Array<PlannerActionNode>>();
			action_predicate_map_.set(predicate_name_, array);
		}
		
		return array;
	}
	
}