package htnPlanner;

import haxe.ds.HashMap;
import haxe.Int64;


/**
 * ...
 * @author Michael Stephens
 */
class Planner
{
	
	var closedStates:Map<Int64, PlannerNode> = new Map<Int, State>();
	
	var domain:Domain = null;
	var problem:Problem = null;
	
	var hasMetric:Bool = false;
	var metricComparator:Int -> Int -> Bool = null;

	public function new() 
	{
		
	}
	
	public function FindPlan(domain_:Domain, problem_:Problem):String
	{
		domain = domain_;
		problem = problem_;
		
		hasMetric = problem.HasProperty("metric");
		if (hasMetric)
		{
			if (problem.HasProperty("minimize"))
			{
				metricComparator = function(valueA_, valueB_) {
					return valueA_ < valueB_;
				};
			}
			else
			{
				metricComparator = function(valueA_, valueB_) {
					return valueA_ > valueB_;
				};
			}
		}
		
		var currentState:PlannerNode = new PlannerNode(problem_.GetClonedInitialState(), null);
		
		var openList:Array<PlannerNode> = new Array<PlannerNode>();
		openList.push(currentState);
		
		while (!problem_.EvaluateGoal(currentState) || openList.length == 0)
		{
			currentState = GetNextState(openList);
			
			var successiveStates:Array<PlannerNode> = GetAllSuccessiveStates(currentState.state);
			
			for (i in successiveStates)
			{
				openList.push(i);
			}
		}
		
	}
	
	function GetNextState(openList_:Array<PlannerNode>):PlannerNode
	{
		var returnNode:PlannerNode = null;
		
		if (hasMetric)
		{
			var lowestNode:PlannerNode = null;
			for (i in openList_)
			{
				if (lowestNode == null || metricComparator(i, lowestNode))
				{
					lowestNode = i;
				}
			}
			
			returnNode = lowestNode;
		}
		else
		{
			returnNode = openList_[0];
		}
		
		openList_.remove(returnNode);
		
		return returnNode;
	}
	
	function GetAllSuccessiveStates(state_:State):Array<PlannerNode>
	{
		var states:Array<PlannerNode> = new Array<PlannerNode>();
		
		var actions:Array<Action> = GetAllActionsForState(state_, domain);
		
		for (i in actions)
		{
			var newState:State = state_.Clone();
			i.Execute(newState, domain);
			
			var hash:Int64 = newState.GenerateStateHash();
			if (!closedStates.exists(hash))
			{
				var plannerNode:PlannerNode = new PlannerNode(newState, state_);
				closedStates.set(hash, plannerNode);
				states.push(plannerNode);
			}
		}
		
		return states;
	}
	
	function GetAllActionsForState(state_:State):Array<PlannerActionNode>
	{
		var actions:Array<PlannerActionNode> = new Array<PlannerActionNode>();
		
		for (i in domain.GetAllActionNames())
		{
			var action:Action = domain.GetAction(i);
			
			var params:Array<Parameter> = action.GetParameters();
			
			var values:Array<Array<Pair>> = new Array<Array<Pair>>();
			var valuesIndex:Array<Int> = new Array<Int>();
			for (param in 0...params.length)
			{
				var objects:Array<Pair> = problem.GetObjectsOfType(params[param].GetType());
				values[param] = objects;
				valuesIndex[param] = 0;
			}
			
			// the idea behind this while loop is to generate a series of all the possible combinations
			// i am doing this with the same process that a number system increases. only when a digit has
			// hit the limit of its values, the next digit will increment eg. 08, 09, 10, 11, 12, 13
			while (valuesIndex[values.length - 1] != values[values.length - 1].length) // this checks to see if the most significant has hit its limit
			{
				// add the current index values to the set and store it
				var valuesSet:Array<String> = new Array<String>();
				for (i in 0...values.length)
				{
					valuesSet.push(values[i][valuesIndex[i]]);
				}
				
				if (action.Evaluate(state_, domain))
				{
					actions.push(action);
				}
				
				for (i in 0...valuesIndex.length)
				{
					valuesIndex[i]++;
					if (valuesIndex[i] != values[i].length) // if this value has not hit the limit, do not increase any futher values
					{
						break;
					}
				}
				
			}
			
		}
		
		return actions;
	}
	
}