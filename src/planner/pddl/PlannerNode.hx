package planner.pddl;
import de.polygonal.ds.Heapable;
import planner.pddl.PlannerActionNode;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode implements Heapable<PlannerNode>
{	
	public var value:Float;
	public var position:Int;
	public var depth:Int;
	public var estimate:Int;

	public var state:State = null;
	public var parent:PlannerNode = null;
	
	public var plannerActionNode:PlannerActionNode = null;
	
	public function new(state_:State, parent_:PlannerNode, plannerActionNode_:PlannerActionNode, depth_:Int, estimate_:Int) 
	{
		state = state_;
		parent = parent_;
		plannerActionNode = plannerActionNode_;
		depth = depth_;
		estimate = estimate_;
	}
	
	public function SetMetric(metric_:Float)
	{
		value = metric_;
	}
	
	public function GetMetric():Float
	{
		return value;
	}
	
	public function compare(other:PlannerNode):Int
	{
		return (2*other.estimate+other.depth) - (2*estimate+depth);
	}
	
}
