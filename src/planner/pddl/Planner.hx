package planner.pddl;

import de.polygonal.ds.Heap;
import haxe.ds.HashMap;
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
	
	var hasMetric:Bool = false;
	
	public function new() 
	{
		
	}
	
	#if debug_output
	var iteration:Int = 0;
	#end
	
	public function FindPlan(domain_:Domain, problem_:Problem):Array<PlannerActionNode>
	{
		domain = domain_;
		problem = problem_;
		
		hasMetric = problem.HasProperty("metric");
		
		var currentState:PlannerNode = new PlannerNode(problem_.GetClonedInitialState(), null, null, 0);
		
		var openList:Heap<PlannerNode> = new Heap<PlannerNode>();
		openList.add(currentState);
		
		while (!problem_.EvaluateGoal(currentState.state) && openList.size() != 0)
		{
			currentState = GetNextState(openList);
			var successiveStates:Array<PlannerNode> = GetAllSuccessiveStates(currentState);
			
			#if debug_output
			if (iteration++ >= 1000)
			{
				iteration = 0;
				trace("openListCount: " + openList.size() + " _ " + openList.top().depth);
			}
			#end
			
			for (i in successiveStates)
			{
				openList.add(i);
			}
			
		}
		
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
	
	function GetAllSuccessiveStates(stateNode_:PlannerNode):Array<PlannerNode>
	{
		var states:Array<PlannerNode> = new Array<PlannerNode>();
		
		var actions:Array<PlannerActionNode> = GetAllActionsForState(stateNode_.state);
		//trace("action count: " + actions.length);
		
		for (actionNode in actions)
		{
			//trace("action: " + actionNode.action.GetName());
			
			actionNode.action.GetData().Set(actionNode.params, actionNode.valuesType);
			var newState:State = actionNode.action.Execute(stateNode_.state, domain);
			
			var hash:Int = newState.GenerateStateHash();
			
			if (!closedStates.exists(hash))
			{
				var plannerNode:PlannerNode = new PlannerNode(newState, stateNode_, actionNode, stateNode_.depth + 1);
				//trace(plannerNode.depth);
				
				if (hasMetric)
				{
					plannerNode.SetMetric(problem.EvaluateMetric(plannerNode.state));
					//trace("p: " + plannerNode.GetMetric() + " _ " + plannerNode.position);
				}
				
				closedStates.set(hash, plannerNode);
				states.push(plannerNode);
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
			
			var combinations:Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>> = GetAllPossibleParameterCombinations(action, state_);
			
			var action_params:Array<Parameter> = action.GetData().GetParameters();
			var action_values:Array<Value> = action.GetData().GetValues();
			
			for (combination in combinations.b)
			{
				for (variable_index in 0...combinations.a.length)
				{
					
					switch(combinations.a[variable_index])
					{
						case EParam:
							action_params[variable_index].SetValue(combination[variable_index].b);
							
						case EValue:
							action_values[variable_index - action_params.length].SetValue(combination[variable_index].b);
						
					}
					
				}
				
				if (action.Evaluate(state_, domain))
				{
					actions.push(new PlannerActionNode(action, combination, combinations.a));
				}
			}
			
		}
		
		return actions;
	}
	
	function GetAllPossibleParameterCombinations(action_:Action, initial_state_:State):Pair<Array<ValuesType>, Array<Array<Pair<String, String>>>>
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
			for (obj in actionValues[valueIndex].GetPossibleValues(initial_state_, domain))
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