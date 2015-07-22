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
	
	var types:Map<String, String> = new StringMap<String>();
	
	var predicates:Map<String, Predicate> = new StringMap<Predicate>();
	
	var actions:Map<String, Action> = new StringMap<Action>();
	
	public function new(domainFilePath_:String) 
	{
		domainTree = new RawTree();
		domainTree.SetupFromString(Utilities.CleanFileImport(domainFilePath_));
		
		for (i in domainTree.GetBaseNode().children)
		{
			trace(i.value);
		}
		
		// this gets the scope of the domain name, which only returns an array with a single element as there
		// are never 2 definitions for the domain name. We then split this value into two strings due to the value
		// being eg. "domain trucks", where trucks is the name we want.
		domainName = domainTree.GetBaseNode().GetChildrenWithContainingValue("domain")[0].value.split(" ")[1];
		
		ParseRequirements(domainTree.GetBaseNode().GetChildrenWithContainingValue(":requirements")[0]);
		
		ParseTypes(domainTree.GetBaseNode().GetChildrenWithContainingValue(":types")[0]);
		
		ParsePredicates(domainTree.GetBaseNode().GetChildrenWithContainingValue(":predicates")[0]);
		
		ParseActions(domainTree.GetBaseNode().GetChildrenWithContainingValue(":action"));
		
	}
	
	function ParseRequirements(node_:RawTreeNode)
	{
		
		var split:Array<String> = node_.value.split(" ");
		
		for (i in 1...split.length)
		{
			requirements.push(split[i]);
		}
		
	}
	
	function ParseTypes(node_:RawTreeNode)
	{		
		var split:Array<String> = node_.value.split(" ");
		
		var pairs = Utilities.GenerateValueTypeMap(split.slice(1));
		
		for (i in pairs)
		{
			types.set(i.a, i.b);
		}
	}
	
	function ParsePredicates(parentNode_:RawTreeNode)
	{
		
		var predicateNodes:Array<RawTreeNode> = parentNode_.children;
		
		for (i in predicateNodes)
		{
			var predicate:Predicate = new Predicate(i.value);
			predicates.set(predicate.GetName(), predicate);
		}
		
	}
	
	function ParseActions(actionNodes_:Array<RawTreeNode>)
	{
		
		for (i in actionNodes_)
		{
			var split:Array<String> = i.value.split(" ");
			var action:Action = new Action(StringTools.trim(split[1]));
			
			// index 0 is ":action" whilst index 1 is the name of the action, as shown above
			var index:Int = 2;
			while (index < split.length)
			{
				trace("on: " + split[index]);
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
					trace("precondition: " + (index - 2));
					var preconditionNode:RawTreeNode = i.children[index - 2];
					action.SetPreconditionTree(Tree.ConvertRawTreeNodeToTree(preconditionNode, this));
				}
				else if (Utilities.Compare(split[index], ":effect") == 0)
				{
					trace("effect: " + (index - 2));
					var effectNode:RawTreeNode = i.children[index - 2];
					action.SetEffectTree(Tree.ConvertRawTreeNodeToTree(effectNode, this));
				}
				
				index++;
			}
			
			actions.set(action.GetName(), action);
		}
		
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
		while (types.exists(current))
		{
			current = types.get(current);
			
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
	
}