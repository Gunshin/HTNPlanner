package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode
{

	public var state:State = null;
	public var parent:State = null;
	
	public var metric:Int = -1;
	
	public function new(state_:State, parent_:State) 
	{
		state = state_;
		parent = parent_;
	}
	
}