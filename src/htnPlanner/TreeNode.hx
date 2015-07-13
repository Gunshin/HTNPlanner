package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNode
{
	public var value:String = null;
	public var parentNode:TreeNode = null;
	public var children:Array<TreeNode> = null;

	public function new(parentNode_:TreeNode) 
	{
		parentNode = parentNode_;
		children = new Array<TreeNode>();
	}
	
}