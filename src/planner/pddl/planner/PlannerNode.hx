package planner.pddl.planner;
import de.polygonal.ds.Heapable;
import planner.pddl.heuristic.HeuristicResult;
import planner.pddl.planner.PlannerActionNode;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode implements Heapable<PlannerNode>
{	
	
	public var position:Int;
	public var value:Int;
	
	public var metric:Float;
	public var depth:Int;
	static public var estimate_multiplier:Int = 10;
	public var estimate:HeuristicResult;

	public var state:State = null;
	public var parent:PlannerNode = null;
	
	public var plannerActionNode:PlannerActionNode = null;
	
	public function new(state_:State, parent_:PlannerNode, plannerActionNode_:PlannerActionNode, depth_:Int, estimate_:HeuristicResult) 
	{
		state = state_;
		parent = parent_;
		plannerActionNode = plannerActionNode_;
		depth = depth_;
		estimate = estimate_;
		value = estimate_multiplier * estimate.length + depth;
	}
	
	public function SetMetric(metric_:Float)
	{
		metric = metric_;
	}
	
	public function GetMetric():Float
	{
		return metric;
	}
	
	public function compare(other:PlannerNode):Int
	{
		return other.value - value;
	}
	
}
