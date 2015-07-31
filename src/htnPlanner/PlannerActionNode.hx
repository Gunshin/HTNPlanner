package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerActionNode
{
	
	public var action:Action = null;
	public var params:Array<String> = null;

	public function new(action_:Action, params_:Array<String>) 
	{
		action = action_;
		params = params_;
	}
	
}