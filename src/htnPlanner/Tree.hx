package htnPlanner;

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
	
	public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		return baseNode.Evaluate(parameters_, state_, domain_);
	}
	
	public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String
	{
		return baseNode.Execute(parameters_, state_, domain_);
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
		
		// after we have added the children, insert any values for TreeNodeInt, into the correct place
		if (Std.is(currentNode, TreeNodeInt))
		{
			var treeNode:TreeNodeInt = cast(currentNode, TreeNodeInt);
			treeNode.AddValues(rawNode_.value.split(" ").slice(1));
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
			newNode = new TreeNodePredicate(predicate, terms.slice(1));
			return newNode;
		}
		
		var func:Function = domain_.GetFunction(firstTerm);
		if (func != null)
		{
			newNode = new TreeNodeFunction(func, terms.slice(1));
			return newNode;
		}
		
		if (Utilities.Compare(firstTerm.charAt(0), "?") == 0)
		{
			newNode = new TreeNodeParameter(firstTerm);
			return newNode;
		}
		
		switch(firstTerm)
		{
			case "and":
				newNode = new TreeNodeAnd();
			case "not":
				newNode = new TreeNodeNot();
			case "imply":
				newNode = new TreeNodeImply();
			case "forall":
				newNode = new TreeNodeForall(rawNode_.children, domain_);
				rawNode_.children = new Array<RawTreeNode>(); // we dont want to iterate through the children and add them to THIS tree
			case "when":
				newNode = new TreeNodeWhen();
			case ">":
				newNode = new TreeNodeIntMoreThan();
			case ">=":
				newNode = new TreeNodeIntMoreThanOrEqual();
			case "<":
				newNode = new TreeNodeIntLessThan();
			case "<=":
				newNode = new TreeNodeIntLessThanOrEqual();
			case "assign":
				newNode = new TreeNodeIntAssign();
			case "=":
				newNode = new TreeNodeIntAssign();
			case "==":
				newNode = new TreeNodeIntEquivalent();
			case "increase":
				newNode = new TreeNodeIntIncrease();
			case "decrease":
				newNode = new TreeNodeIntDecrease();
			case "+":
				newNode = new TreeNodeIntAdd();
			case "-":
				newNode = new TreeNodeIntMinus();
			case "*":
				newNode = new TreeNodeIntMultiply();
			case "/":
				newNode = new TreeNodeIntDivide();
			default:
				throw "we do not know what this node is!: " + firstTerm + " _ raw term: " + rawNode_.parentNode.value;
		}
		
		return newNode;
		
	}
	
}