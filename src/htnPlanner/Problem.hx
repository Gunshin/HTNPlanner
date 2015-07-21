package htnPlanner;

import haxe.ds.HashMap;
import haxe.ds.StringMap;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

/**
 * ...
 * @author Michael Stephens
 */
class Problem
{
	var problemName:String = null;
	
	var problemTree:RawTree = null;
	
	var domainName:String = null;
	
	var initialState:State = new State();
	
	var goal:RawTree = null;

	public function new(problemFilePath_:String) 
	{
		var fileContent = File.getContent(problemFilePath_);
		
		problemTree = new RawTree();
		problemTree.SetupFromString(fileContent);
		
		// this gets the scope of the problem name, which only returns an array with a single element as there
		// are never 2 definitions for the problem name. We then split this value into two strings due to the value
		// being eg. "problem truck-12", where truck-12 is the name we want.
		problemName = problemTree.GetBaseNode().GetChildrenWithContainingValue("problem")[0].value.split(" ")[1];
		
		// same as above eg. ":domain Trucks"
		domainName = problemTree.GetBaseNode().GetChildrenWithContainingValue(":domain")[0].value.split(" ")[1];
		
		ParseObjects(problemTree.GetBaseNode().GetChildrenWithContainingValue(":objects")[0]);
		
		ParseInit(problemTree.GetBaseNode().GetChildrenWithContainingValue(":init")[0]);
		
		ParseGoal(problemTree.GetBaseNode().GetChildrenWithContainingValue(":goal")[0]);
	}
	
	function ParseObjects(node_:RawTreeNode)
	{
		
		var pairs:Array<Pair> = Utilities.GenerateValueTypeMap(node_.value.split(" ").slice(1));
		
		for (i in pairs)
		{
			
			initialState.AddRelation(i.a + " " + i.b);
			
		}
	}
	
	function ParseInit(node_:RawTreeNode)
	{
		
		var children:Array<RawTreeNode> = node_.children;
		
		for (i in children)
		{
			initialState.AddRelation(i.value);
		}
	}
	
	function ParseGoal(node_:RawTreeNode)
	{
		
		// for now just leaving goal as a tree that can be evaluated
		goal = new RawTree();
		goal.SetupFromNode(node_);
		
	}
	
}