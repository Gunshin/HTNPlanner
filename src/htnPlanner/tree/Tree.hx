package htnPlanner.tree;

/**
 * ...
 * @author Michael Stephens
 */
class Tree
{
	
	var baseNode:TreeNode = null;

	public function new(baseNode_:TreeNode) 
	{
		baseNode = baseNode_;
	}
	
	public function GetBaseNode():TreeNode
	{
		return baseNode;
	}
	
	public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{
		return baseNode.Evaluate(data_, state_, domain_);
	}
	
	public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{
		return baseNode.Execute(data_, state_, domain_);
	}
	
	public function Recurse(func_:TreeNode-> Void)
	{
		Recursive(func_, baseNode);
	}
	
	function Recursive(func_:TreeNode-> Void, currentNode_:TreeNode)
	{		
		for (i in currentNode_.GetChildren())
		{
			Recursive(func_, i);
		}
		
		func_(currentNode_);
	}
	
	public static function ConvertRawTreeNodeToTree(rawNode_:RawTreeNode, domain_:Domain):Tree
	{		
		var baseNode:TreeNode = RecursiveGenerateTree(rawNode_, domain_);
		
		return new Tree(baseNode);
		
	}
	
	static function RecursiveGenerateTree(rawNode_:RawTreeNode, domain_:Domain):TreeNode
	{
		var currentNode:TreeNode = ConvertRawNode(rawNode_, domain_);
		
		// get/generate the children
		var children:Array<TreeNode> = new Array<TreeNode>();
		for (i in rawNode_.children)
		{
			children.push(RecursiveGenerateTree(i, domain_));
		}
		
		for (i in children)
		{
			currentNode.AddChild(i);
			i.SetParent(currentNode);
		}
		
		return currentNode;
	}
	
	static function ConvertRawNode(rawNode_:RawTreeNode, domain_:Domain):TreeNode
	{
		//trace("rawnode.value: " + rawNode_.value);
		
		var newNode:TreeNode = null;
		
		var terms:Array<String> = rawNode_.value.split(" ");
		var firstTerm:String = terms[0];
		
		var predicate:Predicate = domain_.GetPredicate(firstTerm);
		if (predicate != null)
		{
			newNode = new TreeNodePredicate(predicate, rawNode_.children);
			return newNode;
		}
		
		var func:Function = domain_.GetFunction(firstTerm);
		if (func != null)
		{
			newNode = new TreeNodeFunction(func, rawNode_.children);
			return newNode;
		}
		
		if (Utilities.Compare(firstTerm.charAt(0), "?") == 0)
		{
			newNode = new TreeNodeParameter(firstTerm);
			return newNode;
		}
		
		if (Utilities.Compare(firstTerm.charAt(0), "~") == 0)
		{
			newNode = new TreeNodeValue(firstTerm);
			return newNode;
		}
		
		switch(firstTerm)
		{
			case "and":
				newNode = new TreeNodeAnd();
				return newNode;
			case "not":
				newNode = new TreeNodeNot();
				return newNode;
			case "imply":
				newNode = new TreeNodeImply();
				return newNode;
			case "forall":
				newNode = new TreeNodeForall(rawNode_.children, domain_);
				rawNode_.children = new Array<RawTreeNode>(); // we dont want to iterate through the children and add them to THIS tree
				return newNode;
			case "when":
				newNode = new TreeNodeWhen();
				return newNode;
			case ">":
				newNode = new TreeNodeIntMoreThan();
				return newNode;
			case ">=":
				newNode = new TreeNodeIntMoreThanOrEqual();
				return newNode;
			case "<":
				newNode = new TreeNodeIntLessThan();
				return newNode;
			case "<=":
				newNode = new TreeNodeIntLessThanOrEqual();
				return newNode;
			case "assign":
				newNode = new TreeNodeIntAssign();
				return newNode;
			case "=":
				newNode = new TreeNodeIntAssign();
				return newNode;
			case "==":
				newNode = new TreeNodeIntEquivalent();
				return newNode;
			case "increase":
				newNode = new TreeNodeIntIncrease();
				return newNode;
			case "decrease":
				newNode = new TreeNodeIntDecrease();
				return newNode;
			case "+":
				newNode = new TreeNodeIntAdd();
				return newNode;
			case "-":
				newNode = new TreeNodeIntMinus();
				return newNode;
			case "*":
				newNode = new TreeNodeIntMultiply();
				return newNode;
			case "/":
				newNode = new TreeNodeIntDivide();
				return newNode;
		}
		
		//we do not know what this term is, so it could be a value. Best way to check is to see if it has any children, as values do not
		if (rawNode_.children.length == 0)
		{
			newNode = new TreeNodeIntFunctionValue(firstTerm);
			return newNode;
		}
		
		throw "we do not know what this node is!: " + firstTerm + " _ raw term: " + rawNode_.parentNode.value;
	}
	
}