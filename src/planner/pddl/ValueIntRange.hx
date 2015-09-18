package planner.pddl;
import planner.pddl.tree.TreeNode;
import planner.pddl.tree.Tree;

/**
 * ...
 * @author 
 */
class ValueIntRange extends Value
{
	
	var baseNode:TreeNode = null;
	
	public function new(name_:String, action_:Action) 
	{
		super(name_);
		
		baseNode = FindBaseNode(action_);
		trace(baseNode.GetRawTreeString());
	}
	
	override public function GetPossibleValues(state_:State, domain_:Domain):Array<String>
	{
		var range:Array<String> = baseNode.GenerateRangeOfValues(name, state_, domain_);
		
		trace(range);
		
		return range;
	}

	static public function FindBaseNode(action_:Action):TreeNode
	{
		var baseNode:TreeNode = null;
		action_.GetPreconditionTree().Recurse(
			function(node)
			{
				if (Utilities.Compare(node.GetRawName(), "and") == 0 || Utilities.Compare(node.GetRawName(), "or") == 0)
				{
					var count:Int = 0;
					
					for (child in node.GetChildren())
					{
						Tree.Recursive(
							function(testNode)
							{
								if (Utilities.Compare(testNode.GetRawName(), "~count") == 0)
								{
									count++;
									return false;
								}
								
								return true;
							}
						, child);
					}
					
					if (count > 1)
					{
						baseNode = node;
						return false;
					}
				}
				
				return true;
			}
		);
		
		return baseNode;
	}
	
	
}