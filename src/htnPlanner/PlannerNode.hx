package htnPlanner;
import de.polygonal.ds.Heapable;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode implements Heapable<PlannerNode>
{	
	public var value:Float;
	public var position:Int;
	public var depth:Int;

	public var state:State = null;
	public var parent:PlannerNode = null;
	
	public var plannerActionNode:PlannerActionNode = null;
	
	public function new(state_:State, parent_:PlannerNode, plannerActionNode_:PlannerActionNode, depth_:Int) 
	{
		state = state_;
		parent = parent_;
		plannerActionNode = plannerActionNode_;
		depth = depth_;
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
		return other.depth - depth == 0 ? other.value - value < 0 ? -1 : 1 : other.depth - depth < 0 ? -1 : 1;
	}
	
}
