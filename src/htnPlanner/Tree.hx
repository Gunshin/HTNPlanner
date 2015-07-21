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
		return baseNode.Execute(parameters_, state_, domain_);
	}
	
	public static function ConvertRawTreeNodeToTreeCondition(rawNode_:RawTreeNode, domain_:Domain):Tree
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
		
		var predicate:Predicate = domain_.GetPredicate(rawNode_.value);
		if (predicate != null)
		{
			return new TreeNodePredicate(predicate);
		}
		
		switch(rawNode_.value)
		{
			case "and":
				return new TreeNodeAnd();
				break;
			case "not":
				return new TreeNodeNot();
				break;
			case "imply":
				return new TreeNodeImply();
				break;
			case "forall":
				return new TreeNodeForall();
				break;
			default:
				throw "we do not know what this node is!: " + rawNode_.value;
				break;
		}
		
	}
	
}