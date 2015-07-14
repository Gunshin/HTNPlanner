package htnPlanner;

typedef RecursiveParseEval = { returnNode:TreeNode, start:Int, end:Int };

/**
 * ...
 * @author Michael Stephens
 */
class Tree
{
	
	var baseNode:TreeNode = null;

	public function new() 
	{
	}
	
	public function SetupFromString(scope_:String)
	{
		baseNode = RecursiveParse(0, scope_.substr(1, scope_.length - 2), null).returnNode;
	}
	
	public function SetupFromNode(node_:TreeNode)
	{
		baseNode = node_;
	}
	
	function RecursiveParse(start_:Int, string_:String, currentParentNode_:TreeNode):RecursiveParseEval
	{
		var value:String = "";
		var newNode:TreeNode = new TreeNode(currentParentNode_);
		
		var i:Int = start_;
		while (i < string_.length)
		{
			if (string_.charAt(i) == '(')
			{
				var childNode:RecursiveParseEval = RecursiveParse(i + 1, string_, newNode);
				
				newNode.children.push(childNode.returnNode);
				i = childNode.end; // set the i to after the childs stuff
			}
			else if(string_.charAt(i) == ')')
			{
				newNode.value = StringTools.trim(value);
				return {returnNode:newNode, start:start_, end:i + 1};
			}
			else
			{
				value += string_.charAt(i);
				i++;
			}
		}
		
		newNode.value = StringTools.trim(value);
		
		return {returnNode:newNode, start:start_, end:i + 1};
	}
	
	public function GetBaseNode():TreeNode
	{
		return baseNode;
	}
	
}