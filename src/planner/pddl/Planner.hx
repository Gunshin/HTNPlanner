package planner.pddl;

import de.polygonal.ds.Heap;
import haxe.ds.HashMap;
import planner.pddl.heuristic.Heuristic;
import planner.pddl.Planner.ValuesType;
import planner.pddl.Action;
import planner.pddl.Domain;
import planner.pddl.Pair;

enum ValuesType
{
	EParam;
	EValue;
}

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
			trace(current_lowest_total_cost_seen);
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
		
		var actions:Array<PlannerActionNode> = GetAllActionsForState(parent_state_.state);
		//trace("action count: " + actions.length);
		for (actionNode in actions)
		{
			
			actionNode.action.GetData().Set(actionNode.params, actionNode.valuesType);
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
				
				//trace("action: " + actionNode.action.GetName() + " _ " + actionNode.params.toString() + " _ " + plannerNode.depth + " _ " + plannerNode.estimate);
			}
			
		}
		
		
		return states;
	}
	
	
	function GetAllActionsForState(state_:State):Array<PlannerActionNode>
	{
		var actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		for (actionName in domain.GetAllActionNames())
		{
			var action:Action = domain.GetAction(actionName);
			
			var combinations_result:Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>> = GetAllPossibleParameterCombinations(action, state_, domain);
			
			for (combination in combinations_result.b)
			{
				action.GetData().Set(combination, combinations_result.a);
				
				if (action.Evaluate(state_, domain))
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