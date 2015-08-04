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
	
}