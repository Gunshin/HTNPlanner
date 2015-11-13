package planner.pddl;
import planner.pddl.Planner;

import planner.pddl.Action;
import planner.pddl.Pair;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerActionNode
{
	
	public var action:Action = null;
	public var params:Array<Pair<String, String>> = null;
	public var values:Array<Pair<String, String>> = null;

	public function new(action_:Action, params_:Array<Pair<String, String>>, values_:Array<Pair<String, String>>) 
	{
		action = action_;
		params = params_;
		values = values_;
	}
	
	/**
	 * This function is a quick way to setup the action with the params in this node so that the action can be evaluated or executed
	 */
	public function Set()
	{
		if (params != null && params.length > 0)
		{
			action.GetData().SetParameters(params);
		}
		
		if (values != null && values.length > 0)
		{
			action.GetData().SetValues(values);
		}
	}
	
	public function GetActionTransform():String
	{
		var final:String = action.GetName();
		for (layoutName in action.GetData().GetParameterLayout())
		{
			for (varName in params)
			{
				if (Utilities.Compare(varName.a, layoutName) == 0)
				{
					final += " " + varName.b;
				}
			}
		}
		for (layoutName in action.GetData().GetValuesLayout())
		{
			for (varName in values)
			{
				if (Utilities.Compare(varName.a, layoutName) == 0)
				{
					final += " " + varName.a + ": " + varName.b;
				}
			}
		}
		
		return StringTools.trim(final);
	}
	
	public function toString():String
	{
		return "{\"action\":" + action + ", \"params\":" + params + ", \"values\":" + values + "}";
	}
	
}