package planner.pddl.planner;
import de.polygonal.ds.Heapable;
import planner.pddl.heuristic.Heuristic.HeuristicResult;
import planner.pddl.planner.PlannerActionNode;

/**
 * ...
 * @author Michael Stephens
 */
class PlannerNode implements Heapable<PlannerNode>
{	
	public var value:Float;
	public var position:Int;
	public var depth:Int;
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
		//return (2*other.estimate.length+other.depth) - (2*estimate.length+depth);
		return (other.estimate.length) - (estimate.length);
	}
	
}
