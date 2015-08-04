package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode
{

	public var state:State = null;
	public var parent:PlannerNode = null;
	
	public var plannerActionNode:PlannerActionNode = null;
	
	public var metric:Int = -1;
	
	public function new(state_:State, parent_:PlannerNode, plannerActionNode_:PlannerActionNode) 
	{
		state = state_;
		parent = parent_;
		plannerActionNode = plannerActionNode_;
	}
	
}