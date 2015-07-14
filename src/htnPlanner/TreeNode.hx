package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNode
{
	public var value:String = null;
	public var parentNode:TreeNode = null;
	public var children:Array<TreeNode> = new Array<TreeNode>();

	
	public var evaluatedVar:String = null;

	public function new(parentNode_:TreeNode)
	{
		parentNode = parentNode_;
	}

	
	public function GetChildrenWithContainingValue(value_:String):Array<TreeNode>
	{
		if (value_ == null || value_.length == 0)
		{
			throw "value_ is null";
		}
		
		var childrenWithValue:Array<TreeNode> = new Array<TreeNode>();
		
		for (i in children)
		{
			
			if (i.value.indexOf(value_) != -1)
			{
				childrenWithValue.push(i);
			}
			
		}
		
		return childrenWithValue;
		
	}
	
}