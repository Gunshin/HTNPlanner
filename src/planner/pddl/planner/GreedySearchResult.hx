package planner.pddl.planner;

import de.polygonal.ds.Heap;

/**
 * 
 * This class is seperate to BreadthSearchResult purely so that you cant get mixed up with what the two do in the respective functions
 * 
 * ...
 * @author Michael Stephens
 */
class GreedySearchResult
{

	public var last_successively_lower_node:PlannerNode = null;
	public var open_list:Heap<PlannerNode> = null;
	public var closed_list:Array<PlannerNode> = null;
	
	public function new(last_successively_lower_node_:PlannerNode, open_list_:Heap<PlannerNode>, closed_list_:Array<PlannerNode>) 
	{
		last_successively_lower_node = last_successively_lower_node_;
		open_list = open_list_;
		closed_list = closed_list_;
	}
	
}