package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Precondition
{
	
	var tree:Tree = null;
	
	static var functions:Map<String, TreeNode -> Map<String, Parameter> -> Void> = [
		"and" => And,
		"not" => Not,
		"imply" => Imply,
		"forall" => Forall
	];

	public function new(treeNode_:TreeNode) 
	{
		tree = new Tree();
		tree.SetupFromNode(treeNode_);
		
	}
	
	public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		RecursiveEvaluate(tree.GetBaseNode(), parameters_, state_, domain_);
		
		return Utilities.Compare(tree.GetBaseNode().evaluatedVar, "true") == 0;
	}
	
	function RecursiveEvaluate(node_:TreeNode, parameters_:Map<String, Parameter>, state_:State, domain_:Domain)
	{
		
		for (i in node_.children)
		{
			RecursiveEvaluate(i, parameters_, state_, domain_);
		}
		
		DetermineStatement(node_, parameters_, state_, domain_);
		
	}
	
	/*
	 * 
	 * This function is used to determine whether a node needs to use a predicate or a primitive
	 * 
	 */
	static function DetermineStatement(node_:TreeNode, parameters_:Map<String, Parameter>, state_:State, domain_:Domain)
	{
		
		var split:Array<String> = node_.value.split(" ");
		
		var predicate:Predicate = null;
		if ((predicate = domain_.GetPredicate(split[0])) != null)
		{
			var predicateValue:String = predicate.Construct(parameters_);
			if (state_.Exists(predicateValue))
			{
				node_.evaluatedVar = "true";
			}
			else
			{
				node_.evaluatedVar = "false";
			}
			return;
		}
		
		functions.get(split[0])(node_);
		
	}
	
	static function And(node_:TreeNode, parameterMap_:Map<String, Parameter>):Void
	{
		
		for (i in node_.children)
		{
			
			if (Utilities.Compare(i.evaluatedVar, "false") == 0)
			{
				node_.evaluatedVar = "false";
				return;
			}
			
		}
		
		node_.evaluatedVar = "true";
	}
	
	static function Not(node_:TreeNode, parameterMap_:Map<String, Parameter>):Void
	{
		if (Utilities.Compare(node_.children[0].evaluatedVar, "true") == 0)
		{
			node_.evaluatedVar = "false";
			return;
		}
		
		node_.evaluatedVar = "true";
	}
	
	static function Imply(node_:TreeNode, parameterMap_:Map<String, Parameter>):Void
	{
		
		node_.evaluatedVar = (Utilities.Compare(node_.children[0].evaluatedVar, "true") != 0 || Utilities.Compare(node_.children[1].evaluatedVar, "true") == 0) ? "true" : "false";
		
	}
	
	static function Forall(node_:TreeNode, parameterMap_:Map<String, Parameter>)
	{
		
		var forParameter:String = node_.children[0].value;
		var pair:Pair = Utilities.GenerateValueTypeMap([forParameter]);
		
		var relations_
		
	}
	
}