package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.Function;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.Predicate;
import planner.pddl.RawTreeNode;
import planner.pddl.State;
import planner.pddl.Utilities;

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
	
	public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool
	{
		return baseNode.HeuristicEvaluate(data_, heuristic_data_, state_, domain_);
	}
	
	public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String
	{
		return baseNode.HeuristicExecute(data_, heuristic_data_, state_, domain_);
	}
	
	public function Recurse(func_:TreeNode-> Bool)
	{
		Recursive(baseNode, func_);
	}
	
	/**
	 * The function TreeNode -> Bool has the return type 'Bool' so we can prematurely stop the recursion if neccessary.
	 * A return value of true is continue, false is stop.
	 * 
	 * This differs from RecursiveExplore in that the return value dictates whether we should completely stop searching.
	 */
	static public function Recursive(currentNode_:TreeNode, func_:TreeNode -> Bool):Bool
	{
		if (!func_(currentNode_))
		{
			return false;
		}
		
		for (i in currentNode_.GetChildren())
		{
			if (!Recursive(i, func_))
			{
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * This function differs from Recursive in that the return value dictates whether we should continue exploring
	 * the branch we are currently on.
	 */
	static public function RecursiveExplore(currentNode_:TreeNode, func_:TreeNode -> Bool):Bool
	{
		if (func_(currentNode_)) //if our function tells us to stop, do not explore the children and just return false, so the current nodes siblings are still explored
		{
			return false;
		}
		
		for (i in currentNode_.GetChildren())
		{
			Recursive(i, func_);
		}
		
		return false;
	}
	
	static public function ConvertRawTreeNodeToTree(rawNode_:RawTreeNode, domain_:Domain):Tree
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
		
		if (domain_.PredicateExists(firstTerm))
		{
			var params:Array<String> = new Array<String>();
			for (raw_node in rawNode_.children)
			{
				params.push(raw_node.value);
			}
			
			newNode = new TreeNodePredicate(firstTerm, params);
			return newNode;
		}
		
		if (domain_.FunctionExists(firstTerm))
		{
			var params:Array<String> = new Array<String>();
			for (raw_node in rawNode_.children)
			{
				params.push(raw_node.value);
			}
			newNode = new TreeNodeFunction(firstTerm, params);
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
			case "or":
				newNode = new TreeNodeOr();
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
		
		
		//could be a constant
		if (domain_.ConstantExists(firstTerm))
		{
			newNode = new TreeNodeConstant(firstTerm);
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
	
	public function Clone():Tree
	{
		return new Tree(baseNode.Clone());
	}
	
}