package htnPlanner;

import de.polygonal.ds.Heap;
import haxe.ds.HashMap;

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
	
	var thingy:State = null;
	var plannerNodeThingy:PlannerNode = null;
	
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
			//trace(currentState.depth);
			
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
		
		for (actionNode in actions)
		{
			actionNode.action.SetParameters(actionNode.params);
			var newState:State = actionNode.action.Execute(stateNode_.state, domain);
			
			var hash:Int = newState.GenerateStateHash();
			
			//trace(actionNode.action.GetName() + " _ " + actionNode.params.toString() + " _ " + stateNode_.state.CompareState(newState).toString() );
			
			//trace(!closedStates.exists(hash) + " _ " + hash);
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
			//trace("running on action: " + action.GetName());
			
			var params:Array<Parameter> = action.GetParameters();
			
			var values:Array<Array<String>> = new Array<Array<String>>();
			var valuesIndex:Array<Int> = new Array<Int>();
			for (param in 0...params.length)
			{
				var objects:Array<String> = problem.GetObjectsOfType(params[param].GetType());
				
				//trace("found object count: " + objects.length + " _ for type: " + params[param].GetType());
				
				values[param] = objects;
				valuesIndex[param] = 0;
			}
			
			//trace("_________________: " + (valuesIndex[values.length - 1] != values[values.length - 1].length) + " _ " + valuesIndex[values.length - 1] + " _ " + values[values.length - 1].length);
			
			// the idea behind this while loop is to generate a series of all the possible combinations
			// i am doing this with the same process that a number system increases. only when a digit has
			// hit the limit of its values, the next digit will increment eg. 08, 09, 10, 11, 12, 13
			while (valuesIndex[values.length - 1] != values[values.length - 1].length) // this checks to see if the most significant has hit its limit
			{
				// add the current index values to the set and store it
				var valuesSet:Array<Pair> = new Array<Pair>();
				for (i in 0...values.length)
				{
					valuesSet.push(new Pair(params[i].GetName(), values[i][valuesIndex[i]]));
					params[i].SetValue(values[i][valuesIndex[i]]);
				}
				
				//trace("attempting with value set: " + valuesSet.toString());
				
				if (action.Evaluate(state_, domain))
				{
					actions.push(new PlannerActionNode(action, valuesSet));
				}
				
				//trace(valuesIndex.toString() + " _______ " + values.toString());
				
				for (i in 0...valuesIndex.length)
				{
					valuesIndex[i]++;
					if (valuesIndex[i] != values[i].length) // if this value has not hit the limit, do not increase any futher values
					{
						break;
					}
					
					// since it passed the above, it did hit the limit, so reset to 0
					if (i != valuesIndex.length - 1) // we also need to make sure we dont reset the most significant. if we do, we enter a forever loop
					{
						valuesIndex[i] = 0;
					}
				}
				
			}
			
		}
		
		return actions;
	}
	
}