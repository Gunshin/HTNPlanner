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
	
	override public function GetPossibleValues(data_:ActionData, state_:State, domain_:Domain, heuristic_version_:Bool, use_sampling_:Bool, percentage_:Float):Array<String>
	{
		var range:Array<String> = baseNode.GenerateRangeOfValues(data_, name, state_, domain_, heuristic_version_);
		
		
		if (use_sampling_ && range.length > 1)
		{
			var total_amount_to_be_used:Int = Math.ceil(range.length * percentage_);
			var range_split_amount:Int = Math.round(range.length / (total_amount_to_be_used - 1));
			
			//trace(total_amount_to_be_used + " _ " + range_split_amount);
			
			var final_range:Array<String> = [range[0]];

			var i:Int = 1;
			while (i <= total_amount_to_be_used - 2)
			{
				final_range.push(range[(range_split_amount * i) - 1]);
				i++;
			}
			final_range.push(range[range.length - 1]);
			//trace("length: " + final_range.length);
			//trace(name + ": range: " + range);
			//trace(name + ": final_range: " + final_range);
			return final_range;
		}
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