package planner.pddl.planner;

import de.polygonal.ds.Heap;

/**
 * ...
 * @author Michael Stephens
 */
class BreadthSearchResult
{

	public var found_better_node:PlannerNode = null;
	
	public var open_list:Heap<PlannerNode> = null;
	public var closed_list:Array<PlannerNode> = null;
	
	public function new(found_better_node_:PlannerNode, open_list_:Heap<PlannerNode>, closed_list_:Array<PlannerNode>) 
	{
		found_better_node = found_better_node_;
		open_list = open_list_;
		closed_list = closed_list_;
	}
	
}