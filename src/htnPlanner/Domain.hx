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
		
		// used to cache which values are the same, so that when a type is hit, we can set them correctly
		var currentSetOfValues:Array<String> = new Array<String>();
		
		// this indicator is used to define a type being set for values. it is flipped when a "-" is met
		var indicator:Bool = false;
		
		// set it to 1 since the first element in split is ":types"
		var index:Int = 1;
		while (index < split.length) // dont ask about god damn while loops since someone on the haxe development team had the bright idea of 
		// not allowing normal for loops. cant use foreach since they dont allow manual changing of the iterator
		{
			// check to see if the current element is empty
			if (Utilities.Compare(split[index], "") != 0)
			{
				// indicator value declaring that the next element is a type
				if (Utilities.Compare(split[index], "-") == 0)
				{
					indicator = true;
				}
				else
				{
					
					if (!indicator)
					{
						// indicator has not been set yet, so the next value is not the type
						currentSetOfValues.push(split[index]);
					}
					else
					{
						// indicator has been set, so lets set all our current values to the type
						
						for (i in currentSetOfValues)
						{
							// need to trim since the endline character might be included here
							types.set(i, StringTools.trim(split[index]));
						}
						
						currentSetOfValues = new Array<String>(); // reset the array (why is there no clear function? T_T)
						
						indicator = false;
					}
				}
			}
			
			index++;
		}
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
	
}