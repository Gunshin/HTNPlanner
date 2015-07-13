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
	
	public function ParsePDDL(string_:String)
	{		
		baseNode = RecursiveParse(0, string_.substr(1, string_.length - 2), null, 0).returnNode;
	}
	
	public function RecursiveParse(start_:Int, string_:String, currentParentNode_:TreeNode, depth:Int):RecursiveParseEval
	{
		
		var value:String = "";
		var newNode:TreeNode = new TreeNode(currentParentNode_);
		
		var i:Int = start_;
		while (i < string_.length)
		{
			if (string_.charAt(i) == '(')
			{
				//trace("starting child at: " + (i + 1));
				var childNode:RecursiveParseEval = RecursiveParse(i + 1, string_, newNode, depth + 1);
				
				newNode.children.push(childNode.returnNode);
				trace("added child: " + value + " _ " + childNode.returnNode.value + " at depth: " + depth);
				i = childNode.end; // set the i to after the childs stuff
			}
			else if(string_.charAt(i) == ')')
			{
				newNode.value = StringTools.trim(value);
				//trace("node: " + value + " returning i: " + i);
				//trace("ending child at: " + (i + 1) + " _ currently in: " + value + " returning on depth: " + depth);
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
	
	public function Evaluate():Void
	{
		
		
		
	}
	
	function RecursiveEvaluate(node_:TreeNode, state_:State, taskManager_:TaskManager):Void
	{
		
		// we are a leaf node
		if (node_.children == 0)
		{
			
			taskManager_.Evaluate(
			
		}
		
		var childValues:Array<String> = new Array<String>();
		
		for (i in node_.children)
		{
			
			childValues.push(RecursiveEvaluate(i));
			
		}
		
	}
	
	function
	
}