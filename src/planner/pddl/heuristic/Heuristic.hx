package planner.pddl.heuristic;

import planner.pddl.Planner.ValuesType;
import planner.pddl.StateHeuristic;

import planner.pddl.tree.Tree;
import planner.pddl.tree.TreeNode;

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
	 * get all applicable actions
	 * apply applicable actions
	 * 
	 * @param	initial_state_
	 * @return
	 */
	public function RunHeuristic(initial_state_:State):Int
	{
		//trace("init: " + initial_state_.toString());
		var heuristic_state:StateHeuristic = new StateHeuristic();
		initial_state_.CopyTo(heuristic_state);
		var current_node:HeuristicNode = new HeuristicNode(heuristic_state, GetAllActionsForState(heuristic_state), new HeuristicData());
		
		var state_list:Array<HeuristicNode> = new Array<HeuristicNode>();
		state_list.push(current_node);
		
		// first generate the full graph to ensure we can fulfill the goal
		var depth:Int = 0;
		
		while (!problem.HeuristicEvaluateGoal(current_node.state))
		{
			var successor_state:StateHeuristic = ApplyActions(current_node);
			current_node = new HeuristicNode(successor_state, GetAllActionsForState(successor_state), new HeuristicData());
			state_list.push(current_node);
			
			depth++;
			
			if (depth > 30)
			{
				return depth;
			}
		}
		
		// now lets extract the relaxed plan
		var action_count:Int = 0;
		
		// first we need to grab all of the individual goal nodes
		var goal_nodes:Array<TreeNode> = new Array<TreeNode>();
		Tree.RecursiveExplore(problem.GetGoalTree().GetBaseNode(), function(node_)
		{
			if (domain.GetPredicate(node_.GetRawName()) != null)
			{
				goal_nodes.push(node_);
				return true;
			}
			
			return false;
		});
		//trace(state_list);
		var completed_nodes:Array<TreeNode> = new Array<TreeNode>();
		while (goal_nodes.length > 0)
		{
			var current_goal_node:TreeNode = goal_nodes.pop();
			//var earliest_state:StateHeuristic = state_list[state_list.length - 1]; // set it to the last one as default
			var earliest_index:Int = state_list.length - 1;
			for (index in (state_list.length - 1)...0)
			{
				var s_h_n:HeuristicNode = state_list[index];
				trace((s_h_n != null) + " _ " /*+ (s_h_n.state != null) + " _ " + s_h_n.actions_applied_to_state*/);
				if (current_goal_node.HeuristicEvaluate(null, null, s_h_n.state, domain))
				{
					earliest_index = index;
				}
				else // since we have hit the point that the goal is no longer satisfied, exit the for loop
				{
					break;
				}
			}
			action_count += earliest_index;
		}		
		
		return action_count;
	}
	
	function ApplyActions(current_node_:HeuristicNode):StateHeuristic
	{
		var new_state:StateHeuristic = new StateHeuristic();
		current_node_.state.CopyTo(new_state);
		
		//trace("action count: " + actions_.length);
		for (actionNode in current_node_.actions_applied_to_state)
		{			
			actionNode.action.GetData().Set(actionNode.params, actionNode.valuesType);			
			actionNode.action.HeuristicExecute(current_node_.heuristic_data, new_state, domain);
		}
		
		for (i in current_node_.heuristic_data.function_changes)
		{
			new_state.SetFunctionBounds(i.name, i.bounds);
		}
		
		return new_state;
	}
	
	function GetAllActionsForState(state_:StateHeuristic):Array<PlannerActionNode>
	{
		var actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		for (actionName in domain.GetAllActionNames())
		{
			var action:Action = domain.GetAction(actionName);
			
			var combinations_result:Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>> = GetAllPossibleParameterCombinations(action, state_, domain);
			
			for (combination in combinations_result.b)
			{
				action.GetData().Set(combination, combinations_result.a);
				if (action.HeuristicEvaluate(null, state_, domain))
				{
					actions.push(new PlannerActionNode(action, combination, combinations_result.a));
				}
			}
			
		}
		
		return actions;
	}
	
	static public function GetAllPossibleParameterCombinations(action_:Action, initial_state_:State, domain_:Domain):Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>>
	{
		/*
		 * This pair represents two slightly seperate things.
		 * The first value: Array<ValuesType> is the type layout for the tuple containing pairs for the second argument.
		 * The second value: Array<Array<Pair<String, String>>> Is essentialy an array of tuples, with each element of the tuple being a pair
		 * which contains the name and value associated with that name. The name is required so that the action knows which parameter needs the value.
		 */
		var returnee:Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>> = 
			new Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>>(new Array<ValuesType>(), new Array<Array<Pair<String, String>>>());
		
		var raw_values:Array<Array<Pair<String, String>>> = new Array<Array<Pair<String, String>>>();
		var values_index:Array<Int> = new Array<Int>();
		
		// first lets populate the raw_values array with everything we need
		
		var actionParams:Array<Parameter> = action_.GetData().GetParameters();
		for (paramIndex in 0...actionParams.length)
		{
			// lets record the fact that the first so many raw values are of the param type
			returnee.a.push(ValuesType.EParam);
			
			var obj_array:Array<Pair<String, String>> = new Array<Pair<String, String>>();
			for (obj in initial_state_.GetObjectsOfType(actionParams[paramIndex].GetType()))
			{
				obj_array.push(new Pair(actionParams[paramIndex].GetName(), obj));
			}
			
			raw_values.push(obj_array);
			values_index.push(0);
		}
		
		var actionValues:Array<Value> = action_.GetData().GetValues();
		for (valueIndex in 0...actionValues.length)
		{
			// now lets record that these are values
			returnee.a.push(ValuesType.EValue);
			
			var obj_array:Array<Pair<String, String>> = new Array<Pair<String, String>>();
			for (obj in actionValues[valueIndex].GetPossibleValues(initial_state_, domain_))
			{
				obj_array.push(new Pair(actionValues[valueIndex].GetName(), obj));
			}
			
			raw_values.push(obj_array);
			values_index.push(0);
		}
		
		// since we have now finished populating the array, lets generate the sets correctly
		
		// this condition checks the last element in the index array to the last element in the raw values array
		// we do this because we are counting up in a left to right manner eg.
		// 000, 100, 200, 300, 400, 500, 600, 700, 800, 900, 010, 110, 210, 310, etc. etc.
		// if the last digit is equal to the end of the last elements length, we know that we have finished brute forcing the combinations.
		while (values_index[raw_values.length - 1] != raw_values[raw_values.length - 1].length)
		{
			// add the current index values to the set and store it
			var values_set:Array<Pair<String, String>> = new Array<Pair<String, String>>();
			for (i in 0...raw_values.length)
			{
				values_set.push(raw_values[i][values_index[i]]);
			}
			
			returnee.b.push(values_set);
			
			for (i in 0...values_index.length)
			{
				values_index[i]++;
				if (values_index[i] != raw_values[i].length) // if this value has not hit the limit, do not increase any futher values
				{
					break;
				}
				
				// since it passed the above, it did hit the limit, so reset to 0
				if (i != values_index.length - 1) // we also need to make sure we dont reset the most significant. if we do, we enter a forever loop
				{
					values_index[i] = 0;
				}
			}
			
		}
		
		
		return returnee;
	}
}