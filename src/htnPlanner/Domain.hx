package htnPlanner;

import cpp.Void;
import haxe.ds.HashMap;
import haxe.ds.StringMap;
import haxe.io.Eof;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

/**
 * ...
 * @author Michael Stephens
 */
class Domain
{
	var domainName:String = null;
	
	var domainTree:Tree = null;
	
	var requirements:Array<String> = new Array<String>();
	
	var types:Map<String, String> = new StringMap<String>();
	
	var predicates:Map<String, Predicate> = new StringMap<Predicate>();
	
	public var actions:Map<String, Action> = new StringMap<Action>();
	
	public function new(domainFilePath_:String) 
	{
		var fileContent = File.getContent(domainFilePath_);
		
		domainTree = new Tree();
		domainTree.SetupFromString(fileContent);
		
		// this gets the scope of the domain name, which only returns an array with a single element as there
		// are never 2 definitions for the domain name. We then split this value into two strings due to the value
		// being eg. "domain trucks", where trucks is the name we want.
		domainName = domainTree.GetBaseNode().GetChildrenWithContainingValue("domain")[0].value.split(" ")[1];
		
		ParseRequirements(domainTree.GetBaseNode().GetChildrenWithContainingValue(":requirements")[0]);
		
		ParseTypes(domainTree.GetBaseNode().GetChildrenWithContainingValue(":types")[0]);
		
		ParsePredicates(domainTree.GetBaseNode().GetChildrenWithContainingValue(":predicates")[0]);
		
		ParseActions(domainTree.GetBaseNode().GetChildrenWithContainingValue(":action"));
		
	}
	
	function ParseRequirements(node_:TreeNode)
	{
		
		var split:Array<String> = node_.value.split(" ");
		
		for (i in 1...split.length)
		{
			requirements.push(split[i]);
		}
		
	}
	
	function ParseTypes(node_:TreeNode)
	{		
		var split:Array<String> = node_.value.split(" ");
		
		types = Utilities.GenerateValueTypeMap(split.slice(1));
	}
	
	function ParsePredicates(parentNode_:TreeNode)
	{
		
		var predicateNodes:Array<TreeNode> = parentNode_.children;
		
		for (i in predicateNodes)
		{
			var predicate:Predicate = new Predicate(i.value);
			predicates.set(predicate.firstPartOfValue, predicate);
		}
		
	}
	
	function ParseActions(actionNodes_:Array<TreeNode>)
	{
		
		for (i in actionNodes_)
		{
			var split:Array<String> = i.value.split(" ");
			var action:Action = new Action(StringTools.trim(split[1]));
			
			// index 0 is ":action" whilst index 1 is the name of the action, as shown above
			var index:Int = 2;
			while (index < split.length)
			{
				
				// we do index - 2 below because of the 2 indexs we have to skip
				// this gives us a corresponding child node with correct scope for each key word such as parameters.
				
				if (Utilities.Compare(split[index], ":parameters") == 0)
				{
					var map:Map<String, String> = Utilities.GenerateValueTypeMap(i.children[index - 2].value.split(" "));
					
					for (key in map.keys())
					{
						action.AddParameter(key, map.get(key));
					}
				}
				else if (Utilities.Compare(split[index], ":precondition") == 0)
				{
					var preconditionNode:TreeNode = i.children[index - 2];
					action.SetPreconditionTree(preconditionNode);
				}
				else if (Utilities.Compare(split[index], ":effect") == 0)
				{
					var effectNode:TreeNode = i.children[index - 2];
					action.SetEffectTree(effectNode);
				}
				
				index++;
			}
			
			actions.set(action.GetName(), action);
		}
		
	}
	
}