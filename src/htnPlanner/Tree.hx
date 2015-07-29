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
	
	public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Void
	{
		baseNode.Execute(parameters_, state_, domain_);
	}
	
	public static function ConvertRawTreeNodeToTree(rawNode_:RawTreeNode, domain_:Domain):Tree
	{
		var baseNode:TreeNode = ConvertRawNode(rawNode_, domain_);
		
		RecursiveGenerateTree(rawNode_, baseNode, domain_);
		
		return new Tree(baseNode);
		
	}
	
	static function RecursiveGenerateTree(rawNodeParent_:RawTreeNode, conditionNodeParent_:TreeNode, domain_:Domain)
	{
		
		for (i in rawNodeParent_.children)
		{
			
			var conditionNode:TreeNode = ConvertRawNode(i, domain_);
			conditionNodeParent_.AddChild(conditionNode);
			conditionNode.SetParent(conditionNodeParent_);
			
			RecursiveGenerateTree(i, conditionNode, domain_);
		}
		
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
		
		// we filter this because function evaluators (TreeNodeInt) may produce a null element in the array due to the way things a parsed. We also cut
		// off the front element because the name is not a param.
		var params:Array<String> = terms.filter(function(s) { return s.length > 0; } ).slice(1);
		
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
			case ">":
				newNode = new TreeNodeIntMoreThan(params);
			case ">=":
				newNode = new TreeNodeIntMoreThanOrEqual(params);
			case "<":
				newNode = new TreeNodeIntLessThan(params);
			case "<=":
				newNode = new TreeNodeIntLessThanOrEqual(params);
			case "assign":
				newNode = new TreeNodeIntAssign(params);
			case "increase":
				newNode = new TreeNodeIntIncrease(params);
			case "decrease":
				newNode = new TreeNodeIntDecrease(params);
			default:
				throw "we do not know what this node is!: " + firstTerm;
		}
		
		return newNode;
		
	}
	
}