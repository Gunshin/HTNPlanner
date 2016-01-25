package planner.pddl.heuristic;

import planner.pddl.planner.PlannerActionNode;

/**
 * ...
 * @author ...
 */
class FunctionRateOfChange
{
	public var function_name:String = null;
	
	public var rate_of_change:Int = 0;
	
	public var state_level:Int = 0;
	
	public var action:PlannerActionNode = null;
	
	public function new(function_name_:String, rate_of_change_:Int, state_level_:Int, action_:PlannerActionNode)
	{
		function_name = function_name_;
		rate_of_change = rate_of_change_;
		state_level = state_level_;
		action = action_;
	}
	
	public function toString():String
	{
		return "{\"function_name\":\"" + function_name + "\", \"rate_of_change\":" + rate_of_change +
		", \"state_level\":" + state_level + ", \"action\":\"" + action.GetActionTransform() + "\"}"; 
	}
}