package htnPlanner;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

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
	
	var predicates:Map<String, Predicate> = new StringMap<Predicate>();
	
	var functions:Map<String, Function> = new StringMap<Function>();
	
	var actions:Map<String, Action> = new StringMap<Action>();
	
	var constants:Array<Pair> = new Array<Pair>();
	
	var properties:Map<String, Bool> = new Map<String, Bool>();
	
	public function new(domainFilePath_:String) 
	{
		domainTree = new RawTree();
		domainTree.SetupFromString(Utilities.CleanFileImport(domainFilePath_));
		
		// this gets the scope of the domain name, which only returns an array with a single element as there
		// are never 2 definitions for the domain name. We then split this value into two strings due to the value
		// being eg. "domain trucks", where trucks is the name we want.
		domainName = domainTree.GetBaseNode().GetChildrenWithContainingValue("domain")[0].value.split(" ")[1];
		
		ParseRequirements(domainTree.GetBaseNode().GetChildrenWithContainingValue(":requirements")[0]);
		
		ParseTypes(domainTree.GetBaseNode().GetChildrenWithContainingValue(":types")[0]);
		
		ParsePredicates(domainTree.GetBaseNode().GetChildrenWithContainingValue(":predicates")[0]);
		
		var functionsNodes:Array<RawTreeNode> = domainTree.GetBaseNode().GetChildrenWithContainingValue(":functions");
		if (functionsNodes.length > 0)
		{
			ParseFunctions(functionsNodes[0]);
		}
		
		ParseActions(domainTree.GetBaseNode().GetChildrenWithContainingValue(":action"));
		
		var constantsNodes:Array<RawTreeNode> = domainTree.GetBaseNode().GetChildrenWithContainingValue(":constants");
		if (constantsNodes.length > 0)
		{
			ParseConstants(constantsNodes[0]);
		}
		
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
		constants = Utilities.GenerateValueTypeMap(node_.value.split(" ").slice(1));
		
		properties.set("constants", true);
	}
	
	function ParsePredicates(parentNode_:RawTreeNode)
	{
		
		var predicateNodes:Array<RawTreeNode> = parentNode_.children;
		
		for (i in predicateNodes)
		{
			var predicate:Predicate = new Predicate(i.value);
			predicates.set(predicate.GetName(), predicate);
		}
		
		properties.set("predicates", true);
	}
	
	function ParseFunctions(parentNode_:RawTreeNode)
	{
		var functionNodes:Array<RawTreeNode> = parentNode_.children;
		
		for (i in functionNodes)
		{
			var newFunction:Function = new Function(i.value);
			functions.set(newFunction.GetName(), newFunction);
		}
		
		properties.set("functions", true);
	}
	
	function ParseActions(actionNodes_:Array<RawTreeNode>)
	{
		
		for (i in actionNodes_)
		{
			var split:Array<String> = i.value.split(" ").filter(function(input) {
				return input.length > 0;
			});
			
			var action:Action = new Action(StringTools.trim(split[1]));
			
			// index 0 is ":action" whilst index 1 is the name of the action, as shown above
			var index:Int = 2;
			while (index < split.length)
			{
				// we do index - 2 below because of the 2 indexs we have to skip
				// this gives us a corresponding child node with correct scope for each key word such as parameters.
				
				if (Utilities.Compare(split[index], ":parameters") == 0)
				{
					var pairs:Array<Pair> = Utilities.GenerateValueTypeMap(i.children[index - 2].value.split(" "));
					
					for (a in pairs)
					{
						action.AddParameter(a.a, a.b);
					}
				}
				else if (Utilities.Compare(split[index], ":precondition") == 0)
				{
					var preconditionNode:RawTreeNode = i.children[index - 2];
					action.SetPreconditionTree(Tree.ConvertRawTreeNodeToTree(preconditionNode, this));
				}
				else if (Utilities.Compare(split[index], ":effect") == 0)
				{
					var effectNode:RawTreeNode = i.children[index - 2];
					action.SetEffectTree(Tree.ConvertRawTreeNodeToTree(effectNode, this));
				}
				
				index++;
			}
			
			actions.set(action.GetName(), action);
		}
		
		
		properties.set("actions", true);
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
	
	public function GetPredicate(name_:String):Predicate
	{
		return predicates.get(name_);
	}
	
	public function GetAction(name_:String):Action
	{
		return actions.get(name_);
	}
	
	public function GetAllActionNames():Iterator<String>
	{
		return actions.keys();
	}
	
	public function GetFunction(name_:String):Function
	{
		return functions.get(name_);
	}
	
	public function HasProperty(string_:String):Bool
	{
		return properties.exists(string_);
	}
	
	public function GetTypes():Types
	{
		return types;
	}

	public function GetConstants():Array<Pair>
	{
		return constants;
	}
}