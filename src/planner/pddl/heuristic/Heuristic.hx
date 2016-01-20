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
		
		var state_list:Array<HeuristicNode> = GenerateStateLevels(heuristic_state);
		
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
		
		
		// now that things have been set into layers, the idea is that we traverse backwards through the layers findiong actions that provide the effects needed
		// in the next goal_node_layers.
		var state_list_index:Int = state_list.length - 1;
		while(state_list_index > 0)// we only go down to 1, as layer 0 are the initial predicates provided to start the heuristic with, and have already been fulfilled
		{
			if (goal_node_layers[state_list_index].length > 0)// just to guarantee that we only do this action expansion on a layer that needs something satisfied
			{
				#if debugging_heuristic
				Utilities.Log("------------------");
				for (layer in goal_node_layers)
				{
					Utilities.Log("\n"+layer);
				}
				Utilities.Log("\n------------------------\n\n");
				
				/*Utilities.Log("@@@@@@@@@@@@@@@@@@@@@@@@@@");
				for (action in state_list[state_list_index - 1].actions_applied_to_state)
				{
					Utilities.Log("\n"+action.GetActionTransform());
				}
				Utilities.Log("\n@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n");*/
				#end
				
				var goal_node_function_changes:Map<TreeNodeInt, Heap<HeuristicGoalChangesNode>> = new Map<TreeNodeInt, Heap<HeuristicGoalChangesNode>>();
				
				var s_h_n:HeuristicNode = state_list[state_list_index - 1]; // index - 1 since we need to use actions from the previous layer
				for (action_node in s_h_n.actions_applied_to_state)
				{
					
					if (!concrete_actions.exists(action_node))// only run on this action if it has not been added to the list
					{
						
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
						//var original_function_values:Map<String, Pair<Int, Int>> = new Map<String, Pair<Int, Int>>();
						
						//need to apply the functions to the state
						for (i in heuristic_data_for_looking.function_changes)
						{
							//original_function_values.set(i.name, s_h_n.state.GetFunctionBounds(i.name));
							goal_node_checking_state.SetFunctionBounds(i.name, i.bounds);
						}
						
						//Utilities.Log("action: " + action_node.GetActionTransform() + "\n");
						//Utilities.Log("funcs original: " + original_function_values + "\n");
						//Utilities.Log("funcs changes: " + heuristic_data_for_looking.function_changes + "\n");
						
						var goal_nodes_to_remove:Array<TreeNode> = new Array<TreeNode>();
						
						// now lets check to see if any of the predicates we are looking for were satisfied
						var escape:Bool = false;
						for (goal_node in goal_node_layers[state_list_index])
						{
							if (Std.is(goal_node, TreeNodeInt))
							{
								// check to see if the bounds are closer
								var tree_node_int_goal:TreeNodeInt = cast(goal_node, TreeNodeInt);
								
								#if debugging_heuristic
								//Utilities.Logln(action_node.GetActionTransform());
								#end
								
								var before_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, action_node.action.GetData(), null, s_h_n.state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, action_node.action.GetData(), null, s_h_n.state, domain));
								
								var after_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, action_node.action.GetData(), null, goal_node_checking_state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, action_node.action.GetData(), null, goal_node_checking_state, domain));
								
								
								// since goal_node_checking_state is a subset of state_list[state_list_index], we must compare the values against the full state goal evaluation
								var goal_values:Pair<Pair<Int, Int>, Pair<Int, Int>> = new Pair(
									tree_node_int_goal.HeuristicGetValueFromChild(0, action_node.action.GetData(), null, state_list[state_list_index].state, domain),
									tree_node_int_goal.HeuristicGetValueFromChild(1, action_node.action.GetData(), null, state_list[state_list_index].state, domain));
								
								var function_is_closer:Bool = 	(((after_values.b.a - before_values.b.a) < 0) && ((goal_values.a.a - before_values.b.a) < 0)) ||
																(((after_values.b.b - before_values.b.b) > 0) && ((goal_values.a.b - before_values.b.b) > 0)) ||
																(((after_values.a.a - before_values.a.a) < 0) && ((goal_values.b.a - before_values.a.a) < 0)) ||
																(((after_values.a.b - before_values.a.b) > 0) && ((goal_values.b.b - before_values.a.b) > 0));
								
								#if debugging_heuristic
								if (function_is_closer)
								{
									Utilities.Logln(action_node.GetActionTransform() + " :: " + tree_node_int_goal.GetRawTreeString());
									Utilities.Logln(goal_values + " :: " + before_values + " :: " + after_values + " : " + function_is_closer);
								}
								#end
								
								//trace(goal_node);
								if (function_is_closer)
								{
									
									var heap:Heap<HeuristicGoalChangesNode> = goal_node_function_changes.get(tree_node_int_goal);
									
									if (heap == null)
									{
										heap = new Heap<HeuristicGoalChangesNode>();
										goal_node_function_changes.set(tree_node_int_goal, heap);
									}
									
									var changed_amount:Float = 	Math.abs(after_values.a.b - before_values.a.b) +
																Math.abs(after_values.b.a - before_values.b.a) +
																Math.abs(after_values.a.a - before_values.a.a) +
																Math.abs(after_values.b.b - before_values.b.b);
									
									heap.add(new HeuristicGoalChangesNode(action_node, cast(changed_amount, Int), before_values, after_values, goal_values, goal_node_checking_state));
									
									// leave this goal node loop since this action has just been added
									escape = true;
								}
							}
							else if (goal_node.HeuristicEvaluate(null, null, goal_node_checking_state, domain))
							{
								// we found a successful satisfaction due to this action
								goal_nodes_to_remove.push(goal_node); //lets add it to a list for safe removal
								
								// lets also record this action node. cannot break out of goal_nodes loop because one action may affect multiple goal_nodes. especially fluent nodes
								if (!concrete_actions.exists(action_node))
								{
									//lets find any and all preconditions of this action that need satisfying and add them to the goal list
									var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(action_node.action.GetPreconditionTree().GetBaseNode());
									
									#if debugging_heuristic
									Utilities.Log("predicates: " + action_node.GetActionTransform() + "\n removing: " + goal_nodes_to_remove + "\n");
									#end
									
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
							
							if (escape)
							{
								break;
							}
						}
						
						// safely remove the goal nodes so we do not attempt them again
						for (goal_node in goal_nodes_to_remove)
						{
							goal_node_layers[state_list_index].remove(goal_node);
						}
						
					}
				}
				
				//Utilities.Logln(goal_node_function_changes.toString());
				
				for (goal_node in goal_node_function_changes.keys())
				{
					var heap:Heap<HeuristicGoalChangesNode> = goal_node_function_changes.get(goal_node);
					
					#if debugging_heuristic
					Utilities.Logln("heap: " + heap.toString());
					#end
					
					var stop:Bool = false;
					while(heap.size() > 0 && !stop)
					{
						var node:HeuristicGoalChangesNode = heap.pop();
						
						if (!concrete_actions.exists(node.action_node))
						{
							node.action_node.Set();
							var action_precondition_nodes_to_add:Array<TreeNode> = GetGoalNodes(node.action_node.action.GetPreconditionTree().GetBaseNode());
							
							#if debugging_heuristic
							Utilities.Log("Adding: " + node.action_node.GetActionTransform() + "\n");
							#end
							
							for (action_precondition_node in action_precondition_nodes_to_add)
							{
								// an array since a for loop can return many nodes when asked for a concrete version
								var concrete_nodes:Array<TreeNode> = action_precondition_node.GenerateConcrete(node.action_node.action.GetData(), s_h_n.state, domain);
								
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
							
							concrete_actions.set(node.action_node, true);
							ordered_concrete_actions.push(node.action_node);
						}
						
						// since we have run this section of code, we need to remove the changes from the node itself
						if (goal_node.GetRawName().charAt(0) == ">")
						{
							if (node.after_values.a.b - node.before_values.a.b > 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.a.b - node.before_values.a.b, 1);
							}
							if (node.after_values.b.a - node.before_values.b.a < 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.b.a - node.before_values.b.a, 0);
							}
						}
						else if (goal_node.GetRawName().charAt(0) == "<")
						{
							if (node.after_values.a.a - node.before_values.a.a < 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.a.a - node.before_values.a.a, 1);
							}
							if (node.after_values.b.b - node.before_values.b.b > 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.b.b - node.before_values.b.b, 0);
							}
						}
						else
						{
							if (node.after_values.a.b - node.before_values.a.b > 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.a.b - node.before_values.a.b, 1);
							}
							if (node.after_values.b.a - node.before_values.b.a < 0)
							{
								AddNegationToGoalNodesChild(goal_node, node.after_values.b.a - node.before_values.b.a, 0);
							}
							throw "i have not verified if equivalence in the heuristic works yet!";
						}
						
						// check if we can now add this goal node to an earlier state than the one we are on
						if (GetEarliestIndexGoalNodeCanBeAddedTo(goal_node, state_list) < state_list_index)
						{
							// if we can we want to fall out of
							stop = true;
						}
						
						// since the function is closer, we may want to see if the goal is now satisfied
					}
					
					AddGoalNodeToLayers(goal_node, state_list, goal_node_layers);
				}
				
				
				
			}
			/*Utilities.Log("\n\n\n\n\n\n" + goal_node_layers + "\n\n\n\n\n\n");
			for (goal in goal_node_layers[state_list_index])
			{
				trace(state_list_index + " ___ " + goal);
				AddGoalNodeToLayers(goal.Clone(), state_list, goal_node_layers);
			}*/
			goal_node_layers[state_list_index] = null;
			
			state_list_index--;
		}
		
		#if debugging_heuristic
		Utilities.Log("------------------");
		for (action in ordered_concrete_actions)
		{
			Utilities.Log("\n"+action.GetActionTransform());
		}
		Utilities.Log("\n------------------------\n\n");
		#end
		
		//trace("length: " + ordered_concrete_actions.length);
		//throw "";
		return new HeuristicResult(ordered_concrete_actions, ordered_concrete_actions.length);
	}
	
	function GenerateStateLevels(heuristic_initial_state_:StateHeuristic):Array<HeuristicNode>
	{
		
		var current_node:HeuristicNode = new HeuristicNode(heuristic_initial_state_, Planner.GetAllActionsForState(heuristic_initial_state_, domain), new HeuristicData());
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
			var successor_state:StateHeuristic = ApplyActions(current_node, domain);
			current_node = new HeuristicNode(successor_state, GetAllActionsForState(successor_state, domain), new HeuristicData());
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
				
				//trace("returning with no heuristic found: " + (total_action_count * 20));
				//throw "";
			}
		}
		
		return state_list;
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
	static public function ApplyActions(current_node_:HeuristicNode, domain_:Domain):StateHeuristic
	{
		var new_state:StateHeuristic = new StateHeuristic();
		current_node_.state.StateHeuristicCopyTo(new_state);
		
		//trace("action count: " + actions_.length);
		for (actionNode in current_node_.actions_applied_to_state)
		{
			actionNode.Set();
			actionNode.action.HeuristicExecute(current_node_.heuristic_data, new_state, domain_);
		}
		
		for (i in current_node_.heuristic_data.function_changes)
		{
			//Utilities.Log("Heuristic.ApplyActions: setting function: " + i.name + " ____ " + i.bounds + "\n");
			new_state.SetFunctionBounds(i.name, i.bounds);
		}
		
		for (i in current_node_.heuristic_data.predicates.keys())
		{
			new_state.AddRelation(i);
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

	static public function GetAllPossibleMinMaxValueCombinations(action_:Action, parameter_combinations_:Array<Array<Pair<String, String>>>, state_:State, domain_:Domain, heuristic_version_:Bool):Array<Array<Array<Pair<String, String>>>>
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
					var possible_values:Array<String> = actionValues[valueIndex].GetPossibleValues(action_.GetData(), state_, domain_, heuristic_version_);
					
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
	
}