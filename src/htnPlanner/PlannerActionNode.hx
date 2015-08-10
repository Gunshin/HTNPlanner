package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerActionNode
{
	
	public var action:Action = null;
	public var params:Array<Pair> = null;

	public function new(action_:Action, params_:Array<Pair>) 
	{
		action = action_;
		params = params_;
	}
	
	public function GetActionTransform():String
	{
		var final:String = action.GetName();
		for (layoutName in action.GetLayout())
		{
			for (varName in params)
			{
				if (Utilities.Compare(varName.a, layoutName) == 0)
				{
					final += " " + varName.b;
				}
			}
		}
		
		return StringTools.trim(final);
	}
	
}