package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.StateHeuristic;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNode
{
	
	var parent:TreeNode = null;
	var children:Array<TreeNode> = new Array<TreeNode>();

	public function new() 
	{
		
	}
	
	public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool { throw "must override this function"; }
	
	public function Execute(data_:ActionData, state_:State, domain_:Domain):String { throw "must override this function"; }
	
	public function GenerateRangeOfValues(valueName_:String, state_:State, domain_:Domain):Array<String> { throw "must override this function"; }
	
	public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool { throw "must override this function"; }
	
	public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String { throw "must override this function"; }
	
	
	public function AddChild(child_:TreeNode)
	{
		children.push(child_);
	}
	
	public function SetParent(parent_:TreeNode)
	{
		parent = parent_;
	}
	
	public function GetChildren():Array<TreeNode>
	{
		return children;
	}
	
	public function GetParent():TreeNode
	{
		return parent;
	}
	
	/**
	 * This function returns the raw name defining this node eg. TreeNodeIntEquivalent returns "=="
	 * @return
	 */
	public function GetRawName():String
	{
		throw "must override this function";
	}
	
	/**
	 * This function is for recreating the raw tree for this node and its children. If you need the value for debug purposes.
	 * @return
	 */
	public function GetRawTreeString():String
	{
		var returnee:String = GetRawName() + " ";
		for (i in children)
		{
			returnee += "(" + i.GetRawTreeString() + ") ";
		}
		
		return returnee;
	}
	
	/**
	 * Filtered version of the above
	 * @return
	 */
	public function GetRawTreeStringFiltered(filter_:TreeNode -> Bool):String
	{
		var returnee:String = GetRawName() + " ";
		for (i in children)
		{
			if (filter_(i))
			{
				returnee += "(" + i.GetRawTreeString() + ") ";
			}
		}
		
		return returnee;
	}
	
	public function toString():String
	{
		return GetRawName();
	}
	
}