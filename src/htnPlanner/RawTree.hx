package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class RawTree
{
	
	var baseNode:RawTreeNode = null;

	public function new() 
	{
	}
	
	public function SetupFromString(scope_:String)
	{
		baseNode = RecursiveParse(scope_, null);
	}
	
	public function SetupFromNode(node_:RawTreeNode)
	{
		baseNode = node_;
	}
	
	function RecursiveParse(string_:String, currentParentNode_:RawTreeNode):RawTreeNode
	{
		var newNode:RawTreeNode = new RawTreeNode(currentParentNode_);
		
		//trace("string_: " + string_);
		
		var elements:Array<String> = Utilities.GetScopedContents(string_);
		
		//trace("length: " + elements.length + " ___ " + elements.toString());
		
		newNode.value = elements[0];
		
		for (elementIndex in 1...elements.length)
		{
			var child:RawTreeNode = RecursiveParse(elements[elementIndex], newNode);
			newNode.children.push(child);
		}
		
		return newNode;
	}
	
	public function Recurse(func_:RawTreeNode-> Void)
	{
		Recursive(func_, baseNode);
	}
	
	function Recursive(func_:RawTreeNode-> Void, currentNode_:RawTreeNode)
	{
		trace("entered");
		for (i in currentNode_.children)
		{
			Recursive(func_, i);
		}
		
		func_(currentNode_);
		trace("exiting");
	}
	
	/*function RecursiveParse(start_:Int, string_:String, currentParentNode_:RawTreeNode):RecursiveParseEval
	{
		var value:String = "";
		var newNode:RawTreeNode = new RawTreeNode(currentParentNode_);
		
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
	}*/
	
	public function GetBaseNode():RawTreeNode
	{
		return baseNode;
	}
	
}