package planner.pddl;

import de.polygonal.ds.Heap;
import haxe.ds.HashMap;
import planner.pddl.heuristic.Heuristic;
import planner.pddl.Action;
import planner.pddl.Domain;
import planner.pddl.Pair;

/**
 * ...
 * @author Michael Stephens
 */
class Planner
{
	var closedStates:Map<Int, PlannerNode> = new Map<Int, PlannerNode>();
	
	var domain:Domain = null;
	var problem:Problem = null;
	
	var heuristic:Heuristic = null;
	
	var hasMetric:Bool = false;
	
	public function new() 
	{
		
	}
	
	#if debug_output
	var iteration:Int = 0;
	#end
	
	var current_lowest_total_cost_seen:Int = 99999999;
	
	public function FindPlan(domain_:Domain, problem_:Problem, use_heuristic_:Bool):Array<PlannerActionNode>
	{
		domain = domain_;
		problem = problem_;
		
		if (use_heuristic_)
		{
			heuristic = new Heuristic(domain, problem);
		}
		
		hasMetric = problem.HasProperty("metric");
		
		var currentState:PlannerNode = new PlannerNode(problem_.GetClonedInitialState(), null, null, 0, 0);
		
		var openList:Heap<PlannerNode> = new Heap<PlannerNode>();
		
		do
		{
			var successiveStates:Array<PlannerNode> = GetAllSuccessiveStates(currentState);
			#if debug_output
			if (iteration++ >= 1000)
			{
				iteration = 0;
				trace("openListCount: " + openList.size() + " _ " + openList.top().depth + " _ " + openList.top().estimate);
			}
			#end
			
			for (i in successiveStates)
			{
				openList.add(i);
			}
			
			currentState = GetNextState(openList);
			//trace(current_lowest_total_cost_seen);
			//trace("iter: current_state: " + currentState.depth + " _ " + currentState.estimate + " _____ " + problem_.EvaluateGoal(currentState.state) + "\n" + currentState);
		}
		while (currentState != null && !problem_.EvaluateGoal(currentState.state));
		
		trace("openListcount exit: " + openList.size());
		
		return BacktrackPlan(currentState);
	}
	
	function BacktrackPlan(plannerNode_:PlannerNode):Array<PlannerActionNode>
	{
		var backwardsActionSet:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		var currentNode:PlannerNode = plannerNode_;
		while (currentNode.plannerActionNode != null)
		{
			backwardsActionSet.push(currentNode.plannerActionNode);
			
			currentNode = currentNode.parent;
		}
		backwardsActionSet.reverse();
		return backwardsActionSet;
		
	}
	
	function GetNextState(openList_:Heap<PlannerNode>):PlannerNode
	{
		return openList_.pop();
	}
	
	function GetAllSuccessiveStates(parent_state_:PlannerNode):Array<PlannerNode>
	{
		//trace(parent_state_.state);
		var states:Array<PlannerNode> = new Array<PlannerNode>();
		
		var actions:Array<PlannerActionNode> = GetAllActionsForState(parent_state_.state, domain);
		//trace("action count: " + actions.length);
		for (actionNode in actions)
		{
			
			actionNode.Set();
			var newState:State = actionNode.action.Execute(parent_state_.state, domain);
			
			var hash:Int = newState.GenerateStateHash();
			
			if (!closedStates.exists(hash))
			{
				var heuristic_estimate:Int = 0;
				if (heuristic != null)
				{
					heuristic_estimate = heuristic.RunHeuristic(newState);
					//trace("ran heuristic: " + actionNode + "\n" + newState + "\n" + heuristic_estimate);
				}
				
				var plannerNode:PlannerNode = new PlannerNode(newState, parent_state_, actionNode, parent_state_.depth + 1, heuristic_estimate);
				if (plannerNode.depth + plannerNode.estimate < current_lowest_total_cost_seen)
				{
					current_lowest_total_cost_seen = plannerNode.depth + plannerNode.estimate;
				}
				
				if (hasMetric)
				{
					plannerNode.SetMetric(problem.EvaluateMetric(plannerNode.state));
					//trace("p: " + plannerNode.GetMetric() + " _ " + plannerNode.position);
				}
				
				closedStates.set(hash, plannerNode);
				states.push(plannerNode);
				
				trace("action: " + actionNode.action.GetName() + " _ " + actionNode.params.toString() + " _ " + plannerNode.depth + " _ " + plannerNode.estimate);
			}
			
		}
		
		
		return states;
	}
	
	
	static public function GetAllActionsForState(state_:State, domain_:Domain):Array<PlannerActionNode>
	{
		var actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		for (actionName in domain_.GetAllActionNames())
		{
			var action:Action = domain_.GetAction(actionName);
			
			var parameter_combinations:Array<Array<Pair<String, String>>> = GetAllPossibleParameterCombinations(action, state_, domain_);
			
			// has an extra array since these combinations are used per parameter combination
			var value_combinations:Array<Array<Array<Pair<String, String>>>> = GetAllPossibleValueCombinations(action, parameter_combinations, state_, domain_, false);
			
			for (param_index in 0...parameter_combinations.length)
			{
				var param_combination:Array<Pair<String, String>> = parameter_combinations[param_index];
				action.GetData().SetParameters(param_combination);
				if (value_combinations[param_index].length > 0)
				{
					for (val_combination in value_combinations[param_index])
					{
						action.GetData().SetValues(val_combination);
						
						if (action.Evaluate(state_, domain_))
						{
							actions.push(new PlannerActionNode(action, param_combination, val_combination));
						}
					}
				}
				else
				{
					if (action.Evaluate(state_, domain_))
					{
						actions.push(new PlannerActionNode(action, param_combination, null));
					}
				}
			}
			
		}
		
		return actions;
	}
	
	static public function GetAllPossibleParameterCombinations(action_:Action, initial_state_:State, domain_:Domain):Array<Array<Pair<String, String>>>
	{
		/*
		 * Array<Array<Pair<String, String>>> Is essentialy an array of tuples, with each element of the tuple being a pair
		 * which contains the name and value associated with that name. The name is required so that the action knows which parameter needs the value.
		 */	
		var combinations:Array<Array<Pair<String, String>>> = null;
		
		var raw_values:Array<Array<Pair<String, String>>> = new Array<Array<Pair<String, String>>>();
		
		// first lets populate the raw_values array with everything we need
		
		var actionParams:Array<Parameter> = action_.GetData().GetParameters();
		for (paramIndex in 0...actionParams.length)
		{
			// lets record the fact that the first so many raw values are of the param type			
			var obj_array:Array<Pair<String, String>> = new Array<Pair<String, String>>();
			for (obj in initial_state_.GetObjectsOfType(actionParams[paramIndex].GetType()))
			{
				obj_array.push(new Pair(actionParams[paramIndex].GetName(), obj));
			}
			
			raw_values.push(obj_array);
		}
		
		// since we have now finished populating the array, lets generate the sets correctly
		
		combinations = GenerateCombinations(raw_values);
		return combinations;
	}
	
	static public function GetAllPossibleValueCombinations(action_:Action, parameter_combinations_:Array<Array<Pair<String, String>>>, state_:State, domain_:Domain, heuristic_version_:Bool):Array<Array<Array<Pair<String, String>>>>
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
					for (obj in actionValues[valueIndex].GetPossibleValues(action_.GetData(), state_, domain_, heuristic_version_))
					{
						obj_array.push(new Pair(actionValues[valueIndex].GetName(), obj));
					}
					
					value_ranges.push(obj_array);
				}
				
				returnee.push(GenerateCombinations(value_ranges));
			}
			else
			{
				returnee.push(new Array<Array<Pair<String, String>>>()); // just push an empty array, since we want this to succeed
			}
		}
		
		return returnee;
	}
	
	static function GenerateCombinations(value_ranges_:Array<Array<Pair<String, String>>>):Array<Array<Pair<String, String>>>
	{
		var returnee:Array<Array<Pair<String, String>>> = new Array<Array<Pair<String, String>>>();
		
		var values_index:Array<Int> = new Array<Int>();
		for (value in value_ranges_) // set values_index to start indexs
		{
			values_index.push(0);
		}
		
		// this condition checks the last element in the index array to the last element in the raw values array
		// we do this because we are counting up in a left to right manner eg.
		// 000, 100, 200, 300, 400, 500, 600, 700, 800, 900, 010, 110, 210, 310, etc. etc.
		// if the last digit is equal to the end of the last elements length, we know that we have finished brute forcing the combinations.
		while (values_index[value_ranges_.length - 1] != value_ranges_[value_ranges_.length - 1].length)
		{
			// add the current index values to the set and store it
			var values_set:Array<Pair<String, String>> = new Array<Pair<String, String>>();
			for (i in 0...value_ranges_.length)
			{
				values_set.push(value_ranges_[i][values_index[i]]);
			}
			
			returnee.push(values_set);
			
			for (i in 0...values_index.length)
			{
				values_index[i]++;
				if (values_index[i] != value_ranges_[i].length) // if this value has not hit the limit, do not increase any futher values
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