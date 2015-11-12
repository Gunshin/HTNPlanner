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
		//trace("running");
		baseNode = FindBaseNode(action_, name);
		//trace(baseNode.GetRawTreeString());
	}
	
	override public function GetPossibleValues(data_:ActionData, state_:State, domain_:Domain, heuristic_version_:Bool):Array<String>
	{
		var range:Array<String> = baseNode.GenerateRangeOfValues(data_, name, state_, domain_, heuristic_version_);
		
		//trace(name + ": " + range);
		
		return range;
	}

	static public function FindBaseNode(action_:Action, name_:String):TreeNode
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
						Tree.Recursive(child, 
							function(testNode)
							{
								if (Utilities.Compare(testNode.GetRawName(), name_) == 0)
								{
									count++;
									return false;
								}
								
								return true;
							}
						);
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