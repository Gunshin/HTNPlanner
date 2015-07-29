package htnPlanner;

import haxe.ds.HashMap;
import haxe.ds.StringMap;

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
	var objects:Array<Pair> = new Array<Pair>();
	
	
	var goal:RawTree = null;

	public function new(problemFilePath_:String) 
	{		
		problemTree = new RawTree();
		problemTree.SetupFromString(Utilities.CleanFileImport(problemFilePath_));
		
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
		objects = Utilities.GenerateValueTypeMap(node_.value.split(" ").slice(1));
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
	
	public function GetClonedInitialState():State
	{
		
		return initialState.Clone();
		
	}
	
}