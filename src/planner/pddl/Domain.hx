package planner.pddl;

import haxe.ds.HashMap;
import haxe.ds.StringMap;
import planner.pddl.Action;
import planner.pddl.tree.Tree;

/**
 * ...
 * @author Michael Stephens
 */
class Domain
{
	var domainName:String = null;
	
	var domainTree:RawTree = null;
	
	var requirements:Array<String> = new Array<String>();
	
	var types:Types = null;
	
	var predicates:Map<String, Bool> = new StringMap<Bool>();
	
	/**
	 * This variable is for storing links between predicates and where they are applied in actions preconditions. 
	 */
	var predicate_action_precondition:Map<String, Array<Action>> = new Map<String, Array<Action>>();
	
	/**
	 * This variable is for storing links between predicates and where they are applied in actions effects. 
	 */
	var predicate_action_effect:Map<String, Array<Action>> = new Map<String, Array<Action>>();
	
	/**
	 * This is a map of which actions contain the specific function precondition
	 */
	var function_action_precondition:Map<String, Array<Action>> = new Map<String, Array<Action>>();
	
	/**
	 * Map of which functions are contained within an action precondition
	 */
	var action_function_precondition:Map<Action, Array<String>> = new Map<Action, Array<String>>();
	
	/**
	 * This is a map of which actions contain the specific function effect
	 */
	var function_action_effect:Map<String, Array<Action>> = new Map<String, Array<Action>>();
	
	/**
	 * Map of which functions are contained within an action effect
	 */
	var action_function_effect:Map<Action, Array<String>> = new Map<Action, Array<String>>();
	
	var functions:Map<String, Bool> = new StringMap<Bool>();
	var evaluator:Map<String, Bool> = new StringMap<Bool>();
	
	var actions:Map<String, Action> = new StringMap<Action>();
	
	var constants:Array<Pair<String, String>> = new Array<Pair<String, String>>();
	
	var properties:Map<String, Bool> = new Map<String, Bool>();
	
	public function new(domainFilePath_:String) 
	{
		domainTree = new RawTree();
		domainTree.SetupFromString(Utilities.CleanFileImport(domainFilePath_));
		
		/*domainTree.Recurse(function(node) {
			trace(node.value);
		});*/
		
		// this gets the scope of the domain name, which only returns an array with a single element as there
		// are never 2 definitions for the domain name. We then split this value into two strings due to the value
		// being eg. "domain trucks", where trucks is the name we want.
		domainName = domainTree.GetBaseNode().GetChildrenWithContainingValue("domain")[0].children[0].value;
		
		ParseRequirements(domainTree.GetBaseNode().GetChildrenWithContainingValue(":requirements")[0]);
		
		ParseTypes(domainTree.GetBaseNode().GetChildrenWithContainingValue(":types")[0]);
		
		var constantsNodes:Array<RawTreeNode> = domainTree.GetBaseNode().GetChildrenWithContainingValue(":constants");
		if (constantsNodes.length > 0)
		{
			ParseConstants(constantsNodes[0]);
		}
		
		ParsePredicates(domainTree.GetBaseNode().GetChildrenWithContainingValue(":predicates")[0]);
		
		var functionsNodes:Array<RawTreeNode> = domainTree.GetBaseNode().GetChildrenWithContainingValue(":functions");
		if (functionsNodes.length > 0)
		{
			ParseFunctions(functionsNodes[0]);
		}
		
		ParseActions(domainTree.GetBaseNode().GetChildrenWithContainingValue(":action"));
		
		AddStandardFunctions();
		
		LinkActionsToPredicates();
		LinkActionsAndFunctions();
		//trace("Domain loaded");
	}
	
	function ParseRequirements(node_:RawTreeNode)
	{
		var split:Array<String> = node_.value.split(" ");
		
		for (i in 1...split.length)
		{
			requirements.push(split[i]);
			trace("need to re-enable requirements checking");
			//Requirements.HasRequirement(split[i]);
		}
		
		properties.set("requirements", true);
	}
	
	function ParseTypes(node_:RawTreeNode)
	{
		if (node_ == null)
		{
			throw "there are no types specified in domain file";
		}
		
		types = new Types(node_);
		
		properties.set("types", true);
	}
	
	function ParseConstants(node_:RawTreeNode)
	{
		constants = Utilities.GenerateValueTypeMap(node_.children);
		
		properties.set("constants", true);
	}
	
	function ParsePredicates(parentNode_:RawTreeNode)
	{
		var predicateNodes:Array<RawTreeNode> = parentNode_.children;
		
		for (i in predicateNodes)
		{
			predicates.set(i.value, true);
		}
		
		properties.set("predicates", true);
	}
	
	function ParseFunctions(parentNode_:RawTreeNode)
	{
		var functionNodes:Array<RawTreeNode> = parentNode_.children;
		
		for (i in functionNodes)
		{
			functions.set(i.value, true);
		}
		
		properties.set("functions", true);
	}
	
	function AddStandardFunctions()
	{
		AddFunction("total-time");
		
		AddEvaluator("and");
		AddEvaluator("not");
		AddEvaluator("imply");
		AddEvaluator("forall");
		AddEvaluator("when");
		AddEvaluator(">");
		AddEvaluator(">=");
		AddEvaluator("<");
		AddEvaluator("<=");
		AddEvaluator("assign");
		AddEvaluator("=");
		AddEvaluator("==");
		AddEvaluator("increase");
		AddEvaluator("decrease");
		AddEvaluator("+");
		AddEvaluator("-");
		AddEvaluator("*");
		AddEvaluator("/");
		
		properties.set("standard_functions", true);
	}
	
	function AddFunction(name_:String)
	{
		functions.set(name_, true);
	}
	
	function AddEvaluator(name_:String)
	{
		evaluator.set(name_, true);
	}
	
	function ParseActions(actionNodes_:Array<RawTreeNode>)
	{
		for (i in actionNodes_)
		{			
			var action:Action = new Action(i.children[0].value);
			var childrenWithNameRemoved:Array<RawTreeNode> = i.children.slice(1);
			
			var preconditionNode:RawTreeNode = ActionGetChild(":precondition", childrenWithNameRemoved);
			action.SetPreconditionTree(Tree.ConvertRawTreeNodeToTree(preconditionNode, this));
			
			var effectNode:RawTreeNode = ActionGetChild(":effect", childrenWithNameRemoved);
			action.SetEffectTree(Tree.ConvertRawTreeNodeToTree(effectNode, this));
			
			var parameterNode:RawTreeNode = ActionGetChild(":parameters", childrenWithNameRemoved);
			var pairs:Array<Pair<String, String>> = Utilities.GenerateValueTypeMap([parameterNode].concat(parameterNode.children));
			for (a in pairs)
			{
				action.GetData().AddParameter(a.a, a.b);
			}
			
			var valueNode:RawTreeNode = ActionGetChild(":values", childrenWithNameRemoved);
			if (valueNode != null)
			{
				
				var pairs:Array<Pair<String, String>> = Utilities.GenerateValueTypeMap([valueNode].concat(valueNode.children));
				var value:Value = null;
				for (pair in pairs)
				{
					switch(pair.b)
					{
						case "integer-range":
							action.GetData().AddValue(new ValueIntRange(pair.a, action));
					}
				}
			}
			
			actions.set(action.GetName(), action);
		}
		
		
		properties.set("actions", true);
	}
	
	function LinkActionsToPredicates()
	{
		for (action_name in actions.keys())
		{
			var action:Action = actions.get(action_name);
			for (predicate_name in predicates.keys())
			{
				Tree.Recursive(action.GetPreconditionTree().GetBaseNode(), 
					function(node_)
					{
						if (Utilities.Compare(node_.GetRawName(), predicate_name) == 0)
						{
							GetActionsWithPredicatePrecondition(predicate_name).push(action);
							return false;
						}
						return true;
					}
				);
				
				Tree.Recursive(action.GetEffectTree().GetBaseNode(), 
					function(node_)
					{
						if (Utilities.Compare(node_.GetRawName(), predicate_name) == 0)
						{
							GetActionsWithPredicateEffect(predicate_name).push(action);
							return false;
						}
						return true;
					}
				);
			}
		}
	}
	
	function LinkActionsAndFunctions()
	{
		
		for (action_name in actions.keys())
		{
			var action:Action = actions.get(action_name);
			for (function_name in functions.keys())
			{
				Tree.Recursive(action.GetPreconditionTree().GetBaseNode(), 
					function(node_)
					{
						if (Utilities.Compare(node_.GetRawName(), function_name) == 0)
						{
							GetActionsWithFunctionPrecondition(node_.GetRawTreeString()).push(action);
							GetAllFunctionsWithinActionPrecondition(action.GetName()).push(node_.GetRawTreeString());
							return false;
						}
						return true;
					}
				);
				
				Tree.Recursive(action.GetEffectTree().GetBaseNode(), 
					function(node_)
					{
						if (Utilities.Compare(node_.GetRawName(), function_name) == 0)
						{
							GetActionsWithFunctionEffect(node_.GetRawTreeString()).push(action);
							GetAllFunctionsWithinActionEffect(action.GetName()).push(node_.GetRawTreeString());
							return false;
						}
						return true;
					}
				);
			}
		}
		
	}
	
	/***
	 * 
	 *	For Actions
	 * 
	 **/
	
	public function GetActionsWithPredicatePrecondition(predicate_name_:String):Array<Action>
	{
		if (!predicate_action_precondition.exists(predicate_name_))
		{
			predicate_action_precondition.set(predicate_name_, new Array<Action>());
		}
		
		return predicate_action_precondition.get(predicate_name_);
	}
	
	public function GetActionsWithPredicateEffect(predicate_name_:String):Array<Action>
	{
		if (!predicate_action_effect.exists(predicate_name_))
		{
			predicate_action_effect.set(predicate_name_, new Array<Action>());
		}
		
		return predicate_action_effect.get(predicate_name_);
	}
	
	/***
	 * 
	 *	For Functions
	 * 
	 **/
	
	public function GetActionsWithFunctionPrecondition(function_name_:String):Array<Action>
	{
		if (!function_action_precondition.exists(function_name_))
		{
			function_action_precondition.set(function_name_, new Array<Action>());
		}
		
		return function_action_precondition.get(function_name_);
	}
	
	public function GetActionsWithFunctionEffect(function_name_:String):Array<Action>
	{
		if (!function_action_effect.exists(function_name_))
		{
			function_action_effect.set(function_name_, new Array<Action>());
		}
		
		return function_action_effect.get(function_name_);
	}
	
	public function GetAllFunctionsWithinActionPrecondition(action_name_:String):Array<String>
	{
		var action:Action = actions.get(action_name_);
		
		#if assert_debugging
		Utilities.Assert(action != null, "GetAllFunctionsWithinActionPrecondition has been called with a non-existant action: " + action_name_);
		#end
		
		if (!action_function_precondition.exists(action))
		{
			action_function_precondition.set(action, new Array<String>());
		}
		
		return action_function_precondition.get(action);
	}
	
	public function GetAllFunctionsWithinActionEffect(action_name_:String):Array<String>
	{
		var action:Action = actions.get(action_name_);
		
		#if assert_debugging
		Utilities.Assert(action != null, "GetAllFunctionsWithinActionPrecondition has been called with a non-existant action: " + action_name_);
		#end
		
		if (!action_function_effect.exists(action))
		{
			action_function_effect.set(action, new Array<String>());
		}
		
		return action_function_effect.get(action);
	}
	
	/***
	 * 
	 *	
	 * 
	 **/
	
	static function ActionGetChild(child_name_:String, children_:Array<RawTreeNode>):RawTreeNode
	{
		for (i in 0...children_.length)
		{
			if (Utilities.Compare(child_name_, children_[i].value) == 0)
			{
				return children_[i + 1];
			}
		}
		
		return null;
	}
	
	public function ResolveInheritance(typeChecking_:String, typeCheckAgainst_:String):Bool
	{
		if (Utilities.Compare(typeChecking_, typeCheckAgainst_) == 0)
		{
			return true;
		}
		
		var current:String = typeChecking_;
		
		// we want to break if the current type has a super type in the map. types that will not should likely
		// only be "object"
		while (types.Exists(current))
		{
			current = types.GetSuperType(current);
			
			if (Utilities.Compare(current, typeCheckAgainst_) == 0)
			{
				// we have found a correct type eg. the inheritance is correct
				return true;
			}
		}
		
		//we iterated through the hierarchy but did not find the typeCheckAgainst_ in typeChecking_'s hierarchy
		return false;
		
	}
	
	public function PredicateExists(name_:String):Bool
	{
		return predicates.exists(name_);
	}
	
	public function GetAction(name_:String):Action
	{
		return actions.get(name_);
	}
	
	public function GetAllActionNames():Iterator<String>
	{
		return actions.keys();
	}
	
	public function FunctionExists(name_:String):Bool
	{
		return functions.exists(name_);
	}
	
	public function HasProperty(string_:String):Bool
	{
		return properties.exists(string_);
	}
	
	public function GetTypes():Types
	{
		return types;
	}

	public function GetConstants():Array<Pair<String, String>>
	{
		return constants;
	}
	
	public function ConstantExists(constant_:String):Bool
	{
		for (const in constants)
		{
			if (Utilities.Compare(const.a, constant_) == 0)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function GetName():String
	{
		return domainName;
	}
	
}